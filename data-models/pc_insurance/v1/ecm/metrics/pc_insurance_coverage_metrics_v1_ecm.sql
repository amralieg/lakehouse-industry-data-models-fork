-- Metric views for domain: coverage | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Submission lifecycle KPIs: volume, conversion, cycle time, and risk appetite performance across lines of business and distribution channels."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`submission`"
  dimensions:
    - name: "submission_status"
      expr: submission_status
      comment: "Current status of the submission (Quoted, Bound, Declined, Withdrawn)."
    - name: "line_of_business"
      expr: line_of_business
      comment: "Line of business for the submission (Personal Auto, Homeowners, Commercial Property, etc.)."
    - name: "risk_state"
      expr: risk_state
      comment: "State where the insured risk is located."
    - name: "submission_type"
      expr: submission_type
      comment: "Type of submission (New Business, Renewal, Rewrite)."
    - name: "source"
      expr: source
      comment: "Origination channel (Agent Portal, Direct, Aggregator, API)."
    - name: "clearance_status"
      expr: clearance_status
      comment: "Clearance check result (Pass, Fail, Referral)."
    - name: "eligibility_status"
      expr: eligibility_status
      comment: "Eligibility check result (Eligible, Ineligible, Conditional)."
    - name: "submission_month"
      expr: DATE_TRUNC('MONTH', submission_date)
      comment: "Month of submission for trend analysis."
    - name: "inspection_required_flag"
      expr: inspection_required_flag
      comment: "Whether an inspection was required for underwriting."
    - name: "referral_required_flag"
      expr: referral_required_flag
      comment: "Whether underwriting referral was required."
  measures:
    - name: "submission_count"
      expr: COUNT(1)
      comment: "Total number of submissions received."
    - name: "total_estimated_premium"
      expr: SUM(CAST(estimated_annual_premium AS DOUBLE))
      comment: "Sum of estimated annual premium across all submissions."
    - name: "avg_estimated_premium"
      expr: AVG(CAST(estimated_annual_premium AS DOUBLE))
      comment: "Average estimated annual premium per submission."
    - name: "total_insured_value"
      expr: SUM(CAST(total_insured_value AS DOUBLE))
      comment: "Sum of total insured value across all submissions."
    - name: "avg_risk_appetite_score"
      expr: AVG(CAST(risk_appetite_score AS DOUBLE))
      comment: "Average risk appetite score across submissions."
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score of submission applicants."
    - name: "quote_count_total"
      expr: SUM(CAST(quote_count AS BIGINT))
      comment: "Total number of quotes generated from submissions."
    - name: "distinct_applicants"
      expr: COUNT(DISTINCT submission_applicant_party_id)
      comment: "Count of unique applicant parties across submissions."
    - name: "distinct_agencies"
      expr: COUNT(DISTINCT agency_id)
      comment: "Count of unique agencies submitting business."
    - name: "distinct_producers"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Count of unique producers submitting business."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_quote`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Quote performance KPIs: volume, premium, conversion, referral rates, and distribution effectiveness across products and territories."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`quote`"
  dimensions:
    - name: "quote_status"
      expr: quote_status
      comment: "Current status of the quote (Quoted, Bound, Declined, Expired)."
    - name: "state_code"
      expr: state_code
      comment: "State where the risk is located."
    - name: "distribution_channel"
      expr: distribution_channel
      comment: "Distribution channel (Agent, Broker, Direct, Aggregator)."
    - name: "rating_tier"
      expr: rating_tier
      comment: "Rating tier assigned to the quote (Preferred, Standard, Non-Standard)."
    - name: "payment_plan_code"
      expr: payment_plan_code
      comment: "Payment plan selected (Annual, Semi-Annual, Quarterly, Monthly)."
    - name: "policy_type_code"
      expr: policy_type_code
      comment: "Type of policy quoted (Personal Auto, Homeowners, Commercial Property, etc.)."
    - name: "referral_flag"
      expr: referral_flag
      comment: "Whether the quote required underwriting referral."
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Whether the producer has binding authority for this quote."
    - name: "quote_month"
      expr: DATE_TRUNC('MONTH', quote_date)
      comment: "Month of quote for trend analysis."
    - name: "loss_free_years_band"
      expr: CASE WHEN loss_free_years >= 5 THEN '5+ Years' WHEN loss_free_years >= 3 THEN '3-4 Years' WHEN loss_free_years >= 1 THEN '1-2 Years' ELSE 'Less than 1 Year' END
      comment: "Loss-free years banded for segmentation."
  measures:
    - name: "quote_count"
      expr: COUNT(1)
      comment: "Total number of quotes issued."
    - name: "total_quoted_premium"
      expr: SUM(CAST(quoted_premium_amount AS DOUBLE))
      comment: "Sum of quoted premium across all quotes."
    - name: "avg_quoted_premium"
      expr: AVG(CAST(quoted_premium_amount AS DOUBLE))
      comment: "Average quoted premium per quote."
    - name: "total_base_premium"
      expr: SUM(CAST(base_premium_amount AS DOUBLE))
      comment: "Sum of base premium before fees and taxes."
    - name: "total_commission"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total commission amount across all quotes."
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate across quotes."
    - name: "total_tax"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax amount across all quotes."
    - name: "total_fee"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total fee amount across all quotes."
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score across quotes."
    - name: "distinct_submissions"
      expr: COUNT(DISTINCT submission_id)
      comment: "Count of unique submissions that generated quotes."
    - name: "distinct_agencies"
      expr: COUNT(DISTINCT agency_id)
      comment: "Count of unique agencies receiving quotes."
    - name: "distinct_producers"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Count of unique producers receiving quotes."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Coverage KPIs: exposure, premium, limit utilization, and cession performance across lines, perils, and territories."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`coverage`"
  dimensions:
    - name: "coverage_status"
      expr: coverage_status
      comment: "Current status of the coverage (Active, Cancelled, Expired)."
    - name: "basis"
      expr: basis
      comment: "Coverage basis (Occurrence, Claims-Made, Per-Event)."
    - name: "rating_basis"
      expr: rating_basis
      comment: "Rating basis for premium calculation (Area, Units, Payroll, Sales)."
    - name: "deductible_type"
      expr: deductible_type
      comment: "Type of deductible (Flat, Percentage, Disappearing)."
    - name: "territory"
      expr: territory
      comment: "Territory code for the coverage."
    - name: "underwriting_tier"
      expr: underwriting_tier
      comment: "Underwriting tier assigned (Preferred, Standard, Non-Standard)."
    - name: "valuation_method"
      expr: valuation_method
      comment: "Valuation method (Replacement Cost, Actual Cash Value, Agreed Value)."
    - name: "is_mandatory_coverage"
      expr: is_mandatory_coverage
      comment: "Whether the coverage is mandatory for the policy."
    - name: "is_primary_coverage"
      expr: is_primary_coverage
      comment: "Whether this is the primary coverage on the policy."
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the coverage became effective."
  measures:
    - name: "coverage_count"
      expr: COUNT(1)
      comment: "Total number of coverages in force."
    - name: "total_premium"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Sum of premium across all coverages."
    - name: "avg_premium"
      expr: AVG(CAST(premium_amount AS DOUBLE))
      comment: "Average premium per coverage."
    - name: "total_per_occurrence_limit"
      expr: SUM(CAST(per_occurrence_limit_amount AS DOUBLE))
      comment: "Sum of per-occurrence limits across coverages."
    - name: "total_aggregate_limit"
      expr: SUM(CAST(aggregate_limit_amount AS DOUBLE))
      comment: "Sum of aggregate limits across coverages."
    - name: "avg_per_occurrence_limit"
      expr: AVG(CAST(per_occurrence_limit_amount AS DOUBLE))
      comment: "Average per-occurrence limit per coverage."
    - name: "total_deductible"
      expr: SUM(CAST(deductible_amount AS DOUBLE))
      comment: "Sum of deductible amounts across coverages."
    - name: "avg_deductible"
      expr: AVG(CAST(deductible_amount AS DOUBLE))
      comment: "Average deductible per coverage."
    - name: "total_exposure_units"
      expr: SUM(CAST(exposure_units AS DOUBLE))
      comment: "Sum of exposure units across coverages."
    - name: "avg_rate"
      expr: AVG(CAST(rate AS DOUBLE))
      comment: "Average rate per coverage."
    - name: "avg_coinsurance_pct"
      expr: AVG(CAST(coinsurance_percentage AS DOUBLE))
      comment: "Average coinsurance percentage across coverages."
    - name: "avg_ceded_pct"
      expr: AVG(CAST(ceded_percentage AS DOUBLE))
      comment: "Average ceded percentage to reinsurance."
    - name: "distinct_policy_terms"
      expr: COUNT(DISTINCT policy_term_id)
      comment: "Count of unique policy terms with coverages."
    - name: "distinct_insured_risks"
      expr: COUNT(DISTINCT insured_risk_id)
      comment: "Count of unique insured risks covered."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_rating_worksheet`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rating performance KPIs: premium calculation accuracy, override frequency, minimum premium application, and rating engine performance."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet`"
  dimensions:
    - name: "rating_status"
      expr: rating_status
      comment: "Status of the rating calculation (Complete, Error, Pending)."
    - name: "validation_status"
      expr: validation_status
      comment: "Validation status of the rating worksheet (Valid, Invalid, Warning)."
    - name: "state_code"
      expr: state_code
      comment: "State where the risk is rated."
    - name: "territory_code"
      expr: territory_code
      comment: "Territory code used in rating."
    - name: "policy_type_code"
      expr: policy_type_code
      comment: "Type of policy being rated."
    - name: "rating_calculation_method"
      expr: rating_calculation_method
      comment: "Method used for rating calculation (Manual, ISO, Proprietary)."
    - name: "rating_engine_name"
      expr: rating_engine_name
      comment: "Name of the rating engine used."
    - name: "rating_engine_version"
      expr: rating_engine_version
      comment: "Version of the rating engine."
    - name: "override_flag"
      expr: override_flag
      comment: "Whether the rating was manually overridden."
    - name: "minimum_premium_applied_flag"
      expr: minimum_premium_applied_flag
      comment: "Whether minimum premium was applied."
    - name: "rating_month"
      expr: DATE_TRUNC('MONTH', rating_effective_date)
      comment: "Month of rating for trend analysis."
  measures:
    - name: "rating_worksheet_count"
      expr: COUNT(1)
      comment: "Total number of rating worksheets processed."
    - name: "total_final_premium"
      expr: SUM(CAST(final_premium AS DOUBLE))
      comment: "Sum of final premium after all adjustments."
    - name: "total_manual_premium"
      expr: SUM(CAST(manual_premium AS DOUBLE))
      comment: "Sum of manual premium before modifiers."
    - name: "total_rated_premium"
      expr: SUM(CAST(rated_premium AS DOUBLE))
      comment: "Sum of rated premium before minimum premium check."
    - name: "total_minimum_premium"
      expr: SUM(CAST(minimum_premium AS DOUBLE))
      comment: "Sum of minimum premium thresholds."
    - name: "avg_base_rate"
      expr: AVG(CAST(base_rate AS DOUBLE))
      comment: "Average base rate across rating worksheets."
    - name: "avg_experience_modifier"
      expr: AVG(CAST(experience_modifier AS DOUBLE))
      comment: "Average experience modifier applied."
    - name: "avg_schedule_modifier"
      expr: AVG(CAST(schedule_modifier AS DOUBLE))
      comment: "Average schedule modifier applied."
    - name: "avg_increased_limits_factor"
      expr: AVG(CAST(increased_limits_factor AS DOUBLE))
      comment: "Average increased limits factor applied."
    - name: "avg_deductible_credit_factor"
      expr: AVG(CAST(deductible_credit_factor AS DOUBLE))
      comment: "Average deductible credit factor applied."
    - name: "total_credit_amount"
      expr: SUM(CAST(total_credit_amount AS DOUBLE))
      comment: "Sum of total credits applied."
    - name: "total_surcharge_amount"
      expr: SUM(CAST(total_surcharge_amount AS DOUBLE))
      comment: "Sum of total surcharges applied."
    - name: "avg_exposure_base"
      expr: AVG(CAST(exposure_base AS DOUBLE))
      comment: "Average exposure base used in rating."
    - name: "distinct_quotes"
      expr: COUNT(DISTINCT quote_id)
      comment: "Count of unique quotes rated."
    - name: "distinct_submissions"
      expr: COUNT(DISTINCT submission_id)
      comment: "Count of unique submissions rated."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_uw_decision`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Underwriting decision KPIs: approval rates, referral volume, decline reasons, cycle time, and risk tier distribution."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`"
  dimensions:
    - name: "decision_status"
      expr: decision_status
      comment: "Status of the underwriting decision (Approved, Declined, Referred, Pending)."
    - name: "decision_type"
      expr: decision_type
      comment: "Type of decision (Automated, Manual, Hybrid)."
    - name: "risk_tier"
      expr: risk_tier
      comment: "Risk tier assigned (Preferred, Standard, Non-Standard, Declined)."
    - name: "decline_reason_code"
      expr: decline_reason_code
      comment: "Primary reason code for decline."
    - name: "referral_reason_code"
      expr: referral_reason_code
      comment: "Primary reason code for referral."
    - name: "referral_priority"
      expr: referral_priority
      comment: "Priority level of the referral (High, Medium, Low)."
    - name: "underwriter_authority_level"
      expr: underwriter_authority_level
      comment: "Authority level of the underwriter making the decision."
    - name: "automated_decision_flag"
      expr: automated_decision_flag
      comment: "Whether the decision was fully automated."
    - name: "override_flag"
      expr: override_flag
      comment: "Whether the decision was manually overridden."
    - name: "approval_required_flag"
      expr: approval_required_flag
      comment: "Whether senior approval was required."
    - name: "decision_month"
      expr: DATE_TRUNC('MONTH', decision_effective_date)
      comment: "Month of decision for trend analysis."
  measures:
    - name: "decision_count"
      expr: COUNT(1)
      comment: "Total number of underwriting decisions made."
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score across decisions."
    - name: "avg_modified_premium"
      expr: AVG(CAST(modified_premium_amount AS DOUBLE))
      comment: "Average modified premium after underwriting adjustments."
    - name: "total_modified_premium"
      expr: SUM(CAST(modified_premium_amount AS DOUBLE))
      comment: "Sum of modified premium across decisions."
    - name: "avg_modified_limit"
      expr: AVG(CAST(modified_limit_amount AS DOUBLE))
      comment: "Average modified limit after underwriting adjustments."
    - name: "avg_modified_deductible"
      expr: AVG(CAST(modified_deductible_amount AS DOUBLE))
      comment: "Average modified deductible after underwriting adjustments."
    - name: "avg_sla_actual_hours"
      expr: AVG(CAST(sla_actual_hours AS DOUBLE))
      comment: "Average actual hours to decision."
    - name: "avg_sla_target_hours"
      expr: AVG(CAST(sla_target_hours AS DOUBLE))
      comment: "Average target hours for decision SLA."
    - name: "distinct_submissions"
      expr: COUNT(DISTINCT submission_id)
      comment: "Count of unique submissions with decisions."
    - name: "distinct_quotes"
      expr: COUNT(DISTINCT quote_id)
      comment: "Count of unique quotes with decisions."
    - name: "distinct_underwriters"
      expr: COUNT(DISTINCT uw_approved_by_party_id)
      comment: "Count of unique underwriters making decisions."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_uw_referral`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Underwriting referral KPIs: volume, cycle time, resolution outcomes, escalation patterns, and workload distribution."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral`"
  dimensions:
    - name: "referral_status"
      expr: referral_status
      comment: "Current status of the referral (Open, Resolved, Escalated, Closed)."
    - name: "referral_type"
      expr: referral_type
      comment: "Type of referral (Risk, Premium, Coverage, Compliance)."
    - name: "referral_reason_code"
      expr: referral_reason_code
      comment: "Primary reason code for the referral."
    - name: "resolution_outcome"
      expr: resolution_outcome
      comment: "Outcome of the referral (Approved, Declined, Modified, Withdrawn)."
    - name: "priority_level"
      expr: priority_level
      comment: "Priority level of the referral (High, Medium, Low)."
    - name: "authority_level_required"
      expr: authority_level_required
      comment: "Authority level required to resolve the referral."
    - name: "state_code"
      expr: state_code
      comment: "State where the referred risk is located."
    - name: "product_code"
      expr: product_code
      comment: "Product code for the referred submission."
    - name: "fraud_indicator_flag"
      expr: fraud_indicator_flag
      comment: "Whether fraud indicators were present."
    - name: "catastrophe_exposure_flag"
      expr: catastrophe_exposure_flag
      comment: "Whether catastrophe exposure triggered the referral."
    - name: "reinsurance_required_flag"
      expr: reinsurance_required_flag
      comment: "Whether reinsurance was required."
    - name: "referral_month"
      expr: DATE_TRUNC('MONTH', referral_created_timestamp)
      comment: "Month the referral was created."
  measures:
    - name: "referral_count"
      expr: COUNT(1)
      comment: "Total number of underwriting referrals."
    - name: "avg_premium_amount"
      expr: AVG(CAST(premium_amount AS DOUBLE))
      comment: "Average premium amount for referred submissions."
    - name: "total_premium_amount"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Sum of premium for referred submissions."
    - name: "avg_total_insured_value"
      expr: AVG(CAST(total_insured_value AS DOUBLE))
      comment: "Average total insured value for referred risks."
    - name: "total_insured_value"
      expr: SUM(CAST(total_insured_value AS DOUBLE))
      comment: "Sum of total insured value for referred risks."
    - name: "avg_prior_loss_amount"
      expr: AVG(CAST(prior_loss_amount AS DOUBLE))
      comment: "Average prior loss amount for referred risks."
    - name: "avg_prior_loss_count"
      expr: AVG(CAST(prior_loss_count AS DOUBLE))
      comment: "Average prior loss count for referred risks."
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score for referred submissions."
    - name: "avg_escalation_level"
      expr: AVG(CAST(escalation_level AS DOUBLE))
      comment: "Average escalation level across referrals."
    - name: "distinct_submissions"
      expr: COUNT(DISTINCT submission_id)
      comment: "Count of unique submissions with referrals."
    - name: "distinct_underwriters"
      expr: COUNT(DISTINCT uw_assigned_underwriter_party_id)
      comment: "Count of unique underwriters assigned to referrals."
    - name: "distinct_agencies"
      expr: COUNT(DISTINCT agency_id)
      comment: "Count of unique agencies with referrals."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_loss_history`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Loss history KPIs: prior loss frequency, severity, verification rates, and impact on underwriting and rating decisions."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`loss_history`"
  dimensions:
    - name: "loss_type"
      expr: loss_type
      comment: "Type of loss (Property, Liability, Auto Physical Damage, Bodily Injury)."
    - name: "loss_cause_code"
      expr: loss_cause_code
      comment: "Cause of loss code (Fire, Theft, Collision, Weather, etc.)."
    - name: "claim_status"
      expr: claim_status
      comment: "Status of the claim (Open, Closed, Reopened)."
    - name: "coverage_type"
      expr: coverage_type
      comment: "Type of coverage involved in the loss."
    - name: "verification_status"
      expr: verification_status
      comment: "Verification status of the loss (Verified, Unverified, Disputed)."
    - name: "verification_method"
      expr: verification_method
      comment: "Method used to verify the loss (CLUE, MVR, Carrier Contact, Adjuster Review)."
    - name: "at_fault_flag"
      expr: at_fault_flag
      comment: "Whether the insured was at fault."
    - name: "catastrophe_flag"
      expr: catastrophe_flag
      comment: "Whether the loss was catastrophe-related."
    - name: "excluded_from_rating_flag"
      expr: excluded_from_rating_flag
      comment: "Whether the loss was excluded from rating."
    - name: "within_lookback_flag"
      expr: within_lookback_flag
      comment: "Whether the loss falls within the underwriting lookback period."
    - name: "loss_year"
      expr: YEAR(loss_date)
      comment: "Year the loss occurred."
  measures:
    - name: "loss_history_count"
      expr: COUNT(1)
      comment: "Total number of prior loss records."
    - name: "total_incurred_amount"
      expr: SUM(CAST(incurred_amount AS DOUBLE))
      comment: "Sum of incurred amounts across prior losses."
    - name: "avg_incurred_amount"
      expr: AVG(CAST(incurred_amount AS DOUBLE))
      comment: "Average incurred amount per prior loss."
    - name: "total_paid_amount"
      expr: SUM(CAST(paid_amount AS DOUBLE))
      comment: "Sum of paid amounts across prior losses."
    - name: "avg_paid_amount"
      expr: AVG(CAST(paid_amount AS DOUBLE))
      comment: "Average paid amount per prior loss."
    - name: "total_reserve_amount"
      expr: SUM(CAST(reserve_amount AS DOUBLE))
      comment: "Sum of reserve amounts across prior losses."
    - name: "avg_reserve_amount"
      expr: AVG(CAST(reserve_amount AS DOUBLE))
      comment: "Average reserve amount per prior loss."
    - name: "total_surcharge_amount"
      expr: SUM(CAST(surcharge_amount AS DOUBLE))
      comment: "Sum of surcharge amounts applied due to prior losses."
    - name: "avg_surcharge_pct"
      expr: AVG(CAST(surcharge_percentage AS DOUBLE))
      comment: "Average surcharge percentage applied."
    - name: "avg_loss_free_years"
      expr: AVG(CAST(loss_free_years AS DOUBLE))
      comment: "Average loss-free years across insureds."
    - name: "avg_lookback_period_months"
      expr: AVG(CAST(lookback_period_months AS DOUBLE))
      comment: "Average lookback period in months."
    - name: "distinct_parties"
      expr: COUNT(DISTINCT party_id)
      comment: "Count of unique parties with loss history."
    - name: "distinct_submissions"
      expr: COUNT(DISTINCT submission_id)
      comment: "Count of unique submissions with loss history."
    - name: "distinct_insured_risks"
      expr: COUNT(DISTINCT insured_risk_id)
      comment: "Count of unique insured risks with loss history."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_inspection_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Inspection order KPIs: volume, cycle time, pass/fail rates, cost, and impact on underwriting decisions across property and auto lines."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order`"
  dimensions:
    - name: "order_status"
      expr: order_status
      comment: "Current status of the inspection order (Ordered, Scheduled, Completed, Cancelled)."
    - name: "order_type"
      expr: order_type
      comment: "Type of inspection (Property, MVR, CLUE, 4-Point, Wind Mitigation)."
    - name: "lob"
      expr: lob
      comment: "Line of business for the inspection."
    - name: "pass_fail_indicator"
      expr: pass_fail_indicator
      comment: "Pass/Fail result of the inspection."
    - name: "referral_required_flag"
      expr: referral_required_flag
      comment: "Whether underwriting referral was required based on inspection findings."
    - name: "vendor_name"
      expr: vendor_name
      comment: "Name of the inspection vendor."
    - name: "construction_type"
      expr: construction_type
      comment: "Construction type found during property inspection."
    - name: "occupancy_type"
      expr: occupancy_type
      comment: "Occupancy type found during property inspection."
    - name: "roof_condition"
      expr: roof_condition
      comment: "Roof condition found during property inspection."
    - name: "protection_class"
      expr: protection_class
      comment: "Protection class assigned based on inspection."
    - name: "mvr_license_status"
      expr: mvr_license_status
      comment: "Driver license status from MVR inspection."
    - name: "order_month"
      expr: DATE_TRUNC('MONTH', order_date)
      comment: "Month the inspection was ordered."
  measures:
    - name: "inspection_order_count"
      expr: COUNT(1)
      comment: "Total number of inspection orders."
    - name: "total_cost"
      expr: SUM(CAST(cost_amount AS DOUBLE))
      comment: "Sum of inspection costs."
    - name: "avg_cost"
      expr: AVG(CAST(cost_amount AS DOUBLE))
      comment: "Average cost per inspection."
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score from inspections."
    - name: "avg_roof_age_years"
      expr: AVG(CAST(roof_age_years AS DOUBLE))
      comment: "Average roof age in years from property inspections."
    - name: "avg_mvr_violation_count"
      expr: AVG(CAST(mvr_violation_count AS DOUBLE))
      comment: "Average violation count from MVR inspections."
    - name: "avg_mvr_accident_count"
      expr: AVG(CAST(mvr_accident_count AS DOUBLE))
      comment: "Average accident count from MVR inspections."
    - name: "distinct_submissions"
      expr: COUNT(DISTINCT submission_id)
      comment: "Count of unique submissions with inspections."
    - name: "distinct_locations"
      expr: COUNT(DISTINCT location_id)
      comment: "Count of unique locations inspected."
    - name: "distinct_vehicles"
      expr: COUNT(DISTINCT vehicle_id)
      comment: "Count of unique vehicles inspected."
    - name: "distinct_drivers"
      expr: COUNT(DISTINCT driver_id)
      comment: "Count of unique drivers with MVR inspections."
    - name: "distinct_vendors"
      expr: COUNT(DISTINCT vendor_code)
      comment: "Count of unique inspection vendors used."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_underwriting_risk_score`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Underwriting risk score KPIs: composite score distribution, component score analysis, override patterns, and predictive model performance."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score`"
  dimensions:
    - name: "score_band"
      expr: score_band
      comment: "Risk score band (Excellent, Good, Fair, Poor, Declined)."
    - name: "score_confidence_level"
      expr: score_confidence_level
      comment: "Confidence level of the score (High, Medium, Low)."
    - name: "score_model_name"
      expr: score_model_name
      comment: "Name of the scoring model used."
    - name: "score_model_version"
      expr: score_model_version
      comment: "Version of the scoring model."
    - name: "scoring_engine"
      expr: scoring_engine
      comment: "Scoring engine used (Proprietary, ISO, LexisNexis, etc.)."
    - name: "lob"
      expr: lob
      comment: "Line of business scored."
    - name: "state_code"
      expr: state_code
      comment: "State where the risk is located."
    - name: "protection_class"
      expr: protection_class
      comment: "Protection class assigned."
    - name: "auto_decline_flag"
      expr: auto_decline_flag
      comment: "Whether the score triggered automatic decline."
    - name: "override_flag"
      expr: override_flag
      comment: "Whether the score was manually overridden."
    - name: "uw_referral_flag"
      expr: uw_referral_flag
      comment: "Whether the score triggered underwriting referral."
    - name: "score_month"
      expr: DATE_TRUNC('MONTH', score_timestamp)
      comment: "Month the score was calculated."
  measures:
    - name: "risk_score_count"
      expr: COUNT(1)
      comment: "Total number of risk scores calculated."
    - name: "avg_composite_score"
      expr: AVG(CAST(composite_score AS DOUBLE))
      comment: "Average composite risk score."
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score component."
    - name: "avg_clue_score"
      expr: AVG(CAST(clue_score AS DOUBLE))
      comment: "Average CLUE score component."
    - name: "avg_mvr_score"
      expr: AVG(CAST(mvr_score AS DOUBLE))
      comment: "Average MVR score component."
    - name: "avg_catastrophe_score"
      expr: AVG(CAST(catastrophe_score AS DOUBLE))
      comment: "Average catastrophe score component."
    - name: "avg_territory_score"
      expr: AVG(CAST(territory_score AS DOUBLE))
      comment: "Average territory score component."
    - name: "avg_cope_score"
      expr: AVG(CAST(cope_score AS DOUBLE))
      comment: "Average COPE (Construction, Occupancy, Protection, Exposure) score."
    - name: "avg_prior_carrier_score"
      expr: AVG(CAST(prior_carrier_score AS DOUBLE))
      comment: "Average prior carrier score component."
    - name: "avg_occupancy_score"
      expr: AVG(CAST(occupancy_score AS DOUBLE))
      comment: "Average occupancy score component."
    - name: "avg_data_quality_score"
      expr: AVG(CAST(data_quality_score AS DOUBLE))
      comment: "Average data quality score."
    - name: "avg_itv_ratio"
      expr: AVG(CAST(itv_ratio AS DOUBLE))
      comment: "Average insurance-to-value ratio."
    - name: "avg_loss_free_years"
      expr: AVG(CAST(loss_free_years AS DOUBLE))
      comment: "Average loss-free years."
    - name: "avg_lapse_in_coverage_days"
      expr: AVG(CAST(lapse_in_coverage_days AS DOUBLE))
      comment: "Average lapse in coverage days."
    - name: "avg_claim_count_3yr"
      expr: AVG(CAST(claim_count_3yr AS DOUBLE))
      comment: "Average claim count in last 3 years."
    - name: "avg_claim_count_5yr"
      expr: AVG(CAST(claim_count_5yr AS DOUBLE))
      comment: "Average claim count in last 5 years."
    - name: "total_incurred_3yr"
      expr: SUM(CAST(total_incurred_3yr AS DOUBLE))
      comment: "Sum of total incurred in last 3 years."
    - name: "avg_years_with_prior_carrier"
      expr: AVG(CAST(years_with_prior_carrier AS DOUBLE))
      comment: "Average years with prior carrier."
    - name: "distinct_submissions"
      expr: COUNT(DISTINCT submission_id)
      comment: "Count of unique submissions scored."
    - name: "distinct_parties"
      expr: COUNT(DISTINCT party_id)
      comment: "Count of unique parties scored."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_bind_request`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Bind request KPIs: volume, approval rates, cycle time, down payment collection, and SLA performance across distribution channels."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`bind_request`"
  dimensions:
    - name: "bind_request_status"
      expr: bind_request_status
      comment: "Current status of the bind request (Pending, Approved, Rejected, Bound)."
    - name: "lob"
      expr: lob
      comment: "Line of business for the bind request."
    - name: "state_code"
      expr: state_code
      comment: "State where the policy will be bound."
    - name: "policy_type_code"
      expr: policy_type_code
      comment: "Type of policy being bound."
    - name: "payment_method"
      expr: payment_method
      comment: "Payment method selected (Credit Card, ACH, Check, Financed)."
    - name: "payment_plan_code"
      expr: payment_plan_code
      comment: "Payment plan selected (Annual, Semi-Annual, Quarterly, Monthly)."
    - name: "bind_authority_level"
      expr: bind_authority_level
      comment: "Authority level required to bind (Agent, Underwriter, Manager)."
    - name: "automated_bind_flag"
      expr: automated_bind_flag
      comment: "Whether the bind was fully automated."
    - name: "bind_conditions_met_flag"
      expr: bind_conditions_met_flag
      comment: "Whether all bind conditions were met."
    - name: "down_payment_received_flag"
      expr: down_payment_received_flag
      comment: "Whether down payment was received."
    - name: "inspection_required_flag"
      expr: inspection_required_flag
      comment: "Whether inspection was required before binding."
    - name: "sla_met_flag"
      expr: sla_met_flag
      comment: "Whether bind SLA was met."
    - name: "bind_month"
      expr: DATE_TRUNC('MONTH', bind_request_date)
      comment: "Month the bind request was submitted."
  measures:
    - name: "bind_request_count"
      expr: COUNT(1)
      comment: "Total number of bind requests."
    - name: "total_premium"
      expr: SUM(CAST(total_premium_amount AS DOUBLE))
      comment: "Sum of total premium for bind requests."
    - name: "avg_premium"
      expr: AVG(CAST(total_premium_amount AS DOUBLE))
      comment: "Average premium per bind request."
    - name: "total_down_payment"
      expr: SUM(CAST(down_payment_amount AS DOUBLE))
      comment: "Sum of down payment amounts."
    - name: "avg_down_payment"
      expr: AVG(CAST(down_payment_amount AS DOUBLE))
      comment: "Average down payment per bind request."
    - name: "avg_sla_actual_hours"
      expr: AVG(CAST(sla_actual_hours AS DOUBLE))
      comment: "Average actual hours to bind."
    - name: "avg_sla_target_hours"
      expr: AVG(CAST(sla_target_hours AS DOUBLE))
      comment: "Average target hours for bind SLA."
    - name: "distinct_submissions"
      expr: COUNT(DISTINCT submission_id)
      comment: "Count of unique submissions with bind requests."
    - name: "distinct_quotes"
      expr: COUNT(DISTINCT quote_id)
      comment: "Count of unique quotes with bind requests."
    - name: "distinct_agencies"
      expr: COUNT(DISTINCT agency_id)
      comment: "Count of unique agencies submitting bind requests."
    - name: "distinct_producers"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Count of unique producers submitting bind requests."
$$;