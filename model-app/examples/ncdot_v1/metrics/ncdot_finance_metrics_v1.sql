-- Metric views for domain: finance | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_accounts_payable_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key accounts payable metrics tracking invoice processing efficiency, payment performance, vendor compliance, and cash flow management. Supports treasury operations, vendor relationship management, and working capital optimization."
  source: "`feip_eastus_03`.`finance`.`accounts_payable_invoice`"
  dimensions:
    - name: "invoice_type"
      expr: invoice_type
      comment: "Classification of invoice by purpose and processing requirements"
    - name: "payment_status"
      expr: payment_status
      comment: "Current payment status of the invoice"
    - name: "invoice_status"
      expr: invoice_status
      comment: "Current processing status in accounts payable workflow"
    - name: "approval_status"
      expr: approval_status
      comment: "Current approval workflow status"
    - name: "payment_method"
      expr: payment_method
      comment: "Method by which payment will be made to vendor"
    - name: "three_way_match_status"
      expr: three_way_match_status
      comment: "Status of three-way matching between PO, goods receipt, and invoice"
    - name: "vendor_number"
      expr: vendor_number
      comment: "Unique identifier for the vendor in SAP"
    - name: "cost_center"
      expr: cost_center
      comment: "Organizational cost center responsible for expenditure"
    - name: "functional_area"
      expr: functional_area
      comment: "Functional classification for governmental reporting"
    - name: "program_code"
      expr: program_code
      comment: "Program identifier for tracking by strategic initiative"
    - name: "fiscal_period"
      expr: fiscal_period
      comment: "Fiscal period within the fiscal year"
    - name: "company_code"
      expr: company_code
      comment: "SAP company code representing legal entity"
    - name: "federal_funding_source"
      expr: federal_funding_source
      comment: "Federal funding program or grant source"
    - name: "hub_vendor_indicator"
      expr: hub_vendor_indicator
      comment: "Whether vendor is certified as Historically Underutilized Business"
    - name: "dispute_indicator"
      expr: dispute_indicator
      comment: "Whether invoice is under dispute"
    - name: "invoice_date_year"
      expr: YEAR(invoice_date)
      comment: "Year when invoice was issued by vendor"
    - name: "invoice_date_month"
      expr: DATE_TRUNC('MONTH', invoice_date)
      comment: "Month when invoice was issued by vendor"
    - name: "payment_date_month"
      expr: DATE_TRUNC('MONTH', payment_date)
      comment: "Month when invoice was paid"
    - name: "posting_date_month"
      expr: DATE_TRUNC('MONTH', posting_date)
      comment: "Month when invoice was posted to general ledger"
  measures:
    - name: "total_invoice_amount"
      expr: SUM(CAST(invoice_amount AS DOUBLE))
      comment: "Total invoice amount in invoice currency - key metric for accounts payable volume and cash flow forecasting"
    - name: "total_functional_amount"
      expr: SUM(CAST(functional_amount AS DOUBLE))
      comment: "Total invoice amount in functional currency (USD) - standardized metric for financial reporting and budget tracking"
    - name: "total_net_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net invoice amount after discounts and adjustments - actual payment obligation metric"
    - name: "total_tax_amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax amount across invoices - critical for tax compliance and reporting"
    - name: "total_discount_amount"
      expr: SUM(CAST(discount_amount AS DOUBLE))
      comment: "Total early payment discount amount available - measures potential savings from prompt payment"
    - name: "total_retainage_amount"
      expr: SUM(CAST(retainage_amount AS DOUBLE))
      comment: "Total amount withheld as retainage per contract terms - tracks contractor holdbacks for construction projects"
    - name: "total_dbe_participation_amount"
      expr: SUM(CAST(dbe_participation_amount AS DOUBLE))
      comment: "Total dollar amount attributable to DBE vendor participation - critical for federal compliance and diversity goals"
    - name: "avg_invoice_amount"
      expr: AVG(CAST(invoice_amount AS DOUBLE))
      comment: "Average invoice amount - indicates typical transaction size and helps identify outliers"
    - name: "avg_days_to_payment"
      expr: AVG(CAST(DATEDIFF(payment_date, invoice_date) AS DOUBLE))
      comment: "Average days from invoice date to payment date - key metric for payment cycle efficiency and vendor satisfaction"
    - name: "avg_days_to_approval"
      expr: AVG(CAST(DATEDIFF(approved_date, invoice_received_date) AS DOUBLE))
      comment: "Average days from invoice receipt to approval - measures internal approval workflow efficiency"
    - name: "discount_capture_rate"
      expr: ROUND(100.0 * SUM(CAST(discount_amount AS DOUBLE)) / NULLIF(SUM(CAST(invoice_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of available discounts captured through early payment - measures working capital optimization effectiveness"
    - name: "three_way_match_exception_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN three_way_match_status = 'Exception' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of invoices with three-way match exceptions - indicates procurement and receiving process quality"
    - name: "dispute_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN dispute_indicator = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of invoices under dispute - measures vendor relationship quality and invoice accuracy"
    - name: "on_time_payment_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN payment_date <= due_date THEN 1 END) / NULLIF(COUNT(CASE WHEN payment_date IS NOT NULL THEN 1 END), 0), 2)
      comment: "Percentage of invoices paid on or before due date - critical metric for vendor relations and payment performance"
    - name: "hub_vendor_spend_percentage"
      expr: ROUND(100.0 * SUM(CASE WHEN hub_vendor_indicator = true THEN CAST(functional_amount AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(functional_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of spend with HUB-certified vendors - tracks diversity procurement goals and state compliance"
    - name: "dbe_participation_percentage"
      expr: ROUND(100.0 * SUM(CAST(dbe_participation_amount AS DOUBLE)) / NULLIF(SUM(CAST(functional_amount AS DOUBLE)), 0), 2)
      comment: "DBE participation as percentage of total spend - federal compliance metric for disadvantaged business enterprise goals"
    - name: "invoice_count"
      expr: COUNT(1)
      comment: "Total number of invoices - baseline volume metric for workload planning and process capacity"
    - name: "unique_vendor_count"
      expr: COUNT(DISTINCT vendor_number)
      comment: "Number of unique vendors with invoices - measures vendor base diversity and concentration risk"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_accounts_receivable_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key accounts receivable metrics tracking revenue collection, aging, write-offs, and customer payment behavior. Supports cash flow management, collections strategy, and revenue assurance."
  source: "`feip_eastus_03`.`finance`.`accounts_receivable_invoice`"
  dimensions:
    - name: "invoice_type"
      expr: invoice_type
      comment: "Classification of invoice by nature of receivable"
    - name: "payment_status"
      expr: payment_status
      comment: "Current payment status of the invoice"
    - name: "aging_category"
      expr: aging_category
      comment: "Aging bucket classification based on days past due"
    - name: "collection_status"
      expr: collection_status
      comment: "Status of collection efforts for overdue invoices"
    - name: "billing_division"
      expr: billing_division
      comment: "NCDOT division responsible for issuing invoice"
    - name: "program_code"
      expr: program_code
      comment: "Program code identifying specific program or initiative"
    - name: "payment_method"
      expr: payment_method
      comment: "Method by which payment is expected or received"
    - name: "dispute_flag"
      expr: dispute_flag
      comment: "Whether invoice is currently under dispute by customer"
    - name: "invoice_date_year"
      expr: YEAR(invoice_date)
      comment: "Year when invoice was issued"
    - name: "invoice_date_month"
      expr: DATE_TRUNC('MONTH', invoice_date)
      comment: "Month when invoice was issued"
    - name: "due_date_month"
      expr: DATE_TRUNC('MONTH', due_date)
      comment: "Month when payment is due"
  measures:
    - name: "total_invoice_amount"
      expr: SUM(CAST(invoice_amount AS DOUBLE))
      comment: "Total amount billed before adjustments - measures gross revenue billed"
    - name: "total_net_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net amount due after taxes and discounts - actual revenue expected"
    - name: "total_outstanding_balance"
      expr: SUM(CAST(outstanding_balance AS DOUBLE))
      comment: "Total remaining unpaid balance - critical metric for cash flow forecasting and working capital management"
    - name: "total_write_off_amount"
      expr: SUM(CAST(write_off_amount AS DOUBLE))
      comment: "Total amount written off as uncollectible - measures bad debt expense and collection effectiveness"
    - name: "total_adjustment_amount"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total adjustments made to invoices after issuance - indicates billing accuracy and dispute resolution"
    - name: "avg_invoice_amount"
      expr: AVG(CAST(invoice_amount AS DOUBLE))
      comment: "Average invoice amount - indicates typical transaction size"
    - name: "avg_days_past_due"
      expr: AVG(CAST(days_past_due AS DOUBLE))
      comment: "Average days invoices are overdue - key metric for collections effectiveness and customer payment behavior"
    - name: "collection_rate"
      expr: ROUND(100.0 * (SUM(CAST(invoice_amount AS DOUBLE)) - SUM(CAST(outstanding_balance AS DOUBLE))) / NULLIF(SUM(CAST(invoice_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of billed amount collected - measures revenue realization and collections effectiveness"
    - name: "write_off_rate"
      expr: ROUND(100.0 * SUM(CAST(write_off_amount AS DOUBLE)) / NULLIF(SUM(CAST(invoice_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of billed amount written off - measures bad debt expense as percentage of revenue"
    - name: "dispute_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN dispute_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of invoices under dispute - indicates billing accuracy and customer satisfaction"
    - name: "overdue_invoice_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN days_past_due > 0 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of invoices past due date - measures payment timeliness and collection risk"
    - name: "avg_days_to_payment"
      expr: AVG(CAST(DATEDIFF(last_payment_date, invoice_date) AS DOUBLE))
      comment: "Average days from invoice to payment - measures customer payment cycle and cash conversion"
    - name: "invoice_count"
      expr: COUNT(1)
      comment: "Total number of invoices issued - baseline volume metric"
    - name: "overdue_invoice_count"
      expr: COUNT(CASE WHEN days_past_due > 0 THEN 1 END)
      comment: "Number of invoices past due - workload metric for collections team"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_budget`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic budget performance metrics tracking appropriations, expenditures, fund utilization, and budget variance. Supports fiscal planning, legislative reporting, and resource allocation decisions."
  source: "`feip_eastus_03`.`finance`.`budget`"
  dimensions:
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year for which budget is approved"
    - name: "fiscal_year_type"
      expr: fiscal_year_type
      comment: "State Fiscal Year (SFY) or Federal Fiscal Year (FFY)"
    - name: "budget_type"
      expr: type
      comment: "Classification by type: operating, capital, grant, federal, state"
    - name: "budget_status"
      expr: status
      comment: "Current status in lifecycle: draft, proposed, approved, amended, closed"
    - name: "fund_code"
      expr: fund_code
      comment: "Code identifying governmental fund"
    - name: "fund_name"
      expr: fund_name
      comment: "Descriptive name of governmental fund"
    - name: "program_code"
      expr: program_code
      comment: "Code identifying program or functional area"
    - name: "program_name"
      expr: program_name
      comment: "Descriptive name of program or functional area"
    - name: "division_code"
      expr: division_code
      comment: "Code identifying NCDOT division responsible for budget"
    - name: "division_name"
      expr: division_name
      comment: "Full name of NCDOT division"
    - name: "functional_area"
      expr: functional_area
      comment: "Functional classification of budget"
    - name: "multi_year_flag"
      expr: multi_year_flag
      comment: "Whether budget spans multiple fiscal years"
  measures:
    - name: "total_appropriation_amount"
      expr: SUM(CAST(total_appropriation_amount AS DOUBLE))
      comment: "Total authorized budget appropriation - maximum amount that can be obligated and expended, critical for fiscal control"
    - name: "total_revenue_amount"
      expr: SUM(CAST(total_revenue_amount AS DOUBLE))
      comment: "Total projected revenue - measures funding sources and revenue expectations"
    - name: "total_expenditure_amount"
      expr: SUM(CAST(total_expenditure_amount AS DOUBLE))
      comment: "Total budgeted expenditure across all programs - planned spending level"
    - name: "total_federal_funding"
      expr: SUM(CAST(federal_funding_amount AS DOUBLE))
      comment: "Total federal funding portion - tracks federal grant and aid dependency"
    - name: "total_state_funding"
      expr: SUM(CAST(state_funding_amount AS DOUBLE))
      comment: "Total state appropriation portion - tracks state funding commitment"
    - name: "total_local_funding"
      expr: SUM(CAST(local_funding_amount AS DOUBLE))
      comment: "Total local government funding portion - tracks local match and contributions"
    - name: "total_encumbrance_amount"
      expr: SUM(CAST(encumbrance_amount AS DOUBLE))
      comment: "Total budget committed through obligations - measures committed but unspent funds"
    - name: "total_expended_amount"
      expr: SUM(CAST(expended_amount AS DOUBLE))
      comment: "Total budget actually expended - measures actual spending to date"
    - name: "total_available_balance"
      expr: SUM(CAST(available_balance_amount AS DOUBLE))
      comment: "Total remaining budget available for obligation - critical metric for spending authority and fiscal capacity"
    - name: "budget_utilization_rate"
      expr: ROUND(100.0 * SUM(CAST(expended_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_appropriation_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of appropriation expended - key metric for budget execution performance and spending pace"
    - name: "encumbrance_rate"
      expr: ROUND(100.0 * SUM(CAST(encumbrance_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_appropriation_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of appropriation encumbered - measures commitment level and pipeline of spending"
    - name: "available_balance_rate"
      expr: ROUND(100.0 * SUM(CAST(available_balance_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_appropriation_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of appropriation still available - measures remaining fiscal capacity"
    - name: "federal_funding_percentage"
      expr: ROUND(100.0 * SUM(CAST(federal_funding_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_appropriation_amount AS DOUBLE)), 0), 2)
      comment: "Federal funding as percentage of total budget - measures federal dependency and grant leverage"
    - name: "state_funding_percentage"
      expr: ROUND(100.0 * SUM(CAST(state_funding_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_appropriation_amount AS DOUBLE)), 0), 2)
      comment: "State funding as percentage of total budget - measures state investment level"
    - name: "budget_count"
      expr: COUNT(1)
      comment: "Number of budget records - baseline metric for budget portfolio size"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_budget_line`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Detailed budget line item performance metrics tracking allocations, adjustments, expenditures, and variance at granular level. Supports program managers, cost center owners, and budget analysts in execution monitoring."
  source: "`feip_eastus_03`.`finance`.`budget_line`"
  dimensions:
    - name: "program_code"
      expr: program_code
      comment: "Code identifying program or initiative"
    - name: "program_name"
      expr: program_name
      comment: "Descriptive name of program"
    - name: "division_code"
      expr: division_code
      comment: "Code identifying NCDOT division"
    - name: "division_name"
      expr: division_name
      comment: "Full name of NCDOT division"
    - name: "budget_type"
      expr: budget_type
      comment: "Classification by type: Operating, Capital, Grant, Federal, State"
    - name: "budget_category"
      expr: budget_category
      comment: "Expenditure category: Personnel, Equipment, Supplies, Contractual Services"
    - name: "budget_status"
      expr: budget_status
      comment: "Current status: Draft, Submitted, Approved, Active, Closed"
    - name: "approval_status"
      expr: approval_status
      comment: "Approval status within budget approval workflow"
    - name: "federal_funding_indicator"
      expr: federal_funding_indicator
      comment: "Whether budget line includes federal funding"
    - name: "account_category"
      expr: account_category
      comment: "High-level GL account classification"
    - name: "functional_area_code"
      expr: functional_area_code
      comment: "Code representing functional area or business segment"
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county associated with budget line"
  measures:
    - name: "total_original_budget"
      expr: SUM(CAST(original_budget_amount AS DOUBLE))
      comment: "Total initial budget allocated at beginning of fiscal year - baseline for variance analysis"
    - name: "total_revised_budget"
      expr: SUM(CAST(revised_budget_amount AS DOUBLE))
      comment: "Total current revised budget after adjustments - active budget amount for execution"
    - name: "total_adjustment_amount"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total net adjustments to original budget - measures budget flexibility and reallocation activity"
    - name: "total_encumbrance_amount"
      expr: SUM(CAST(encumbrance_amount AS DOUBLE))
      comment: "Total budget committed through obligations - measures pipeline of spending"
    - name: "total_actual_expenditure"
      expr: SUM(CAST(actual_expenditure_amount AS DOUBLE))
      comment: "Total actual expenditure to date - measures spending execution"
    - name: "total_available_balance"
      expr: SUM(CAST(available_balance_amount AS DOUBLE))
      comment: "Total remaining budget available - critical for spending authority and fiscal capacity"
    - name: "avg_budget_line_amount"
      expr: AVG(CAST(revised_budget_amount AS DOUBLE))
      comment: "Average budget line allocation - indicates typical allocation size"
    - name: "budget_execution_rate"
      expr: ROUND(100.0 * SUM(CAST(actual_expenditure_amount AS DOUBLE)) / NULLIF(SUM(CAST(revised_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of revised budget expended - key metric for spending pace and execution performance"
    - name: "encumbrance_rate"
      expr: ROUND(100.0 * SUM(CAST(encumbrance_amount AS DOUBLE)) / NULLIF(SUM(CAST(revised_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of revised budget encumbered - measures commitment level"
    - name: "available_balance_rate"
      expr: ROUND(100.0 * SUM(CAST(available_balance_amount AS DOUBLE)) / NULLIF(SUM(CAST(revised_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of revised budget still available - measures remaining fiscal capacity"
    - name: "budget_variance_amount"
      expr: SUM(CAST(revised_budget_amount AS DOUBLE)) - SUM(CAST(original_budget_amount AS DOUBLE))
      comment: "Total variance between revised and original budget - measures budget change magnitude"
    - name: "budget_variance_rate"
      expr: ROUND(100.0 * (SUM(CAST(revised_budget_amount AS DOUBLE)) - SUM(CAST(original_budget_amount AS DOUBLE))) / NULLIF(SUM(CAST(original_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage variance between revised and original budget - measures budget stability and change rate"
    - name: "budget_line_count"
      expr: COUNT(1)
      comment: "Number of budget line items - baseline metric for budget detail granularity"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payment transaction metrics tracking disbursements, processing efficiency, payment methods, and cash management. Supports treasury operations, vendor relations, and working capital optimization."
  source: "`feip_eastus_03`.`finance`.`payment`"
  dimensions:
    - name: "payment_method"
      expr: method
      comment: "Financial instrument or method used to make payment"
    - name: "payment_channel"
      expr: channel
      comment: "Interface or channel through which payment was submitted"
    - name: "payment_status"
      expr: status
      comment: "Current processing status of payment transaction"
    - name: "payment_type"
      expr: type
      comment: "Classification by business purpose or transaction category"
    - name: "payer_type"
      expr: payer_type
      comment: "Classification of entity making payment"
    - name: "payee_type"
      expr: payee_type
      comment: "Classification of entity receiving payment"
    - name: "federal_funding_indicator"
      expr: federal_funding_indicator
      comment: "Whether payment is funded by federal sources"
    - name: "dbe_indicator"
      expr: dbe_indicator
      comment: "Whether payment is made to DBE-certified vendor"
    - name: "hub_indicator"
      expr: hub_indicator
      comment: "Whether payment is made to HUB-certified vendor"
    - name: "payment_date_year"
      expr: YEAR(date)
      comment: "Year when payment was processed"
    - name: "payment_date_month"
      expr: DATE_TRUNC('MONTH', date)
      comment: "Month when payment was processed"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code associated with payment"
  measures:
    - name: "total_payment_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total monetary amount of payments - critical metric for cash disbursement and liquidity management"
    - name: "total_net_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net payment amount after fees and adjustments - actual cash outflow"
    - name: "total_processing_fee"
      expr: SUM(CAST(processing_fee_amount AS DOUBLE))
      comment: "Total processing fees charged - measures payment processing cost"
    - name: "total_discount_amount"
      expr: SUM(CAST(discount_amount AS DOUBLE))
      comment: "Total discount amount applied - measures savings from early payment"
    - name: "total_tax_amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax amount in payments - tracks tax withholding and remittance"
    - name: "total_refund_amount"
      expr: SUM(CAST(refund_amount AS DOUBLE))
      comment: "Total amount refunded - measures payment reversals and adjustments"
    - name: "avg_payment_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average payment amount - indicates typical transaction size"
    - name: "avg_processing_fee"
      expr: AVG(CAST(processing_fee_amount AS DOUBLE))
      comment: "Average processing fee per payment - measures per-transaction processing cost"
    - name: "processing_fee_rate"
      expr: ROUND(100.0 * SUM(CAST(processing_fee_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Processing fees as percentage of payment amount - measures payment processing efficiency and cost"
    - name: "discount_capture_rate"
      expr: ROUND(100.0 * SUM(CAST(discount_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Discounts as percentage of payment amount - measures early payment savings realization"
    - name: "refund_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN refund_amount > 0 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of payments with refunds - indicates payment accuracy and reversal frequency"
    - name: "dbe_payment_percentage"
      expr: ROUND(100.0 * SUM(CASE WHEN dbe_indicator = true THEN CAST(amount AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "DBE vendor payments as percentage of total - tracks disadvantaged business enterprise spending goals"
    - name: "hub_payment_percentage"
      expr: ROUND(100.0 * SUM(CASE WHEN hub_indicator = true THEN CAST(amount AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "HUB vendor payments as percentage of total - tracks historically underutilized business spending goals"
    - name: "payment_count"
      expr: COUNT(1)
      comment: "Total number of payment transactions - baseline volume metric for treasury workload"
    - name: "unique_payee_count"
      expr: COUNT(DISTINCT payee_account_number)
      comment: "Number of unique payees - measures vendor/payee diversity"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_fund`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fund performance and utilization metrics tracking authorizations, obligations, expenditures, and fund balance. Supports legislative reporting, grant compliance, and fiscal stewardship."
  source: "`feip_eastus_03`.`finance`.`fund`"
  dimensions:
    - name: "fund_type"
      expr: type
      comment: "Classification according to governmental accounting standards"
    - name: "fund_source_type"
      expr: source_type
      comment: "Primary source: federal grants, state appropriations, special revenues"
    - name: "fund_status"
      expr: status
      comment: "Current operational status: available, closed, pending approval"
    - name: "federal_program_name"
      expr: federal_program_name
      comment: "Name of federal program providing grant funding"
    - name: "funding_agency"
      expr: funding_agency
      comment: "Federal, state, or local agency providing funding"
    - name: "administering_division"
      expr: administering_division
      comment: "NCDOT division responsible for administering fund"
    - name: "match_requirement_indicator"
      expr: match_requirement_indicator
      comment: "Whether fund requires matching funds from state or local sources"
    - name: "reimbursable_indicator"
      expr: reimbursable_indicator
      comment: "Whether fund operates on reimbursement basis"
    - name: "restricted_use_indicator"
      expr: restricted_use_indicator
      comment: "Whether fund has restrictions on use"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year designation for fund"
  measures:
    - name: "total_authorized_amount"
      expr: SUM(CAST(authorized_amount AS DOUBLE))
      comment: "Total amount authorized by legislative appropriation or grant award - maximum funding available"
    - name: "total_budgeted_amount"
      expr: SUM(CAST(budgeted_amount AS DOUBLE))
      comment: "Total budgeted amount allocated for current fiscal period - planned utilization"
    - name: "total_obligated_amount"
      expr: SUM(CAST(obligated_amount AS DOUBLE))
      comment: "Total funds obligated through commitments - measures committed spending"
    - name: "total_expended_amount"
      expr: SUM(CAST(expended_amount AS DOUBLE))
      comment: "Total funds actually expended or disbursed - measures actual spending"
    - name: "total_available_balance"
      expr: SUM(CAST(available_balance AS DOUBLE))
      comment: "Total available balance remaining - critical metric for fiscal capacity and spending authority"
    - name: "avg_fund_size"
      expr: AVG(CAST(authorized_amount AS DOUBLE))
      comment: "Average fund authorization amount - indicates typical fund size"
    - name: "fund_utilization_rate"
      expr: ROUND(100.0 * SUM(CAST(expended_amount AS DOUBLE)) / NULLIF(SUM(CAST(authorized_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of authorized amount expended - key metric for fund execution and spending pace"
    - name: "obligation_rate"
      expr: ROUND(100.0 * SUM(CAST(obligated_amount AS DOUBLE)) / NULLIF(SUM(CAST(authorized_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of authorized amount obligated - measures commitment level and pipeline"
    - name: "available_balance_rate"
      expr: ROUND(100.0 * SUM(CAST(available_balance AS DOUBLE)) / NULLIF(SUM(CAST(authorized_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of authorized amount still available - measures remaining fiscal capacity"
    - name: "budget_to_authorization_rate"
      expr: ROUND(100.0 * SUM(CAST(budgeted_amount AS DOUBLE)) / NULLIF(SUM(CAST(authorized_amount AS DOUBLE)), 0), 2)
      comment: "Budgeted amount as percentage of authorization - measures budget planning conservatism"
    - name: "avg_federal_share_percentage"
      expr: AVG(CAST(federal_share_percentage AS DOUBLE))
      comment: "Average federal share percentage across funds - indicates typical federal match rate"
    - name: "avg_state_match_percentage"
      expr: AVG(CAST(state_match_percentage AS DOUBLE))
      comment: "Average state match percentage required - indicates typical state match obligation"
    - name: "fund_count"
      expr: COUNT(1)
      comment: "Total number of funds - baseline metric for fund portfolio size"
    - name: "restricted_fund_count"
      expr: COUNT(CASE WHEN restricted_use_indicator = true THEN 1 END)
      comment: "Number of funds with use restrictions - measures compliance complexity"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_funding_allocation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Funding allocation performance metrics tracking allocations to projects and programs, expenditure progress, and fund utilization. Supports capital planning, grant management, and project finance."
  source: "`feip_eastus_03`.`finance`.`funding_allocation`"
  dimensions:
    - name: "allocation_status"
      expr: allocation_status
      comment: "Current lifecycle status: planned, committed, obligated, expended"
    - name: "allocation_type"
      expr: allocation_type
      comment: "Classification: initial allocation, supplemental funding, reallocation"
    - name: "funding_source_type"
      expr: funding_source_type
      comment: "High-level classification by governmental level or origin"
    - name: "federal_program_name"
      expr: federal_program_name
      comment: "Name of federal funding program"
    - name: "program_code"
      expr: program_code
      comment: "Code identifying transportation program or initiative"
    - name: "program_name"
      expr: program_name
      comment: "Descriptive name of transportation program"
    - name: "division_code"
      expr: division_code
      comment: "Code identifying NCDOT division responsible for allocation"
    - name: "division_name"
      expr: division_name
      comment: "Name of NCDOT division"
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where funded project is located"
    - name: "match_requirement_flag"
      expr: match_requirement_flag
      comment: "Whether allocation requires matching funds"
    - name: "allocation_category"
      expr: allocation_category
      comment: "High-level category classifying purpose or functional area"
  measures:
    - name: "total_allocation_amount"
      expr: SUM(CAST(allocation_amount AS DOUBLE))
      comment: "Total monetary amount allocated - measures funding commitment to projects and programs"
    - name: "total_federal_share"
      expr: SUM(CAST(federal_share_amount AS DOUBLE))
      comment: "Total federal funding portion - tracks federal grant and aid utilization"
    - name: "total_state_share"
      expr: SUM(CAST(state_share_amount AS DOUBLE))
      comment: "Total state funding portion - tracks state investment"
    - name: "total_local_share"
      expr: SUM(CAST(local_share_amount AS DOUBLE))
      comment: "Total local government funding portion - tracks local match and contributions"
    - name: "total_match_amount"
      expr: SUM(CAST(match_amount AS DOUBLE))
      comment: "Total matching funds required or committed - measures match obligation"
    - name: "total_obligated_amount"
      expr: SUM(CAST(obligated_amount AS DOUBLE))
      comment: "Total amount formally obligated - measures committed spending"
    - name: "total_encumbered_amount"
      expr: SUM(CAST(encumbered_amount AS DOUBLE))
      comment: "Total amount encumbered through commitments - measures pipeline of spending"
    - name: "total_expended_amount"
      expr: SUM(CAST(expended_amount AS DOUBLE))
      comment: "Total amount actually expended - measures spending execution"
    - name: "total_remaining_balance"
      expr: SUM(CAST(remaining_balance AS DOUBLE))
      comment: "Total unspent balance available - critical metric for remaining fiscal capacity"
    - name: "avg_allocation_amount"
      expr: AVG(CAST(allocation_amount AS DOUBLE))
      comment: "Average allocation amount - indicates typical allocation size"
    - name: "allocation_execution_rate"
      expr: ROUND(100.0 * SUM(CAST(expended_amount AS DOUBLE)) / NULLIF(SUM(CAST(allocation_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of allocation expended - key metric for spending pace and execution performance"
    - name: "obligation_rate"
      expr: ROUND(100.0 * SUM(CAST(obligated_amount AS DOUBLE)) / NULLIF(SUM(CAST(allocation_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of allocation obligated - measures commitment level"
    - name: "remaining_balance_rate"
      expr: ROUND(100.0 * SUM(CAST(remaining_balance AS DOUBLE)) / NULLIF(SUM(CAST(allocation_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of allocation still available - measures remaining fiscal capacity"
    - name: "federal_share_percentage"
      expr: ROUND(100.0 * SUM(CAST(federal_share_amount AS DOUBLE)) / NULLIF(SUM(CAST(allocation_amount AS DOUBLE)), 0), 2)
      comment: "Federal funding as percentage of total allocation - measures federal leverage"
    - name: "state_share_percentage"
      expr: ROUND(100.0 * SUM(CAST(state_share_amount AS DOUBLE)) / NULLIF(SUM(CAST(allocation_amount AS DOUBLE)), 0), 2)
      comment: "State funding as percentage of total allocation - measures state investment level"
    - name: "allocation_count"
      expr: COUNT(1)
      comment: "Total number of funding allocations - baseline metric for allocation portfolio size"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_cost_center`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cost center budget performance metrics tracking allocations, commitments, expenditures, and variance. Supports departmental budget management, cost control, and organizational accountability."
  source: "`feip_eastus_03`.`finance`.`cost_center`"
  dimensions:
    - name: "cost_center_code"
      expr: code
      comment: "Alphanumeric code uniquely identifying cost center"
    - name: "cost_center_type"
      expr: type
      comment: "Classification: operational, project, grant"
    - name: "cost_center_status"
      expr: status
      comment: "Current operational status"
    - name: "division_code"
      expr: division_code
      comment: "Code identifying NCDOT division"
    - name: "division_name"
      expr: division_name
      comment: "Full name of NCDOT division"
    - name: "functional_area"
      expr: functional_area
      comment: "Primary functional area or business process"
    - name: "county"
      expr: county
      comment: "North Carolina county where cost center is located"
    - name: "region"
      expr: region
      comment: "NCDOT operational region or district"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary source of funding"
    - name: "is_grant_funded"
      expr: is_grant_funded
      comment: "Whether cost center is funded by grant programs"
    - name: "budget_year"
      expr: budget_year
      comment: "Fiscal year for which cost center configuration is active"
  measures:
    - name: "total_budget_amount"
      expr: SUM(CAST(budget_amount AS DOUBLE))
      comment: "Total approved budget allocation for current fiscal year - planned spending authority"
    - name: "total_committed_amount"
      expr: SUM(CAST(committed_amount AS DOUBLE))
      comment: "Total budget committed through purchase orders and contracts - measures pipeline of spending"
    - name: "total_actual_expenditure"
      expr: SUM(CAST(actual_expenditure_amount AS DOUBLE))
      comment: "Total actual expenditures posted - measures spending execution"
    - name: "total_available_budget"
      expr: SUM(CAST(available_budget_amount AS DOUBLE))
      comment: "Total remaining budget available - critical metric for spending authority and fiscal capacity"
    - name: "avg_budget_per_cost_center"
      expr: AVG(CAST(budget_amount AS DOUBLE))
      comment: "Average budget allocation per cost center - indicates typical cost center size"
    - name: "budget_utilization_rate"
      expr: ROUND(100.0 * SUM(CAST(actual_expenditure_amount AS DOUBLE)) / NULLIF(SUM(CAST(budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of budget expended - key metric for spending pace and execution performance"
    - name: "commitment_rate"
      expr: ROUND(100.0 * SUM(CAST(committed_amount AS DOUBLE)) / NULLIF(SUM(CAST(budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of budget committed - measures commitment level and pipeline"
    - name: "available_budget_rate"
      expr: ROUND(100.0 * SUM(CAST(available_budget_amount AS DOUBLE)) / NULLIF(SUM(CAST(budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of budget still available - measures remaining fiscal capacity"
    - name: "cost_center_count"
      expr: COUNT(1)
      comment: "Total number of cost centers - baseline metric for organizational structure size"
    - name: "active_cost_center_count"
      expr: COUNT(CASE WHEN status = 'Active' THEN 1 END)
      comment: "Number of active cost centers - measures operational organizational units"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`finance_journal_entry`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Journal entry metrics tracking financial postings, adjustments, and accounting activity. Supports financial close, audit, and accounting operations management."
  source: "`feip_eastus_03`.`finance`.`journal_entry`"
  dimensions:
    - name: "journal_source"
      expr: journal_source
      comment: "Source system or module that originated journal entry"
    - name: "journal_category"
      expr: journal_category
      comment: "Category or type: Adjustment, Accrual, Reclassification, Standard"
    - name: "entry_type"
      expr: entry_type
      comment: "Classification based on accounting purpose and timing"
    - name: "posting_status"
      expr: posting_status
      comment: "Whether journal entry has been successfully posted to GL"
    - name: "approval_status"
      expr: approval_status
      comment: "Approval status within financial approval workflow"
    - name: "fiscal_period"
      expr: fiscal_period
      comment: "Fiscal period or accounting period within fiscal year"
    - name: "company_code"
      expr: company_code
      comment: "Organizational unit code representing legal entity"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether journal entry is a reversal of previous entry"
    - name: "adjustment_flag"
      expr: adjustment_flag
      comment: "Whether journal entry is an adjustment to correct previous records"
    - name: "federal_flag"
      expr: federal_flag
      comment: "Whether journal entry involves federal funds or grant programs"
    - name: "posting_date_month"
      expr: DATE_TRUNC('MONTH', posting_date)
      comment: "Month when journal entry was posted to general ledger"
  measures:
    - name: "total_debit_amount"
      expr: SUM(CAST(entered_debit_amount AS DOUBLE))
      comment: "Total debit amount in transaction currency - measures debit side of accounting entries"
    - name: "total_credit_amount"
      expr: SUM(CAST(entered_credit_amount AS DOUBLE))
      comment: "Total credit amount in transaction currency - measures credit side of accounting entries"
    - name: "total_accounted_debit"
      expr: SUM(CAST(accounted_debit_amount AS DOUBLE))
      comment: "Total debit amount in functional currency - standardized metric for financial reporting"
    - name: "total_accounted_credit"
      expr: SUM(CAST(accounted_credit_amount AS DOUBLE))
      comment: "Total credit amount in functional currency - standardized metric for financial reporting"
    - name: "avg_entry_amount"
      expr: AVG(CAST(entered_debit_amount AS DOUBLE))
      comment: "Average journal entry debit amount - indicates typical transaction size"
    - name: "avg_line_count"
      expr: AVG(CAST(line_count AS DOUBLE))
      comment: "Average number of line items per journal entry - measures entry complexity"
    - name: "reversal_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN reversal_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of journal entries that are reversals - indicates correction frequency and accounting accuracy"
    - name: "adjustment_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN adjustment_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of journal entries that are adjustments - measures correction activity"
    - name: "unbalanced_entry_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN balanced_flag = false THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of journal entries that are unbalanced - critical data quality metric for accounting integrity"
    - name: "journal_entry_count"
      expr: COUNT(1)
      comment: "Total number of journal entries - baseline volume metric for accounting workload"
    - name: "unique_batch_count"
      expr: COUNT(DISTINCT batch_number)
      comment: "Number of unique batches - measures batch processing activity"
$$;