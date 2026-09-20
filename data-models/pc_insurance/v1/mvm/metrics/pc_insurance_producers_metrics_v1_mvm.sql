-- Metric views for domain: producers | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_commission_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commission transaction-level KPIs tracking earned, paid, and adjusted commission amounts by producer, agency, policy, and time period. Grain: one row per commission transaction."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction`"
  dimensions:
    - name: "transaction_date"
      expr: transaction_date
      comment: "Date the commission transaction was recorded"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month of the commission transaction"
    - name: "transaction_year"
      expr: YEAR(transaction_date)
      comment: "Year of the commission transaction"
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the commission transaction"
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of commission transaction (new business, renewal, endorsement, cancellation)"
    - name: "transaction_status"
      expr: transaction_status
      comment: "Current status of the commission transaction"
    - name: "payment_status"
      expr: payment_status
      comment: "Payment status of the commission"
    - name: "policy_transaction_type"
      expr: policy_transaction_type
      comment: "Type of underlying policy transaction driving the commission"
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code for the commission"
    - name: "state_code"
      expr: state_code
      comment: "State code where the commission was earned"
    - name: "commission_basis"
      expr: commission_basis
      comment: "Basis for commission calculation (written premium, earned premium, etc.)"
    - name: "contingent_commission_flag"
      expr: contingent_commission_flag
      comment: "Whether this is a contingent commission"
    - name: "override_flag"
      expr: override_flag
      comment: "Whether commission rate was manually overridden"
    - name: "writing_company_code"
      expr: writing_company_code
      comment: "Writing company code for the commission"
  measures:
    - name: "total_net_commission"
      expr: SUM(CAST(net_commission_amount AS DOUBLE))
      comment: "Total net commission amount after all adjustments and deductions"
    - name: "total_earned_commission"
      expr: SUM(CAST(earned_amount AS DOUBLE))
      comment: "Total earned commission amount before adjustments"
    - name: "total_adjustment_amount"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total commission adjustment amount (positive or negative)"
    - name: "total_claw_back"
      expr: SUM(CAST(claw_back_amount AS DOUBLE))
      comment: "Total commission claw-back amount due to policy cancellations or returns"
    - name: "total_tax_withholding"
      expr: SUM(CAST(tax_withholding_amount AS DOUBLE))
      comment: "Total tax withholding amount deducted from commission payments"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate applied across transactions"
    - name: "avg_split_percentage"
      expr: AVG(CAST(split_percentage AS DOUBLE))
      comment: "Average commission split percentage when multiple producers share commission"
    - name: "commission_transaction_count"
      expr: COUNT(1)
      comment: "Total number of commission transactions"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of distinct producers earning commission"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of distinct agencies earning commission"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of distinct policies generating commission"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_commission_statement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commission statement-level KPIs tracking periodic commission payables by producer and agency. Grain: one row per commission statement per producer per period."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`commission_statement`"
  dimensions:
    - name: "statement_date"
      expr: statement_date
      comment: "Date the commission statement was generated"
    - name: "statement_month"
      expr: DATE_TRUNC('MONTH', statement_date)
      comment: "Month of the commission statement"
    - name: "statement_year"
      expr: YEAR(statement_date)
      comment: "Year of the commission statement"
    - name: "statement_period_start"
      expr: statement_period_start_date
      comment: "Start date of the commission statement period"
    - name: "statement_period_end"
      expr: statement_period_end_date
      comment: "End date of the commission statement period"
    - name: "statement_status"
      expr: statement_status
      comment: "Status of the commission statement (draft, issued, paid, disputed)"
    - name: "statement_type"
      expr: statement_type
      comment: "Type of commission statement"
    - name: "payment_status"
      expr: payment_status
      comment: "Payment status of the commission statement"
    - name: "payment_method"
      expr: payment_method
      comment: "Method used to pay the commission"
    - name: "dispute_flag"
      expr: dispute_flag
      comment: "Whether the statement has been disputed by the producer"
    - name: "writing_company_code"
      expr: writing_company_code
      comment: "Writing company code for the statement"
  measures:
    - name: "total_commission_earned"
      expr: SUM(CAST(total_commission_earned AS DOUBLE))
      comment: "Total commission earned before deductions and adjustments"
    - name: "total_net_commission_payable"
      expr: SUM(CAST(net_commission_payable AS DOUBLE))
      comment: "Total net commission payable after all deductions and adjustments"
    - name: "total_new_business_commission"
      expr: SUM(CAST(new_business_commission AS DOUBLE))
      comment: "Total commission earned on new business policies"
    - name: "total_renewal_commission"
      expr: SUM(CAST(renewal_commission AS DOUBLE))
      comment: "Total commission earned on renewal policies"
    - name: "total_endorsement_commission"
      expr: SUM(CAST(endorsement_commission AS DOUBLE))
      comment: "Total commission earned on policy endorsements"
    - name: "total_deductions"
      expr: SUM(CAST(total_deductions AS DOUBLE))
      comment: "Total deductions from commission (chargebacks, EO premiums, etc.)"
    - name: "total_adjustments"
      expr: SUM(CAST(total_adjustments AS DOUBLE))
      comment: "Total adjustments to commission (positive or negative)"
    - name: "total_chargeback"
      expr: SUM(CAST(chargeback_amount AS DOUBLE))
      comment: "Total chargeback amount due to policy cancellations"
    - name: "total_eo_premium_deduction"
      expr: SUM(CAST(eo_premium_deduction AS DOUBLE))
      comment: "Total errors and omissions insurance premium deducted from commission"
    - name: "total_contingent_commission"
      expr: SUM(CAST(contingent_commission AS DOUBLE))
      comment: "Total contingent commission earned based on performance metrics"
    - name: "avg_policy_count_per_statement"
      expr: AVG(CAST(policy_count AS DOUBLE))
      comment: "Average number of policies per commission statement"
    - name: "avg_transaction_count_per_statement"
      expr: AVG(CAST(transaction_count AS DOUBLE))
      comment: "Average number of transactions per commission statement"
    - name: "statement_count"
      expr: COUNT(1)
      comment: "Total number of commission statements"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of distinct producers receiving statements"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of distinct agencies receiving statements"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_agency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Agency-level KPIs tracking production volume, policy count, binding authority, and appointment status. Grain: one row per agency."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`agency`"
  dimensions:
    - name: "agency_status"
      expr: agency_status
      comment: "Current status of the agency (active, suspended, terminated)"
    - name: "agency_type"
      expr: agency_type
      comment: "Type of agency (independent, captive, MGA, etc.)"
    - name: "tier"
      expr: tier
      comment: "Agency tier classification based on production volume or strategic importance"
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Whether the agency has binding authority"
    - name: "contingent_commission_eligible"
      expr: contingent_commission_eligible
      comment: "Whether the agency is eligible for contingent commission"
    - name: "surplus_lines_eligible"
      expr: surplus_lines_eligible
      comment: "Whether the agency is eligible to write surplus lines business"
    - name: "writing_company_code"
      expr: writing_company_code
      comment: "Writing company code the agency represents"
    - name: "appointment_year"
      expr: YEAR(appointment_effective_date)
      comment: "Year the agency appointment became effective"
    - name: "termination_reason_code"
      expr: termination_reason_code
      comment: "Reason code if the agency appointment was terminated"
  measures:
    - name: "total_annual_premium_volume"
      expr: SUM(CAST(annual_premium_volume AS DOUBLE))
      comment: "Total annual premium volume across all agencies"
    - name: "avg_annual_premium_volume"
      expr: AVG(CAST(annual_premium_volume AS DOUBLE))
      comment: "Average annual premium volume per agency"
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS DOUBLE))
      comment: "Total number of policies across all agencies"
    - name: "avg_policy_count"
      expr: AVG(CAST(policy_count AS DOUBLE))
      comment: "Average number of policies per agency"
    - name: "total_binding_authority_limit"
      expr: SUM(CAST(binding_authority_limit AS DOUBLE))
      comment: "Total binding authority limit across all agencies with binding authority"
    - name: "avg_binding_authority_limit"
      expr: AVG(CAST(binding_authority_limit AS DOUBLE))
      comment: "Average binding authority limit per agency with binding authority"
    - name: "total_eo_coverage_amount"
      expr: SUM(CAST(eo_coverage_amount AS DOUBLE))
      comment: "Total errors and omissions insurance coverage amount across all agencies"
    - name: "avg_default_commission_rate"
      expr: AVG(CAST(default_commission_rate AS DOUBLE))
      comment: "Average default commission rate across agencies"
    - name: "agency_count"
      expr: COUNT(1)
      comment: "Total number of agencies"
    - name: "active_agency_count"
      expr: COUNT(CASE WHEN agency_status = 'Active' THEN 1 END)
      comment: "Number of agencies with active status"
    - name: "binding_authority_agency_count"
      expr: COUNT(CASE WHEN binding_authority_flag = TRUE THEN 1 END)
      comment: "Number of agencies with binding authority"
    - name: "contingent_eligible_agency_count"
      expr: COUNT(CASE WHEN contingent_commission_eligible = TRUE THEN 1 END)
      comment: "Number of agencies eligible for contingent commission"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_producer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Producer-level KPIs tracking appointment status, licensing, binding authority, and compliance. Grain: one row per producer."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`"
  dimensions:
    - name: "appointment_status"
      expr: appointment_status
      comment: "Current appointment status of the producer"
    - name: "producer_type"
      expr: producer_type
      comment: "Type of producer (agent, broker, MGA, etc.)"
    - name: "producer_role"
      expr: producer_role
      comment: "Role of the producer within the distribution channel"
    - name: "license_class"
      expr: license_class
      comment: "License class of the producer"
    - name: "resident_state_code"
      expr: resident_state_code
      comment: "State code where the producer is a resident"
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Whether the producer has binding authority"
    - name: "contingent_commission_eligible"
      expr: contingent_commission_eligible
      comment: "Whether the producer is eligible for contingent commission"
    - name: "is_surplus_lines_licensed"
      expr: is_surplus_lines_licensed
      comment: "Whether the producer is licensed for surplus lines"
    - name: "regulatory_action_flag"
      expr: regulatory_action_flag
      comment: "Whether the producer has any regulatory actions on record"
    - name: "background_check_status"
      expr: background_check_status
      comment: "Status of the producer background check"
    - name: "w9_on_file"
      expr: w9_on_file
      comment: "Whether a W9 form is on file for the producer"
    - name: "appointment_year"
      expr: YEAR(appointment_effective_date)
      comment: "Year the producer appointment became effective"
    - name: "license_year"
      expr: YEAR(license_effective_date)
      comment: "Year the producer license became effective"
  measures:
    - name: "total_binding_authority_limit"
      expr: SUM(CAST(binding_authority_limit AS DOUBLE))
      comment: "Total binding authority limit across all producers with binding authority"
    - name: "avg_binding_authority_limit"
      expr: AVG(CAST(binding_authority_limit AS DOUBLE))
      comment: "Average binding authority limit per producer with binding authority"
    - name: "total_eo_coverage_amount"
      expr: SUM(CAST(eo_coverage_amount AS DOUBLE))
      comment: "Total errors and omissions insurance coverage amount across all producers"
    - name: "avg_eo_coverage_amount"
      expr: AVG(CAST(eo_coverage_amount AS DOUBLE))
      comment: "Average errors and omissions insurance coverage amount per producer"
    - name: "avg_default_commission_rate"
      expr: AVG(CAST(default_commission_rate AS DOUBLE))
      comment: "Average default commission rate across producers"
    - name: "avg_ce_hours_completed"
      expr: AVG(CAST(continuing_education_hours_completed AS DOUBLE))
      comment: "Average continuing education hours completed per producer"
    - name: "producer_count"
      expr: COUNT(1)
      comment: "Total number of producers"
    - name: "active_producer_count"
      expr: COUNT(CASE WHEN appointment_status = 'Active' THEN 1 END)
      comment: "Number of producers with active appointment status"
    - name: "binding_authority_producer_count"
      expr: COUNT(CASE WHEN binding_authority_flag = TRUE THEN 1 END)
      comment: "Number of producers with binding authority"
    - name: "contingent_eligible_producer_count"
      expr: COUNT(CASE WHEN contingent_commission_eligible = TRUE THEN 1 END)
      comment: "Number of producers eligible for contingent commission"
    - name: "surplus_lines_licensed_count"
      expr: COUNT(CASE WHEN is_surplus_lines_licensed = TRUE THEN 1 END)
      comment: "Number of producers licensed for surplus lines"
    - name: "regulatory_action_count"
      expr: COUNT(CASE WHEN regulatory_action_flag = TRUE THEN 1 END)
      comment: "Number of producers with regulatory actions on record"
    - name: "w9_on_file_count"
      expr: COUNT(CASE WHEN w9_on_file = TRUE THEN 1 END)
      comment: "Number of producers with W9 forms on file"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_producer_appointment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Producer appointment-level KPIs tracking appointment lifecycle, binding authority, and line-of-business authorizations. Grain: one row per producer appointment per company per LOB."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment`"
  dimensions:
    - name: "appointment_status"
      expr: appointment_status
      comment: "Current status of the producer appointment"
    - name: "appointment_type"
      expr: appointment_type
      comment: "Type of producer appointment"
    - name: "appointment_tier"
      expr: appointment_tier
      comment: "Tier classification of the appointment"
    - name: "appointment_state_code"
      expr: appointment_state_code
      comment: "State code where the appointment is registered"
    - name: "resident_state_code"
      expr: resident_state_code
      comment: "Resident state code of the producer"
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Whether the appointment includes binding authority"
    - name: "contingent_commission_eligible"
      expr: contingent_commission_eligible
      comment: "Whether the appointment is eligible for contingent commission"
    - name: "surplus_lines_flag"
      expr: surplus_lines_flag
      comment: "Whether the appointment covers surplus lines business"
    - name: "renewal_flag"
      expr: renewal_flag
      comment: "Whether this is a renewal appointment"
    - name: "termination_for_cause_flag"
      expr: termination_for_cause_flag
      comment: "Whether the appointment was terminated for cause"
    - name: "eo_insurance_required_flag"
      expr: eo_insurance_required_flag
      comment: "Whether errors and omissions insurance is required for this appointment"
    - name: "regulatory_reporting_required"
      expr: regulatory_reporting_required
      comment: "Whether regulatory reporting is required for this appointment"
    - name: "appointment_year"
      expr: YEAR(effective_date)
      comment: "Year the appointment became effective"
    - name: "termination_reason_code"
      expr: termination_reason_code
      comment: "Reason code if the appointment was terminated"
  measures:
    - name: "total_binding_authority_limit"
      expr: SUM(CAST(binding_authority_limit AS DOUBLE))
      comment: "Total binding authority limit across all appointments with binding authority"
    - name: "avg_binding_authority_limit"
      expr: AVG(CAST(binding_authority_limit AS DOUBLE))
      comment: "Average binding authority limit per appointment with binding authority"
    - name: "total_eo_minimum_coverage"
      expr: SUM(CAST(eo_minimum_coverage_amount AS DOUBLE))
      comment: "Total minimum errors and omissions coverage required across all appointments"
    - name: "avg_default_commission_rate"
      expr: AVG(CAST(default_commission_rate AS DOUBLE))
      comment: "Average default commission rate across appointments"
    - name: "appointment_count"
      expr: COUNT(1)
      comment: "Total number of producer appointments"
    - name: "active_appointment_count"
      expr: COUNT(CASE WHEN appointment_status = 'Active' THEN 1 END)
      comment: "Number of active producer appointments"
    - name: "binding_authority_appointment_count"
      expr: COUNT(CASE WHEN binding_authority_flag = TRUE THEN 1 END)
      comment: "Number of appointments with binding authority"
    - name: "contingent_eligible_appointment_count"
      expr: COUNT(CASE WHEN contingent_commission_eligible = TRUE THEN 1 END)
      comment: "Number of appointments eligible for contingent commission"
    - name: "surplus_lines_appointment_count"
      expr: COUNT(CASE WHEN surplus_lines_flag = TRUE THEN 1 END)
      comment: "Number of appointments covering surplus lines business"
    - name: "renewal_appointment_count"
      expr: COUNT(CASE WHEN renewal_flag = TRUE THEN 1 END)
      comment: "Number of renewal appointments"
    - name: "terminated_for_cause_count"
      expr: COUNT(CASE WHEN termination_for_cause_flag = TRUE THEN 1 END)
      comment: "Number of appointments terminated for cause"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of distinct producers with appointments"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of distinct agencies with producer appointments"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_underwriting_authority`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Underwriting authority-level KPIs tracking risk limits, binding authority, and underwriting constraints by producer and territory. Grain: one row per underwriting authority grant."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority`"
  dimensions:
    - name: "authority_status"
      expr: authority_status
      comment: "Current status of the underwriting authority"
    - name: "authority_type"
      expr: authority_type
      comment: "Type of underwriting authority granted"
    - name: "limit_tier"
      expr: limit_tier
      comment: "Tier classification of the underwriting limit"
    - name: "new_business_allowed"
      expr: new_business_allowed
      comment: "Whether new business underwriting is allowed"
    - name: "renewal_allowed"
      expr: renewal_allowed
      comment: "Whether renewal underwriting is allowed"
    - name: "endorsement_allowed"
      expr: endorsement_allowed
      comment: "Whether endorsement underwriting is allowed"
    - name: "cancellation_allowed"
      expr: cancellation_allowed
      comment: "Whether cancellation authority is granted"
    - name: "reinstatement_allowed"
      expr: reinstatement_allowed
      comment: "Whether reinstatement authority is granted"
    - name: "blanket_coverage_allowed"
      expr: blanket_coverage_allowed
      comment: "Whether blanket coverage underwriting is allowed"
    - name: "coinsurance_allowed"
      expr: coinsurance_allowed
      comment: "Whether coinsurance underwriting is allowed"
    - name: "audit_required"
      expr: audit_required
      comment: "Whether periodic audits are required for this authority"
    - name: "audit_frequency"
      expr: audit_frequency
      comment: "Frequency of required audits"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the underwriting authority became effective"
  measures:
    - name: "total_max_single_risk_limit"
      expr: SUM(CAST(max_single_risk_limit AS DOUBLE))
      comment: "Total maximum single risk limit across all underwriting authorities"
    - name: "avg_max_single_risk_limit"
      expr: AVG(CAST(max_single_risk_limit AS DOUBLE))
      comment: "Average maximum single risk limit per underwriting authority"
    - name: "total_max_tiv"
      expr: SUM(CAST(max_tiv AS DOUBLE))
      comment: "Total maximum total insured value across all underwriting authorities"
    - name: "avg_max_tiv"
      expr: AVG(CAST(max_tiv AS DOUBLE))
      comment: "Average maximum total insured value per underwriting authority"
    - name: "total_max_premium_threshold"
      expr: SUM(CAST(max_premium_threshold AS DOUBLE))
      comment: "Total maximum premium threshold across all underwriting authorities"
    - name: "avg_max_premium_threshold"
      expr: AVG(CAST(max_premium_threshold AS DOUBLE))
      comment: "Average maximum premium threshold per underwriting authority"
    - name: "avg_deductible_max"
      expr: AVG(CAST(deductible_max AS DOUBLE))
      comment: "Average maximum deductible allowed per underwriting authority"
    - name: "avg_deductible_min"
      expr: AVG(CAST(deductible_min AS DOUBLE))
      comment: "Average minimum deductible required per underwriting authority"
    - name: "underwriting_authority_count"
      expr: COUNT(1)
      comment: "Total number of underwriting authority grants"
    - name: "active_authority_count"
      expr: COUNT(CASE WHEN authority_status = 'Active' THEN 1 END)
      comment: "Number of active underwriting authorities"
    - name: "new_business_authority_count"
      expr: COUNT(CASE WHEN new_business_allowed = TRUE THEN 1 END)
      comment: "Number of authorities allowing new business underwriting"
    - name: "renewal_authority_count"
      expr: COUNT(CASE WHEN renewal_allowed = TRUE THEN 1 END)
      comment: "Number of authorities allowing renewal underwriting"
    - name: "audit_required_count"
      expr: COUNT(CASE WHEN audit_required = TRUE THEN 1 END)
      comment: "Number of authorities requiring periodic audits"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of distinct producers with underwriting authority"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of distinct agencies with underwriting authority"
$$;