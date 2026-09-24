-- Metric views for domain: shared | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`shared_calendar`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Calendar business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`shared`.`calendar`"
  dimensions:
    - name: "Close Date"
      expr: close_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "End Date"
      expr: end_date
    - name: "Gaap Period Key"
      expr: gaap_period_key
    - name: "Ifrs17 Period Key"
      expr: ifrs17_period_key
    - name: "Is Closed"
      expr: is_closed
    - name: "Is Current Period"
      expr: is_current_period
    - name: "Is Leap Year"
      expr: is_leap_year
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Period Key"
      expr: period_key
    - name: "Period Name"
      expr: period_name
    - name: "Period Status"
      expr: period_status
    - name: "Period Type"
      expr: period_type
    - name: "Reporting Period Key"
      expr: reporting_period_key
    - name: "Sap Period Key"
      expr: sap_period_key
    - name: "Start Date"
      expr: start_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Calendar"
      expr: COUNT(DISTINCT calendar_id)
    - name: "Total Accident Year"
      expr: SUM(accident_year)
    - name: "Average Accident Year"
      expr: AVG(accident_year)
    - name: "Total Day Count"
      expr: SUM(day_count)
    - name: "Average Day Count"
      expr: AVG(day_count)
    - name: "Total Fiscal Month"
      expr: SUM(fiscal_month)
    - name: "Average Fiscal Month"
      expr: AVG(fiscal_month)
    - name: "Total Fiscal Quarter"
      expr: SUM(fiscal_quarter)
    - name: "Average Fiscal Quarter"
      expr: AVG(fiscal_quarter)
    - name: "Total Fiscal Year"
      expr: SUM(fiscal_year)
    - name: "Average Fiscal Year"
      expr: AVG(fiscal_year)
    - name: "Total Fiscal Year Start Month"
      expr: SUM(fiscal_year_start_month)
    - name: "Average Fiscal Year Start Month"
      expr: AVG(fiscal_year_start_month)
    - name: "Total Month"
      expr: SUM(month)
    - name: "Average Month"
      expr: AVG(month)
    - name: "Total Naic Reporting Quarter"
      expr: SUM(naic_reporting_quarter)
    - name: "Average Naic Reporting Quarter"
      expr: AVG(naic_reporting_quarter)
    - name: "Total Naic Reporting Year"
      expr: SUM(naic_reporting_year)
    - name: "Average Naic Reporting Year"
      expr: AVG(naic_reporting_year)
    - name: "Total Policy Year"
      expr: SUM(policy_year)
    - name: "Average Policy Year"
      expr: AVG(policy_year)
    - name: "Total Quarter"
      expr: SUM(quarter)
    - name: "Average Quarter"
      expr: AVG(quarter)
    - name: "Total Week"
      expr: SUM(week)
    - name: "Average Week"
      expr: AVG(week)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`shared_classification_code`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Classification Code business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`shared`.`classification_code`"
  dimensions:
    - name: "Appetite Tier"
      expr: appetite_tier
    - name: "Classification Code Status"
      expr: classification_code_status
    - name: "Classification System"
      expr: classification_system
    - name: "Code"
      expr: classification_code_code
    - name: "Code Description"
      expr: code_description
    - name: "Construction Type"
      expr: construction_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deductible Options"
      expr: deductible_options
    - name: "Effective Date"
      expr: effective_date
    - name: "Eligibility Flag"
      expr: eligibility_flag
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exposure Category"
      expr: exposure_category
    - name: "Hazard Group"
      expr: hazard_group
    - name: "Industry Group"
      expr: industry_group
    - name: "Iso Edition"
      expr: iso_edition
    - name: "Iso Gl Class Code"
      expr: iso_gl_class_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Classification Code"
      expr: COUNT(DISTINCT classification_code_id)
    - name: "Total Base Rate"
      expr: SUM(base_rate)
    - name: "Average Base Rate"
      expr: AVG(base_rate)
    - name: "Total Expense Provision"
      expr: SUM(expense_provision)
    - name: "Average Expense Provision"
      expr: AVG(expense_provision)
    - name: "Total Increased Limits Factor"
      expr: SUM(increased_limits_factor)
    - name: "Average Increased Limits Factor"
      expr: AVG(increased_limits_factor)
    - name: "Total Loss Cost"
      expr: SUM(loss_cost)
    - name: "Average Loss Cost"
      expr: AVG(loss_cost)
    - name: "Total Minimum Premium"
      expr: SUM(minimum_premium)
    - name: "Average Minimum Premium"
      expr: AVG(minimum_premium)
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
  comment: "Line Of Business business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`"
  dimensions:
    - name: "Catastrophe Exposed"
      expr: catastrophe_exposed
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Description"
      expr: line_of_business_description
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Is Admitted"
      expr: is_admitted
    - name: "Is Surplus Lines"
      expr: is_surplus_lines
    - name: "Iso Line Code"
      expr: iso_line_code
    - name: "Line Of Business Status"
      expr: line_of_business_status
    - name: "Lob Abbreviation"
      expr: lob_abbreviation
    - name: "Lob Category"
      expr: lob_category
    - name: "Lob Code"
      expr: lob_code
    - name: "Lob Name"
      expr: lob_name
    - name: "Lob Type"
      expr: lob_type
    - name: "Naic Line Code"
      expr: naic_line_code
    - name: "Regulatory Approval Date"
      expr: regulatory_approval_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Line Of Business"
      expr: COUNT(DISTINCT line_of_business_id)
    - name: "Total Combined Ratio Target Pct"
      expr: SUM(combined_ratio_target_pct)
    - name: "Average Combined Ratio Target Pct"
      expr: AVG(combined_ratio_target_pct)
    - name: "Total Default Commission Pct"
      expr: SUM(default_commission_pct)
    - name: "Average Default Commission Pct"
      expr: AVG(default_commission_pct)
    - name: "Total Default Policy Term Months"
      expr: SUM(default_policy_term_months)
    - name: "Average Default Policy Term Months"
      expr: AVG(default_policy_term_months)
    - name: "Total Display Order"
      expr: SUM(display_order)
    - name: "Average Display Order"
      expr: AVG(display_order)
    - name: "Total Expense Ratio Target Pct"
      expr: SUM(expense_ratio_target_pct)
    - name: "Average Expense Ratio Target Pct"
      expr: AVG(expense_ratio_target_pct)
    - name: "Total Loss Ratio Target Pct"
      expr: SUM(loss_ratio_target_pct)
    - name: "Average Loss Ratio Target Pct"
      expr: AVG(loss_ratio_target_pct)
    - name: "Total Minimum Premium Amount"
      expr: SUM(minimum_premium_amount)
    - name: "Average Minimum Premium Amount"
      expr: AVG(minimum_premium_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`shared_unit_of_measure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Unit Of Measure business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`shared`.`unit_of_measure`"
  dimensions:
    - name: "Acord Code"
      expr: acord_code
    - name: "Audit Required Flag"
      expr: audit_required_flag
    - name: "Base Unit Code"
      expr: base_unit_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Display Format"
      expr: display_format
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exposure Basis Flag"
      expr: exposure_basis_flag
    - name: "Iso Standard Code"
      expr: iso_standard_code
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Modified By User"
      expr: modified_by_user
    - name: "Naic Code"
      expr: naic_code
    - name: "Notes"
      expr: notes
    - name: "System Of Measurement"
      expr: system_of_measurement
    - name: "Unit Of Measure Status"
      expr: unit_of_measure_status
    - name: "Uom Abbreviation"
      expr: uom_abbreviation
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Unit Of Measure"
      expr: COUNT(DISTINCT unit_of_measure_id)
    - name: "Total Conversion Factor To Base"
      expr: SUM(conversion_factor_to_base)
    - name: "Average Conversion Factor To Base"
      expr: AVG(conversion_factor_to_base)
    - name: "Total Decimal Precision"
      expr: SUM(decimal_precision)
    - name: "Average Decimal Precision"
      expr: AVG(decimal_precision)
$$;