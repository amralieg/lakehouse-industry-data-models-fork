-- Metric views for domain: premium | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core premium transaction metrics tracking written, earned, unearned, and return premium across policies, coverages, and insured risks. Grain: one row per premium financial transaction."
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`"
  dimensions:
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of premium transaction: New Business, Renewal, Endorsement, Cancellation, Reinstatement, Return"
    - name: "transaction_status"
      expr: transaction_status
      comment: "Current status of the premium transaction: Posted, Pending, Reversed, Voided"
    - name: "endorsement_type"
      expr: endorsement_type
      comment: "Type of policy endorsement when transaction_type is Endorsement"
    - name: "earning_method"
      expr: earning_method
      comment: "Method used to earn premium: Pro-rata, Short-rate, Daily, Custom"
    - name: "transaction_year"
      expr: YEAR(transaction_date)
      comment: "Calendar year of the premium transaction"
    - name: "transaction_quarter"
      expr: CONCAT('Q', QUARTER(transaction_date), '-', YEAR(transaction_date))
      comment: "Calendar quarter of the premium transaction"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Calendar month of the premium transaction"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Calendar year of the transaction effective date"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Calendar month of the transaction effective date"
    - name: "state_code"
      expr: state_code
      comment: "State or jurisdiction code where the premium applies"
    - name: "payment_plan_code"
      expr: payment_plan_code
      comment: "Payment plan code associated with the premium transaction"
    - name: "audit_basis"
      expr: audit_basis
      comment: "Basis for premium audit: Payroll, Sales, Units, None"
    - name: "direct_billed_indicator"
      expr: direct_billed_indicator
      comment: "True if premium is billed directly by the insurer, False if agency-billed"
    - name: "reversal_indicator"
      expr: reversal_indicator
      comment: "True if this transaction reverses a prior premium transaction"
  measures:
    - name: "total_gross_written_premium"
      expr: SUM(CAST(gross_written_premium AS DOUBLE))
      comment: "Total gross written premium before cessions and commissions, the primary top-line premium measure"
    - name: "total_net_written_premium"
      expr: SUM(CAST(net_written_premium AS DOUBLE))
      comment: "Total net written premium after cessions, the retained premium measure for profitability analysis"
    - name: "total_earned_premium"
      expr: SUM(CAST(earned_premium AS DOUBLE))
      comment: "Total earned premium recognized in the accounting period, the revenue measure for P&L"
    - name: "total_unearned_premium"
      expr: SUM(CAST(unearned_premium AS DOUBLE))
      comment: "Total unearned premium liability representing future coverage obligations"
    - name: "total_return_premium"
      expr: SUM(CAST(return_premium AS DOUBLE))
      comment: "Total return premium from cancellations, endorsements, and audits"
    - name: "total_ceded_written_premium"
      expr: SUM(CAST(ceded_written_premium AS DOUBLE))
      comment: "Total premium ceded to reinsurers, measuring reinsurance utilization"
    - name: "avg_gross_written_premium"
      expr: AVG(CAST(gross_written_premium AS DOUBLE))
      comment: "Average gross written premium per transaction, indicating typical policy size"
    - name: "avg_net_written_premium"
      expr: AVG(CAST(net_written_premium AS DOUBLE))
      comment: "Average net written premium per transaction after cessions"
    - name: "total_exposure_amount"
      expr: SUM(CAST(exposure_amount AS DOUBLE))
      comment: "Total exposure amount used as rating basis for premium calculation"
    - name: "avg_rate"
      expr: AVG(CAST(rate AS DOUBLE))
      comment: "Average premium rate applied across transactions"
    - name: "total_days_in_force"
      expr: SUM(CAST(days_in_force AS DOUBLE))
      comment: "Total days of coverage in force across all transactions"
    - name: "avg_days_in_force"
      expr: AVG(CAST(days_in_force AS DOUBLE))
      comment: "Average days of coverage in force per transaction"
    - name: "avg_pro_rata_factor"
      expr: AVG(CAST(pro_rata_factor AS DOUBLE))
      comment: "Average pro-rata factor applied for mid-term adjustments"
    - name: "transaction_count"
      expr: COUNT(1)
      comment: "Total number of premium transactions, measuring transaction volume"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct count of policies with premium transactions, measuring policy volume"
    - name: "distinct_policy_term_count"
      expr: COUNT(DISTINCT policy_term_id)
      comment: "Distinct count of policy terms with premium transactions"
    - name: "distinct_coverage_count"
      expr: COUNT(DISTINCT coverage_id)
      comment: "Distinct count of coverages with premium transactions"
    - name: "distinct_insured_risk_count"
      expr: COUNT(DISTINCT insured_risk_id)
      comment: "Distinct count of insured risks with premium transactions"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_charge`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Detailed premium charge metrics capturing rating elements, commissions, and cessions at the charge level. Grain: one row per charge per premium transaction."
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`charge`"
  dimensions:
    - name: "charge_type"
      expr: charge_type
      comment: "Type of charge: Base Premium, Surcharge, Discount, Credit, Adjustment"
    - name: "charge_status"
      expr: charge_status
      comment: "Status of the charge: Active, Reversed, Voided, Pending"
    - name: "charge_category"
      expr: charge_category
      comment: "Charge charge_category for grouping and reporting"
    - name: "rating_element_code"
      expr: rating_element_code
      comment: "Code identifying the rating element or factor applied"
    - name: "rating_element_description"
      expr: rating_element_description
      comment: "Description of the rating element or factor"
    - name: "statutory_line_code"
      expr: statutory_line_code
      comment: "Statutory line of business code for regulatory reporting"
    - name: "gl_account_code"
      expr: gl_account_code
      comment: "General ledger account code for financial posting"
    - name: "is_ceded"
      expr: is_ceded
      comment: "True if the charge is ceded to reinsurance"
    - name: "is_commissionable"
      expr: is_commissionable
      comment: "True if the charge is eligible for producer commission"
    - name: "is_earned"
      expr: is_earned
      comment: "True if the charge has been earned in the accounting period"
    - name: "is_minimum_premium"
      expr: is_minimum_premium
      comment: "True if the charge represents a minimum premium adjustment"
    - name: "is_prorated"
      expr: is_prorated
      comment: "True if the charge has been prorated for mid-term changes"
    - name: "reversal_reason_code"
      expr: reversal_reason_code
      comment: "Code indicating the reason for charge reversal"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Calendar year of the charge effective date"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Calendar month of the charge effective date"
  measures:
    - name: "total_charge_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total charge amount before cessions and commissions, the gross charge measure"
    - name: "total_net_charge_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net charge amount after cessions and commissions, the retained charge measure"
    - name: "total_ceded_amount"
      expr: SUM(CAST(ceded_amount AS DOUBLE))
      comment: "Total amount ceded to reinsurers at the charge level"
    - name: "total_earned_amount"
      expr: SUM(CAST(earned_amount AS DOUBLE))
      comment: "Total earned charge amount recognized in the accounting period"
    - name: "total_unearned_amount"
      expr: SUM(CAST(unearned_amount AS DOUBLE))
      comment: "Total unearned charge amount representing future coverage obligations"
    - name: "total_commission_amount"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total commission amount paid to producers on charges"
    - name: "total_basis_amount"
      expr: SUM(CAST(basis_amount AS DOUBLE))
      comment: "Total basis amount used for charge calculation"
    - name: "avg_charge_rate"
      expr: AVG(CAST(rate AS DOUBLE))
      comment: "Average rate applied across charges"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average commission rate applied to charges"
    - name: "avg_proration_factor"
      expr: AVG(CAST(proration_factor AS DOUBLE))
      comment: "Average proration factor applied for mid-term charge adjustments"
    - name: "charge_count"
      expr: COUNT(1)
      comment: "Total number of charges, measuring charge transaction volume"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct count of policies with charges"
    - name: "distinct_coverage_count"
      expr: COUNT(DISTINCT coverage_id)
      comment: "Distinct count of coverages with charges"
    - name: "distinct_rating_element_count"
      expr: COUNT(DISTINCT rating_element_code)
      comment: "Distinct count of rating elements applied across charges"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_commission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Producer commission metrics tracking commission amounts, rates, splits, and payment status across policies and producers. Grain: one row per commission transaction."
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`commission`"
  dimensions:
    - name: "commission_type"
      expr: commission_type
      comment: "Type of commission: New Business, Renewal, Endorsement, Contingent, Override, Bonus"
    - name: "commission_status"
      expr: commission_status
      comment: "Status of the commission: Calculated, Approved, Paid, Reversed, Disputed"
    - name: "payment_status"
      expr: payment_status
      comment: "Payment status: Pending, Paid, Withheld, Charged Back"
    - name: "payment_method"
      expr: payment_method
      comment: "Method of commission payment: Direct Deposit, Check, Wire Transfer, Offset"
    - name: "basis"
      expr: basis
      comment: "Basis for commission calculation: Written Premium, Earned Premium, Net Premium, Gross Premium"
    - name: "calculation_method"
      expr: calculation_method
      comment: "Method used to calculate commission: Flat Rate, Tiered, Sliding Scale, Custom"
    - name: "tier_level"
      expr: tier_level
      comment: "Commission tier level when using tiered calculation method"
    - name: "policy_transaction_type"
      expr: policy_transaction_type
      comment: "Type of policy transaction triggering the commission"
    - name: "chargeback_indicator"
      expr: chargeback_indicator
      comment: "True if this commission is a chargeback reversing a prior commission"
    - name: "chargeback_reason"
      expr: chargeback_reason
      comment: "Reason for commission chargeback: Cancellation, Non-payment, Policy Void"
    - name: "contingent_indicator"
      expr: contingent_indicator
      comment: "True if this is a contingent commission based on performance or profitability"
    - name: "override_indicator"
      expr: override_indicator
      comment: "True if this commission rate was manually overridden from the standard schedule"
    - name: "reversal_indicator"
      expr: reversal_indicator
      comment: "True if this commission reverses a prior commission transaction"
    - name: "transaction_year"
      expr: YEAR(transaction_date)
      comment: "Calendar year of the commission transaction"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Calendar month of the commission transaction"
    - name: "earned_year"
      expr: YEAR(earned_date)
      comment: "Calendar year when the commission was earned"
    - name: "payment_year"
      expr: YEAR(payment_date)
      comment: "Calendar year when the commission was paid"
    - name: "gl_account_code"
      expr: gl_account_code
      comment: "General ledger account code for commission expense posting"
  measures:
    - name: "total_commission_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total commission amount before tax withholding, the primary producer compensation measure"
    - name: "total_net_payable_amount"
      expr: SUM(CAST(net_payable_amount AS DOUBLE))
      comment: "Total net commission payable after tax withholding, the actual disbursement amount"
    - name: "total_basis_amount"
      expr: SUM(CAST(basis_amount AS DOUBLE))
      comment: "Total premium basis amount used for commission calculation"
    - name: "total_tax_withholding_amount"
      expr: SUM(CAST(tax_withholding_amount AS DOUBLE))
      comment: "Total tax withholding amount deducted from commission payments"
    - name: "avg_commission_rate"
      expr: AVG(CAST(rate AS DOUBLE))
      comment: "Average commission rate applied across transactions"
    - name: "avg_split_percentage"
      expr: AVG(CAST(split_percentage AS DOUBLE))
      comment: "Average split percentage when commission is shared among multiple producers"
    - name: "commission_count"
      expr: COUNT(1)
      comment: "Total number of commission transactions, measuring commission activity volume"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct count of policies generating commissions"
    - name: "distinct_producer_count"
      expr: COUNT(DISTINCT payee_party_id)
      comment: "Distinct count of producers receiving commissions, measuring producer engagement"
    - name: "distinct_agency_count"
      expr: COUNT(DISTINCT agency_id)
      comment: "Distinct count of agencies receiving commissions"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_policy_fee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy fee metrics tracking non-premium charges such as policy fees, installment fees, and service charges. Grain: one row per fee per policy transaction."
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`policy_fee`"
  dimensions:
    - name: "fee_type"
      expr: fee_type
      comment: "Type of fee: Policy Fee, Installment Fee, Service Fee, Late Fee, Reinstatement Fee"
    - name: "fee_status"
      expr: fee_status
      comment: "Status of the fee: Active, Waived, Reversed, Refunded"
    - name: "fee_code"
      expr: fee_code
      comment: "Code identifying the specific fee"
    - name: "fee_description"
      expr: fee_description
      comment: "Description of the fee"
    - name: "fee_basis"
      expr: fee_basis
      comment: "Basis for fee calculation: Flat, Per Policy, Per Installment, Percentage"
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of policy transaction triggering the fee"
    - name: "billing_method"
      expr: billing_method
      comment: "Billing method: Direct Bill, Agency Bill, Mortgagee Bill"
    - name: "is_taxable"
      expr: is_taxable
      comment: "True if the fee is subject to tax"
    - name: "is_refundable"
      expr: is_refundable
      comment: "True if the fee is refundable upon policy cancellation"
    - name: "is_commission_bearing"
      expr: is_commission_bearing
      comment: "True if the fee is included in the commission basis"
    - name: "waived_flag"
      expr: waived_flag
      comment: "True if the fee was waived"
    - name: "waiver_reason_code"
      expr: waiver_reason_code
      comment: "Code indicating the reason for fee waiver"
    - name: "reversal_reason_code"
      expr: reversal_reason_code
      comment: "Code indicating the reason for fee reversal"
    - name: "transaction_year"
      expr: YEAR(transaction_effective_date)
      comment: "Calendar year of the fee transaction effective date"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_effective_date)
      comment: "Calendar month of the fee transaction effective date"
    - name: "statutory_line_code"
      expr: statutory_line_code
      comment: "Statutory line of business code for regulatory reporting"
    - name: "gl_account_code"
      expr: gl_account_code
      comment: "General ledger account code for fee posting"
  measures:
    - name: "total_fee_amount"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total policy fee amount, measuring non-premium revenue"
    - name: "avg_fee_amount"
      expr: AVG(CAST(fee_amount AS DOUBLE))
      comment: "Average fee amount per transaction"
    - name: "total_fee_quantity"
      expr: SUM(CAST(fee_quantity AS DOUBLE))
      comment: "Total fee quantity when fees are charged per unit"
    - name: "avg_fee_rate"
      expr: AVG(CAST(fee_rate AS DOUBLE))
      comment: "Average fee rate applied across transactions"
    - name: "fee_count"
      expr: COUNT(1)
      comment: "Total number of fee transactions, measuring fee activity volume"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct count of policies with fees"
    - name: "distinct_fee_code_count"
      expr: COUNT(DISTINCT fee_code)
      comment: "Distinct count of fee codes applied"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`premium_tax_levy`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tax and levy metrics tracking premium taxes, surplus lines taxes, stamping fees, and other regulatory levies. Grain: one row per tax levy per policy transaction."
  source: "`vibe_pc_insurance_blog_v499`.`premium`.`tax_levy`"
  dimensions:
    - name: "tax_type_code"
      expr: tax_type_code
      comment: "Code identifying the type of tax or levy: Premium Tax, Surplus Lines Tax, Stamping Fee, Fire Marshal Tax"
    - name: "tax_reporting_category_code"
      expr: tax_reporting_category_code
      comment: "Category code for tax reporting and remittance"
    - name: "tax_calculation_method_code"
      expr: tax_calculation_method_code
      comment: "Method used to calculate the tax: Rate-based, Flat, Tiered"
    - name: "tax_authority_name"
      expr: tax_authority_name
      comment: "Name of the tax authority receiving the levy"
    - name: "stamping_office_code"
      expr: stamping_office_code
      comment: "Code identifying the surplus lines stamping office"
    - name: "surplus_lines_flag"
      expr: surplus_lines_flag
      comment: "True if this is a surplus lines tax"
    - name: "tax_exemption_flag"
      expr: tax_exemption_flag
      comment: "True if the policy is exempt from this tax"
    - name: "tax_exemption_reason_code"
      expr: tax_exemption_reason_code
      comment: "Code indicating the reason for tax exemption"
    - name: "tax_adjustment_flag"
      expr: tax_adjustment_flag
      comment: "True if this is a tax adjustment transaction"
    - name: "tax_remittance_status"
      expr: tax_remittance_status
      comment: "Status of tax remittance: Pending, Remitted, Overdue, Disputed"
    - name: "policy_transaction_type_code"
      expr: policy_transaction_type_code
      comment: "Type of policy transaction triggering the tax"
    - name: "naic_company_code"
      expr: naic_company_code
      comment: "NAIC company code for regulatory reporting"
    - name: "tax_effective_year"
      expr: YEAR(tax_effective_date)
      comment: "Calendar year of the tax effective date"
    - name: "tax_effective_month"
      expr: DATE_TRUNC('MONTH', tax_effective_date)
      comment: "Calendar month of the tax effective date"
    - name: "remittance_year"
      expr: YEAR(tax_remittance_date)
      comment: "Calendar year when the tax was remitted"
  measures:
    - name: "total_tax_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total tax and levy amount, measuring regulatory tax expense"
    - name: "total_taxable_premium_amount"
      expr: SUM(CAST(taxable_premium_amount AS DOUBLE))
      comment: "Total taxable premium basis for tax calculation"
    - name: "avg_tax_rate"
      expr: AVG(CAST(tax_rate AS DOUBLE))
      comment: "Average tax rate applied across transactions"
    - name: "tax_levy_count"
      expr: COUNT(1)
      comment: "Total number of tax levy transactions, measuring tax activity volume"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Distinct count of policies with tax levies"
    - name: "distinct_tax_type_count"
      expr: COUNT(DISTINCT tax_type_code)
      comment: "Distinct count of tax types applied"
    - name: "distinct_tax_authority_count"
      expr: COUNT(DISTINCT tax_authority_name)
      comment: "Distinct count of tax authorities receiving levies"
$$;