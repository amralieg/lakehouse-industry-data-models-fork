-- Metric views for domain: producers | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`producers_commission_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commission transaction metrics tracking earned, gross, and net commission amounts, chargeback activity, and payment performance across producers, policies, and lines of business."
  source: "`vibe_pc_insurance_v499`.`producers`.`commission_transaction`"
  dimensions:
    - name: "transaction_date"
      expr: transaction_date
      comment: "Date the commission transaction was recorded."
    - name: "transaction_year"
      expr: YEAR(transaction_date)
      comment: "Year of the commission transaction."
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month of the commission transaction."
    - name: "accounting_date"
      expr: accounting_date
      comment: "Date the commission was recognized for accounting purposes."
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of commission transaction (new business, renewal, endorsement, cancellation, etc.)."
    - name: "commission_type"
      expr: commission_type
      comment: "Classification of commission (base, override, contingent, bonus, etc.)."
    - name: "transaction_status"
      expr: transaction_status
      comment: "Current status of the commission transaction (pending, approved, paid, reversed, etc.)."
    - name: "payment_status"
      expr: payment_status
      comment: "Payment status of the commission (unpaid, paid, partially paid, etc.)."
    - name: "approval_status"
      expr: approval_status
      comment: "Approval status of the commission transaction."
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Indicates whether this transaction is a reversal of a prior commission."
    - name: "contingent_commission_flag"
      expr: contingent_commission_flag
      comment: "Indicates whether this is a contingent commission based on performance metrics."
    - name: "dac_eligible_flag"
      expr: dac_eligible_flag
      comment: "Indicates whether this commission is eligible for deferred acquisition cost treatment."
    - name: "payment_method"
      expr: payment_method
      comment: "Method used to pay the commission (ACH, check, wire, etc.)."
    - name: "cancellation_reason_code"
      expr: cancellation_reason_code
      comment: "Reason code when commission is related to a policy cancellation."
  measures:
    - name: "total_earned_commission"
      expr: SUM(CAST(earned_commission_amount AS DOUBLE))
      comment: "Total earned commission amount across all transactions."
    - name: "total_gross_commission"
      expr: SUM(CAST(gross_commission_amount AS DOUBLE))
      comment: "Total gross commission amount before adjustments and chargebacks."
    - name: "total_net_commission"
      expr: SUM(CAST(net_commission_amount AS DOUBLE))
      comment: "Total net commission amount after all adjustments, chargebacks, and withholdings."
    - name: "total_chargeback_amount"
      expr: SUM(CAST(chargeback_amount AS DOUBLE))
      comment: "Total commission chargeback amount due to cancellations or policy adjustments."
    - name: "total_adjustment_amount"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total commission adjustment amount (positive or negative corrections)."
    - name: "total_override_commission"
      expr: SUM(CAST(override_commission_amount AS DOUBLE))
      comment: "Total override commission paid to managing producers or agencies."
    - name: "total_unearned_commission"
      expr: SUM(CAST(unearned_commission_amount AS DOUBLE))
      comment: "Total unearned commission amount deferred for future recognition."
    - name: "total_gwp_basis"
      expr: SUM(CAST(gwp_basis_amount AS DOUBLE))
      comment: "Total gross written premium amount used as the basis for commission calculation."
    - name: "total_tax_withholding"
      expr: SUM(CAST(tax_withholding_amount AS DOUBLE))
      comment: "Total tax withholding amount deducted from commission payments."
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate applied across transactions."
    - name: "transaction_count"
      expr: COUNT(1)
      comment: "Total number of commission transactions."
    - name: "reversal_transaction_count"
      expr: COUNT(CASE WHEN reversal_flag = TRUE THEN 1 END)
      comment: "Number of commission transactions that are reversals."
    - name: "contingent_commission_count"
      expr: COUNT(CASE WHEN contingent_commission_flag = TRUE THEN 1 END)
      comment: "Number of contingent commission transactions."
    - name: "unique_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of unique producers receiving commission in the transaction set."
    - name: "unique_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of unique policies generating commission transactions."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`producers_commission_statement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commission statement metrics tracking settlement amounts, policy counts, loss ratios, and payment performance by producer and agency over settlement periods."
  source: "`vibe_pc_insurance_v499`.`producers`.`commission_statement`"
  dimensions:
    - name: "statement_date"
      expr: statement_date
      comment: "Date the commission statement was generated."
    - name: "statement_year"
      expr: YEAR(statement_date)
      comment: "Year of the commission statement."
    - name: "statement_month"
      expr: DATE_TRUNC('MONTH', statement_date)
      comment: "Month of the commission statement."
    - name: "settlement_period_start"
      expr: settlement_period_start_date
      comment: "Start date of the settlement period covered by the statement."
    - name: "settlement_period_end"
      expr: settlement_period_end_date
      comment: "End date of the settlement period covered by the statement."
    - name: "payment_date"
      expr: payment_date
      comment: "Date the commission payment was made or scheduled."
    - name: "statement_status"
      expr: statement_status
      comment: "Current status of the commission statement (draft, finalized, paid, disputed, etc.)."
    - name: "statement_type"
      expr: statement_type
      comment: "Type of commission statement (regular, supplemental, adjustment, etc.)."
    - name: "producer_type"
      expr: producer_type
      comment: "Type of producer receiving the commission (agent, broker, MGA, etc.)."
    - name: "settlement_frequency"
      expr: settlement_frequency
      comment: "Frequency of commission settlement (monthly, quarterly, annual, etc.)."
    - name: "payment_method"
      expr: payment_method
      comment: "Method used to pay the commission (ACH, check, wire, etc.)."
    - name: "is_disputed"
      expr: is_disputed
      comment: "Indicates whether the commission statement is under dispute."
    - name: "dispute_resolution_date"
      expr: dispute_resolution_date
      comment: "Date the dispute was resolved, if applicable."
  measures:
    - name: "total_earned_commission"
      expr: SUM(CAST(earned_commission_amt AS DOUBLE))
      comment: "Total earned commission amount across all statements."
    - name: "total_net_payable"
      expr: SUM(CAST(net_payable_amt AS DOUBLE))
      comment: "Total net payable commission amount after all adjustments and deductions."
    - name: "total_gwp"
      expr: SUM(CAST(gross_written_premium_amt AS DOUBLE))
      comment: "Total gross written premium underlying the commission statements."
    - name: "total_chargeback"
      expr: SUM(CAST(chargeback_amt AS DOUBLE))
      comment: "Total chargeback amount due to cancellations or policy adjustments."
    - name: "total_adjustment"
      expr: SUM(CAST(adjustment_amt AS DOUBLE))
      comment: "Total adjustment amount applied to commission statements."
    - name: "total_bonus_commission"
      expr: SUM(CAST(bonus_commission_amt AS DOUBLE))
      comment: "Total bonus commission amount paid for performance or volume."
    - name: "total_contingent_commission"
      expr: SUM(CAST(contingent_commission_amt AS DOUBLE))
      comment: "Total contingent commission amount based on loss ratio or profitability."
    - name: "total_dac_eligible"
      expr: SUM(CAST(dac_eligible_amt AS DOUBLE))
      comment: "Total commission amount eligible for deferred acquisition cost treatment."
    - name: "total_tax_withheld"
      expr: SUM(CAST(tax_withheld_amt AS DOUBLE))
      comment: "Total tax withholding amount deducted from commission payments."
    - name: "total_prior_period_balance"
      expr: SUM(CAST(prior_period_balance_amt AS DOUBLE))
      comment: "Total prior period balance carried forward into current statements."
    - name: "avg_loss_ratio"
      expr: AVG(CAST(loss_ratio AS DOUBLE))
      comment: "Average loss ratio across commission statements."
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS BIGINT))
      comment: "Total number of policies included in commission statements."
    - name: "total_new_business_count"
      expr: SUM(CAST(new_business_policy_count AS BIGINT))
      comment: "Total number of new business policies generating commission."
    - name: "total_renewal_count"
      expr: SUM(CAST(renewal_policy_count AS BIGINT))
      comment: "Total number of renewal policies generating commission."
    - name: "total_cancellation_count"
      expr: SUM(CAST(cancellation_count AS BIGINT))
      comment: "Total number of policy cancellations affecting commission."
    - name: "statement_count"
      expr: COUNT(1)
      comment: "Total number of commission statements."
    - name: "disputed_statement_count"
      expr: COUNT(CASE WHEN is_disputed = TRUE THEN 1 END)
      comment: "Number of commission statements currently under dispute."
    - name: "unique_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of unique producers receiving commission statements."
    - name: "unique_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of unique agencies receiving commission statements."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`producers_contingent_bonus`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Contingent bonus metrics tracking performance-based compensation tied to loss ratio, growth, and volume targets for producers and agencies."
  source: "`vibe_pc_insurance_v499`.`producers`.`contingent_bonus`"
  dimensions:
    - name: "calculation_date"
      expr: calculation_date
      comment: "Date the contingent bonus was calculated."
    - name: "program_year"
      expr: program_year
      comment: "Program year for which the contingent bonus is calculated."
    - name: "measurement_period_start"
      expr: measurement_period_start_date
      comment: "Start date of the measurement period for bonus qualification."
    - name: "measurement_period_end"
      expr: measurement_period_end_date
      comment: "End date of the measurement period for bonus qualification."
    - name: "approval_date"
      expr: approval_date
      comment: "Date the contingent bonus was approved for payment."
    - name: "payment_date"
      expr: payment_date
      comment: "Date the contingent bonus was paid."
    - name: "bonus_status"
      expr: bonus_status
      comment: "Current status of the contingent bonus (pending, approved, paid, denied, etc.)."
    - name: "bonus_type"
      expr: bonus_type
      comment: "Type of contingent bonus (loss ratio, growth, volume, combined, etc.)."
    - name: "lr_qualified"
      expr: lr_qualified
      comment: "Indicates whether the producer met the loss ratio qualification threshold."
    - name: "growth_qualified"
      expr: growth_qualified
      comment: "Indicates whether the producer met the growth qualification threshold."
    - name: "volume_qualified"
      expr: volume_qualified
      comment: "Indicates whether the producer met the volume qualification threshold."
    - name: "overall_qualified"
      expr: overall_qualified
      comment: "Indicates whether the producer met all qualification criteria for the bonus."
    - name: "payment_method"
      expr: payment_method
      comment: "Method used to pay the contingent bonus (ACH, check, wire, etc.)."
  measures:
    - name: "total_earned_bonus"
      expr: SUM(CAST(earned_amount AS DOUBLE))
      comment: "Total earned contingent bonus amount across all producers."
    - name: "total_net_payable_bonus"
      expr: SUM(CAST(net_payable_amount AS DOUBLE))
      comment: "Total net payable contingent bonus amount after adjustments and withholdings."
    - name: "total_adjustment"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total adjustment amount applied to contingent bonuses."
    - name: "total_withholding_tax"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Total withholding tax amount deducted from contingent bonus payments."
    - name: "total_gwp"
      expr: SUM(CAST(gwp_amount AS DOUBLE))
      comment: "Total gross written premium used as the basis for contingent bonus calculation."
    - name: "total_nwp"
      expr: SUM(CAST(nwp_amount AS DOUBLE))
      comment: "Total net written premium used in contingent bonus calculation."
    - name: "total_ep"
      expr: SUM(CAST(ep_amount AS DOUBLE))
      comment: "Total earned premium used in loss ratio calculation for bonus qualification."
    - name: "total_incurred_losses"
      expr: SUM(CAST(incurred_losses_amount AS DOUBLE))
      comment: "Total incurred losses used in loss ratio calculation for bonus qualification."
    - name: "total_lae"
      expr: SUM(CAST(lae_amount AS DOUBLE))
      comment: "Total loss adjustment expense included in loss ratio calculation."
    - name: "total_prior_year_gwp"
      expr: SUM(CAST(prior_year_gwp_amount AS DOUBLE))
      comment: "Total prior year gross written premium used for growth calculation."
    - name: "avg_actual_lr"
      expr: AVG(CAST(actual_lr AS DOUBLE))
      comment: "Average actual loss ratio across contingent bonus calculations."
    - name: "avg_lr_threshold"
      expr: AVG(CAST(lr_threshold AS DOUBLE))
      comment: "Average loss ratio threshold required for bonus qualification."
    - name: "avg_bonus_rate"
      expr: AVG(CAST(bonus_rate AS DOUBLE))
      comment: "Average bonus rate applied to qualified producers."
    - name: "avg_gwp_growth_rate"
      expr: AVG(CAST(gwp_growth_rate AS DOUBLE))
      comment: "Average gross written premium growth rate across producers."
    - name: "avg_growth_target_rate"
      expr: AVG(CAST(growth_target_rate AS DOUBLE))
      comment: "Average growth target rate required for bonus qualification."
    - name: "bonus_count"
      expr: COUNT(1)
      comment: "Total number of contingent bonus records."
    - name: "qualified_bonus_count"
      expr: COUNT(CASE WHEN overall_qualified = TRUE THEN 1 END)
      comment: "Number of contingent bonuses where the producer met all qualification criteria."
    - name: "lr_qualified_count"
      expr: COUNT(CASE WHEN lr_qualified = TRUE THEN 1 END)
      comment: "Number of producers who met the loss ratio qualification threshold."
    - name: "growth_qualified_count"
      expr: COUNT(CASE WHEN growth_qualified = TRUE THEN 1 END)
      comment: "Number of producers who met the growth qualification threshold."
    - name: "volume_qualified_count"
      expr: COUNT(CASE WHEN volume_qualified = TRUE THEN 1 END)
      comment: "Number of producers who met the volume qualification threshold."
    - name: "unique_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of unique producers eligible for contingent bonuses."
    - name: "unique_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of unique agencies eligible for contingent bonuses."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`producers_agency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Agency performance metrics tracking premium volume, loss ratios, binding authority, and operational status across the agency distribution network."
  source: "`vibe_pc_insurance_v499`.`producers`.`agency`"
  dimensions:
    - name: "appointment_effective_date"
      expr: appointment_effective_date
      comment: "Date the agency appointment became effective."
    - name: "appointment_year"
      expr: YEAR(appointment_effective_date)
      comment: "Year the agency appointment became effective."
    - name: "appointment_termination_date"
      expr: appointment_termination_date
      comment: "Date the agency appointment was terminated, if applicable."
    - name: "agency_status"
      expr: agency_status
      comment: "Current operational status of the agency (active, suspended, terminated, etc.)."
    - name: "agency_type"
      expr: agency_type
      comment: "Type of agency (independent, captive, MGA, wholesaler, etc.)."
    - name: "binding_authority_flag"
      expr: binding_authority_flag
      comment: "Indicates whether the agency has binding authority to issue policies."
    - name: "managing_ga_flag"
      expr: managing_ga_flag
      comment: "Indicates whether the agency operates as a managing general agent."
    - name: "contingent_commission_eligible"
      expr: contingent_commission_eligible
      comment: "Indicates whether the agency is eligible for contingent commission programs."
    - name: "surplus_lines_licensed"
      expr: surplus_lines_licensed
      comment: "Indicates whether the agency is licensed to write surplus lines business."
    - name: "background_check_status"
      expr: background_check_status
      comment: "Status of the agency background check (passed, failed, pending, etc.)."
    - name: "termination_reason"
      expr: termination_reason
      comment: "Reason for agency appointment termination, if applicable."
    - name: "network_code"
      expr: network_code
      comment: "Network or cluster code the agency belongs to."
    - name: "territory_code"
      expr: territory_code
      comment: "Territory code assigned to the agency."
  measures:
    - name: "total_annual_premium_volume"
      expr: SUM(CAST(annual_premium_volume AS DOUBLE))
      comment: "Total annual premium volume across all agencies."
    - name: "total_pc_insurance_gwp"
      expr: SUM(CAST(pc_insurance_gwp AS DOUBLE))
      comment: "Total gross written premium for property and casualty insurance across agencies."
    - name: "total_binding_authority_limit"
      expr: SUM(CAST(binding_authority_limit AS DOUBLE))
      comment: "Total binding authority limit granted across all agencies."
    - name: "total_eo_coverage_amount"
      expr: SUM(CAST(eo_coverage_amount AS DOUBLE))
      comment: "Total errors and omissions coverage amount held by agencies."
    - name: "avg_loss_ratio"
      expr: AVG(CAST(loss_ratio AS DOUBLE))
      comment: "Average loss ratio across agencies."
    - name: "avg_years_in_business"
      expr: AVG(CAST(years_in_business AS DOUBLE))
      comment: "Average number of years agencies have been in business."
    - name: "agency_count"
      expr: COUNT(1)
      comment: "Total number of agencies."
    - name: "active_agency_count"
      expr: COUNT(CASE WHEN agency_status = 'active' THEN 1 END)
      comment: "Number of agencies with active status."
    - name: "binding_authority_agency_count"
      expr: COUNT(CASE WHEN binding_authority_flag = TRUE THEN 1 END)
      comment: "Number of agencies with binding authority."
    - name: "mga_agency_count"
      expr: COUNT(CASE WHEN managing_ga_flag = TRUE THEN 1 END)
      comment: "Number of agencies operating as managing general agents."
    - name: "contingent_eligible_agency_count"
      expr: COUNT(CASE WHEN contingent_commission_eligible = TRUE THEN 1 END)
      comment: "Number of agencies eligible for contingent commission programs."
    - name: "surplus_lines_agency_count"
      expr: COUNT(CASE WHEN surplus_lines_licensed = TRUE THEN 1 END)
      comment: "Number of agencies licensed to write surplus lines business."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`producers_producer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Individual producer performance metrics tracking licensing, appointments, binding authority, compliance, and E&O coverage status."
  source: "`vibe_pc_insurance_v499`.`producers`.`producers_producer`"
  dimensions:
    - name: "appointment_effective_date"
      expr: appointment_effective_date
      comment: "Date the producer appointment became effective."
    - name: "appointment_year"
      expr: YEAR(appointment_effective_date)
      comment: "Year the producer appointment became effective."
    - name: "appointment_termination_date"
      expr: appointment_termination_date
      comment: "Date the producer appointment was terminated, if applicable."
    - name: "onboarding_date"
      expr: onboarding_date
      comment: "Date the producer completed onboarding."
    - name: "license_expiration_date"
      expr: license_expiration_date
      comment: "Date the producer license expires."
    - name: "e_and_o_expiration_date"
      expr: e_and_o_expiration_date
      comment: "Date the producer errors and omissions policy expires."
    - name: "appointment_status"
      expr: appointment_status
      comment: "Current appointment status of the producer (active, suspended, terminated, etc.)."
    - name: "producer_type"
      expr: producer_type
      comment: "Type of producer (agent, broker, sub-producer, etc.)."
    - name: "entity_type"
      expr: entity_type
      comment: "Legal entity type of the producer (individual, corporation, LLC, etc.)."
    - name: "license_class"
      expr: license_class
      comment: "License class held by the producer (resident, non-resident, etc.)."
    - name: "binding_authority_granted"
      expr: binding_authority_granted
      comment: "Indicates whether the producer has been granted binding authority."
    - name: "contingent_commission_eligible"
      expr: contingent_commission_eligible
      comment: "Indicates whether the producer is eligible for contingent commission programs."
    - name: "surplus_lines_licensed"
      expr: surplus_lines_licensed
      comment: "Indicates whether the producer is licensed to write surplus lines business."
    - name: "continuing_education_compliant"
      expr: continuing_education_compliant
      comment: "Indicates whether the producer is compliant with continuing education requirements."
    - name: "anti_money_laundering_certified"
      expr: anti_money_laundering_certified
      comment: "Indicates whether the producer is certified in anti-money laundering compliance."
    - name: "background_check_status"
      expr: background_check_status
      comment: "Status of the producer background check (passed, failed, pending, etc.)."
    - name: "termination_reason"
      expr: termination_reason
      comment: "Reason for producer appointment termination, if applicable."
    - name: "uw_authority_level"
      expr: uw_authority_level
      comment: "Underwriting authority level granted to the producer."
    - name: "preferred_lob"
      expr: preferred_lob
      comment: "Preferred line of business for the producer."
  measures:
    - name: "total_binding_authority_limit"
      expr: SUM(CAST(binding_authority_limit AS DOUBLE))
      comment: "Total binding authority limit granted across all producers."
    - name: "total_eo_limit"
      expr: SUM(CAST(e_and_o_limit_amount AS DOUBLE))
      comment: "Total errors and omissions coverage limit held by producers."
    - name: "producer_count"
      expr: COUNT(1)
      comment: "Total number of producers."
    - name: "active_producer_count"
      expr: COUNT(CASE WHEN appointment_status = 'active' THEN 1 END)
      comment: "Number of producers with active appointment status."
    - name: "binding_authority_producer_count"
      expr: COUNT(CASE WHEN binding_authority_granted = TRUE THEN 1 END)
      comment: "Number of producers with binding authority."
    - name: "contingent_eligible_producer_count"
      expr: COUNT(CASE WHEN contingent_commission_eligible = TRUE THEN 1 END)
      comment: "Number of producers eligible for contingent commission programs."
    - name: "surplus_lines_producer_count"
      expr: COUNT(CASE WHEN surplus_lines_licensed = TRUE THEN 1 END)
      comment: "Number of producers licensed to write surplus lines business."
    - name: "ce_compliant_producer_count"
      expr: COUNT(CASE WHEN continuing_education_compliant = TRUE THEN 1 END)
      comment: "Number of producers compliant with continuing education requirements."
    - name: "aml_certified_producer_count"
      expr: COUNT(CASE WHEN anti_money_laundering_certified = TRUE THEN 1 END)
      comment: "Number of producers certified in anti-money laundering compliance."
    - name: "unique_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Number of unique agencies associated with producers."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`producers_binding_authority`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Binding authority metrics tracking authority limits, eligible coverages, risk restrictions, and compliance status for producers authorized to bind coverage."
  source: "`vibe_pc_insurance_v499`.`producers`.`binding_authority`"
  dimensions:
    - name: "effective_date"
      expr: effective_date
      comment: "Date the binding authority became effective."
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the binding authority became effective."
    - name: "expiration_date"
      expr: expiration_date
      comment: "Date the binding authority expires."
    - name: "approval_date"
      expr: approval_date
      comment: "Date the binding authority was approved."
    - name: "last_audit_date"
      expr: last_audit_date
      comment: "Date of the last audit of the binding authority."
    - name: "next_audit_date"
      expr: next_audit_date
      comment: "Date of the next scheduled audit."
    - name: "suspension_date"
      expr: suspension_date
      comment: "Date the binding authority was suspended, if applicable."
    - name: "authority_status"
      expr: authority_status
      comment: "Current status of the binding authority (active, suspended, expired, etc.)."
    - name: "authority_type"
      expr: authority_type
      comment: "Type of binding authority (full, limited, conditional, etc.)."
    - name: "renewal_type"
      expr: renewal_type
      comment: "Renewal type for the binding authority (automatic, manual, conditional, etc.)."
    - name: "is_suspended"
      expr: is_suspended
      comment: "Indicates whether the binding authority is currently suspended."
    - name: "admitted_carrier_flag"
      expr: admitted_carrier_flag
      comment: "Indicates whether the binding authority is for admitted carrier business."
    - name: "surplus_lines_flag"
      expr: surplus_lines_flag
      comment: "Indicates whether the binding authority covers surplus lines business."
    - name: "cat_exposed_flag"
      expr: cat_exposed_flag
      comment: "Indicates whether the binding authority covers catastrophe-exposed risks."
    - name: "reinsurance_required_flag"
      expr: reinsurance_required_flag
      comment: "Indicates whether reinsurance is required for risks bound under this authority."
    - name: "audit_frequency"
      expr: audit_frequency
      comment: "Frequency of audits required for the binding authority (monthly, quarterly, annual, etc.)."
    - name: "suspension_reason"
      expr: suspension_reason
      comment: "Reason for suspension of the binding authority, if applicable."
  measures:
    - name: "total_aggregate_annual_limit"
      expr: SUM(CAST(aggregate_annual_limit AS DOUBLE))
      comment: "Total aggregate annual limit across all binding authorities."
    - name: "total_max_policy_limit"
      expr: SUM(CAST(max_policy_limit AS DOUBLE))
      comment: "Total maximum policy limit across all binding authorities."
    - name: "total_max_single_risk_limit"
      expr: SUM(CAST(max_single_risk_limit AS DOUBLE))
      comment: "Total maximum single risk limit across all binding authorities."
    - name: "total_max_cat_tiv"
      expr: SUM(CAST(max_cat_tiv AS DOUBLE))
      comment: "Total maximum catastrophe total insured value across all binding authorities."
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate_pct AS DOUBLE))
      comment: "Average commission rate for binding authorities."
    - name: "avg_profit_commission_rate"
      expr: AVG(CAST(profit_commission_rate_pct AS DOUBLE))
      comment: "Average profit commission rate for binding authorities."
    - name: "avg_loss_ratio_threshold"
      expr: AVG(CAST(loss_ratio_threshold_pct AS DOUBLE))
      comment: "Average loss ratio threshold for binding authority compliance."
    - name: "avg_max_deductible"
      expr: AVG(CAST(max_deductible_amount AS DOUBLE))
      comment: "Average maximum deductible amount allowed under binding authorities."
    - name: "avg_min_deductible"
      expr: AVG(CAST(min_deductible_amount AS DOUBLE))
      comment: "Average minimum deductible amount required under binding authorities."
    - name: "binding_authority_count"
      expr: COUNT(1)
      comment: "Total number of binding authorities."
    - name: "active_authority_count"
      expr: COUNT(CASE WHEN authority_status = 'active' THEN 1 END)
      comment: "Number of binding authorities with active status."
    - name: "suspended_authority_count"
      expr: COUNT(CASE WHEN is_suspended = TRUE THEN 1 END)
      comment: "Number of binding authorities currently suspended."
    - name: "cat_exposed_authority_count"
      expr: COUNT(CASE WHEN cat_exposed_flag = TRUE THEN 1 END)
      comment: "Number of binding authorities covering catastrophe-exposed risks."
    - name: "surplus_lines_authority_count"
      expr: COUNT(CASE WHEN surplus_lines_flag = TRUE THEN 1 END)
      comment: "Number of binding authorities covering surplus lines business."
    - name: "unique_producer_count"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Number of unique producers with binding authority."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`producers_producer_compliance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Producer compliance metrics tracking license verification, background checks, continuing education, E&O coverage, and regulatory action status."
  source: "`vibe_pc_insurance_v499`.`producers`.`producer_compliance`"
  dimensions:
    - name: "case_open_date"
      expr: case_open_date
      comment: "Date the compliance case was opened."
    - name: "case_close_date"
      expr: case_close_date
      comment: "Date the compliance case was closed."
    - name: "review_completed_date"
      expr: review_completed_date
      comment: "Date the compliance review was completed."
    - name: "next_review_date"
      expr: next_review_date
      comment: "Date of the next scheduled compliance review."
    - name: "license_verification_date"
      expr: license_verification_date
      comment: "Date the producer license was last verified."
    - name: "license_expiration_date"
      expr: license_expiration_date
      comment: "Date the producer license expires."
    - name: "background_check_date"
      expr: background_check_date
      comment: "Date the background check was performed."
    - name: "ofac_screening_date"
      expr: ofac_screening_date
      comment: "Date the OFAC screening was performed."
    - name: "e_o_expiration_date"
      expr: e_o_expiration_date
      comment: "Date the errors and omissions policy expires."
    - name: "case_status"
      expr: case_status
      comment: "Current status of the compliance case (open, closed, pending, etc.)."
    - name: "case_type"
      expr: case_type
      comment: "Type of compliance case (onboarding, renewal, audit, investigation, etc.)."
    - name: "license_verification_status"
      expr: license_verification_status
      comment: "Status of the license verification (verified, failed, pending, etc.)."
    - name: "background_check_status"
      expr: background_check_status
      comment: "Status of the background check (passed, failed, pending, etc.)."
    - name: "ofac_screening_status"
      expr: ofac_screening_status
      comment: "Status of the OFAC screening (clear, match, pending, etc.)."
    - name: "appointment_eligibility_status"
      expr: appointment_eligibility_status
      comment: "Eligibility status for producer appointment (eligible, ineligible, conditional, etc.)."
    - name: "continuing_education_compliant"
      expr: continuing_education_compliant
      comment: "Indicates whether the producer is compliant with continuing education requirements."
    - name: "anti_money_laundering_trained"
      expr: anti_money_laundering_trained
      comment: "Indicates whether the producer has completed anti-money laundering training."
    - name: "e_o_coverage_verified"
      expr: e_o_coverage_verified
      comment: "Indicates whether the producer errors and omissions coverage has been verified."
    - name: "doi_disciplinary_flag"
      expr: doi_disciplinary_flag
      comment: "Indicates whether the producer has a Department of Insurance disciplinary action on record."
    - name: "market_conduct_finding_flag"
      expr: market_conduct_finding_flag
      comment: "Indicates whether the producer has a market conduct finding on record."
    - name: "state_appointment_filed"
      expr: state_appointment_filed
      comment: "Indicates whether the state appointment has been filed."
  measures:
    - name: "avg_ce_credit_hours_verified"
      expr: AVG(CAST(ce_credit_hours_verified AS DOUBLE))
      comment: "Average continuing education credit hours verified across producers."
    - name: "compliance_case_count"
      expr: COUNT(1)
      comment: "Total number of producer compliance cases."
    - name: "open_case_count"
      expr: COUNT(CASE WHEN case_status = 'open' THEN 1 END)
      comment: "Number of compliance cases currently open."
    - name: "closed_case_count"
      expr: COUNT(CASE WHEN case_status = 'closed' THEN 1 END)
      comment: "Number of compliance cases that have been closed."
    - name: "ce_compliant_count"
      expr: COUNT(CASE WHEN continuing_education_compliant = TRUE THEN 1 END)
      comment: "Number of producers compliant with continuing education requirements."
    - name: "aml_trained_count"
      expr: COUNT(CASE WHEN anti_money_laundering_trained = TRUE THEN 1 END)
      comment: "Number of producers who have completed anti-money laundering training."
    - name: "eo_verified_count"
      expr: COUNT(CASE WHEN e_o_coverage_verified = TRUE THEN 1 END)
      comment: "Number of producers with verified errors and omissions coverage."
    - name: "doi_disciplinary_count"
      expr: COUNT(CASE WHEN doi_disciplinary_flag = TRUE THEN 1 END)
      comment: "Number of producers with Department of Insurance disciplinary actions."
    - name: "market_conduct_finding_count"
      expr: COUNT(CASE WHEN market_conduct_finding_flag = TRUE THEN 1 END)
      comment: "Number of producers with market conduct findings."
    - name: "state_appointment_filed_count"
      expr: COUNT(CASE WHEN state_appointment_filed = TRUE THEN 1 END)
      comment: "Number of producers with state appointments filed."
    - name: "unique_producer_count"
      expr: COUNT(DISTINCT compliance_reviewer_producers_producer_id)
      comment: "Number of unique producers in compliance cases."
$$;