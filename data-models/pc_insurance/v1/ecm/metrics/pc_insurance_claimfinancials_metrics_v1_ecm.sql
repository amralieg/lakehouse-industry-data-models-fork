-- Metric views for domain: claimfinancials | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_claim_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payment transactions on claims, tracking gross and net amounts, deductible offsets, and reinsurance recoverables per claim exposure and accounting period."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`"
  dimensions:
    - name: "payment_date"
      expr: payment_date
      comment: "Date the payment was issued to the payee."
    - name: "payment_year"
      expr: YEAR(payment_date)
      comment: "Calendar year of payment issuance."
    - name: "payment_month"
      expr: DATE_TRUNC('MONTH', payment_date)
      comment: "Month of payment issuance for trending."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying loss event."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year in which the loss occurred."
    - name: "payment_type"
      expr: payment_type
      comment: "Type of payment: Indemnity, Medical, Expense, etc."
    - name: "payment_status"
      expr: payment_status
      comment: "Current status of the payment: Issued, Cleared, Voided, Stopped."
    - name: "payment_method"
      expr: payment_method
      comment: "Method of payment: Check, EFT, Wire, etc."
    - name: "coverage_type_code"
      expr: coverage_type_code
      comment: "Coverage type code under which the payment was made."
    - name: "loss_category"
      expr: loss_category
      comment: "Category of loss: Property, Liability, Auto Physical Damage, etc."
    - name: "state_jurisdiction_code"
      expr: state_jurisdiction_code
      comment: "State jurisdiction code governing the claim."
    - name: "is_final_payment"
      expr: is_final_payment
      comment: "Indicates whether this is the final payment on the claim exposure."
    - name: "is_structured_settlement"
      expr: is_structured_settlement
      comment: "Indicates whether the payment is part of a structured settlement."
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Indicates whether the claim was referred to Special Investigation Unit."
  measures:
    - name: "total_payment_count"
      expr: COUNT(1)
      comment: "Total number of payment transactions."
    - name: "total_gross_payment_amount"
      expr: SUM(CAST(gross_payment_amount AS DOUBLE))
      comment: "Total gross payment amount before deductible and reinsurance offsets."
    - name: "total_net_payment_amount"
      expr: SUM(CAST(net_payment_amount AS DOUBLE))
      comment: "Total net payment amount after all offsets."
    - name: "total_deductible_offset_amount"
      expr: SUM(CAST(deductible_offset_amount AS DOUBLE))
      comment: "Total deductible amount offset against payments."
    - name: "total_reinsurance_recoverable_amount"
      expr: SUM(CAST(reinsurance_recoverable_amount AS DOUBLE))
      comment: "Total reinsurance recoverable amount on payments."
    - name: "total_withholding_amount"
      expr: SUM(CAST(withholding_amount AS DOUBLE))
      comment: "Total tax withholding amount on payments."
    - name: "avg_gross_payment_amount"
      expr: AVG(CAST(gross_payment_amount AS DOUBLE))
      comment: "Average gross payment amount per transaction."
    - name: "avg_net_payment_amount"
      expr: AVG(CAST(net_payment_amount AS DOUBLE))
      comment: "Average net payment amount per transaction."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with payments."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with payments."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_reserve`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reserve movements tracking case, IBNR, and LAE reserves with opening, closing balances and movement amounts per claim exposure and accounting period."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve`"
  dimensions:
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the reserve movement."
    - name: "reserve_year"
      expr: YEAR(effective_date)
      comment: "Calendar year of reserve movement."
    - name: "reserve_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month of reserve movement for trending."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying loss event."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year in which the loss occurred."
    - name: "development_period"
      expr: development_period
      comment: "Number of periods since loss occurrence for development analysis."
    - name: "reserve_type"
      expr: reserve_type
      comment: "Type of reserve: Case, IBNR, LAE, ULAE, ALAE."
    - name: "reserve_status"
      expr: reserve_status
      comment: "Current status of the reserve: Active, Closed, Pending."
    - name: "reserve_category"
      expr: reserve_category
      comment: "Reserve reserve_category for classification."
    - name: "basis"
      expr: basis
      comment: "Basis of reserve estimation: Actuarial, Case-by-case, Formula."
    - name: "method"
      expr: method
      comment: "Method used for reserve calculation."
    - name: "movement_reason_code"
      expr: movement_reason_code
      comment: "Code indicating reason for reserve movement."
    - name: "catastrophe_indicator"
      expr: catastrophe_indicator
      comment: "Indicates whether the reserve is related to a catastrophe event."
    - name: "state_code"
      expr: state_code
      comment: "State code for the claim jurisdiction."
  measures:
    - name: "total_reserve_movement_count"
      expr: COUNT(1)
      comment: "Total number of reserve movement transactions."
    - name: "total_opening_balance_amount"
      expr: SUM(CAST(opening_balance_amount AS DOUBLE))
      comment: "Total opening reserve balance at start of period."
    - name: "total_closing_balance_amount"
      expr: SUM(CAST(closing_balance_amount AS DOUBLE))
      comment: "Total closing reserve balance at end of period."
    - name: "total_movement_amount"
      expr: SUM(CAST(movement_amount AS DOUBLE))
      comment: "Total reserve movement amount during period."
    - name: "total_ceded_opening_balance_amount"
      expr: SUM(CAST(ceded_opening_balance_amount AS DOUBLE))
      comment: "Total ceded opening reserve balance."
    - name: "total_ceded_closing_balance_amount"
      expr: SUM(CAST(ceded_closing_balance_amount AS DOUBLE))
      comment: "Total ceded closing reserve balance."
    - name: "total_ceded_movement_amount"
      expr: SUM(CAST(ceded_movement_amount AS DOUBLE))
      comment: "Total ceded reserve movement amount."
    - name: "total_reinsurance_recoverable_amount"
      expr: SUM(CAST(reinsurance_recoverable_amount AS DOUBLE))
      comment: "Total reinsurance recoverable amount on reserves."
    - name: "total_salvage_anticipated_amount"
      expr: SUM(CAST(salvage_anticipated_amount AS DOUBLE))
      comment: "Total anticipated salvage recovery amount."
    - name: "total_subrogation_anticipated_amount"
      expr: SUM(CAST(subrogation_anticipated_amount AS DOUBLE))
      comment: "Total anticipated subrogation recovery amount."
    - name: "avg_movement_amount"
      expr: AVG(CAST(movement_amount AS DOUBLE))
      comment: "Average reserve movement amount per transaction."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with reserve movements."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with reserve movements."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_claim_financial_snapshot`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Point-in-time financial snapshot of claims capturing incurred, paid, reserved, and ceded amounts per claim exposure and accounting period for actuarial and regulatory reporting."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot`"
  dimensions:
    - name: "valuation_date"
      expr: valuation_date
      comment: "Date at which the financial snapshot was taken."
    - name: "valuation_year"
      expr: YEAR(valuation_date)
      comment: "Calendar year of valuation."
    - name: "valuation_month"
      expr: DATE_TRUNC('MONTH', valuation_date)
      comment: "Month of valuation for trending."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying loss event."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year in which the loss occurred."
    - name: "report_year"
      expr: report_year
      comment: "Year in which the claim was reported."
    - name: "development_period"
      expr: development_period
      comment: "Number of periods since loss occurrence for development analysis."
    - name: "claim_status"
      expr: claim_status
      comment: "Current status of the claim: Open, Closed, Reopened."
    - name: "coverage_type_code"
      expr: coverage_type_code
      comment: "Coverage type code under which the claim is filed."
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code for the claim."
    - name: "state_code"
      expr: state_code
      comment: "State code for the claim jurisdiction."
    - name: "catastrophe_indicator"
      expr: catastrophe_indicator
      comment: "Indicates whether the claim is related to a catastrophe event."
    - name: "reserve_basis"
      expr: reserve_basis
      comment: "Basis of reserve estimation: Case, Actuarial, Formula."
    - name: "snapshot_status"
      expr: snapshot_status
      comment: "Status of the snapshot: Final, Preliminary, Adjusted."
  measures:
    - name: "total_snapshot_count"
      expr: COUNT(1)
      comment: "Total number of financial snapshots."
    - name: "total_incurred_amount"
      expr: SUM(CAST(total_incurred_amount AS DOUBLE))
      comment: "Total incurred loss amount including paid and reserved."
    - name: "total_paid_loss_amount"
      expr: SUM(CAST(paid_loss_amount AS DOUBLE))
      comment: "Total paid loss amount."
    - name: "total_case_reserve_amount"
      expr: SUM(CAST(case_reserve_amount AS DOUBLE))
      comment: "Total case reserve amount."
    - name: "total_ibnr_reserve_amount"
      expr: SUM(CAST(ibnr_reserve_amount AS DOUBLE))
      comment: "Total IBNR reserve amount."
    - name: "total_lae_reserve_amount"
      expr: SUM(CAST(lae_reserve_amount AS DOUBLE))
      comment: "Total LAE reserve amount."
    - name: "total_paid_lae_amount"
      expr: SUM(CAST(paid_lae_amount AS DOUBLE))
      comment: "Total paid LAE amount."
    - name: "total_incurred_lae_amount"
      expr: SUM(CAST(total_incurred_lae_amount AS DOUBLE))
      comment: "Total incurred LAE amount including paid and reserved."
    - name: "total_net_incurred_amount"
      expr: SUM(CAST(net_incurred_amount AS DOUBLE))
      comment: "Total net incurred amount after reinsurance cessions."
    - name: "total_net_reserve_amount"
      expr: SUM(CAST(net_reserve_amount AS DOUBLE))
      comment: "Total net reserve amount after reinsurance cessions."
    - name: "total_ceded_paid_amount"
      expr: SUM(CAST(ceded_paid_amount AS DOUBLE))
      comment: "Total ceded paid amount to reinsurers."
    - name: "total_ceded_reserve_amount"
      expr: SUM(CAST(ceded_reserve_amount AS DOUBLE))
      comment: "Total ceded reserve amount to reinsurers."
    - name: "total_ceded_ibnr_amount"
      expr: SUM(CAST(ceded_ibnr_amount AS DOUBLE))
      comment: "Total ceded IBNR amount to reinsurers."
    - name: "total_reserve_change_amount"
      expr: SUM(CAST(reserve_change_amount AS DOUBLE))
      comment: "Total reserve change amount from prior period."
    - name: "total_recovery_collected_amount"
      expr: SUM(CAST(total_recovery_collected_amount AS DOUBLE))
      comment: "Total recovery amount collected from salvage and subrogation."
    - name: "total_salvage_reserve_amount"
      expr: SUM(CAST(salvage_reserve_amount AS DOUBLE))
      comment: "Total salvage reserve amount anticipated."
    - name: "total_subrogation_reserve_amount"
      expr: SUM(CAST(subrogation_reserve_amount AS DOUBLE))
      comment: "Total subrogation reserve amount anticipated."
    - name: "avg_incurred_amount"
      expr: AVG(CAST(total_incurred_amount AS DOUBLE))
      comment: "Average incurred loss amount per snapshot."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims in snapshots."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures in snapshots."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_recovery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Recovery transactions tracking salvage, subrogation, and reinsurance recoveries with demand, collected, and net amounts per claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery`"
  dimensions:
    - name: "transaction_date"
      expr: transaction_date
      comment: "Date the recovery transaction was recorded."
    - name: "recovery_year"
      expr: YEAR(transaction_date)
      comment: "Calendar year of recovery transaction."
    - name: "recovery_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month of recovery transaction for trending."
    - name: "collected_date"
      expr: collected_date
      comment: "Date the recovery amount was collected."
    - name: "demand_date"
      expr: demand_date
      comment: "Date the recovery demand was made."
    - name: "closed_date"
      expr: closed_date
      comment: "Date the recovery was closed."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying loss event."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year in which the loss occurred."
    - name: "recovery_type"
      expr: recovery_type
      comment: "Type of recovery: Salvage, Subrogation, Reinsurance."
    - name: "recovery_status"
      expr: recovery_status
      comment: "Current status of the recovery: Open, Collected, Closed, Written Off."
    - name: "method"
      expr: method
      comment: "Method of recovery: Negotiation, Litigation, Arbitration."
    - name: "salvage_type"
      expr: salvage_type
      comment: "Type of salvage: Vehicle, Property, Equipment."
    - name: "subrogation_basis"
      expr: subrogation_basis
      comment: "Basis for subrogation claim."
    - name: "litigation_flag"
      expr: litigation_flag
      comment: "Indicates whether the recovery involves litigation."
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Indicates whether the recovery was referred to Special Investigation Unit."
    - name: "state_code"
      expr: state_code
      comment: "State code for the recovery jurisdiction."
  measures:
    - name: "total_recovery_count"
      expr: COUNT(1)
      comment: "Total number of recovery transactions."
    - name: "total_demand_amount"
      expr: SUM(CAST(demand_amount AS DOUBLE))
      comment: "Total recovery amount demanded."
    - name: "total_collected_amount"
      expr: SUM(CAST(collected_amount AS DOUBLE))
      comment: "Total recovery amount collected."
    - name: "total_net_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net recovery amount after expenses."
    - name: "total_collection_expense_amount"
      expr: SUM(CAST(collection_expense_amount AS DOUBLE))
      comment: "Total expense incurred to collect recoveries."
    - name: "avg_collected_amount"
      expr: AVG(CAST(collected_amount AS DOUBLE))
      comment: "Average recovery amount collected per transaction."
    - name: "avg_net_amount"
      expr: AVG(CAST(net_amount AS DOUBLE))
      comment: "Average net recovery amount per transaction."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with recoveries."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with recoveries."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_claim_expense`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim expense transactions tracking LAE, DCC, and AO expenses with approval status and reinsurance recoverables per claim exposure and accounting period."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense`"
  dimensions:
    - name: "expense_date"
      expr: expense_date
      comment: "Date the expense was incurred."
    - name: "expense_year"
      expr: YEAR(expense_date)
      comment: "Calendar year of expense incurrence."
    - name: "expense_month"
      expr: DATE_TRUNC('MONTH', expense_date)
      comment: "Month of expense incurrence for trending."
    - name: "payment_date"
      expr: payment_date
      comment: "Date the expense was paid."
    - name: "approval_date"
      expr: approval_date
      comment: "Date the expense was approved."
    - name: "invoice_date"
      expr: invoice_date
      comment: "Date of the expense invoice."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying loss event."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year in which the loss occurred."
    - name: "expense_type"
      expr: expense_type
      comment: "Type of expense: LAE, DCC, AO, Legal, Medical Review."
    - name: "expense_status"
      expr: expense_status
      comment: "Current status of the expense: Pending, Approved, Paid, Rejected."
    - name: "approval_status"
      expr: approval_status
      comment: "Approval status of the expense."
    - name: "lae_category"
      expr: lae_category
      comment: "Category of LAE: Allocated, Unallocated."
    - name: "payment_method"
      expr: payment_method
      comment: "Method of payment for the expense."
    - name: "is_dcc_expense"
      expr: is_dcc_expense
      comment: "Indicates whether the expense is a Defense and Cost Containment expense."
    - name: "is_recoverable"
      expr: is_recoverable
      comment: "Indicates whether the expense is recoverable from reinsurance."
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Indicates whether the expense is a reversal transaction."
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Indicates whether the claim was referred to Special Investigation Unit."
  measures:
    - name: "total_expense_count"
      expr: COUNT(1)
      comment: "Total number of expense transactions."
    - name: "total_expense_amount"
      expr: SUM(CAST(expense_amount AS DOUBLE))
      comment: "Total expense amount incurred."
    - name: "total_functional_currency_amount"
      expr: SUM(CAST(functional_currency_amount AS DOUBLE))
      comment: "Total expense amount in functional currency."
    - name: "total_reinsurance_recoverable_amount"
      expr: SUM(CAST(reinsurance_recoverable_amount AS DOUBLE))
      comment: "Total reinsurance recoverable amount on expenses."
    - name: "avg_expense_amount"
      expr: AVG(CAST(expense_amount AS DOUBLE))
      comment: "Average expense amount per transaction."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with expenses."
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with expenses."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_reinsurance_recovery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance recovery transactions tracking ceded loss and LAE amounts billed, collected, and outstanding per reinsurance agreement and claim exposure."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery`"
  dimensions:
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying loss event."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year in which the loss occurred."
    - name: "recovery_type"
      expr: recovery_type
      comment: "Type of reinsurance recovery: Treaty, Facultative."
    - name: "recovery_status"
      expr: recovery_status
      comment: "Current status of the recovery: Billed, Collected, Overdue, Disputed."
    - name: "bordereaux_period"
      expr: bordereaux_period
      comment: "Bordereaux reporting period for the recovery."
  measures:
    - name: "total_recovery_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance recovery transactions."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with reinsurance recoveries."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_ibnr_estimate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "IBNR and IBNER reserve estimates by actuarial method, accident year, and line of business for reserving and financial reporting."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate`"
  dimensions:
    - name: "valuation_date"
      expr: valuation_date
      comment: "Date at which the IBNR estimate was calculated."
    - name: "valuation_year"
      expr: YEAR(valuation_date)
      comment: "Calendar year of IBNR valuation."
    - name: "valuation_month"
      expr: DATE_TRUNC('MONTH', valuation_date)
      comment: "Month of IBNR valuation for trending."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for which IBNR is estimated."
    - name: "estimate_type"
      expr: estimate_type
      comment: "Type of estimate: IBNR, IBNER, LAE IBNR."
    - name: "estimate_status"
      expr: estimate_status
      comment: "Current status of the estimate: Draft, Final, Approved."
    - name: "development_method"
      expr: development_method
      comment: "Actuarial development method used: Chain Ladder, Bornhuetter-Ferguson, Cape Cod."
    - name: "reserving_basis"
      expr: reserving_basis
      comment: "Basis of reserving: Gross, Net of Reinsurance."
    - name: "is_cat_included"
      expr: is_cat_included
      comment: "Indicates whether catastrophe losses are included in the estimate."
    - name: "is_reinsurance_net"
      expr: is_reinsurance_net
      comment: "Indicates whether the estimate is net of reinsurance."
    - name: "lob_description"
      expr: lob_description
      comment: "Line of business description for the estimate."
  measures:
    - name: "total_estimate_count"
      expr: COUNT(1)
      comment: "Total number of IBNR estimates."
    - name: "total_ibnr_amt"
      expr: SUM(CAST(ibnr_amt AS DOUBLE))
      comment: "Total IBNR reserve amount."
    - name: "total_ibner_amt"
      expr: SUM(CAST(ibner_amt AS DOUBLE))
      comment: "Total IBNER reserve amount."
    - name: "total_lae_ibnr_amt"
      expr: SUM(CAST(lae_ibnr_amt AS DOUBLE))
      comment: "Total LAE IBNR reserve amount."
    - name: "total_ultimate_loss_amt"
      expr: SUM(CAST(ultimate_loss_amt AS DOUBLE))
      comment: "Total ultimate loss amount estimated."
    - name: "total_case_reserve_amt"
      expr: SUM(CAST(case_reserve_amt AS DOUBLE))
      comment: "Total case reserve amount."
    - name: "total_paid_losses_amt"
      expr: SUM(CAST(paid_losses_amt AS DOUBLE))
      comment: "Total paid losses amount."
    - name: "total_reported_losses_amt"
      expr: SUM(CAST(reported_losses_amt AS DOUBLE))
      comment: "Total reported losses amount."
    - name: "total_reserve_change_amt"
      expr: SUM(CAST(reserve_change_amt AS DOUBLE))
      comment: "Total reserve change amount from prior estimate."
    - name: "total_earned_premium_amt"
      expr: SUM(CAST(earned_premium_amt AS DOUBLE))
      comment: "Total earned premium amount for the accident year."
    - name: "avg_expected_loss_ratio"
      expr: AVG(CAST(expected_loss_ratio AS DOUBLE))
      comment: "Average expected loss ratio used in estimates."
    - name: "avg_cumulative_ldf"
      expr: AVG(CAST(cumulative_ldf AS DOUBLE))
      comment: "Average cumulative loss development factor."
    - name: "avg_tail_factor"
      expr: AVG(CAST(tail_factor AS DOUBLE))
      comment: "Average tail factor applied to development."
    - name: "total_claim_count_reported"
      expr: SUM(CAST(claim_count_reported AS DOUBLE))
      comment: "Total number of claims reported."
    - name: "total_claim_count_ultimate"
      expr: SUM(CAST(claim_count_ultimate AS DOUBLE))
      comment: "Total ultimate claim count estimated."
    - name: "total_ibnr_claim_count"
      expr: SUM(CAST(ibnr_claim_count AS DOUBLE))
      comment: "Total IBNR claim count estimated."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claimfinancials_loss_triangle`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Loss development triangle data capturing incurred, paid, and ultimate loss amounts by accident year and development period for actuarial reserving and trend analysis."
  source: "`vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle`"
  dimensions:
    - name: "evaluation_date"
      expr: evaluation_date
      comment: "Date at which the loss triangle was evaluated."
    - name: "evaluation_year"
      expr: YEAR(evaluation_date)
      comment: "Calendar year of loss triangle evaluation."
    - name: "evaluation_month"
      expr: DATE_TRUNC('MONTH', evaluation_date)
      comment: "Month of loss triangle evaluation for trending."
    - name: "cohort_year"
      expr: cohort_year
      comment: "Cohort year for the loss triangle: Accident Year, Policy Year, Report Year."
    - name: "cohort_type"
      expr: cohort_type
      comment: "Type of cohort: Accident Year, Policy Year, Report Year."
    - name: "development_period"
      expr: development_period
      comment: "Number of periods since cohort origin for development analysis."
    - name: "triangle_type"
      expr: triangle_type
      comment: "Type of triangle: Incurred, Paid, Case Reserve, IBNR."
    - name: "triangle_status"
      expr: triangle_status
      comment: "Current status of the triangle: Draft, Final, Approved."
    - name: "lob_name"
      expr: lob_name
      comment: "Line of business name for the triangle."
    - name: "gross_net_indicator"
      expr: gross_net_indicator
      comment: "Indicates whether the triangle is Gross or Net of reinsurance."
    - name: "catastrophe_flag"
      expr: catastrophe_flag
      comment: "Indicates whether catastrophe losses are included in the triangle."
    - name: "is_diagonal"
      expr: is_diagonal
      comment: "Indicates whether the cell is on the diagonal of the triangle."
    - name: "is_tail_period"
      expr: is_tail_period
      comment: "Indicates whether the development period is in the tail."
    - name: "reserving_method"
      expr: reserving_method
      comment: "Reserving method applied to the triangle."
    - name: "reinsurance_program_type"
      expr: reinsurance_program_type
      comment: "Type of reinsurance program applied."
  measures:
    - name: "total_triangle_cell_count"
      expr: COUNT(1)
      comment: "Total number of loss triangle cells."
    - name: "total_incurred_loss_amount"
      expr: SUM(CAST(incurred_loss_amount AS DOUBLE))
      comment: "Total incurred loss amount in the triangle."
    - name: "total_paid_loss_amount"
      expr: SUM(CAST(paid_loss_amount AS DOUBLE))
      comment: "Total paid loss amount in the triangle."
    - name: "total_case_reserve_amount"
      expr: SUM(CAST(case_reserve_amount AS DOUBLE))
      comment: "Total case reserve amount in the triangle."
    - name: "total_ibnr_amount"
      expr: SUM(CAST(ibnr_amount AS DOUBLE))
      comment: "Total IBNR amount in the triangle."
    - name: "total_ultimate_loss_amount"
      expr: SUM(CAST(ultimate_loss_amount AS DOUBLE))
      comment: "Total ultimate loss amount estimated in the triangle."
    - name: "total_paid_alae_amount"
      expr: SUM(CAST(paid_alae_amount AS DOUBLE))
      comment: "Total paid ALAE amount in the triangle."
    - name: "total_case_alae_reserve_amount"
      expr: SUM(CAST(case_alae_reserve_amount AS DOUBLE))
      comment: "Total case ALAE reserve amount in the triangle."
    - name: "total_ibnr_alae_amount"
      expr: SUM(CAST(ibnr_alae_amount AS DOUBLE))
      comment: "Total IBNR ALAE amount in the triangle."
    - name: "total_ultimate_alae_amount"
      expr: SUM(CAST(ultimate_alae_amount AS DOUBLE))
      comment: "Total ultimate ALAE amount estimated in the triangle."
    - name: "total_reserve_development_amount"
      expr: SUM(CAST(reserve_development_amount AS DOUBLE))
      comment: "Total reserve development amount from prior period."
    - name: "total_earned_premium_amount"
      expr: SUM(CAST(earned_premium_amount AS DOUBLE))
      comment: "Total earned premium amount for the cohort."
    - name: "total_written_premium_amount"
      expr: SUM(CAST(written_premium_amount AS DOUBLE))
      comment: "Total written premium amount for the cohort."
    - name: "avg_development_factor"
      expr: AVG(CAST(development_factor AS DOUBLE))
      comment: "Average loss development factor for the period."
    - name: "avg_tail_factor"
      expr: AVG(CAST(tail_factor AS DOUBLE))
      comment: "Average tail factor applied to development."
    - name: "total_claim_count_reported"
      expr: SUM(CAST(claim_count_reported AS DOUBLE))
      comment: "Total number of claims reported in the triangle."
    - name: "total_claim_count_open"
      expr: SUM(CAST(claim_count_open AS DOUBLE))
      comment: "Total number of open claims in the triangle."
    - name: "total_claim_count_closed"
      expr: SUM(CAST(claim_count_closed AS DOUBLE))
      comment: "Total number of closed claims in the triangle."
$$;