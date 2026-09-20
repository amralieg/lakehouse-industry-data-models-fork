-- Metric views for domain: policy | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core policy metrics tracking written premium, total insured value, and policy counts by status, line of business, state, and distribution channel. Grain: one row per policy."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`policy`"
  dimensions:
    - name: "policy_status"
      expr: policy_status
      comment: "Current status of the policy (Active, Cancelled, Expired, etc.)"
    - name: "state_code"
      expr: state_code
      comment: "State where the policy is written"
    - name: "carrier_code"
      expr: carrier_code
      comment: "Insurance carrier code"
    - name: "program_code"
      expr: program_code
      comment: "Insurance program code"
    - name: "underwriting_tier"
      expr: underwriting_tier
      comment: "Underwriting tier classification (Preferred, Standard, Non-standard)"
    - name: "billing_method"
      expr: billing_method
      comment: "Method of billing (Direct, Agency, etc.)"
    - name: "payment_plan_code"
      expr: payment_plan_code
      comment: "Payment plan code"
    - name: "auto_renew_flag"
      expr: auto_renew_flag
      comment: "Whether policy is set to auto-renew"
    - name: "renewal_indicator"
      expr: renewal_indicator
      comment: "Whether this policy is a renewal"
    - name: "facultative_flag"
      expr: facultative_flag
      comment: "Whether policy has facultative reinsurance"
    - name: "cancellation_reason_code"
      expr: cancellation_reason_code
      comment: "Reason code for policy cancellation"
    - name: "non_renewal_reason_code"
      expr: non_renewal_reason_code
      comment: "Reason code for non-renewal"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the policy became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the policy became effective"
    - name: "inception_year"
      expr: YEAR(inception_date)
      comment: "Year of policy inception"
    - name: "binding_year"
      expr: YEAR(binding_date)
      comment: "Year the policy was bound"
  measures:
    - name: "policy_count"
      expr: COUNT(1)
      comment: "Total number of policies"
    - name: "total_written_premium"
      expr: SUM(CAST(written_premium_amount AS DOUBLE))
      comment: "Total written premium across all policies"
    - name: "avg_written_premium"
      expr: AVG(CAST(written_premium_amount AS DOUBLE))
      comment: "Average written premium per policy"
    - name: "total_insured_value_sum"
      expr: SUM(CAST(total_insured_value AS DOUBLE))
      comment: "Total insured value across all policies"
    - name: "avg_total_insured_value"
      expr: AVG(CAST(total_insured_value AS DOUBLE))
      comment: "Average total insured value per policy"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate across policies"
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score across policies"
    - name: "avg_term_months"
      expr: AVG(CAST(term_months AS DOUBLE))
      comment: "Average policy term length in months"
    - name: "cancelled_policy_count"
      expr: COUNT(CASE WHEN cancellation_date IS NOT NULL THEN 1 END)
      comment: "Number of policies that have been cancelled"
    - name: "renewal_policy_count"
      expr: COUNT(CASE WHEN renewal_indicator = TRUE THEN 1 END)
      comment: "Number of renewal policies"
    - name: "auto_renew_policy_count"
      expr: COUNT(CASE WHEN auto_renew_flag = TRUE THEN 1 END)
      comment: "Number of policies set to auto-renew"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_term`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy term metrics tracking written premium, term duration, and term counts by status, renewal type, and cancellation reason. Grain: one row per policy per term."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`term`"
  dimensions:
    - name: "term_status"
      expr: term_status
      comment: "Status of the policy term"
    - name: "is_renewal"
      expr: is_renewal
      comment: "Whether this term is a renewal"
    - name: "renewal_type"
      expr: renewal_type
      comment: "Type of renewal (Automatic, Manual, etc.)"
    - name: "cancellation_type"
      expr: cancellation_type
      comment: "Type of cancellation (Flat, Pro-rata, Short-rate)"
    - name: "cancellation_reason_code"
      expr: cancellation_reason_code
      comment: "Reason code for term cancellation"
    - name: "non_renewal_reason_code"
      expr: non_renewal_reason_code
      comment: "Reason code for non-renewal"
    - name: "billing_method"
      expr: billing_method
      comment: "Billing method for the term"
    - name: "payment_plan_code"
      expr: payment_plan_code
      comment: "Payment plan code for the term"
    - name: "underwriting_company_code"
      expr: underwriting_company_code
      comment: "Underwriting company code"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the term became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the term became effective"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year of the term"
    - name: "calendar_year"
      expr: calendar_year
      comment: "Calendar year of the term"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for the term"
  measures:
    - name: "term_count"
      expr: COUNT(1)
      comment: "Total number of policy terms"
    - name: "total_written_premium"
      expr: SUM(CAST(written_premium_amount AS DOUBLE))
      comment: "Total written premium across all terms"
    - name: "avg_written_premium"
      expr: AVG(CAST(written_premium_amount AS DOUBLE))
      comment: "Average written premium per term"
    - name: "avg_duration_days"
      expr: AVG(CAST(duration_days AS DOUBLE))
      comment: "Average term duration in days"
    - name: "total_duration_days"
      expr: SUM(CAST(duration_days AS DOUBLE))
      comment: "Total duration days across all terms"
    - name: "renewal_term_count"
      expr: COUNT(CASE WHEN is_renewal = TRUE THEN 1 END)
      comment: "Number of renewal terms"
    - name: "cancelled_term_count"
      expr: COUNT(CASE WHEN cancellation_date IS NOT NULL THEN 1 END)
      comment: "Number of cancelled terms"
    - name: "reinstated_term_count"
      expr: COUNT(CASE WHEN reinstatement_date IS NOT NULL THEN 1 END)
      comment: "Number of reinstated terms"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct number of policies across terms"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy transaction metrics tracking premium changes, transaction counts, and transaction types. Grain: one row per policy transaction."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`"
  dimensions:
    - name: "type_code"
      expr: type_code
      comment: "Transaction type code (New Business, Renewal, Endorsement, Cancellation, Reinstatement)"
    - name: "transaction_status"
      expr: transaction_status
      comment: "Status of the transaction"
    - name: "reason_code"
      expr: reason_code
      comment: "Reason code for the transaction"
    - name: "cancellation_type_code"
      expr: cancellation_type_code
      comment: "Type of cancellation (Flat, Pro-rata, Short-rate)"
    - name: "cancellation_basis"
      expr: cancellation_basis
      comment: "Basis for cancellation calculation"
    - name: "is_renewal_flag"
      expr: is_renewal_flag
      comment: "Whether transaction is a renewal"
    - name: "is_midterm_flag"
      expr: is_midterm_flag
      comment: "Whether transaction is mid-term"
    - name: "is_backdated_flag"
      expr: is_backdated_flag
      comment: "Whether transaction is backdated"
    - name: "requires_underwriting_review_flag"
      expr: requires_underwriting_review_flag
      comment: "Whether transaction requires underwriting review"
    - name: "regulatory_filing_required_flag"
      expr: regulatory_filing_required_flag
      comment: "Whether regulatory filing is required"
    - name: "reinsurance_cession_required_flag"
      expr: reinsurance_cession_required_flag
      comment: "Whether reinsurance cession is required"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the transaction became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the transaction became effective"
    - name: "accounting_month"
      expr: DATE_TRUNC('MONTH', accounting_date)
      comment: "Accounting month of the transaction"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year of the transaction"
  measures:
    - name: "transaction_count"
      expr: COUNT(1)
      comment: "Total number of policy transactions"
    - name: "total_premium_change"
      expr: SUM(CAST(written_premium_change_amount AS DOUBLE))
      comment: "Total written premium change across all transactions"
    - name: "avg_premium_change"
      expr: AVG(CAST(written_premium_change_amount AS DOUBLE))
      comment: "Average written premium change per transaction"
    - name: "total_commission_impact"
      expr: SUM(CAST(commission_impact_amount AS DOUBLE))
      comment: "Total commission impact across all transactions"
    - name: "avg_commission_impact"
      expr: AVG(CAST(commission_impact_amount AS DOUBLE))
      comment: "Average commission impact per transaction"
    - name: "avg_reinstatement_lapse_days"
      expr: AVG(CAST(reinstatement_lapse_days AS DOUBLE))
      comment: "Average lapse days for reinstatement transactions"
    - name: "renewal_transaction_count"
      expr: COUNT(CASE WHEN is_renewal_flag = TRUE THEN 1 END)
      comment: "Number of renewal transactions"
    - name: "midterm_transaction_count"
      expr: COUNT(CASE WHEN is_midterm_flag = TRUE THEN 1 END)
      comment: "Number of mid-term transactions"
    - name: "backdated_transaction_count"
      expr: COUNT(CASE WHEN is_backdated_flag = TRUE THEN 1 END)
      comment: "Number of backdated transactions"
    - name: "uw_review_required_count"
      expr: COUNT(CASE WHEN requires_underwriting_review_flag = TRUE THEN 1 END)
      comment: "Number of transactions requiring underwriting review"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct number of policies with transactions"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_fee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy fee metrics tracking fee amounts, refunds, waivers, and fee counts by type, state, and payment plan. Grain: one row per fee transaction."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`fee`"
  dimensions:
    - name: "type_code"
      expr: type_code
      comment: "Fee type code"
    - name: "state_code"
      expr: state_code
      comment: "State where fee applies"
    - name: "billing_method_code"
      expr: billing_method_code
      comment: "Billing method code"
    - name: "payment_plan_code"
      expr: payment_plan_code
      comment: "Payment plan code"
    - name: "taxable_flag"
      expr: taxable_flag
      comment: "Whether fee is taxable"
    - name: "refunded_flag"
      expr: refunded_flag
      comment: "Whether fee has been refunded"
    - name: "waived_flag"
      expr: waived_flag
      comment: "Whether fee has been waived"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether fee is a reversal"
    - name: "refund_reason_code"
      expr: refund_reason_code
      comment: "Reason code for fee refund"
    - name: "waiver_reason_code"
      expr: waiver_reason_code
      comment: "Reason code for fee waiver"
    - name: "reversal_reason_code"
      expr: reversal_reason_code
      comment: "Reason code for fee reversal"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month of fee transaction"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month fee became effective"
  measures:
    - name: "fee_count"
      expr: COUNT(1)
      comment: "Total number of fee transactions"
    - name: "total_fee_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total fee amount across all transactions"
    - name: "avg_fee_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average fee amount per transaction"
    - name: "refunded_fee_count"
      expr: COUNT(CASE WHEN refunded_flag = TRUE THEN 1 END)
      comment: "Number of refunded fees"
    - name: "waived_fee_count"
      expr: COUNT(CASE WHEN waived_flag = TRUE THEN 1 END)
      comment: "Number of waived fees"
    - name: "reversal_fee_count"
      expr: COUNT(CASE WHEN reversal_flag = TRUE THEN 1 END)
      comment: "Number of reversed fees"
    - name: "taxable_fee_count"
      expr: COUNT(CASE WHEN taxable_flag = TRUE THEN 1 END)
      comment: "Number of taxable fees"
    - name: "avg_installment_number"
      expr: AVG(CAST(installment_number AS DOUBLE))
      comment: "Average installment number for fees"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct number of policies with fees"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_line`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Line of business metrics tracking written premium, total insured value, limits, deductibles, and retention by line, territory, and program. Grain: one row per line of business per policy term."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`line`"
  dimensions:
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code"
    - name: "lob_name"
      expr: lob_name
      comment: "Line of business name"
    - name: "lob_status"
      expr: lob_status
      comment: "Status of the line of business"
    - name: "sub_line_code"
      expr: sub_line_code
      comment: "Sub-line of business code"
    - name: "sub_line_name"
      expr: sub_line_name
      comment: "Sub-line of business name"
    - name: "naic_lob_code"
      expr: naic_lob_code
      comment: "NAIC line of business code"
    - name: "program_code"
      expr: program_code
      comment: "Program code"
    - name: "program_name"
      expr: program_name
      comment: "Program name"
    - name: "underwriting_tier"
      expr: underwriting_tier
      comment: "Underwriting tier"
    - name: "package_indicator"
      expr: package_indicator
      comment: "Whether line is part of a package policy"
    - name: "rate_basis"
      expr: rate_basis
      comment: "Basis for rating (per unit, per thousand, etc.)"
    - name: "reinsurance_treaty_code"
      expr: reinsurance_treaty_code
      comment: "Reinsurance treaty code"
    - name: "naics_code"
      expr: naics_code
      comment: "NAICS industry classification code"
    - name: "sic_code"
      expr: sic_code
      comment: "SIC industry classification code"
    - name: "effective_year"
      expr: YEAR(lob_effective_date)
      comment: "Year the line became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', lob_effective_date)
      comment: "Month the line became effective"
  measures:
    - name: "line_count"
      expr: COUNT(1)
      comment: "Total number of line of business records"
    - name: "total_written_premium"
      expr: SUM(CAST(written_premium_amount AS DOUBLE))
      comment: "Total written premium across all lines"
    - name: "avg_written_premium"
      expr: AVG(CAST(written_premium_amount AS DOUBLE))
      comment: "Average written premium per line"
    - name: "total_insured_value"
      expr: SUM(CAST(total_insured_value_amount AS DOUBLE))
      comment: "Total insured value across all lines"
    - name: "avg_total_insured_value"
      expr: AVG(CAST(total_insured_value_amount AS DOUBLE))
      comment: "Average total insured value per line"
    - name: "total_policy_limit"
      expr: SUM(CAST(policy_limit_amount AS DOUBLE))
      comment: "Total policy limit across all lines"
    - name: "avg_policy_limit"
      expr: AVG(CAST(policy_limit_amount AS DOUBLE))
      comment: "Average policy limit per line"
    - name: "total_deductible"
      expr: SUM(CAST(deductible_amount AS DOUBLE))
      comment: "Total deductible across all lines"
    - name: "avg_deductible"
      expr: AVG(CAST(deductible_amount AS DOUBLE))
      comment: "Average deductible per line"
    - name: "total_retention"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention across all lines"
    - name: "avg_retention"
      expr: AVG(CAST(retention_amount AS DOUBLE))
      comment: "Average retention per line"
    - name: "total_pml"
      expr: SUM(CAST(pml_amount AS DOUBLE))
      comment: "Total probable maximum loss across all lines"
    - name: "avg_pml"
      expr: AVG(CAST(pml_amount AS DOUBLE))
      comment: "Average probable maximum loss per line"
    - name: "total_aal"
      expr: SUM(CAST(aal_amount AS DOUBLE))
      comment: "Total average annual loss across all lines"
    - name: "avg_aal"
      expr: AVG(CAST(aal_amount AS DOUBLE))
      comment: "Average annual loss per line"
    - name: "avg_ceded_percentage"
      expr: AVG(CAST(ceded_percentage AS DOUBLE))
      comment: "Average ceded percentage across lines"
    - name: "avg_coinsurance_percentage"
      expr: AVG(CAST(coinsurance_percentage AS DOUBLE))
      comment: "Average coinsurance percentage across lines"
    - name: "avg_experience_mod_factor"
      expr: AVG(CAST(experience_mod_factor AS DOUBLE))
      comment: "Average experience modification factor across lines"
    - name: "avg_rate_factor"
      expr: AVG(CAST(rate_factor AS DOUBLE))
      comment: "Average rate factor across lines"
    - name: "avg_loss_ratio_target"
      expr: AVG(CAST(loss_ratio_target AS DOUBLE))
      comment: "Average loss ratio target across lines"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct number of policies across lines"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_producer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Producer relationship metrics tracking commission rates, split percentages, and producer counts by role, appointment status, and servicing rights. Grain: one row per producer per policy."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`policy_producer`"
  dimensions:
    - name: "role_type"
      expr: role_type
      comment: "Producer role type (Primary, Secondary, Referral, etc.)"
    - name: "appointment_status"
      expr: appointment_status
      comment: "Status of producer appointment"
    - name: "producer_tier"
      expr: producer_tier
      comment: "Producer tier classification"
    - name: "of_record_flag"
      expr: of_record_flag
      comment: "Whether producer is the producer of record"
    - name: "servicing_rights_flag"
      expr: servicing_rights_flag
      comment: "Whether producer has servicing rights"
    - name: "commission_payable_flag"
      expr: commission_payable_flag
      comment: "Whether commission is payable to this producer"
    - name: "contingent_commission_eligible_flag"
      expr: contingent_commission_eligible_flag
      comment: "Whether producer is eligible for contingent commission"
    - name: "eo_coverage_verified_flag"
      expr: eo_coverage_verified_flag
      comment: "Whether errors and omissions coverage has been verified"
    - name: "referral_source"
      expr: referral_source
      comment: "Source of referral"
    - name: "servicing_office_code"
      expr: servicing_office_code
      comment: "Servicing office code"
    - name: "writing_company_code"
      expr: writing_company_code
      comment: "Writing company code"
    - name: "termination_reason_code"
      expr: termination_reason_code
      comment: "Reason code for producer termination"
    - name: "appointment_year"
      expr: YEAR(appointment_date)
      comment: "Year of producer appointment"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month producer relationship became effective"
  measures:
    - name: "producer_relationship_count"
      expr: COUNT(1)
      comment: "Total number of producer relationships"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate across producer relationships"
    - name: "avg_override_rate"
      expr: AVG(CAST(override_rate AS DOUBLE))
      comment: "Average override rate across producer relationships"
    - name: "avg_split_percentage"
      expr: AVG(CAST(split_percentage AS DOUBLE))
      comment: "Average split percentage across producer relationships"
    - name: "producer_of_record_count"
      expr: COUNT(CASE WHEN of_record_flag = TRUE THEN 1 END)
      comment: "Number of producer of record relationships"
    - name: "servicing_rights_count"
      expr: COUNT(CASE WHEN servicing_rights_flag = TRUE THEN 1 END)
      comment: "Number of relationships with servicing rights"
    - name: "commission_payable_count"
      expr: COUNT(CASE WHEN commission_payable_flag = TRUE THEN 1 END)
      comment: "Number of relationships with payable commission"
    - name: "contingent_eligible_count"
      expr: COUNT(CASE WHEN contingent_commission_eligible_flag = TRUE THEN 1 END)
      comment: "Number of relationships eligible for contingent commission"
    - name: "eo_verified_count"
      expr: COUNT(CASE WHEN eo_coverage_verified_flag = TRUE THEN 1 END)
      comment: "Number of relationships with verified E&O coverage"
    - name: "terminated_relationship_count"
      expr: COUNT(CASE WHEN termination_date IS NOT NULL THEN 1 END)
      comment: "Number of terminated producer relationships"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct number of policies with producer relationships"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Distinct number of producers"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Distinct number of agencies"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_form`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy form metrics tracking form counts, premium-bearing forms, and mandatory forms by type, state, and filing status. Grain: one row per form per policy."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`form`"
  dimensions:
    - name: "form_type"
      expr: form_type
      comment: "Type of form (Coverage, Endorsement, Exclusion, Condition)"
    - name: "form_status"
      expr: form_status
      comment: "Status of the form"
    - name: "form_category"
      expr: form_category
      comment: "Form form_category"
    - name: "state_code"
      expr: state_code
      comment: "State where form applies"
    - name: "mandatory_flag"
      expr: mandatory_flag
      comment: "Whether form is mandatory"
    - name: "premium_bearing_flag"
      expr: premium_bearing_flag
      comment: "Whether form affects premium"
    - name: "iso_form_flag"
      expr: iso_form_flag
      comment: "Whether form is an ISO standard form"
    - name: "acord_form_flag"
      expr: acord_form_flag
      comment: "Whether form is an ACORD standard form"
    - name: "attachment_reason_code"
      expr: attachment_reason_code
      comment: "Reason code for form attachment"
    - name: "transaction_type"
      expr: transaction_type
      comment: "Transaction type that triggered form attachment"
    - name: "language"
      expr: language
      comment: "Language of the form"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the form became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the form became effective"
    - name: "approval_year"
      expr: YEAR(approval_date)
      comment: "Year the form was approved"
  measures:
    - name: "form_count"
      expr: COUNT(1)
      comment: "Total number of forms attached to policies"
    - name: "total_form_premium"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Total premium associated with forms"
    - name: "avg_form_premium"
      expr: AVG(CAST(premium_amount AS DOUBLE))
      comment: "Average premium per form"
    - name: "avg_attachment_sequence"
      expr: AVG(CAST(attachment_sequence AS DOUBLE))
      comment: "Average attachment sequence number"
    - name: "mandatory_form_count"
      expr: COUNT(CASE WHEN mandatory_flag = TRUE THEN 1 END)
      comment: "Number of mandatory forms"
    - name: "premium_bearing_form_count"
      expr: COUNT(CASE WHEN premium_bearing_flag = TRUE THEN 1 END)
      comment: "Number of premium-bearing forms"
    - name: "iso_form_count"
      expr: COUNT(CASE WHEN iso_form_flag = TRUE THEN 1 END)
      comment: "Number of ISO standard forms"
    - name: "acord_form_count"
      expr: COUNT(CASE WHEN acord_form_flag = TRUE THEN 1 END)
      comment: "Number of ACORD standard forms"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct number of policies with forms"
    - name: "distinct_form_number_count"
      expr: COUNT(DISTINCT form_number)
      comment: "Distinct number of unique form numbers"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_state_reg`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "State regulatory compliance metrics tracking tax amounts, stamping fees, guaranty fund assessments, and compliance status by state and line of business. Grain: one row per state regulation per policy."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`state_reg`"
  dimensions:
    - name: "admitted_status"
      expr: admitted_status
      comment: "Admitted or surplus lines status"
    - name: "regulatory_compliance_status"
      expr: regulatory_compliance_status
      comment: "Regulatory compliance status"
    - name: "assigned_risk_pool_indicator"
      expr: assigned_risk_pool_indicator
      comment: "Whether policy is in assigned risk pool"
    - name: "fair_plan_indicator"
      expr: fair_plan_indicator
      comment: "Whether policy is in FAIR plan"
    - name: "financial_responsibility_filing_indicator"
      expr: financial_responsibility_filing_indicator
      comment: "Whether financial responsibility filing is required"
    - name: "financial_responsibility_filing_type"
      expr: financial_responsibility_filing_type
      comment: "Type of financial responsibility filing"
    - name: "state_mandated_coverage_indicator"
      expr: state_mandated_coverage_indicator
      comment: "Whether policy includes state-mandated coverage"
    - name: "surplus_lines_stamping_office"
      expr: surplus_lines_stamping_office
      comment: "Surplus lines stamping office"
    - name: "naic_company_code"
      expr: naic_company_code
      comment: "NAIC company code"
    - name: "state_reporting_code"
      expr: state_reporting_code
      comment: "State reporting code"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the state regulation became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the state regulation became effective"
    - name: "compliance_review_year"
      expr: YEAR(compliance_review_date)
      comment: "Year of compliance review"
  measures:
    - name: "state_reg_count"
      expr: COUNT(1)
      comment: "Total number of state regulatory records"
    - name: "total_state_tax"
      expr: SUM(CAST(state_tax_amount AS DOUBLE))
      comment: "Total state tax amount"
    - name: "avg_state_tax"
      expr: AVG(CAST(state_tax_amount AS DOUBLE))
      comment: "Average state tax per record"
    - name: "total_municipal_tax"
      expr: SUM(CAST(municipal_tax_amount AS DOUBLE))
      comment: "Total municipal tax amount"
    - name: "avg_municipal_tax"
      expr: AVG(CAST(municipal_tax_amount AS DOUBLE))
      comment: "Average municipal tax per record"
    - name: "total_stamping_fee"
      expr: SUM(CAST(stamping_fee_amount AS DOUBLE))
      comment: "Total stamping fee amount"
    - name: "avg_stamping_fee"
      expr: AVG(CAST(stamping_fee_amount AS DOUBLE))
      comment: "Average stamping fee per record"
    - name: "total_guaranty_fund_assessment"
      expr: SUM(CAST(guaranty_fund_assessment_amount AS DOUBLE))
      comment: "Total guaranty fund assessment amount"
    - name: "avg_guaranty_fund_assessment"
      expr: AVG(CAST(guaranty_fund_assessment_amount AS DOUBLE))
      comment: "Average guaranty fund assessment per record"
    - name: "total_minimum_liability_limit"
      expr: SUM(CAST(minimum_liability_limit_required AS DOUBLE))
      comment: "Total minimum liability limit required"
    - name: "avg_state_tax_rate"
      expr: AVG(CAST(state_tax_rate AS DOUBLE))
      comment: "Average state tax rate"
    - name: "avg_municipal_tax_rate"
      expr: AVG(CAST(municipal_tax_rate AS DOUBLE))
      comment: "Average municipal tax rate"
    - name: "avg_guaranty_fund_rate"
      expr: AVG(CAST(guaranty_fund_assessment_rate AS DOUBLE))
      comment: "Average guaranty fund assessment rate"
    - name: "assigned_risk_count"
      expr: COUNT(CASE WHEN assigned_risk_pool_indicator = TRUE THEN 1 END)
      comment: "Number of assigned risk pool policies"
    - name: "fair_plan_count"
      expr: COUNT(CASE WHEN fair_plan_indicator = TRUE THEN 1 END)
      comment: "Number of FAIR plan policies"
    - name: "financial_filing_count"
      expr: COUNT(CASE WHEN financial_responsibility_filing_indicator = TRUE THEN 1 END)
      comment: "Number of policies with financial responsibility filing"
    - name: "state_mandated_coverage_count"
      expr: COUNT(CASE WHEN state_mandated_coverage_indicator = TRUE THEN 1 END)
      comment: "Number of policies with state-mandated coverage"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct number of policies with state regulations"
$$;