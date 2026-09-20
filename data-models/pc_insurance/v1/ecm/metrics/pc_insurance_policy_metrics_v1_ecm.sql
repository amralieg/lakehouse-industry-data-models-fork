-- Metric views for domain: policy | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core policy-level KPIs tracking written premium, policy counts, and risk distribution across lines of business, states, and distribution channels."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`policy`"
  dimensions:
    - name: "policy_status"
      expr: policy_status
      comment: "Current status of the policy (Active, Cancelled, Expired, etc.)"
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code (e.g., Personal Auto, Commercial Property)"
    - name: "state_code"
      expr: state_code
      comment: "State jurisdiction where policy is written"
    - name: "distribution_channel"
      expr: distribution_channel
      comment: "Distribution channel (Agent, Broker, Direct, etc.)"
    - name: "underwriting_tier"
      expr: underwriting_tier
      comment: "Underwriting tier or risk classification"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Calendar year when policy became effective"
    - name: "effective_quarter"
      expr: CONCAT('Q', QUARTER(effective_date), '-', YEAR(effective_date))
      comment: "Quarter and year when policy became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when policy became effective"
    - name: "renewal_indicator"
      expr: renewal_indicator
      comment: "Flag indicating whether policy is a renewal"
    - name: "auto_renew_flag"
      expr: auto_renew_flag
      comment: "Flag indicating whether policy is set to auto-renew"
    - name: "program_code"
      expr: program_code
      comment: "Program or product code"
    - name: "carrier_code"
      expr: carrier_code
      comment: "Carrier or company code"
  measures:
    - name: "policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Total number of unique policies"
    - name: "total_written_premium"
      expr: SUM(CAST(written_premium_amount AS DOUBLE))
      comment: "Total written premium across all policies"
    - name: "avg_written_premium"
      expr: AVG(CAST(written_premium_amount AS DOUBLE))
      comment: "Average written premium per policy"
    - name: "total_insured_value"
      expr: SUM(CAST(total_insured_value AS DOUBLE))
      comment: "Total insured value across all policies"
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average risk score across policies"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate across policies"
    - name: "renewal_count"
      expr: COUNT(DISTINCT CASE WHEN renewal_indicator = TRUE THEN policy_id END)
      comment: "Count of policies that are renewals"
    - name: "new_business_count"
      expr: COUNT(DISTINCT CASE WHEN renewal_indicator = FALSE THEN policy_id END)
      comment: "Count of new business policies"
    - name: "cancelled_policy_count"
      expr: COUNT(DISTINCT CASE WHEN cancellation_date IS NOT NULL THEN policy_id END)
      comment: "Count of policies that have been cancelled"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_term`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy term-level KPIs tracking premium, term counts, and performance by term period, enabling time-bounded policy analysis and renewal tracking."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`term`"
  dimensions:
    - name: "term_status"
      expr: term_status
      comment: "Current status of the policy term"
    - name: "lob"
      expr: lob
      comment: "Line of business for this term"
    - name: "is_renewal"
      expr: is_renewal
      comment: "Flag indicating whether term is a renewal"
    - name: "billing_method"
      expr: billing_method
      comment: "Billing method for this term"
    - name: "distribution_channel"
      expr: distribution_channel
      comment: "Distribution channel for this term"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Calendar year when term became effective"
    - name: "effective_quarter"
      expr: CONCAT('Q', QUARTER(effective_date), '-', YEAR(effective_date))
      comment: "Quarter and year when term became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when term became effective"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year number"
    - name: "calendar_year"
      expr: calendar_year
      comment: "Calendar year for reporting"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss reserving"
    - name: "cancellation_type"
      expr: cancellation_type
      comment: "Type of cancellation if term was cancelled"
    - name: "renewal_type"
      expr: renewal_type
      comment: "Type of renewal if term is a renewal"
  measures:
    - name: "term_count"
      expr: COUNT(DISTINCT term_id)
      comment: "Total number of unique policy terms"
    - name: "total_written_premium"
      expr: SUM(CAST(written_premium_amount AS DOUBLE))
      comment: "Total written premium across all terms"
    - name: "avg_written_premium"
      expr: AVG(CAST(written_premium_amount AS DOUBLE))
      comment: "Average written premium per term"
    - name: "avg_term_duration_days"
      expr: AVG(CAST(duration_days AS DOUBLE))
      comment: "Average term duration in days"
    - name: "renewal_term_count"
      expr: COUNT(DISTINCT CASE WHEN is_renewal = TRUE THEN term_id END)
      comment: "Count of terms that are renewals"
    - name: "new_business_term_count"
      expr: COUNT(DISTINCT CASE WHEN is_renewal = FALSE THEN term_id END)
      comment: "Count of new business terms"
    - name: "cancelled_term_count"
      expr: COUNT(DISTINCT CASE WHEN cancellation_date IS NOT NULL THEN term_id END)
      comment: "Count of terms that have been cancelled"
    - name: "unique_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Count of unique policies across all terms"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy transaction-level KPIs tracking premium changes, transaction counts, and endorsement activity by transaction type and effective period."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`"
  dimensions:
    - name: "type_code"
      expr: type_code
      comment: "Transaction type code (New Business, Renewal, Endorsement, Cancellation, etc.)"
    - name: "transaction_status"
      expr: transaction_status
      comment: "Current status of the transaction"
    - name: "reason_code"
      expr: reason_code
      comment: "Reason code for the transaction"
    - name: "cancellation_type_code"
      expr: cancellation_type_code
      comment: "Type of cancellation if transaction is a cancellation"
    - name: "cancellation_basis"
      expr: cancellation_basis
      comment: "Basis for cancellation (pro-rata, short-rate, flat)"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Calendar year when transaction became effective"
    - name: "effective_quarter"
      expr: CONCAT('Q', QUARTER(effective_date), '-', YEAR(effective_date))
      comment: "Quarter and year when transaction became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when transaction became effective"
    - name: "accounting_month"
      expr: DATE_TRUNC('MONTH', accounting_date)
      comment: "Accounting month for the transaction"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year number"
    - name: "is_renewal_flag"
      expr: is_renewal_flag
      comment: "Flag indicating whether transaction is a renewal"
    - name: "is_midterm_flag"
      expr: is_midterm_flag
      comment: "Flag indicating whether transaction is mid-term"
    - name: "is_backdated_flag"
      expr: is_backdated_flag
      comment: "Flag indicating whether transaction is backdated"
    - name: "requires_underwriting_review_flag"
      expr: requires_underwriting_review_flag
      comment: "Flag indicating whether transaction requires underwriting review"
  measures:
    - name: "transaction_count"
      expr: COUNT(DISTINCT policy_transaction_id)
      comment: "Total number of unique policy transactions"
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
    - name: "endorsement_count"
      expr: COUNT(DISTINCT CASE WHEN type_code = 'Endorsement' THEN policy_transaction_id END)
      comment: "Count of endorsement transactions"
    - name: "cancellation_count"
      expr: COUNT(DISTINCT CASE WHEN type_code = 'Cancellation' THEN policy_transaction_id END)
      comment: "Count of cancellation transactions"
    - name: "renewal_count"
      expr: COUNT(DISTINCT CASE WHEN is_renewal_flag = TRUE THEN policy_transaction_id END)
      comment: "Count of renewal transactions"
    - name: "midterm_transaction_count"
      expr: COUNT(DISTINCT CASE WHEN is_midterm_flag = TRUE THEN policy_transaction_id END)
      comment: "Count of mid-term transactions"
    - name: "backdated_transaction_count"
      expr: COUNT(DISTINCT CASE WHEN is_backdated_flag = TRUE THEN policy_transaction_id END)
      comment: "Count of backdated transactions"
    - name: "avg_reinstatement_lapse_days"
      expr: AVG(CAST(reinstatement_lapse_days AS DOUBLE))
      comment: "Average lapse days for reinstatement transactions"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_fee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fee transaction KPIs tracking fee revenue, waiver rates, and refund activity by fee type, state, and billing method."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`fee`"
  dimensions:
    - name: "type_code"
      expr: type_code
      comment: "Fee type code (Policy Fee, Installment Fee, etc.)"
    - name: "state_code"
      expr: state_code
      comment: "State jurisdiction for the fee"
    - name: "billing_method_code"
      expr: billing_method_code
      comment: "Billing method code"
    - name: "payment_plan_code"
      expr: payment_plan_code
      comment: "Payment plan code"
    - name: "waived_flag"
      expr: waived_flag
      comment: "Flag indicating whether fee was waived"
    - name: "refunded_flag"
      expr: refunded_flag
      comment: "Flag indicating whether fee was refunded"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Flag indicating whether fee was reversed"
    - name: "taxable_flag"
      expr: taxable_flag
      comment: "Flag indicating whether fee is taxable"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month when fee transaction occurred"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when fee became effective"
    - name: "waiver_reason_code"
      expr: waiver_reason_code
      comment: "Reason code for fee waiver"
    - name: "refund_reason_code"
      expr: refund_reason_code
      comment: "Reason code for fee refund"
  measures:
    - name: "fee_count"
      expr: COUNT(DISTINCT fee_id)
      comment: "Total number of unique fee transactions"
    - name: "total_fee_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total fee amount across all transactions"
    - name: "avg_fee_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average fee amount per transaction"
    - name: "waived_fee_count"
      expr: COUNT(DISTINCT CASE WHEN waived_flag = TRUE THEN fee_id END)
      comment: "Count of fees that were waived"
    - name: "refunded_fee_count"
      expr: COUNT(DISTINCT CASE WHEN refunded_flag = TRUE THEN fee_id END)
      comment: "Count of fees that were refunded"
    - name: "reversed_fee_count"
      expr: COUNT(DISTINCT CASE WHEN reversal_flag = TRUE THEN fee_id END)
      comment: "Count of fees that were reversed"
    - name: "taxable_fee_count"
      expr: COUNT(DISTINCT CASE WHEN taxable_flag = TRUE THEN fee_id END)
      comment: "Count of fees that are taxable"
    - name: "avg_installment_number"
      expr: AVG(CAST(installment_number AS DOUBLE))
      comment: "Average installment number for installment fees"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_line`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Line of business KPIs tracking written premium, limits, deductibles, and loss ratios by LOB, territory, and program."
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
    - name: "territory_code"
      expr: territory_code
      comment: "Territory code"
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
      comment: "Flag indicating whether line is part of a package"
    - name: "catastrophe_zone_code"
      expr: catastrophe_zone_code
      comment: "Catastrophe zone code"
    - name: "naic_lob_code"
      expr: naic_lob_code
      comment: "NAIC line of business code"
    - name: "effective_year"
      expr: YEAR(lob_effective_date)
      comment: "Calendar year when LOB became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', lob_effective_date)
      comment: "Month when LOB became effective"
  measures:
    - name: "line_count"
      expr: COUNT(DISTINCT line_id)
      comment: "Total number of unique lines of business"
    - name: "total_written_premium"
      expr: SUM(CAST(written_premium_amount AS DOUBLE))
      comment: "Total written premium across all lines"
    - name: "avg_written_premium"
      expr: AVG(CAST(written_premium_amount AS DOUBLE))
      comment: "Average written premium per line"
    - name: "total_policy_limit"
      expr: SUM(CAST(policy_limit_amount AS DOUBLE))
      comment: "Total policy limit across all lines"
    - name: "avg_policy_limit"
      expr: AVG(CAST(policy_limit_amount AS DOUBLE))
      comment: "Average policy limit per line"
    - name: "total_insured_value"
      expr: SUM(CAST(total_insured_value_amount AS DOUBLE))
      comment: "Total insured value across all lines"
    - name: "avg_deductible"
      expr: AVG(CAST(deductible_amount AS DOUBLE))
      comment: "Average deductible amount per line"
    - name: "avg_retention"
      expr: AVG(CAST(retention_amount AS DOUBLE))
      comment: "Average retention amount per line"
    - name: "total_pml"
      expr: SUM(CAST(pml_amount AS DOUBLE))
      comment: "Total probable maximum loss across all lines"
    - name: "total_aal"
      expr: SUM(CAST(aal_amount AS DOUBLE))
      comment: "Total average annual loss across all lines"
    - name: "avg_loss_ratio_target"
      expr: AVG(CAST(loss_ratio_target AS DOUBLE))
      comment: "Average target loss ratio across lines"
    - name: "avg_experience_mod_factor"
      expr: AVG(CAST(experience_mod_factor AS DOUBLE))
      comment: "Average experience modification factor"
    - name: "avg_rate_factor"
      expr: AVG(CAST(rate_factor AS DOUBLE))
      comment: "Average rate factor"
    - name: "avg_ceded_percentage"
      expr: AVG(CAST(ceded_percentage AS DOUBLE))
      comment: "Average ceded percentage to reinsurance"
    - name: "avg_coinsurance_percentage"
      expr: AVG(CAST(coinsurance_percentage AS DOUBLE))
      comment: "Average coinsurance percentage"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_policyholder`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policyholder relationship KPIs tracking insured counts, primary vs additional insured distribution, and interest types by holder type and role."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`policyholder`"
  dimensions:
    - name: "holder_type"
      expr: holder_type
      comment: "Type of policyholder (Named Insured, Additional Insured, etc.)"
    - name: "interest_type"
      expr: interest_type
      comment: "Type of insurable interest"
    - name: "policyholder_status"
      expr: policyholder_status
      comment: "Current status of the policyholder relationship"
    - name: "is_primary_insured"
      expr: is_primary_insured
      comment: "Flag indicating whether this is the primary insured"
    - name: "certificate_holder_flag"
      expr: certificate_holder_flag
      comment: "Flag indicating whether policyholder is a certificate holder"
    - name: "billing_responsibility_flag"
      expr: billing_responsibility_flag
      comment: "Flag indicating whether policyholder has billing responsibility"
    - name: "waiver_of_subrogation_flag"
      expr: waiver_of_subrogation_flag
      comment: "Flag indicating whether waiver of subrogation applies"
    - name: "notice_required_flag"
      expr: notice_required_flag
      comment: "Flag indicating whether notice is required"
    - name: "relationship_to_primary"
      expr: relationship_to_primary
      comment: "Relationship to primary insured"
    - name: "loss_payable_clause_type"
      expr: loss_payable_clause_type
      comment: "Type of loss payable clause"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Calendar year when policyholder relationship became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when policyholder relationship became effective"
  measures:
    - name: "policyholder_count"
      expr: COUNT(DISTINCT policyholder_id)
      comment: "Total number of unique policyholder relationships"
    - name: "unique_party_count"
      expr: COUNT(DISTINCT party_id)
      comment: "Count of unique parties across all policyholder relationships"
    - name: "unique_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Count of unique policies across all policyholder relationships"
    - name: "primary_insured_count"
      expr: COUNT(DISTINCT CASE WHEN is_primary_insured = TRUE THEN policyholder_id END)
      comment: "Count of primary insured relationships"
    - name: "additional_insured_count"
      expr: COUNT(DISTINCT CASE WHEN is_primary_insured = FALSE THEN policyholder_id END)
      comment: "Count of additional insured relationships"
    - name: "certificate_holder_count"
      expr: COUNT(DISTINCT CASE WHEN certificate_holder_flag = TRUE THEN policyholder_id END)
      comment: "Count of certificate holder relationships"
    - name: "avg_ownership_percentage"
      expr: AVG(CAST(ownership_percentage AS DOUBLE))
      comment: "Average ownership percentage across policyholder relationships"
    - name: "avg_rank_order"
      expr: AVG(CAST(rank_order AS DOUBLE))
      comment: "Average rank order of policyholders"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_reinsurance_link`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance cession KPIs tracking ceded limits, attachment points, commission rates, and reinsurer participation by treaty type and placement status."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`reinsurance_link`"
  dimensions:
    - name: "placement_type"
      expr: placement_type
      comment: "Type of reinsurance placement (Treaty, Facultative)"
    - name: "placement_status"
      expr: placement_status
      comment: "Status of the reinsurance placement"
    - name: "treaty_type"
      expr: treaty_type
      comment: "Type of treaty (Quota Share, Excess of Loss, Stop Loss)"
    - name: "cession_basis"
      expr: cession_basis
      comment: "Basis for cession calculation"
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code"
    - name: "territorial_scope"
      expr: territorial_scope
      comment: "Territorial scope of reinsurance coverage"
    - name: "authorized_flag"
      expr: authorized_flag
      comment: "Flag indicating whether reinsurer is authorized"
    - name: "cat_event_flag"
      expr: cat_event_flag
      comment: "Flag indicating whether coverage applies to catastrophe events"
    - name: "collateral_required_flag"
      expr: collateral_required_flag
      comment: "Flag indicating whether collateral is required"
    - name: "reinstatement_provision_flag"
      expr: reinstatement_provision_flag
      comment: "Flag indicating whether reinstatement provisions apply"
    - name: "sliding_scale_flag"
      expr: sliding_scale_flag
      comment: "Flag indicating whether sliding scale commission applies"
    - name: "loss_corridor_flag"
      expr: loss_corridor_flag
      comment: "Flag indicating whether loss corridor applies"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Calendar year when reinsurance became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when reinsurance became effective"
  measures:
    - name: "reinsurance_link_count"
      expr: COUNT(DISTINCT reinsurance_link_id)
      comment: "Total number of unique reinsurance links"
    - name: "total_ceded_limit"
      expr: SUM(CAST(ceded_limit_amount AS DOUBLE))
      comment: "Total ceded limit across all reinsurance links"
    - name: "avg_ceded_limit"
      expr: AVG(CAST(ceded_limit_amount AS DOUBLE))
      comment: "Average ceded limit per reinsurance link"
    - name: "total_retention"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount across all reinsurance links"
    - name: "avg_retention"
      expr: AVG(CAST(retention_amount AS DOUBLE))
      comment: "Average retention amount per reinsurance link"
    - name: "avg_attachment_point"
      expr: AVG(CAST(attachment_point AS DOUBLE))
      comment: "Average attachment point across reinsurance links"
    - name: "avg_cession_percentage"
      expr: AVG(CAST(cession_percentage AS DOUBLE))
      comment: "Average cession percentage to reinsurers"
    - name: "avg_reinsurer_share_percentage"
      expr: AVG(CAST(reinsurer_share_percentage AS DOUBLE))
      comment: "Average reinsurer share percentage"
    - name: "avg_commission_percentage"
      expr: AVG(CAST(commission_percentage AS DOUBLE))
      comment: "Average commission percentage from reinsurers"
    - name: "avg_profit_commission_percentage"
      expr: AVG(CAST(profit_commission_percentage AS DOUBLE))
      comment: "Average profit commission percentage"
    - name: "total_aggregate_limit"
      expr: SUM(CAST(aggregate_limit_amount AS DOUBLE))
      comment: "Total aggregate limit across all reinsurance links"
    - name: "total_aggregate_deductible"
      expr: SUM(CAST(aggregate_deductible_amount AS DOUBLE))
      comment: "Total aggregate deductible across all reinsurance links"
    - name: "total_collateral"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral amount across all reinsurance links"
    - name: "avg_reinstatement_premium_percentage"
      expr: AVG(CAST(reinstatement_premium_percentage AS DOUBLE))
      comment: "Average reinstatement premium percentage"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`policy_state_reg`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "State regulatory compliance KPIs tracking tax amounts, filing counts, and compliance status by state, LOB, and regulatory program."
  source: "`vibe_pc_insurance_blog_v499`.`policy`.`state_reg`"
  dimensions:
    - name: "admitted_status"
      expr: admitted_status
      comment: "Admitted or surplus lines status"
    - name: "regulatory_compliance_status"
      expr: regulatory_compliance_status
      comment: "Current regulatory compliance status"
    - name: "naic_line_of_business_code"
      expr: naic_line_of_business_code
      comment: "NAIC line of business code"
    - name: "assigned_risk_pool_indicator"
      expr: assigned_risk_pool_indicator
      comment: "Flag indicating whether policy is in assigned risk pool"
    - name: "fair_plan_indicator"
      expr: fair_plan_indicator
      comment: "Flag indicating whether policy is in FAIR plan"
    - name: "financial_responsibility_filing_indicator"
      expr: financial_responsibility_filing_indicator
      comment: "Flag indicating whether financial responsibility filing is required"
    - name: "state_mandated_coverage_indicator"
      expr: state_mandated_coverage_indicator
      comment: "Flag indicating whether state-mandated coverage applies"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Calendar year when state regulation became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when state regulation became effective"
    - name: "compliance_review_month"
      expr: DATE_TRUNC('MONTH', compliance_review_date)
      comment: "Month when compliance review occurred"
  measures:
    - name: "state_reg_count"
      expr: COUNT(DISTINCT state_reg_id)
      comment: "Total number of unique state regulatory records"
    - name: "total_state_tax"
      expr: SUM(CAST(state_tax_amount AS DOUBLE))
      comment: "Total state tax amount across all records"
    - name: "avg_state_tax_rate"
      expr: AVG(CAST(state_tax_rate AS DOUBLE))
      comment: "Average state tax rate"
    - name: "total_municipal_tax"
      expr: SUM(CAST(municipal_tax_amount AS DOUBLE))
      comment: "Total municipal tax amount across all records"
    - name: "avg_municipal_tax_rate"
      expr: AVG(CAST(municipal_tax_rate AS DOUBLE))
      comment: "Average municipal tax rate"
    - name: "total_stamping_fee"
      expr: SUM(CAST(stamping_fee_amount AS DOUBLE))
      comment: "Total stamping fee amount across all records"
    - name: "total_guaranty_fund_assessment"
      expr: SUM(CAST(guaranty_fund_assessment_amount AS DOUBLE))
      comment: "Total guaranty fund assessment amount"
    - name: "avg_guaranty_fund_assessment_rate"
      expr: AVG(CAST(guaranty_fund_assessment_rate AS DOUBLE))
      comment: "Average guaranty fund assessment rate"
    - name: "avg_minimum_liability_limit"
      expr: AVG(CAST(minimum_liability_limit_required AS DOUBLE))
      comment: "Average minimum liability limit required by state"
    - name: "assigned_risk_pool_count"
      expr: COUNT(DISTINCT CASE WHEN assigned_risk_pool_indicator = TRUE THEN state_reg_id END)
      comment: "Count of policies in assigned risk pools"
    - name: "fair_plan_count"
      expr: COUNT(DISTINCT CASE WHEN fair_plan_indicator = TRUE THEN state_reg_id END)
      comment: "Count of policies in FAIR plans"
    - name: "financial_responsibility_filing_count"
      expr: COUNT(DISTINCT CASE WHEN financial_responsibility_filing_indicator = TRUE THEN state_reg_id END)
      comment: "Count of policies with financial responsibility filings"
$$;