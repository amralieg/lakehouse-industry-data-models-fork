-- Metric views for domain: reinsurance | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_cession`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance cession transactions tracking ceded premium, limits, and reserves by treaty, facultative agreement, and reinsurer. Grain: one row per cession transaction."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`cession`"
  dimensions:
    - name: "agreement_type"
      expr: agreement_type
      comment: "Type of reinsurance agreement (Treaty, Facultative, etc.)"
    - name: "treaty_type"
      expr: treaty_type
      comment: "Treaty structure type (Quota Share, Excess of Loss, Stop Loss, etc.)"
    - name: "direction"
      expr: direction
      comment: "Cession direction (Outward, Inward, Retrocession)"
    - name: "reinsurance_cession_status"
      expr: reinsurance_cession_status
      comment: "Current status of the cession (Pending, Confirmed, Disputed, Settled)"
    - name: "is_catastrophe_cession"
      expr: is_catastrophe_cession
      comment: "Flag indicating whether this cession relates to a catastrophe event"
    - name: "reinsurer_domicile_country"
      expr: reinsurer_domicile_country
      comment: "Country where the reinsurer is domiciled"
    - name: "reinsurer_authorization_status"
      expr: reinsurer_authorization_status
      comment: "Authorization status of the reinsurer (Authorized, Unauthorized, Certified)"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss-based cessions"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for premium-based cessions"
    - name: "bordereaux_period"
      expr: bordereaux_period
      comment: "Reporting period for bordereaux submission"
    - name: "booking_month"
      expr: DATE_TRUNC('MONTH', booking_date)
      comment: "Month when the cession was booked"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when the cession became effective"
  measures:
    - name: "total_ceded_gwp"
      expr: SUM(CAST(ceded_gwp AS DOUBLE))
      comment: "Total ceded gross written premium across all cessions"
    - name: "total_ceded_earned_premium"
      expr: SUM(CAST(ceded_earned_premium AS DOUBLE))
      comment: "Total ceded earned premium recognized in the period"
    - name: "total_ceded_unearned_premium"
      expr: SUM(CAST(ceded_unearned_premium AS DOUBLE))
      comment: "Total ceded unearned premium liability at period end"
    - name: "total_ceded_case_reserve"
      expr: SUM(CAST(ceded_case_reserve AS DOUBLE))
      comment: "Total ceded case reserves for reported claims"
    - name: "total_ceded_ibnr_reserve"
      expr: SUM(CAST(ceded_ibnr_reserve AS DOUBLE))
      comment: "Total ceded incurred but not reported reserves"
    - name: "total_ceded_limit"
      expr: SUM(CAST(ceded_limit AS DOUBLE))
      comment: "Total ceded limit capacity across all cessions"
    - name: "total_ceded_tiv"
      expr: SUM(CAST(ceded_tiv AS DOUBLE))
      comment: "Total ceded total insured value for property risks"
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission_amount AS DOUBLE))
      comment: "Total ceding commission received from reinsurers"
    - name: "avg_ceding_commission_pct"
      expr: AVG(CAST(ceding_commission_pct AS DOUBLE))
      comment: "Average ceding commission percentage across cessions"
    - name: "avg_share_pct"
      expr: AVG(CAST(share_pct AS DOUBLE))
      comment: "Average reinsurer share percentage across cessions"
    - name: "total_collateral_amount"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral held or posted for cessions"
    - name: "total_funds_held"
      expr: SUM(CAST(funds_held_amount AS DOUBLE))
      comment: "Total funds withheld by cedant under funds-held arrangements"
    - name: "total_ultimate_net_loss"
      expr: SUM(CAST(ultimate_net_loss AS DOUBLE))
      comment: "Total ultimate net loss after reinsurance recoveries"
    - name: "avg_rate_on_line"
      expr: AVG(CAST(rate_on_line AS DOUBLE))
      comment: "Average rate on line (premium as percentage of limit) across cessions"
    - name: "cession_count"
      expr: COUNT(1)
      comment: "Total number of cession transactions"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers participating in cessions"
    - name: "distinct_treaty_count"
      expr: COUNT(DISTINCT treaty_layer_id)
      comment: "Number of distinct treaty layers involved in cessions"
    - name: "catastrophe_cession_count"
      expr: SUM(CAST(CASE WHEN is_catastrophe_cession = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of cessions related to catastrophe events"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_claim_cession`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance claim cessions tracking ceded loss, reserves, and recoveries by claim exposure and reinsurer. Grain: one row per claim cession transaction."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`cession`"
  dimensions:
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying claim"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year of the underlying policy"
    - name: "bordereaux_period"
      expr: bordereaux_period
      comment: "Bordereaux reporting period"
  measures:
    - name: "total_funds_held"
      expr: SUM(CAST(funds_held_amount AS DOUBLE))
      comment: "Total funds held by cedant for claim cessions"
    - name: "claim_cession_count"
      expr: COUNT(1)
      comment: "Total number of claim cession transactions"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers involved in claim cessions"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_recovery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance recoveries tracking billed, collected, and outstanding recovery amounts by claim and reinsurer. Grain: one row per recovery transaction."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`"
  dimensions:
    - name: "recovery_status"
      expr: recovery_status
      comment: "Status of the recovery (Billed, Collected, Outstanding, Disputed, Written Off)"
    - name: "movement_type"
      expr: movement_type
      comment: "Type of recovery movement (Initial, Adjustment, Reversal, Commutation)"
    - name: "payment_type"
      expr: payment_type
      comment: "Type of payment (Loss, LAE, ALAE, Expense)"
    - name: "reserve_type"
      expr: reserve_type
      comment: "Type of reserve recovered (Case, IBNR, LAE)"
    - name: "dispute_flag"
      expr: dispute_flag
      comment: "Flag indicating whether the recovery is disputed"
    - name: "commutation_flag"
      expr: commutation_flag
      comment: "Flag indicating whether the recovery is part of a commutation"
    - name: "reinstatement_premium_flag"
      expr: reinstatement_premium_flag
      comment: "Flag indicating whether reinstatement premium applies"
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Flag indicating whether the reinsurer is authorized"
    - name: "collateral_required_flag"
      expr: collateral_required_flag
      comment: "Flag indicating whether collateral is required for this recovery"
    - name: "cat_code"
      expr: cat_code
      comment: "Catastrophe event code if recovery relates to a cat claim"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the underlying claim"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year of the underlying policy"
    - name: "treaty_year"
      expr: treaty_year
      comment: "Treaty year for the reinsurance agreement"
    - name: "billed_month"
      expr: DATE_TRUNC('MONTH', billed_date)
      comment: "Month when the recovery was billed"
    - name: "collected_month"
      expr: DATE_TRUNC('MONTH', collected_date)
      comment: "Month when the recovery was collected"
    - name: "movement_month"
      expr: DATE_TRUNC('MONTH', movement_date)
      comment: "Month of the recovery movement"
  measures:
    - name: "total_recovery_amount"
      expr: SUM(CAST(recovery_amount AS DOUBLE))
      comment: "Total recovery amount billed to reinsurers"
    - name: "total_recovery_amount_usd"
      expr: SUM(CAST(recovery_amount_usd AS DOUBLE))
      comment: "Total recovery amount in USD after currency conversion"
    - name: "total_collected_amount"
      expr: SUM(CAST(collected_amount AS DOUBLE))
      comment: "Total recovery amount collected from reinsurers"
    - name: "total_outstanding_amount"
      expr: SUM(CAST(outstanding_amount AS DOUBLE))
      comment: "Total recovery amount outstanding and not yet collected"
    - name: "total_reinstatement_premium"
      expr: SUM(CAST(reinstatement_premium_amount AS DOUBLE))
      comment: "Total reinstatement premium charged for layer reinstatements"
    - name: "avg_ceded_share_percentage"
      expr: AVG(CAST(ceded_share_percentage AS DOUBLE))
      comment: "Average ceded share percentage across recoveries"
    - name: "avg_exchange_rate"
      expr: AVG(CAST(exchange_rate AS DOUBLE))
      comment: "Average exchange rate applied to recoveries"
    - name: "recovery_count"
      expr: COUNT(1)
      comment: "Total number of recovery transactions"
    - name: "distinct_claim_count"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with recoveries"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers from whom recoveries are sought"
    - name: "collected_recovery_count"
      expr: SUM(CAST(CASE WHEN recovery_status = 'Collected' THEN 1 ELSE 0 END AS INT))
      comment: "Number of recoveries fully collected"
    - name: "disputed_recovery_count"
      expr: SUM(CAST(CASE WHEN dispute_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of disputed recoveries"
    - name: "commuted_recovery_count"
      expr: SUM(CAST(CASE WHEN commutation_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of recoveries settled via commutation"
    - name: "reinstatement_recovery_count"
      expr: SUM(CAST(CASE WHEN reinstatement_premium_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of recoveries triggering reinstatement premium"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_premium_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance premium transactions tracking ceded written, earned, and unearned premium with ceding commission and profit commission. Grain: one row per premium transaction."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction`"
  dimensions:
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of premium transaction (Written, Earned, Unearned, Return, Adjustment)"
    - name: "transaction_status"
      expr: transaction_status
      comment: "Status of the transaction (Pending, Confirmed, Reversed, Adjusted)"
    - name: "cession_type"
      expr: cession_type
      comment: "Type of cession (Treaty, Facultative, Retrocession)"
    - name: "agreement_type"
      expr: agreement_type
      comment: "Type of reinsurance agreement (Quota Share, Excess of Loss, Stop Loss, Facultative)"
    - name: "bordereaux_status"
      expr: bordereaux_status
      comment: "Status of bordereaux submission (Draft, Submitted, Confirmed, Disputed)"
    - name: "bordereaux_period"
      expr: bordereaux_period
      comment: "Reporting period for bordereaux"
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Flag indicating whether this is a reversal transaction"
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss-based premium"
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for the underlying policy"
    - name: "treaty_year"
      expr: treaty_year
      comment: "Treaty year for the reinsurance agreement"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month when the transaction occurred"
    - name: "accounting_month"
      expr: DATE_TRUNC('MONTH', accounting_date)
      comment: "Accounting month for the transaction"
    - name: "policy_effective_month"
      expr: DATE_TRUNC('MONTH', policy_effective_date)
      comment: "Month when the underlying policy became effective"
  measures:
    - name: "total_ceded_written_premium"
      expr: SUM(CAST(ceded_written_premium AS DOUBLE))
      comment: "Total ceded written premium across all transactions"
    - name: "total_ceded_earned_premium"
      expr: SUM(CAST(ceded_earned_premium AS DOUBLE))
      comment: "Total ceded earned premium recognized in the period"
    - name: "total_ceded_unearned_premium"
      expr: SUM(CAST(ceded_unearned_premium AS DOUBLE))
      comment: "Total ceded unearned premium liability at period end"
    - name: "total_gross_written_premium"
      expr: SUM(CAST(gross_written_premium AS DOUBLE))
      comment: "Total gross written premium before cession"
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission AS DOUBLE))
      comment: "Total ceding commission received from reinsurers"
    - name: "total_profit_commission"
      expr: SUM(CAST(profit_commission AS DOUBLE))
      comment: "Total profit commission earned on favorable loss experience"
    - name: "total_reinstatement_premium"
      expr: SUM(CAST(reinstatement_premium AS DOUBLE))
      comment: "Total reinstatement premium charged for layer reinstatements"
    - name: "total_return_premium"
      expr: SUM(CAST(return_premium AS DOUBLE))
      comment: "Total return premium due to cancellations or adjustments"
    - name: "total_reinstated_limit"
      expr: SUM(CAST(reinstated_limit AS DOUBLE))
      comment: "Total limit reinstated after loss payments"
    - name: "avg_cession_percentage"
      expr: AVG(CAST(cession_percentage AS DOUBLE))
      comment: "Average cession percentage across transactions"
    - name: "avg_ceding_commission_rate"
      expr: AVG(CAST(ceding_commission_rate AS DOUBLE))
      comment: "Average ceding commission rate across transactions"
    - name: "avg_rate_on_line"
      expr: AVG(CAST(rate_on_line AS DOUBLE))
      comment: "Average rate on line (premium as percentage of limit)"
    - name: "avg_exchange_rate"
      expr: AVG(CAST(exchange_rate AS DOUBLE))
      comment: "Average exchange rate applied to transactions"
    - name: "premium_transaction_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance premium transactions"
    - name: "distinct_policy_count"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of distinct policies with reinsurance premium transactions"
    - name: "distinct_reinsurer_count"
      expr: COUNT(DISTINCT reinsurer_id)
      comment: "Number of distinct reinsurers receiving premium"
    - name: "reversal_transaction_count"
      expr: SUM(CAST(CASE WHEN reversal_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of reversal transactions"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_ri_agreement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance agreements defining treaty and facultative structures with limits, attachments, and commission terms. Grain: one row per reinsurance agreement."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`"
  dimensions:
    - name: "agreement_type"
      expr: agreement_type
      comment: "Type of reinsurance agreement (Treaty, Facultative, Retrocession)"
    - name: "treaty_type"
      expr: treaty_type
      comment: "Treaty structure type (Quota Share, Surplus, Excess of Loss, Stop Loss, Catastrophe XOL)"
    - name: "agreement_status"
      expr: agreement_status
      comment: "Current status of the agreement (Draft, Bound, In Force, Expired, Cancelled)"
    - name: "authorized_status"
      expr: authorized_status
      comment: "Authorization status of reinsurers (Authorized, Unauthorized, Certified)"
    - name: "coverage_basis"
      expr: coverage_basis
      comment: "Coverage basis (Occurrence, Claims Made, Losses Occurring)"
    - name: "cat_event_scope"
      expr: cat_event_scope
      comment: "Catastrophe event scope (Per Occurrence, Annual Aggregate, Hours Clause)"
    - name: "territory_scope"
      expr: territory_scope
      comment: "Geographic territory covered by the agreement"
    - name: "collateral_required"
      expr: collateral_required
      comment: "Flag indicating whether collateral is required"
    - name: "funds_withheld"
      expr: funds_withheld
      comment: "Flag indicating whether funds are withheld by cedant"
    - name: "retrocession_flag"
      expr: retrocession_flag
      comment: "Flag indicating whether this is a retrocession agreement"
    - name: "arbitration_clause"
      expr: arbitration_clause
      comment: "Flag indicating whether arbitration clause is included"
    - name: "insolvency_clause"
      expr: insolvency_clause
      comment: "Flag indicating whether insolvency clause is included"
    - name: "offset_clause"
      expr: offset_clause
      comment: "Flag indicating whether offset clause is included"
    - name: "inception_year"
      expr: YEAR(inception_date)
      comment: "Year when the agreement became effective"
    - name: "inception_month"
      expr: DATE_TRUNC('MONTH', inception_date)
      comment: "Month when the agreement became effective"
  measures:
    - name: "total_limit_amt"
      expr: SUM(CAST(limit_amt AS DOUBLE))
      comment: "Total limit amount across all reinsurance agreements"
    - name: "total_aggregate_limit_amt"
      expr: SUM(CAST(aggregate_limit_amt AS DOUBLE))
      comment: "Total annual aggregate limit across agreements"
    - name: "total_attachment_point_amt"
      expr: SUM(CAST(attachment_point_amt AS DOUBLE))
      comment: "Total attachment point (retention) across agreements"
    - name: "total_retention_amt"
      expr: SUM(CAST(retention_amt AS DOUBLE))
      comment: "Total retention amount kept by cedant"
    - name: "total_deposit_premium_amt"
      expr: SUM(CAST(deposit_premium_amt AS DOUBLE))
      comment: "Total deposit premium paid upfront"
    - name: "total_minimum_premium_amt"
      expr: SUM(CAST(minimum_premium_amt AS DOUBLE))
      comment: "Total minimum premium guaranteed to reinsurers"
    - name: "avg_ceding_commission_pct"
      expr: AVG(CAST(ceding_commission_pct AS DOUBLE))
      comment: "Average ceding commission percentage across agreements"
    - name: "avg_profit_commission_pct"
      expr: AVG(CAST(profit_commission_pct AS DOUBLE))
      comment: "Average profit commission percentage"
    - name: "avg_cession_pct"
      expr: AVG(CAST(cession_pct AS DOUBLE))
      comment: "Average cession percentage across proportional treaties"
    - name: "avg_rol_pct"
      expr: AVG(CAST(rol_pct AS DOUBLE))
      comment: "Average rate on line percentage"
    - name: "avg_loss_corridor_pct"
      expr: AVG(CAST(loss_corridor_pct AS DOUBLE))
      comment: "Average loss corridor percentage for swing-rated treaties"
    - name: "avg_reinstatement_premium_pct"
      expr: AVG(CAST(reinstatement_premium_pct AS DOUBLE))
      comment: "Average reinstatement premium percentage"
    - name: "avg_reinstatement_count"
      expr: AVG(CAST(reinstatement_count AS DOUBLE))
      comment: "Average number of reinstatements allowed"
    - name: "avg_hours_clause_hrs"
      expr: AVG(CAST(hours_clause_hrs AS DOUBLE))
      comment: "Average hours clause duration for catastrophe aggregation"
    - name: "agreement_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance agreements"
    - name: "in_force_agreement_count"
      expr: SUM(CAST(CASE WHEN agreement_status = 'In Force' THEN 1 ELSE 0 END AS INT))
      comment: "Number of agreements currently in force"
    - name: "retrocession_agreement_count"
      expr: SUM(CAST(CASE WHEN retrocession_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of retrocession agreements"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_treaty`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance treaties defining proportional and non-proportional structures with layer limits, attachments, and commission terms. Grain: one row per treaty."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`"
  dimensions:
    - name: "treaty_type"
      expr: treaty_type
      comment: "Treaty structure type (Quota Share, Surplus, Excess of Loss, Stop Loss, Catastrophe XOL)"
    - name: "treaty_status"
      expr: treaty_status
      comment: "Current status of the treaty (Draft, Bound, In Force, Expired, Cancelled)"
    - name: "coverage_basis"
      expr: coverage_basis
      comment: "Coverage basis (Occurrence, Claims Made, Losses Occurring)"
    - name: "subject_premium_basis"
      expr: subject_premium_basis
      comment: "Basis for subject premium calculation (Gross, Net, Written, Earned)"
    - name: "unl_basis"
      expr: unl_basis
      comment: "Ultimate net loss basis for loss-based treaties"
    - name: "territory"
      expr: territory
      comment: "Geographic territory covered by the treaty"
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Flag indicating whether reinsurers are authorized"
    - name: "collateral_required_flag"
      expr: collateral_required_flag
      comment: "Flag indicating whether collateral is required"
    - name: "retrocession_flag"
      expr: retrocession_flag
      comment: "Flag indicating whether this is a retrocession treaty"
    - name: "inception_year"
      expr: inception_year
      comment: "Year when the treaty became effective"
    - name: "layer_number"
      expr: layer_number
      comment: "Layer number for multi-layer treaties"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month when the treaty became effective"
  measures:
    - name: "total_limit"
      expr: SUM(CAST(limit AS DOUBLE))
      comment: "Total treaty limit across all treaties"
    - name: "total_aggregate_limit"
      expr: SUM(CAST(aggregate_limit AS DOUBLE))
      comment: "Total annual aggregate limit"
    - name: "total_occurrence_limit"
      expr: SUM(CAST(occurrence_limit AS DOUBLE))
      comment: "Total per-occurrence limit"
    - name: "total_attachment_point"
      expr: SUM(CAST(attachment_point AS DOUBLE))
      comment: "Total attachment point (retention) across treaties"
    - name: "total_retention_amount"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount kept by cedant"
    - name: "total_aggregate_deductible"
      expr: SUM(CAST(aggregate_deductible AS DOUBLE))
      comment: "Total annual aggregate deductible"
    - name: "total_premium"
      expr: SUM(CAST(premium AS DOUBLE))
      comment: "Total treaty premium across all treaties"
    - name: "total_deposit_premium"
      expr: SUM(CAST(deposit_premium AS DOUBLE))
      comment: "Total deposit premium paid upfront"
    - name: "total_minimum_premium"
      expr: SUM(CAST(minimum_premium AS DOUBLE))
      comment: "Total minimum premium guaranteed to reinsurers"
    - name: "avg_ceding_commission_pct"
      expr: AVG(CAST(ceding_commission_pct AS DOUBLE))
      comment: "Average ceding commission percentage"
    - name: "avg_profit_commission_pct"
      expr: AVG(CAST(profit_commission_pct AS DOUBLE))
      comment: "Average profit commission percentage"
    - name: "avg_cession_pct"
      expr: AVG(CAST(cession_pct AS DOUBLE))
      comment: "Average cession percentage for proportional treaties"
    - name: "avg_retention_pct"
      expr: AVG(CAST(retention_pct AS DOUBLE))
      comment: "Average retention percentage"
    - name: "avg_reinsurer_share_pct"
      expr: AVG(CAST(reinsurer_share_pct AS DOUBLE))
      comment: "Average reinsurer share percentage"
    - name: "avg_placement_pct"
      expr: AVG(CAST(placement_pct AS DOUBLE))
      comment: "Average placement percentage (portion of treaty placed)"
    - name: "avg_rol_pct"
      expr: AVG(CAST(rol_pct AS DOUBLE))
      comment: "Average rate on line percentage"
    - name: "avg_brokerage_pct"
      expr: AVG(CAST(brokerage_pct AS DOUBLE))
      comment: "Average brokerage commission percentage"
    - name: "avg_reinstatement_premium_pct"
      expr: AVG(CAST(reinstatement_premium_pct AS DOUBLE))
      comment: "Average reinstatement premium percentage"
    - name: "avg_reinstatement_count"
      expr: AVG(CAST(reinstatement_count AS DOUBLE))
      comment: "Average number of reinstatements allowed"
    - name: "avg_hours_clause"
      expr: AVG(CAST(hours_clause AS DOUBLE))
      comment: "Average hours clause duration for catastrophe aggregation"
    - name: "treaty_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance treaties"
    - name: "in_force_treaty_count"
      expr: SUM(CAST(CASE WHEN treaty_status = 'In Force' THEN 1 ELSE 0 END AS INT))
      comment: "Number of treaties currently in force"
    - name: "retrocession_treaty_count"
      expr: SUM(CAST(CASE WHEN retrocession_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of retrocession treaties"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`reinsurance_reinsurer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurer master data tracking authorization status, financial ratings, credit limits, and collateral requirements. Grain: one row per reinsurer."
  source: "`vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`"
  dimensions:
    - name: "reinsurer_type"
      expr: reinsurer_type
      comment: "Type of reinsurer (Professional, Captive, Pool, Lloyds Syndicate)"
    - name: "reinsurer_status"
      expr: reinsurer_status
      comment: "Current status of the reinsurer (Active, Inactive, Suspended, Run-Off)"
    - name: "authorization_status"
      expr: authorization_status
      comment: "Authorization status (Authorized, Unauthorized, Certified, Alien)"
    - name: "schedule_f_category"
      expr: schedule_f_category
      comment: "Schedule F category for regulatory reporting"
    - name: "domicile_country"
      expr: domicile_country
      comment: "Country where the reinsurer is domiciled"
    - name: "domicile_state"
      expr: domicile_state
      comment: "State where the reinsurer is domiciled (US reinsurers)"
    - name: "am_best_rating"
      expr: am_best_rating
      comment: "AM Best financial strength rating"
    - name: "am_best_outlook"
      expr: am_best_outlook
      comment: "AM Best rating outlook (Stable, Positive, Negative, Developing)"
    - name: "sp_rating"
      expr: sp_rating
      comment: "Standard & Poors financial strength rating"
    - name: "moodys_rating"
      expr: moodys_rating
      comment: "Moodys financial strength rating"
    - name: "approved_flag"
      expr: approved_flag
      comment: "Flag indicating whether the reinsurer is approved for use"
    - name: "collateral_required_flag"
      expr: collateral_required_flag
      comment: "Flag indicating whether collateral is required"
    - name: "collateral_type"
      expr: collateral_type
      comment: "Type of collateral required (Letter of Credit, Trust Fund, Cash)"
    - name: "retrocession_flag"
      expr: retrocession_flag
      comment: "Flag indicating whether this is a retrocessionaire"
    - name: "federal_excise_tax_exempt_flag"
      expr: federal_excise_tax_exempt_flag
      comment: "Flag indicating whether federal excise tax exemption applies"
  measures:
    - name: "total_credit_limit"
      expr: SUM(CAST(credit_limit_amount AS DOUBLE))
      comment: "Total credit limit approved across all reinsurers"
    - name: "total_collateral_amount"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral held or required from reinsurers"
    - name: "avg_tax_withholding_rate"
      expr: AVG(CAST(tax_withholding_rate AS DOUBLE))
      comment: "Average tax withholding rate for foreign reinsurers"
    - name: "reinsurer_count"
      expr: COUNT(1)
      comment: "Total number of reinsurers"
    - name: "active_reinsurer_count"
      expr: SUM(CAST(CASE WHEN reinsurer_status = 'Active' THEN 1 ELSE 0 END AS INT))
      comment: "Number of active reinsurers"
    - name: "approved_reinsurer_count"
      expr: SUM(CAST(CASE WHEN approved_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of approved reinsurers"
    - name: "authorized_reinsurer_count"
      expr: SUM(CAST(CASE WHEN authorization_status = 'Authorized' THEN 1 ELSE 0 END AS INT))
      comment: "Number of authorized reinsurers"
    - name: "collateral_required_count"
      expr: SUM(CAST(CASE WHEN collateral_required_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of reinsurers requiring collateral"
    - name: "retrocessionaire_count"
      expr: SUM(CAST(CASE WHEN retrocession_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of retrocessionaires"
$$;