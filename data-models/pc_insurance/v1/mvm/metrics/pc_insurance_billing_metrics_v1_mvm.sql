-- Metric views for domain: billing | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_account`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Billing account KPIs: balance, delinquency, payment behavior, and account health metrics. Grain: one row per billing account."
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
      comment: "Frequency of billing cycle (Monthly, Quarterly, Annual, etc.)"
    - name: "billing_method"
      expr: billing_method
      comment: "Method used for billing (Direct Bill, Agency Bill, List Bill, etc.)"
    - name: "payment_plan_type"
      expr: payment_plan_type
      comment: "Type of payment plan associated with the account"
    - name: "delinquency_status"
      expr: delinquency_status
      comment: "Current delinquency status of the account"
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
      comment: "Total current balance across all accounts"
    - name: "total_outstanding_premium"
      expr: SUM(CAST(outstanding_premium AS DOUBLE))
      comment: "Total outstanding premium across all accounts"
    - name: "total_outstanding_fees"
      expr: SUM(CAST(outstanding_fees AS DOUBLE))
      comment: "Total outstanding fees across all accounts"
    - name: "total_outstanding_taxes"
      expr: SUM(CAST(outstanding_taxes AS DOUBLE))
      comment: "Total outstanding taxes across all accounts"
    - name: "total_credit_balance"
      expr: SUM(CAST(credit_balance AS DOUBLE))
      comment: "Total credit balance across all accounts"
    - name: "total_unapplied_cash"
      expr: SUM(CAST(unapplied_cash AS DOUBLE))
      comment: "Total unapplied cash across all accounts"
    - name: "avg_days_past_due"
      expr: AVG(CAST(days_past_due AS DOUBLE))
      comment: "Average number of days past due across accounts"
    - name: "total_write_off_amount"
      expr: SUM(CAST(write_off_amount AS DOUBLE))
      comment: "Total amount written off across all accounts"
    - name: "delinquent_account_count"
      expr: COUNT(CASE WHEN delinquency_status IS NOT NULL AND delinquency_status != 'Current' THEN 1 END)
      comment: "Number of accounts with delinquent status"
    - name: "autopay_enabled_count"
      expr: COUNT(CASE WHEN auto_pay_enabled = TRUE THEN 1 END)
      comment: "Number of accounts with autopay enabled"
    - name: "paperless_billing_count"
      expr: COUNT(CASE WHEN paperless_billing_flag = TRUE THEN 1 END)
      comment: "Number of accounts enrolled in paperless billing"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payment transaction KPIs: payment volume, amounts, methods, status, and return rates. Grain: one row per payment transaction."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`payment`"
  dimensions:
    - name: "payment_status"
      expr: payment_status
      comment: "Current status of the payment (Pending, Cleared, Returned, Reversed, etc.)"
    - name: "payment_type"
      expr: payment_type
      comment: "Type of payment (Premium, Fee, Tax, Commission, etc.)"
    - name: "channel"
      expr: channel
      comment: "Channel through which payment was received (Online, Mail, Phone, Agent, etc.)"
    - name: "source"
      expr: source
      comment: "Source system or origin of the payment"
    - name: "card_type"
      expr: card_type
      comment: "Type of credit/debit card used (Visa, MasterCard, Amex, etc.)"
    - name: "is_returned"
      expr: is_returned
      comment: "Whether the payment was returned (NSF, stop payment, etc.)"
    - name: "return_reason_code"
      expr: return_reason_code
      comment: "Code indicating reason for payment return"
    - name: "receipt_year"
      expr: YEAR(receipt_date)
      comment: "Year the payment was received"
    - name: "receipt_month"
      expr: DATE_TRUNC('MONTH', receipt_date)
      comment: "Month the payment was received"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the payment became effective"
  measures:
    - name: "total_payments"
      expr: COUNT(1)
      comment: "Total number of payment transactions"
    - name: "total_payment_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total payment amount received"
    - name: "total_applied_amount"
      expr: SUM(CAST(applied_amount AS DOUBLE))
      comment: "Total amount applied to invoices and balances"
    - name: "total_unapplied_amount"
      expr: SUM(CAST(unapplied_amount AS DOUBLE))
      comment: "Total amount not yet applied to invoices"
    - name: "total_nsf_fees"
      expr: SUM(CAST(nsf_fee_amount AS DOUBLE))
      comment: "Total NSF (non-sufficient funds) fees charged"
    - name: "avg_payment_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average payment amount per transaction"
    - name: "returned_payment_count"
      expr: COUNT(CASE WHEN is_returned = TRUE THEN 1 END)
      comment: "Number of payments that were returned"
    - name: "cleared_payment_count"
      expr: COUNT(CASE WHEN payment_status = 'Cleared' THEN 1 END)
      comment: "Number of payments that have cleared"
    - name: "unique_payers"
      expr: COUNT(DISTINCT payer_party_id)
      comment: "Number of unique parties making payments"
    - name: "unique_billing_accounts"
      expr: COUNT(DISTINCT billing_account_id)
      comment: "Number of unique billing accounts receiving payments"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Invoice KPIs: billing volume, amounts due, payment status, and aging. Grain: one row per invoice."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`invoice`"
  dimensions:
    - name: "invoice_status"
      expr: invoice_status
      comment: "Current status of the invoice (Issued, Paid, Overdue, Cancelled, etc.)"
    - name: "invoice_type"
      expr: invoice_type
      comment: "Type of invoice (Premium, Endorsement, Cancellation, Reinstatement, etc.)"
    - name: "billing_method"
      expr: billing_method
      comment: "Method used for billing this invoice"
    - name: "delinquency_status"
      expr: delinquency_status
      comment: "Delinquency status of the invoice"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether the invoice has been reversed"
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
      comment: "Total number of invoices issued"
    - name: "total_amount_due"
      expr: SUM(CAST(total_amount_due AS DOUBLE))
      comment: "Total amount due across all invoices"
    - name: "total_premium_amount"
      expr: SUM(CAST(premium_amount AS DOUBLE))
      comment: "Total premium amount billed"
    - name: "total_tax_amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax amount billed"
    - name: "total_fee_amount"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total fee amount billed"
    - name: "total_commission_amount"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total commission amount on invoices"
    - name: "total_outstanding_balance"
      expr: SUM(CAST(outstanding_balance AS DOUBLE))
      comment: "Total outstanding balance across all invoices"
    - name: "total_amount_paid"
      expr: SUM(CAST(amount_paid AS DOUBLE))
      comment: "Total amount paid against invoices"
    - name: "avg_invoice_amount"
      expr: AVG(CAST(total_amount_due AS DOUBLE))
      comment: "Average invoice amount"
    - name: "paid_invoice_count"
      expr: COUNT(CASE WHEN invoice_status = 'Paid' THEN 1 END)
      comment: "Number of invoices fully paid"
    - name: "overdue_invoice_count"
      expr: COUNT(CASE WHEN invoice_status = 'Overdue' THEN 1 END)
      comment: "Number of invoices past due"
    - name: "reversed_invoice_count"
      expr: COUNT(CASE WHEN reversal_flag = TRUE THEN 1 END)
      comment: "Number of invoices that have been reversed"
    - name: "unique_billing_accounts"
      expr: COUNT(DISTINCT billing_account_id)
      comment: "Number of unique billing accounts invoiced"
    - name: "unique_policies"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of unique policies invoiced"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_delinquency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Delinquency KPIs: past-due accounts, aging, collections activity, and resolution rates. Grain: one row per delinquency case."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`delinquency`"
  dimensions:
    - name: "delinquency_status"
      expr: delinquency_status
      comment: "Current status of the delinquency case"
    - name: "reason_code"
      expr: reason_code
      comment: "Code indicating reason for delinquency"
    - name: "cancellation_reason_code"
      expr: cancellation_reason_code
      comment: "Reason code if policy was cancelled due to delinquency"
    - name: "collections_agency_flag"
      expr: collections_agency_flag
      comment: "Whether the case has been referred to a collections agency"
    - name: "payment_plan_default_flag"
      expr: payment_plan_default_flag
      comment: "Whether the delinquency resulted from payment plan default"
    - name: "returned_payment_flag"
      expr: returned_payment_flag
      comment: "Whether the delinquency was caused by a returned payment"
    - name: "resolution_method"
      expr: resolution_method
      comment: "Method used to resolve the delinquency"
    - name: "start_year"
      expr: YEAR(start_date)
      comment: "Year the delinquency started"
    - name: "start_month"
      expr: DATE_TRUNC('MONTH', start_date)
      comment: "Month the delinquency started"
  measures:
    - name: "total_delinquencies"
      expr: COUNT(1)
      comment: "Total number of delinquency cases"
    - name: "total_past_due_amount"
      expr: SUM(CAST(past_due_amount AS DOUBLE))
      comment: "Total amount past due across all delinquency cases"
    - name: "total_late_fees"
      expr: SUM(CAST(late_fee_amount AS DOUBLE))
      comment: "Total late fees assessed"
    - name: "total_penalty_amount"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Total penalty amounts assessed"
    - name: "total_amount_due"
      expr: SUM(CAST(total_amount_due AS DOUBLE))
      comment: "Total amount due including fees and penalties"
    - name: "total_reinstatement_amount"
      expr: SUM(CAST(reinstatement_amount AS DOUBLE))
      comment: "Total reinstatement amounts required"
    - name: "total_write_off_amount"
      expr: SUM(CAST(write_off_amount AS DOUBLE))
      comment: "Total amount written off from delinquent accounts"
    - name: "avg_days_past_due"
      expr: AVG(CAST(days_past_due AS DOUBLE))
      comment: "Average number of days past due"
    - name: "avg_grace_period_days"
      expr: AVG(CAST(grace_period_days AS DOUBLE))
      comment: "Average grace period days allowed"
    - name: "collections_referral_count"
      expr: COUNT(CASE WHEN collections_agency_flag = TRUE THEN 1 END)
      comment: "Number of cases referred to collections agencies"
    - name: "payment_plan_default_count"
      expr: COUNT(CASE WHEN payment_plan_default_flag = TRUE THEN 1 END)
      comment: "Number of cases resulting from payment plan defaults"
    - name: "returned_payment_delinquency_count"
      expr: COUNT(CASE WHEN returned_payment_flag = TRUE THEN 1 END)
      comment: "Number of delinquencies caused by returned payments"
    - name: "resolved_delinquency_count"
      expr: COUNT(CASE WHEN resolved_date IS NOT NULL THEN 1 END)
      comment: "Number of delinquency cases that have been resolved"
    - name: "unique_billing_accounts"
      expr: COUNT(DISTINCT billing_account_id)
      comment: "Number of unique billing accounts with delinquencies"
    - name: "unique_policies"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of unique policies with delinquencies"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_disbursement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Disbursement KPIs: outbound payment volume, amounts, types, and payee analysis. Grain: one row per disbursement transaction."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`disbursement`"
  dimensions:
    - name: "disbursement_status"
      expr: disbursement_status
      comment: "Current status of the disbursement (Pending, Issued, Cleared, Voided, etc.)"
    - name: "disbursement_type"
      expr: disbursement_type
      comment: "Type of disbursement (Claim Payment, Commission, Refund, Reinsurance, etc.)"
    - name: "payment_method"
      expr: payment_method
      comment: "Method used for disbursement (Check, ACH, Wire, EFT, etc.)"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether the disbursement has been reversed"
    - name: "reversal_reason_code"
      expr: reversal_reason_code
      comment: "Code indicating reason for disbursement reversal"
    - name: "gl_account_code"
      expr: gl_account_code
      comment: "General ledger account code for the disbursement"
    - name: "disbursement_year"
      expr: YEAR(disbursement_date)
      comment: "Year the disbursement was made"
    - name: "disbursement_month"
      expr: DATE_TRUNC('MONTH', disbursement_date)
      comment: "Month the disbursement was made"
    - name: "approval_year"
      expr: YEAR(approval_date)
      comment: "Year the disbursement was approved"
  measures:
    - name: "total_disbursements"
      expr: COUNT(1)
      comment: "Total number of disbursement transactions"
    - name: "total_gross_amount"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross disbursement amount before withholdings"
    - name: "total_net_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net disbursement amount after withholdings"
    - name: "total_withheld_amount"
      expr: SUM(CAST(withheld_amount AS DOUBLE))
      comment: "Total amount withheld from disbursements"
    - name: "total_commission_basis"
      expr: SUM(CAST(commission_basis_amount AS DOUBLE))
      comment: "Total commission basis amount for commission disbursements"
    - name: "avg_disbursement_amount"
      expr: AVG(CAST(net_amount AS DOUBLE))
      comment: "Average net disbursement amount per transaction"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate for commission disbursements"
    - name: "reversed_disbursement_count"
      expr: COUNT(CASE WHEN reversal_flag = TRUE THEN 1 END)
      comment: "Number of disbursements that have been reversed"
    - name: "cleared_disbursement_count"
      expr: COUNT(CASE WHEN disbursement_status = 'Cleared' THEN 1 END)
      comment: "Number of disbursements that have cleared"
    - name: "voided_disbursement_count"
      expr: COUNT(CASE WHEN void_date IS NOT NULL THEN 1 END)
      comment: "Number of disbursements that have been voided"
    - name: "unique_payees"
      expr: COUNT(DISTINCT payee_party_id)
      comment: "Number of unique payees receiving disbursements"
    - name: "unique_billing_accounts"
      expr: COUNT(DISTINCT billing_account_id)
      comment: "Number of unique billing accounts with disbursements"
    - name: "unique_claims"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of unique claims with disbursements"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_installment_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Installment plan KPIs: plan performance, payment progress, delinquency rates, and plan completion. Grain: one row per installment plan."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`installment_plan`"
  dimensions:
    - name: "plan_status"
      expr: plan_status
      comment: "Current status of the installment plan (Active, Completed, Defaulted, Cancelled, etc.)"
    - name: "billing_method"
      expr: billing_method
      comment: "Billing method for the installment plan"
    - name: "payment_method"
      expr: payment_method
      comment: "Payment method used for installments"
    - name: "auto_pay_flag"
      expr: auto_pay_flag
      comment: "Whether the plan is enrolled in automatic payments"
    - name: "is_delinquent"
      expr: is_delinquent
      comment: "Whether the plan is currently delinquent"
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
      comment: "Total amount financed across all installment plans"
    - name: "total_premium_amount"
      expr: SUM(CAST(total_premium_amount AS DOUBLE))
      comment: "Total premium amount in installment plans"
    - name: "total_fees_amount"
      expr: SUM(CAST(total_fees_amount AS DOUBLE))
      comment: "Total fees charged on installment plans"
    - name: "total_down_payment"
      expr: SUM(CAST(down_payment_amount AS DOUBLE))
      comment: "Total down payment amounts collected"
    - name: "total_amount_paid"
      expr: SUM(CAST(amount_paid_to_date AS DOUBLE))
      comment: "Total amount paid to date across all plans"
    - name: "total_amount_outstanding"
      expr: SUM(CAST(amount_outstanding AS DOUBLE))
      comment: "Total amount still outstanding across all plans"
    - name: "total_late_fees"
      expr: SUM(CAST(late_fee_amount AS DOUBLE))
      comment: "Total late fees assessed on installment plans"
    - name: "total_reinstatement_fees"
      expr: SUM(CAST(reinstatement_fee_amount AS DOUBLE))
      comment: "Total reinstatement fees charged"
    - name: "avg_installments_per_plan"
      expr: AVG(CAST(number_of_installments AS DOUBLE))
      comment: "Average number of installments per plan"
    - name: "avg_installments_paid"
      expr: AVG(CAST(installments_paid AS DOUBLE))
      comment: "Average number of installments paid per plan"
    - name: "avg_installments_outstanding"
      expr: AVG(CAST(installments_outstanding AS DOUBLE))
      comment: "Average number of installments still outstanding per plan"
    - name: "avg_days_delinquent"
      expr: AVG(CAST(days_delinquent AS DOUBLE))
      comment: "Average number of days delinquent for plans in arrears"
    - name: "delinquent_plan_count"
      expr: COUNT(CASE WHEN is_delinquent = TRUE THEN 1 END)
      comment: "Number of installment plans currently delinquent"
    - name: "autopay_plan_count"
      expr: COUNT(CASE WHEN auto_pay_flag = TRUE THEN 1 END)
      comment: "Number of plans enrolled in automatic payments"
    - name: "unique_billing_accounts"
      expr: COUNT(DISTINCT billing_account_id)
      comment: "Number of unique billing accounts with installment plans"
    - name: "unique_policies"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of unique policies on installment plans"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`billing_payment_application`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payment application KPIs: allocation accuracy, suspense balances, reversal rates, and application timing. Grain: one row per payment application transaction."
  source: "`vibe_pc_insurance_blog_v499`.`billing`.`payment_application`"
  dimensions:
    - name: "application_status"
      expr: application_status
      comment: "Current status of the payment application"
    - name: "application_type"
      expr: application_type
      comment: "Type of payment application (Standard, Suspense, Reversal, etc.)"
    - name: "application_method"
      expr: application_method
      comment: "Method used to apply the payment (Auto, Manual, etc.)"
    - name: "allocation_rule_code"
      expr: allocation_rule_code
      comment: "Rule code governing payment allocation priority"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether this application has been reversed"
    - name: "delinquency_flag"
      expr: delinquency_flag
      comment: "Whether the application relates to a delinquent account"
    - name: "write_off_flag"
      expr: write_off_flag
      comment: "Whether the application includes a write-off"
    - name: "commission_payable_flag"
      expr: commission_payable_flag
      comment: "Whether commission is payable on this application"
    - name: "application_year"
      expr: YEAR(application_date)
      comment: "Year the payment was applied"
    - name: "application_month"
      expr: DATE_TRUNC('MONTH', application_date)
      comment: "Month the payment was applied"
  measures:
    - name: "total_applications"
      expr: COUNT(1)
      comment: "Total number of payment application transactions"
    - name: "total_applied_amount"
      expr: SUM(CAST(applied_amount AS DOUBLE))
      comment: "Total amount applied to invoices and balances"
    - name: "total_unapplied_amount"
      expr: SUM(CAST(unapplied_amount AS DOUBLE))
      comment: "Total amount remaining unapplied"
    - name: "total_suspense_amount"
      expr: SUM(CAST(suspense_amount AS DOUBLE))
      comment: "Total amount held in suspense"
    - name: "avg_applied_amount"
      expr: AVG(CAST(applied_amount AS DOUBLE))
      comment: "Average amount applied per transaction"
    - name: "reversed_application_count"
      expr: COUNT(CASE WHEN reversal_flag = TRUE THEN 1 END)
      comment: "Number of payment applications that have been reversed"
    - name: "delinquent_application_count"
      expr: COUNT(CASE WHEN delinquency_flag = TRUE THEN 1 END)
      comment: "Number of applications related to delinquent accounts"
    - name: "write_off_application_count"
      expr: COUNT(CASE WHEN write_off_flag = TRUE THEN 1 END)
      comment: "Number of applications including write-offs"
    - name: "suspense_cleared_count"
      expr: COUNT(CASE WHEN suspense_cleared_date IS NOT NULL THEN 1 END)
      comment: "Number of suspense amounts that have been cleared"
    - name: "unique_payments"
      expr: COUNT(DISTINCT payment_id)
      comment: "Number of unique payments applied"
    - name: "unique_invoices"
      expr: COUNT(DISTINCT invoice_id)
      comment: "Number of unique invoices receiving payment applications"
    - name: "unique_billing_accounts"
      expr: COUNT(DISTINCT billing_account_id)
      comment: "Number of unique billing accounts with payment applications"
$$;