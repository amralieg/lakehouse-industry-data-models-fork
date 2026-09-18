-- Metric views for domain: shared | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`shared_calendar`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Calendar business metrics"
  source: "`vibe_pc_insurance_v499`.`shared`.`calendar`"
  dimensions:
    - name: "Accounting Period"
      expr: accounting_period
    - name: "Calendar Date"
      expr: calendar_date
    - name: "Cat Season Indicator"
      expr: cat_season_indicator
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Day Name"
      expr: day_name
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fiscal Period End Date"
      expr: fiscal_period_end_date
    - name: "Fiscal Period Start Date"
      expr: fiscal_period_start_date
    - name: "Holiday Name"
      expr: holiday_name
    - name: "Is Business Day"
      expr: is_business_day
    - name: "Is Current"
      expr: is_current
    - name: "Is Holiday"
      expr: is_holiday
    - name: "Is Leap Year"
      expr: is_leap_year
    - name: "Is Month End"
      expr: is_month_end
    - name: "Is Quarter End"
      expr: is_quarter_end
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Calendar"
      expr: COUNT(DISTINCT calendar_id)
    - name: "Total Accident Year"
      expr: SUM(accident_year)
    - name: "Average Accident Year"
      expr: AVG(accident_year)
    - name: "Total Day Of Month"
      expr: SUM(day_of_month)
    - name: "Average Day Of Month"
      expr: AVG(day_of_month)
    - name: "Total Day Of Week"
      expr: SUM(day_of_week)
    - name: "Average Day Of Week"
      expr: AVG(day_of_week)
    - name: "Total Day Of Year"
      expr: SUM(day_of_year)
    - name: "Average Day Of Year"
      expr: AVG(day_of_year)
    - name: "Total Days In Month"
      expr: SUM(days_in_month)
    - name: "Average Days In Month"
      expr: AVG(days_in_month)
    - name: "Total Days In Year"
      expr: SUM(days_in_year)
    - name: "Average Days In Year"
      expr: AVG(days_in_year)
    - name: "Total Fiscal Month"
      expr: SUM(fiscal_month)
    - name: "Average Fiscal Month"
      expr: AVG(fiscal_month)
    - name: "Total Fiscal Quarter"
      expr: SUM(fiscal_quarter)
    - name: "Average Fiscal Quarter"
      expr: AVG(fiscal_quarter)
    - name: "Total Fiscal Week"
      expr: SUM(fiscal_week)
    - name: "Average Fiscal Week"
      expr: AVG(fiscal_week)
    - name: "Total Fiscal Year"
      expr: SUM(fiscal_year)
    - name: "Average Fiscal Year"
      expr: AVG(fiscal_year)
    - name: "Total Month"
      expr: SUM(month)
    - name: "Average Month"
      expr: AVG(month)
    - name: "Total Policy Year"
      expr: SUM(policy_year)
    - name: "Average Policy Year"
      expr: AVG(policy_year)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`shared_country`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_v499`.`shared`.`country`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`shared_currency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_v499`.`shared`.`currency`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`shared_lob_code`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Lob Code business metrics"
  source: "`vibe_pc_insurance_v499`.`shared`.`lob_code`"
  dimensions:
    - name: "Cat Exposure Flag"
      expr: cat_exposure_flag
    - name: "Claims Made Basis Flag"
      expr: claims_made_basis_flag
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Description"
      expr: lob_code_description
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gaap Accounting Line"
      expr: gaap_accounting_line
    - name: "Is Admitted"
      expr: is_admitted
    - name: "Is Monoline"
      expr: is_monoline
    - name: "Is Package Eligible"
      expr: is_package_eligible
    - name: "Iso Line Code"
      expr: iso_line_code
    - name: "Lob Abbreviation"
      expr: lob_abbreviation
    - name: "Lob Category"
      expr: lob_category
    - name: "Lob Code"
      expr: lob_code
    - name: "Lob Name"
      expr: lob_name
    - name: "Lob Status"
      expr: lob_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Lob Code"
      expr: COUNT(DISTINCT lob_code_id)
    - name: "Total Commission Rate Pct"
      expr: SUM(commission_rate_pct)
    - name: "Average Commission Rate Pct"
      expr: AVG(commission_rate_pct)
    - name: "Total Loss Development Period Months"
      expr: SUM(loss_development_period_months)
    - name: "Average Loss Development Period Months"
      expr: AVG(loss_development_period_months)
    - name: "Total Reinsurance Ceded Pct"
      expr: SUM(reinsurance_ceded_pct)
    - name: "Average Reinsurance Ceded Pct"
      expr: AVG(reinsurance_ceded_pct)
    - name: "Total Renewal Commission Rate Pct"
      expr: SUM(renewal_commission_rate_pct)
    - name: "Average Renewal Commission Rate Pct"
      expr: AVG(renewal_commission_rate_pct)
    - name: "Total Risk Based Capital Factor"
      expr: SUM(risk_based_capital_factor)
    - name: "Average Risk Based Capital Factor"
      expr: AVG(risk_based_capital_factor)
    - name: "Total Sort Order"
      expr: SUM(sort_order)
    - name: "Average Sort Order"
      expr: AVG(sort_order)
    - name: "Total Target Combined Ratio Pct"
      expr: SUM(target_combined_ratio_pct)
    - name: "Average Target Combined Ratio Pct"
      expr: AVG(target_combined_ratio_pct)
    - name: "Total Target Expense Ratio Pct"
      expr: SUM(target_expense_ratio_pct)
    - name: "Average Target Expense Ratio Pct"
      expr: AVG(target_expense_ratio_pct)
    - name: "Total Target Loss Ratio Pct"
      expr: SUM(target_loss_ratio_pct)
    - name: "Average Target Loss Ratio Pct"
      expr: AVG(target_loss_ratio_pct)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`shared_org_unit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Org Unit business metrics"
  source: "`vibe_pc_insurance_v499`.`shared`.`org_unit`"
  dimensions:
    - name: "Address Line1"
      expr: address_line1
    - name: "Address Line2"
      expr: address_line2
    - name: "City"
      expr: city
    - name: "Cost Center Code"
      expr: cost_center_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Description"
      expr: org_unit_description
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fein"
      expr: fein
    - name: "Is Licensed"
      expr: is_licensed
    - name: "Manager Email"
      expr: manager_email
    - name: "Manager Name"
      expr: manager_name
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Naic Company Code"
      expr: naic_company_code
    - name: "Phone Number"
      expr: phone_number
    - name: "Postal Code"
      expr: postal_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Org Unit"
      expr: COUNT(DISTINCT org_unit_id)
    - name: "Total Budget Amount"
      expr: SUM(budget_amount)
    - name: "Average Budget Amount"
      expr: AVG(budget_amount)
    - name: "Total Headcount"
      expr: SUM(headcount)
    - name: "Average Headcount"
      expr: AVG(headcount)
    - name: "Total Hierarchy Level"
      expr: SUM(hierarchy_level)
    - name: "Average Hierarchy Level"
      expr: AVG(hierarchy_level)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`shared_party`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Party business metrics"
  source: "`vibe_pc_insurance_v499`.`shared`.`party`"
  dimensions:
    - name: "Address Line 1"
      expr: address_line_1
    - name: "Address Line 2"
      expr: address_line_2
    - name: "City"
      expr: city
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Date Of Birth"
      expr: date_of_birth
    - name: "Doing Business As Name"
      expr: doing_business_as_name
    - name: "Email Address"
      expr: email_address
    - name: "Established Date"
      expr: established_date
    - name: "Fax Number"
      expr: fax_number
    - name: "First Name"
      expr: first_name
    - name: "Gender"
      expr: gender
    - name: "Industry Code"
      expr: industry_code
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Last Name"
      expr: last_name
    - name: "Legal Name"
      expr: legal_name
    - name: "License Expiration Date"
      expr: license_expiration_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Party"
      expr: COUNT(DISTINCT party_id)
    - name: "Total Commission Rate"
      expr: SUM(commission_rate)
    - name: "Average Commission Rate"
      expr: AVG(commission_rate)
    - name: "Total Credit Score"
      expr: SUM(credit_score)
    - name: "Average Credit Score"
      expr: AVG(credit_score)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`shared_state`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "State business metrics"
  source: "`vibe_pc_insurance_v499`.`shared`.`state`"
  dimensions:
    - name: "Active Indicator"
      expr: active_indicator
    - name: "Catastrophe Exposure Zone"
      expr: catastrophe_exposure_zone
    - name: "Coastal State Indicator"
      expr: coastal_state_indicator
    - name: "Code"
      expr: state_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Doi Contact Email"
      expr: doi_contact_email
    - name: "Doi Contact Phone"
      expr: doi_contact_phone
    - name: "Doi Mailing Address"
      expr: doi_mailing_address
    - name: "Doi Name"
      expr: doi_name
    - name: "Doi Website Url"
      expr: doi_website_url
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Filing System Type"
      expr: filing_system_type
    - name: "Fips Code"
      expr: fips_code
    - name: "Form Filing Requirement"
      expr: form_filing_requirement
    - name: "Guaranty Fund Participation"
      expr: guaranty_fund_participation
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct State"
      expr: COUNT(DISTINCT state_id)
    - name: "Total Premium Tax Rate"
      expr: SUM(premium_tax_rate)
    - name: "Average Premium Tax Rate"
      expr: AVG(premium_tax_rate)
    - name: "Total Surplus Lines Tax Rate"
      expr: SUM(surplus_lines_tax_rate)
    - name: "Average Surplus Lines Tax Rate"
      expr: AVG(surplus_lines_tax_rate)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`shared_user_account`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "User Account business metrics"
  source: "`vibe_pc_insurance_v499`.`shared`.`user_account`"
  dimensions:
    - name: "Account Expiration Date"
      expr: account_expiration_date
    - name: "Account Locked Flag"
      expr: account_locked_flag
    - name: "Account Status"
      expr: account_status
    - name: "Account Type"
      expr: account_type
    - name: "Authentication Method"
      expr: authentication_method
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deactivated Timestamp"
      expr: deactivated_timestamp
    - name: "Deactivation Reason"
      expr: deactivation_reason
    - name: "Email Address"
      expr: email_address
    - name: "Employee Code"
      expr: employee_code
    - name: "First Name"
      expr: first_name
    - name: "Full Name"
      expr: full_name
    - name: "Job Title"
      expr: job_title
    - name: "Language Preference"
      expr: language_preference
    - name: "Last Login Timestamp"
      expr: last_login_timestamp
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct User Account"
      expr: COUNT(DISTINCT user_account_id)
    - name: "Total Failed Login Attempts"
      expr: SUM(failed_login_attempts)
    - name: "Average Failed Login Attempts"
      expr: AVG(failed_login_attempts)
$$;