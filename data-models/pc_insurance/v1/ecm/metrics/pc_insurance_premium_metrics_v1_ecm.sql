-- Metric views for domain: premium | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_agency_bill_statement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Agency Bill Statement business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`agency_bill_statement`"
  dimensions:
    - name: "Billing Method"
      expr: billing_method
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Due Date"
      expr: due_date
    - name: "Issued By User Code"
      expr: issued_by_user_code
    - name: "Lob Summary"
      expr: lob_summary
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Naic Company Code"
      expr: naic_company_code
    - name: "Notes"
      expr: notes
    - name: "Producer Contact Email"
      expr: producer_contact_email
    - name: "Producer Contact Name"
      expr: producer_contact_name
    - name: "Producer Contact Phone"
      expr: producer_contact_phone
    - name: "Reconciliation Status"
      expr: reconciliation_status
    - name: "Statement Date"
      expr: statement_date
    - name: "Statement Delivery Method"
      expr: statement_delivery_method
    - name: "Statement Format"
      expr: statement_format
    - name: "Statement Number"
      expr: statement_number
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Agency Bill Statement"
      expr: COUNT(DISTINCT agency_bill_statement_id)
    - name: "Total Adjustment Amount"
      expr: SUM(adjustment_amount)
    - name: "Average Adjustment Amount"
      expr: AVG(adjustment_amount)
    - name: "Total Balance Forward Amount"
      expr: SUM(balance_forward_amount)
    - name: "Average Balance Forward Amount"
      expr: AVG(balance_forward_amount)
    - name: "Total Cancellation Count"
      expr: SUM(cancellation_count)
    - name: "Average Cancellation Count"
      expr: AVG(cancellation_count)
    - name: "Total Commission Amount"
      expr: SUM(commission_amount)
    - name: "Average Commission Amount"
      expr: AVG(commission_amount)
    - name: "Total Commission Rate Percent"
      expr: SUM(commission_rate_percent)
    - name: "Average Commission Rate Percent"
      expr: AVG(commission_rate_percent)
    - name: "Total Current Balance Amount"
      expr: SUM(current_balance_amount)
    - name: "Average Current Balance Amount"
      expr: AVG(current_balance_amount)
    - name: "Total Delinquency Days"
      expr: SUM(delinquency_days)
    - name: "Average Delinquency Days"
      expr: AVG(delinquency_days)
    - name: "Total Endorsement Count"
      expr: SUM(endorsement_count)
    - name: "Average Endorsement Count"
      expr: AVG(endorsement_count)
    - name: "Total Fees Amount"
      expr: SUM(fees_amount)
    - name: "Average Fees Amount"
      expr: AVG(fees_amount)
    - name: "Total Gwp Amount"
      expr: SUM(gwp_amount)
    - name: "Average Gwp Amount"
      expr: AVG(gwp_amount)
    - name: "Total Net Amount Due"
      expr: SUM(net_amount_due)
    - name: "Average Net Amount Due"
      expr: AVG(net_amount_due)
    - name: "Total New Business Count"
      expr: SUM(new_business_count)
    - name: "Average New Business Count"
      expr: AVG(new_business_count)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_billing_account`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Billing Account business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`billing_account`"
  dimensions:
    - name: "Account Name"
      expr: account_name
    - name: "Account Number"
      expr: account_number
    - name: "Account Status"
      expr: account_status
    - name: "Account Type"
      expr: account_type
    - name: "Autopay Flag"
      expr: autopay_flag
    - name: "Billing Address Line1"
      expr: billing_address_line1
    - name: "Billing Address Line2"
      expr: billing_address_line2
    - name: "Billing City"
      expr: billing_city
    - name: "Billing Contact Email"
      expr: billing_contact_email
    - name: "Billing Contact Phone"
      expr: billing_contact_phone
    - name: "Billing Method"
      expr: billing_method
    - name: "Billing Postal Code"
      expr: billing_postal_code
    - name: "Cancellation Date"
      expr: cancellation_date
    - name: "Cancellation Reason Code"
      expr: cancellation_reason_code
    - name: "Created By User"
      expr: created_by_user
    - name: "Created Timestamp"
      expr: created_timestamp
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Billing Account"
      expr: COUNT(DISTINCT billing_account_id)
    - name: "Total Commission Rate Percent"
      expr: SUM(commission_rate_percent)
    - name: "Average Commission Rate Percent"
      expr: AVG(commission_rate_percent)
    - name: "Total Current Balance Amount"
      expr: SUM(current_balance_amount)
    - name: "Average Current Balance Amount"
      expr: AVG(current_balance_amount)
    - name: "Total Delinquency Days"
      expr: SUM(delinquency_days)
    - name: "Average Delinquency Days"
      expr: AVG(delinquency_days)
    - name: "Total Grace Period Days"
      expr: SUM(grace_period_days)
    - name: "Average Grace Period Days"
      expr: AVG(grace_period_days)
    - name: "Total Last Payment Amount"
      expr: SUM(last_payment_amount)
    - name: "Average Last Payment Amount"
      expr: AVG(last_payment_amount)
    - name: "Total Next Due Amount"
      expr: SUM(next_due_amount)
    - name: "Average Next Due Amount"
      expr: AVG(next_due_amount)
    - name: "Total Past Due Amount"
      expr: SUM(past_due_amount)
    - name: "Average Past Due Amount"
      expr: AVG(past_due_amount)
    - name: "Total Total Billed Amount"
      expr: SUM(total_billed_amount)
    - name: "Average Total Billed Amount"
      expr: AVG(total_billed_amount)
    - name: "Total Total Paid Amount"
      expr: SUM(total_paid_amount)
    - name: "Average Total Paid Amount"
      expr: AVG(total_paid_amount)
    - name: "Total Unapplied Payment Amount"
      expr: SUM(unapplied_payment_amount)
    - name: "Average Unapplied Payment Amount"
      expr: AVG(unapplied_payment_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_dac_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Dac Transaction business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`dac_transaction`"
  dimensions:
    - name: "Accounting Standard"
      expr: accounting_standard
    - name: "Amortization Method"
      expr: amortization_method
    - name: "Approval Date"
      expr: approval_date
    - name: "Approved By User Code"
      expr: approved_by_user_code
    - name: "Cost Center Code"
      expr: cost_center_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Notes"
      expr: notes
    - name: "Policy Effective Date"
      expr: policy_effective_date
    - name: "Policy Expiration Date"
      expr: policy_expiration_date
    - name: "Posted By User Code"
      expr: posted_by_user_code
    - name: "Product Code"
      expr: product_code
    - name: "Recoverability Test Date"
      expr: recoverability_test_date
    - name: "Recoverability Test Result"
      expr: recoverability_test_result
    - name: "Reversal Reason"
      expr: reversal_reason
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Dac Transaction"
      expr: COUNT(DISTINCT dac_transaction_id)
    - name: "Total Adjustment Amount"
      expr: SUM(adjustment_amount)
    - name: "Average Adjustment Amount"
      expr: AVG(adjustment_amount)
    - name: "Total Amortization Amount"
      expr: SUM(amortization_amount)
    - name: "Average Amortization Amount"
      expr: AVG(amortization_amount)
    - name: "Total Amortization Period Months"
      expr: SUM(amortization_period_months)
    - name: "Average Amortization Period Months"
      expr: AVG(amortization_period_months)
    - name: "Total Capitalized Amount"
      expr: SUM(capitalized_amount)
    - name: "Average Capitalized Amount"
      expr: AVG(capitalized_amount)
    - name: "Total Commission Amount"
      expr: SUM(commission_amount)
    - name: "Average Commission Amount"
      expr: AVG(commission_amount)
    - name: "Total Dac Balance"
      expr: SUM(dac_balance)
    - name: "Average Dac Balance"
      expr: AVG(dac_balance)
    - name: "Total Earned Premium Amount"
      expr: SUM(earned_premium_amount)
    - name: "Average Earned Premium Amount"
      expr: AVG(earned_premium_amount)
    - name: "Total Impairment Amount"
      expr: SUM(impairment_amount)
    - name: "Average Impairment Amount"
      expr: AVG(impairment_amount)
    - name: "Total Other Acquisition Cost Amount"
      expr: SUM(other_acquisition_cost_amount)
    - name: "Average Other Acquisition Cost Amount"
      expr: AVG(other_acquisition_cost_amount)
    - name: "Total Underwriting Expense Amount"
      expr: SUM(underwriting_expense_amount)
    - name: "Average Underwriting Expense Amount"
      expr: AVG(underwriting_expense_amount)
    - name: "Total Write Off Amount"
      expr: SUM(write_off_amount)
    - name: "Average Write Off Amount"
      expr: AVG(write_off_amount)
    - name: "Total Written Premium Amount"
      expr: SUM(written_premium_amount)
    - name: "Average Written Premium Amount"
      expr: AVG(written_premium_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_earned_premium`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Earned Premium business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`earned_premium`"
  dimensions:
    - name: "Adjustment Description"
      expr: adjustment_description
    - name: "Adjustment Reason Code"
      expr: adjustment_reason_code
    - name: "Calculation Timestamp"
      expr: calculation_timestamp
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Earned Premium Status"
      expr: earned_premium_status
    - name: "Earning Method"
      expr: earning_method
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Naic Company Code"
      expr: naic_company_code
    - name: "Posting Date"
      expr: posting_date
    - name: "Reversal Flag"
      expr: reversal_flag
    - name: "Statutory Line Code"
      expr: statutory_line_code
    - name: "Transaction Type"
      expr: transaction_type
    - name: "Updated Timestamp"
      expr: updated_timestamp
    - name: "Calculation Timestamp Month"
      expr: DATE_TRUNC('MONTH', calculation_timestamp)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Earned Premium"
      expr: COUNT(DISTINCT earned_premium_id)
    - name: "Total Ceded Ep Amount"
      expr: SUM(ceded_ep_amount)
    - name: "Average Ceded Ep Amount"
      expr: AVG(ceded_ep_amount)
    - name: "Total Commission Amount"
      expr: SUM(commission_amount)
    - name: "Average Commission Amount"
      expr: AVG(commission_amount)
    - name: "Total Commission Rate"
      expr: SUM(commission_rate)
    - name: "Average Commission Rate"
      expr: AVG(commission_rate)
    - name: "Total Dac Amount"
      expr: SUM(dac_amount)
    - name: "Average Dac Amount"
      expr: AVG(dac_amount)
    - name: "Total Earning Percentage"
      expr: SUM(earning_percentage)
    - name: "Average Earning Percentage"
      expr: AVG(earning_percentage)
    - name: "Total Ep Amount"
      expr: SUM(ep_amount)
    - name: "Average Ep Amount"
      expr: AVG(ep_amount)
    - name: "Total Exchange Rate"
      expr: SUM(exchange_rate)
    - name: "Average Exchange Rate"
      expr: AVG(exchange_rate)
    - name: "Total Exposure Days"
      expr: SUM(exposure_days)
    - name: "Average Exposure Days"
      expr: AVG(exposure_days)
    - name: "Total Gaap Revenue Amount"
      expr: SUM(gaap_revenue_amount)
    - name: "Average Gaap Revenue Amount"
      expr: AVG(gaap_revenue_amount)
    - name: "Total Gwp Amount"
      expr: SUM(gwp_amount)
    - name: "Average Gwp Amount"
      expr: AVG(gwp_amount)
    - name: "Total Ifrs17 Revenue Amount"
      expr: SUM(ifrs17_revenue_amount)
    - name: "Average Ifrs17 Revenue Amount"
      expr: AVG(ifrs17_revenue_amount)
    - name: "Total Net Ep Amount"
      expr: SUM(net_ep_amount)
    - name: "Average Net Ep Amount"
      expr: AVG(net_ep_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_finance_agreement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Finance Agreement business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`finance_agreement`"
  dimensions:
    - name: "Agreement Number"
      expr: agreement_number
    - name: "Agreement Signed Date"
      expr: agreement_signed_date
    - name: "Agreement Status"
      expr: agreement_status
    - name: "Agreement Type"
      expr: agreement_type
    - name: "Cancellation Date"
      expr: cancellation_date
    - name: "Cancellation Reason Code"
      expr: cancellation_reason_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Default Date"
      expr: default_date
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Final Installment Due Date"
      expr: final_installment_due_date
    - name: "First Installment Due Date"
      expr: first_installment_due_date
    - name: "Installment Frequency"
      expr: installment_frequency
    - name: "Last Payment Date"
      expr: last_payment_date
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Next Payment Due Date"
      expr: next_payment_due_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Finance Agreement"
      expr: COUNT(DISTINCT finance_agreement_id)
    - name: "Total Annual Percentage Rate"
      expr: SUM(annual_percentage_rate)
    - name: "Average Annual Percentage Rate"
      expr: AVG(annual_percentage_rate)
    - name: "Total Cancellation Notice Days"
      expr: SUM(cancellation_notice_days)
    - name: "Average Cancellation Notice Days"
      expr: AVG(cancellation_notice_days)
    - name: "Total Delinquency Days"
      expr: SUM(delinquency_days)
    - name: "Average Delinquency Days"
      expr: AVG(delinquency_days)
    - name: "Total Down Payment Amount"
      expr: SUM(down_payment_amount)
    - name: "Average Down Payment Amount"
      expr: AVG(down_payment_amount)
    - name: "Total Finance Company Party Code"
      expr: SUM(finance_company_party_code)
    - name: "Average Finance Company Party Code"
      expr: AVG(finance_company_party_code)
    - name: "Total Financed Premium Amount"
      expr: SUM(financed_premium_amount)
    - name: "Average Financed Premium Amount"
      expr: AVG(financed_premium_amount)
    - name: "Total Grace Period Days"
      expr: SUM(grace_period_days)
    - name: "Average Grace Period Days"
      expr: AVG(grace_period_days)
    - name: "Total Installment Amount"
      expr: SUM(installment_amount)
    - name: "Average Installment Amount"
      expr: AVG(installment_amount)
    - name: "Total Interest Rate Percent"
      expr: SUM(interest_rate_percent)
    - name: "Average Interest Rate Percent"
      expr: AVG(interest_rate_percent)
    - name: "Total Last Payment Amount"
      expr: SUM(last_payment_amount)
    - name: "Average Last Payment Amount"
      expr: AVG(last_payment_amount)
    - name: "Total Late Fee Amount"
      expr: SUM(late_fee_amount)
    - name: "Average Late Fee Amount"
      expr: AVG(late_fee_amount)
    - name: "Total Next Payment Due Amount"
      expr: SUM(next_payment_due_amount)
    - name: "Average Next Payment Due Amount"
      expr: AVG(next_payment_due_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_installment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Installment business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`installment`"
  dimensions:
    - name: "Autopay Flag"
      expr: autopay_flag
    - name: "Billed Date"
      expr: billed_date
    - name: "Billing Notice Sent Flag"
      expr: billing_notice_sent_flag
    - name: "Cancellation Effective Date"
      expr: cancellation_effective_date
    - name: "Cancellation Notice Date"
      expr: cancellation_notice_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Delinquency Status"
      expr: delinquency_status
    - name: "Due Date"
      expr: due_date
    - name: "Grace Period End Date"
      expr: grace_period_end_date
    - name: "Installment Status"
      expr: installment_status
    - name: "Invoice Number"
      expr: invoice_number
    - name: "Late Notice Sent Flag"
      expr: late_notice_sent_flag
    - name: "Paid Date"
      expr: paid_date
    - name: "Payment Channel"
      expr: payment_channel
    - name: "Payment Method"
      expr: payment_method
    - name: "Payment Reference Number"
      expr: payment_reference_number
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Installment"
      expr: COUNT(DISTINCT installment_id)
    - name: "Total Billed Amount"
      expr: SUM(billed_amount)
    - name: "Average Billed Amount"
      expr: AVG(billed_amount)
    - name: "Total Days Overdue"
      expr: SUM(days_overdue)
    - name: "Average Days Overdue"
      expr: AVG(days_overdue)
    - name: "Total Fee Amount"
      expr: SUM(fee_amount)
    - name: "Average Fee Amount"
      expr: AVG(fee_amount)
    - name: "Total Grace Period Days"
      expr: SUM(grace_period_days)
    - name: "Average Grace Period Days"
      expr: AVG(grace_period_days)
    - name: "Total Late Fee Amount"
      expr: SUM(late_fee_amount)
    - name: "Average Late Fee Amount"
      expr: AVG(late_fee_amount)
    - name: "Total Number"
      expr: SUM(number)
    - name: "Average Number"
      expr: AVG(number)
    - name: "Total Outstanding Balance"
      expr: SUM(outstanding_balance)
    - name: "Average Outstanding Balance"
      expr: AVG(outstanding_balance)
    - name: "Total Paid Amount"
      expr: SUM(paid_amount)
    - name: "Average Paid Amount"
      expr: AVG(paid_amount)
    - name: "Total Premium Amount"
      expr: SUM(premium_amount)
    - name: "Average Premium Amount"
      expr: AVG(premium_amount)
    - name: "Total Tax Amount"
      expr: SUM(tax_amount)
    - name: "Average Tax Amount"
      expr: AVG(tax_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_installment_schedule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Installment Schedule business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`installment_schedule`"
  dimensions:
    - name: "Autopay Enrolled Flag"
      expr: autopay_enrolled_flag
    - name: "Billing Method"
      expr: billing_method
    - name: "Cancellation Reason Code"
      expr: cancellation_reason_code
    - name: "Cancelled Timestamp"
      expr: cancelled_timestamp
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Down Payment Due Date"
      expr: down_payment_due_date
    - name: "Eligibility Criteria"
      expr: eligibility_criteria
    - name: "First Installment Due Date"
      expr: first_installment_due_date
    - name: "Installment Frequency"
      expr: installment_frequency
    - name: "Notes"
      expr: notes
    - name: "Paperless Billing Flag"
      expr: paperless_billing_flag
    - name: "Payment Method Preference"
      expr: payment_method_preference
    - name: "Payment Plan Code"
      expr: payment_plan_code
    - name: "Payment Plan Name"
      expr: payment_plan_name
    - name: "Schedule Effective Date"
      expr: schedule_effective_date
    - name: "Schedule Expiration Date"
      expr: schedule_expiration_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Installment Schedule"
      expr: COUNT(DISTINCT installment_schedule_id)
    - name: "Total Autopay Discount Amount"
      expr: SUM(autopay_discount_amount)
    - name: "Average Autopay Discount Amount"
      expr: AVG(autopay_discount_amount)
    - name: "Total Cancellation For Nonpayment Days"
      expr: SUM(cancellation_for_nonpayment_days)
    - name: "Average Cancellation For Nonpayment Days"
      expr: AVG(cancellation_for_nonpayment_days)
    - name: "Total Down Payment Amount"
      expr: SUM(down_payment_amount)
    - name: "Average Down Payment Amount"
      expr: AVG(down_payment_amount)
    - name: "Total Down Payment Percentage"
      expr: SUM(down_payment_percentage)
    - name: "Average Down Payment Percentage"
      expr: AVG(down_payment_percentage)
    - name: "Total Grace Period Days"
      expr: SUM(grace_period_days)
    - name: "Average Grace Period Days"
      expr: AVG(grace_period_days)
    - name: "Total Installment Count"
      expr: SUM(installment_count)
    - name: "Average Installment Count"
      expr: AVG(installment_count)
    - name: "Total Installment Fee Amount"
      expr: SUM(installment_fee_amount)
    - name: "Average Installment Fee Amount"
      expr: AVG(installment_fee_amount)
    - name: "Total Late Payment Fee Amount"
      expr: SUM(late_payment_fee_amount)
    - name: "Average Late Payment Fee Amount"
      expr: AVG(late_payment_fee_amount)
    - name: "Total Maximum Premium Threshold"
      expr: SUM(maximum_premium_threshold)
    - name: "Average Maximum Premium Threshold"
      expr: AVG(maximum_premium_threshold)
    - name: "Total Minimum Premium Threshold"
      expr: SUM(minimum_premium_threshold)
    - name: "Average Minimum Premium Threshold"
      expr: AVG(minimum_premium_threshold)
    - name: "Total Paperless Discount Amount"
      expr: SUM(paperless_discount_amount)
    - name: "Average Paperless Discount Amount"
      expr: AVG(paperless_discount_amount)
    - name: "Total Reinstatement Fee Amount"
      expr: SUM(reinstatement_fee_amount)
    - name: "Average Reinstatement Fee Amount"
      expr: AVG(reinstatement_fee_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_minimum_earned_premium`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Minimum Earned Premium business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium`"
  dimensions:
    - name: "Applies To Cancellation Type"
      expr: applies_to_cancellation_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Filing Approval Date"
      expr: filing_approval_date
    - name: "Filing Reference Number"
      expr: filing_reference_number
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Mep Calculation Method"
      expr: mep_calculation_method
    - name: "Mep Waiver Reason Code"
      expr: mep_waiver_reason_code
    - name: "Minimum Earned Premium Status"
      expr: minimum_earned_premium_status
    - name: "Modified By User Code"
      expr: modified_by_user_code
    - name: "Notes"
      expr: notes
    - name: "Override Allowed Flag"
      expr: override_allowed_flag
    - name: "Override Authority Level"
      expr: override_authority_level
    - name: "Product Code"
      expr: product_code
    - name: "Regulatory Mandate Flag"
      expr: regulatory_mandate_flag
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Minimum Earned Premium"
      expr: COUNT(DISTINCT minimum_earned_premium_id)
    - name: "Total Mep Amount"
      expr: SUM(mep_amount)
    - name: "Average Mep Amount"
      expr: AVG(mep_amount)
    - name: "Total Mep Percentage"
      expr: SUM(mep_percentage)
    - name: "Average Mep Percentage"
      expr: AVG(mep_percentage)
    - name: "Total Policy Term Months"
      expr: SUM(policy_term_months)
    - name: "Average Policy Term Months"
      expr: AVG(policy_term_months)
    - name: "Total Short Rate Penalty Percentage"
      expr: SUM(short_rate_penalty_percentage)
    - name: "Average Short Rate Penalty Percentage"
      expr: AVG(short_rate_penalty_percentage)
    - name: "Total Version Number"
      expr: SUM(version_number)
    - name: "Average Version Number"
      expr: AVG(version_number)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payment business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`payment`"
  dimensions:
    - name: "Authorization Code"
      expr: authorization_code
    - name: "Bank Name"
      expr: bank_name
    - name: "Bank Routing Number"
      expr: bank_routing_number
    - name: "Channel"
      expr: channel
    - name: "Cleared Date"
      expr: cleared_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deposit Date"
      expr: deposit_date
    - name: "Effective Date"
      expr: effective_date
    - name: "Method"
      expr: method
    - name: "Modified By"
      expr: modified_by
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Notes"
      expr: notes
    - name: "Number"
      expr: number
    - name: "Payer Account Number"
      expr: payer_account_number
    - name: "Payer Name"
      expr: payer_name
    - name: "Payment Date"
      expr: payment_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Payment"
      expr: COUNT(DISTINCT payment_id)
    - name: "Total Amount"
      expr: SUM(amount)
    - name: "Average Amount"
      expr: AVG(amount)
    - name: "Total Applied Amount"
      expr: SUM(applied_amount)
    - name: "Average Applied Amount"
      expr: AVG(applied_amount)
    - name: "Total Convenience Fee Amount"
      expr: SUM(convenience_fee_amount)
    - name: "Average Convenience Fee Amount"
      expr: AVG(convenience_fee_amount)
    - name: "Total Installment Number"
      expr: SUM(installment_number)
    - name: "Average Installment Number"
      expr: AVG(installment_number)
    - name: "Total Processing Fee Amount"
      expr: SUM(processing_fee_amount)
    - name: "Average Processing Fee Amount"
      expr: AVG(processing_fee_amount)
    - name: "Total Unapplied Amount"
      expr: SUM(unapplied_amount)
    - name: "Average Unapplied Amount"
      expr: AVG(unapplied_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_payment_application`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payment Application business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`payment_application`"
  dimensions:
    - name: "Application Date"
      expr: application_date
    - name: "Application Method"
      expr: application_method
    - name: "Application Notes"
      expr: application_notes
    - name: "Application Status"
      expr: application_status
    - name: "Application Timestamp"
      expr: application_timestamp
    - name: "Applied By User Code"
      expr: applied_by_user_code
    - name: "Applied To Fee Flag"
      expr: applied_to_fee_flag
    - name: "Applied To Interest Flag"
      expr: applied_to_interest_flag
    - name: "Applied To Principal Flag"
      expr: applied_to_principal_flag
    - name: "Billing Account Number"
      expr: billing_account_number
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Nsf Reversal Flag"
      expr: nsf_reversal_flag
    - name: "Policy Number"
      expr: policy_number
    - name: "Reversal Date"
      expr: reversal_date
    - name: "Reversal Reason Code"
      expr: reversal_reason_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Payment Application"
      expr: COUNT(DISTINCT payment_application_id)
    - name: "Total Allocation Priority"
      expr: SUM(allocation_priority)
    - name: "Average Allocation Priority"
      expr: AVG(allocation_priority)
    - name: "Total Application Sequence"
      expr: SUM(application_sequence)
    - name: "Average Application Sequence"
      expr: AVG(application_sequence)
    - name: "Total Applied Amount"
      expr: SUM(applied_amount)
    - name: "Average Applied Amount"
      expr: AVG(applied_amount)
    - name: "Total Installment Balance After"
      expr: SUM(installment_balance_after)
    - name: "Average Installment Balance After"
      expr: AVG(installment_balance_after)
    - name: "Total Installment Balance Before"
      expr: SUM(installment_balance_before)
    - name: "Average Installment Balance Before"
      expr: AVG(installment_balance_before)
    - name: "Total Unapplied Amount"
      expr: SUM(unapplied_amount)
    - name: "Average Unapplied Amount"
      expr: AVG(unapplied_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_premium_rate_filing`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Premium Rate Filing business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`premium_rate_filing`"
  dimensions:
    - name: "Actuarial Justification"
      expr: actuarial_justification
    - name: "Actuary Credential"
      expr: actuary_credential
    - name: "Actuary Name"
      expr: actuary_name
    - name: "Approval Date"
      expr: approval_date
    - name: "Certification Date"
      expr: certification_date
    - name: "Competitive Impact Analysis"
      expr: competitive_impact_analysis
    - name: "Consumer Impact Statement"
      expr: consumer_impact_statement
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Filing Description"
      expr: filing_description
    - name: "Filing Fee Paid Flag"
      expr: filing_fee_paid_flag
    - name: "Filing Method"
      expr: filing_method
    - name: "Filing Number"
      expr: filing_number
    - name: "Filing Status"
      expr: filing_status
    - name: "Filing Type"
      expr: filing_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Premium Rate Filing"
      expr: COUNT(DISTINCT premium_rate_filing_id)
    - name: "Total Affected Policy Count"
      expr: SUM(affected_policy_count)
    - name: "Average Affected Policy Count"
      expr: AVG(affected_policy_count)
    - name: "Total Filing Fee Amount"
      expr: SUM(filing_fee_amount)
    - name: "Average Filing Fee Amount"
      expr: AVG(filing_fee_amount)
    - name: "Total Indicated Rate Change Percentage"
      expr: SUM(indicated_rate_change_percentage)
    - name: "Average Indicated Rate Change Percentage"
      expr: AVG(indicated_rate_change_percentage)
    - name: "Total Loss Ratio Target"
      expr: SUM(loss_ratio_target)
    - name: "Average Loss Ratio Target"
      expr: AVG(loss_ratio_target)
    - name: "Total Rate Change Percentage"
      expr: SUM(rate_change_percentage)
    - name: "Average Rate Change Percentage"
      expr: AVG(rate_change_percentage)
    - name: "Total Rate Impact Amount"
      expr: SUM(rate_impact_amount)
    - name: "Average Rate Impact Amount"
      expr: AVG(rate_impact_amount)
    - name: "Total Supporting Document Count"
      expr: SUM(supporting_document_count)
    - name: "Average Supporting Document Count"
      expr: AVG(supporting_document_count)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_premium_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Premium Transaction business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`premium_transaction`"
  dimensions:
    - name: "Booking Date"
      expr: booking_date
    - name: "Coverage Part Code"
      expr: coverage_part_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Due Date"
      expr: due_date
    - name: "Effective Date"
      expr: effective_date
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Payment Method"
      expr: payment_method
    - name: "Payment Received Date"
      expr: payment_received_date
    - name: "Reason Code"
      expr: reason_code
    - name: "Reversal Flag"
      expr: reversal_flag
    - name: "Statutory Line Code"
      expr: statutory_line_code
    - name: "Transaction Description"
      expr: transaction_description
    - name: "Transaction Number"
      expr: transaction_number
    - name: "Transaction Status"
      expr: transaction_status
    - name: "Transaction Type"
      expr: transaction_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Premium Transaction"
      expr: COUNT(DISTINCT premium_transaction_id)
    - name: "Total Audit Code"
      expr: SUM(audit_code)
    - name: "Average Audit Code"
      expr: AVG(audit_code)
    - name: "Total Ceded Premium Amount"
      expr: SUM(ceded_premium_amount)
    - name: "Average Ceded Premium Amount"
      expr: AVG(ceded_premium_amount)
    - name: "Total Commission Amount"
      expr: SUM(commission_amount)
    - name: "Average Commission Amount"
      expr: AVG(commission_amount)
    - name: "Total Commission Rate"
      expr: SUM(commission_rate)
    - name: "Average Commission Rate"
      expr: AVG(commission_rate)
    - name: "Total Dac Amount"
      expr: SUM(dac_amount)
    - name: "Average Dac Amount"
      expr: AVG(dac_amount)
    - name: "Total Earned Premium Amount"
      expr: SUM(earned_premium_amount)
    - name: "Average Earned Premium Amount"
      expr: AVG(earned_premium_amount)
    - name: "Total Exchange Rate"
      expr: SUM(exchange_rate)
    - name: "Average Exchange Rate"
      expr: AVG(exchange_rate)
    - name: "Total Exposure Units"
      expr: SUM(exposure_units)
    - name: "Average Exposure Units"
      expr: AVG(exposure_units)
    - name: "Total Fee Amount"
      expr: SUM(fee_amount)
    - name: "Average Fee Amount"
      expr: AVG(fee_amount)
    - name: "Total Gwp Amount"
      expr: SUM(gwp_amount)
    - name: "Average Gwp Amount"
      expr: AVG(gwp_amount)
    - name: "Total Installment Number"
      expr: SUM(installment_number)
    - name: "Average Installment Number"
      expr: AVG(installment_number)
    - name: "Total Nwp Amount"
      expr: SUM(nwp_amount)
    - name: "Average Nwp Amount"
      expr: AVG(nwp_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_rate_element`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_v499`.`premium`.`rate_element`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_rate_table`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_v499`.`premium`.`rate_table`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_rating_worksheet`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rating Worksheet business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`rating_worksheet`"
  dimensions:
    - name: "Approval Timestamp"
      expr: approval_timestamp
    - name: "Approved By"
      expr: approved_by
    - name: "Calculation Notes"
      expr: calculation_notes
    - name: "Calculation Timestamp"
      expr: calculation_timestamp
    - name: "Class Code"
      expr: class_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Minimum Premium Applied Flag"
      expr: minimum_premium_applied_flag
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Product Code"
      expr: product_code
    - name: "Rate Effective Date"
      expr: rate_effective_date
    - name: "Rate Source"
      expr: rate_source
    - name: "Rating Basis"
      expr: rating_basis
    - name: "Rating Factor Code"
      expr: rating_factor_code
    - name: "Rating Factor Type"
      expr: rating_factor_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Rating Worksheet"
      expr: COUNT(DISTINCT rating_worksheet_id)
    - name: "Total Base Rate"
      expr: SUM(base_rate)
    - name: "Average Base Rate"
      expr: AVG(base_rate)
    - name: "Total Cumulative Premium"
      expr: SUM(cumulative_premium)
    - name: "Average Cumulative Premium"
      expr: AVG(cumulative_premium)
    - name: "Total Deductible Credit"
      expr: SUM(deductible_credit)
    - name: "Average Deductible Credit"
      expr: AVG(deductible_credit)
    - name: "Total Experience Mod"
      expr: SUM(experience_mod)
    - name: "Average Experience Mod"
      expr: AVG(experience_mod)
    - name: "Total Exposure Units"
      expr: SUM(exposure_units)
    - name: "Average Exposure Units"
      expr: AVG(exposure_units)
    - name: "Total Gwp"
      expr: SUM(gwp)
    - name: "Average Gwp"
      expr: AVG(gwp)
    - name: "Total Intermediate Premium"
      expr: SUM(intermediate_premium)
    - name: "Average Intermediate Premium"
      expr: AVG(intermediate_premium)
    - name: "Total Minimum Premium"
      expr: SUM(minimum_premium)
    - name: "Average Minimum Premium"
      expr: AVG(minimum_premium)
    - name: "Total Nwp"
      expr: SUM(nwp)
    - name: "Average Nwp"
      expr: AVG(nwp)
    - name: "Total Rating Factor Value"
      expr: SUM(rating_factor_value)
    - name: "Average Rating Factor Value"
      expr: AVG(rating_factor_value)
    - name: "Total Rating Step Sequence"
      expr: SUM(rating_step_sequence)
    - name: "Average Rating Step Sequence"
      expr: AVG(rating_step_sequence)
    - name: "Total Schedule Credit Debit"
      expr: SUM(schedule_credit_debit)
    - name: "Average Schedule Credit Debit"
      expr: AVG(schedule_credit_debit)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_surplus_lines_tax`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Surplus Lines Tax business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax`"
  dimensions:
    - name: "Adjustment Reason"
      expr: adjustment_reason
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Diligent Search Completed Flag"
      expr: diligent_search_completed_flag
    - name: "Diligent Search Date"
      expr: diligent_search_date
    - name: "Diligent Search Documentation Reference"
      expr: diligent_search_documentation_reference
    - name: "Exemption Code"
      expr: exemption_code
    - name: "Exemption Reason"
      expr: exemption_reason
    - name: "Filing Period End Date"
      expr: filing_period_end_date
    - name: "Filing Period Start Date"
      expr: filing_period_start_date
    - name: "Multi State Allocation Flag"
      expr: multi_state_allocation_flag
    - name: "Nonadmitted Insurer Naic Code"
      expr: nonadmitted_insurer_naic_code
    - name: "Nonadmitted Insurer Name"
      expr: nonadmitted_insurer_name
    - name: "Notes"
      expr: notes
    - name: "Payment Reference Number"
      expr: payment_reference_number
    - name: "Policy Effective Date"
      expr: policy_effective_date
    - name: "Policy Expiration Date"
      expr: policy_expiration_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Surplus Lines Tax"
      expr: COUNT(DISTINCT surplus_lines_tax_id)
    - name: "Total Adjustment Amount"
      expr: SUM(adjustment_amount)
    - name: "Average Adjustment Amount"
      expr: AVG(adjustment_amount)
    - name: "Total Gwp Subject To Tax"
      expr: SUM(gwp_subject_to_tax)
    - name: "Average Gwp Subject To Tax"
      expr: AVG(gwp_subject_to_tax)
    - name: "Total Home State Allocation Percent"
      expr: SUM(home_state_allocation_percent)
    - name: "Average Home State Allocation Percent"
      expr: AVG(home_state_allocation_percent)
    - name: "Total Interest Amount"
      expr: SUM(interest_amount)
    - name: "Average Interest Amount"
      expr: AVG(interest_amount)
    - name: "Total Penalty Amount"
      expr: SUM(penalty_amount)
    - name: "Average Penalty Amount"
      expr: AVG(penalty_amount)
    - name: "Total Stamping Fee Amount"
      expr: SUM(stamping_fee_amount)
    - name: "Average Stamping Fee Amount"
      expr: AVG(stamping_fee_amount)
    - name: "Total Stamping Fee Rate Percent"
      expr: SUM(stamping_fee_rate_percent)
    - name: "Average Stamping Fee Rate Percent"
      expr: AVG(stamping_fee_rate_percent)
    - name: "Total Tax Amount"
      expr: SUM(tax_amount)
    - name: "Average Tax Amount"
      expr: AVG(tax_amount)
    - name: "Total Tax Rate Percent"
      expr: SUM(tax_rate_percent)
    - name: "Average Tax Rate Percent"
      expr: AVG(tax_rate_percent)
    - name: "Total Total Tax And Fee Amount"
      expr: SUM(total_tax_and_fee_amount)
    - name: "Average Total Tax And Fee Amount"
      expr: AVG(total_tax_and_fee_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`premium_written_premium`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Written Premium business metrics"
  source: "`vibe_pc_insurance_v499`.`premium`.`written_premium`"
  dimensions:
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Exposure Basis"
      expr: exposure_basis
    - name: "Is Audit Premium"
      expr: is_audit_premium
    - name: "Is Installment Plan"
      expr: is_installment_plan
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Policy Term Effective Date"
      expr: policy_term_effective_date
    - name: "Policy Term Expiration Date"
      expr: policy_term_expiration_date
    - name: "Product Code"
      expr: product_code
    - name: "Rate Effective Date"
      expr: rate_effective_date
    - name: "Rate Version"
      expr: rate_version
    - name: "Rating Plan Code"
      expr: rating_plan_code
    - name: "Reversal Reason Code"
      expr: reversal_reason_code
    - name: "Statutory Reporting Period"
      expr: statutory_reporting_period
    - name: "Transaction Booking Date"
      expr: transaction_booking_date
    - name: "Transaction Effective Date"
      expr: transaction_effective_date
    - name: "Transaction Type"
      expr: transaction_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Written Premium"
      expr: COUNT(DISTINCT written_premium_id)
    - name: "Total Ceded Premium Amount"
      expr: SUM(ceded_premium_amount)
    - name: "Average Ceded Premium Amount"
      expr: AVG(ceded_premium_amount)
    - name: "Total Commission Amount"
      expr: SUM(commission_amount)
    - name: "Average Commission Amount"
      expr: AVG(commission_amount)
    - name: "Total Commission Rate"
      expr: SUM(commission_rate)
    - name: "Average Commission Rate"
      expr: AVG(commission_rate)
    - name: "Total Experience Mod Factor"
      expr: SUM(experience_mod_factor)
    - name: "Average Experience Mod Factor"
      expr: AVG(experience_mod_factor)
    - name: "Total Exposure Units"
      expr: SUM(exposure_units)
    - name: "Average Exposure Units"
      expr: AVG(exposure_units)
    - name: "Total Gwp Amount"
      expr: SUM(gwp_amount)
    - name: "Average Gwp Amount"
      expr: AVG(gwp_amount)
    - name: "Total Installment Count"
      expr: SUM(installment_count)
    - name: "Average Installment Count"
      expr: AVG(installment_count)
    - name: "Total Installment Fee Amount"
      expr: SUM(installment_fee_amount)
    - name: "Average Installment Fee Amount"
      expr: AVG(installment_fee_amount)
    - name: "Total Manual Premium Amount"
      expr: SUM(manual_premium_amount)
    - name: "Average Manual Premium Amount"
      expr: AVG(manual_premium_amount)
    - name: "Total Nwp Amount"
      expr: SUM(nwp_amount)
    - name: "Average Nwp Amount"
      expr: AVG(nwp_amount)
    - name: "Total Policy Fee Amount"
      expr: SUM(policy_fee_amount)
    - name: "Average Policy Fee Amount"
      expr: AVG(policy_fee_amount)
    - name: "Total Premium Basis Amount"
      expr: SUM(premium_basis_amount)
    - name: "Average Premium Basis Amount"
      expr: AVG(premium_basis_amount)
$$;