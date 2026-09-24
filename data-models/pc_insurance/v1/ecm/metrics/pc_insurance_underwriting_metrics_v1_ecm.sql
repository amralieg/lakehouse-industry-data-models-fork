-- Metric views for domain: underwriting | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`underwriting_uw_guideline`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Underwriting guideline metrics tracking risk appetite, eligibility criteria, coverage limits, deductibles, and referral triggers across lines of business, geographies, and catastrophe zones."
  source: "`vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline`"
  dimensions:
    - name: "guideline_code"
      expr: guideline_code
      comment: "Unique code identifying the underwriting guideline."
    - name: "guideline_name"
      expr: guideline_name
      comment: "Business name of the underwriting guideline."
    - name: "guideline_type"
      expr: guideline_type
      comment: "Type of guideline (e.g., eligibility, pricing, referral)."
    - name: "uw_guideline_status"
      expr: uw_guideline_status
      comment: "Current status of the guideline (active, expired, pending)."
    - name: "state_code"
      expr: state_code
      comment: "State jurisdiction where the guideline applies."
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the guideline became effective."
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the guideline became effective."
    - name: "approval_year"
      expr: YEAR(approval_date)
      comment: "Year the guideline was approved."
    - name: "approved_by"
      expr: approved_by
      comment: "Person or role who approved the guideline."
    - name: "version_number"
      expr: version_number
      comment: "Version number of the guideline."
    - name: "inspection_required_flag"
      expr: inspection_required_flag
      comment: "Whether physical inspection is required."
    - name: "credit_score_required_flag"
      expr: credit_score_required_flag
      comment: "Whether credit score check is required."
    - name: "clue_required_flag"
      expr: clue_required_flag
      comment: "Whether CLUE report is required."
    - name: "mvr_required_flag"
      expr: mvr_required_flag
      comment: "Whether motor vehicle record check is required."
    - name: "risk_appetite_description"
      expr: risk_appetite_description
      comment: "Description of the insurer's risk appetite for this guideline."
    - name: "eligibility_criteria"
      expr: eligibility_criteria
      comment: "Criteria that must be met for a risk to be eligible."
    - name: "declination_reasons"
      expr: declination_reasons
      comment: "Reasons a submission may be declined under this guideline."
    - name: "referral_triggers"
      expr: referral_triggers
      comment: "Conditions that trigger referral to senior underwriter."
  measures:
    - name: "guideline_count"
      expr: COUNT(1)
      comment: "Total number of underwriting guidelines."
    - name: "avg_coverage_limit_min"
      expr: AVG(CAST(coverage_limits_min AS DOUBLE))
      comment: "Average minimum coverage limit across guidelines."
    - name: "avg_coverage_limit_max"
      expr: AVG(CAST(coverage_limits_max AS DOUBLE))
      comment: "Average maximum coverage limit across guidelines."
    - name: "avg_deductible_min"
      expr: AVG(CAST(deductible_min AS DOUBLE))
      comment: "Average minimum deductible across guidelines."
    - name: "avg_deductible_max"
      expr: AVG(CAST(deductible_max AS DOUBLE))
      comment: "Average maximum deductible across guidelines."
    - name: "avg_tiv_min"
      expr: AVG(CAST(tiv_min AS DOUBLE))
      comment: "Average minimum total insured value threshold."
    - name: "avg_tiv_max"
      expr: AVG(CAST(tiv_max AS DOUBLE))
      comment: "Average maximum total insured value threshold."
    - name: "avg_credit_score_threshold"
      expr: AVG(CAST(credit_score_min_threshold AS DOUBLE))
      comment: "Average minimum credit score threshold across guidelines."
    - name: "avg_loss_history_years"
      expr: AVG(CAST(loss_history_years AS DOUBLE))
      comment: "Average number of years of loss history required."
    - name: "avg_max_prior_claims"
      expr: AVG(CAST(max_prior_claims_allowed AS DOUBLE))
      comment: "Average maximum prior claims allowed under guidelines."
    - name: "inspection_required_pct"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN inspection_required_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of guidelines requiring physical inspection."
    - name: "credit_score_required_pct"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN credit_score_required_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of guidelines requiring credit score check."
    - name: "clue_required_pct"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN clue_required_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of guidelines requiring CLUE report."
    - name: "mvr_required_pct"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN mvr_required_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of guidelines requiring motor vehicle record check."
    - name: "total_coverage_limit_min"
      expr: SUM(CAST(coverage_limits_min AS DOUBLE))
      comment: "Sum of minimum coverage limits across all guidelines."
    - name: "total_coverage_limit_max"
      expr: SUM(CAST(coverage_limits_max AS DOUBLE))
      comment: "Sum of maximum coverage limits across all guidelines."
    - name: "total_tiv_min"
      expr: SUM(CAST(tiv_min AS DOUBLE))
      comment: "Sum of minimum total insured value thresholds."
    - name: "total_tiv_max"
      expr: SUM(CAST(tiv_max AS DOUBLE))
      comment: "Sum of maximum total insured value thresholds."
    - name: "distinct_states"
      expr: COUNT(DISTINCT state_code)
      comment: "Number of distinct states covered by guidelines."
    - name: "distinct_guideline_types"
      expr: COUNT(DISTINCT guideline_type)
      comment: "Number of distinct guideline types in use."
    - name: "distinct_approvers"
      expr: COUNT(DISTINCT approved_by)
      comment: "Number of distinct approvers who have approved guidelines."
$$;