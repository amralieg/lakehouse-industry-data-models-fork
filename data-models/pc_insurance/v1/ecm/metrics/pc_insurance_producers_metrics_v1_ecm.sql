-- Metric views for domain: producers | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_commission_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commission transaction-level KPIs tracking earned, paid, and adjusted commission amounts by producer, agency, policy, and accounting period. Grain: one row per commission transaction."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction`"
  dimensions:
    - name: "transaction_date"
      expr: transaction_date
      comment: "Date the commission transaction was recorded"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month of commission transaction"
    - name: "transaction_year"
      expr: YEAR(transaction_date)
      comment: "Year of commission transaction"
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the commission transaction"
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of commission transaction (e.g., New Business, Renewal, Endorsement, Chargeback)"
    - name: "transaction_status"
      expr: transaction_status
      comment: "Current status of the commission transaction"
    - name: "commission_basis"
      expr: commission_basis
      comment: "Basis for commission calculation (e.g., Written Premium, Earned Premium)"
    - name: "payment_status"
      expr: payment_status
      comment: "Payment status of the commission"
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code"
    - name: "state_code"
      expr: state_code
      comment: "State code where commission was earned"
    - name: "policy_transaction_type"
      expr: policy_transaction_type
      comment: "Type of policy transaction generating the commission"
    - name: "override_flag"
      expr: override_flag
      comment: "Indicates if commission rate was overridden"
    - name: "contingent_commission_flag"
      expr: contingent_commission_flag
      comment: "Indicates if this is a contingent commission"
  measures:
    - name: "total_earned_commission"
      expr: SUM(CAST(earned_amount AS DOUBLE))
      comment: "Total commission earned across all transactions"
    - name: "total_net_commission"
      expr: SUM(CAST(net_commission_amount AS DOUBLE))
      comment: "Total net commission after adjustments and withholdings"
    - name: "total_adjustment_amount"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total commission adjustments (positive or negative)"
    - name: "total_claw_back_amount"
      expr: SUM(CAST(claw_back_amount AS DOUBLE))
      comment: "Total commission clawed back due to policy cancellations or returns"
    - name: "total_tax_withholding"
      expr: SUM(CAST(tax_withholding_amount AS DOUBLE))
      comment: "Total tax withholding on commission payments"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate across transactions"
    - name: "avg_split_percentage"
      expr: AVG(CAST(split_percentage AS DOUBLE))
      comment: "Average commission split percentage when multiple producers share commission"
    - name: "commission_transaction_count"
      expr: COUNT(1)
      comment: "Total number of commission transactions"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of unique producers earning commission"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of unique policies generating commission"
    - name: "override_transaction_count"
      expr: SUM(CAST(CASE WHEN override_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of transactions with overridden commission rates"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_producer_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Producer performance KPIs tracking production, profitability, retention, and quality metrics by producer, agency, line of business, and evaluation period. Grain: one row per producer per evaluation period."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`producer_performance`"
  dimensions:
    - name: "evaluation_period_start"
      expr: evaluation_period_start_date
      comment: "Start date of the performance evaluation period"
    - name: "evaluation_period_end"
      expr: evaluation_period_end_date
      comment: "End date of the performance evaluation period"
    - name: "evaluation_year"
      expr: YEAR(evaluation_period_start_date)
      comment: "Year of the evaluation period start"
    - name: "evaluation_status"
      expr: evaluation_status
      comment: "Status of the performance evaluation"
    - name: "period_type"
      expr: period_type
      comment: "Type of evaluation period (e.g., Monthly, Quarterly, Annual)"
    - name: "currency_code"
      expr: currency_code
      comment: "Currency code for financial metrics"
    - name: "npn"
      expr: npn
      comment: "National Producer Number"
  measures:
    - name: "total_gwp"
      expr: SUM(CAST(gwp_amount AS DOUBLE))
      comment: "Total gross written premium produced"
    - name: "total_nwp"
      expr: SUM(CAST(nwp_amount AS DOUBLE))
      comment: "Total net written premium after cancellations and returns"
    - name: "total_dwp"
      expr: SUM(CAST(dwp_amount AS DOUBLE))
      comment: "Total direct written premium"
    - name: "total_earned_premium"
      expr: SUM(CAST(earned_premium_amount AS DOUBLE))
      comment: "Total earned premium during the evaluation period"
    - name: "total_commission_earned"
      expr: SUM(CAST(commission_earned_amount AS DOUBLE))
      comment: "Total commission earned by producers"
    - name: "total_contingent_commission"
      expr: SUM(CAST(contingent_commission_amount AS DOUBLE))
      comment: "Total contingent commission earned based on performance targets"
    - name: "total_incurred_losses"
      expr: SUM(CAST(incurred_losses_amount AS DOUBLE))
      comment: "Total incurred losses on producer book of business"
    - name: "total_paid_losses"
      expr: SUM(CAST(paid_losses_amount AS DOUBLE))
      comment: "Total paid losses on producer book of business"
    - name: "avg_loss_ratio"
      expr: AVG(CAST(loss_ratio AS DOUBLE))
      comment: "Average loss ratio across producers (incurred losses divided by earned premium)"
    - name: "avg_combined_ratio"
      expr: AVG(CAST(combined_ratio AS DOUBLE))
      comment: "Average combined ratio across producers (loss ratio plus expense ratio)"
    - name: "avg_expense_ratio"
      expr: AVG(CAST(expense_ratio AS DOUBLE))
      comment: "Average expense ratio across producers"
    - name: "avg_retention_rate"
      expr: AVG(CAST(retention_rate AS DOUBLE))
      comment: "Average policy retention rate across producers"
    - name: "avg_quote_to_bind_ratio"
      expr: AVG(CAST(quote_to_bind_ratio AS DOUBLE))
      comment: "Average ratio of quotes to bound policies"
    - name: "avg_policy_premium"
      expr: AVG(CAST(average_policy_premium AS DOUBLE))
      comment: "Average premium per policy across producer book"
    - name: "avg_claim_severity"
      expr: AVG(CAST(average_claim_severity AS DOUBLE))
      comment: "Average claim severity (average loss per claim)"
    - name: "avg_claim_frequency"
      expr: AVG(CAST(claim_frequency AS DOUBLE))
      comment: "Average claim frequency (claims per policy or exposure unit)"
    - name: "avg_performance_score"
      expr: AVG(CAST(performance_score AS DOUBLE))
      comment: "Average overall performance score"
    - name: "total_new_business_count"
      expr: SUM(CAST(new_business_count AS BIGINT))
      comment: "Total count of new business policies written"
    - name: "total_renewal_count"
      expr: SUM(CAST(renewal_count AS BIGINT))
      comment: "Total count of renewed policies"
    - name: "total_cancellation_count"
      expr: SUM(CAST(cancellation_count AS BIGINT))
      comment: "Total count of cancelled policies"
    - name: "total_pif_count"
      expr: SUM(CAST(pif_count AS BIGINT))
      comment: "Total policies in force at period end"
    - name: "total_claim_count"
      expr: SUM(CAST(claim_count AS BIGINT))
      comment: "Total number of claims on producer book"
    - name: "total_quote_count"
      expr: SUM(CAST(quote_count AS BIGINT))
      comment: "Total number of quotes issued"
    - name: "total_endorsement_count"
      expr: SUM(CAST(endorsement_count AS BIGINT))
      comment: "Total number of policy endorsements processed"
    - name: "total_eo_claim_count"
      expr: SUM(CAST(eo_claim_count AS BIGINT))
      comment: "Total errors and omissions claims against producers"
    - name: "total_compliance_violations"
      expr: SUM(CAST(compliance_violations_count AS BIGINT))
      comment: "Total compliance violations recorded"
    - name: "total_customer_complaints"
      expr: SUM(CAST(customer_complaint_count AS BIGINT))
      comment: "Total customer complaints against producers"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of unique producers evaluated"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of unique agencies evaluated"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_commission_statement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commission statement KPIs tracking total commission earned, payable, and deductions by producer, agency, and statement period. Grain: one row per commission statement."
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
      comment: "Start date of the statement period"
    - name: "statement_period_end"
      expr: statement_period_end_date
      comment: "End date of the statement period"
    - name: "statement_status"
      expr: statement_status
      comment: "Status of the commission statement"
    - name: "statement_type"
      expr: statement_type
      comment: "Type of commission statement"
    - name: "payment_status"
      expr: payment_status
      comment: "Payment status of the statement"
    - name: "payment_method"
      expr: payment_method
      comment: "Method of commission payment"
    - name: "currency_code"
      expr: currency_code
      comment: "Currency code for statement amounts"
    - name: "dispute_flag"
      expr: dispute_flag
      comment: "Indicates if the statement is disputed"
    - name: "npn"
      expr: npn
      comment: "National Producer Number"
  measures:
    - name: "total_commission_earned"
      expr: SUM(CAST(total_commission_earned AS DOUBLE))
      comment: "Total commission earned across all statements"
    - name: "total_net_commission_payable"
      expr: SUM(CAST(net_commission_payable AS DOUBLE))
      comment: "Total net commission payable after all adjustments and deductions"
    - name: "total_new_business_commission"
      expr: SUM(CAST(new_business_commission AS DOUBLE))
      comment: "Total commission from new business policies"
    - name: "total_renewal_commission"
      expr: SUM(CAST(renewal_commission AS DOUBLE))
      comment: "Total commission from renewal policies"
    - name: "total_endorsement_commission"
      expr: SUM(CAST(endorsement_commission AS DOUBLE))
      comment: "Total commission from policy endorsements"
    - name: "total_contingent_commission"
      expr: SUM(CAST(contingent_commission AS DOUBLE))
      comment: "Total contingent commission earned"
    - name: "total_chargeback_amount"
      expr: SUM(CAST(chargeback_amount AS DOUBLE))
      comment: "Total commission chargebacks due to cancellations or returns"
    - name: "total_adjustments"
      expr: SUM(CAST(total_adjustments AS DOUBLE))
      comment: "Total commission adjustments (positive or negative)"
    - name: "total_deductions"
      expr: SUM(CAST(total_deductions AS DOUBLE))
      comment: "Total deductions from commission (EO premium, fees, etc.)"
    - name: "total_eo_premium_deduction"
      expr: SUM(CAST(eo_premium_deduction AS DOUBLE))
      comment: "Total errors and omissions insurance premium deducted from commission"
    - name: "avg_commission_per_policy"
      expr: AVG(CAST(total_commission_earned AS DOUBLE) / NULLIF(CAST(policy_count AS DOUBLE), 0))
      comment: "Average commission earned per policy on the statement"
    - name: "statement_count"
      expr: COUNT(1)
      comment: "Total number of commission statements"
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS BIGINT))
      comment: "Total number of policies included in statements"
    - name: "total_transaction_count"
      expr: SUM(CAST(transaction_count AS BIGINT))
      comment: "Total number of commission transactions in statements"
    - name: "disputed_statement_count"
      expr: SUM(CAST(CASE WHEN dispute_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of disputed commission statements"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of unique producers receiving statements"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of unique agencies receiving statements"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_broker_of_record_change`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Broker of record change KPIs tracking producer transitions, commission splits, and premium at risk during BOR changes. Grain: one row per broker of record change request."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change`"
  dimensions:
    - name: "request_date"
      expr: request_date
      comment: "Date the BOR change was requested"
    - name: "request_month"
      expr: DATE_TRUNC('MONTH', request_date)
      comment: "Month of BOR change request"
    - name: "request_year"
      expr: YEAR(request_date)
      comment: "Year of BOR change request"
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the BOR change"
    - name: "change_status"
      expr: change_status
      comment: "Status of the BOR change request"
    - name: "change_reason_code"
      expr: change_reason_code
      comment: "Reason code for the BOR change"
    - name: "mid_term_change_flag"
      expr: mid_term_change_flag
      comment: "Indicates if BOR change occurred mid-term"
    - name: "renewal_bor_flag"
      expr: renewal_bor_flag
      comment: "Indicates if BOR change is at renewal"
    - name: "insured_consent_method"
      expr: insured_consent_method
      comment: "Method by which insured consent was obtained"
    - name: "commission_split_basis"
      expr: commission_split_basis
      comment: "Basis for splitting commission between incoming and outgoing producers"
    - name: "policy_state"
      expr: policy_state
      comment: "State where the policy is written"
    - name: "currency_code"
      expr: currency_code
      comment: "Currency code for premium amounts"
  measures:
    - name: "total_written_premium_at_change"
      expr: SUM(CAST(written_premium_at_change AS DOUBLE))
      comment: "Total written premium affected by BOR changes"
    - name: "avg_incoming_commission_rate"
      expr: AVG(CAST(incoming_commission_rate AS DOUBLE))
      comment: "Average commission rate for incoming producers"
    - name: "avg_outgoing_commission_rate"
      expr: AVG(CAST(outgoing_commission_rate AS DOUBLE))
      comment: "Average commission rate for outgoing producers"
    - name: "avg_commission_split_incoming_pct"
      expr: AVG(CAST(commission_split_incoming_pct AS DOUBLE))
      comment: "Average commission split percentage to incoming producer"
    - name: "avg_commission_split_outgoing_pct"
      expr: AVG(CAST(commission_split_outgoing_pct AS DOUBLE))
      comment: "Average commission split percentage to outgoing producer"
    - name: "bor_change_count"
      expr: COUNT(1)
      comment: "Total number of broker of record changes"
    - name: "mid_term_change_count"
      expr: SUM(CAST(CASE WHEN mid_term_change_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of BOR changes occurring mid-term"
    - name: "renewal_bor_change_count"
      expr: SUM(CAST(CASE WHEN renewal_bor_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of BOR changes at renewal"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of unique policies affected by BOR changes"
    - name: "distinct_incoming_agency_count"
      expr: COUNT(DISTINCT broker_incoming_agency_id)
      comment: "Number of unique incoming agencies"
    - name: "distinct_outgoing_agency_count"
      expr: COUNT(DISTINCT broker_outgoing_agency_id)
      comment: "Number of unique outgoing agencies"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_contingent_commission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Contingent commission KPIs tracking performance-based commission earned, paid, and outstanding by producer, agency, and performance period. Grain: one row per contingent commission agreement per period."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission`"
  dimensions:
    - name: "performance_period_start"
      expr: performance_period_start_date
      comment: "Start date of the performance measurement period"
    - name: "performance_period_end"
      expr: performance_period_end_date
      comment: "End date of the performance measurement period"
    - name: "performance_year"
      expr: YEAR(performance_period_start_date)
      comment: "Year of the performance period start"
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the contingent commission agreement"
    - name: "agreement_status"
      expr: agreement_status
      comment: "Status of the contingent commission agreement"
    - name: "agreement_type"
      expr: agreement_type
      comment: "Type of contingent commission agreement"
    - name: "approval_status"
      expr: approval_status
      comment: "Approval status of the contingent commission"
    - name: "calculation_basis"
      expr: calculation_basis
      comment: "Basis for calculating contingent commission (e.g., loss ratio, growth, retention)"
    - name: "settlement_frequency"
      expr: settlement_frequency
      comment: "Frequency of contingent commission settlement"
    - name: "performance_met_flag"
      expr: performance_met_flag
      comment: "Indicates if performance targets were met"
    - name: "currency_code"
      expr: currency_code
      comment: "Currency code for commission amounts"
  measures:
    - name: "total_earned_commission"
      expr: SUM(CAST(earned_commission_amount AS DOUBLE))
      comment: "Total contingent commission earned based on performance"
    - name: "total_paid_commission"
      expr: SUM(CAST(paid_commission_amount AS DOUBLE))
      comment: "Total contingent commission paid to producers"
    - name: "total_outstanding_commission"
      expr: SUM(CAST(outstanding_commission_amount AS DOUBLE))
      comment: "Total contingent commission earned but not yet paid"
    - name: "total_maximum_commission"
      expr: SUM(CAST(maximum_commission_amount AS DOUBLE))
      comment: "Total maximum contingent commission available under agreements"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average contingent commission rate"
    - name: "avg_actual_loss_ratio"
      expr: AVG(CAST(actual_loss_ratio AS DOUBLE))
      comment: "Average actual loss ratio achieved"
    - name: "avg_target_loss_ratio"
      expr: AVG(CAST(target_loss_ratio AS DOUBLE))
      comment: "Average target loss ratio for contingent commission eligibility"
    - name: "avg_actual_retention_rate"
      expr: AVG(CAST(actual_retention_rate AS DOUBLE))
      comment: "Average actual retention rate achieved"
    - name: "avg_target_retention_rate"
      expr: AVG(CAST(target_retention_rate AS DOUBLE))
      comment: "Average target retention rate for contingent commission eligibility"
    - name: "avg_actual_growth_rate"
      expr: AVG(CAST(actual_growth_rate AS DOUBLE))
      comment: "Average actual premium growth rate achieved"
    - name: "avg_target_growth_rate"
      expr: AVG(CAST(target_growth_rate AS DOUBLE))
      comment: "Average target growth rate for contingent commission eligibility"
    - name: "avg_actual_combined_ratio"
      expr: AVG(CAST(actual_combined_ratio AS DOUBLE))
      comment: "Average actual combined ratio achieved"
    - name: "avg_target_combined_ratio"
      expr: AVG(CAST(target_combined_ratio AS DOUBLE))
      comment: "Average target combined ratio for contingent commission eligibility"
    - name: "agreement_count"
      expr: COUNT(1)
      comment: "Total number of contingent commission agreements"
    - name: "performance_met_count"
      expr: SUM(CAST(CASE WHEN performance_met_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of agreements where performance targets were met"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of unique producers with contingent commission agreements"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of unique agencies with contingent commission agreements"
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
      comment: "Current status of the agency"
    - name: "agency_type"
      expr: agency_type
      comment: "Type of agency (e.g., Independent, Captive, MGA)"
    - name: "tier"
      expr: tier
      comment: "Agency tier or classification"
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Indicates if agency has binding authority"
    - name: "contingent_commission_eligible"
      expr: contingent_commission_eligible
      comment: "Indicates if agency is eligible for contingent commission"
    - name: "surplus_lines_eligible"
      expr: surplus_lines_eligible
      comment: "Indicates if agency is eligible to write surplus lines"
    - name: "principal_state_code"
      expr: principal_state_code
      comment: "State code of agency principal address"
    - name: "principal_country_code"
      expr: principal_country_code
      comment: "Country code of agency principal address"
    - name: "appointment_effective_date"
      expr: appointment_effective_date
      comment: "Date agency appointment became effective"
  measures:
    - name: "total_annual_premium_volume"
      expr: SUM(CAST(annual_premium_volume AS DOUBLE))
      comment: "Total annual premium volume across all agencies"
    - name: "avg_annual_premium_volume"
      expr: AVG(CAST(annual_premium_volume AS DOUBLE))
      comment: "Average annual premium volume per agency"
    - name: "total_binding_authority_limit"
      expr: SUM(CAST(binding_authority_limit AS DOUBLE))
      comment: "Total binding authority limit across agencies with binding authority"
    - name: "avg_binding_authority_limit"
      expr: AVG(CAST(binding_authority_limit AS DOUBLE))
      comment: "Average binding authority limit per agency"
    - name: "total_eo_coverage_amount"
      expr: SUM(CAST(eo_coverage_amount AS DOUBLE))
      comment: "Total errors and omissions coverage amount across agencies"
    - name: "avg_default_commission_rate"
      expr: AVG(CAST(default_commission_rate AS DOUBLE))
      comment: "Average default commission rate across agencies"
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS BIGINT))
      comment: "Total number of policies across all agencies"
    - name: "avg_policy_count_per_agency"
      expr: AVG(CAST(policy_count AS DOUBLE))
      comment: "Average number of policies per agency"
    - name: "agency_count"
      expr: COUNT(1)
      comment: "Total number of agencies"
    - name: "binding_authority_agency_count"
      expr: SUM(CAST(CASE WHEN binding_authority_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of agencies with binding authority"
    - name: "contingent_commission_eligible_count"
      expr: SUM(CAST(CASE WHEN contingent_commission_eligible = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of agencies eligible for contingent commission"
    - name: "surplus_lines_eligible_count"
      expr: SUM(CAST(CASE WHEN surplus_lines_eligible = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of agencies eligible to write surplus lines"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`producers_producer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Producer-level KPIs tracking licensing, appointment status, binding authority, and errors and omissions coverage. Grain: one row per producer."
  source: "`vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`"
  dimensions:
    - name: "appointment_status"
      expr: appointment_status
      comment: "Current appointment status of the producer"
    - name: "producer_type"
      expr: producer_type
      comment: "Type of producer (e.g., Agent, Broker, MGA)"
    - name: "producer_role"
      expr: producer_role
      comment: "Role of the producer"
    - name: "license_class"
      expr: license_class
      comment: "Class of producer license"
    - name: "resident_state_code"
      expr: resident_state_code
      comment: "State code where producer is resident"
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Indicates if producer has binding authority"
    - name: "contingent_commission_eligible"
      expr: contingent_commission_eligible
      comment: "Indicates if producer is eligible for contingent commission"
    - name: "is_surplus_lines_licensed"
      expr: is_surplus_lines_licensed
      comment: "Indicates if producer is licensed for surplus lines"
    - name: "regulatory_action_flag"
      expr: regulatory_action_flag
      comment: "Indicates if producer has regulatory actions on record"
    - name: "background_check_status"
      expr: background_check_status
      comment: "Status of producer background check"
    - name: "npn"
      expr: npn
      comment: "National Producer Number"
  measures:
    - name: "total_binding_authority_limit"
      expr: SUM(CAST(binding_authority_limit AS DOUBLE))
      comment: "Total binding authority limit across producers with binding authority"
    - name: "avg_binding_authority_limit"
      expr: AVG(CAST(binding_authority_limit AS DOUBLE))
      comment: "Average binding authority limit per producer"
    - name: "total_eo_coverage_amount"
      expr: SUM(CAST(eo_coverage_amount AS DOUBLE))
      comment: "Total errors and omissions coverage amount across producers"
    - name: "avg_eo_coverage_amount"
      expr: AVG(CAST(eo_coverage_amount AS DOUBLE))
      comment: "Average errors and omissions coverage amount per producer"
    - name: "avg_default_commission_rate"
      expr: AVG(CAST(default_commission_rate AS DOUBLE))
      comment: "Average default commission rate across producers"
    - name: "avg_continuing_education_hours"
      expr: AVG(CAST(continuing_education_hours_completed AS DOUBLE))
      comment: "Average continuing education hours completed per producer"
    - name: "producer_count"
      expr: COUNT(1)
      comment: "Total number of producers"
    - name: "binding_authority_producer_count"
      expr: SUM(CAST(CASE WHEN binding_authority_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of producers with binding authority"
    - name: "contingent_commission_eligible_count"
      expr: SUM(CAST(CASE WHEN contingent_commission_eligible = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of producers eligible for contingent commission"
    - name: "surplus_lines_licensed_count"
      expr: SUM(CAST(CASE WHEN is_surplus_lines_licensed = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of producers licensed for surplus lines"
    - name: "regulatory_action_count"
      expr: SUM(CAST(CASE WHEN regulatory_action_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of producers with regulatory actions"
$$;