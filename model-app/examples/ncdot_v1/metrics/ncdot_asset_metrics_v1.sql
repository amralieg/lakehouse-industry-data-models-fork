-- Metric views for domain: asset | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`asset_asset_portfolio`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic asset portfolio metrics tracking total asset value, depreciation, replacement needs, and financial health of NCDOT's capital asset base. Used by CFO and asset management leadership for capital planning, budget forecasting, and GASB reporting."
  source: "`feip_eastus_03`.`asset`.`asset`"
  dimensions:
    - name: "asset_status"
      expr: status
      comment: "Current operational and lifecycle status of the asset (Active, In Service, Out of Service, Retired, Disposed)"
    - name: "asset_ownership_type"
      expr: ownership_type
      comment: "Type of ownership or control NCDOT has over the asset (Owned, Leased, Loaned, Donated)"
    - name: "responsible_organization"
      expr: responsible_organization
      comment: "Organizational unit or department within NCDOT responsible for managing and maintaining the asset"
    - name: "cost_center"
      expr: cost_center
      comment: "SAP cost center code to which asset-related expenses are charged for financial tracking and reporting"
    - name: "criticality_rating"
      expr: criticality_rating
      comment: "Business criticality classification indicating the importance of the asset to NCDOT operations and service delivery"
    - name: "fuel_type"
      expr: fuel_type
      comment: "Type of fuel or energy source used to power the asset (Gasoline, Diesel, Electric, Hybrid, CNG)"
    - name: "grant_program"
      expr: grant_program
      comment: "Name of the grant program that funded the asset acquisition (HSIP, CMAQ, BUILD, INFRA)"
    - name: "acquisition_year"
      expr: YEAR(acquisition_date)
      comment: "Year when the asset was acquired or purchased by NCDOT"
    - name: "in_service_year"
      expr: YEAR(in_service_date)
      comment: "Year when the asset was placed into active service and began depreciation"
    - name: "environmental_compliant"
      expr: environmental_compliance_flag
      comment: "Indicator of whether the asset meets current environmental compliance standards and regulations"
    - name: "ada_compliant"
      expr: ada_compliant_flag
      comment: "Indicator of whether the asset meets ADA accessibility requirements"
  measures:
    - name: "total_asset_count"
      expr: COUNT(1)
      comment: "Total number of assets in the portfolio"
    - name: "total_acquisition_cost"
      expr: SUM(CAST(acquisition_cost AS DOUBLE))
      comment: "Total original purchase price or acquisition cost of all assets in US dollars"
    - name: "total_accumulated_depreciation"
      expr: SUM(CAST(accumulated_depreciation AS DOUBLE))
      comment: "Total depreciation expense accumulated across all assets since placed in service, in US dollars"
    - name: "total_net_book_value"
      expr: SUM(CAST(net_book_value AS DOUBLE))
      comment: "Total current book value of all assets calculated as acquisition cost minus accumulated depreciation, in US dollars"
    - name: "total_replacement_cost"
      expr: SUM(CAST(replacement_cost AS DOUBLE))
      comment: "Total estimated current cost to replace all assets with similar new assets, in US dollars"
    - name: "avg_condition_rating"
      expr: AVG(CAST(condition_rating AS DOUBLE))
      comment: "Average numerical condition rating score across all assets, typically on a scale of 0-100"
    - name: "avg_risk_score"
      expr: AVG(CAST(risk_score AS DOUBLE))
      comment: "Average calculated risk score based on probability of failure and consequence of failure, used for prioritization"
    - name: "depreciation_rate_pct"
      expr: ROUND(100.0 * SUM(CAST(accumulated_depreciation AS DOUBLE)) / NULLIF(SUM(CAST(acquisition_cost AS DOUBLE)), 0), 2)
      comment: "Portfolio-wide depreciation rate as percentage of original acquisition cost, indicating asset aging and replacement needs"
    - name: "replacement_funding_gap"
      expr: SUM(CAST(replacement_cost AS DOUBLE)) - SUM(CAST(net_book_value AS DOUBLE))
      comment: "Total funding gap between replacement cost and current book value, indicating capital investment needs in US dollars"
    - name: "federal_participation_weighted_avg"
      expr: AVG(CAST(federal_participation_percent AS DOUBLE))
      comment: "Average percentage of asset cost funded by federal sources, used for grant compliance and reporting"
    - name: "unique_asset_types"
      expr: COUNT(DISTINCT type_id)
      comment: "Number of distinct asset types in the portfolio, indicating portfolio diversity"
    - name: "unique_locations"
      expr: COUNT(DISTINCT location_id)
      comment: "Number of distinct locations where assets are deployed, indicating geographic distribution"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`asset_asset_condition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset condition and maintenance readiness metrics tracking condition ratings, inspection compliance, and maintenance backlog. Used by maintenance managers and operations directors to prioritize maintenance spending and ensure regulatory compliance."
  source: "`feip_eastus_03`.`asset`.`asset`"
  filter: status IN ('Active', 'In Service')
  dimensions:
    - name: "asset_status"
      expr: status
      comment: "Current operational and lifecycle status of the asset"
    - name: "responsible_organization"
      expr: responsible_organization
      comment: "Organizational unit or department within NCDOT responsible for managing and maintaining the asset"
    - name: "criticality_rating"
      expr: criticality_rating
      comment: "Business criticality classification indicating the importance of the asset to NCDOT operations and service delivery"
    - name: "maintenance_plan"
      expr: maintenance_plan
      comment: "Identifier for the preventive maintenance plan or schedule assigned to the asset in SAP PM"
    - name: "safety_certification"
      expr: safety_certification
      comment: "Safety certification or compliance standard met by the asset (OSHA, FMCSA, MUTCD)"
    - name: "environmental_compliant"
      expr: environmental_compliance_flag
      comment: "Indicator of whether the asset meets current environmental compliance standards and regulations"
    - name: "inspection_overdue"
      expr: CASE WHEN next_inspection_date < CURRENT_DATE() THEN 'Overdue' WHEN next_inspection_date <= DATE_ADD(CURRENT_DATE(), 30) THEN 'Due Soon' ELSE 'Current' END
      comment: "Inspection status indicating whether asset inspection is overdue, due soon, or current"
    - name: "maintenance_overdue"
      expr: CASE WHEN next_maintenance_date < CURRENT_DATE() THEN 'Overdue' WHEN next_maintenance_date <= DATE_ADD(CURRENT_DATE(), 30) THEN 'Due Soon' ELSE 'Current' END
      comment: "Maintenance status indicating whether asset maintenance is overdue, due soon, or current"
  measures:
    - name: "active_asset_count"
      expr: COUNT(1)
      comment: "Total number of active assets requiring condition monitoring and maintenance"
    - name: "avg_condition_rating"
      expr: AVG(CAST(condition_rating AS DOUBLE))
      comment: "Average numerical condition rating score across active assets, typically on a scale of 0-100"
    - name: "poor_condition_asset_count"
      expr: SUM(CASE WHEN CAST(condition_rating AS DOUBLE) < 50 THEN 1 ELSE 0 END)
      comment: "Number of assets in poor condition (rating below 50) requiring immediate attention or replacement"
    - name: "poor_condition_asset_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(condition_rating AS DOUBLE) < 50 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets in poor condition, indicating portfolio health and replacement urgency"
    - name: "inspection_overdue_count"
      expr: SUM(CASE WHEN next_inspection_date < CURRENT_DATE() THEN 1 ELSE 0 END)
      comment: "Number of assets with overdue inspections, indicating regulatory compliance risk"
    - name: "inspection_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN next_inspection_date >= CURRENT_DATE() THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets with current inspections, measuring regulatory compliance performance"
    - name: "maintenance_overdue_count"
      expr: SUM(CASE WHEN next_maintenance_date < CURRENT_DATE() THEN 1 ELSE 0 END)
      comment: "Number of assets with overdue maintenance, indicating maintenance backlog and operational risk"
    - name: "maintenance_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN next_maintenance_date >= CURRENT_DATE() THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets with current maintenance, measuring maintenance program effectiveness"
    - name: "avg_days_since_last_inspection"
      expr: AVG(DATEDIFF(CURRENT_DATE(), last_inspection_date))
      comment: "Average number of days since last inspection across all active assets"
    - name: "avg_days_since_last_maintenance"
      expr: AVG(DATEDIFF(CURRENT_DATE(), last_maintenance_date))
      comment: "Average number of days since last maintenance across all active assets"
    - name: "high_risk_asset_count"
      expr: SUM(CASE WHEN CAST(risk_score AS DOUBLE) >= 7.0 THEN 1 ELSE 0 END)
      comment: "Number of assets with high risk scores (7.0 or above) requiring priority attention"
    - name: "high_risk_asset_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(risk_score AS DOUBLE) >= 7.0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets with high risk scores, indicating portfolio risk exposure"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`asset_asset_depreciation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Financial depreciation metrics tracking monthly depreciation expense, accumulated depreciation, and book value trends. Used by CFO, controllers, and financial analysts for GASB reporting, budget forecasting, and capital planning."
  source: "`feip_eastus_03`.`asset`.`depreciation`"
  dimensions:
    - name: "fiscal_year"
      expr: CONCAT('FY', CAST(YEAR(date) AS STRING))
      comment: "State fiscal year in which the depreciation was recorded"
    - name: "fiscal_period"
      expr: fiscal_period
      comment: "The fiscal period (month) within the fiscal year when depreciation is recorded, ranging from 1 to 12"
    - name: "depreciation_area"
      expr: area
      comment: "SAP depreciation area code indicating the accounting principle or valuation view (book depreciation, tax depreciation)"
    - name: "company_code"
      expr: company_code
      comment: "SAP company code representing the legal entity or organizational unit responsible for the asset"
    - name: "cost_center"
      expr: cost_center
      comment: "The cost center or organizational unit to which the depreciation expense is charged"
    - name: "division_code"
      expr: division_code
      comment: "The NCDOT division code indicating which organizational division owns or operates the asset (DOH, DMV)"
    - name: "county_code"
      expr: county_code
      comment: "The North Carolina county code where the asset is physically located, used for geographic reporting"
    - name: "depreciation_status"
      expr: status
      comment: "The current status of depreciation calculation for the asset indicating whether depreciation is actively being recorded"
    - name: "transaction_type"
      expr: transaction_type
      comment: "The type of depreciation transaction being recorded (planned, unplanned, special, catch-up, impairment)"
  measures:
    - name: "total_depreciation_entries"
      expr: COUNT(1)
      comment: "Total number of depreciation entries recorded in the period"
    - name: "total_period_depreciation"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total monetary value of depreciation expense recorded for all assets in the current period, in US dollars"
    - name: "total_accumulated_depreciation"
      expr: SUM(CAST(accumulated_depreciation AS DOUBLE))
      comment: "Total cumulative depreciation recorded for all assets from acquisition date through the current period, in US dollars"
    - name: "total_book_value"
      expr: SUM(CAST(book_value AS DOUBLE))
      comment: "Total current net book value of all assets calculated as original cost minus accumulated depreciation, in US dollars"
    - name: "total_original_cost"
      expr: SUM(CAST(original_cost AS DOUBLE))
      comment: "Total original acquisition or construction cost of all assets when first capitalized, in US dollars"
    - name: "avg_depreciation_per_asset"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average depreciation expense per asset in the current period, in US dollars"
    - name: "avg_remaining_life_years"
      expr: AVG(CAST(remaining_life_years AS DOUBLE))
      comment: "Average remaining useful life of assets in years as of the depreciation date"
    - name: "portfolio_depreciation_rate"
      expr: ROUND(100.0 * SUM(CAST(accumulated_depreciation AS DOUBLE)) / NULLIF(SUM(CAST(original_cost AS DOUBLE)), 0), 2)
      comment: "Portfolio-wide depreciation rate as percentage of original cost, indicating asset aging and replacement timing"
    - name: "book_value_to_replacement_ratio"
      expr: ROUND(SUM(CAST(book_value AS DOUBLE)) / NULLIF(SUM(CAST(replacement_cost AS DOUBLE)), 0), 4)
      comment: "Ratio of current book value to replacement cost, indicating capital reinvestment needs (values below 0.5 suggest high replacement urgency)"
    - name: "impaired_asset_count"
      expr: SUM(CASE WHEN impairment_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of assets identified as impaired under GASB 42 impairment standards"
    - name: "total_impairment_amount"
      expr: SUM(CAST(impairment_amount AS DOUBLE))
      comment: "Total monetary amount of asset impairment loss recognized, in US dollars"
    - name: "unique_assets_depreciated"
      expr: COUNT(DISTINCT asset_id)
      comment: "Number of distinct assets with depreciation entries in the period"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`asset_asset_disposal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset disposal and end-of-life metrics tracking disposal proceeds, gains/losses, and disposal method effectiveness. Used by asset managers, CFO, and procurement for surplus asset management, revenue optimization, and disposal policy evaluation."
  source: "`feip_eastus_03`.`asset`.`disposal`"
  dimensions:
    - name: "disposal_fiscal_year"
      expr: fiscal_year
      comment: "State fiscal year in which the disposal occurred"
    - name: "disposal_method"
      expr: method
      comment: "The method by which the asset was disposed (Auction, Sale, Trade-In, Scrap, Transfer, Donation, Demolition)"
    - name: "disposal_reason"
      expr: reason
      comment: "Business justification or reason for disposing of the asset (End of Useful Life, Obsolete, Damaged, Surplus, Upgrade)"
    - name: "disposal_status"
      expr: status
      comment: "Current status of the disposal transaction in the approval and execution workflow"
    - name: "disposal_type"
      expr: type
      comment: "Classification of the disposal event based on whether it was planned or unplanned"
    - name: "buyer_type"
      expr: buyer_type
      comment: "Classification of the buyer or recipient of the disposed asset (Private, Government, Non-Profit, Scrap Dealer)"
    - name: "responsible_division"
      expr: responsible_division
      comment: "NCDOT division or organizational unit responsible for the asset and its disposal (DOH, DMV, Ferry Division)"
    - name: "federal_funded"
      expr: federal_funding_flag
      comment: "Indicates whether the asset was originally acquired with federal funding, requiring compliance with federal disposal regulations"
    - name: "hazmat_present"
      expr: hazardous_material_flag
      comment: "Indicates whether the disposed asset contained or was contaminated with hazardous materials"
    - name: "disposal_year"
      expr: YEAR(date)
      comment: "Calendar year when the asset disposal transaction was completed"
  measures:
    - name: "total_disposals"
      expr: COUNT(1)
      comment: "Total number of asset disposal transactions completed in the period"
    - name: "total_disposal_proceeds"
      expr: SUM(CAST(disposition_proceeds_amount AS DOUBLE))
      comment: "Total monetary proceeds received from the disposal of all assets, in US dollars"
    - name: "total_disposal_cost"
      expr: SUM(CAST(cost AS DOUBLE))
      comment: "Total direct costs incurred to dispose of assets, including transportation, demolition, environmental remediation, and administrative fees, in US dollars"
    - name: "net_disposal_proceeds"
      expr: SUM(CAST(disposition_proceeds_amount AS DOUBLE)) - SUM(CAST(cost AS DOUBLE))
      comment: "Net proceeds from disposals after deducting disposal costs, in US dollars"
    - name: "total_gain_loss"
      expr: SUM(CAST(gain_loss_amount AS DOUBLE))
      comment: "Total calculated gain or loss on disposal of assets, computed as proceeds minus net book value, in US dollars"
    - name: "avg_disposal_proceeds"
      expr: AVG(CAST(disposition_proceeds_amount AS DOUBLE))
      comment: "Average monetary proceeds received per disposed asset, in US dollars"
    - name: "avg_asset_age_at_disposal"
      expr: AVG(CAST(age_at_disposal_years AS DOUBLE))
      comment: "Average age of assets in years at the time of disposal, indicating asset lifecycle effectiveness"
    - name: "disposal_recovery_rate"
      expr: ROUND(100.0 * SUM(CAST(disposition_proceeds_amount AS DOUBLE)) / NULLIF(SUM(CAST(net_book_value AS DOUBLE)), 0), 2)
      comment: "Percentage of net book value recovered through disposal proceeds, measuring disposal effectiveness (higher is better)"
    - name: "profitable_disposal_count"
      expr: SUM(CASE WHEN CAST(gain_loss_amount AS DOUBLE) > 0 THEN 1 ELSE 0 END)
      comment: "Number of disposals that resulted in a gain (proceeds exceeded book value)"
    - name: "profitable_disposal_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(gain_loss_amount AS DOUBLE) > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of disposals that resulted in a gain, indicating disposal timing and pricing effectiveness"
    - name: "total_federal_reimbursement"
      expr: SUM(CAST(federal_reimbursement_amount AS DOUBLE))
      comment: "Total amount of disposal proceeds that must be returned to federal funding agencies per grant requirements, in US dollars"
    - name: "hazmat_disposal_count"
      expr: SUM(CASE WHEN hazardous_material_flag = true THEN 1 ELSE 0 END)
      comment: "Number of disposals involving hazardous materials, indicating environmental compliance workload"
    - name: "unique_disposed_asset_types"
      expr: COUNT(DISTINCT type_id)
      comment: "Number of distinct asset types disposed in the period, indicating disposal portfolio diversity"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`asset_inspection_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset inspection program performance metrics tracking inspection completion rates, defect identification, critical findings, and inspector productivity. Used by maintenance managers, safety officers, and compliance directors to ensure regulatory compliance and asset safety."
  source: "`feip_eastus_03`.`asset`.`inspection`"
  dimensions:
    - name: "inspection_fiscal_year"
      expr: state_fiscal_year
      comment: "The North Carolina state fiscal year in which the inspection was performed, used for state budgeting and reporting"
    - name: "inspection_type"
      expr: type
      comment: "The category or type of inspection performed, indicating the purpose and scope of the inspection activity"
    - name: "inspection_status"
      expr: status
      comment: "The current status of the inspection event in its lifecycle from scheduling through completion and approval"
    - name: "inspection_method"
      expr: method
      comment: "The methodology or technique used to conduct the inspection (visual, instrumented, remote sensing)"
    - name: "inspection_program"
      expr: program
      comment: "The name or identifier of the inspection program or initiative under which this inspection was conducted (NBIS, HSIP, Pavement Management)"
    - name: "critical_findings_present"
      expr: critical_findings_flag
      comment: "Indicates whether any critical safety or structural issues were identified that require immediate attention"
    - name: "compliance_status"
      expr: compliance_status
      comment: "Indicates whether the asset meets applicable regulatory, safety, or design standards based on inspection findings"
    - name: "corrective_action_priority"
      expr: corrective_action_priority
      comment: "The priority level assigned to the recommended corrective actions based on severity and risk"
    - name: "funding_source"
      expr: funding_source
      comment: "The primary funding source that paid for the inspection activity"
  measures:
    - name: "total_inspections"
      expr: COUNT(1)
      comment: "Total number of asset inspections completed in the period"
    - name: "total_inspection_cost"
      expr: SUM(CAST(cost AS DOUBLE))
      comment: "Total cost incurred to perform all inspections, including labor, equipment, and materials, in US dollars"
    - name: "avg_inspection_cost"
      expr: AVG(CAST(cost AS DOUBLE))
      comment: "Average cost per inspection, in US dollars"
    - name: "avg_inspection_duration_hours"
      expr: AVG(CAST(duration_hours AS DOUBLE))
      comment: "Average number of hours spent conducting inspections from start to completion"
    - name: "total_inspection_hours"
      expr: SUM(CAST(duration_hours AS DOUBLE))
      comment: "Total number of hours spent conducting all inspections in the period"
    - name: "avg_condition_score"
      expr: AVG(CAST(condition_score AS DOUBLE))
      comment: "Average numeric score representing the overall condition of inspected assets, typically on a standardized scale"
    - name: "critical_findings_count"
      expr: SUM(CASE WHEN critical_findings_flag = true THEN 1 ELSE 0 END)
      comment: "Number of inspections that identified critical safety or structural issues requiring immediate attention"
    - name: "critical_findings_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN critical_findings_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections that identified critical findings, indicating asset risk exposure and safety concerns"
    - name: "total_defects_identified"
      expr: SUM(CAST(defect_count AS DOUBLE))
      comment: "Total number of distinct defects or issues identified across all inspections"
    - name: "avg_defects_per_inspection"
      expr: AVG(CAST(defect_count AS DOUBLE))
      comment: "Average number of defects identified per inspection, indicating asset condition trends"
    - name: "total_estimated_repair_cost"
      expr: SUM(CAST(estimated_repair_cost AS DOUBLE))
      comment: "Total estimated cost to complete all recommended corrective actions or repairs identified through inspections, in US dollars"
    - name: "compliance_pass_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_status IN ('Compliant', 'Pass') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections where assets met applicable regulatory, safety, or design standards"
    - name: "avg_photos_per_inspection"
      expr: AVG(CAST(photos_taken_count AS DOUBLE))
      comment: "Average number of photographs taken per inspection to document asset condition and defects"
    - name: "unique_inspectors"
      expr: COUNT(DISTINCT inspector_employee_id)
      comment: "Number of distinct inspectors who performed inspections in the period"
    - name: "unique_assets_inspected"
      expr: COUNT(DISTINCT asset_id)
      comment: "Number of distinct assets inspected in the period"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`asset_procurement_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset procurement performance metrics tracking procurement cycle time, cost efficiency, vendor performance, and budget utilization. Used by procurement managers, CFO, and division directors for vendor management, budget control, and procurement process improvement."
  source: "`feip_eastus_03`.`asset`.`procurement`"
  dimensions:
    - name: "procurement_fiscal_year"
      expr: state_fiscal_year
      comment: "North Carolina state fiscal year in which the procurement was executed or funded"
    - name: "procurement_method"
      expr: method
      comment: "Method used to procure the asset (Competitive Bid, RFP, RFQ, IFB, Sole Source, Emergency)"
    - name: "procurement_status"
      expr: status
      comment: "Current status of the procurement transaction in the acquisition lifecycle"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary source of funding for the asset procurement (State, Federal, Grant, STIP)"
    - name: "federal_funding_program"
      expr: federal_funding_program
      comment: "Specific federal funding program if federal funds were used (FHWA, FTA, BUILD, INFRA, RAISE, TIFIA)"
    - name: "vendor_type"
      expr: vendor_type
      comment: "Classification of the vendor relationship type (Prime, Subcontractor, Distributor, Manufacturer)"
    - name: "vendor_dbe_status"
      expr: vendor_dbe_status
      comment: "Vendor certification status as DBE, MBE, WBE, or HUB"
    - name: "cost_center"
      expr: cost_center
      comment: "Organizational cost center responsible for the asset and its procurement costs"
    - name: "emergency_procurement"
      expr: emergency_procurement_indicator
      comment: "Indicates whether this was an emergency procurement requiring expedited processing"
    - name: "inspection_required"
      expr: inspection_required_indicator
      comment: "Indicates whether the asset requires formal inspection or acceptance testing upon receipt"
    - name: "capitalization_threshold_met"
      expr: capitalization_threshold_met_indicator
      comment: "Indicates whether the asset cost meets the minimum threshold for capitalization as a fixed asset"
  measures:
    - name: "total_procurements"
      expr: COUNT(1)
      comment: "Total number of asset procurement transactions completed in the period"
    - name: "total_procurement_value"
      expr: SUM(CAST(total_acquisition_cost AS DOUBLE))
      comment: "Total capitalized cost including purchase price, tax, shipping, installation, and all costs necessary to place assets in service, in US dollars"
    - name: "total_asset_quantity"
      expr: SUM(CAST(quantity AS DOUBLE))
      comment: "Total number of asset units or items procured across all transactions"
    - name: "avg_procurement_value"
      expr: AVG(CAST(total_acquisition_cost AS DOUBLE))
      comment: "Average total acquisition cost per procurement transaction, in US dollars"
    - name: "avg_unit_price"
      expr: AVG(CAST(unit_price AS DOUBLE))
      comment: "Average price per unit across all procured assets, in US dollars"
    - name: "avg_procurement_cycle_days"
      expr: AVG(DATEDIFF(receipt_date, requisition_date))
      comment: "Average number of days from requisition to receipt, measuring procurement process efficiency"
    - name: "avg_delivery_delay_days"
      expr: AVG(DATEDIFF(delivery_date, expected_delivery_date))
      comment: "Average number of days between expected and actual delivery, measuring vendor delivery performance (negative values indicate early delivery)"
    - name: "on_time_delivery_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN delivery_date <= expected_delivery_date THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of procurements delivered on or before expected delivery date, measuring vendor reliability"
    - name: "total_shipping_cost"
      expr: SUM(CAST(shipping_cost AS DOUBLE))
      comment: "Total freight and shipping charges for delivering all assets, in US dollars"
    - name: "shipping_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(shipping_cost AS DOUBLE)) / NULLIF(SUM(CAST(total_cost AS DOUBLE)), 0), 2)
      comment: "Shipping cost as percentage of total procurement cost, indicating logistics efficiency"
    - name: "warranty_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN warranty_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of procurements that include manufacturer or vendor warranty coverage"
    - name: "avg_warranty_duration_months"
      expr: AVG(CAST(warranty_duration_months AS DOUBLE))
      comment: "Average duration of warranty coverage in months across all procurements with warranties"
    - name: "inspection_pass_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN inspection_status IN ('Passed', 'Accepted') THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN inspection_required_indicator = true THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of required inspections that passed, measuring procurement quality and vendor performance"
    - name: "emergency_procurement_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN emergency_procurement_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of procurements that were emergency procurements, indicating planning effectiveness"
    - name: "dbe_participation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN vendor_dbe_status IN ('DBE', 'MBE', 'WBE', 'HUB') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of procurements awarded to DBE/MBE/WBE/HUB vendors, measuring diversity program compliance"
    - name: "unique_vendors"
      expr: COUNT(DISTINCT vendor_id)
      comment: "Number of distinct vendors used for asset procurement in the period"
    - name: "unique_assets_procured"
      expr: COUNT(DISTINCT asset_id)
      comment: "Number of distinct assets procured in the period"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`asset_maintenance_schedule_compliance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Preventive maintenance schedule compliance metrics tracking schedule adherence, overdue maintenance, and maintenance program effectiveness. Used by maintenance managers and operations directors to optimize maintenance planning, reduce downtime, and extend asset life."
  source: "`feip_eastus_03`.`asset`.`maintenance_schedule`"
  dimensions:
    - name: "schedule_type"
      expr: schedule_type
      comment: "Classification of the maintenance schedule based on the triggering methodology (preventive, predictive, condition-based, time-based, usage-based, seasonal, regulatory, inspection)"
    - name: "schedule_status"
      expr: schedule_status
      comment: "Current operational status of the maintenance schedule (Active, Inactive, Suspended, Expired)"
    - name: "priority"
      expr: priority
      comment: "Priority level assigned to the maintenance schedule indicating urgency and importance (Critical, High, Medium, Low)"
    - name: "responsible_crew"
      expr: responsible_crew_name
      comment: "Name of the maintenance crew or team assigned to perform the scheduled maintenance"
    - name: "work_center"
      expr: work_center_name
      comment: "Name of the work center or maintenance facility assigned to the schedule"
    - name: "planning_plant"
      expr: planning_plant
      comment: "Plant or facility code where the maintenance planning and execution is managed"
    - name: "safety_critical"
      expr: safety_critical_flag
      comment: "Indicates whether the maintenance schedule is related to safety-critical components or systems"
    - name: "regulatory_required"
      expr: regulatory_required_flag
      comment: "Indicates whether the maintenance is mandated by regulatory requirements or compliance standards"
    - name: "season"
      expr: season
      comment: "Seasonal designation for maintenance activities that are season-specific (Winter, Spring, Summer, Fall)"
    - name: "schedule_overdue"
      expr: CASE WHEN next_scheduled_date < CURRENT_DATE() THEN 'Overdue' WHEN next_scheduled_date <= DATE_ADD(CURRENT_DATE(), 30) THEN 'Due Soon' ELSE 'Current' END
      comment: "Schedule status indicating whether maintenance is overdue, due soon, or current"
  measures:
    - name: "total_maintenance_schedules"
      expr: COUNT(1)
      comment: "Total number of active maintenance schedules in the program"
    - name: "total_estimated_cost"
      expr: SUM(CAST(estimated_cost AS DOUBLE))
      comment: "Total estimated cost for completing all scheduled maintenance including labor, materials, and equipment, in US dollars"
    - name: "total_estimated_labor_hours"
      expr: SUM(CAST(estimated_labor_hours AS DOUBLE))
      comment: "Total estimated labor hours required to complete all maintenance tasks"
    - name: "avg_estimated_cost"
      expr: AVG(CAST(estimated_cost AS DOUBLE))
      comment: "Average estimated cost per scheduled maintenance activity, in US dollars"
    - name: "avg_estimated_duration_hours"
      expr: AVG(CAST(estimated_duration_hours AS DOUBLE))
      comment: "Average estimated time in hours required to complete scheduled maintenance activities"
    - name: "overdue_schedule_count"
      expr: SUM(CASE WHEN next_scheduled_date < CURRENT_DATE() THEN 1 ELSE 0 END)
      comment: "Number of maintenance schedules that are overdue, indicating maintenance backlog"
    - name: "schedule_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN next_scheduled_date >= CURRENT_DATE() THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of maintenance schedules that are current (not overdue), measuring maintenance program effectiveness"
    - name: "avg_days_overdue"
      expr: AVG(CASE WHEN next_scheduled_date < CURRENT_DATE() THEN DATEDIFF(CURRENT_DATE(), next_scheduled_date) ELSE 0 END)
      comment: "Average number of days that overdue maintenance schedules are past due"
    - name: "safety_critical_schedule_count"
      expr: SUM(CASE WHEN safety_critical_flag = true THEN 1 ELSE 0 END)
      comment: "Number of maintenance schedules related to safety-critical components or systems"
    - name: "safety_critical_overdue_count"
      expr: SUM(CASE WHEN safety_critical_flag = true AND next_scheduled_date < CURRENT_DATE() THEN 1 ELSE 0 END)
      comment: "Number of safety-critical maintenance schedules that are overdue, indicating high-priority safety risk"
    - name: "regulatory_schedule_count"
      expr: SUM(CASE WHEN regulatory_required_flag = true THEN 1 ELSE 0 END)
      comment: "Number of maintenance schedules mandated by regulatory requirements or compliance standards"
    - name: "regulatory_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN regulatory_required_flag = true AND next_scheduled_date >= CURRENT_DATE() THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN regulatory_required_flag = true THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of regulatory-required maintenance schedules that are current, measuring regulatory compliance"
    - name: "avg_frequency_days"
      expr: AVG(CASE WHEN frequency_unit = 'days' THEN CAST(frequency_value AS DOUBLE) WHEN frequency_unit = 'weeks' THEN CAST(frequency_value AS DOUBLE) * 7 WHEN frequency_unit = 'months' THEN CAST(frequency_value AS DOUBLE) * 30 WHEN frequency_unit = 'years' THEN CAST(frequency_value AS DOUBLE) * 365 ELSE NULL END)
      comment: "Average maintenance frequency in days across all schedules, indicating maintenance intensity"
    - name: "unique_assets_scheduled"
      expr: COUNT(DISTINCT asset_id)
      comment: "Number of distinct assets with active maintenance schedules"
    - name: "unique_work_centers"
      expr: COUNT(DISTINCT work_center_id)
      comment: "Number of distinct work centers or maintenance facilities managing scheduled maintenance"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`asset_warranty_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Warranty coverage and claims management metrics tracking warranty status, coverage value, and warranty utilization. Used by asset managers, procurement, and finance to maximize warranty value, ensure compliance with warranty terms, and optimize warranty purchasing decisions."
  source: "`feip_eastus_03`.`asset`.`warranty`"
  dimensions:
    - name: "warranty_type"
      expr: type
      comment: "Classification of the warranty coverage type (Manufacturer, Extended, Service Contract, Maintenance Agreement)"
    - name: "warranty_status"
      expr: status
      comment: "Current lifecycle status of the warranty (Active, Expired, Cancelled, Suspended, Pending Activation, Claimed)"
    - name: "provider_name"
      expr: provider_name
      comment: "Name of the organization or entity providing the warranty coverage (manufacturer, dealer, third-party warranty company)"
    - name: "responsible_division"
      expr: responsible_division
      comment: "NCDOT division responsible for managing and administering the warranty (DOH, DMV, Ferry Division)"
    - name: "parts_covered"
      expr: parts_covered_flag
      comment: "Indicates whether replacement parts are covered under the warranty"
    - name: "labor_covered"
      expr: labor_covered_flag
      comment: "Indicates whether labor costs for repairs are covered under the warranty"
    - name: "transferable"
      expr: transferable_flag
      comment: "Indicates whether the warranty can be transferred to a new owner if the asset is sold or reassigned"
    - name: "maintenance_required"
      expr: maintenance_required_flag
      comment: "Indicates whether regular maintenance is required to keep the warranty valid and enforceable"
    - name: "compliance_status"
      expr: compliance_flag
      comment: "Indicates whether the warranty is in compliance with all terms, conditions, and maintenance requirements"
    - name: "warranty_expiring_soon"
      expr: CASE WHEN end_date < CURRENT_DATE() THEN 'Expired' WHEN end_date <= DATE_ADD(CURRENT_DATE(), 90) THEN 'Expiring Soon' ELSE 'Active' END
      comment: "Warranty expiration status indicating whether warranty is expired, expiring soon, or active"
  measures:
    - name: "total_warranties"
      expr: COUNT(1)
      comment: "Total number of warranty records in the system"
    - name: "active_warranty_count"
      expr: SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END)
      comment: "Number of warranties currently active and providing coverage"
    - name: "total_warranty_cost"
      expr: SUM(CAST(cost_amount AS DOUBLE))
      comment: "Total cost paid for all warranty coverage, including purchase price or premium for extended warranties and service contracts, in US dollars"
    - name: "total_coverage_limit"
      expr: SUM(CAST(coverage_limit_amount AS DOUBLE))
      comment: "Total maximum dollar amount that all warranties will pay for covered repairs or replacements during warranty periods, in US dollars"
    - name: "avg_warranty_cost"
      expr: AVG(CAST(cost_amount AS DOUBLE))
      comment: "Average cost paid per warranty, in US dollars"
    - name: "avg_warranty_duration_months"
      expr: AVG(CAST(duration_months AS DOUBLE))
      comment: "Average total duration of warranty coverage in months from start date to end date"
    - name: "avg_coverage_limit"
      expr: AVG(CAST(coverage_limit_amount AS DOUBLE))
      comment: "Average maximum dollar amount per warranty for covered repairs or replacements, in US dollars"
    - name: "warranty_coverage_ratio"
      expr: ROUND(SUM(CAST(coverage_limit_amount AS DOUBLE)) / NULLIF(SUM(CAST(cost_amount AS DOUBLE)), 0), 2)
      comment: "Ratio of total coverage limit to total warranty cost, indicating warranty value (higher is better)"
    - name: "expiring_soon_count"
      expr: SUM(CASE WHEN end_date BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), 90) THEN 1 ELSE 0 END)
      comment: "Number of warranties expiring within the next 90 days, requiring renewal decisions"
    - name: "expired_warranty_count"
      expr: SUM(CASE WHEN end_date < CURRENT_DATE() THEN 1 ELSE 0 END)
      comment: "Number of warranties that have expired and no longer provide coverage"
    - name: "non_compliant_warranty_count"
      expr: SUM(CASE WHEN compliance_flag = false THEN 1 ELSE 0 END)
      comment: "Number of warranties not in compliance with terms, conditions, or maintenance requirements, at risk of voiding"
    - name: "compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of warranties in compliance with all terms and conditions, measuring warranty management effectiveness"
    - name: "full_coverage_warranty_count"
      expr: SUM(CASE WHEN parts_covered_flag = true AND labor_covered_flag = true THEN 1 ELSE 0 END)
      comment: "Number of warranties that cover both parts and labor, indicating comprehensive coverage"
    - name: "full_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN parts_covered_flag = true AND labor_covered_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of warranties providing full parts and labor coverage, measuring coverage quality"
    - name: "unique_warranty_providers"
      expr: COUNT(DISTINCT provider_name)
      comment: "Number of distinct warranty providers, indicating vendor diversity"
    - name: "unique_asset_types_covered"
      expr: COUNT(DISTINCT type_id)
      comment: "Number of distinct asset types with warranty coverage"
$$;