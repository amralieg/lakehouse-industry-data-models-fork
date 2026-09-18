-- Metric views for domain: reservespayments | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reservespayments_loss_reserve`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core loss reserve metrics tracking reserve adequacy, development, and incurred losses across policies, claims, and coverages for actuarial and financial reporting."
  source: "`vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve`"
  dimensions:
    - name: "reserve_status"
      expr: reserve_status
      comment: "Current status of the loss reserve (open, closed, pending review)."
    - name: "reserve_type"
      expr: reserve_type
      comment: "Type of reserve (case, IBNR, ALAE, ULAE, salvage, subrogation)."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss reserve aggregation and development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for reserve segmentation and trend analysis."
    - name: "report_year"
      expr: report_year
      comment: "Report year for statutory and financial reporting."
    - name: "cat_event_indicator"
      expr: cat_event_indicator
      comment: "Flag indicating whether the reserve is associated with a catastrophe event."
    - name: "large_loss_indicator"
      expr: large_loss_indicator
      comment: "Flag indicating whether the reserve exceeds the large loss threshold."
    - name: "litigation_indicator"
      expr: litigation_indicator
      comment: "Flag indicating whether the claim is in litigation, affecting reserve volatility."
    - name: "reserve_adequacy_status"
      expr: reserve_adequacy_status
      comment: "Actuarial assessment of reserve adequacy (adequate, deficient, redundant)."
    - name: "reserve_change_reason"
      expr: reserve_change_reason
      comment: "Reason code for reserve changes (new information, settlement, development)."
    - name: "actuarial_segment_code"
      expr: actuarial_segment_code
      comment: "Actuarial segment code for reserve grouping and analysis."
    - name: "stat_line_code"
      expr: stat_line_code
      comment: "Statutory line code for regulatory reporting and Schedule P alignment."
    - name: "reserve_method"
      expr: reserve_method
      comment: "Method used to establish the reserve (case-by-case, formula, actuarial)."
  measures:
    - name: "total_current_reserve_amount"
      expr: SUM(CAST(current_reserve_amount AS DOUBLE))
      comment: "Total current reserve amount across all loss reserves, key indicator of outstanding liability."
    - name: "total_initial_reserve_amount"
      expr: SUM(CAST(initial_reserve_amount AS DOUBLE))
      comment: "Total initial reserve amount at establishment, used to measure reserve development."
    - name: "total_incurred_loss_amount"
      expr: SUM(CAST(incurred_loss_amount AS DOUBLE))
      comment: "Total incurred losses (paid plus outstanding reserves), critical for loss ratio and profitability analysis."
    - name: "total_paid_losses_to_date"
      expr: SUM(CAST(paid_losses_to_date AS DOUBLE))
      comment: "Total paid losses to date, used to calculate outstanding reserves and cash flow."
    - name: "total_net_reserve_amount"
      expr: SUM(CAST(net_reserve_amount AS DOUBLE))
      comment: "Total net reserve amount after reinsurance recoverable, key for net retained liability."
    - name: "total_alae_reserve_amount"
      expr: SUM(CAST(alae_reserve_amount AS DOUBLE))
      comment: "Total allocated loss adjustment expense reserves, critical for total claim cost estimation."
    - name: "total_ulae_reserve_amount"
      expr: SUM(CAST(ulae_reserve_amount AS DOUBLE))
      comment: "Total unallocated loss adjustment expense reserves, used for overhead cost allocation."
    - name: "total_ibnr_amount"
      expr: SUM(CAST(ibnr_amount AS DOUBLE))
      comment: "Total incurred but not reported reserve amount, key actuarial estimate for unreported claims."
    - name: "total_ibner_amount"
      expr: SUM(CAST(ibner_amount AS DOUBLE))
      comment: "Total incurred but not enough reported amount, actuarial estimate for development on known claims."
    - name: "total_reinsurance_recoverable_amount"
      expr: SUM(CAST(reinsurance_recoverable_amount AS DOUBLE))
      comment: "Total reinsurance recoverable on reserves, critical for net exposure and ceded liability tracking."
    - name: "total_salvage_reserve_amount"
      expr: SUM(CAST(salvage_reserve_amount AS DOUBLE))
      comment: "Total salvage reserve amount, expected recovery from salvage reducing net loss."
    - name: "total_subrogation_reserve_amount"
      expr: SUM(CAST(subrogation_reserve_amount AS DOUBLE))
      comment: "Total subrogation reserve amount, expected recovery from third parties reducing net loss."
    - name: "reserve_count"
      expr: COUNT(1)
      comment: "Total count of loss reserve records, used for volume and workload analysis."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Distinct count of claims with reserves, key for claim frequency and reserve penetration analysis."
    - name: "avg_current_reserve_amount"
      expr: AVG(CAST(current_reserve_amount AS DOUBLE))
      comment: "Average current reserve amount per reserve record, indicator of reserve severity."
    - name: "avg_incurred_loss_amount"
      expr: AVG(CAST(incurred_loss_amount AS DOUBLE))
      comment: "Average incurred loss amount per reserve, key severity metric for loss cost analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reservespayments_payment_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Payment transaction metrics tracking gross, net, and deduction amounts across claim payments for cash flow, settlement velocity, and financial reporting."
  source: "`vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction`"
  dimensions:
    - name: "payment_status"
      expr: payment_status
      comment: "Current status of the payment (issued, cleared, voided, reissued)."
    - name: "payment_type"
      expr: payment_type
      comment: "Type of payment (indemnity, expense, settlement, advance)."
    - name: "payment_method"
      expr: payment_method
      comment: "Method of payment (check, ACH, wire, EFT)."
    - name: "payee_type"
      expr: payee_type
      comment: "Type of payee (claimant, insured, vendor, attorney, medical provider)."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for payment aggregation and loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for payment segmentation and profitability analysis."
    - name: "is_cat_loss"
      expr: is_cat_loss
      comment: "Flag indicating whether the payment is related to a catastrophe event."
    - name: "is_1099_reportable"
      expr: is_1099_reportable
      comment: "Flag indicating whether the payment is reportable on IRS Form 1099."
    - name: "reinsurance_recoverable_flag"
      expr: reinsurance_recoverable_flag
      comment: "Flag indicating whether the payment is recoverable from reinsurance."
    - name: "subrogation_flag"
      expr: subrogation_flag
      comment: "Flag indicating whether the payment is subject to subrogation recovery."
    - name: "loss_category"
      expr: loss_category
      comment: "Category of loss (property, liability, medical, legal)."
    - name: "line_of_business_code"
      expr: line_of_business_code
      comment: "Line of business code for payment segmentation and profitability analysis."
    - name: "ofac_screening_status"
      expr: ofac_screening_status
      comment: "OFAC screening status for compliance and fraud prevention."
    - name: "void_reason"
      expr: void_reason
      comment: "Reason for voiding the payment (duplicate, error, fraud)."
  measures:
    - name: "total_gross_amount"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross payment amount before deductions, key for total claim settlement cost."
    - name: "total_net_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net payment amount after deductions and withholdings, actual cash disbursed."
    - name: "total_deduction_amount"
      expr: SUM(CAST(deduction_amount AS DOUBLE))
      comment: "Total deduction amount (deductibles, offsets), reducing gross payment to net."
    - name: "total_tax_withholding_amount"
      expr: SUM(CAST(tax_withholding_amount AS DOUBLE))
      comment: "Total tax withholding amount for IRS compliance and 1099 reporting."
    - name: "total_sir_deductible_amount"
      expr: SUM(CAST(sir_deductible_amount AS DOUBLE))
      comment: "Total self-insured retention deductible amount, reducing insurer liability."
    - name: "total_ri_recoverable_amount"
      expr: SUM(CAST(ri_recoverable_amount AS DOUBLE))
      comment: "Total reinsurance recoverable amount on payments, key for ceded loss tracking."
    - name: "payment_count"
      expr: COUNT(1)
      comment: "Total count of payment transactions, used for payment velocity and workload analysis."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Distinct count of claims with payments, key for settlement frequency and claim closure rate."
    - name: "distinct_payee_count"
      expr: COUNT(DISTINCT payee_id)
      comment: "Distinct count of payees receiving payments, used for vendor and claimant concentration analysis."
    - name: "avg_gross_amount"
      expr: AVG(CAST(gross_amount AS DOUBLE))
      comment: "Average gross payment amount per transaction, indicator of payment severity."
    - name: "avg_net_amount"
      expr: AVG(CAST(net_amount AS DOUBLE))
      comment: "Average net payment amount per transaction, key for cash flow planning."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reservespayments_ibnr_estimate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "IBNR estimate metrics tracking incurred but not reported reserves, actuarial methods, and ultimate loss projections for reserve adequacy and financial planning."
  source: "`vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate`"
  dimensions:
    - name: "estimate_status"
      expr: estimate_status
      comment: "Current status of the IBNR estimate (draft, approved, superseded)."
    - name: "actuarial_method"
      expr: actuarial_method
      comment: "Actuarial method used for IBNR estimation (chain ladder, Bornhuetter-Ferguson, expected loss ratio)."
    - name: "reserve_type"
      expr: reserve_type
      comment: "Type of reserve estimated (IBNR, IBNER, case reserve)."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for IBNR estimation and loss development analysis."
    - name: "is_cat_estimate"
      expr: is_cat_estimate
      comment: "Flag indicating whether the IBNR estimate is for a catastrophe event."
    - name: "lob_name"
      expr: lob_name
      comment: "Line of business name for IBNR segmentation and reserve analysis."
    - name: "statutory_basis"
      expr: statutory_basis
      comment: "Statutory basis for IBNR estimation (statutory, GAAP, IFRS)."
    - name: "filing_period"
      expr: filing_period
      comment: "Filing period for regulatory reporting and reserve disclosure."
    - name: "data_source_system"
      expr: data_source_system
      comment: "Source system for IBNR data, used for data lineage and quality tracking."
  measures:
    - name: "total_ibnr_amount"
      expr: SUM(CAST(ibnr_amount AS DOUBLE))
      comment: "Total incurred but not reported reserve amount, critical actuarial estimate for unreported claims."
    - name: "total_ibner_amount"
      expr: SUM(CAST(ibner_amount AS DOUBLE))
      comment: "Total incurred but not enough reported amount, actuarial estimate for development on known claims."
    - name: "total_case_reserve_amount"
      expr: SUM(CAST(case_reserve_amount AS DOUBLE))
      comment: "Total case reserve amount, adjuster-set reserves on reported claims."
    - name: "total_reserve_amount"
      expr: SUM(CAST(total_reserve_amount AS DOUBLE))
      comment: "Total reserve amount (case plus IBNR plus IBNER), comprehensive reserve liability."
    - name: "total_ultimate_loss_amount"
      expr: SUM(CAST(ultimate_loss_amount AS DOUBLE))
      comment: "Total ultimate loss amount, actuarial projection of total incurred losses at maturity."
    - name: "total_paid_losses_amount"
      expr: SUM(CAST(paid_losses_amount AS DOUBLE))
      comment: "Total paid losses amount to date, used to calculate outstanding reserves."
    - name: "total_reported_losses_amount"
      expr: SUM(CAST(reported_losses_amount AS DOUBLE))
      comment: "Total reported losses amount (case reserves plus paid), basis for IBNR calculation."
    - name: "total_earned_premium_amount"
      expr: SUM(CAST(earned_premium_amount AS DOUBLE))
      comment: "Total earned premium amount, denominator for loss ratio and ultimate loss ratio calculation."
    - name: "total_ulae_amount"
      expr: SUM(CAST(ulae_amount AS DOUBLE))
      comment: "Total unallocated loss adjustment expense amount, overhead cost estimate for claim handling."
    - name: "total_ceded_reserve_amount"
      expr: SUM(CAST(ceded_reserve_amount AS DOUBLE))
      comment: "Total ceded reserve amount to reinsurance, reducing net retained liability."
    - name: "total_net_of_reinsurance_amount"
      expr: SUM(CAST(net_of_reinsurance_amount AS DOUBLE))
      comment: "Total net of reinsurance reserve amount, net retained reserve after cessions."
    - name: "total_reserve_development_amount"
      expr: SUM(CAST(reserve_development_amount AS DOUBLE))
      comment: "Total reserve development amount (change from prior period), key for reserve adequacy assessment."
    - name: "total_high_estimate_amount"
      expr: SUM(CAST(high_estimate_amount AS DOUBLE))
      comment: "Total high estimate amount, upper bound of IBNR range for risk assessment."
    - name: "total_low_estimate_amount"
      expr: SUM(CAST(low_estimate_amount AS DOUBLE))
      comment: "Total low estimate amount, lower bound of IBNR range for risk assessment."
    - name: "ibnr_estimate_count"
      expr: COUNT(1)
      comment: "Total count of IBNR estimate records, used for actuarial workload and version tracking."
    - name: "avg_ultimate_loss_ratio"
      expr: AVG(CAST(ultimate_loss_ratio AS DOUBLE))
      comment: "Average ultimate loss ratio across estimates, key profitability and pricing indicator."
    - name: "avg_expected_loss_ratio"
      expr: AVG(CAST(expected_loss_ratio AS DOUBLE))
      comment: "Average expected loss ratio, actuarial assumption for IBNR estimation."
    - name: "avg_confidence_level"
      expr: AVG(CAST(confidence_level AS DOUBLE))
      comment: "Average confidence level of IBNR estimates, indicator of estimation uncertainty."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reservespayments_recovery_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Recovery transaction metrics tracking salvage, subrogation, and reinsurance recoveries to reduce net loss and improve profitability."
  source: "`vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction`"
  dimensions:
    - name: "recovery_status"
      expr: recovery_status
      comment: "Current status of the recovery (open, collected, closed, written off)."
    - name: "recovery_type"
      expr: recovery_type
      comment: "Type of recovery (salvage, subrogation, reinsurance, deductible)."
    - name: "recovery_method"
      expr: recovery_method
      comment: "Method of recovery (negotiation, litigation, arbitration, direct billing)."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for recovery aggregation and loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for recovery segmentation and profitability analysis."
    - name: "is_cat_event"
      expr: is_cat_event
      comment: "Flag indicating whether the recovery is related to a catastrophe event."
    - name: "is_intercompany"
      expr: is_intercompany
      comment: "Flag indicating whether the recovery is from an intercompany transaction."
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code for recovery segmentation and profitability analysis."
    - name: "recovery_basis"
      expr: recovery_basis
      comment: "Basis for recovery (liability, negligence, contract, statute)."
    - name: "at_fault_party_insurer"
      expr: at_fault_party_insurer
      comment: "At-fault party insurer name for subrogation tracking and collection."
    - name: "state_code"
      expr: state_code
      comment: "State code for recovery jurisdiction and legal analysis."
    - name: "write_off_reason"
      expr: write_off_reason
      comment: "Reason for writing off uncollectible recovery (statute expired, bankruptcy, uneconomical)."
  measures:
    - name: "total_gross_recovery_amount"
      expr: SUM(CAST(gross_recovery_amount AS DOUBLE))
      comment: "Total gross recovery amount before expenses, key for total recovery potential."
    - name: "total_net_recovery_amount"
      expr: SUM(CAST(net_recovery_amount AS DOUBLE))
      comment: "Total net recovery amount after collection expenses, actual recovery benefit."
    - name: "total_collection_expense_amount"
      expr: SUM(CAST(collection_expense_amount AS DOUBLE))
      comment: "Total collection expense amount (attorney fees, court costs), reducing net recovery."
    - name: "total_net_retained_recovery_amount"
      expr: SUM(CAST(net_retained_recovery_amount AS DOUBLE))
      comment: "Total net retained recovery amount after reinsurance share, net benefit to insurer."
    - name: "total_ri_share_amount"
      expr: SUM(CAST(ri_share_amount AS DOUBLE))
      comment: "Total reinsurance share of recovery amount, ceded recovery to reinsurers."
    - name: "total_reserve_release_amount"
      expr: SUM(CAST(reserve_release_amount AS DOUBLE))
      comment: "Total reserve release amount from recovery, improving reserve adequacy and profitability."
    - name: "total_write_off_amount"
      expr: SUM(CAST(write_off_amount AS DOUBLE))
      comment: "Total write-off amount for uncollectible recoveries, reducing recovery potential."
    - name: "total_subrogation_demand_amount"
      expr: SUM(CAST(subrogation_demand_amount AS DOUBLE))
      comment: "Total subrogation demand amount sent to third parties, initial recovery target."
    - name: "recovery_count"
      expr: COUNT(1)
      comment: "Total count of recovery transactions, used for recovery frequency and workload analysis."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Distinct count of claims with recoveries, key for recovery penetration and effectiveness."
    - name: "avg_gross_recovery_amount"
      expr: AVG(CAST(gross_recovery_amount AS DOUBLE))
      comment: "Average gross recovery amount per transaction, indicator of recovery severity."
    - name: "avg_net_recovery_amount"
      expr: AVG(CAST(net_recovery_amount AS DOUBLE))
      comment: "Average net recovery amount per transaction, key for recovery efficiency."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reservespayments_reinsurance_recoverable`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance recoverable metrics tracking ceded loss and ALAE amounts, collectability, and reinsurer credit exposure for net retained liability and capital management."
  source: "`vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable`"
  dimensions:
    - name: "recoverable_status"
      expr: recoverable_status
      comment: "Current status of the reinsurance recoverable (billed, collected, disputed, uncollectible)."
    - name: "recoverable_type"
      expr: recoverable_type
      comment: "Type of recoverable (paid loss, case reserve, IBNR, ALAE)."
    - name: "reinsurance_type"
      expr: reinsurance_type
      comment: "Type of reinsurance (treaty, facultative, pool)."
    - name: "treaty_type"
      expr: treaty_type
      comment: "Type of treaty (quota share, surplus, excess of loss, catastrophe)."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for recoverable aggregation and loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for recoverable segmentation and profitability analysis."
    - name: "cat_event_indicator"
      expr: cat_event_indicator
      comment: "Flag indicating whether the recoverable is related to a catastrophe event."
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Flag indicating whether the reinsurer is authorized, affecting credit for reserves."
    - name: "collectability_status"
      expr: collectability_status
      comment: "Collectability status of the recoverable (current, overdue, disputed, uncollectible)."
    - name: "reinsurer_credit_rating"
      expr: reinsurer_credit_rating
      comment: "Credit rating of the reinsurer, key for credit risk and collateral assessment."
    - name: "collateral_type"
      expr: collateral_type
      comment: "Type of collateral held (letter of credit, trust fund, cash)."
    - name: "dispute_reason"
      expr: dispute_reason
      comment: "Reason for dispute on recoverable (coverage interpretation, calculation error, late notice)."
    - name: "accounting_basis"
      expr: accounting_basis
      comment: "Accounting basis for recoverable (statutory, GAAP, IFRS)."
  measures:
    - name: "total_ri_recoverable_loss_amount"
      expr: SUM(CAST(ri_recoverable_loss_amount AS DOUBLE))
      comment: "Total reinsurance recoverable loss amount, key for ceded loss tracking and net retained liability."
    - name: "total_ri_recoverable_alae_amount"
      expr: SUM(CAST(ri_recoverable_alae_amount AS DOUBLE))
      comment: "Total reinsurance recoverable ALAE amount, ceded loss adjustment expense."
    - name: "total_ri_recoverable_total_amount"
      expr: SUM(CAST(ri_recoverable_total_amount AS DOUBLE))
      comment: "Total reinsurance recoverable amount (loss plus ALAE), comprehensive ceded liability."
    - name: "total_gross_loss_amount"
      expr: SUM(CAST(gross_loss_amount AS DOUBLE))
      comment: "Total gross loss amount before reinsurance, basis for cession calculation."
    - name: "total_gross_alae_amount"
      expr: SUM(CAST(gross_alae_amount AS DOUBLE))
      comment: "Total gross ALAE amount before reinsurance, basis for ceded ALAE calculation."
    - name: "total_collected_amount"
      expr: SUM(CAST(collected_amount AS DOUBLE))
      comment: "Total collected amount from reinsurers, actual cash received reducing net loss."
    - name: "total_outstanding_recoverable_amount"
      expr: SUM(CAST(outstanding_recoverable_amount AS DOUBLE))
      comment: "Total outstanding recoverable amount not yet collected, key for cash flow and credit risk."
    - name: "total_uncollectible_amount"
      expr: SUM(CAST(uncollectible_amount AS DOUBLE))
      comment: "Total uncollectible amount written off, reinsurer credit loss."
    - name: "total_retention_amount"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount (deductible, SIR), insurer retained loss before reinsurance."
    - name: "total_collateral_held_amount"
      expr: SUM(CAST(collateral_held_amount AS DOUBLE))
      comment: "Total collateral held amount securing recoverable, mitigating credit risk."
    - name: "recoverable_count"
      expr: COUNT(1)
      comment: "Total count of reinsurance recoverable records, used for cession volume and workload analysis."
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Distinct count of claims with reinsurance recoverables, key for cession penetration."
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Distinct count of reinsurers with recoverables, used for reinsurer concentration and credit risk."
    - name: "avg_ri_share_percent"
      expr: AVG(CAST(ri_share_percent AS DOUBLE))
      comment: "Average reinsurance share percentage, indicator of cession rate and retention strategy."
    - name: "avg_ri_recoverable_total_amount"
      expr: AVG(CAST(ri_recoverable_total_amount AS DOUBLE))
      comment: "Average reinsurance recoverable amount per record, indicator of ceded severity."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reservespayments_reserve_study`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reserve study metrics tracking actuarial reserve estimates, loss development factors, and reserve adequacy for financial planning and regulatory compliance."
  source: "`vibe_pc_insurance_v499`.`reservespayments`.`reserve_study`"
  dimensions:
    - name: "study_status"
      expr: study_status
      comment: "Current status of the reserve study (draft, approved, superseded)."
    - name: "study_type"
      expr: study_type
      comment: "Type of reserve study (quarterly, annual, special, regulatory)."
    - name: "actuarial_method"
      expr: actuarial_method
      comment: "Actuarial method used for reserve estimation (chain ladder, Bornhuetter-Ferguson, expected loss ratio)."
    - name: "line_of_business"
      expr: line_of_business
      comment: "Line of business for reserve study segmentation and analysis."
    - name: "coverage_type"
      expr: coverage_type
      comment: "Coverage type for reserve study segmentation (property, liability, medical)."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for reserve study aggregation and loss development analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for reserve study segmentation and profitability analysis."
    - name: "report_year"
      expr: report_year
      comment: "Report year for reserve study filing and regulatory reporting."
    - name: "data_quality_rating"
      expr: data_quality_rating
      comment: "Data quality rating for reserve study (high, medium, low), affecting confidence."
    - name: "actuary_credential"
      expr: actuary_credential
      comment: "Credential of the actuary performing the study (FCAS, ACAS, MAAA)."
  measures:
    - name: "total_reserve_estimate_amount"
      expr: SUM(CAST(reserve_estimate_amount AS DOUBLE))
      comment: "Total reserve estimate amount from actuarial study, key for reserve adequacy and financial planning."
    - name: "total_ibnr_reserve_amount"
      expr: SUM(CAST(ibnr_reserve_amount AS DOUBLE))
      comment: "Total IBNR reserve amount from study, actuarial estimate for unreported claims."
    - name: "total_case_reserve_amount"
      expr: SUM(CAST(case_reserve_amount AS DOUBLE))
      comment: "Total case reserve amount from study, adjuster-set reserves on reported claims."
    - name: "total_alae_reserve_amount"
      expr: SUM(CAST(alae_reserve_amount AS DOUBLE))
      comment: "Total ALAE reserve amount from study, allocated loss adjustment expense estimate."
    - name: "total_ulae_reserve_amount"
      expr: SUM(CAST(ulae_reserve_amount AS DOUBLE))
      comment: "Total ULAE reserve amount from study, unallocated loss adjustment expense estimate."
    - name: "total_ultimate_loss_estimate_amount"
      expr: SUM(CAST(ultimate_loss_estimate_amount AS DOUBLE))
      comment: "Total ultimate loss estimate amount, actuarial projection of total incurred losses at maturity."
    - name: "total_paid_loss_amount"
      expr: SUM(CAST(paid_loss_amount AS DOUBLE))
      comment: "Total paid loss amount to date, used to calculate outstanding reserves."
    - name: "total_reserve_change_amount"
      expr: SUM(CAST(reserve_change_amount AS DOUBLE))
      comment: "Total reserve change amount from prior study, key for reserve development and adequacy."
    - name: "total_prior_reserve_amount"
      expr: SUM(CAST(prior_reserve_amount AS DOUBLE))
      comment: "Total prior reserve amount, baseline for reserve development analysis."
    - name: "total_salvage_subrogation_amount"
      expr: SUM(CAST(salvage_subrogation_amount AS DOUBLE))
      comment: "Total salvage and subrogation amount, expected recovery reducing net reserve."
    - name: "total_reserve_high_estimate_amount"
      expr: SUM(CAST(reserve_high_estimate_amount AS DOUBLE))
      comment: "Total high reserve estimate amount, upper bound for risk assessment."
    - name: "total_reserve_low_estimate_amount"
      expr: SUM(CAST(reserve_low_estimate_amount AS DOUBLE))
      comment: "Total low reserve estimate amount, lower bound for risk assessment."
    - name: "reserve_study_count"
      expr: COUNT(1)
      comment: "Total count of reserve study records, used for actuarial workload and version tracking."
    - name: "total_claim_count"
      expr: SUM(CAST(claim_count AS BIGINT))
      comment: "Total claim count from reserve study, used for frequency analysis."
    - name: "total_open_claim_count"
      expr: SUM(CAST(open_claim_count AS BIGINT))
      comment: "Total open claim count from reserve study, key for workload and reserve volatility."
    - name: "total_closed_claim_count"
      expr: SUM(CAST(closed_claim_count AS BIGINT))
      comment: "Total closed claim count from reserve study, used for closure rate and development analysis."
    - name: "total_ibnr_claim_count_estimate"
      expr: SUM(CAST(ibnr_claim_count_estimate AS BIGINT))
      comment: "Total IBNR claim count estimate, actuarial projection of unreported claim frequency."
    - name: "avg_loss_development_factor"
      expr: AVG(CAST(loss_development_factor AS DOUBLE))
      comment: "Average loss development factor, key actuarial parameter for reserve projection."
    - name: "avg_expected_loss_ratio"
      expr: AVG(CAST(expected_loss_ratio AS DOUBLE))
      comment: "Average expected loss ratio, actuarial assumption for reserve estimation."
    - name: "avg_confidence_level"
      expr: AVG(CAST(confidence_level AS DOUBLE))
      comment: "Average confidence level of reserve estimates, indicator of estimation uncertainty."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reservespayments_cat_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_v499`.`reservespayments`.`cat_event`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;