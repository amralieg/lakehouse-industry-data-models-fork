-- Metric views for domain: claimfinancials | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_reserve`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reserve movements and balances by claim exposure, coverage, and accounting period. Grain: one row per reserve transaction per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve`"
  dimensions:
    - name: "reserve_type"
      expr: reserve_type
      comment: "Type of reserve: Case, IBNR, LAE, etc."
    - name: "reserve_status"
      expr: reserve_status
      comment: "Current status of the reserve transaction."
    - name: "reserve_category"
      expr: reserve_category
      comment: "Reserve reserve_category classification."
    - name: "basis"
      expr: basis
      comment: "Basis for reserve calculation."
    - name: "method"
      expr: method
      comment: "Method used to establish the reserve."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for cohort analysis."
    - name: "development_period"
      expr: development_period
      comment: "Number of periods since loss date for development triangles."
    - name: "state_code"
      expr: state_code
      comment: "State jurisdiction code for regulatory reporting."
    - name: "catastrophe_indicator"
      expr: catastrophe_indicator
      comment: "Flag indicating catastrophe-related reserve."
    - name: "case_reserve_adequacy_flag"
      expr: case_reserve_adequacy_flag
      comment: "Flag indicating whether case reserve is adequate."
    - name: "requires_supervisor_approval"
      expr: requires_supervisor_approval
      comment: "Flag indicating supervisor approval requirement."
    - name: "movement_reason_code"
      expr: movement_reason_code
      comment: "Code describing reason for reserve movement."
  measures:
    - name: "total_opening_balance"
      expr: SUM(CAST(opening_balance_amount AS DOUBLE))
      comment: "Total opening reserve balance at start of accounting period."
    - name: "total_closing_balance"
      expr: SUM(CAST(closing_balance_amount AS DOUBLE))
      comment: "Total closing reserve balance at end of accounting period."
    - name: "total_movement_amount"
      expr: SUM(CAST(movement_amount AS DOUBLE))
      comment: "Total reserve movement (increases minus decreases) during period."
    - name: "total_ceded_opening_balance"
      expr: SUM(CAST(ceded_opening_balance_amount AS DOUBLE))
      comment: "Total ceded opening reserve balance at start of period."
    - name: "total_ceded_closing_balance"
      expr: SUM(CAST(ceded_closing_balance_amount AS DOUBLE))
      comment: "Total ceded closing reserve balance at end of period."
    - name: "total_ceded_movement"
      expr: SUM(CAST(ceded_movement_amount AS DOUBLE))
      comment: "Total ceded reserve movement during period."
    - name: "total_reinsurance_recoverable"
      expr: SUM(CAST(reinsurance_recoverable_amount AS DOUBLE))
      comment: "Total reinsurance recoverable amount on reserves."
    - name: "total_salvage_anticipated"
      expr: SUM(CAST(salvage_anticipated_amount AS DOUBLE))
      comment: "Total anticipated salvage recovery amount."
    - name: "total_subrogation_anticipated"
      expr: SUM(CAST(subrogation_anticipated_amount AS DOUBLE))
      comment: "Total anticipated subrogation recovery amount."
    - name: "avg_authority_limit"
      expr: AVG(CAST(authority_limit_amount AS DOUBLE))
      comment: "Average authority limit for reserve transactions."
    - name: "reserve_transaction_count"
      expr: COUNT(1)
      comment: "Number of reserve transactions recorded."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with reserve activity."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with reserve activity."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_claim_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim payment transactions by claimant, coverage, and accounting period. Grain: one row per payment transaction per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`"
  dimensions:
    - name: "payment_status"
      expr: payment_status
      comment: "Current status of the payment transaction."
    - name: "payment_type"
      expr: payment_type
      comment: "Type of payment: Indemnity, Medical, Expense, etc."
    - name: "payment_method"
      expr: payment_method
      comment: "Method of payment: Check, EFT, Wire, etc."
    - name: "loss_category"
      expr: loss_category
      comment: "Category of loss for payment classification."
    - name: "coverage_type_code"
      expr: coverage_type_code
      comment: "Coverage type code for the payment."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for cohort analysis."
    - name: "state_jurisdiction_code"
      expr: state_jurisdiction_code
      comment: "State jurisdiction code for regulatory reporting."
    - name: "is_final_payment"
      expr: is_final_payment
      comment: "Flag indicating final payment on claim exposure."
    - name: "is_structured_settlement"
      expr: is_structured_settlement
      comment: "Flag indicating structured settlement payment."
    - name: "is_1099_reportable"
      expr: is_1099_reportable
      comment: "Flag indicating IRS 1099 reporting requirement."
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Flag indicating Special Investigation Unit referral."
    - name: "stop_payment_flag"
      expr: stop_payment_flag
      comment: "Flag indicating stop payment issued."
  measures:
    - name: "total_gross_payment"
      expr: SUM(CAST(gross_payment_amount AS DOUBLE))
      comment: "Total gross payment amount before offsets and deductions."
    - name: "total_net_payment"
      expr: SUM(CAST(net_payment_amount AS DOUBLE))
      comment: "Total net payment amount after offsets and deductions."
    - name: "total_deductible_offset"
      expr: SUM(CAST(deductible_offset_amount AS DOUBLE))
      comment: "Total deductible offset amount applied to payments."
    - name: "total_withholding"
      expr: SUM(CAST(withholding_amount AS DOUBLE))
      comment: "Total withholding amount for tax or other purposes."
    - name: "total_reinsurance_recoverable"
      expr: SUM(CAST(reinsurance_recoverable_amount AS DOUBLE))
      comment: "Total reinsurance recoverable amount on payments."
    - name: "avg_gross_payment"
      expr: AVG(CAST(gross_payment_amount AS DOUBLE))
      comment: "Average gross payment amount per transaction."
    - name: "avg_net_payment"
      expr: AVG(CAST(net_payment_amount AS DOUBLE))
      comment: "Average net payment amount per transaction."
    - name: "avg_authority_limit"
      expr: AVG(CAST(authority_limit_amount AS DOUBLE))
      comment: "Average authority limit for payment transactions."
    - name: "payment_transaction_count"
      expr: COUNT(1)
      comment: "Number of payment transactions recorded."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with payment activity."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with payment activity."
    - name: "distinct_claimant_count"
      expr: COUNT(DISTINCT claimant_id)
      comment: "Number of distinct claimants receiving payments."
    - name: "distinct_payee_count"
      expr: COUNT(DISTINCT payee_id)
      comment: "Number of distinct payees receiving payments."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_claim_expense`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim expense transactions including LAE, DCC, and AO by claim exposure and accounting period. Grain: one row per expense transaction per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense`"
  dimensions:
    - name: "expense_status"
      expr: expense_status
      comment: "Current status of the expense transaction."
    - name: "expense_type"
      expr: expense_type
      comment: "Type of expense: LAE, DCC, AO, etc."
    - name: "lae_category"
      expr: lae_category
      comment: "Loss Adjustment Expense category: Allocated or Unallocated."
    - name: "is_dcc_expense"
      expr: is_dcc_expense
      comment: "Flag indicating Defense and Cost Containment expense."
    - name: "is_recoverable"
      expr: is_recoverable
      comment: "Flag indicating expense is recoverable from reinsurance or other party."
    - name: "approval_status"
      expr: approval_status
      comment: "Approval status of the expense transaction."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for cohort analysis."
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Flag indicating Special Investigation Unit referral."
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Flag indicating expense reversal transaction."
    - name: "payment_method"
      expr: payment_method
      comment: "Method of payment for the expense."
  measures:
    - name: "total_expense_amount"
      expr: SUM(CAST(expense_amount AS DOUBLE))
      comment: "Total expense amount incurred."
    - name: "total_functional_currency_amount"
      expr: SUM(CAST(functional_currency_amount AS DOUBLE))
      comment: "Total expense amount in functional currency."
    - name: "total_reinsurance_recoverable"
      expr: SUM(CAST(reinsurance_recoverable_amount AS DOUBLE))
      comment: "Total reinsurance recoverable amount on expenses."
    - name: "avg_expense_amount"
      expr: AVG(CAST(expense_amount AS DOUBLE))
      comment: "Average expense amount per transaction."
    - name: "avg_exchange_rate"
      expr: AVG(CAST(exchange_rate AS DOUBLE))
      comment: "Average exchange rate applied to expense transactions."
    - name: "expense_transaction_count"
      expr: COUNT(1)
      comment: "Number of expense transactions recorded."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with expense activity."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with expense activity."
    - name: "distinct_payee_count"
      expr: COUNT(DISTINCT payee_id)
      comment: "Number of distinct payees receiving expense payments."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_recovery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Recovery transactions including subrogation, salvage, and reinsurance by claim exposure and accounting period. Grain: one row per recovery transaction per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery`"
  dimensions:
    - name: "recovery_status"
      expr: recovery_status
      comment: "Current status of the recovery transaction."
    - name: "recovery_type"
      expr: recovery_type
      comment: "Type of recovery: Subrogation, Salvage, Reinsurance, etc."
    - name: "method"
      expr: method
      comment: "Method used to pursue or collect recovery."
    - name: "salvage_type"
      expr: salvage_type
      comment: "Type of salvage recovery."
    - name: "subrogation_basis"
      expr: subrogation_basis
      comment: "Legal basis for subrogation recovery."
    - name: "ri_recovery_basis"
      expr: ri_recovery_basis
      comment: "Basis for reinsurance recovery calculation."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for cohort analysis."
    - name: "state_code"
      expr: state_code
      comment: "State jurisdiction code for recovery."
    - name: "litigation_flag"
      expr: litigation_flag
      comment: "Flag indicating recovery involves litigation."
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Flag indicating Special Investigation Unit referral."
    - name: "bordereaux_period"
      expr: bordereaux_period
      comment: "Bordereaux reporting period for reinsurance recovery."
  measures:
    - name: "total_demand_amount"
      expr: SUM(CAST(demand_amount AS DOUBLE))
      comment: "Total demand amount for recovery."
    - name: "total_collected_amount"
      expr: SUM(CAST(collected_amount AS DOUBLE))
      comment: "Total amount collected from recovery efforts."
    - name: "total_net_recovery"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net recovery amount after expenses."
    - name: "total_collection_expense"
      expr: SUM(CAST(collection_expense_amount AS DOUBLE))
      comment: "Total expense incurred to collect recovery."
    - name: "avg_ri_participation_pct"
      expr: AVG(CAST(ri_participation_pct AS DOUBLE))
      comment: "Average reinsurance participation percentage on recoveries."
    - name: "recovery_transaction_count"
      expr: COUNT(1)
      comment: "Number of recovery transactions recorded."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with recovery activity."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with recovery activity."
    - name: "distinct_responsible_party_count"
      expr: COUNT(DISTINCT responsible_party_id)
      comment: "Number of distinct responsible parties for recovery."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_reinsurance_recovery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance recovery transactions by reinsurer, agreement, and accounting period. Grain: one row per reinsurance recovery transaction per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery`"
  dimensions:
    - name: "recovery_status"
      expr: recovery_status
      comment: "Current status of the reinsurance recovery transaction."
    - name: "recovery_type"
      expr: recovery_type
      comment: "Type of reinsurance recovery: Treaty, Facultative, etc."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for cohort analysis."
    - name: "bordereaux_period"
      expr: bordereaux_period
      comment: "Bordereaux reporting period for reinsurance recovery."
  measures:
    - name: "reinsurance_recovery_count"
      expr: COUNT(1)
      comment: "Number of reinsurance recovery transactions recorded."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with reinsurance recovery."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with reinsurance recovery."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_subrogation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Subrogation pursuit and recovery by liable party, claim exposure, and accounting period. Grain: one row per subrogation case per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation`"
  dimensions:
    - name: "subrogation_type"
      expr: subrogation_type
      comment: "Type of subrogation: Auto, Property, General Liability, etc."
    - name: "pursuit_status"
      expr: pursuit_status
      comment: "Current pursuit status of the subrogation case."
    - name: "litigation_status"
      expr: litigation_status
      comment: "Litigation status of the subrogation case."
    - name: "recovery_method"
      expr: recovery_method
      comment: "Method used to recover subrogation: Settlement, Arbitration, Litigation, etc."
    - name: "closure_reason"
      expr: closure_reason
      comment: "Reason for closing the subrogation case."
    - name: "state_of_loss"
      expr: state_of_loss
      comment: "State jurisdiction where loss occurred."
    - name: "made_whole_indicator"
      expr: made_whole_indicator
      comment: "Flag indicating insured has been made whole before subrogation."
    - name: "siu_referral_indicator"
      expr: siu_referral_indicator
      comment: "Flag indicating Special Investigation Unit referral."
    - name: "reinsurance_recovery_indicator"
      expr: reinsurance_recovery_indicator
      comment: "Flag indicating reinsurance participation in subrogation recovery."
  measures:
    - name: "total_demand_amount"
      expr: SUM(CAST(demand_amount AS DOUBLE))
      comment: "Total demand amount sent to liable parties."
    - name: "total_collectible_amount"
      expr: SUM(CAST(collectible_amount AS DOUBLE))
      comment: "Total amount deemed collectible from liable parties."
    - name: "total_collected_amount"
      expr: SUM(CAST(collected_amount AS DOUBLE))
      comment: "Total amount collected from liable parties."
    - name: "total_settlement_amount"
      expr: SUM(CAST(settlement_amount AS DOUBLE))
      comment: "Total settlement amount agreed with liable parties."
    - name: "total_arbitration_award"
      expr: SUM(CAST(arbitration_award_amount AS DOUBLE))
      comment: "Total arbitration award amount received."
    - name: "total_net_recovery"
      expr: SUM(CAST(net_recovery_amount AS DOUBLE))
      comment: "Total net recovery amount after expenses."
    - name: "total_recovery_expense"
      expr: SUM(CAST(recovery_expense_amount AS DOUBLE))
      comment: "Total expense incurred to pursue subrogation recovery."
    - name: "total_insured_reimbursement"
      expr: SUM(CAST(insured_reimbursement_amount AS DOUBLE))
      comment: "Total amount reimbursed to insured from subrogation recovery."
    - name: "avg_negligence_pct"
      expr: AVG(CAST(negligence_pct AS DOUBLE))
      comment: "Average negligence percentage assigned to liable parties."
    - name: "subrogation_case_count"
      expr: COUNT(1)
      comment: "Number of subrogation cases recorded."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with subrogation activity."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with subrogation activity."
    - name: "distinct_liable_party_count"
      expr: COUNT(DISTINCT liable_party_id)
      comment: "Number of distinct liable parties pursued for subrogation."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_salvage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Salvage recovery transactions by insured risk, claim exposure, and accounting period. Grain: one row per salvage item per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage`"
  dimensions:
    - name: "salvage_status"
      expr: salvage_status
      comment: "Current status of the salvage item."
    - name: "salvage_type"
      expr: salvage_type
      comment: "Type of salvage: Vehicle, Property, Equipment, etc."
    - name: "disposition_method"
      expr: disposition_method
      comment: "Method used to dispose of salvage: Auction, Direct Sale, Scrap, etc."
    - name: "buyer_type"
      expr: buyer_type
      comment: "Type of buyer: Dealer, Salvage Yard, Insured, etc."
    - name: "title_transfer_status"
      expr: title_transfer_status
      comment: "Status of title transfer for salvage item."
    - name: "total_loss_indicator"
      expr: total_loss_indicator
      comment: "Flag indicating total loss claim."
    - name: "insured_retained_indicator"
      expr: insured_retained_indicator
      comment: "Flag indicating insured retained salvage item."
    - name: "reinsurance_recoverable_indicator"
      expr: reinsurance_recoverable_indicator
      comment: "Flag indicating reinsurance participation in salvage recovery."
    - name: "siu_referral_indicator"
      expr: siu_referral_indicator
      comment: "Flag indicating Special Investigation Unit referral."
    - name: "state_code"
      expr: state_code
      comment: "State jurisdiction code for salvage."
  measures:
    - name: "total_value_estimate"
      expr: SUM(CAST(value_estimate AS DOUBLE))
      comment: "Total estimated value of salvage items."
    - name: "total_auction_proceeds"
      expr: SUM(CAST(auction_proceeds AS DOUBLE))
      comment: "Total proceeds received from salvage auctions."
    - name: "total_net_salvage"
      expr: SUM(CAST(net_salvage_amount AS DOUBLE))
      comment: "Total net salvage amount after expenses."
    - name: "total_auction_fee"
      expr: SUM(CAST(auction_fee AS DOUBLE))
      comment: "Total auction fees paid for salvage disposition."
    - name: "total_storage_cost"
      expr: SUM(CAST(storage_cost AS DOUBLE))
      comment: "Total storage cost incurred for salvage items."
    - name: "total_towing_cost"
      expr: SUM(CAST(towing_cost AS DOUBLE))
      comment: "Total towing cost incurred for salvage items."
    - name: "total_insured_retention_deduction"
      expr: SUM(CAST(insured_retention_deduction AS DOUBLE))
      comment: "Total deduction for insured retention of salvage."
    - name: "total_reinsurance_salvage_share"
      expr: SUM(CAST(reinsurance_salvage_share AS DOUBLE))
      comment: "Total reinsurance share of salvage recovery."
    - name: "salvage_item_count"
      expr: COUNT(1)
      comment: "Number of salvage items recorded."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with salvage activity."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with salvage activity."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_financial_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "All claim financial transactions across reserves, payments, recoveries, and expenses by accounting period. Grain: one row per financial transaction per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction`"
  dimensions:
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of financial transaction: Reserve, Payment, Recovery, Expense, etc."
    - name: "transaction_subtype"
      expr: transaction_subtype
      comment: "Subtype of financial transaction for detailed classification."
    - name: "transaction_status"
      expr: transaction_status
      comment: "Current status of the financial transaction."
    - name: "reserve_type"
      expr: reserve_type
      comment: "Type of reserve: Case, IBNR, LAE, etc."
    - name: "loss_category"
      expr: loss_category
      comment: "Category of loss for transaction classification."
    - name: "expense_category"
      expr: expense_category
      comment: "Category of expense for transaction classification."
    - name: "coverage_type_code"
      expr: coverage_type_code
      comment: "Coverage type code for the transaction."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for cohort analysis."
    - name: "calendar_year"
      expr: calendar_year
      comment: "Calendar year of transaction for reporting."
    - name: "state_code"
      expr: state_code
      comment: "State jurisdiction code for transaction."
    - name: "reversal_indicator"
      expr: reversal_indicator
      comment: "Flag indicating transaction is a reversal."
    - name: "reinsurance_recoverable_indicator"
      expr: reinsurance_recoverable_indicator
      comment: "Flag indicating reinsurance recoverable on transaction."
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Flag indicating Special Investigation Unit referral."
  measures:
    - name: "total_gross_amount"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross transaction amount before cessions and offsets."
    - name: "total_net_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net transaction amount after cessions and offsets."
    - name: "total_ceded_amount"
      expr: SUM(CAST(ceded_amount AS DOUBLE))
      comment: "Total ceded amount to reinsurers."
    - name: "total_deductible_offset"
      expr: SUM(CAST(deductible_offset_amount AS DOUBLE))
      comment: "Total deductible offset amount applied to transactions."
    - name: "total_current_balance"
      expr: SUM(CAST(current_balance_amount AS DOUBLE))
      comment: "Total current balance after transaction."
    - name: "total_prior_balance"
      expr: SUM(CAST(prior_balance_amount AS DOUBLE))
      comment: "Total prior balance before transaction."
    - name: "avg_authority_limit"
      expr: AVG(CAST(authority_limit_amount AS DOUBLE))
      comment: "Average authority limit for financial transactions."
    - name: "financial_transaction_count"
      expr: COUNT(1)
      comment: "Number of financial transactions recorded."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with financial activity."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with financial activity."
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of distinct policies with claim financial activity."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_accounting_period`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Accounting period master for claim financial reporting and loss development. Grain: one row per accounting period."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`"
  dimensions:
    - name: "period_code"
      expr: period_code
      comment: "Unique code identifying the accounting period."
    - name: "period_name"
      expr: period_name
      comment: "Descriptive name of the accounting period."
    - name: "period_type"
      expr: period_type
      comment: "Type of accounting period: Monthly, Quarterly, Annual, etc."
    - name: "period_status"
      expr: period_status
      comment: "Current status of the accounting period: Open, Closed, Locked, etc."
    - name: "period_basis"
      expr: period_basis
      comment: "Basis for the accounting period: Calendar, Fiscal, Policy, Accident, etc."
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year of the accounting period."
    - name: "fiscal_quarter"
      expr: fiscal_quarter
      comment: "Fiscal quarter of the accounting period."
    - name: "fiscal_month"
      expr: fiscal_month
      comment: "Fiscal month of the accounting period."
    - name: "calendar_year"
      expr: calendar_year
      comment: "Calendar year of the accounting period."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for cohort analysis."
    - name: "is_year_end"
      expr: is_year_end
      comment: "Flag indicating year-end accounting period."
    - name: "is_quarter_end"
      expr: is_quarter_end
      comment: "Flag indicating quarter-end accounting period."
    - name: "is_stub_period"
      expr: is_stub_period
      comment: "Flag indicating stub period for partial year."
    - name: "reporting_framework"
      expr: reporting_framework
      comment: "Reporting framework: GAAP, IFRS, Statutory, etc."
    - name: "gl_period_code"
      expr: gl_period_code
      comment: "General ledger period code for integration."
    - name: "naic_statement_period"
      expr: naic_statement_period
      comment: "NAIC statement period for regulatory reporting."
    - name: "ifrs17_reporting_period"
      expr: ifrs17_reporting_period
      comment: "IFRS 17 reporting period for international standards."
    - name: "schedule_p_period_label"
      expr: schedule_p_period_label
      comment: "Schedule P period label for loss development triangles."
    - name: "bordereaux_period_code"
      expr: bordereaux_period_code
      comment: "Bordereaux period code for reinsurance reporting."
    - name: "premium_earning_method"
      expr: premium_earning_method
      comment: "Method used to earn premium during the period."
  measures:
    - name: "total_period_days"
      expr: SUM(CAST(period_days AS DOUBLE))
      comment: "Total number of days across accounting periods."
    - name: "avg_period_days"
      expr: AVG(CAST(period_days AS DOUBLE))
      comment: "Average number of days per accounting period."
    - name: "avg_loss_development_lag"
      expr: AVG(CAST(loss_development_lag AS DOUBLE))
      comment: "Average loss development lag in periods."
    - name: "avg_fx_rate_to_usd"
      expr: AVG(CAST(fx_rate_to_usd AS DOUBLE))
      comment: "Average foreign exchange rate to USD for the period."
    - name: "accounting_period_count"
      expr: COUNT(1)
      comment: "Number of accounting periods defined."
$$;