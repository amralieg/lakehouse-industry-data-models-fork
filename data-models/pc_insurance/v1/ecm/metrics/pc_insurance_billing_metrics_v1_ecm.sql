-- Metric views for domain: billing | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_account`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Billing account lifecycle and balance metrics. Grain: one row per billing account."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`account`"
  dimensions:
    - name: "account_status"
      expr: account_status
      comment: "Current status of the billing account (Active, Suspended, Closed, etc.)"
    - name: "account_type"
      expr: account_type
      comment: "Type of billing account (Individual, Commercial, Agency, etc.)"
    - name: "billing_frequency"
      expr: billing_frequency
      comment: "Billing frequency (Monthly, Quarterly, Annual, etc.)"
    - name: "billing_method"
      expr: billing_method
      comment: "Method of billing (Direct Bill, Agency Bill, List Bill, etc.)"
    - name: "payment_plan_type"
      expr: payment_plan_type
      comment: "Type of payment plan (Full Pay, Installment, etc.)"
    - name: "delinquency_status"
      expr: delinquency_status
      comment: "Delinquency status of the account (Current, Past Due, Collections, etc.)"
    - name: "auto_pay_enabled"
      expr: auto_pay_enabled
      comment: "Whether automatic payment is enabled for this account"
    - name: "paperless_billing_flag"
      expr: paperless_billing_flag
      comment: "Whether the account is enrolled in paperless billing"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the account became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the account became effective"
  measures:
    - name: "total_accounts"
      expr: COUNT(1)
      comment: "Total number of billing accounts"
    - name: "total_current_balance"
      expr: SUM(CAST(current_balance AS DOUBLE))
      comment: "Sum of current outstanding balances across all accounts"
    - name: "total_outstanding_premium"
      expr: SUM(CAST(outstanding_premium AS DOUBLE))
      comment: "Sum of outstanding premium amounts across all accounts"
    - name: "total_outstanding_fees"
      expr: SUM(CAST(outstanding_fees AS DOUBLE))
      comment: "Sum of outstanding fee amounts across all accounts"
    - name: "total_outstanding_taxes"
      expr: SUM(CAST(outstanding_taxes AS DOUBLE))
      comment: "Sum of outstanding tax amounts across all accounts"
    - name: "total_credit_balance"
      expr: SUM(CAST(credit_balance AS DOUBLE))
      comment: "Sum of credit balances (overpayments) across all accounts"
    - name: "total_unapplied_cash"
      expr: SUM(CAST(unapplied_cash AS DOUBLE))
      comment: "Sum of unapplied cash (payments not yet allocated) across all accounts"
    - name: "total_write_off_amount"
      expr: SUM(CAST(write_off_amount AS DOUBLE))
      comment: "Sum of amounts written off across all accounts"
    - name: "avg_days_past_due"
      expr: AVG(CAST(days_past_due AS DOUBLE))
      comment: "Average number of days past due across all accounts"
    - name: "avg_current_balance"
      expr: AVG(CAST(current_balance AS DOUBLE))
      comment: "Average current balance per account"
    - name: "accounts_with_autopay"
      expr: SUM(CAST(CASE WHEN auto_pay_enabled = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of accounts with automatic payment enabled"
    - name: "accounts_delinquent"
      expr: SUM(CAST(CASE WHEN days_past_due > 0 THEN 1 ELSE 0 END AS INT))
      comment: "Count of accounts with any past due balance"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Invoice issuance, payment, and aging metrics. Grain: one row per invoice."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`invoice`"
  dimensions:
    - name: "invoice_status"
      expr: invoice_status
      comment: "Current status of the invoice (Issued, Paid, Partially Paid, Cancelled, etc.)"
    - name: "invoice_type"
      expr: invoice_type
      comment: "Type of invoice (New Business, Renewal, Endorsement, Cancellation, etc.)"
    - name: "billing_method"
      expr: billing_method
      comment: "Method of billing for this invoice"
    - name: "payment_method"
      expr: payment_method
      comment: "Payment method used or expected for this invoice"
    - name: "delinquency_status"
      expr: delinquency_status
      comment: "Delinquency status of the invoice"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether this invoice has been reversed"
    - name: "invoice_year"
      expr: YEAR(invoice_date)
      comment: "Year the invoice was issued"
    - name: "invoice_month"
      expr: DATE_TRUNC('MONTH', invoice_date)
      comment: "Month the invoice was issued"
    - name: "due_year"
      expr: YEAR(due_date)
      comment: "Year the invoice is due"
    - name: "due_month"
      expr: DATE_TRUNC('MONTH', due_date)
      comment: "Month the invoice is due"
  measures:
    - name: "total_invoices"
      expr: COUNT(1)
      comment: "Total number of invoices"
    - name: "total_invoice_amount"
      expr: SUM(CAST(total_amount_due AS DOUBLE))
      comment: "Sum of total amounts due across all invoices"
    - name: "total_premium_billed"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Sum of premium amounts billed across all invoices"
    - name: "total_fees_billed"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Sum of fee amounts billed across all invoices"
    - name: "total_taxes_billed"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Sum of tax amounts billed across all invoices"
    - name: "total_commission_billed"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Sum of commission amounts billed across all invoices"
    - name: "total_amount_paid"
      expr: SUM(CAST(amount_paid AS DOUBLE))
      comment: "Sum of amounts paid across all invoices"
    - name: "total_outstanding_balance"
      expr: SUM(CAST(outstanding_balance AS DOUBLE))
      comment: "Sum of outstanding balances across all invoices"
    - name: "avg_invoice_amount"
      expr: AVG(CAST(total_amount_due AS DOUBLE))
      comment: "Average invoice amount"
    - name: "invoices_paid_in_full"
      expr: SUM(CAST(CASE WHEN outstanding_balance = 0 AND amount_paid > 0 THEN 1 ELSE 0 END AS INT))
      comment: "Count of invoices paid in full"
    - name: "invoices_reversed"
      expr: SUM(CAST(CASE WHEN reversal_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of invoices that have been reversed"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payment receipt, application, and return metrics. Grain: one row per payment transaction."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`payment`"
  dimensions:
    - name: "payment_status"
      expr: payment_status
      comment: "Current status of the payment (Received, Applied, Cleared, Returned, Reversed, etc.)"
    - name: "payment_type"
      expr: payment_type
      comment: "Type of payment (Premium, Fee, Tax, Reinstatement, etc.)"
    - name: "method"
      expr: method
      comment: "Payment method (Check, ACH, Credit Card, Wire, etc.)"
    - name: "channel"
      expr: channel
      comment: "Channel through which payment was received (Online, Mail, Agent, Phone, etc.)"
    - name: "source"
      expr: source
      comment: "Source system or origin of the payment"
    - name: "is_returned"
      expr: is_returned
      comment: "Whether the payment was returned (NSF, stop payment, etc.)"
    - name: "receipt_year"
      expr: YEAR(receipt_date)
      comment: "Year the payment was received"
    - name: "receipt_month"
      expr: DATE_TRUNC('MONTH', receipt_date)
      comment: "Month the payment was received"
    - name: "applied_year"
      expr: YEAR(applied_date)
      comment: "Year the payment was applied"
    - name: "applied_month"
      expr: DATE_TRUNC('MONTH', applied_date)
      comment: "Month the payment was applied"
  measures:
    - name: "total_payments"
      expr: COUNT(1)
      comment: "Total number of payment transactions"
    - name: "total_payment_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Sum of payment amounts received"
    - name: "total_applied_amount"
      expr: SUM(CAST(applied_amount AS DOUBLE))
      comment: "Sum of payment amounts applied to invoices"
    - name: "total_unapplied_amount"
      expr: SUM(CAST(unapplied_amount AS DOUBLE))
      comment: "Sum of payment amounts not yet applied"
    - name: "total_nsf_fees"
      expr: SUM(CAST(nsf_fee_amount AS DOUBLE))
      comment: "Sum of NSF (non-sufficient funds) fees assessed"
    - name: "avg_payment_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average payment amount per transaction"
    - name: "payments_returned"
      expr: SUM(CAST(CASE WHEN is_returned = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of payments that were returned"
    - name: "payments_fully_applied"
      expr: SUM(CAST(CASE WHEN unapplied_amount = 0 AND applied_amount > 0 THEN 1 ELSE 0 END AS INT))
      comment: "Count of payments fully applied to invoices"
    - name: "distinct_payers"
      expr: COUNT(DISTINCT payer_party_id)
      comment: "Count of distinct parties making payments"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_delinquency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Delinquency tracking and collections metrics. Grain: one row per delinquency case."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`delinquency`"
  dimensions:
    - name: "delinquency_status"
      expr: delinquency_status
      comment: "Current status of the delinquency (Active, Resolved, Cancelled, Written Off, etc.)"
    - name: "reason_code"
      expr: reason_code
      comment: "Reason code for the delinquency"
    - name: "resolution_method"
      expr: resolution_method
      comment: "Method by which the delinquency was resolved (Payment, Write-off, Cancellation, etc.)"
    - name: "collections_agency_flag"
      expr: collections_agency_flag
      comment: "Whether the delinquency was referred to a collections agency"
    - name: "payment_plan_default_flag"
      expr: payment_plan_default_flag
      comment: "Whether the delinquency resulted from payment plan default"
    - name: "returned_payment_flag"
      expr: returned_payment_flag
      comment: "Whether the delinquency was caused by a returned payment"
    - name: "start_year"
      expr: YEAR(start_date)
      comment: "Year the delinquency started"
    - name: "start_month"
      expr: DATE_TRUNC('MONTH', start_date)
      comment: "Month the delinquency started"
    - name: "resolved_year"
      expr: YEAR(resolved_date)
      comment: "Year the delinquency was resolved"
    - name: "resolved_month"
      expr: DATE_TRUNC('MONTH', resolved_date)
      comment: "Month the delinquency was resolved"
  measures:
    - name: "total_delinquencies"
      expr: COUNT(1)
      comment: "Total number of delinquency cases"
    - name: "total_past_due_amount"
      expr: SUM(CAST(past_due_amount AS DOUBLE))
      comment: "Sum of past due amounts across all delinquencies"
    - name: "total_late_fees"
      expr: SUM(CAST(late_fee_amount AS DOUBLE))
      comment: "Sum of late fee amounts assessed"
    - name: "total_penalties"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Sum of penalty amounts assessed"
    - name: "total_amount_due"
      expr: SUM(CAST(total_amount_due AS DOUBLE))
      comment: "Sum of total amounts due including fees and penalties"
    - name: "total_reinstatement_amount"
      expr: SUM(CAST(reinstatement_amount AS DOUBLE))
      comment: "Sum of reinstatement amounts required to cure delinquencies"
    - name: "total_write_off_amount"
      expr: SUM(CAST(write_off_amount AS DOUBLE))
      comment: "Sum of amounts written off from delinquencies"
    - name: "avg_days_past_due"
      expr: AVG(CAST(days_past_due AS DOUBLE))
      comment: "Average number of days past due across all delinquencies"
    - name: "avg_notice_count"
      expr: AVG(CAST(notice_sent_count AS DOUBLE))
      comment: "Average number of notices sent per delinquency"
    - name: "delinquencies_referred_to_collections"
      expr: SUM(CAST(CASE WHEN collections_agency_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of delinquencies referred to collections agencies"
    - name: "delinquencies_resolved"
      expr: SUM(CAST(CASE WHEN resolved_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of delinquencies that have been resolved"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_commission_payable`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Producer commission payable and disbursement metrics. Grain: one row per commission payable transaction."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`commission_payable`"
  dimensions:
    - name: "payable_status"
      expr: payable_status
      comment: "Current status of the commission payable (Pending, Approved, Paid, Withheld, Reversed, etc.)"
    - name: "commission_type"
      expr: commission_type
      comment: "Type of commission (New Business, Renewal, Endorsement, Contingent, etc.)"
    - name: "commission_basis"
      expr: commission_basis
      comment: "Basis for commission calculation (Premium, Fee, etc.)"
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of transaction generating the commission"
    - name: "payment_method"
      expr: payment_method
      comment: "Method of commission payment (ACH, Check, Wire, etc.)"
    - name: "chargeback_flag"
      expr: chargeback_flag
      comment: "Whether this is a commission chargeback"
    - name: "override_flag"
      expr: override_flag
      comment: "Whether the commission rate was manually overridden"
    - name: "split_flag"
      expr: split_flag
      comment: "Whether the commission is split among multiple producers"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether this commission payable has been reversed"
    - name: "earned_year"
      expr: YEAR(earned_date)
      comment: "Year the commission was earned"
    - name: "earned_month"
      expr: DATE_TRUNC('MONTH', earned_date)
      comment: "Month the commission was earned"
    - name: "paid_year"
      expr: YEAR(paid_date)
      comment: "Year the commission was paid"
    - name: "paid_month"
      expr: DATE_TRUNC('MONTH', paid_date)
      comment: "Month the commission was paid"
  measures:
    - name: "total_commission_payables"
      expr: COUNT(1)
      comment: "Total number of commission payable transactions"
    - name: "total_gross_commission"
      expr: SUM(CAST(gross_commission_amount AS DOUBLE))
      comment: "Sum of gross commission amounts before withholdings"
    - name: "total_net_payable"
      expr: SUM(CAST(net_payable_amount AS DOUBLE))
      comment: "Sum of net commission amounts payable to producers"
    - name: "total_withheld_amount"
      expr: SUM(CAST(withheld_amount AS DOUBLE))
      comment: "Sum of commission amounts withheld"
    - name: "total_chargeback_amount"
      expr: SUM(CAST(chargeback_amount AS DOUBLE))
      comment: "Sum of commission chargeback amounts"
    - name: "total_premium_basis"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Sum of premium amounts on which commission is based"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate across all payables"
    - name: "avg_split_percentage"
      expr: AVG(CAST(split_percentage AS DOUBLE))
      comment: "Average split percentage for split commissions"
    - name: "commissions_paid"
      expr: SUM(CAST(CASE WHEN paid_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of commission payables that have been paid"
    - name: "commissions_withheld"
      expr: SUM(CAST(CASE WHEN withheld_amount > 0 THEN 1 ELSE 0 END AS INT))
      comment: "Count of commission payables with withholdings"
    - name: "distinct_producers_paid"
      expr: COUNT(DISTINCT producers_producer_id)
      comment: "Count of distinct producers receiving commission"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_installment_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Installment plan performance and delinquency metrics. Grain: one row per installment plan."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`installment_plan`"
  dimensions:
    - name: "plan_status"
      expr: plan_status
      comment: "Current status of the installment plan (Active, Paid, Defaulted, Cancelled, etc.)"
    - name: "billing_method"
      expr: billing_method
      comment: "Billing method for the installment plan"
    - name: "payment_method"
      expr: payment_method
      comment: "Payment method for the installment plan"
    - name: "auto_pay_flag"
      expr: auto_pay_flag
      comment: "Whether automatic payment is enabled for this plan"
    - name: "is_delinquent"
      expr: is_delinquent
      comment: "Whether the installment plan is currently delinquent"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the installment plan became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the installment plan became effective"
  measures:
    - name: "total_installment_plans"
      expr: COUNT(1)
      comment: "Total number of installment plans"
    - name: "total_plan_amount"
      expr: SUM(CAST(total_plan_amount AS DOUBLE))
      comment: "Sum of total plan amounts across all installment plans"
    - name: "total_premium_amount"
      expr: SUM(CAST(total_premium_amount AS DOUBLE))
      comment: "Sum of premium amounts financed through installment plans"
    - name: "total_fees_amount"
      expr: SUM(CAST(total_fees_amount AS DOUBLE))
      comment: "Sum of installment fees charged across all plans"
    - name: "total_down_payment"
      expr: SUM(CAST(down_payment_amount AS DOUBLE))
      comment: "Sum of down payment amounts across all plans"
    - name: "total_amount_outstanding"
      expr: SUM(CAST(amount_outstanding AS DOUBLE))
      comment: "Sum of outstanding amounts across all installment plans"
    - name: "total_amount_paid_to_date"
      expr: SUM(CAST(amount_paid_to_date AS DOUBLE))
      comment: "Sum of amounts paid to date across all installment plans"
    - name: "total_late_fees"
      expr: SUM(CAST(late_fee_amount AS DOUBLE))
      comment: "Sum of late fees assessed on installment plans"
    - name: "total_reinstatement_fees"
      expr: SUM(CAST(reinstatement_fee_amount AS DOUBLE))
      comment: "Sum of reinstatement fees charged on defaulted plans"
    - name: "avg_installments_total"
      expr: AVG(CAST(number_of_installments AS DOUBLE))
      comment: "Average number of installments per plan"
    - name: "avg_installments_paid"
      expr: AVG(CAST(installments_paid AS DOUBLE))
      comment: "Average number of installments paid per plan"
    - name: "avg_days_delinquent"
      expr: AVG(CAST(days_delinquent AS DOUBLE))
      comment: "Average number of days delinquent across all plans"
    - name: "plans_with_autopay"
      expr: SUM(CAST(CASE WHEN auto_pay_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of installment plans with automatic payment enabled"
    - name: "plans_delinquent"
      expr: SUM(CAST(CASE WHEN is_delinquent = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of installment plans currently delinquent"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_write_off`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Bad debt write-off and recovery metrics. Grain: one row per write-off transaction."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`write_off`"
  dimensions:
    - name: "write_off_status"
      expr: write_off_status
      comment: "Current status of the write-off (Pending, Approved, Posted, Reversed, etc.)"
    - name: "write_off_type"
      expr: write_off_type
      comment: "Type of write-off (Bad Debt, Uncollectible, Small Balance, etc.)"
    - name: "reason_code"
      expr: reason_code
      comment: "Reason code for the write-off"
    - name: "statutory_category_code"
      expr: statutory_category_code
      comment: "Statutory reporting category for the write-off"
    - name: "approval_authority_level"
      expr: approval_authority_level
      comment: "Authority level required to approve this write-off"
    - name: "approval_required_flag"
      expr: approval_required_flag
      comment: "Whether approval was required for this write-off"
    - name: "collection_agency_flag"
      expr: collection_agency_flag
      comment: "Whether the debt was referred to a collection agency before write-off"
    - name: "recovery_expected_flag"
      expr: recovery_expected_flag
      comment: "Whether future recovery is expected on this write-off"
    - name: "regulatory_reporting_flag"
      expr: regulatory_reporting_flag
      comment: "Whether this write-off must be reported to regulators"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether this write-off has been reversed"
    - name: "write_off_year"
      expr: YEAR(write_off_date)
      comment: "Year the write-off was recorded"
    - name: "write_off_month"
      expr: DATE_TRUNC('MONTH', write_off_date)
      comment: "Month the write-off was recorded"
  measures:
    - name: "total_write_offs"
      expr: COUNT(1)
      comment: "Total number of write-off transactions"
    - name: "total_write_off_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Sum of total write-off amounts"
    - name: "total_principal_written_off"
      expr: SUM(CAST(principal_amount AS DOUBLE))
      comment: "Sum of principal amounts written off"
    - name: "total_interest_written_off"
      expr: SUM(CAST(interest_amount AS DOUBLE))
      comment: "Sum of interest amounts written off"
    - name: "total_fees_written_off"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Sum of fee amounts written off"
    - name: "total_penalties_written_off"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Sum of penalty amounts written off"
    - name: "avg_write_off_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average write-off amount per transaction"
    - name: "avg_recovery_probability"
      expr: AVG(CAST(recovery_probability_percent AS DOUBLE))
      comment: "Average probability of recovery across all write-offs"
    - name: "write_offs_reversed"
      expr: SUM(CAST(CASE WHEN reversal_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of write-offs that have been reversed"
    - name: "write_offs_with_recovery_expected"
      expr: SUM(CAST(CASE WHEN recovery_expected_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of write-offs where future recovery is expected"
    - name: "distinct_accounts_written_off"
      expr: COUNT(DISTINCT billing_account_id)
      comment: "Count of distinct billing accounts with write-offs"
$$;