-- Metric views for domain: reinsurance | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_cession`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance cession KPIs tracking ceded premium, limits, retention, and share percentages by agreement type, treaty layer, and catastrophe exposure."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`"
  dimensions:
    - name: "agreement_type"
      expr: agreement_type
      comment: "Type of reinsurance agreement (Treaty, Facultative, etc.)"
    - name: "treaty_type"
      expr: treaty_type
      comment: "Treaty structure type (Quota Share, Excess of Loss, Stop Loss, etc.)"
    - name: "direction"
      expr: direction
      comment: "Cession direction (Ceded, Assumed, Retroceded)"
    - name: "reinsurance_cession_status"
      expr: reinsurance_cession_status
      comment: "Current status of the cession (Active, Expired, Cancelled, etc.)"
    - name: "is_catastrophe_cession"
      expr: is_catastrophe_cession
      comment: "Flag indicating whether this cession covers catastrophe exposure"
    - name: "reinsurer_authorization_status"
      expr: reinsurer_authorization_status
      comment: "Authorization status of the reinsurer (Authorized, Unauthorized, Certified)"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss-based treaty accounting"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for policy-based treaty accounting"
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the cession"
    - name: "expiration_date"
      expr: expiration_date
      comment: "Expiration date of the cession"
    - name: "booking_date"
      expr: booking_date
      comment: "Date the cession was booked in the system"
  measures:
    - name: "total_ceded_gwp"
      expr: SUM(CAST(ceded_gwp AS DOUBLE))
      comment: "Total ceded gross written premium across all cessions"
    - name: "total_ceded_earned_premium"
      expr: SUM(CAST(ceded_earned_premium AS DOUBLE))
      comment: "Total ceded earned premium recognized in the period"
    - name: "total_ceded_unearned_premium"
      expr: SUM(CAST(ceded_unearned_premium AS DOUBLE))
      comment: "Total ceded unearned premium reserve at period end"
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission_amount AS DOUBLE))
      comment: "Total ceding commission received from reinsurers"
    - name: "avg_ceding_commission_pct"
      expr: AVG(CAST(ceding_commission_pct AS DOUBLE))
      comment: "Average ceding commission percentage across cessions"
    - name: "total_ceded_limit"
      expr: SUM(CAST(ceded_limit AS DOUBLE))
      comment: "Total ceded limit capacity across all cessions"
    - name: "total_retention_amount"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount held by the cedant"
    - name: "avg_share_pct"
      expr: AVG(CAST(share_pct AS DOUBLE))
      comment: "Average reinsurer share percentage across cessions"
    - name: "avg_rate_on_line"
      expr: AVG(CAST(rate_on_line AS DOUBLE))
      comment: "Average rate on line (premium as percentage of limit) across cessions"
    - name: "total_ceded_case_reserve"
      expr: SUM(CAST(ceded_case_reserve AS DOUBLE))
      comment: "Total ceded case reserves for reported claims"
    - name: "total_ceded_ibnr_reserve"
      expr: SUM(CAST(ceded_ibnr_reserve AS DOUBLE))
      comment: "Total ceded IBNR (Incurred But Not Reported) reserves"
    - name: "total_collateral_amount"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral held for unauthorized or certified reinsurers"
    - name: "cession_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance cessions"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_party_id)
      comment: "Number of distinct reinsurers participating in cessions"
    - name: "distinct_agreement_count"
      expr: COUNT(DISTINCT ri_agreement_id)
      comment: "Number of distinct reinsurance agreements with active cessions"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_claim_cession`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance claim cession KPIs tracking ceded loss, LAE, reserves, and recoveries by treaty layer, catastrophe event, and reinsurer participation."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`"
  dimensions:
    - name: "cession_type"
      expr: cession_type
      comment: "Type of claim cession (Treaty, Facultative, Retrocession)"
    - name: "cession_status"
      expr: cession_status
      comment: "Current status of the claim cession (Pending, Billed, Collected, Disputed)"
    - name: "reinsurance_type"
      expr: reinsurance_type
      comment: "Reinsurance structure type (Proportional, Non-Proportional, etc.)"
    - name: "recovery_status"
      expr: recovery_status
      comment: "Status of recovery from reinsurer (Pending, Billed, Received, Overdue)"
    - name: "is_cat_claim"
      expr: is_cat_claim
      comment: "Flag indicating whether this is a catastrophe claim"
    - name: "commutation_flag"
      expr: commutation_flag
      comment: "Flag indicating whether the cession has been commuted"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying claim"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year of the underlying claim"
    - name: "treaty_year"
      expr: treaty_year
      comment: "Treaty year under which the claim is ceded"
    - name: "loss_date"
      expr: loss_date
      comment: "Date of loss for the underlying claim"
    - name: "report_date"
      expr: report_date
      comment: "Date the claim was reported to the reinsurer"
    - name: "schedule_f_category"
      expr: schedule_f_category
      comment: "Schedule F category for regulatory reporting (Authorized, Unauthorized, Certified)"
  measures:
    - name: "total_ceded_loss_amount"
      expr: SUM(CAST(ceded_loss_amount AS DOUBLE))
      comment: "Total ceded loss amount across all claim cessions"
    - name: "total_ceded_paid_loss"
      expr: SUM(CAST(ceded_paid_loss_amount AS DOUBLE))
      comment: "Total ceded paid loss amounts"
    - name: "total_ceded_reserve"
      expr: SUM(CAST(ceded_reserve_amount AS DOUBLE))
      comment: "Total ceded outstanding loss reserves"
    - name: "total_ceded_lae"
      expr: SUM(CAST(ceded_lae_amount AS DOUBLE))
      comment: "Total ceded loss adjustment expense"
    - name: "total_ceded_alae"
      expr: SUM(CAST(ceded_alae_amount AS DOUBLE))
      comment: "Total ceded allocated loss adjustment expense"
    - name: "total_gross_loss"
      expr: SUM(CAST(gross_loss_amount AS DOUBLE))
      comment: "Total gross loss amount before reinsurance"
    - name: "avg_cession_percentage"
      expr: AVG(CAST(cession_percentage AS DOUBLE))
      comment: "Average cession percentage across claim cessions"
    - name: "avg_reinsurer_participation_pct"
      expr: AVG(CAST(reinsurer_participation_pct AS DOUBLE))
      comment: "Average reinsurer participation percentage"
    - name: "total_layer_limit"
      expr: SUM(CAST(layer_limit_amount AS DOUBLE))
      comment: "Total treaty layer limit capacity applied to claims"
    - name: "total_layer_retention"
      expr: SUM(CAST(layer_retention_amount AS DOUBLE))
      comment: "Total retention amount at the treaty layer level"
    - name: "total_unl_amount"
      expr: SUM(CAST(unl_amount AS DOUBLE))
      comment: "Total ultimate net loss amount ceded"
    - name: "total_funds_held"
      expr: SUM(CAST(funds_held_amount AS DOUBLE))
      comment: "Total funds held by cedant on behalf of reinsurers"
    - name: "claim_cession_count"
      expr: COUNT(1)
      comment: "Total number of claim cessions"
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with reinsurance cessions"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers participating in claim recoveries"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_recovery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance recovery KPIs tracking billed, collected, and outstanding recovery amounts by reinsurer, agreement, and catastrophe event."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`"
  dimensions:
    - name: "recovery_status"
      expr: recovery_status
      comment: "Current status of the recovery (Pending, Billed, Collected, Overdue, Disputed)"
    - name: "movement_type"
      expr: movement_type
      comment: "Type of recovery movement (Initial, Adjustment, Reversal, Commutation)"
    - name: "payment_type"
      expr: payment_type
      comment: "Type of payment (Loss, LAE, ALAE, ULAE, Reinstatement Premium)"
    - name: "reserve_type"
      expr: reserve_type
      comment: "Type of reserve being recovered (Case, IBNR, LAE)"
    - name: "dispute_flag"
      expr: dispute_flag
      comment: "Flag indicating whether the recovery is in dispute"
    - name: "commutation_flag"
      expr: commutation_flag
      comment: "Flag indicating whether the recovery is part of a commutation"
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Flag indicating whether the reinsurer is authorized"
    - name: "collateral_required_flag"
      expr: collateral_required_flag
      comment: "Flag indicating whether collateral is required for this recovery"
    - name: "reinstatement_premium_flag"
      expr: reinstatement_premium_flag
      comment: "Flag indicating whether reinstatement premium applies"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying claim"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year of the underlying claim"
    - name: "calendar_year"
      expr: calendar_year
      comment: "Calendar year of the recovery transaction"
    - name: "movement_date"
      expr: movement_date
      comment: "Date of the recovery movement"
    - name: "billed_date"
      expr: billed_date
      comment: "Date the recovery was billed to the reinsurer"
    - name: "collected_date"
      expr: collected_date
      comment: "Date the recovery was collected from the reinsurer"
  measures:
    - name: "total_recovery_amount"
      expr: SUM(CAST(recovery_amount AS DOUBLE))
      comment: "Total recovery amount billed to reinsurers"
    - name: "total_recovery_amount_usd"
      expr: SUM(CAST(recovery_amount_usd AS DOUBLE))
      comment: "Total recovery amount in USD for consolidated reporting"
    - name: "total_collected_amount"
      expr: SUM(CAST(collected_amount AS DOUBLE))
      comment: "Total recovery amount collected from reinsurers"
    - name: "total_outstanding_amount"
      expr: SUM(CAST(outstanding_amount AS DOUBLE))
      comment: "Total outstanding recovery amount not yet collected"
    - name: "total_reinstatement_premium"
      expr: SUM(CAST(reinstatement_premium_amount AS DOUBLE))
      comment: "Total reinstatement premium charged for layer restoration"
    - name: "avg_ceded_share_percentage"
      expr: AVG(CAST(ceded_share_percentage AS DOUBLE))
      comment: "Average ceded share percentage across recoveries"
    - name: "recovery_count"
      expr: COUNT(1)
      comment: "Total number of recovery transactions"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers with recovery activity"
    - name: "distinct_claim_exposure_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with reinsurance recoveries"
    - name: "distinct_agreement_count"
      expr: COUNT(DISTINCT ri_agreement_id)
      comment: "Number of distinct reinsurance agreements with recoveries"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_premium_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance premium transaction KPIs tracking ceded written, earned, and unearned premium with ceding commission and profit commission by agreement and treaty layer."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction`"
  dimensions:
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of premium transaction (Written, Earned, Unearned, Return, Adjustment)"
    - name: "transaction_status"
      expr: transaction_status
      comment: "Current status of the transaction (Pending, Posted, Reversed, Cancelled)"
    - name: "agreement_type"
      expr: agreement_type
      comment: "Type of reinsurance agreement (Treaty, Facultative, etc.)"
    - name: "cession_type"
      expr: cession_type
      comment: "Type of cession (Proportional, Non-Proportional, etc.)"
    - name: "bordereaux_status"
      expr: bordereaux_status
      comment: "Status of the bordereaux submission (Draft, Submitted, Accepted, Rejected)"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Flag indicating whether this is a reversal transaction"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss-based accounting"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for policy-based accounting"
    - name: "treaty_year"
      expr: treaty_year
      comment: "Treaty year under which the premium is ceded"
    - name: "transaction_date"
      expr: transaction_date
      comment: "Date of the premium transaction"
    - name: "accounting_date"
      expr: accounting_date
      comment: "Accounting date for financial reporting"
    - name: "bordereaux_period"
      expr: bordereaux_period
      comment: "Bordereaux reporting period (e.g., 2024-Q1, 2024-03)"
  measures:
    - name: "total_ceded_written_premium"
      expr: SUM(CAST(ceded_written_premium AS DOUBLE))
      comment: "Total ceded written premium across all transactions"
    - name: "total_ceded_earned_premium"
      expr: SUM(CAST(ceded_earned_premium AS DOUBLE))
      comment: "Total ceded earned premium recognized in the period"
    - name: "total_ceded_unearned_premium"
      expr: SUM(CAST(ceded_unearned_premium AS DOUBLE))
      comment: "Total ceded unearned premium reserve at period end"
    - name: "total_gross_written_premium"
      expr: SUM(CAST(gross_written_premium AS DOUBLE))
      comment: "Total gross written premium before reinsurance"
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission AS DOUBLE))
      comment: "Total ceding commission received from reinsurers"
    - name: "total_profit_commission"
      expr: SUM(CAST(profit_commission AS DOUBLE))
      comment: "Total profit commission earned based on favorable loss experience"
    - name: "total_reinstatement_premium"
      expr: SUM(CAST(reinstatement_premium AS DOUBLE))
      comment: "Total reinstatement premium charged for layer restoration"
    - name: "total_return_premium"
      expr: SUM(CAST(return_premium AS DOUBLE))
      comment: "Total return premium due to policy cancellations or adjustments"
    - name: "avg_ceding_commission_rate"
      expr: AVG(CAST(ceding_commission_rate AS DOUBLE))
      comment: "Average ceding commission rate across transactions"
    - name: "avg_cession_percentage"
      expr: AVG(CAST(cession_percentage AS DOUBLE))
      comment: "Average cession percentage across transactions"
    - name: "avg_rate_on_line"
      expr: AVG(CAST(rate_on_line AS DOUBLE))
      comment: "Average rate on line (premium as percentage of limit)"
    - name: "transaction_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance premium transactions"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of distinct policies with reinsurance premium transactions"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers receiving ceded premium"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_settlement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance settlement KPIs tracking net settlement amounts, ceding commission, profit commission, and funds withheld by agreement and settlement period."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement`"
  dimensions:
    - name: "settlement_type"
      expr: settlement_type
      comment: "Type of settlement (Premium, Loss, Combined, Commutation)"
    - name: "settlement_status"
      expr: settlement_status
      comment: "Current status of the settlement (Draft, Pending, Approved, Paid, Disputed)"
    - name: "settlement_direction"
      expr: settlement_direction
      comment: "Direction of settlement (Due To Reinsurer, Due From Reinsurer)"
    - name: "agreement_type"
      expr: agreement_type
      comment: "Type of reinsurance agreement (Treaty, Facultative, etc.)"
    - name: "treaty_type"
      expr: treaty_type
      comment: "Treaty structure type (Quota Share, Excess of Loss, Stop Loss, etc.)"
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Flag indicating whether the reinsurer is authorized"
    - name: "settlement_date"
      expr: settlement_date
      comment: "Date of the settlement"
    - name: "due_date"
      expr: due_date
      comment: "Due date for settlement payment"
    - name: "paid_date"
      expr: paid_date
      comment: "Date the settlement was paid"
    - name: "settlement_period_start_date"
      expr: settlement_period_start_date
      comment: "Start date of the settlement period"
    - name: "settlement_period_end_date"
      expr: settlement_period_end_date
      comment: "End date of the settlement period"
  measures:
    - name: "total_net_settlement_amount"
      expr: SUM(CAST(net_settlement_amount AS DOUBLE))
      comment: "Total net settlement amount due to or from reinsurers"
    - name: "total_ceded_premium_written"
      expr: SUM(CAST(ceded_premium_written_amount AS DOUBLE))
      comment: "Total ceded written premium in the settlement period"
    - name: "total_ceded_premium_earned"
      expr: SUM(CAST(ceded_premium_earned_amount AS DOUBLE))
      comment: "Total ceded earned premium in the settlement period"
    - name: "total_ceded_unearned_premium"
      expr: SUM(CAST(ceded_unearned_premium_amount AS DOUBLE))
      comment: "Total ceded unearned premium at settlement date"
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission_amount AS DOUBLE))
      comment: "Total ceding commission received in the settlement"
    - name: "total_profit_commission"
      expr: SUM(CAST(profit_commission_amount AS DOUBLE))
      comment: "Total profit commission earned based on favorable loss experience"
    - name: "total_loss_recoverable"
      expr: SUM(CAST(loss_recoverable_amount AS DOUBLE))
      comment: "Total loss amount recoverable from reinsurers"
    - name: "total_lae_recoverable"
      expr: SUM(CAST(lae_recoverable_amount AS DOUBLE))
      comment: "Total loss adjustment expense recoverable from reinsurers"
    - name: "total_reinstatement_premium"
      expr: SUM(CAST(reinstatement_premium_amount AS DOUBLE))
      comment: "Total reinstatement premium charged in the settlement"
    - name: "total_funds_withheld"
      expr: SUM(CAST(funds_withheld_amount AS DOUBLE))
      comment: "Total funds withheld by cedant on behalf of reinsurers"
    - name: "total_collateral_held"
      expr: SUM(CAST(collateral_held_amount AS DOUBLE))
      comment: "Total collateral held for unauthorized or certified reinsurers"
    - name: "avg_profit_commission_rate"
      expr: AVG(CAST(profit_commission_rate AS DOUBLE))
      comment: "Average profit commission rate across settlements"
    - name: "avg_profit_commission_loss_ratio"
      expr: AVG(CAST(profit_commission_loss_ratio AS DOUBLE))
      comment: "Average loss ratio used for profit commission calculation"
    - name: "settlement_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance settlements"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_party_id)
      comment: "Number of distinct reinsurers in settlements"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_bordereaux`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Bordereaux reporting KPIs tracking ceded premium, loss, reserve, and commission by bordereaux type, status, and reporting period for treaty and facultative agreements."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux`"
  dimensions:
    - name: "bordereaux_type"
      expr: bordereaux_type
      comment: "Type of bordereaux (Premium, Loss, Combined, Claim, Policy)"
    - name: "bordereaux_status"
      expr: bordereaux_status
      comment: "Current status of the bordereaux (Draft, Submitted, Accepted, Rejected, Amended)"
    - name: "submission_method"
      expr: submission_method
      comment: "Method of bordereaux submission (Electronic, Email, Portal, Manual)"
    - name: "submission_format"
      expr: submission_format
      comment: "Format of the bordereaux submission (XML, CSV, Excel, PDF)"
    - name: "submission_date"
      expr: submission_date
      comment: "Date the bordereaux was submitted to the reinsurer"
    - name: "accepted_date"
      expr: accepted_date
      comment: "Date the bordereaux was accepted by the reinsurer"
    - name: "rejected_date"
      expr: rejected_date
      comment: "Date the bordereaux was rejected by the reinsurer"
    - name: "reporting_period_start_date"
      expr: reporting_period_start_date
      comment: "Start date of the reporting period"
    - name: "reporting_period_end_date"
      expr: reporting_period_end_date
      comment: "End date of the reporting period"
    - name: "due_date"
      expr: due_date
      comment: "Due date for bordereaux submission"
  measures:
    - name: "total_ceded_written_premium"
      expr: SUM(CAST(ceded_written_premium_amount AS DOUBLE))
      comment: "Total ceded written premium reported in bordereaux"
    - name: "total_ceded_earned_premium"
      expr: SUM(CAST(ceded_earned_premium_amount AS DOUBLE))
      comment: "Total ceded earned premium reported in bordereaux"
    - name: "total_ceded_unearned_premium"
      expr: SUM(CAST(ceded_unearned_premium_amount AS DOUBLE))
      comment: "Total ceded unearned premium reported in bordereaux"
    - name: "total_ceded_loss_amount"
      expr: SUM(CAST(ceded_loss_amount AS DOUBLE))
      comment: "Total ceded loss amount reported in bordereaux"
    - name: "total_ceded_paid_loss"
      expr: SUM(CAST(ceded_paid_loss_amount AS DOUBLE))
      comment: "Total ceded paid loss reported in bordereaux"
    - name: "total_ceded_outstanding_loss_reserve"
      expr: SUM(CAST(ceded_outstanding_loss_reserve_amount AS DOUBLE))
      comment: "Total ceded outstanding loss reserves reported in bordereaux"
    - name: "total_ceded_ibnr"
      expr: SUM(CAST(ceded_ibnr_amount AS DOUBLE))
      comment: "Total ceded IBNR reserves reported in bordereaux"
    - name: "total_ceded_lae"
      expr: SUM(CAST(ceded_lae_amount AS DOUBLE))
      comment: "Total ceded loss adjustment expense reported in bordereaux"
    - name: "total_ceded_alae"
      expr: SUM(CAST(ceded_alae_amount AS DOUBLE))
      comment: "Total ceded allocated loss adjustment expense reported in bordereaux"
    - name: "total_commission_amount"
      expr: SUM(CAST(commission_amount AS DOUBLE))
      comment: "Total ceding commission reported in bordereaux"
    - name: "total_profit_commission"
      expr: SUM(CAST(profit_commission_amount AS DOUBLE))
      comment: "Total profit commission reported in bordereaux"
    - name: "total_net_balance_due"
      expr: SUM(CAST(net_balance_due_amount AS DOUBLE))
      comment: "Total net balance due to or from reinsurer per bordereaux"
    - name: "avg_commission_rate"
      expr: AVG(CAST(commission_rate AS DOUBLE))
      comment: "Average ceding commission rate across bordereaux"
    - name: "avg_loss_ratio"
      expr: AVG(CAST(loss_ratio AS DOUBLE))
      comment: "Average loss ratio reported in bordereaux"
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS BIGINT))
      comment: "Total number of policies reported in bordereaux"
    - name: "total_claim_count"
      expr: SUM(CAST(claim_count AS BIGINT))
      comment: "Total number of claims reported in bordereaux"
    - name: "bordereaux_count"
      expr: COUNT(1)
      comment: "Total number of bordereaux submissions"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_treaty`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Treaty reinsurance KPIs tracking treaty limits, attachment points, retention, cession percentages, and reinstatement provisions by treaty type and line of business."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`"
  dimensions:
    - name: "treaty_type"
      expr: treaty_type
      comment: "Treaty structure type (Quota Share, Surplus, Excess of Loss, Stop Loss, Aggregate XOL)"
    - name: "treaty_status"
      expr: treaty_status
      comment: "Current status of the treaty (Active, Expired, Cancelled, Pending)"
    - name: "coverage_basis"
      expr: coverage_basis
      comment: "Coverage basis (Occurrence, Claims-Made, Losses Occurring)"
    - name: "catastrophe_event_type"
      expr: catastrophe_event_type
      comment: "Type of catastrophe event covered (Hurricane, Earthquake, Flood, All Perils)"
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Flag indicating whether the reinsurer is authorized"
    - name: "collateral_required_flag"
      expr: collateral_required_flag
      comment: "Flag indicating whether collateral is required"
    - name: "retrocession_flag"
      expr: retrocession_flag
      comment: "Flag indicating whether this is a retrocession treaty"
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the treaty"
    - name: "expiration_date"
      expr: expiration_date
      comment: "Expiration date of the treaty"
    - name: "inception_year"
      expr: inception_year
      comment: "Year the treaty was first incepted"
  measures:
    - name: "total_treaty_limit"
      expr: SUM(CAST(limit AS DOUBLE))
      comment: "Total treaty limit capacity across all treaties"
    - name: "total_aggregate_limit"
      expr: SUM(CAST(aggregate_limit AS DOUBLE))
      comment: "Total aggregate limit for annual treaty capacity"
    - name: "total_attachment_point"
      expr: SUM(CAST(attachment_point AS DOUBLE))
      comment: "Total attachment point (retention) across treaties"
    - name: "total_retention_amount"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount held by the cedant"
    - name: "total_premium"
      expr: SUM(CAST(premium AS DOUBLE))
      comment: "Total treaty premium across all treaties"
    - name: "total_deposit_premium"
      expr: SUM(CAST(deposit_premium AS DOUBLE))
      comment: "Total deposit premium paid upfront"
    - name: "total_minimum_premium"
      expr: SUM(CAST(minimum_premium AS DOUBLE))
      comment: "Total minimum premium guaranteed to reinsurers"
    - name: "avg_cession_pct"
      expr: AVG(CAST(cession_pct AS DOUBLE))
      comment: "Average cession percentage across treaties"
    - name: "avg_ceding_commission_pct"
      expr: AVG(CAST(ceding_commission_pct AS DOUBLE))
      comment: "Average ceding commission percentage across treaties"
    - name: "avg_profit_commission_pct"
      expr: AVG(CAST(profit_commission_pct AS DOUBLE))
      comment: "Average profit commission percentage across treaties"
    - name: "avg_rol_pct"
      expr: AVG(CAST(rol_pct AS DOUBLE))
      comment: "Average rate on line (premium as percentage of limit) across treaties"
    - name: "avg_reinsurer_share_pct"
      expr: AVG(CAST(reinsurer_share_pct AS DOUBLE))
      comment: "Average reinsurer share percentage across treaties"
    - name: "avg_placement_pct"
      expr: AVG(CAST(placement_pct AS DOUBLE))
      comment: "Average placement percentage (portion of treaty placed with reinsurers)"
    - name: "treaty_count"
      expr: COUNT(1)
      comment: "Total number of treaty agreements"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers participating in treaties"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_fac_agreement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Facultative agreement KPIs tracking ceded limits, premium, retention, and reinsurer participation by facultative type and placement basis."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`"
  dimensions:
    - name: "fac_type"
      expr: fac_type
      comment: "Type of facultative agreement (Proportional, Excess of Loss, Quota Share)"
    - name: "agreement_status"
      expr: agreement_status
      comment: "Current status of the facultative agreement (Pending, Bound, Declined, Expired)"
    - name: "placement_basis"
      expr: placement_basis
      comment: "Basis for facultative placement (Per Risk, Per Occurrence, Aggregate)"
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Flag indicating whether the reinsurer is authorized"
    - name: "collateral_required_flag"
      expr: collateral_required_flag
      comment: "Flag indicating whether collateral is required"
    - name: "reinstatement_provision"
      expr: reinstatement_provision
      comment: "Flag indicating whether reinstatement provisions apply"
    - name: "retrocession_flag"
      expr: retrocession_flag
      comment: "Flag indicating whether this is a retrocession agreement"
    - name: "bound_date"
      expr: bound_date
      comment: "Date the facultative agreement was bound"
    - name: "inception_date"
      expr: inception_date
      comment: "Inception date of the facultative agreement"
    - name: "expiry_date"
      expr: expiry_date
      comment: "Expiry date of the facultative agreement"
    - name: "cancellation_date"
      expr: cancellation_date
      comment: "Date the facultative agreement was cancelled"
  measures:
    - name: "total_ceded_limit"
      expr: SUM(CAST(ceded_limit_amount AS DOUBLE))
      comment: "Total ceded limit capacity across all facultative agreements"
    - name: "total_ceded_premium"
      expr: SUM(CAST(ceded_premium_amount AS DOUBLE))
      comment: "Total ceded premium for facultative agreements"
    - name: "total_gross_written_premium"
      expr: SUM(CAST(gross_written_premium AS DOUBLE))
      comment: "Total gross written premium before facultative reinsurance"
    - name: "total_retention_amount"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount held by the cedant"
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission_amount AS DOUBLE))
      comment: "Total ceding commission received from reinsurers"
    - name: "total_collateral_amount"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral held for unauthorized or certified reinsurers"
    - name: "total_original_insured_tiv"
      expr: SUM(CAST(original_insured_tiv AS DOUBLE))
      comment: "Total insured value (TIV) of the underlying risks"
    - name: "avg_ceded_percentage"
      expr: AVG(CAST(ceded_percentage AS DOUBLE))
      comment: "Average ceded percentage across facultative agreements"
    - name: "avg_reinsurer_share_percentage"
      expr: AVG(CAST(reinsurer_share_percentage AS DOUBLE))
      comment: "Average reinsurer share percentage across facultative agreements"
    - name: "avg_ceding_commission_rate"
      expr: AVG(CAST(ceding_commission_rate AS DOUBLE))
      comment: "Average ceding commission rate across facultative agreements"
    - name: "avg_broker_commission_rate"
      expr: AVG(CAST(broker_commission_rate AS DOUBLE))
      comment: "Average broker commission rate across facultative agreements"
    - name: "avg_loss_participation_rate"
      expr: AVG(CAST(loss_participation_rate AS DOUBLE))
      comment: "Average loss participation rate for reinsurers"
    - name: "fac_agreement_count"
      expr: COUNT(1)
      comment: "Total number of facultative agreements"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of distinct policies with facultative reinsurance"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers participating in facultative agreements"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_collateral`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance collateral KPIs tracking face amount, available amount, drawn amount, and deficiency by collateral type and reinsurer authorization status."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral`"
  dimensions:
    - name: "collateral_type"
      expr: collateral_type
      comment: "Type of collateral (Letter of Credit, Trust Account, Funds Withheld, Cash Deposit)"
    - name: "collateral_status"
      expr: collateral_status
      comment: "Current status of the collateral (Active, Expired, Released, Drawn, Insufficient)"
    - name: "collateral_purpose"
      expr: collateral_purpose
      comment: "Purpose of the collateral (Credit for Reinsurance, Regulatory Compliance, Contractual)"
    - name: "adequacy_status"
      expr: adequacy_status
      comment: "Adequacy status of the collateral (Adequate, Deficient, Excess)"
    - name: "schedule_f_category"
      expr: schedule_f_category
      comment: "Schedule F category for regulatory reporting (Authorized, Unauthorized, Certified)"
    - name: "reinsurer_certified_flag"
      expr: reinsurer_certified_flag
      comment: "Flag indicating whether the reinsurer is certified"
    - name: "evergreen_flag"
      expr: evergreen_flag
      comment: "Flag indicating whether the collateral automatically renews"
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the collateral"
    - name: "expiry_date"
      expr: expiry_date
      comment: "Expiry date of the collateral"
    - name: "renewal_date"
      expr: renewal_date
      comment: "Renewal date of the collateral"
  measures:
    - name: "total_face_amt"
      expr: SUM(CAST(face_amt AS DOUBLE))
      comment: "Total face amount of collateral instruments"
    - name: "total_available_amt"
      expr: SUM(CAST(available_amt AS DOUBLE))
      comment: "Total available collateral amount not yet drawn"
    - name: "total_drawn_amt"
      expr: SUM(CAST(drawn_amt AS DOUBLE))
      comment: "Total collateral amount drawn to date"
    - name: "total_required_amt"
      expr: SUM(CAST(required_amt AS DOUBLE))
      comment: "Total collateral amount required by regulation or contract"
    - name: "total_deficiency_amt"
      expr: SUM(CAST(deficiency_amt AS DOUBLE))
      comment: "Total collateral deficiency (required minus available)"
    - name: "avg_reduced_collateral_pct"
      expr: AVG(CAST(reduced_collateral_pct AS DOUBLE))
      comment: "Average reduced collateral percentage for certified reinsurers"
    - name: "collateral_count"
      expr: COUNT(1)
      comment: "Total number of collateral instruments"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers with collateral requirements"
    - name: "distinct_agreement_count"
      expr: COUNT(DISTINCT ri_agreement_id)
      comment: "Number of distinct reinsurance agreements with collateral"
$$;