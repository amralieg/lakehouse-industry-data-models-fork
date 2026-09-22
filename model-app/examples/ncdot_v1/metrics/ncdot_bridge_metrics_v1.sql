-- Metric views for domain: bridge | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`bridge_bridge_inventory`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic bridge asset inventory metrics tracking structural condition, deficiency status, and load capacity across the NCDOT bridge network. Used by executive leadership for capital planning, federal compliance reporting, and infrastructure investment prioritization."
  source: "`feip_eastus_03`.`bridge`.`bridge`"
  dimensions:
    - name: "county_name"
      expr: county_name
      comment: "County where the bridge is located, enabling geographic analysis of bridge conditions and investment needs by region."
    - name: "functional_class_description"
      expr: functional_class_description
      comment: "Functional classification of the route carried by the bridge (Interstate, Principal Arterial, Minor Collector), critical for prioritizing bridges by traffic importance."
    - name: "ownership_description"
      expr: ownership_description
      comment: "Entity that owns the bridge structure, enabling analysis of state vs. local vs. federal bridge portfolios."
    - name: "structure_type_main_description"
      expr: structure_type_main_description
      comment: "Main span structure type and material (Steel Girder, Prestressed Concrete, Concrete Arch), used for lifecycle cost analysis and material-specific deterioration patterns."
    - name: "year_built_decade"
      expr: CONCAT(CAST(FLOOR(CAST(year_built AS INT) / 10) * 10 AS STRING), 's')
      comment: "Decade when the bridge was built, enabling age-based analysis of infrastructure replacement needs and deterioration trends."
    - name: "structurally_deficient_flag"
      expr: structurally_deficient_flag
      comment: "Boolean indicator whether the bridge is classified as structurally deficient, critical for federal reporting and safety prioritization."
    - name: "functionally_obsolete_flag"
      expr: functionally_obsolete_flag
      comment: "Boolean indicator whether the bridge is functionally obsolete, used to identify bridges requiring geometric or capacity improvements."
    - name: "fracture_critical_flag"
      expr: fracture_critical_flag
      comment: "Boolean indicator whether the bridge contains fracture critical members, requiring specialized inspection resources and risk management."
    - name: "scour_critical_flag"
      expr: scour_critical_flag
      comment: "Boolean indicator whether the bridge is scour critical, identifying bridges at risk of foundation failure requiring monitoring and countermeasures."
    - name: "deck_condition_rating"
      expr: deck_condition_rating
      comment: "FHWA condition rating for bridge deck (0-9 scale), used to segment bridges by deck condition for maintenance planning."
    - name: "superstructure_condition_rating"
      expr: superstructure_condition_rating
      comment: "FHWA condition rating for bridge superstructure (0-9 scale), used to segment bridges by superstructure condition for rehabilitation planning."
    - name: "substructure_condition_rating"
      expr: substructure_condition_rating
      comment: "FHWA condition rating for bridge substructure (0-9 scale), used to segment bridges by foundation condition for structural intervention planning."
    - name: "posting_status_code"
      expr: posting_status_code
      comment: "Weight restriction posting status, identifying bridges with load limitations that impact freight mobility and economic activity."
  measures:
    - name: "total_bridge_count"
      expr: COUNT(1)
      comment: "Total number of bridges in the NCDOT inventory, baseline metric for infrastructure portfolio size and federal reporting."
    - name: "structurally_deficient_count"
      expr: SUM(CASE WHEN structurally_deficient_flag = true THEN 1 ELSE 0 END)
      comment: "Count of structurally deficient bridges, critical KPI for federal MAP-21 performance measures and safety investment prioritization."
    - name: "structurally_deficient_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN structurally_deficient_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of bridges classified as structurally deficient, key federal performance measure tracked by FHWA and used for state DOT performance evaluation."
    - name: "functionally_obsolete_count"
      expr: SUM(CASE WHEN functionally_obsolete_flag = true THEN 1 ELSE 0 END)
      comment: "Count of functionally obsolete bridges, indicating bridges requiring geometric or capacity improvements to meet current standards."
    - name: "functionally_obsolete_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN functionally_obsolete_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of bridges classified as functionally obsolete, strategic metric for modernization investment planning and capacity expansion needs."
    - name: "fracture_critical_count"
      expr: SUM(CASE WHEN fracture_critical_flag = true THEN 1 ELSE 0 END)
      comment: "Count of fracture critical bridges requiring specialized inspection, used for inspection resource planning and risk management budgeting."
    - name: "scour_critical_count"
      expr: SUM(CASE WHEN scour_critical_flag = true THEN 1 ELSE 0 END)
      comment: "Count of scour critical bridges at risk of foundation failure, critical for emergency preparedness and hydraulic countermeasure investment."
    - name: "total_deck_area_sq_ft"
      expr: SUM(CAST(deck_area_sq_ft AS DOUBLE))
      comment: "Total bridge deck area in square feet across the portfolio, used for maintenance cost estimation, material quantity planning, and asset valuation."
    - name: "avg_sufficiency_rating"
      expr: AVG(CAST(sufficiency_rating AS DOUBLE))
      comment: "Average bridge sufficiency rating (0-100 scale), composite metric indicating overall bridge adequacy for continued service and federal funding eligibility."
    - name: "total_improvement_cost"
      expr: SUM(CAST(improvement_cost AS DOUBLE))
      comment: "Total estimated cost for recommended bridge improvements across the portfolio, critical for capital planning, budget requests, and long-range financial forecasting."
    - name: "avg_bridge_age_years"
      expr: AVG(CAST(YEAR(CURRENT_DATE()) - CAST(year_built AS INT) AS DOUBLE))
      comment: "Average age of bridges in years, strategic metric for understanding infrastructure lifecycle stage and replacement wave timing."
    - name: "posted_bridge_count"
      expr: COUNT(DISTINCT CASE WHEN posting_status_code IS NOT NULL AND posting_status_code != '' THEN bridge_id END)
      comment: "Count of bridges with weight restrictions posted, indicating load capacity constraints that impact freight mobility and economic competitiveness."
    - name: "avg_operating_rating_tons"
      expr: AVG(CAST(operating_rating_tons AS DOUBLE))
      comment: "Average operating load rating in tons across bridges, indicating typical load capacity for routine traffic and freight planning."
    - name: "poor_condition_bridge_count"
      expr: SUM(CASE WHEN CAST(deck_condition_rating AS INT) <= 4 OR CAST(superstructure_condition_rating AS INT) <= 4 OR CAST(substructure_condition_rating AS INT) <= 4 THEN 1 ELSE 0 END)
      comment: "Count of bridges in poor condition (rating 4 or below on any major component), federal performance measure for infrastructure condition and safety risk."
    - name: "poor_condition_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(deck_condition_rating AS INT) <= 4 OR CAST(superstructure_condition_rating AS INT) <= 4 OR CAST(substructure_condition_rating AS INT) <= 4 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of bridges in poor condition, key federal MAP-21 performance measure tracked by FHWA for state DOT accountability and funding allocation."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`bridge_bridge_inspection`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Bridge inspection performance and compliance metrics tracking inspection timeliness, defect identification rates, and recommended action prioritization. Used by bridge management leadership for regulatory compliance, quality assurance, and resource allocation decisions."
  source: "`feip_eastus_03`.`bridge`.`inspection_record`"
  dimensions:
    - name: "inspection_type"
      expr: inspection_type
      comment: "Type of inspection performed (routine, fracture-critical, underwater, special, damage), enabling analysis of inspection program composition and resource allocation."
    - name: "inspection_year"
      expr: YEAR(inspection_date)
      comment: "Year when the inspection was performed, enabling trend analysis of inspection activity and compliance over time."
    - name: "inspection_quarter"
      expr: CONCAT('Q', CAST(QUARTER(inspection_date) AS STRING), ' ', CAST(YEAR(inspection_date) AS STRING))
      comment: "Quarter when the inspection was performed, used for quarterly performance reporting and resource utilization tracking."
    - name: "inspection_organization"
      expr: inspection_organization
      comment: "Organization or contractor that performed the inspection, enabling performance comparison between internal staff and external contractors."
    - name: "recommended_action"
      expr: recommended_action
      comment: "Primary recommended action based on inspection findings (monitor, repair, rehabilitate, replace, close), used to prioritize maintenance and capital investments."
    - name: "recommended_action_priority"
      expr: recommended_action_priority
      comment: "Priority level for recommended action (low, medium, high, critical), critical for resource allocation and emergency response planning."
    - name: "defect_severity"
      expr: defect_severity
      comment: "Severity classification of primary defect (minor, moderate, severe, critical), used to assess inspection findings and prioritize interventions."
    - name: "safety_concern_indicator"
      expr: safety_concern_indicator
      comment: "Boolean indicator whether immediate safety concerns were identified, critical for emergency response and public safety risk management."
    - name: "inspection_compliance_status"
      expr: inspection_compliance_status
      comment: "Compliance status relative to regulatory requirements (compliant, overdue, early), used to track NBIS compliance and avoid federal penalties."
    - name: "qa_review_status"
      expr: qa_review_status
      comment: "Quality assurance review status (approved, approved with comments, rejected, pending), used to monitor inspection quality and training needs."
    - name: "corrosion_severity"
      expr: corrosion_severity
      comment: "Severity of observed corrosion (none, light, moderate, severe, critical), used to track deterioration patterns and protective coating effectiveness."
    - name: "scour_critical_indicator"
      expr: scour_critical_indicator
      comment: "Scour criticality indicator (Y, N, U, T), identifying bridges at risk of foundation failure requiring monitoring and countermeasures."
  measures:
    - name: "total_inspection_count"
      expr: COUNT(1)
      comment: "Total number of bridge inspections performed, baseline metric for inspection program activity and resource utilization."
    - name: "safety_concern_inspection_count"
      expr: SUM(CASE WHEN safety_concern_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of inspections identifying immediate safety concerns, critical KPI for public safety risk management and emergency response effectiveness."
    - name: "safety_concern_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN safety_concern_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections identifying safety concerns, key performance indicator for bridge condition trends and proactive maintenance effectiveness."
    - name: "overdue_inspection_count"
      expr: SUM(CASE WHEN inspection_compliance_status = 'overdue' THEN 1 ELSE 0 END)
      comment: "Count of overdue inspections, critical compliance metric for NBIS regulatory adherence and federal funding eligibility."
    - name: "overdue_inspection_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN inspection_compliance_status = 'overdue' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections that were overdue, key compliance metric tracked by FHWA for state DOT performance evaluation and potential penalties."
    - name: "critical_priority_action_count"
      expr: SUM(CASE WHEN recommended_action_priority = 'critical' THEN 1 ELSE 0 END)
      comment: "Count of inspections recommending critical priority actions, used for emergency response planning and immediate resource allocation."
    - name: "closure_recommended_count"
      expr: SUM(CASE WHEN closure_recommended_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of inspections recommending bridge closure, critical metric for public safety risk management and emergency traffic management planning."
    - name: "load_restriction_recommended_count"
      expr: SUM(CASE WHEN load_restriction_recommended_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of inspections recommending load restrictions, indicating structural capacity concerns that impact freight mobility and economic activity."
    - name: "total_estimated_repair_cost"
      expr: SUM(CAST(estimated_repair_cost AS DOUBLE))
      comment: "Total estimated cost for recommended repairs across all inspections, critical for maintenance budget planning and capital investment prioritization."
    - name: "avg_estimated_repair_cost"
      expr: AVG(CAST(estimated_repair_cost AS DOUBLE))
      comment: "Average estimated repair cost per inspection, used to benchmark repair complexity and budget adequacy for maintenance programs."
    - name: "avg_inspection_duration_hours"
      expr: AVG(CAST(inspection_duration_hours AS DOUBLE))
      comment: "Average inspection duration in hours, used for resource planning, productivity analysis, and inspection cost estimation."
    - name: "corrosion_observed_count"
      expr: SUM(CASE WHEN corrosion_observed_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of inspections observing corrosion, indicating deterioration trends and protective coating program effectiveness."
    - name: "corrosion_detection_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN corrosion_observed_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections detecting corrosion, strategic metric for evaluating protective coating investments and material selection decisions."
    - name: "qa_rejection_count"
      expr: SUM(CASE WHEN qa_review_status = 'rejected' THEN 1 ELSE 0 END)
      comment: "Count of inspections rejected during quality assurance review, indicating inspection quality issues and training needs."
    - name: "qa_rejection_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN qa_review_status = 'rejected' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections rejected during QA review, key quality metric for inspector training effectiveness and program quality control."
    - name: "avg_deck_condition_rating"
      expr: AVG(CAST(deck_condition_rating AS DOUBLE))
      comment: "Average deck condition rating across inspections, strategic metric for tracking deck deterioration trends and deck preservation program effectiveness."
    - name: "avg_superstructure_condition_rating"
      expr: AVG(CAST(superstructure_condition_rating AS DOUBLE))
      comment: "Average superstructure condition rating across inspections, used to evaluate structural deterioration trends and rehabilitation program effectiveness."
    - name: "avg_substructure_condition_rating"
      expr: AVG(CAST(substructure_condition_rating AS DOUBLE))
      comment: "Average substructure condition rating across inspections, used to assess foundation condition trends and scour countermeasure effectiveness."
    - name: "underwater_inspection_count"
      expr: SUM(CASE WHEN underwater_inspection_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of underwater inspections performed, used for specialized inspection resource planning and diving contractor budget allocation."
    - name: "fracture_critical_inspection_count"
      expr: SUM(CASE WHEN fracture_critical_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of fracture critical member inspections, used for specialized inspection resource planning and high-risk bridge monitoring."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`bridge_bridge_cost_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Bridge project cost item performance metrics tracking expenditure patterns, federal funding eligibility, and cost category distribution. Used by finance and project management leadership for budget variance analysis, federal reimbursement optimization, and cost control decisions."
  source: "`feip_eastus_03`.`bridge`.`cost_item`"
  dimensions:
    - name: "category"
      expr: category
      comment: "High-level cost category (materials, labor, equipment, indirect), enabling cost structure analysis and budget allocation decisions."
    - name: "subcategory"
      expr: subcategory
      comment: "Secondary cost classification within primary category, providing granular cost tracking for detailed budget variance analysis."
    - name: "project_phase"
      expr: project_phase
      comment: "Project phase where cost item is applied (Preliminary Engineering, Right-of-Way, Construction), used for phase-based budget tracking and cash flow planning."
    - name: "federal_eligible_flag"
      expr: federal_eligible_flag
      comment: "Boolean indicator whether cost item is eligible for federal reimbursement, critical for maximizing federal funding and minimizing state match requirements."
    - name: "status"
      expr: status
      comment: "Lifecycle status of cost item code (active, inactive, deprecated), used to track cost code evolution and ensure budget compliance."
    - name: "material_type"
      expr: material_type
      comment: "Specific material type for material cost items, enabling material-specific cost analysis and procurement strategy optimization."
    - name: "labor_classification"
      expr: labor_classification
      comment: "Labor classification (skilled, semi-skilled, professional), used for workforce planning and prevailing wage compliance analysis."
    - name: "equipment_type"
      expr: equipment_type
      comment: "Equipment or machinery type for equipment cost items, used for equipment utilization analysis and rental vs. purchase decisions."
    - name: "prevailing_wage_flag"
      expr: prevailing_wage_flag
      comment: "Boolean indicator whether cost item is subject to Davis-Bacon prevailing wage requirements, critical for federal project labor cost estimation."
    - name: "capitalization_flag"
      expr: capitalization_flag
      comment: "Boolean indicator whether cost item should be capitalized as asset value, used for financial reporting and asset valuation decisions."
    - name: "bms_category_code"
      expr: bms_category_code
      comment: "Bridge Management System category code for lifecycle cost analysis, enabling long-term cost forecasting and asset management optimization."
  measures:
    - name: "total_cost_item_count"
      expr: COUNT(1)
      comment: "Total number of cost item codes in the reference system, baseline metric for cost tracking granularity and budget classification complexity."
    - name: "active_cost_item_count"
      expr: SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END)
      comment: "Count of active cost item codes available for use, used to track cost code portfolio size and budget classification options."
    - name: "federal_eligible_cost_item_count"
      expr: SUM(CASE WHEN federal_eligible_flag = true THEN 1 ELSE 0 END)
      comment: "Count of cost items eligible for federal reimbursement, strategic metric for maximizing federal funding opportunities and minimizing state match."
    - name: "federal_eligible_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN federal_eligible_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of cost items eligible for federal reimbursement, used to assess federal funding optimization potential and reimbursement strategy effectiveness."
    - name: "avg_unit_price"
      expr: AVG(CAST(unit_price AS DOUBLE))
      comment: "Average unit price across cost items, used for cost benchmarking, inflation tracking, and budget estimation accuracy assessment."
    - name: "avg_federal_participation_rate_pct"
      expr: AVG(CAST(federal_participation_rate AS DOUBLE))
      comment: "Average federal participation rate across eligible cost items, strategic metric for federal funding leverage and state match optimization."
    - name: "prevailing_wage_cost_item_count"
      expr: SUM(CASE WHEN prevailing_wage_flag = true THEN 1 ELSE 0 END)
      comment: "Count of cost items subject to prevailing wage requirements, used for labor cost estimation and Davis-Bacon compliance planning."
    - name: "capitalizable_cost_item_count"
      expr: SUM(CASE WHEN capitalization_flag = true THEN 1 ELSE 0 END)
      comment: "Count of cost items that should be capitalized as asset value, used for financial reporting and asset valuation accuracy."
    - name: "avg_useful_life_years"
      expr: AVG(CAST(useful_life_years AS DOUBLE))
      comment: "Average useful life in years for capitalizable cost items, used for depreciation planning and lifecycle cost analysis."
    - name: "avg_escalation_rate_pct"
      expr: AVG(CAST(escalation_rate AS DOUBLE))
      comment: "Average annual escalation rate for cost items, critical for multi-year project budgeting and long-range financial forecasting."
    - name: "avg_lead_time_days"
      expr: AVG(CAST(lead_time_days AS DOUBLE))
      comment: "Average lead time in days for materials and equipment, used for project scheduling, procurement planning, and supply chain risk management."
    - name: "approval_required_cost_item_count"
      expr: SUM(CASE WHEN approval_required_flag = true THEN 1 ELSE 0 END)
      comment: "Count of cost items requiring special approval, indicating high-value or high-risk items requiring enhanced budget controls."
    - name: "nbis_eligible_cost_item_count"
      expr: SUM(CASE WHEN nbis_eligible_flag = true THEN 1 ELSE 0 END)
      comment: "Count of cost items applicable to NBIS-compliant bridge inspections, used for inspection program budgeting and federal compliance cost tracking."
    - name: "stip_eligible_cost_item_count"
      expr: SUM(CASE WHEN stip_eligible_flag = true THEN 1 ELSE 0 END)
      comment: "Count of cost items eligible for State Transportation Improvement Program budgets, used for STIP project planning and funding allocation."
$$;