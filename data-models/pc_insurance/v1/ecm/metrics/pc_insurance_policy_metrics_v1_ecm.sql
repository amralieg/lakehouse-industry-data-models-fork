-- Metric views for domain: policy | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core policy metrics tracking written premium, insured value, policy counts, and portfolio composition by line of business, status, and regulatory state."
  source: "`vibe_pc_insurance_v499`.`policy`.`policy`"
  dimensions:
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code (e.g., commercial auto, homeowners, workers comp) for portfolio segmentation."
    - name: "policy_status"
      expr: policy_status
      comment: "Current policy status (active, cancelled, expired, pending) for portfolio health analysis."
    - name: "policy_type"
      expr: policy_type
      comment: "Policy type classification (new business, renewal, rewrite) for growth and retention analysis."
    - name: "regulatory_state"
      expr: regulatory_state_id
      comment: "Regulatory state jurisdiction for compliance and geographic performance analysis."
    - name: "business_type"
      expr: business_type
      comment: "Business type classification (personal lines, commercial lines) for market segment analysis."
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Policy effective year for trend analysis and vintage cohort tracking."
    - name: "effective_quarter"
      expr: CONCAT(CAST(YEAR(effective_date) AS STRING), '-Q', CAST(QUARTER(effective_date) AS STRING))
      comment: "Policy effective quarter for seasonal pattern analysis and quarterly performance tracking."
    - name: "term_months"
      expr: term_months
      comment: "Policy term length in months for term structure analysis."
    - name: "cat_exposure_flag"
      expr: cat_exposure_flag
      comment: "Catastrophe exposure indicator for risk concentration and reinsurance planning."
    - name: "underwriting_company_code"
      expr: underwriting_company_code
      comment: "Underwriting company code for multi-carrier portfolio analysis."
  measures:
    - name: "policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct count of policies for portfolio size and growth tracking."
    - name: "total_gwp"
      expr: SUM(CAST(gwp_amount AS DOUBLE))
      comment: "Total gross written premium for top-line revenue and production volume."
    - name: "total_nwp"
      expr: SUM(CAST(nwp_amount AS DOUBLE))
      comment: "Total net written premium after cancellations and adjustments for earned premium forecasting."
    - name: "total_insured_value"
      expr: SUM(CAST(total_insured_value AS DOUBLE))
      comment: "Total insured value across all policies for exposure aggregation and capacity planning."
    - name: "total_pml"
      expr: SUM(CAST(pml_amount AS DOUBLE))
      comment: "Total probable maximum loss for catastrophe risk assessment and reinsurance structuring."
    - name: "avg_gwp_per_policy"
      expr: AVG(CAST(gwp_amount AS DOUBLE))
      comment: "Average gross written premium per policy for pricing adequacy and market positioning analysis."
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate for distribution cost analysis and profitability assessment."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy transaction metrics tracking premium changes, transaction volume, and commission by transaction type, effective period, and line of business."
  source: "`vibe_pc_insurance_v499`.`policy`.`policy_transaction`"
  dimensions:
    - name: "transaction_type"
      expr: type_code
      comment: "Transaction type code (new business, endorsement, cancellation, renewal) for transaction mix analysis."
    - name: "transaction_status"
      expr: transaction_status
      comment: "Transaction status (pending, approved, rejected, reversed) for workflow efficiency tracking."
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code for transaction volume and premium change analysis by product line."
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Transaction effective year for annual trend analysis."
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Transaction effective month for monthly production tracking and seasonality analysis."
    - name: "booking_year_month"
      expr: DATE_TRUNC('MONTH', booking_date)
      comment: "Booking month for accounting period revenue recognition and financial reporting."
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Reversal indicator for transaction quality and error rate monitoring."
    - name: "cancellation_type"
      expr: cancellation_type
      comment: "Cancellation type (flat, short-rate, pro-rata) for retention analysis and unearned premium calculation."
    - name: "initiating_party_type"
      expr: initiating_party_type
      comment: "Party initiating transaction (insured, carrier, agent) for workflow and service quality analysis."
  measures:
    - name: "transaction_count"
      expr: COUNT(DISTINCT policy_transaction_id)
      comment: "Distinct count of policy transactions for operational volume and workflow capacity planning."
    - name: "total_written_premium"
      expr: SUM(CAST(written_premium_amount AS DOUBLE))
      comment: "Total written premium across all transactions for production volume and revenue tracking."
    - name: "total_premium_change"
      expr: SUM(CAST(premium_change_amount AS DOUBLE))
      comment: "Total premium change amount for endorsement impact and pricing adjustment analysis."
    - name: "total_commission"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total commission paid for distribution cost tracking and profitability analysis."
    - name: "total_fees"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total fees collected for ancillary revenue and administrative cost recovery."
    - name: "total_taxes"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total taxes collected for regulatory remittance and compliance reporting."
    - name: "total_transaction_amount"
      expr: SUM(CAST(total_transaction_amount AS DOUBLE))
      comment: "Total transaction amount including premium, fees, and taxes for cash flow and billing analysis."
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate for distribution cost benchmarking and producer compensation analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Coverage-level metrics tracking limits, deductibles, premium, and coverage mix by coverage status, line of business, and territory."
  source: "`vibe_pc_insurance_v499`.`policy`.`policy_coverage`"
  dimensions:
    - name: "coverage_status"
      expr: coverage_status
      comment: "Coverage status (active, deleted, suspended) for coverage portfolio health analysis."
    - name: "lob_code"
      expr: lob_code_id
      comment: "Line of business code for coverage mix and product performance analysis."
    - name: "territory_code"
      expr: territory_code
      comment: "Territory code for geographic rating and risk concentration analysis."
    - name: "deductible_type"
      expr: deductible_type
      comment: "Deductible type (flat, percentage, franchise) for retention strategy and claims cost analysis."
    - name: "limit_type"
      expr: limit_type
      comment: "Limit type (per occurrence, aggregate, combined) for exposure management and reinsurance structuring."
    - name: "optional_coverage_flag"
      expr: optional_coverage_flag
      comment: "Optional coverage indicator for attachment rate and cross-sell analysis."
    - name: "blanket_coverage_flag"
      expr: blanket_coverage_flag
      comment: "Blanket coverage indicator for multi-location and schedule rating analysis."
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Coverage effective year for trend analysis and vintage performance tracking."
    - name: "valuation_method"
      expr: valuation_method
      comment: "Valuation method (ACV, replacement cost, agreed value) for claims settlement and pricing analysis."
  measures:
    - name: "coverage_count"
      expr: COUNT(DISTINCT policy_coverage_id)
      comment: "Distinct count of coverages for coverage density and product mix analysis."
    - name: "total_limit"
      expr: SUM(CAST(limit_amount AS DOUBLE))
      comment: "Total coverage limit for exposure aggregation and capacity utilization tracking."
    - name: "total_deductible"
      expr: SUM(CAST(deductible_amount AS DOUBLE))
      comment: "Total deductible amount for retention analysis and claims cost forecasting."
    - name: "total_premium"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Total coverage premium for pricing adequacy and product profitability analysis."
    - name: "total_agreed_value"
      expr: SUM(CAST(agreed_value_amount AS DOUBLE))
      comment: "Total agreed value for valuation exposure and claims settlement planning."
    - name: "avg_limit_per_coverage"
      expr: AVG(CAST(limit_amount AS DOUBLE))
      comment: "Average limit per coverage for pricing benchmarking and market positioning."
    - name: "avg_deductible_per_coverage"
      expr: AVG(CAST(deductible_amount AS DOUBLE))
      comment: "Average deductible per coverage for retention strategy and claims frequency impact analysis."
    - name: "avg_rate"
      expr: AVG(CAST(rate AS DOUBLE))
      comment: "Average rate per coverage for pricing competitiveness and rate adequacy monitoring."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_quote`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Quote metrics tracking conversion, quoted premium, underwriting decisions, and quote volume by status, line of business, and producer."
  source: "`vibe_pc_insurance_v499`.`policy`.`quote`"
  dimensions:
    - name: "quote_status"
      expr: quote_status
      comment: "Quote status (draft, quoted, bound, declined, expired) for conversion funnel and sales effectiveness analysis."
    - name: "quote_type"
      expr: quote_type
      comment: "Quote type (new business, renewal, remarket) for quote mix and sales strategy analysis."
    - name: "lob"
      expr: lob
      comment: "Line of business for quote volume and conversion rate analysis by product line."
    - name: "rating_state"
      expr: rating_state
      comment: "Rating state for geographic quote activity and market penetration analysis."
    - name: "uw_tier"
      expr: uw_tier
      comment: "Underwriting tier (preferred, standard, substandard) for risk selection and pricing tier analysis."
    - name: "surplus_lines_flag"
      expr: surplus_lines_flag
      comment: "Surplus lines indicator for non-admitted market activity and regulatory compliance tracking."
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Binding authority indicator for delegated underwriting and producer authority analysis."
    - name: "quote_year"
      expr: YEAR(created_timestamp)
      comment: "Quote creation year for annual quote volume and conversion trend analysis."
    - name: "quote_month"
      expr: DATE_TRUNC('MONTH', created_timestamp)
      comment: "Quote creation month for monthly sales activity and seasonality tracking."
  measures:
    - name: "quote_count"
      expr: COUNT(DISTINCT quote_id)
      comment: "Distinct count of quotes for sales pipeline volume and market demand tracking."
    - name: "total_quoted_gwp"
      expr: SUM(CAST(quoted_gwp AS DOUBLE))
      comment: "Total quoted gross written premium for pipeline value and revenue forecasting."
    - name: "total_quoted_premium"
      expr: SUM(CAST(quoted_total_premium AS DOUBLE))
      comment: "Total quoted premium including taxes and fees for total customer cost analysis."
    - name: "total_tiv"
      expr: SUM(CAST(tiv AS DOUBLE))
      comment: "Total insured value quoted for exposure pipeline and capacity planning."
    - name: "total_pml"
      expr: SUM(CAST(pml AS DOUBLE))
      comment: "Total probable maximum loss quoted for catastrophe exposure pipeline and reinsurance planning."
    - name: "avg_quoted_gwp"
      expr: AVG(CAST(quoted_gwp AS DOUBLE))
      comment: "Average quoted gross written premium per quote for pricing strategy and market positioning."
    - name: "avg_uw_score"
      expr: AVG(CAST(uw_score AS DOUBLE))
      comment: "Average underwriting score for risk selection quality and portfolio risk profile analysis."
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score for credit-based pricing and risk segmentation analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_uw_decision`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Underwriting decision metrics tracking approval rates, declination reasons, risk scores, and premium adjustments by decision action, line of business, and risk tier."
  source: "`vibe_pc_insurance_v499`.`policy`.`uw_decision`"
  dimensions:
    - name: "decision_action"
      expr: decision_action
      comment: "Underwriting decision action (approve, decline, refer, quote) for approval rate and referral analysis."
    - name: "decision_status"
      expr: decision_status
      comment: "Decision status (pending, final, overridden) for workflow efficiency and override rate tracking."
    - name: "lob"
      expr: lob
      comment: "Line of business for underwriting performance and risk appetite analysis by product."
    - name: "risk_tier"
      expr: risk_tier
      comment: "Risk tier classification (preferred, standard, substandard) for risk selection and pricing tier effectiveness."
    - name: "business_type"
      expr: business_type
      comment: "Business type for underwriting performance comparison between personal and commercial lines."
    - name: "automated_decision_flag"
      expr: automated_decision_flag
      comment: "Automated decision indicator for straight-through processing rate and automation effectiveness."
    - name: "override_flag"
      expr: override_flag
      comment: "Override indicator for underwriting authority compliance and exception rate monitoring."
    - name: "approval_required_flag"
      expr: approval_required_flag
      comment: "Approval required indicator for referral rate and authority limit analysis."
    - name: "decision_year"
      expr: YEAR(decision_date)
      comment: "Decision year for annual underwriting performance trend analysis."
    - name: "decision_month"
      expr: DATE_TRUNC('MONTH', decision_date)
      comment: "Decision month for monthly underwriting activity and cycle time tracking."
  measures:
    - name: "decision_count"
      expr: COUNT(DISTINCT uw_decision_id)
      comment: "Distinct count of underwriting decisions for workflow volume and capacity planning."
    - name: "total_premium_adjustment"
      expr: SUM(CAST(premium_adjustment_amount AS DOUBLE))
      comment: "Total premium adjustment amount for pricing discipline and underwriting impact on revenue."
    - name: "total_limit_adjustment"
      expr: SUM(CAST(limit_adjustment AS DOUBLE))
      comment: "Total limit adjustment for exposure management and underwriting authority effectiveness."
    - name: "total_deductible_adjustment"
      expr: SUM(CAST(deductible_adjustment AS DOUBLE))
      comment: "Total deductible adjustment for retention strategy and risk mitigation effectiveness."
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score for portfolio risk profile and underwriting quality monitoring."
    - name: "avg_premium_adjustment_pct"
      expr: AVG(CAST(premium_adjustment_pct AS DOUBLE))
      comment: "Average premium adjustment percentage for pricing discipline and underwriting impact analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_binder`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Binder metrics tracking binding authority usage, estimated premium, conversion to policy, and binder volume by status, line of business, and binding authority."
  source: "`vibe_pc_insurance_v499`.`policy`.`binder`"
  dimensions:
    - name: "binder_status"
      expr: binder_status
      comment: "Binder status (active, converted, cancelled, expired) for binding authority utilization and conversion tracking."
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code for binding authority usage analysis by product line."
    - name: "regulatory_state_code"
      expr: regulatory_state_code
      comment: "Regulatory state code for geographic binding authority activity and compliance monitoring."
    - name: "binding_year"
      expr: YEAR(binding_timestamp)
      comment: "Binding year for annual binding authority volume and trend analysis."
    - name: "binding_month"
      expr: DATE_TRUNC('MONTH', binding_timestamp)
      comment: "Binding month for monthly binding authority activity and seasonality tracking."
    - name: "conversion_year"
      expr: YEAR(conversion_date)
      comment: "Conversion year for binder-to-policy conversion timing and workflow efficiency analysis."
  measures:
    - name: "binder_count"
      expr: COUNT(DISTINCT binder_id)
      comment: "Distinct count of binders for binding authority volume and delegated underwriting activity tracking."
    - name: "total_estimated_premium"
      expr: SUM(CAST(estimated_premium_amount AS DOUBLE))
      comment: "Total estimated premium on binders for binding authority exposure and revenue forecasting."
    - name: "total_deductible"
      expr: SUM(CAST(deductible_amount AS DOUBLE))
      comment: "Total deductible amount on binders for retention analysis and binding authority risk profile."
    - name: "total_per_occurrence_limit"
      expr: SUM(CAST(per_occurrence_limit_amount AS DOUBLE))
      comment: "Total per occurrence limit for binding authority exposure aggregation and capacity monitoring."
    - name: "total_limit"
      expr: SUM(CAST(total_limit_amount AS DOUBLE))
      comment: "Total limit amount for binding authority aggregate exposure and reinsurance planning."
    - name: "avg_estimated_premium"
      expr: AVG(CAST(estimated_premium_amount AS DOUBLE))
      comment: "Average estimated premium per binder for binding authority pricing and market segment analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_premium_cession_allocation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Premium cession allocation metrics tracking ceded premium, cession percentage, and allocation volume by accounting period, allocation status, and premium basis."
  source: "`vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation`"
  dimensions:
    - name: "accounting_period"
      expr: accounting_period
      comment: "Accounting period for ceded premium recognition and reinsurance accounting reconciliation."
    - name: "allocation_status"
      expr: allocation_status
      comment: "Allocation status (pending, confirmed, adjusted) for cession workflow and bordereaux accuracy tracking."
    - name: "premium_allocation_basis"
      expr: premium_allocation_basis
      comment: "Premium allocation basis (written, earned, in-force) for cession timing and reinsurance accounting method."
    - name: "allocation_year"
      expr: YEAR(allocation_effective_date)
      comment: "Allocation effective year for annual ceded premium trend and reinsurance cost analysis."
    - name: "allocation_month"
      expr: DATE_TRUNC('MONTH', allocation_effective_date)
      comment: "Allocation effective month for monthly ceded premium tracking and bordereaux submission timing."
  measures:
    - name: "allocation_count"
      expr: COUNT(DISTINCT premium_cession_allocation_id)
      comment: "Distinct count of premium cession allocations for reinsurance transaction volume and workflow complexity."
    - name: "total_allocated_premium"
      expr: SUM(CAST(allocated_premium_amount AS DOUBLE))
      comment: "Total allocated ceded premium for reinsurance cost and net retention analysis."
    - name: "avg_cession_percentage"
      expr: AVG(CAST(cession_percentage AS DOUBLE))
      comment: "Average cession percentage for reinsurance program utilization and retention strategy effectiveness."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_producer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy producer relationship metrics tracking commission splits, producer assignments, and producer performance by role, territory, and line of business."
  source: "`vibe_pc_insurance_v499`.`policy`.`policy_producer`"
  dimensions:
    - name: "role_code"
      expr: role_code
      comment: "Producer role code (writing agent, servicing agent, broker) for distribution channel and commission structure analysis."
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code for producer specialization and product mix analysis."
    - name: "territory_code"
      expr: territory_code
      comment: "Territory code for geographic producer coverage and market penetration analysis."
    - name: "primary_producer_flag"
      expr: primary_producer_flag
      comment: "Primary producer indicator for commission split and producer hierarchy analysis."
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Binding authority indicator for delegated underwriting and producer authority tracking."
    - name: "relationship_status"
      expr: relationship_status
      comment: "Relationship status (active, terminated, suspended) for producer network health and attrition analysis."
    - name: "commission_plan_code"
      expr: commission_plan_code
      comment: "Commission plan code for compensation structure and producer incentive analysis."
    - name: "assignment_year"
      expr: YEAR(assignment_date)
      comment: "Assignment year for producer onboarding and network growth trend analysis."
  measures:
    - name: "producer_assignment_count"
      expr: COUNT(DISTINCT policy_producer_id)
      comment: "Distinct count of producer assignments for distribution network size and policy-producer relationship complexity."
    - name: "avg_commission_split_pct"
      expr: AVG(CAST(commission_split_percentage AS DOUBLE))
      comment: "Average commission split percentage for multi-producer compensation and split commission analysis."
    - name: "avg_override_commission_rate"
      expr: AVG(CAST(override_commission_rate AS DOUBLE))
      comment: "Average override commission rate for hierarchical compensation and management override tracking."
    - name: "avg_commission_holdback_pct"
      expr: AVG(CAST(commission_holdback_percentage AS DOUBLE))
      comment: "Average commission holdback percentage for producer credit risk and contingent commission reserve analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_condition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy condition metrics tracking underwriting conditions, compliance requirements, and condition satisfaction by category, status, and line of business."
  source: "`vibe_pc_insurance_v499`.`policy`.`condition`"
  dimensions:
    - name: "condition_status"
      expr: condition_status
      comment: "Condition status (open, satisfied, waived, expired) for compliance tracking and underwriting condition management."
    - name: "condition_category"
      expr: condition_category
      comment: "Condition condition_category for condition type analysis and underwriting requirement classification."
    - name: "type_code"
      expr: type_code
      comment: "Condition type code for detailed condition classification and reporting requirement tracking."
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code for condition prevalence and underwriting requirement analysis by product."
    - name: "mandatory_flag"
      expr: mandatory_flag
      comment: "Mandatory condition indicator for compliance risk and critical condition tracking."
    - name: "regulatory_requirement_flag"
      expr: regulatory_requirement_flag
      comment: "Regulatory requirement indicator for compliance obligation and regulatory condition monitoring."
    - name: "compliance_flag"
      expr: compliance_flag
      comment: "Compliance status indicator for condition satisfaction and regulatory adherence tracking."
    - name: "coverage_impact_flag"
      expr: coverage_impact_flag
      comment: "Coverage impact indicator for conditions affecting coverage terms and policy enforceability."
    - name: "premium_impact_flag"
      expr: premium_impact_flag
      comment: "Premium impact indicator for conditions affecting pricing and premium adjustment tracking."
  measures:
    - name: "condition_count"
      expr: COUNT(DISTINCT condition_id)
      comment: "Distinct count of policy conditions for underwriting complexity and compliance workload tracking."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`policy_status_history`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy status transition metrics tracking status changes, cancellation reasons, premium impact, and transition volume by status, line of business, and transition reason."
  source: "`vibe_pc_insurance_v499`.`policy`.`status_history`"
  dimensions:
    - name: "new_status"
      expr: new_status
      comment: "New policy status for status transition analysis and policy lifecycle tracking."
    - name: "prior_status"
      expr: prior_status
      comment: "Prior policy status for status change pattern and workflow analysis."
    - name: "transition_reason_code"
      expr: transition_reason_code
      comment: "Transition reason code for status change driver analysis and retention strategy."
    - name: "lob"
      expr: lob
      comment: "Line of business for status transition pattern and retention analysis by product."
    - name: "cancellation_type"
      expr: cancellation_type
      comment: "Cancellation type (flat, short-rate, pro-rata) for cancellation pattern and unearned premium analysis."
    - name: "initiated_by_party_type"
      expr: initiated_by_party_type
      comment: "Initiating party type (insured, carrier, agent) for cancellation driver and retention strategy analysis."
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Reversal indicator for status change error rate and workflow quality monitoring."
    - name: "transition_year"
      expr: YEAR(transition_timestamp)
      comment: "Transition year for annual status change trend and retention analysis."
    - name: "transition_month"
      expr: DATE_TRUNC('MONTH', transition_timestamp)
      comment: "Transition month for monthly status change activity and seasonality tracking."
  measures:
    - name: "status_transition_count"
      expr: COUNT(DISTINCT status_history_id)
      comment: "Distinct count of status transitions for policy lifecycle complexity and workflow volume tracking."
    - name: "total_premium_impact"
      expr: SUM(CAST(premium_impact_amount AS DOUBLE))
      comment: "Total premium impact from status changes for revenue volatility and cancellation cost analysis."
    - name: "total_unearned_premium_returned"
      expr: SUM(CAST(unearned_premium_returned_amount AS DOUBLE))
      comment: "Total unearned premium returned for cancellation cost and cash flow impact analysis."
$$;