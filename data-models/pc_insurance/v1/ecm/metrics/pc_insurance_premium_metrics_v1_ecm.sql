-- Metric views for domain: premium | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_audit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Audit business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`audit`"
  dimensions:
    - name: "Audit Number"
      expr: audit_number
    - name: "Audit Status"
      expr: audit_status
    - name: "Audit Type"
      expr: audit_type
    - name: "Billing Adjustment Status"
      expr: billing_adjustment_status
    - name: "Completion Date"
      expr: completion_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deposit Reconciliation Status"
      expr: deposit_reconciliation_status
    - name: "Dispute Flag"
      expr: dispute_flag
    - name: "Dispute Reason"
      expr: dispute_reason
    - name: "Dispute Resolution Date"
      expr: dispute_resolution_date
    - name: "Exposure Basis Description"
      expr: exposure_basis_description
    - name: "Is Minimum Premium Applied"
      expr: is_minimum_premium_applied
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Method"
      expr: method
    - name: "Notes"
      expr: notes
    - name: "Period End Date"
      expr: period_end_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Audit"
      expr: COUNT(DISTINCT audit_id)
    - name: "Total Additional Premium Amount"
      expr: SUM(additional_premium_amount)
    - name: "Average Additional Premium Amount"
      expr: AVG(additional_premium_amount)
    - name: "Total Audited Exposure"
      expr: SUM(audited_exposure)
    - name: "Average Audited Exposure"
      expr: AVG(audited_exposure)
    - name: "Total Audited Premium Amount"
      expr: SUM(audited_premium_amount)
    - name: "Average Audited Premium Amount"
      expr: AVG(audited_premium_amount)
    - name: "Total Estimated Exposure"
      expr: SUM(estimated_exposure)
    - name: "Average Estimated Exposure"
      expr: AVG(estimated_exposure)
    - name: "Total Estimated Premium Amount"
      expr: SUM(estimated_premium_amount)
    - name: "Average Estimated Premium Amount"
      expr: AVG(estimated_premium_amount)
    - name: "Total Exposure Variance"
      expr: SUM(exposure_variance)
    - name: "Average Exposure Variance"
      expr: AVG(exposure_variance)
    - name: "Total Exposure Variance Percentage"
      expr: SUM(exposure_variance_percentage)
    - name: "Average Exposure Variance Percentage"
      expr: AVG(exposure_variance_percentage)
    - name: "Total Minimum Premium Amount"
      expr: SUM(minimum_premium_amount)
    - name: "Average Minimum Premium Amount"
      expr: AVG(minimum_premium_amount)
    - name: "Total Premium Variance Amount"
      expr: SUM(premium_variance_amount)
    - name: "Average Premium Variance Amount"
      expr: AVG(premium_variance_amount)
    - name: "Total Return Premium Amount"
      expr: SUM(return_premium_amount)
    - name: "Average Return Premium Amount"
      expr: AVG(return_premium_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_bearing_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Bearing Coverage business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage`"
  dimensions:
    - name: "Allocation Basis"
      expr: allocation_basis
    - name: "Allocation Status"
      expr: allocation_status
    - name: "Allocation Type"
      expr: allocation_type
    - name: "Coverage Description"
      expr: coverage_description
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Is Ceded"
      expr: is_ceded
    - name: "Is Commissionable"
      expr: is_commissionable
    - name: "Is Primary Coverage"
      expr: is_primary_coverage
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Notes"
      expr: notes
    - name: "Reversal Date"
      expr: reversal_date
    - name: "Reversal Reason Code"
      expr: reversal_reason_code
    - name: "Risk Type"
      expr: risk_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Bearing Coverage"
      expr: COUNT(DISTINCT bearing_coverage_id)
    - name: "Total Allocated Amount"
      expr: SUM(allocated_amount)
    - name: "Average Allocated Amount"
      expr: AVG(allocated_amount)
    - name: "Total Allocation Percentage"
      expr: SUM(allocation_percentage)
    - name: "Average Allocation Percentage"
      expr: AVG(allocation_percentage)
    - name: "Total Allocation Sequence"
      expr: SUM(allocation_sequence)
    - name: "Average Allocation Sequence"
      expr: AVG(allocation_sequence)
    - name: "Total Ceded Amount"
      expr: SUM(ceded_amount)
    - name: "Average Ceded Amount"
      expr: AVG(ceded_amount)
    - name: "Total Commission Amount"
      expr: SUM(commission_amount)
    - name: "Average Commission Amount"
      expr: AVG(commission_amount)
    - name: "Total Commission Rate"
      expr: SUM(commission_rate)
    - name: "Average Commission Rate"
      expr: AVG(commission_rate)
    - name: "Total Net Amount"
      expr: SUM(net_amount)
    - name: "Average Net Amount"
      expr: AVG(net_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_ceded_premium`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Ceded Premium business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium`"
  dimensions:
    - name: "Bordereaux Reporting Flag"
      expr: bordereaux_reporting_flag
    - name: "Bordereaux Submission Date"
      expr: bordereaux_submission_date
    - name: "Cession Basis"
      expr: cession_basis
    - name: "Cession Number"
      expr: cession_number
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Notes"
      expr: notes
    - name: "Reversal Indicator"
      expr: reversal_indicator
    - name: "Reversal Reason Code"
      expr: reversal_reason_code
    - name: "Settlement Date"
      expr: settlement_date
    - name: "Settlement Status"
      expr: settlement_status
    - name: "Source System Code"
      expr: source_system_code
    - name: "State Code"
      expr: state_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Ceded Premium"
      expr: COUNT(DISTINCT ceded_premium_id)
    - name: "Total Ceded Earned Premium"
      expr: SUM(ceded_earned_premium)
    - name: "Average Ceded Earned Premium"
      expr: AVG(ceded_earned_premium)
    - name: "Total Ceded Unearned Premium"
      expr: SUM(ceded_unearned_premium)
    - name: "Average Ceded Unearned Premium"
      expr: AVG(ceded_unearned_premium)
    - name: "Total Ceded Written Premium"
      expr: SUM(ceded_written_premium)
    - name: "Average Ceded Written Premium"
      expr: AVG(ceded_written_premium)
    - name: "Total Ceding Commission Amount"
      expr: SUM(ceding_commission_amount)
    - name: "Average Ceding Commission Amount"
      expr: AVG(ceding_commission_amount)
    - name: "Total Ceding Commission Rate"
      expr: SUM(ceding_commission_rate)
    - name: "Average Ceding Commission Rate"
      expr: AVG(ceding_commission_rate)
    - name: "Total Cession Rate"
      expr: SUM(cession_rate)
    - name: "Average Cession Rate"
      expr: AVG(cession_rate)
    - name: "Total Net Ceded Premium"
      expr: SUM(net_ceded_premium)
    - name: "Average Net Ceded Premium"
      expr: AVG(net_ceded_premium)
    - name: "Total Profit Commission Amount"
      expr: SUM(profit_commission_amount)
    - name: "Average Profit Commission Amount"
      expr: AVG(profit_commission_amount)
    - name: "Total Profit Commission Rate"
      expr: SUM(profit_commission_rate)
    - name: "Average Profit Commission Rate"
      expr: AVG(profit_commission_rate)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_charge`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Charge business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`charge`"
  dimensions:
    - name: "Category"
      expr: charge_category
    - name: "Charge Status"
      expr: charge_status
    - name: "Charge Type"
      expr: charge_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Description"
      expr: reversal_reason_description
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Is Ceded"
      expr: is_ceded
    - name: "Is Commissionable"
      expr: is_commissionable
    - name: "Is Earned"
      expr: is_earned
    - name: "Is Minimum Premium"
      expr: is_minimum_premium
    - name: "Is Prorated"
      expr: is_prorated
    - name: "Number"
      expr: number
    - name: "Rating Element Code"
      expr: rating_element_code
    - name: "Rating Element Description"
      expr: rating_element_description
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Charge"
      expr: COUNT(DISTINCT charge_id)
    - name: "Total Amount"
      expr: SUM(amount)
    - name: "Average Amount"
      expr: AVG(amount)
    - name: "Total Basis Amount"
      expr: SUM(basis_amount)
    - name: "Average Basis Amount"
      expr: AVG(basis_amount)
    - name: "Total Ceded Amount"
      expr: SUM(ceded_amount)
    - name: "Average Ceded Amount"
      expr: AVG(ceded_amount)
    - name: "Total Commission Amount"
      expr: SUM(commission_amount)
    - name: "Average Commission Amount"
      expr: AVG(commission_amount)
    - name: "Total Commission Rate"
      expr: SUM(commission_rate)
    - name: "Average Commission Rate"
      expr: AVG(commission_rate)
    - name: "Total Earned Amount"
      expr: SUM(earned_amount)
    - name: "Average Earned Amount"
      expr: AVG(earned_amount)
    - name: "Total Net Amount"
      expr: SUM(net_amount)
    - name: "Average Net Amount"
      expr: AVG(net_amount)
    - name: "Total Percentage"
      expr: SUM(percentage)
    - name: "Average Percentage"
      expr: AVG(percentage)
    - name: "Total Proration Factor"
      expr: SUM(proration_factor)
    - name: "Average Proration Factor"
      expr: AVG(proration_factor)
    - name: "Total Rate"
      expr: SUM(rate)
    - name: "Average Rate"
      expr: AVG(rate)
    - name: "Total Sequence"
      expr: SUM(sequence)
    - name: "Average Sequence"
      expr: AVG(sequence)
    - name: "Total Unearned Amount"
      expr: SUM(unearned_amount)
    - name: "Average Unearned Amount"
      expr: AVG(unearned_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_commission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commission business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`commission`"
  dimensions:
    - name: "Basis"
      expr: basis
    - name: "Calculation Method"
      expr: calculation_method
    - name: "Chargeback Indicator"
      expr: chargeback_indicator
    - name: "Chargeback Reason"
      expr: chargeback_reason
    - name: "Commission Status"
      expr: commission_status
    - name: "Commission Type"
      expr: commission_type
    - name: "Contingent Indicator"
      expr: contingent_indicator
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Earned Date"
      expr: earned_date
    - name: "Effective Date"
      expr: effective_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Notes"
      expr: notes
    - name: "Override Indicator"
      expr: override_indicator
    - name: "Payment Date"
      expr: payment_date
    - name: "Payment Method"
      expr: payment_method
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Commission"
      expr: COUNT(DISTINCT commission_id)
    - name: "Total Amount"
      expr: SUM(amount)
    - name: "Average Amount"
      expr: AVG(amount)
    - name: "Total Basis Amount"
      expr: SUM(basis_amount)
    - name: "Average Basis Amount"
      expr: AVG(basis_amount)
    - name: "Total Net Payable Amount"
      expr: SUM(net_payable_amount)
    - name: "Average Net Payable Amount"
      expr: AVG(net_payable_amount)
    - name: "Total Rate"
      expr: SUM(rate)
    - name: "Average Rate"
      expr: AVG(rate)
    - name: "Total Split Percentage"
      expr: SUM(split_percentage)
    - name: "Average Split Percentage"
      expr: AVG(split_percentage)
    - name: "Total Tax Withholding Amount"
      expr: SUM(tax_withholding_amount)
    - name: "Average Tax Withholding Amount"
      expr: AVG(tax_withholding_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_deposit_premium`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Deposit Premium business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium`"
  dimensions:
    - name: "Adjustment Type"
      expr: adjustment_type
    - name: "Audit Completed Date"
      expr: audit_completed_date
    - name: "Audit Required Flag"
      expr: audit_required_flag
    - name: "Audit Scheduled Date"
      expr: audit_scheduled_date
    - name: "Audit Type"
      expr: audit_type
    - name: "Basis Of Estimate"
      expr: basis_of_estimate
    - name: "Billing Date"
      expr: billing_date
    - name: "Collection Date"
      expr: collection_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deposit Number"
      expr: deposit_number
    - name: "Deposit Status"
      expr: deposit_status
    - name: "Deposit Type"
      expr: deposit_type
    - name: "Effective Date"
      expr: effective_date
    - name: "Estimated Exposure Basis"
      expr: estimated_exposure_basis
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gl Account Code"
      expr: gl_account_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Deposit Premium"
      expr: COUNT(DISTINCT deposit_premium_id)
    - name: "Total Actual Exposure Amount"
      expr: SUM(actual_exposure_amount)
    - name: "Average Actual Exposure Amount"
      expr: AVG(actual_exposure_amount)
    - name: "Total Adjustment Amount"
      expr: SUM(adjustment_amount)
    - name: "Average Adjustment Amount"
      expr: AVG(adjustment_amount)
    - name: "Total Deposit Amount"
      expr: SUM(deposit_amount)
    - name: "Average Deposit Amount"
      expr: AVG(deposit_amount)
    - name: "Total Deposit Percentage"
      expr: SUM(deposit_percentage)
    - name: "Average Deposit Percentage"
      expr: AVG(deposit_percentage)
    - name: "Total Estimated Exposure Amount"
      expr: SUM(estimated_exposure_amount)
    - name: "Average Estimated Exposure Amount"
      expr: AVG(estimated_exposure_amount)
    - name: "Total Final Premium Amount"
      expr: SUM(final_premium_amount)
    - name: "Average Final Premium Amount"
      expr: AVG(final_premium_amount)
    - name: "Total Maximum Deposit Amount"
      expr: SUM(maximum_deposit_amount)
    - name: "Average Maximum Deposit Amount"
      expr: AVG(maximum_deposit_amount)
    - name: "Total Minimum Deposit Amount"
      expr: SUM(minimum_deposit_amount)
    - name: "Average Minimum Deposit Amount"
      expr: AVG(minimum_deposit_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_earned_premium_schedule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Earned Premium Schedule business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule`"
  dimensions:
    - name: "Adjustment Reason Code"
      expr: adjustment_reason_code
    - name: "Cancellation Date"
      expr: cancellation_date
    - name: "Cancellation Reason Code"
      expr: cancellation_reason_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Earning Method"
      expr: earning_method
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Ifrs17 Cohort Code"
      expr: ifrs17_cohort_code
    - name: "Is Minimum Earned"
      expr: is_minimum_earned
    - name: "Is Prorated"
      expr: is_prorated
    - name: "Is Short Rate"
      expr: is_short_rate
    - name: "Last Updated Timestamp"
      expr: last_updated_timestamp
    - name: "Notes"
      expr: notes
    - name: "Reporting Basis"
      expr: reporting_basis
    - name: "Schedule Date"
      expr: schedule_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Earned Premium Schedule"
      expr: COUNT(DISTINCT earned_premium_schedule_id)
    - name: "Total Cumulative Earned Amount"
      expr: SUM(cumulative_earned_amount)
    - name: "Average Cumulative Earned Amount"
      expr: AVG(cumulative_earned_amount)
    - name: "Total Daily Earned Amount"
      expr: SUM(daily_earned_amount)
    - name: "Average Daily Earned Amount"
      expr: AVG(daily_earned_amount)
    - name: "Total Days Elapsed"
      expr: SUM(days_elapsed)
    - name: "Average Days Elapsed"
      expr: AVG(days_elapsed)
    - name: "Total Days In Period"
      expr: SUM(days_in_period)
    - name: "Average Days In Period"
      expr: AVG(days_in_period)
    - name: "Total Days Remaining"
      expr: SUM(days_remaining)
    - name: "Average Days Remaining"
      expr: AVG(days_remaining)
    - name: "Total Earned Premium Amount"
      expr: SUM(earned_premium_amount)
    - name: "Average Earned Premium Amount"
      expr: AVG(earned_premium_amount)
    - name: "Total Earning Percentage"
      expr: SUM(earning_percentage)
    - name: "Average Earning Percentage"
      expr: AVG(earning_percentage)
    - name: "Total Minimum Earned Amount"
      expr: SUM(minimum_earned_amount)
    - name: "Average Minimum Earned Amount"
      expr: AVG(minimum_earned_amount)
    - name: "Total Proration Factor"
      expr: SUM(proration_factor)
    - name: "Average Proration Factor"
      expr: AVG(proration_factor)
    - name: "Total Short Rate Penalty Amount"
      expr: SUM(short_rate_penalty_amount)
    - name: "Average Short Rate Penalty Amount"
      expr: AVG(short_rate_penalty_amount)
    - name: "Total Short Rate Percentage"
      expr: SUM(short_rate_percentage)
    - name: "Average Short Rate Percentage"
      expr: AVG(short_rate_percentage)
    - name: "Total Total Premium Amount"
      expr: SUM(total_premium_amount)
    - name: "Average Total Premium Amount"
      expr: AVG(total_premium_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_minimum_earned_premium`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Minimum Earned Premium business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium`"
  dimensions:
    - name: "Application Level"
      expr: application_level
    - name: "Applies To Endorsement Flag"
      expr: applies_to_endorsement_flag
    - name: "Applies To New Business Flag"
      expr: applies_to_new_business_flag
    - name: "Applies To Renewal Flag"
      expr: applies_to_renewal_flag
    - name: "Calculation Method"
      expr: calculation_method
    - name: "Cancellation Type"
      expr: cancellation_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Filing Approval Date"
      expr: filing_approval_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Lob Code"
      expr: lob_code
    - name: "Minimum Earned Premium Status"
      expr: minimum_earned_premium_status
    - name: "Notes"
      expr: notes
    - name: "Override Allowed Flag"
      expr: override_allowed_flag
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Minimum Earned Premium"
      expr: COUNT(DISTINCT minimum_earned_premium_id)
    - name: "Total Minimum Amount"
      expr: SUM(minimum_amount)
    - name: "Average Minimum Amount"
      expr: AVG(minimum_amount)
    - name: "Total Minimum Days In Force"
      expr: SUM(minimum_days_in_force)
    - name: "Average Minimum Days In Force"
      expr: AVG(minimum_days_in_force)
    - name: "Total Percentage Of Written Premium"
      expr: SUM(percentage_of_written_premium)
    - name: "Average Percentage Of Written Premium"
      expr: AVG(percentage_of_written_premium)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_policy_fee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy Fee business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`policy_fee`"
  dimensions:
    - name: "Billing Method"
      expr: billing_method
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Fee Basis"
      expr: fee_basis
    - name: "Fee Code"
      expr: fee_code
    - name: "Fee Description"
      expr: fee_description
    - name: "Fee Status"
      expr: fee_status
    - name: "Fee Type"
      expr: fee_type
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Is Commission Bearing"
      expr: is_commission_bearing
    - name: "Is Refundable"
      expr: is_refundable
    - name: "Is Taxable"
      expr: is_taxable
    - name: "Jurisdiction Code"
      expr: jurisdiction_code
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Lob Code"
      expr: lob_code
    - name: "Notes"
      expr: notes
    - name: "Reversal Date"
      expr: reversal_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Policy Fee"
      expr: COUNT(DISTINCT policy_fee_id)
    - name: "Total Fee Amount"
      expr: SUM(fee_amount)
    - name: "Average Fee Amount"
      expr: AVG(fee_amount)
    - name: "Total Fee Quantity"
      expr: SUM(fee_quantity)
    - name: "Average Fee Quantity"
      expr: AVG(fee_quantity)
    - name: "Total Fee Rate"
      expr: SUM(fee_rate)
    - name: "Average Fee Rate"
      expr: AVG(fee_rate)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_premium_accounting_period`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Premium Accounting Period business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period`"
  dimensions:
    - name: "Actuarial Reserve Cutoff Date"
      expr: actuarial_reserve_cutoff_date
    - name: "Bordereaux Due Date"
      expr: bordereaux_due_date
    - name: "Close Date"
      expr: close_date
    - name: "Currency Code"
      expr: currency_code
    - name: "Earned Premium Basis"
      expr: earned_premium_basis
    - name: "End Date"
      expr: end_date
    - name: "Filing Status"
      expr: filing_status
    - name: "Gl Period Code"
      expr: gl_period_code
    - name: "Is Current Period"
      expr: is_current_period
    - name: "Is Ifrs17 Reporting Period"
      expr: is_ifrs17_reporting_period
    - name: "Is Statutory Filing Period"
      expr: is_statutory_filing_period
    - name: "Lock Date"
      expr: lock_date
    - name: "Notes"
      expr: notes
    - name: "Period Code"
      expr: period_code
    - name: "Period Name"
      expr: period_name
    - name: "Period Status"
      expr: period_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Premium Accounting Period"
      expr: COUNT(DISTINCT premium_accounting_period_id)
    - name: "Total Accident Year Ay"
      expr: SUM(accident_year_ay)
    - name: "Average Accident Year Ay"
      expr: AVG(accident_year_ay)
    - name: "Total Calendar Year Cy"
      expr: SUM(calendar_year_cy)
    - name: "Average Calendar Year Cy"
      expr: AVG(calendar_year_cy)
    - name: "Total Days In Period"
      expr: SUM(days_in_period)
    - name: "Average Days In Period"
      expr: AVG(days_in_period)
    - name: "Total Fiscal Month"
      expr: SUM(fiscal_month)
    - name: "Average Fiscal Month"
      expr: AVG(fiscal_month)
    - name: "Total Fiscal Quarter"
      expr: SUM(fiscal_quarter)
    - name: "Average Fiscal Quarter"
      expr: AVG(fiscal_quarter)
    - name: "Total Fiscal Year"
      expr: SUM(fiscal_year)
    - name: "Average Fiscal Year"
      expr: AVG(fiscal_year)
    - name: "Total Policy Year Py"
      expr: SUM(policy_year_py)
    - name: "Average Policy Year Py"
      expr: AVG(policy_year_py)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_premium_endorsement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Premium Endorsement business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement`"
  dimensions:
    - name: "Billing Status"
      expr: billing_status
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Is Billable"
      expr: is_billable
    - name: "Notes"
      expr: notes
    - name: "Proration Method"
      expr: proration_method
    - name: "Reversal Indicator"
      expr: reversal_indicator
    - name: "Reversal Reason Code"
      expr: reversal_reason_code
    - name: "Reversal Reason Description"
      expr: reversal_reason_description
    - name: "Source System Code"
      expr: source_system_code
    - name: "Source System Transaction Code"
      expr: source_system_transaction_code
    - name: "Statutory Line Code"
      expr: statutory_line_code
    - name: "Transaction Effective Date"
      expr: transaction_effective_date
    - name: "Transaction Reason Code"
      expr: transaction_reason_code
    - name: "Transaction Reason Description"
      expr: transaction_reason_description
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Premium Endorsement"
      expr: COUNT(DISTINCT premium_endorsement_id)
    - name: "Total Ceded Premium Change Amount"
      expr: SUM(ceded_premium_change_amount)
    - name: "Average Ceded Premium Change Amount"
      expr: AVG(ceded_premium_change_amount)
    - name: "Total Commission Change Amount"
      expr: SUM(commission_change_amount)
    - name: "Average Commission Change Amount"
      expr: AVG(commission_change_amount)
    - name: "Total Days In Term Remaining"
      expr: SUM(days_in_term_remaining)
    - name: "Average Days In Term Remaining"
      expr: AVG(days_in_term_remaining)
    - name: "Total Earned Premium Change Amount"
      expr: SUM(earned_premium_change_amount)
    - name: "Average Earned Premium Change Amount"
      expr: AVG(earned_premium_change_amount)
    - name: "Total Fee Change Amount"
      expr: SUM(fee_change_amount)
    - name: "Average Fee Change Amount"
      expr: AVG(fee_change_amount)
    - name: "Total Gross Premium Change Amount"
      expr: SUM(gross_premium_change_amount)
    - name: "Average Gross Premium Change Amount"
      expr: AVG(gross_premium_change_amount)
    - name: "Total Net Premium Change Amount"
      expr: SUM(net_premium_change_amount)
    - name: "Average Net Premium Change Amount"
      expr: AVG(net_premium_change_amount)
    - name: "Total Proration Factor"
      expr: SUM(proration_factor)
    - name: "Average Proration Factor"
      expr: AVG(proration_factor)
    - name: "Total Tax Change Amount"
      expr: SUM(tax_change_amount)
    - name: "Average Tax Change Amount"
      expr: AVG(tax_change_amount)
    - name: "Total Total Charge Change Amount"
      expr: SUM(total_charge_change_amount)
    - name: "Average Total Charge Change Amount"
      expr: AVG(total_charge_change_amount)
    - name: "Total Unearned Premium Change Amount"
      expr: SUM(unearned_premium_change_amount)
    - name: "Average Unearned Premium Change Amount"
      expr: AVG(unearned_premium_change_amount)
    - name: "Total Written Premium Change Amount"
      expr: SUM(written_premium_change_amount)
    - name: "Average Written Premium Change Amount"
      expr: AVG(written_premium_change_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_premium_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Premium Transaction business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`"
  dimensions:
    - name: "Audit Basis"
      expr: audit_basis
    - name: "Cost Center Code"
      expr: cost_center_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Direct Billed Indicator"
      expr: direct_billed_indicator
    - name: "Earning Method"
      expr: earning_method
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Type"
      expr: endorsement_type
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Notes"
      expr: notes
    - name: "Payment Plan Code"
      expr: payment_plan_code
    - name: "Posted Timestamp"
      expr: posted_timestamp
    - name: "Rate Effective Date"
      expr: rate_effective_date
    - name: "Reversal Indicator"
      expr: reversal_indicator
    - name: "Source System Code"
      expr: source_system_code
    - name: "State Code"
      expr: state_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Premium Transaction"
      expr: COUNT(DISTINCT premium_transaction_id)
    - name: "Total Ceded Written Premium"
      expr: SUM(ceded_written_premium)
    - name: "Average Ceded Written Premium"
      expr: AVG(ceded_written_premium)
    - name: "Total Days In Force"
      expr: SUM(days_in_force)
    - name: "Average Days In Force"
      expr: AVG(days_in_force)
    - name: "Total Earned Premium"
      expr: SUM(earned_premium)
    - name: "Average Earned Premium"
      expr: AVG(earned_premium)
    - name: "Total Exposure Amount"
      expr: SUM(exposure_amount)
    - name: "Average Exposure Amount"
      expr: AVG(exposure_amount)
    - name: "Total Gross Written Premium"
      expr: SUM(gross_written_premium)
    - name: "Average Gross Written Premium"
      expr: AVG(gross_written_premium)
    - name: "Total Net Written Premium"
      expr: SUM(net_written_premium)
    - name: "Average Net Written Premium"
      expr: AVG(net_written_premium)
    - name: "Total Pro Rata Factor"
      expr: SUM(pro_rata_factor)
    - name: "Average Pro Rata Factor"
      expr: AVG(pro_rata_factor)
    - name: "Total Rate"
      expr: SUM(rate)
    - name: "Average Rate"
      expr: AVG(rate)
    - name: "Total Return Premium"
      expr: SUM(return_premium)
    - name: "Average Return Premium"
      expr: AVG(return_premium)
    - name: "Total Unearned Premium"
      expr: SUM(unearned_premium)
    - name: "Average Unearned Premium"
      expr: AVG(unearned_premium)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_rate_table`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`rate_table`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_rate_table_authorization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rate Table Authorization business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization`"
  dimensions:
    - name: "Authorization Status"
      expr: authorization_status
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Override Allowed Flag"
      expr: override_allowed_flag
    - name: "Effective Date Month"
      expr: DATE_TRUNC('MONTH', effective_date)
    - name: "Expiration Date Month"
      expr: DATE_TRUNC('MONTH', expiration_date)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Rate Table Authorization"
      expr: COUNT(DISTINCT rate_table_authorization_id)
    - name: "Total Deviation Percentage Limit"
      expr: SUM(deviation_percentage_limit)
    - name: "Average Deviation Percentage Limit"
      expr: AVG(deviation_percentage_limit)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_retrospective_adjustment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Retrospective Adjustment business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment`"
  dimensions:
    - name: "Adjustment Effective Date"
      expr: adjustment_effective_date
    - name: "Adjustment Number"
      expr: adjustment_number
    - name: "Adjustment Status"
      expr: adjustment_status
    - name: "Adjustment Type"
      expr: adjustment_type
    - name: "Approved By User Code"
      expr: approved_by_user_code
    - name: "Approved Timestamp"
      expr: approved_timestamp
    - name: "Calculation Method Code"
      expr: calculation_method_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Evaluation Date"
      expr: evaluation_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Is Maximum Applied"
      expr: is_maximum_applied
    - name: "Is Minimum Applied"
      expr: is_minimum_applied
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Lob Code"
      expr: lob_code
    - name: "Loss Limitation Type"
      expr: loss_limitation_type
    - name: "Notes"
      expr: notes
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Retrospective Adjustment"
      expr: COUNT(DISTINCT retrospective_adjustment_id)
    - name: "Total Adjustment Sequence"
      expr: SUM(adjustment_sequence)
    - name: "Average Adjustment Sequence"
      expr: AVG(adjustment_sequence)
    - name: "Total Adjustment Variance Amount"
      expr: SUM(adjustment_variance_amount)
    - name: "Average Adjustment Variance Amount"
      expr: AVG(adjustment_variance_amount)
    - name: "Total Basic Premium Amount"
      expr: SUM(basic_premium_amount)
    - name: "Average Basic Premium Amount"
      expr: AVG(basic_premium_amount)
    - name: "Total Calculated Retro Premium Amount"
      expr: SUM(calculated_retro_premium_amount)
    - name: "Average Calculated Retro Premium Amount"
      expr: AVG(calculated_retro_premium_amount)
    - name: "Total Converted Losses Amount"
      expr: SUM(converted_losses_amount)
    - name: "Average Converted Losses Amount"
      expr: AVG(converted_losses_amount)
    - name: "Total Final Retro Premium Amount"
      expr: SUM(final_retro_premium_amount)
    - name: "Average Final Retro Premium Amount"
      expr: AVG(final_retro_premium_amount)
    - name: "Total Incurred Losses Amount"
      expr: SUM(incurred_losses_amount)
    - name: "Average Incurred Losses Amount"
      expr: AVG(incurred_losses_amount)
    - name: "Total Loss Conversion Factor"
      expr: SUM(loss_conversion_factor)
    - name: "Average Loss Conversion Factor"
      expr: AVG(loss_conversion_factor)
    - name: "Total Loss Limitation Amount"
      expr: SUM(loss_limitation_amount)
    - name: "Average Loss Limitation Amount"
      expr: AVG(loss_limitation_amount)
    - name: "Total Maximum Premium Amount"
      expr: SUM(maximum_premium_amount)
    - name: "Average Maximum Premium Amount"
      expr: AVG(maximum_premium_amount)
    - name: "Total Minimum Premium Amount"
      expr: SUM(minimum_premium_amount)
    - name: "Average Minimum Premium Amount"
      expr: AVG(minimum_premium_amount)
    - name: "Total Prior Retro Premium Amount"
      expr: SUM(prior_retro_premium_amount)
    - name: "Average Prior Retro Premium Amount"
      expr: AVG(prior_retro_premium_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_rule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rule business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`rule`"
  dimensions:
    - name: "Applies To Cancellation"
      expr: applies_to_cancellation
    - name: "Applies To Endorsement"
      expr: applies_to_endorsement
    - name: "Applies To New Business"
      expr: applies_to_new_business
    - name: "Applies To Reinstatement"
      expr: applies_to_reinstatement
    - name: "Applies To Renewal"
      expr: applies_to_renewal
    - name: "Approval Date"
      expr: approval_date
    - name: "Approved By"
      expr: approved_by
    - name: "Calculation Method"
      expr: calculation_method
    - name: "Category"
      expr: rule_category
    - name: "Condition Expression"
      expr: condition_expression
    - name: "Coverage Type Code"
      expr: coverage_type_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Description"
      expr: rule_description
    - name: "Effective Date"
      expr: effective_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Rule"
      expr: COUNT(DISTINCT rule_id)
    - name: "Total Minimum Earned Percentage"
      expr: SUM(minimum_earned_percentage)
    - name: "Average Minimum Earned Percentage"
      expr: AVG(minimum_earned_percentage)
    - name: "Total Percentage Rate"
      expr: SUM(percentage_rate)
    - name: "Average Percentage Rate"
      expr: AVG(percentage_rate)
    - name: "Total Priority Sequence"
      expr: SUM(priority_sequence)
    - name: "Average Priority Sequence"
      expr: AVG(priority_sequence)
    - name: "Total Short Rate Penalty Percentage"
      expr: SUM(short_rate_penalty_percentage)
    - name: "Average Short Rate Penalty Percentage"
      expr: AVG(short_rate_penalty_percentage)
    - name: "Total Threshold Amount"
      expr: SUM(threshold_amount)
    - name: "Average Threshold Amount"
      expr: AVG(threshold_amount)
    - name: "Total Version Number"
      expr: SUM(version_number)
    - name: "Average Version Number"
      expr: AVG(version_number)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_tax_levy`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tax Levy business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`tax_levy`"
  dimensions:
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Description"
      expr: tax_levy_description
    - name: "Naic Company Code"
      expr: naic_company_code
    - name: "Policy Transaction Type Code"
      expr: policy_transaction_type_code
    - name: "Source System Code"
      expr: source_system_code
    - name: "Stamping Office Code"
      expr: stamping_office_code
    - name: "Surplus Lines Flag"
      expr: surplus_lines_flag
    - name: "Tax Adjustment Flag"
      expr: tax_adjustment_flag
    - name: "Tax Authority Name"
      expr: tax_authority_name
    - name: "Tax Calculation Method Code"
      expr: tax_calculation_method_code
    - name: "Tax Effective Date"
      expr: tax_effective_date
    - name: "Tax Exemption Flag"
      expr: tax_exemption_flag
    - name: "Tax Exemption Reason Code"
      expr: tax_exemption_reason_code
    - name: "Tax Remittance Batch Code"
      expr: tax_remittance_batch_code
    - name: "Tax Remittance Date"
      expr: tax_remittance_date
    - name: "Tax Remittance Due Date"
      expr: tax_remittance_due_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Tax Levy"
      expr: COUNT(DISTINCT tax_levy_id)
    - name: "Total Amount"
      expr: SUM(amount)
    - name: "Average Amount"
      expr: AVG(amount)
    - name: "Total Tax Rate"
      expr: SUM(tax_rate)
    - name: "Average Tax Rate"
      expr: AVG(tax_rate)
    - name: "Total Taxable Premium Amount"
      expr: SUM(taxable_premium_amount)
    - name: "Average Taxable Premium Amount"
      expr: AVG(taxable_premium_amount)
$$;