-- Metric views for domain: reinsurance | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reinsurance_ri_treaty`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic reinsurance treaty performance metrics including capacity utilization, rate adequacy, and program efficiency for treaty portfolio management and renewal decisions."
  source: "`vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`"
  dimensions:
    - name: "treaty_type"
      expr: treaty_type
      comment: "Type of reinsurance treaty (e.g., quota share, surplus, excess of loss, catastrophe) for segmenting treaty portfolio performance."
    - name: "treaty_status"
      expr: treaty_status
      comment: "Current status of the treaty (active, expired, cancelled, pending) for filtering operational vs historical treaties."
    - name: "coverage_basis"
      expr: coverage_basis
      comment: "Coverage basis of the treaty (losses occurring, claims made, risks attaching) for analyzing treaty trigger and exposure timing."
    - name: "lob_code_id"
      expr: lob_code_id
      comment: "Line of business identifier for segmenting treaty performance by product line."
    - name: "treaty_year"
      expr: YEAR(effective_date)
      comment: "Year the treaty became effective for analyzing treaty vintage performance and renewal cycles."
    - name: "treaty_quarter"
      expr: CONCAT(CAST(YEAR(effective_date) AS STRING), '-Q', CAST(QUARTER(effective_date) AS STRING))
      comment: "Quarter the treaty became effective for seasonal treaty placement analysis."
    - name: "lead_reinsurer_name"
      expr: lead_reinsurer_name
      comment: "Name of the lead reinsurer for analyzing reinsurer relationship performance and concentration."
    - name: "broker_name"
      expr: broker_name
      comment: "Name of the placement broker for evaluating broker effectiveness and relationship management."
    - name: "territory_scope"
      expr: territory_scope
      comment: "Geographic territory covered by the treaty for analyzing regional reinsurance strategy and exposure."
    - name: "perils_covered"
      expr: perils_covered
      comment: "Perils covered under the treaty for analyzing peril-specific reinsurance protection and gaps."
    - name: "admitted_reinsurer_flag"
      expr: admitted_reinsurer_flag
      comment: "Whether the treaty uses admitted reinsurers for regulatory compliance and credit risk analysis."
    - name: "funds_withheld_flag"
      expr: funds_withheld_flag
      comment: "Whether funds are withheld under the treaty for analyzing collateral and credit risk management strategies."
  measures:
    - name: "treaty_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance treaties for portfolio size and complexity tracking."
    - name: "total_treaty_limit"
      expr: SUM(CAST(limit_amount AS DOUBLE))
      comment: "Total reinsurance limit amount across treaties for measuring total protection capacity purchased."
    - name: "total_ceded_premium"
      expr: SUM(CAST(ceded_premium_amount AS DOUBLE))
      comment: "Total premium ceded to reinsurers for measuring reinsurance program cost and budget impact."
    - name: "total_retention"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount across treaties for measuring net risk retained by the ceding company."
    - name: "total_aggregate_limit"
      expr: SUM(CAST(aggregate_limit_amount AS DOUBLE))
      comment: "Total aggregate limit across treaties for measuring annual catastrophe and aggregate loss protection."
    - name: "avg_rate_on_line"
      expr: AVG(CAST(rate_on_line_pct AS DOUBLE))
      comment: "Average rate on line percentage for measuring reinsurance pricing efficiency and market competitiveness."
    - name: "avg_ceding_commission_pct"
      expr: AVG(CAST(ceding_commission_pct AS DOUBLE))
      comment: "Average ceding commission percentage for measuring acquisition cost recovery from reinsurers."
    - name: "avg_profit_commission_pct"
      expr: AVG(CAST(profit_commission_pct AS DOUBLE))
      comment: "Average profit commission percentage for measuring potential profit sharing with reinsurers."
    - name: "total_collateral_amount"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral held under treaties for measuring credit risk mitigation and regulatory capital relief."
    - name: "total_deposit_premium"
      expr: SUM(CAST(deposit_premium_amount AS DOUBLE))
      comment: "Total deposit premium paid to reinsurers for measuring upfront cash flow impact of reinsurance program."
    - name: "total_minimum_premium"
      expr: SUM(CAST(minimum_premium_amount AS DOUBLE))
      comment: "Total minimum premium commitment across treaties for measuring guaranteed reinsurance cost floor."
    - name: "avg_lead_reinsurer_share_pct"
      expr: AVG(CAST(lead_reinsurer_share_pct AS DOUBLE))
      comment: "Average lead reinsurer participation percentage for measuring lead reinsurer commitment and alignment."
    - name: "avg_cession_percentage"
      expr: AVG(CAST(cession_percentage AS DOUBLE))
      comment: "Average cession percentage across treaties for measuring overall risk transfer ratio and retention strategy."
    - name: "total_pml_amount"
      expr: SUM(CAST(pml_amount AS DOUBLE))
      comment: "Total probable maximum loss amount for measuring catastrophe exposure and reinsurance adequacy."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reinsurance_cession`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Granular reinsurance cession performance metrics including premium ceded, loss recoveries, and ceding commission economics for individual risk and treaty cession analysis."
  source: "`vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`"
  dimensions:
    - name: "reinsurance_cession_type"
      expr: reinsurance_cession_type
      comment: "Type of reinsurance cession (treaty, facultative, retrocession) for segmenting cession portfolio by placement method."
    - name: "reinsurance_cession_status"
      expr: reinsurance_cession_status
      comment: "Current status of the cession (active, expired, cancelled) for filtering operational vs historical cessions."
    - name: "basis"
      expr: basis
      comment: "Basis of the cession (proportional, non-proportional) for analyzing cession structure and risk transfer mechanics."
    - name: "placement_type"
      expr: placement_type
      comment: "Placement type (direct, broker, pool) for analyzing distribution channel effectiveness."
    - name: "lob_code_id"
      expr: lob_code_id
      comment: "Line of business identifier for segmenting cession performance by product line."
    - name: "cession_year"
      expr: YEAR(effective_date)
      comment: "Year the cession became effective for analyzing cession vintage performance and loss development."
    - name: "cession_quarter"
      expr: CONCAT(CAST(YEAR(effective_date) AS STRING), '-Q', CAST(QUARTER(effective_date) AS STRING))
      comment: "Quarter the cession became effective for seasonal cession pattern analysis."
    - name: "am_best_rating"
      expr: am_best_rating
      comment: "AM Best rating of the reinsurer for analyzing credit quality and counterparty risk concentration."
    - name: "naic_company_code"
      expr: naic_company_code
      comment: "NAIC company code of the reinsurer for regulatory reporting and reinsurer identification."
    - name: "cat_event_code"
      expr: cat_event_code
      comment: "Catastrophe event code for isolating catastrophe-related cessions and loss recoveries."
    - name: "is_retrocession"
      expr: is_retrocession
      comment: "Whether the cession is a retrocession for analyzing retrocession strategy and capital optimization."
    - name: "collateral_required"
      expr: collateral_required
      comment: "Whether collateral is required for the cession for analyzing credit risk mitigation and regulatory capital treatment."
  measures:
    - name: "cession_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance cessions for measuring cession volume and portfolio granularity."
    - name: "total_ceded_written_premium"
      expr: SUM(CAST(ceded_written_premium AS DOUBLE))
      comment: "Total written premium ceded to reinsurers for measuring reinsurance program cost and premium leverage."
    - name: "total_ceded_earned_premium"
      expr: SUM(CAST(ceded_earned_premium AS DOUBLE))
      comment: "Total earned premium ceded to reinsurers for measuring reinsurance cost recognition and profitability impact."
    - name: "total_ceded_unearned_premium"
      expr: SUM(CAST(ceded_unearned_premium AS DOUBLE))
      comment: "Total unearned premium ceded to reinsurers for measuring future reinsurance cost and balance sheet liability."
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission_amount AS DOUBLE))
      comment: "Total ceding commission received from reinsurers for measuring acquisition cost recovery and profitability enhancement."
    - name: "total_ceded_limit"
      expr: SUM(CAST(ceded_limit AS DOUBLE))
      comment: "Total limit ceded to reinsurers for measuring reinsurance protection capacity and exposure transfer."
    - name: "total_retention"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount across cessions for measuring net risk retained and reinsurance strategy effectiveness."
    - name: "total_ceded_loss_paid"
      expr: SUM(CAST(ceded_loss_paid AS DOUBLE))
      comment: "Total ceded loss paid by reinsurers for measuring actual loss recovery and reinsurance program effectiveness."
    - name: "total_ceded_loss_reserve"
      expr: SUM(CAST(ceded_loss_reserve AS DOUBLE))
      comment: "Total ceded loss reserve held by reinsurers for measuring expected future loss recoveries and balance sheet impact."
    - name: "total_ceded_alae"
      expr: SUM(CAST(ceded_alae AS DOUBLE))
      comment: "Total allocated loss adjustment expense ceded to reinsurers for measuring LAE recovery and claims handling cost transfer."
    - name: "total_ceded_ibnr"
      expr: SUM(CAST(ceded_ibnr AS DOUBLE))
      comment: "Total incurred but not reported loss ceded to reinsurers for measuring IBNR recovery and reserve adequacy."
    - name: "total_reinsurance_recoverable"
      expr: SUM(CAST(reinsurance_recoverable AS DOUBLE))
      comment: "Total reinsurance recoverable balance for measuring outstanding reinsurer obligations and credit exposure."
    - name: "total_reinstatement_premium"
      expr: SUM(CAST(reinstatement_premium AS DOUBLE))
      comment: "Total reinstatement premium paid for measuring cost of reinstating reinsurance limits after loss events."
    - name: "total_collateral_amount"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral held for cessions for measuring credit risk mitigation and regulatory capital relief."
    - name: "avg_ceded_share_pct"
      expr: AVG(CAST(ceded_share_pct AS DOUBLE))
      comment: "Average ceded share percentage for measuring typical risk transfer ratio and retention strategy."
    - name: "avg_ceding_commission_pct"
      expr: AVG(CAST(ceding_commission_pct AS DOUBLE))
      comment: "Average ceding commission percentage for measuring acquisition cost recovery rate and profitability enhancement."
    - name: "avg_rate_on_line_pct"
      expr: AVG(CAST(rate_on_line_pct AS DOUBLE))
      comment: "Average rate on line percentage for measuring reinsurance pricing efficiency and cost of protection."
    - name: "avg_profit_commission_pct"
      expr: AVG(CAST(profit_commission_pct AS DOUBLE))
      comment: "Average profit commission percentage for measuring potential profit sharing with reinsurers."
    - name: "total_gross_written_premium"
      expr: SUM(CAST(gross_written_premium AS DOUBLE))
      comment: "Total gross written premium subject to cession for measuring cession base and premium leverage ratio."
    - name: "total_ceded_tiv"
      expr: SUM(CAST(ceded_tiv AS DOUBLE))
      comment: "Total insured value ceded to reinsurers for measuring exposure transfer and catastrophe protection adequacy."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reinsurance_ceded_premium_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance premium transaction metrics including ceded premium flows, ceding commissions, and settlement performance for cash flow management and reinsurer accounting."
  source: "`vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction`"
  dimensions:
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of premium transaction (original, adjustment, reinstatement, return) for analyzing premium flow patterns and adjustments."
    - name: "transaction_status"
      expr: transaction_status
      comment: "Current status of the transaction (pending, settled, disputed) for monitoring settlement performance and outstanding items."
    - name: "settlement_status"
      expr: settlement_status
      comment: "Settlement status of the transaction for tracking payment completion and cash flow realization."
    - name: "cession_type"
      expr: cession_type
      comment: "Type of cession (treaty, facultative) for segmenting premium transactions by reinsurance structure."
    - name: "treaty_type"
      expr: treaty_type
      comment: "Type of treaty for analyzing premium patterns by treaty structure (quota share, surplus, XOL, cat)."
    - name: "lob_code_id"
      expr: lob_code_id
      comment: "Line of business identifier for segmenting premium transactions by product line."
    - name: "transaction_year"
      expr: YEAR(transaction_date)
      comment: "Year of the transaction for analyzing premium flow trends and annual reinsurance cost."
    - name: "transaction_quarter"
      expr: CONCAT(CAST(YEAR(transaction_date) AS STRING), '-Q', CAST(QUARTER(transaction_date) AS STRING))
      comment: "Quarter of the transaction for seasonal premium pattern analysis and quarterly reinsurance expense tracking."
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month of the transaction for monthly premium flow analysis and cash flow forecasting."
    - name: "accounting_period"
      expr: CONCAT(CAST(YEAR(accounting_period_start_date) AS STRING), '-', LPAD(CAST(MONTH(accounting_period_start_date) AS STRING), 2, '0'))
      comment: "Accounting period for aligning premium transactions with financial reporting periods."
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Whether the reinsurer is authorized for regulatory compliance and credit risk analysis."
    - name: "reversal_flag"
      expr: reversal_flag
      comment: "Whether the transaction is a reversal for identifying premium adjustments and corrections."
    - name: "cat_event_code"
      expr: cat_event_code
      comment: "Catastrophe event code for isolating catastrophe-related premium transactions and reinstatements."
  measures:
    - name: "transaction_count"
      expr: COUNT(1)
      comment: "Total number of ceded premium transactions for measuring transaction volume and processing complexity."
    - name: "total_gwp_ceded"
      expr: SUM(CAST(gwp_ceded_amount AS DOUBLE))
      comment: "Total gross written premium ceded for measuring reinsurance program cost and premium leverage."
    - name: "total_nwp_ceded"
      expr: SUM(CAST(nwp_ceded_amount AS DOUBLE))
      comment: "Total net written premium ceded for measuring net reinsurance cost after returns and cancellations."
    - name: "total_earned_premium_ceded"
      expr: SUM(CAST(earned_premium_ceded_amount AS DOUBLE))
      comment: "Total earned premium ceded for measuring reinsurance cost recognition and profitability impact."
    - name: "total_uep_ceded"
      expr: SUM(CAST(uep_ceded_amount AS DOUBLE))
      comment: "Total unearned premium ceded for measuring future reinsurance cost and balance sheet liability."
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission_amount AS DOUBLE))
      comment: "Total ceding commission received for measuring acquisition cost recovery and profitability enhancement."
    - name: "total_profit_commission"
      expr: SUM(CAST(profit_commission_amount AS DOUBLE))
      comment: "Total profit commission received for measuring profit sharing with reinsurers and underwriting performance incentives."
    - name: "total_reinstatement_premium"
      expr: SUM(CAST(reinstatement_premium_amount AS DOUBLE))
      comment: "Total reinstatement premium paid for measuring cost of reinstating reinsurance limits after loss events."
    - name: "total_adjustment_premium"
      expr: SUM(CAST(adjustment_premium_amount AS DOUBLE))
      comment: "Total adjustment premium for measuring premium true-ups and experience-based adjustments."
    - name: "total_deposit_premium"
      expr: SUM(CAST(deposit_premium_amount AS DOUBLE))
      comment: "Total deposit premium paid for measuring upfront cash flow impact and minimum premium commitments."
    - name: "total_subject_premium"
      expr: SUM(CAST(subject_premium_amount AS DOUBLE))
      comment: "Total subject premium for measuring the premium base used for reinsurance calculations."
    - name: "total_dac_ceded"
      expr: SUM(CAST(dac_ceded_amount AS DOUBLE))
      comment: "Total deferred acquisition cost ceded for measuring DAC recovery and balance sheet impact."
    - name: "avg_cession_pct"
      expr: AVG(CAST(cession_pct AS DOUBLE))
      comment: "Average cession percentage for measuring typical risk transfer ratio across transactions."
    - name: "avg_rol_pct"
      expr: AVG(CAST(rol_pct AS DOUBLE))
      comment: "Average rate on line percentage for measuring reinsurance pricing efficiency and cost of protection."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reinsurance_claim_ri_recovery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance claim recovery metrics including recoverable amounts, collection performance, and dispute resolution for measuring reinsurance program effectiveness and credit risk."
  source: "`vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery`"
  dimensions:
    - name: "recovery_status"
      expr: recovery_status
      comment: "Current status of the recovery (pending, approved, collected, disputed) for monitoring collection performance and outstanding recoveries."
    - name: "recovery_type"
      expr: recovery_type
      comment: "Type of recovery (paid loss, reserve, IBNR) for analyzing recovery composition and timing."
    - name: "recovery_basis"
      expr: recovery_basis
      comment: "Basis of the recovery (proportional, excess, aggregate) for analyzing recovery mechanics and treaty structure."
    - name: "lob_code_id"
      expr: lob_code_id
      comment: "Line of business identifier for segmenting recovery performance by product line."
    - name: "recovery_year"
      expr: YEAR(submission_date)
      comment: "Year the recovery was submitted for analyzing recovery timing and collection lag."
    - name: "recovery_quarter"
      expr: CONCAT(CAST(YEAR(submission_date) AS STRING), '-Q', CAST(QUARTER(submission_date) AS STRING))
      comment: "Quarter the recovery was submitted for seasonal recovery pattern analysis."
    - name: "accounting_period"
      expr: accounting_period
      comment: "Accounting period for aligning recoveries with financial reporting periods."
    - name: "cat_event_code"
      expr: cat_event_code
      comment: "Catastrophe event code for isolating catastrophe-related recoveries and measuring cat program effectiveness."
    - name: "cat_exposed_flag"
      expr: cat_exposed_flag
      comment: "Whether the recovery is catastrophe-exposed for segmenting cat vs attritional recovery performance."
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Whether the reinsurer is authorized for regulatory compliance and credit risk analysis."
    - name: "dispute_flag"
      expr: dispute_flag
      comment: "Whether the recovery is disputed for monitoring dispute frequency and resolution effectiveness."
    - name: "dispute_reason"
      expr: dispute_reason
      comment: "Reason for the dispute for analyzing dispute root causes and improving claims documentation."
    - name: "collateral_required_flag"
      expr: collateral_required_flag
      comment: "Whether collateral is required for the recovery for analyzing credit risk mitigation strategies."
  measures:
    - name: "recovery_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance recoveries for measuring recovery volume and claims complexity."
    - name: "total_recoverable_amount"
      expr: SUM(CAST(recoverable_amount AS DOUBLE))
      comment: "Total recoverable amount from reinsurers for measuring reinsurance program effectiveness and loss mitigation."
    - name: "total_recovered_amount"
      expr: SUM(CAST(recovered_amount AS DOUBLE))
      comment: "Total amount actually recovered from reinsurers for measuring collection performance and cash flow realization."
    - name: "total_outstanding_recoverable"
      expr: SUM(CAST(outstanding_recoverable_amount AS DOUBLE))
      comment: "Total outstanding recoverable balance for measuring credit exposure and collection risk."
    - name: "total_ceded_loss"
      expr: SUM(CAST(ceded_loss_amount AS DOUBLE))
      comment: "Total ceded loss amount for measuring loss transfer to reinsurers and program utilization."
    - name: "total_ceded_alae"
      expr: SUM(CAST(ceded_alae_amount AS DOUBLE))
      comment: "Total ceded allocated loss adjustment expense for measuring LAE recovery and claims handling cost transfer."
    - name: "total_gross_loss"
      expr: SUM(CAST(gross_loss_amount AS DOUBLE))
      comment: "Total gross loss amount for measuring loss severity and reinsurance attachment penetration."
    - name: "total_gross_alae"
      expr: SUM(CAST(gross_alae_amount AS DOUBLE))
      comment: "Total gross allocated loss adjustment expense for measuring total LAE and reinsurance LAE recovery ratio."
    - name: "total_retention"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount for measuring net loss retained and reinsurance attachment effectiveness."
    - name: "total_reinstatement_premium"
      expr: SUM(CAST(reinstatement_premium_amount AS DOUBLE))
      comment: "Total reinstatement premium paid for measuring cost of reinstating reinsurance limits after recoveries."
    - name: "total_collateral_amount"
      expr: SUM(CAST(collateral_amount AS DOUBLE))
      comment: "Total collateral held for recoveries for measuring credit risk mitigation and regulatory capital relief."
    - name: "avg_cession_percentage"
      expr: AVG(CAST(cession_percentage AS DOUBLE))
      comment: "Average cession percentage for measuring typical risk transfer ratio on recovered claims."
    - name: "avg_reinsurer_share_pct"
      expr: AVG(CAST(reinsurer_share_pct AS DOUBLE))
      comment: "Average reinsurer share percentage for measuring reinsurer participation on recovered claims."
    - name: "avg_layer_limit"
      expr: AVG(CAST(layer_limit_amount AS DOUBLE))
      comment: "Average layer limit for measuring typical reinsurance layer size and program structure."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reinsurance_bordereaux`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance bordereaux reporting metrics including premium and loss reporting performance, submission timeliness, and bordereaux accuracy for reinsurer relationship management."
  source: "`vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`"
  dimensions:
    - name: "bordereaux_type"
      expr: bordereaux_type
      comment: "Type of bordereaux (premium, loss, combined) for segmenting reporting by content type."
    - name: "submission_status"
      expr: submission_status
      comment: "Current status of the bordereaux submission (draft, submitted, acknowledged, disputed) for monitoring reporting completion."
    - name: "submission_method"
      expr: submission_method
      comment: "Method of bordereaux submission (electronic, paper, portal) for analyzing reporting efficiency and automation."
    - name: "submission_format"
      expr: submission_format
      comment: "Format of the bordereaux submission for analyzing data quality and processing efficiency."
    - name: "treaty_type"
      expr: treaty_type
      comment: "Type of treaty for analyzing bordereaux patterns by treaty structure."
    - name: "lob_code_id"
      expr: lob_code_id
      comment: "Line of business identifier for segmenting bordereaux reporting by product line."
    - name: "reporting_period"
      expr: CONCAT(CAST(YEAR(reporting_period_start_date) AS STRING), '-', LPAD(CAST(MONTH(reporting_period_start_date) AS STRING), 2, '0'))
      comment: "Reporting period for aligning bordereaux with treaty reporting requirements."
    - name: "accounting_period"
      expr: accounting_period
      comment: "Accounting period for aligning bordereaux with financial reporting periods."
    - name: "treaty_year"
      expr: treaty_year
      comment: "Treaty year for analyzing bordereaux by treaty vintage and underwriting year."
    - name: "cat_event_code"
      expr: cat_event_code
      comment: "Catastrophe event code for isolating catastrophe-related bordereaux and event reporting."
    - name: "cat_exposed_flag"
      expr: cat_exposed_flag
      comment: "Whether the bordereaux includes catastrophe exposure for segmenting cat vs attritional reporting."
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Whether the reinsurer is authorized for regulatory compliance and credit risk analysis."
    - name: "placement_broker"
      expr: placement_broker
      comment: "Placement broker for analyzing broker reporting performance and relationship management."
  measures:
    - name: "bordereaux_count"
      expr: COUNT(1)
      comment: "Total number of bordereaux submissions for measuring reporting volume and compliance."
    - name: "total_gross_ceded_premium"
      expr: SUM(CAST(gross_ceded_premium AS DOUBLE))
      comment: "Total gross ceded premium reported in bordereaux for measuring premium reporting completeness."
    - name: "total_net_ceded_premium"
      expr: SUM(CAST(net_ceded_premium AS DOUBLE))
      comment: "Total net ceded premium reported in bordereaux for measuring net premium transfer after adjustments."
    - name: "total_ceded_premium_adjustment"
      expr: SUM(CAST(ceded_premium_adjustment AS DOUBLE))
      comment: "Total ceded premium adjustments for measuring premium true-ups and experience-based adjustments."
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission_amount AS DOUBLE))
      comment: "Total ceding commission reported in bordereaux for measuring acquisition cost recovery."
    - name: "total_profit_commission"
      expr: SUM(CAST(profit_commission_amount AS DOUBLE))
      comment: "Total profit commission reported in bordereaux for measuring profit sharing with reinsurers."
    - name: "total_experience_refund"
      expr: SUM(CAST(experience_refund_amount AS DOUBLE))
      comment: "Total experience refund reported in bordereaux for measuring favorable loss experience returns."
    - name: "total_ceded_loss"
      expr: SUM(CAST(ceded_loss_amount AS DOUBLE))
      comment: "Total ceded loss reported in bordereaux for measuring loss reporting completeness and program utilization."
    - name: "total_ceded_alae"
      expr: SUM(CAST(ceded_alae_amount AS DOUBLE))
      comment: "Total ceded allocated loss adjustment expense reported in bordereaux for measuring LAE reporting completeness."
    - name: "total_ceded_ulae"
      expr: SUM(CAST(ceded_ulae_amount AS DOUBLE))
      comment: "Total ceded unallocated loss adjustment expense reported in bordereaux for measuring ULAE recovery."
    - name: "total_ceded_ibnr"
      expr: SUM(CAST(ceded_ibnr_amount AS DOUBLE))
      comment: "Total ceded IBNR reported in bordereaux for measuring IBNR reporting and reserve adequacy."
    - name: "total_recoverable_balance"
      expr: SUM(CAST(recoverable_balance AS DOUBLE))
      comment: "Total recoverable balance reported in bordereaux for measuring outstanding reinsurer obligations."
    - name: "total_retention"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount reported in bordereaux for measuring net risk retained."
    - name: "total_ceded_tiv"
      expr: SUM(CAST(ceded_tiv AS DOUBLE))
      comment: "Total insured value ceded reported in bordereaux for measuring exposure reporting completeness."
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS BIGINT))
      comment: "Total policy count reported in bordereaux for measuring policy reporting volume and portfolio size."
    - name: "total_claim_count"
      expr: SUM(CAST(claim_count AS BIGINT))
      comment: "Total claim count reported in bordereaux for measuring claim reporting volume and loss frequency."
    - name: "avg_ceded_share_pct"
      expr: AVG(CAST(ceded_share_pct AS DOUBLE))
      comment: "Average ceded share percentage reported in bordereaux for measuring typical risk transfer ratio."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reinsurance_ri_recoverable`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance recoverable aging and credit risk metrics including outstanding balances, collection performance, and write-off analysis for managing reinsurer credit exposure."
  source: "`vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable`"
  dimensions:
    - name: "recoverable_status"
      expr: recoverable_status
      comment: "Current status of the recoverable (billed, collected, overdue, disputed, written off) for monitoring collection performance."
    - name: "recoverable_type"
      expr: recoverable_type
      comment: "Type of recoverable (paid loss, case reserve, IBNR) for analyzing recoverable composition and timing."
    - name: "loss_type"
      expr: loss_type
      comment: "Type of loss (attritional, large loss, catastrophe) for segmenting recoverables by loss severity."
    - name: "reserve_category"
      expr: reserve_category
      comment: "Reserve category for analyzing recoverables by reserve type and development pattern."
    - name: "lob_code_id"
      expr: lob_code_id
      comment: "Line of business identifier for segmenting recoverables by product line."
    - name: "accounting_period"
      expr: accounting_period
      comment: "Accounting period for aligning recoverables with financial reporting periods."
    - name: "loss_year"
      expr: YEAR(loss_date)
      comment: "Year of loss for analyzing recoverables by loss vintage and development lag."
    - name: "treaty_year"
      expr: treaty_year
      comment: "Treaty year for analyzing recoverables by treaty vintage and underwriting year."
    - name: "cat_event_code"
      expr: cat_event_code
      comment: "Catastrophe event code for isolating catastrophe-related recoverables and measuring cat program effectiveness."
    - name: "cat_event_flag"
      expr: cat_event_flag
      comment: "Whether the recoverable is catastrophe-related for segmenting cat vs attritional recoverables."
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Whether the reinsurer is authorized for regulatory compliance and credit risk analysis."
    - name: "overdue_flag"
      expr: overdue_flag
      comment: "Whether the recoverable is overdue for monitoring collection timeliness and credit risk."
    - name: "credit_allowed_flag"
      expr: credit_allowed_flag
      comment: "Whether credit is allowed for the recoverable for regulatory capital treatment and reserve credit analysis."
  measures:
    - name: "recoverable_count"
      expr: COUNT(1)
      comment: "Total number of reinsurance recoverables for measuring recoverable volume and portfolio complexity."
    - name: "total_recoverable_balance"
      expr: SUM(CAST(recoverable_balance AS DOUBLE))
      comment: "Total outstanding recoverable balance for measuring credit exposure and collection risk."
    - name: "total_collected_amount"
      expr: SUM(CAST(collected_amount AS DOUBLE))
      comment: "Total amount collected from reinsurers for measuring collection performance and cash flow realization."
    - name: "total_disputed_amount"
      expr: SUM(CAST(disputed_amount AS DOUBLE))
      comment: "Total disputed recoverable amount for measuring dispute frequency and resolution effectiveness."
    - name: "total_written_off_amount"
      expr: SUM(CAST(written_off_amount AS DOUBLE))
      comment: "Total written off recoverable amount for measuring credit losses and reinsurer default impact."
    - name: "total_ceded_loss"
      expr: SUM(CAST(ceded_loss_amount AS DOUBLE))
      comment: "Total ceded loss amount for measuring loss transfer to reinsurers and program utilization."
    - name: "total_ceded_alae"
      expr: SUM(CAST(ceded_alae_amount AS DOUBLE))
      comment: "Total ceded allocated loss adjustment expense for measuring LAE recovery and claims handling cost transfer."
    - name: "total_gross_loss"
      expr: SUM(CAST(gross_loss_amount AS DOUBLE))
      comment: "Total gross loss amount for measuring loss severity and reinsurance attachment penetration."
    - name: "total_collateral_held"
      expr: SUM(CAST(collateral_held_amount AS DOUBLE))
      comment: "Total collateral held for recoverables for measuring credit risk mitigation and regulatory capital relief."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`reinsurance_profit_commission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reinsurance profit commission metrics including commission calculations, loss ratio performance, and sliding scale analysis for measuring treaty profitability and reinsurer alignment."
  source: "`vibe_pc_insurance_v499`.`reinsurance`.`profit_commission`"
  dimensions:
    - name: "calculation_status"
      expr: calculation_status
      comment: "Current status of the profit commission calculation (draft, calculated, approved, paid) for monitoring calculation workflow."
    - name: "calculation_method"
      expr: calculation_method
      comment: "Method used for profit commission calculation (sliding scale, fixed percentage, formula) for analyzing commission structure."
    - name: "treaty_type"
      expr: treaty_type
      comment: "Type of treaty for analyzing profit commission patterns by treaty structure."
    - name: "lob_code_id"
      expr: lob_code_id
      comment: "Line of business identifier for segmenting profit commission by product line."
    - name: "accounting_period"
      expr: accounting_period
      comment: "Accounting period for aligning profit commission with financial reporting periods."
    - name: "treaty_year"
      expr: treaty_year
      comment: "Treaty year for analyzing profit commission by treaty vintage and underwriting year."
    - name: "calculation_year"
      expr: YEAR(calculation_date)
      comment: "Year of calculation for analyzing profit commission timing and recognition patterns."
    - name: "authorized_reinsurer_flag"
      expr: authorized_reinsurer_flag
      comment: "Whether the reinsurer is authorized for regulatory compliance and credit risk analysis."
    - name: "provisional_flag"
      expr: provisional_flag
      comment: "Whether the profit commission is provisional for distinguishing preliminary vs final calculations."
  measures:
    - name: "profit_commission_count"
      expr: COUNT(1)
      comment: "Total number of profit commission calculations for measuring calculation volume and treaty complexity."
    - name: "total_profit_commission"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total profit commission amount for measuring profit sharing with reinsurers and treaty profitability."
    - name: "total_paid_commission"
      expr: SUM(CAST(paid_commission_amount AS DOUBLE))
      comment: "Total paid profit commission for measuring cash flow impact and payment performance."
    - name: "total_accrued_commission"
      expr: SUM(CAST(accrued_commission_amount AS DOUBLE))
      comment: "Total accrued profit commission for measuring outstanding commission liability and balance sheet impact."
    - name: "total_outstanding_balance"
      expr: SUM(CAST(outstanding_balance AS DOUBLE))
      comment: "Total outstanding profit commission balance for measuring unpaid commission and cash flow forecasting."
    - name: "total_adjustment_amount"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total profit commission adjustments for measuring calculation true-ups and experience-based adjustments."
    - name: "total_ceded_premium"
      expr: SUM(CAST(ceded_premium_amount AS DOUBLE))
      comment: "Total ceded premium used in profit commission calculation for measuring commission base."
    - name: "total_net_ceded_premium"
      expr: SUM(CAST(net_ceded_premium AS DOUBLE))
      comment: "Total net ceded premium used in profit commission calculation for measuring net commission base."
    - name: "total_ceded_loss"
      expr: SUM(CAST(ceded_loss_amount AS DOUBLE))
      comment: "Total ceded loss used in profit commission calculation for measuring loss experience and commission eligibility."
    - name: "total_ceded_alae"
      expr: SUM(CAST(ceded_alae_amount AS DOUBLE))
      comment: "Total ceded ALAE used in profit commission calculation for measuring total loss cost including LAE."
    - name: "total_ceded_ulae"
      expr: SUM(CAST(ceded_ulae_amount AS DOUBLE))
      comment: "Total ceded ULAE used in profit commission calculation for measuring total loss cost including ULAE."
    - name: "total_ceded_loss_lae"
      expr: SUM(CAST(total_ceded_loss_lae AS DOUBLE))
      comment: "Total ceded loss plus LAE for measuring total loss cost used in profit commission calculation."
    - name: "total_ceding_commission"
      expr: SUM(CAST(ceding_commission_amount AS DOUBLE))
      comment: "Total ceding commission used in profit commission calculation for measuring acquisition cost recovery."
    - name: "avg_calculated_loss_ratio_pct"
      expr: AVG(CAST(calculated_loss_ratio_pct AS DOUBLE))
      comment: "Average calculated loss ratio percentage for measuring treaty loss experience and profit commission eligibility."
    - name: "avg_calculated_commission_rate_pct"
      expr: AVG(CAST(calculated_commission_rate_pct AS DOUBLE))
      comment: "Average calculated commission rate percentage for measuring profit commission rate and sliding scale performance."
    - name: "avg_loss_ratio_threshold_pct"
      expr: AVG(CAST(loss_ratio_threshold_pct AS DOUBLE))
      comment: "Average loss ratio threshold percentage for measuring profit commission trigger points and treaty terms."
    - name: "avg_sliding_scale_min_pct"
      expr: AVG(CAST(sliding_scale_min_pct AS DOUBLE))
      comment: "Average sliding scale minimum percentage for measuring profit commission floor and treaty terms."
    - name: "avg_sliding_scale_max_pct"
      expr: AVG(CAST(sliding_scale_max_pct AS DOUBLE))
      comment: "Average sliding scale maximum percentage for measuring profit commission ceiling and treaty terms."
$$;