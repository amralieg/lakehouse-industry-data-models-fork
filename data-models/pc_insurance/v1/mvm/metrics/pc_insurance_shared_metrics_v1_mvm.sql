-- Metric views for domain: shared | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`shared_calendar`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Accounting period and calendar metrics for financial reporting, GAAP, IFRS17, SAP, and NAIC compliance. Grain: one row per accounting period."
  source: "`vibe_pc_insurance_blog_v499`.`shared`.`calendar`"
  dimensions:
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year for financial reporting and premium/claim accounting period aggregation."
    - name: "fiscal_quarter"
      expr: fiscal_quarter
      comment: "Fiscal quarter (1-4) for quarterly business reviews and regulatory reporting."
    - name: "fiscal_month"
      expr: fiscal_month
      comment: "Fiscal month (1-12) for monthly premium earned and claim incurred analysis."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development triangles and actuarial reserve analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year for cohort analysis of written premium and loss ratio trends."
    - name: "calendar_year"
      expr: year
      comment: "Calendar year for statutory reporting and year-over-year performance comparison."
    - name: "naic_reporting_year"
      expr: naic_reporting_year
      comment: "NAIC reporting year for statutory annual statement and Schedule P filing."
    - name: "naic_reporting_quarter"
      expr: naic_reporting_quarter
      comment: "NAIC reporting quarter for quarterly statutory financial statements."
    - name: "period_type"
      expr: period_type
      comment: "Type of accounting period (monthly, quarterly, annual) for aggregation control."
    - name: "period_status"
      expr: period_status
      comment: "Status of accounting period (open, closed, locked) for financial close governance."
    - name: "is_current_period"
      expr: is_current_period
      comment: "Flag indicating the current active accounting period for real-time reporting."
    - name: "is_closed"
      expr: is_closed
      comment: "Flag indicating whether the accounting period is closed for transaction posting."
    - name: "gaap_period_key"
      expr: gaap_period_key
      comment: "GAAP accounting period key for US GAAP financial statement preparation."
    - name: "ifrs17_period_key"
      expr: ifrs17_period_key
      comment: "IFRS 17 period key for international insurance contract accounting."
    - name: "sap_period_key"
      expr: sap_period_key
      comment: "Statutory Accounting Principles period key for NAIC annual statement reporting."
  measures:
    - name: "total_periods"
      expr: COUNT(1)
      comment: "Total number of accounting periods available for financial reporting and analysis."
    - name: "total_calendar_days"
      expr: SUM(CAST(day_count AS DOUBLE))
      comment: "Total calendar days across periods for premium earning and exposure calculation."
    - name: "avg_days_per_period"
      expr: AVG(CAST(day_count AS DOUBLE))
      comment: "Average days per accounting period for normalized premium and claim trending."
    - name: "distinct_fiscal_years"
      expr: COUNT(DISTINCT fiscal_year)
      comment: "Count of distinct fiscal years for multi-year loss development and reserve adequacy analysis."
    - name: "distinct_accident_years"
      expr: COUNT(DISTINCT accident_year)
      comment: "Count of distinct accident years for actuarial loss triangle construction and IBNR estimation."
    - name: "distinct_policy_years"
      expr: COUNT(DISTINCT policy_year)
      comment: "Count of distinct policy years for cohort-based underwriting performance evaluation."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`shared_currency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_blog_v499`.`shared`.`currency`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`shared_line_of_business`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Line of business master metrics for underwriting performance, profitability targets, and regulatory compliance. Grain: one row per line of business."
  source: "`vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`"
  dimensions:
    - name: "lob_code"
      expr: lob_code
      comment: "Line of business code for policy, premium, and claim aggregation and reporting."
    - name: "lob_name"
      expr: lob_name
      comment: "Line of business name for executive dashboards and business unit performance tracking."
    - name: "lob_abbreviation"
      expr: lob_abbreviation
      comment: "Short abbreviation for line of business used in operational reports and system interfaces."
    - name: "lob_category"
      expr: lob_category
      comment: "Line category (Personal, Commercial, Specialty) for portfolio segmentation and capital allocation."
    - name: "lob_type"
      expr: lob_type
      comment: "Line type (Property, Casualty, Package) for underwriting strategy and reinsurance treaty structuring."
    - name: "line_of_business_status"
      expr: line_of_business_status
      comment: "Status (Active, Inactive, Runoff) for product portfolio management and strategic planning."
    - name: "iso_line_code"
      expr: iso_line_code
      comment: "ISO line code for industry benchmarking and statistical reporting to advisory organizations."
    - name: "naic_line_code"
      expr: naic_line_code
      comment: "NAIC line code for statutory annual statement Schedule P and loss reserve disclosure."
    - name: "schedule_p_line_number"
      expr: schedule_p_line_number
      comment: "Schedule P line number for NAIC statutory reporting and actuarial reserve triangulation."
    - name: "is_admitted"
      expr: is_admitted
      comment: "Flag indicating admitted line for state regulatory compliance and guaranty fund participation."
    - name: "is_surplus_lines"
      expr: is_surplus_lines
      comment: "Flag indicating surplus lines for non-admitted market and specialty risk underwriting."
    - name: "catastrophe_exposed"
      expr: catastrophe_exposed
      comment: "Flag indicating catastrophe exposure for PML modeling and reinsurance treaty attachment."
    - name: "reinsurance_treaty_applicable"
      expr: reinsurance_treaty_applicable
      comment: "Flag indicating whether line is covered by reinsurance treaty for cession and recovery."
    - name: "requires_state_filing"
      expr: requires_state_filing
      comment: "Flag indicating state rate and form filing requirement for regulatory compliance."
    - name: "supports_package_policy"
      expr: supports_package_policy
      comment: "Flag indicating support for package policy bundling for cross-sell and retention strategy."
  measures:
    - name: "total_lines_of_business"
      expr: COUNT(1)
      comment: "Total number of lines of business for product portfolio breadth and diversification assessment."
    - name: "avg_loss_ratio_target_pct"
      expr: AVG(CAST(loss_ratio_target_pct AS DOUBLE))
      comment: "Average loss ratio target across lines for underwriting profitability benchmarking and pricing discipline."
    - name: "avg_expense_ratio_target_pct"
      expr: AVG(CAST(expense_ratio_target_pct AS DOUBLE))
      comment: "Average expense ratio target across lines for operational efficiency and cost management steering."
    - name: "avg_combined_ratio_target_pct"
      expr: AVG(CAST(combined_ratio_target_pct AS DOUBLE))
      comment: "Average combined ratio target across lines for overall underwriting profitability and capital adequacy planning."
    - name: "avg_default_commission_pct"
      expr: AVG(CAST(default_commission_pct AS DOUBLE))
      comment: "Average default commission rate across lines for producer compensation budgeting and distribution cost analysis."
    - name: "total_minimum_premium"
      expr: SUM(CAST(minimum_premium_amount AS DOUBLE))
      comment: "Total minimum premium across lines for small account profitability and underwriting appetite assessment."
    - name: "avg_minimum_premium"
      expr: AVG(CAST(minimum_premium_amount AS DOUBLE))
      comment: "Average minimum premium per line for pricing floor enforcement and account selection strategy."
    - name: "catastrophe_exposed_lines"
      expr: SUM(CAST(CASE WHEN catastrophe_exposed = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of catastrophe-exposed lines for PML aggregation and reinsurance program design."
    - name: "treaty_applicable_lines"
      expr: SUM(CAST(CASE WHEN reinsurance_treaty_applicable = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of lines covered by reinsurance treaty for cession planning and recovery forecasting."
    - name: "admitted_lines"
      expr: SUM(CAST(CASE WHEN is_admitted = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of admitted lines for regulatory capital allocation and guaranty fund assessment."
    - name: "surplus_lines"
      expr: SUM(CAST(CASE WHEN is_surplus_lines = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of surplus lines for non-admitted market strategy and specialty risk appetite."
$$;