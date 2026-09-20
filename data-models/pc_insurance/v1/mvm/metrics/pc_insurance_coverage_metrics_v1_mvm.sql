-- Metric views for domain: coverage | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Submission lifecycle KPIs tracking quote conversion, referral rates, and risk appetite scoring for underwriting pipeline management."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`submission`"
  dimensions:
    - name: "submission_status"
      expr: submission_status
      comment: "Current status of the submission in the underwriting workflow."
    - name: "line_of_business"
      expr: line_of_business
      comment: "Insurance line of business for the submission."
    - name: "risk_state"
      expr: risk_state
      comment: "State where the insured risk is located."
    - name: "submission_type"
      expr: submission_type
      comment: "Type of submission (new business, renewal, etc.)."
    - name: "referral_required_flag"
      expr: referral_required_flag
      comment: "Whether the submission requires underwriter referral."
    - name: "inspection_required_flag"
      expr: inspection_required_flag
      comment: "Whether a physical inspection is required."
    - name: "submission_year"
      expr: YEAR(submission_date)
      comment: "Year the submission was received."
    - name: "submission_month"
      expr: DATE_TRUNC('MONTH', submission_date)
      comment: "Month the submission was received."
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
      comment: "Average risk appetite score indicating alignment with underwriting guidelines."
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score of submission applicants."
    - name: "quote_count_total"
      expr: SUM(CAST(quote_count AS DOUBLE))
      comment: "Total number of quotes generated from submissions."
    - name: "referral_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN referral_required_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of submissions requiring underwriter referral."
    - name: "inspection_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN inspection_required_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of submissions requiring physical inspection."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_quote`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Quote performance KPIs tracking bind rates, premium adequacy, and distribution channel effectiveness for pricing and sales optimization."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`quote`"
  dimensions:
    - name: "quote_status"
      expr: quote_status
      comment: "Current status of the quote (quoted, bound, declined, expired)."
    - name: "state_code"
      expr: state_code
      comment: "State where the risk is located."
    - name: "policy_type_code"
      expr: policy_type_code
      comment: "Type of policy being quoted."
    - name: "distribution_channel"
      expr: distribution_channel
      comment: "Distribution channel through which the quote was generated."
    - name: "rating_tier"
      expr: rating_tier
      comment: "Underwriting tier assigned to the quote."
    - name: "referral_flag"
      expr: referral_flag
      comment: "Whether the quote required underwriter referral."
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Whether the producer has binding authority for this quote."
    - name: "quote_year"
      expr: YEAR(quote_date)
      comment: "Year the quote was generated."
    - name: "quote_month"
      expr: DATE_TRUNC('MONTH', quote_date)
      comment: "Month the quote was generated."
  measures:
    - name: "quote_count"
      expr: COUNT(1)
      comment: "Total number of quotes generated."
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
      comment: "Sum of commission amounts across all quotes."
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate as a decimal."
    - name: "total_tax"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Sum of tax amounts across all quotes."
    - name: "total_fee"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Sum of fee amounts across all quotes."
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score assigned to quotes."
    - name: "avg_loss_free_years"
      expr: AVG(CAST(loss_free_years AS DOUBLE))
      comment: "Average number of loss-free years for quoted risks."
    - name: "bind_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN quote_status = 'Bound' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of quotes that were bound into policies."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Coverage-level KPIs tracking limits, deductibles, premium, and exposure units for portfolio risk and pricing analysis."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`coverage`"
  dimensions:
    - name: "coverage_status"
      expr: coverage_status
      comment: "Current status of the coverage (active, cancelled, expired)."
    - name: "basis"
      expr: basis
      comment: "Coverage basis (occurrence, claims-made, etc.)."
    - name: "iso_coverage_code"
      expr: iso_coverage_code
      comment: "ISO standard coverage code."
    - name: "naic_line_code"
      expr: naic_line_code
      comment: "NAIC line of business code."
    - name: "territory"
      expr: territory
      comment: "Rating territory for the coverage."
    - name: "underwriting_tier"
      expr: underwriting_tier
      comment: "Underwriting tier assigned to the coverage."
    - name: "deductible_type"
      expr: deductible_type
      comment: "Type of deductible applied to the coverage."
    - name: "rating_basis"
      expr: rating_basis
      comment: "Basis used for rating the coverage."
    - name: "is_mandatory_coverage"
      expr: is_mandatory_coverage
      comment: "Whether the coverage is mandatory for the policy."
    - name: "is_primary_coverage"
      expr: is_primary_coverage
      comment: "Whether this is the primary coverage on the policy."
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the coverage became effective."
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the coverage became effective."
  measures:
    - name: "coverage_count"
      expr: COUNT(1)
      comment: "Total number of coverages in force."
    - name: "total_premium"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Sum of premium amounts across all coverages."
    - name: "avg_premium"
      expr: AVG(CAST(premium_amount AS DOUBLE))
      comment: "Average premium per coverage."
    - name: "total_per_occurrence_limit"
      expr: SUM(CAST(per_occurrence_limit_amount AS DOUBLE))
      comment: "Sum of per-occurrence limit amounts across all coverages."
    - name: "avg_per_occurrence_limit"
      expr: AVG(CAST(per_occurrence_limit_amount AS DOUBLE))
      comment: "Average per-occurrence limit per coverage."
    - name: "total_aggregate_limit"
      expr: SUM(CAST(aggregate_limit_amount AS DOUBLE))
      comment: "Sum of aggregate limit amounts across all coverages."
    - name: "avg_aggregate_limit"
      expr: AVG(CAST(aggregate_limit_amount AS DOUBLE))
      comment: "Average aggregate limit per coverage."
    - name: "total_deductible"
      expr: SUM(CAST(deductible_amount AS DOUBLE))
      comment: "Sum of deductible amounts across all coverages."
    - name: "avg_deductible"
      expr: AVG(CAST(deductible_amount AS DOUBLE))
      comment: "Average deductible per coverage."
    - name: "total_exposure_units"
      expr: SUM(CAST(exposure_units AS DOUBLE))
      comment: "Sum of exposure units across all coverages."
    - name: "avg_rate"
      expr: AVG(CAST(rate AS DOUBLE))
      comment: "Average rate per coverage."
    - name: "avg_coinsurance_pct"
      expr: AVG(CAST(coinsurance_percentage AS DOUBLE))
      comment: "Average coinsurance percentage across coverages."
    - name: "avg_ceded_pct"
      expr: AVG(CAST(ceded_percentage AS DOUBLE))
      comment: "Average percentage of coverage ceded to reinsurance."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_limit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Limit structure KPIs tracking aggregate and per-occurrence limits, attachment points, and erosion for exposure management."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`limit`"
  dimensions:
    - name: "limit_type"
      expr: limit_type
      comment: "Type of limit (per occurrence, aggregate, combined single, etc.)."
    - name: "limit_status"
      expr: limit_status
      comment: "Current status of the limit (active, exhausted, etc.)."
    - name: "basis"
      expr: basis
      comment: "Basis on which the limit applies."
    - name: "scope"
      expr: scope
      comment: "Scope of the limit application."
    - name: "is_combined_single_limit"
      expr: is_combined_single_limit
      comment: "Whether this is a combined single limit."
    - name: "is_shared_limit"
      expr: is_shared_limit
      comment: "Whether this limit is shared across multiple coverages."
    - name: "is_stacked"
      expr: is_stacked
      comment: "Whether this limit can be stacked with other limits."
    - name: "erosion_method"
      expr: erosion_method
      comment: "Method by which the limit erodes (per claim, per occurrence, etc.)."
    - name: "reinstatement_provision"
      expr: reinstatement_provision
      comment: "Provision for reinstating the limit after exhaustion."
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the limit became effective."
  measures:
    - name: "limit_count"
      expr: COUNT(1)
      comment: "Total number of limit records."
    - name: "total_limit_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Sum of limit amounts across all limit records."
    - name: "avg_limit_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average limit amount per limit record."
    - name: "total_attachment_point"
      expr: SUM(CAST(attachment_point AS DOUBLE))
      comment: "Sum of attachment points across all limits."
    - name: "avg_attachment_point"
      expr: AVG(CAST(attachment_point AS DOUBLE))
      comment: "Average attachment point per limit."
    - name: "total_remaining_limit"
      expr: SUM(CAST(remaining_limit_amount AS DOUBLE))
      comment: "Sum of remaining limit amounts after erosion."
    - name: "avg_remaining_limit"
      expr: AVG(CAST(remaining_limit_amount AS DOUBLE))
      comment: "Average remaining limit per limit record."
    - name: "avg_reinstatement_premium_rate"
      expr: AVG(CAST(reinstatement_premium_rate AS DOUBLE))
      comment: "Average reinstatement premium rate as a decimal."
    - name: "limit_utilization_rate"
      expr: ROUND(100.0 * SUM(CAST(amount AS DOUBLE) - CAST(remaining_limit_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Percentage of limit amounts that have been utilized or eroded."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_deductible`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Deductible structure KPIs tracking deductible amounts, types, and waiver rates for claims cost-sharing analysis."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`deductible`"
  dimensions:
    - name: "deductible_type"
      expr: deductible_type
      comment: "Type of deductible (flat, percentage, disappearing, etc.)."
    - name: "basis"
      expr: basis
      comment: "Basis on which the deductible applies."
    - name: "application_method"
      expr: application_method
      comment: "Method by which the deductible is applied."
    - name: "waiver_flag"
      expr: waiver_flag
      comment: "Whether the deductible has been waived."
    - name: "applies_to_lae_flag"
      expr: applies_to_lae_flag
      comment: "Whether the deductible applies to loss adjustment expenses."
    - name: "applies_to_subrogation_flag"
      expr: applies_to_subrogation_flag
      comment: "Whether the deductible applies to subrogation recoveries."
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the deductible became effective."
  measures:
    - name: "deductible_count"
      expr: COUNT(1)
      comment: "Total number of deductible records."
    - name: "total_deductible_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Sum of deductible amounts across all deductible records."
    - name: "avg_deductible_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average deductible amount per deductible record."
    - name: "avg_percentage"
      expr: AVG(CAST(percentage AS DOUBLE))
      comment: "Average deductible percentage for percentage-based deductibles."
    - name: "total_aggregate_limit"
      expr: SUM(CAST(aggregate_limit AS DOUBLE))
      comment: "Sum of aggregate deductible limits."
    - name: "avg_minimum_deductible"
      expr: AVG(CAST(minimum_deductible_amount AS DOUBLE))
      comment: "Average minimum deductible amount."
    - name: "avg_maximum_deductible"
      expr: AVG(CAST(maximum_deductible_amount AS DOUBLE))
      comment: "Average maximum deductible amount."
    - name: "avg_disappearing_threshold"
      expr: AVG(CAST(disappearing_threshold AS DOUBLE))
      comment: "Average threshold at which disappearing deductibles phase out."
    - name: "avg_waiting_period_days"
      expr: AVG(CAST(waiting_period_days AS DOUBLE))
      comment: "Average waiting period in days before deductible applies."
    - name: "waiver_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN waiver_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of deductibles that have been waived."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_loss_history`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Prior loss KPIs tracking claim frequency, severity, and surcharge impact for underwriting risk assessment and pricing."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`loss_history`"
  dimensions:
    - name: "loss_type"
      expr: loss_type
      comment: "Type of loss (property, liability, auto, etc.)."
    - name: "loss_cause_code"
      expr: loss_cause_code
      comment: "Code representing the cause of the loss."
    - name: "claim_status"
      expr: claim_status
      comment: "Status of the claim associated with the loss."
    - name: "verification_status"
      expr: verification_status
      comment: "Status of loss verification by underwriting."
    - name: "at_fault_flag"
      expr: at_fault_flag
      comment: "Whether the insured was at fault for the loss."
    - name: "catastrophe_flag"
      expr: catastrophe_flag
      comment: "Whether the loss was part of a catastrophe event."
    - name: "excluded_from_rating_flag"
      expr: excluded_from_rating_flag
      comment: "Whether the loss is excluded from rating calculations."
    - name: "verified_flag"
      expr: verified_flag
      comment: "Whether the loss has been verified."
    - name: "within_lookback_flag"
      expr: within_lookback_flag
      comment: "Whether the loss falls within the underwriting lookback period."
    - name: "loss_year"
      expr: YEAR(loss_date)
      comment: "Year the loss occurred."
    - name: "loss_month"
      expr: DATE_TRUNC('MONTH', loss_date)
      comment: "Month the loss occurred."
  measures:
    - name: "loss_count"
      expr: COUNT(1)
      comment: "Total number of prior loss records."
    - name: "total_incurred"
      expr: SUM(CAST(incurred_amount AS DOUBLE))
      comment: "Sum of incurred amounts across all prior losses."
    - name: "avg_incurred"
      expr: AVG(CAST(incurred_amount AS DOUBLE))
      comment: "Average incurred amount per prior loss."
    - name: "total_paid"
      expr: SUM(CAST(paid_amount AS DOUBLE))
      comment: "Sum of paid amounts across all prior losses."
    - name: "avg_paid"
      expr: AVG(CAST(paid_amount AS DOUBLE))
      comment: "Average paid amount per prior loss."
    - name: "total_reserve"
      expr: SUM(CAST(reserve_amount AS DOUBLE))
      comment: "Sum of reserve amounts across all prior losses."
    - name: "total_surcharge"
      expr: SUM(CAST(surcharge_amount AS DOUBLE))
      comment: "Sum of surcharge amounts applied due to prior losses."
    - name: "avg_surcharge_pct"
      expr: AVG(CAST(surcharge_percentage AS DOUBLE))
      comment: "Average surcharge percentage applied to premiums."
    - name: "avg_loss_free_years"
      expr: AVG(CAST(loss_free_years AS DOUBLE))
      comment: "Average number of loss-free years for insureds with prior losses."
    - name: "avg_lookback_period_months"
      expr: AVG(CAST(lookback_period_months AS DOUBLE))
      comment: "Average lookback period in months used for underwriting."
    - name: "at_fault_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN at_fault_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of losses where the insured was at fault."
    - name: "catastrophe_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN catastrophe_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of losses that were catastrophe-related."
    - name: "verification_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN verified_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of losses that have been verified by underwriting."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_uw_decision`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Underwriting decision KPIs tracking approval rates, referral reasons, risk tiers, and SLA compliance for underwriting efficiency."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`"
  dimensions:
    - name: "decision_status"
      expr: decision_status
      comment: "Status of the underwriting decision (approved, declined, referred)."
    - name: "decision_type"
      expr: decision_type
      comment: "Type of underwriting decision."
    - name: "risk_tier"
      expr: risk_tier
      comment: "Risk tier assigned by underwriting."
    - name: "decline_reason_code"
      expr: decline_reason_code
      comment: "Code representing the reason for decline."
    - name: "referral_reason_code"
      expr: referral_reason_code
      comment: "Code representing the reason for referral."
    - name: "referral_priority"
      expr: referral_priority
      comment: "Priority level of the referral."
    - name: "underwriter_authority_level"
      expr: underwriter_authority_level
      comment: "Authority level of the underwriter making the decision."
    - name: "automated_decision_flag"
      expr: automated_decision_flag
      comment: "Whether the decision was made automatically by the system."
    - name: "override_flag"
      expr: override_flag
      comment: "Whether the decision was an override of automated rules."
    - name: "sla_met_flag"
      expr: sla_met_flag
      comment: "Whether the decision met the service level agreement."
    - name: "eligibility_flag"
      expr: eligibility_flag
      comment: "Whether the submission met eligibility criteria."
    - name: "appetite_match_flag"
      expr: appetite_match_flag
      comment: "Whether the submission matched risk appetite guidelines."
    - name: "decision_year"
      expr: YEAR(decision_timestamp)
      comment: "Year the underwriting decision was made."
    - name: "decision_month"
      expr: DATE_TRUNC('MONTH', decision_timestamp)
      comment: "Month the underwriting decision was made."
  measures:
    - name: "decision_count"
      expr: COUNT(1)
      comment: "Total number of underwriting decisions."
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score assigned by underwriting."
    - name: "total_modified_premium"
      expr: SUM(CAST(modified_premium_amount AS DOUBLE))
      comment: "Sum of premium amounts modified by underwriting decisions."
    - name: "avg_modified_premium"
      expr: AVG(CAST(modified_premium_amount AS DOUBLE))
      comment: "Average modified premium per underwriting decision."
    - name: "avg_modified_limit"
      expr: AVG(CAST(modified_limit_amount AS DOUBLE))
      comment: "Average modified limit amount per underwriting decision."
    - name: "avg_modified_deductible"
      expr: AVG(CAST(modified_deductible_amount AS DOUBLE))
      comment: "Average modified deductible amount per underwriting decision."
    - name: "avg_sla_actual_hours"
      expr: AVG(CAST(sla_actual_hours AS DOUBLE))
      comment: "Average actual hours taken to make underwriting decisions."
    - name: "avg_sla_target_hours"
      expr: AVG(CAST(sla_target_hours AS DOUBLE))
      comment: "Average target hours for underwriting decisions per SLA."
    - name: "approval_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN decision_status = 'Approved' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of underwriting decisions that were approved."
    - name: "decline_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN decision_status = 'Declined' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of underwriting decisions that were declined."
    - name: "referral_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN decision_status = 'Referred' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of underwriting decisions that required referral."
    - name: "sla_compliance_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN sla_met_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of underwriting decisions that met SLA targets."
    - name: "automated_decision_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN automated_decision_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of decisions made automatically without manual review."
    - name: "override_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN override_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of decisions that were manual overrides of automated rules."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`coverage_binder`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Binder lifecycle KPIs tracking temporary coverage issuance, conversion to policy, and binding authority utilization."
  source: "`vibe_pc_insurance_blog_v499`.`coverage`.`binder`"
  dimensions:
    - name: "binder_status"
      expr: binder_status
      comment: "Current status of the binder (active, converted, cancelled)."
    - name: "binding_authority_type"
      expr: binding_authority_type
      comment: "Type of binding authority granted to the producer."
    - name: "policy_type_code"
      expr: policy_type_code
      comment: "Type of policy covered by the binder."
    - name: "issuing_state"
      expr: issuing_state
      comment: "State where the binder was issued."
    - name: "replaced_by_policy_flag"
      expr: replaced_by_policy_flag
      comment: "Whether the binder has been replaced by a formal policy."
    - name: "bind_year"
      expr: YEAR(bind_date)
      comment: "Year the binder was issued."
    - name: "bind_month"
      expr: DATE_TRUNC('MONTH', bind_date)
      comment: "Month the binder was issued."
  measures:
    - name: "binder_count"
      expr: COUNT(1)
      comment: "Total number of binders issued."
    - name: "total_premium"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Sum of premium amounts across all binders."
    - name: "avg_premium"
      expr: AVG(CAST(premium_amount AS DOUBLE))
      comment: "Average premium per binder."
    - name: "total_coverage_limit"
      expr: SUM(CAST(coverage_limit_amount AS DOUBLE))
      comment: "Sum of coverage limit amounts across all binders."
    - name: "total_deductible"
      expr: SUM(CAST(deductible_amount AS DOUBLE))
      comment: "Sum of deductible amounts across all binders."
    - name: "total_insured_value"
      expr: SUM(CAST(total_insured_value AS DOUBLE))
      comment: "Sum of total insured values across all binders."
    - name: "total_commission"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Sum of commission amounts across all binders."
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate as a decimal."
    - name: "total_down_payment"
      expr: SUM(CAST(down_payment_amount AS DOUBLE))
      comment: "Sum of down payment amounts collected on binders."
    - name: "avg_term_days"
      expr: AVG(CAST(term_days AS DOUBLE))
      comment: "Average term length in days for binders."
    - name: "avg_binding_authority_limit"
      expr: AVG(CAST(binding_authority_limit AS DOUBLE))
      comment: "Average binding authority limit granted to producers."
    - name: "policy_conversion_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN replaced_by_policy_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of binders that were converted to formal policies."
$$;