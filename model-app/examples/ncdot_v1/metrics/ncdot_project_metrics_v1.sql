-- Metric views for domain: project | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_project_portfolio`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic portfolio metrics for transportation project delivery performance, funding utilization, and schedule adherence. Used by executive leadership for STIP/TIP oversight and resource allocation decisions."
  source: "`feip_eastus_03`.`project`.`project`"
  dimensions:
    - name: "project_type"
      expr: type
      comment: "Classification of project by transportation mode or functional category"
    - name: "project_status"
      expr: status
      comment: "Current lifecycle status of the project"
    - name: "project_priority"
      expr: priority
      comment: "Priority level for resource allocation decisions"
    - name: "sponsor_division"
      expr: sponsor_division
      comment: "NCDOT division sponsoring the project"
    - name: "highway_division"
      expr: highway_division_number
      comment: "NCDOT regional division number (1-14)"
    - name: "county"
      expr: county
      comment: "Primary North Carolina county location"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source (federal, state, local, private, mixed)"
    - name: "federal_funding_program"
      expr: federal_funding_program
      comment: "Specific federal funding program (NHS, STP, HSIP, etc.)"
    - name: "nepa_class"
      expr: nepa_class
      comment: "NEPA environmental review classification"
    - name: "delivery_method"
      expr: delivery_method
      comment: "Contracting method for project delivery"
    - name: "mpo_name"
      expr: mpo_name
      comment: "Metropolitan Planning Organization jurisdiction"
    - name: "functional_class"
      expr: functional_class
      comment: "FHWA functional classification of roadway"
    - name: "fiscal_year_programmed"
      expr: CAST(ffy_programmed AS STRING)
      comment: "Federal fiscal year programmed in STIP"
    - name: "is_safety_project"
      expr: safety_project_indicator
      comment: "Whether project is designated as HSIP safety improvement"
    - name: "is_nhs"
      expr: nhs_indicator
      comment: "Whether project is on National Highway System"
    - name: "is_emergency"
      expr: emergency_project_indicator
      comment: "Whether project is emergency disaster recovery"
  measures:
    - name: "Total Projects"
      expr: COUNT(1)
      comment: "Total number of transportation projects in portfolio"
    - name: "Total Estimated Cost"
      expr: SUM(CAST(estimated_total_cost AS DOUBLE))
      comment: "Total estimated cost across all projects in US dollars - key portfolio investment metric"
    - name: "Total Federal Funds"
      expr: SUM(CAST(federal_funds_amount AS DOUBLE))
      comment: "Total federal funding allocated across projects"
    - name: "Total State Funds"
      expr: SUM(CAST(state_funds_amount AS DOUBLE))
      comment: "Total state funding allocated across projects"
    - name: "Total Local Funds"
      expr: SUM(CAST(local_funds_amount AS DOUBLE))
      comment: "Total local government funding across projects"
    - name: "Federal Funding Ratio"
      expr: ROUND(100.0 * SUM(CAST(federal_funds_amount AS DOUBLE)) / NULLIF(SUM(CAST(estimated_total_cost AS DOUBLE)), 0), 2)
      comment: "Percentage of total project costs funded by federal sources - critical for federal aid compliance"
    - name: "Avg Project Cost"
      expr: AVG(CAST(estimated_total_cost AS DOUBLE))
      comment: "Average estimated cost per project - portfolio sizing metric"
    - name: "Total Project Miles"
      expr: SUM(CAST(length_miles AS DOUBLE))
      comment: "Total linear miles of roadway projects in portfolio"
    - name: "Avg Project Length Miles"
      expr: AVG(CAST(length_miles AS DOUBLE))
      comment: "Average project corridor length in miles"
    - name: "Total Bridges"
      expr: SUM(CAST(bridge_count AS DOUBLE))
      comment: "Total number of bridges across all projects"
    - name: "Total Signals"
      expr: SUM(CAST(signal_count AS DOUBLE))
      comment: "Total number of traffic signals across all projects"
    - name: "DBE Goal Achievement Rate"
      expr: ROUND(100.0 * AVG(CAST(dbe_actual_percentage AS DOUBLE)) / NULLIF(AVG(CAST(dbe_goal_percentage AS DOUBLE)), 0), 2)
      comment: "Percentage achievement of DBE participation goals - federal compliance and equity metric"
    - name: "Avg DBE Participation Pct"
      expr: AVG(CAST(dbe_actual_percentage AS DOUBLE))
      comment: "Average actual DBE participation percentage across projects"
    - name: "Bid Competition Rate"
      expr: AVG(CAST(number_of_bidders AS DOUBLE))
      comment: "Average number of bidders per project - market health indicator"
    - name: "Bid to Estimate Ratio"
      expr: ROUND(100.0 * SUM(CAST(bid_amount AS DOUBLE)) / NULLIF(SUM(CAST(engineer_estimate AS DOUBLE)), 0), 2)
      comment: "Ratio of actual bid amounts to engineer estimates - cost estimation accuracy metric"
    - name: "Contract Award Amount"
      expr: SUM(CAST(contract_amount AS DOUBLE))
      comment: "Total contract award amounts across projects"
    - name: "Wetland Impact Acres"
      expr: SUM(CAST(wetland_impact_acres AS DOUBLE))
      comment: "Total wetland acreage impacted requiring mitigation - environmental impact metric"
    - name: "Stream Impact Linear Feet"
      expr: SUM(CAST(stream_impact_linear_feet AS DOUBLE))
      comment: "Total linear feet of stream impacts requiring mitigation"
    - name: "Unique Projects"
      expr: COUNT(DISTINCT project_id)
      comment: "Distinct count of projects for deduplication"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_project_schedule_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project schedule performance and delivery timeline metrics. Used by program managers and executives to monitor on-time delivery, identify delays, and assess project execution efficiency."
  source: "`feip_eastus_03`.`project`.`project`"
  filter: construction_start_date IS NOT NULL
  dimensions:
    - name: "project_type"
      expr: type
      comment: "Classification of project by transportation mode"
    - name: "project_status"
      expr: status
      comment: "Current lifecycle status"
    - name: "sponsor_division"
      expr: sponsor_division
      comment: "NCDOT division sponsoring the project"
    - name: "county"
      expr: county
      comment: "Primary county location"
    - name: "delivery_method"
      expr: delivery_method
      comment: "Contracting method for project delivery"
    - name: "construction_year"
      expr: YEAR(construction_start_date)
      comment: "Year construction commenced"
    - name: "letting_year"
      expr: YEAR(letting_date)
      comment: "Year project was let for bidding"
  measures:
    - name: "Total Projects Under Construction"
      expr: COUNT(1)
      comment: "Number of projects with active construction"
    - name: "Avg Planning Duration Days"
      expr: AVG(DATEDIFF(planning_completion_date, planning_start_date))
      comment: "Average duration of planning phase in days"
    - name: "Avg PE Duration Days"
      expr: AVG(DATEDIFF(pe_completion_date, pe_start_date))
      comment: "Average duration of preliminary engineering phase in days"
    - name: "Avg Environmental Review Days"
      expr: AVG(DATEDIFF(environmental_completion_date, environmental_start_date))
      comment: "Average duration of environmental review and NEPA compliance in days - regulatory timeline metric"
    - name: "Avg ROW Acquisition Days"
      expr: AVG(DATEDIFF(row_completion_date, row_start_date))
      comment: "Average duration of right-of-way acquisition in days - critical path metric"
    - name: "Avg Design Duration Days"
      expr: AVG(DATEDIFF(design_completion_date, design_start_date))
      comment: "Average duration of final design phase in days"
    - name: "Avg Letting to Award Days"
      expr: AVG(DATEDIFF(award_date, letting_date))
      comment: "Average time from bid letting to contract award - procurement efficiency metric"
    - name: "Avg Award to NTP Days"
      expr: AVG(DATEDIFF(ntp_date, award_date))
      comment: "Average time from contract award to notice to proceed - mobilization timeline"
    - name: "Avg Construction Duration Days"
      expr: AVG(DATEDIFF(actual_completion_date, construction_start_date))
      comment: "Average actual construction duration in days - delivery performance metric"
    - name: "Schedule Variance Days"
      expr: AVG(DATEDIFF(actual_completion_date, scheduled_completion_date))
      comment: "Average schedule variance in days (positive = delay, negative = early) - on-time delivery KPI"
    - name: "On-Time Completion Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN actual_completion_date <= scheduled_completion_date THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of projects completed on or before scheduled date - executive delivery performance metric"
    - name: "Avg Total Project Duration Days"
      expr: AVG(DATEDIFF(actual_completion_date, planning_start_date))
      comment: "Average total project lifecycle duration from planning to completion"
    - name: "Projects Completed"
      expr: SUM(CASE WHEN actual_completion_date IS NOT NULL THEN 1 ELSE 0 END)
      comment: "Count of projects with recorded completion dates"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_project_budget`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project budget allocation, expenditure, and financial performance metrics. Used by finance leadership and program managers for budget oversight, variance analysis, and funding utilization decisions."
  source: "`feip_eastus_03`.`project`.`project_budget`"
  dimensions:
    - name: "budget_type"
      expr: type
      comment: "Classification of budget record (original, revision, supplemental, final)"
    - name: "budget_status"
      expr: status
      comment: "Current lifecycle status of budget allocation"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year for budget allocation"
    - name: "funding_source_code"
      expr: funding_source_code
      comment: "Specific funding program code (HSIP, CMAQ, STP, etc.)"
    - name: "funding_category"
      expr: funding_category
      comment: "High-level funding source classification"
    - name: "cost_category"
      expr: cost_category_name
      comment: "Cost category for budget allocation (PE, ROW, CE, Construction)"
    - name: "phase_code"
      expr: phase_code
      comment: "Project delivery phase code"
    - name: "program_area"
      expr: program_area
      comment: "NCDOT program area or modal category"
    - name: "division"
      expr: division_name
      comment: "NCDOT highway division responsible for execution"
    - name: "county"
      expr: county_name
      comment: "Primary county location"
    - name: "mpo_name"
      expr: mpo_name
      comment: "Metropolitan Planning Organization jurisdiction"
    - name: "is_multi_year"
      expr: is_multi_year
      comment: "Whether budget spans multiple fiscal years"
    - name: "is_reimbursable"
      expr: is_reimbursable
      comment: "Whether budget is subject to federal reimbursement"
  measures:
    - name: "Total Budget Records"
      expr: COUNT(1)
      comment: "Total number of budget allocation records"
    - name: "Total Budget Amount"
      expr: SUM(CAST(total_budget_amount AS DOUBLE))
      comment: "Total approved budget across all allocations - portfolio funding level"
    - name: "Total Federal Amount"
      expr: SUM(CAST(federal_amount AS DOUBLE))
      comment: "Total federal funding allocated"
    - name: "Total State Amount"
      expr: SUM(CAST(state_amount AS DOUBLE))
      comment: "Total state funding allocated"
    - name: "Total Local Amount"
      expr: SUM(CAST(local_amount AS DOUBLE))
      comment: "Total local government funding allocated"
    - name: "Federal Share Percentage"
      expr: ROUND(100.0 * SUM(CAST(federal_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of budget from federal sources - federal aid participation metric"
    - name: "State Share Percentage"
      expr: ROUND(100.0 * SUM(CAST(state_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of budget from state sources - state match metric"
    - name: "Total Obligation Amount"
      expr: SUM(CAST(obligation_amount AS DOUBLE))
      comment: "Total budget obligated through contracts and commitments"
    - name: "Total Expenditure Amount"
      expr: SUM(CAST(expenditure_amount AS DOUBLE))
      comment: "Total actual expenditures to date"
    - name: "Total Available Amount"
      expr: SUM(CAST(available_amount AS DOUBLE))
      comment: "Total remaining budget available for new obligations"
    - name: "Budget Utilization Rate"
      expr: ROUND(100.0 * SUM(CAST(expenditure_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of budget expended - financial execution performance metric"
    - name: "Obligation Rate"
      expr: ROUND(100.0 * SUM(CAST(obligation_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of budget obligated - commitment level metric"
    - name: "Avg Budget Per Record"
      expr: AVG(CAST(total_budget_amount AS DOUBLE))
      comment: "Average budget allocation per record"
    - name: "Total Contingency Amount"
      expr: SUM(CAST(contingency_amount AS DOUBLE))
      comment: "Total contingency reserves across budgets - risk mitigation funding"
    - name: "Contingency Reserve Rate"
      expr: ROUND(100.0 * SUM(CAST(contingency_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_budget_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of budget held as contingency - risk management metric"
    - name: "Unique Projects Budgeted"
      expr: COUNT(DISTINCT project_id)
      comment: "Distinct count of projects with budget allocations"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_project_funding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project funding allocation, commitment, and expenditure metrics. Used by finance and grants management for funding source tracking, drawdown monitoring, and federal aid compliance."
  source: "`feip_eastus_03`.`project`.`funding`"
  dimensions:
    - name: "source_type"
      expr: source_type
      comment: "Primary funding source category (federal, state, local, grant, bond, private)"
    - name: "source_name"
      expr: source_name
      comment: "Specific funding source name (FHWA, FTA, BUILD, INFRA, RAISE)"
    - name: "program_code"
      expr: program_code
      comment: "Standardized funding program code (HSIP, CMAQ, STP, NHS)"
    - name: "program_name"
      expr: program_name
      comment: "Full funding program name"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year of allocation"
    - name: "phase_code"
      expr: phase_code
      comment: "Project phase funded (PE, ROW, CE, CN)"
    - name: "funding_status"
      expr: status
      comment: "Current lifecycle status of funding allocation"
    - name: "category"
      expr: category
      comment: "Expenditure category (capital, operating, planning, maintenance, emergency)"
    - name: "nepa_class"
      expr: nepa_class
      comment: "NEPA classification required for funding"
    - name: "is_reimbursable"
      expr: reimbursable_flag
      comment: "Whether funding is reimbursement-based"
    - name: "is_flexible"
      expr: flexible_funding_flag
      comment: "Whether funding can be used across transportation modes"
    - name: "is_garvee"
      expr: garvee_flag
      comment: "Whether funding involves GARVEE bonds"
    - name: "is_tifia"
      expr: tifia_flag
      comment: "Whether funding involves TIFIA loan"
  measures:
    - name: "Total Funding Records"
      expr: COUNT(1)
      comment: "Total number of funding allocation records"
    - name: "Total Allocation Amount"
      expr: SUM(CAST(allocation_amount AS DOUBLE))
      comment: "Total dollar amount allocated from funding sources"
    - name: "Total Committed Amount"
      expr: SUM(CAST(committed_amount AS DOUBLE))
      comment: "Total dollar amount formally committed or obligated"
    - name: "Total Expended Amount"
      expr: SUM(CAST(expended_amount AS DOUBLE))
      comment: "Total dollar amount actually spent or disbursed to date"
    - name: "Total Remaining Amount"
      expr: SUM(CAST(remaining_amount AS DOUBLE))
      comment: "Total dollar amount remaining available from allocations"
    - name: "Funding Commitment Rate"
      expr: ROUND(100.0 * SUM(CAST(committed_amount AS DOUBLE)) / NULLIF(SUM(CAST(allocation_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of allocated funds formally committed - obligation performance metric"
    - name: "Funding Expenditure Rate"
      expr: ROUND(100.0 * SUM(CAST(expended_amount AS DOUBLE)) / NULLIF(SUM(CAST(allocation_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of allocated funds actually expended - drawdown performance metric"
    - name: "Funding Utilization Rate"
      expr: ROUND(100.0 * SUM(CAST(expended_amount AS DOUBLE)) / NULLIF(SUM(CAST(committed_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of committed funds expended - execution efficiency metric"
    - name: "Avg Federal Share Pct"
      expr: AVG(CAST(federal_share_percentage AS DOUBLE))
      comment: "Average federal funding participation percentage"
    - name: "Avg State Share Pct"
      expr: AVG(CAST(state_share_percentage AS DOUBLE))
      comment: "Average state funding match percentage"
    - name: "Avg Local Share Pct"
      expr: AVG(CAST(local_share_percentage AS DOUBLE))
      comment: "Average local funding participation percentage"
    - name: "Total Toll Credits Amount"
      expr: SUM(CAST(toll_credits_amount AS DOUBLE))
      comment: "Total dollar value of toll credits used as non-federal match"
    - name: "Avg DBE Goal Pct"
      expr: AVG(CAST(dbe_goal_percentage AS DOUBLE))
      comment: "Average DBE participation goal percentage for funded projects"
    - name: "Unique Projects Funded"
      expr: COUNT(DISTINCT project_id)
      comment: "Distinct count of projects receiving funding allocations"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_change_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project change order impact and approval metrics. Used by project managers and executives to monitor scope changes, cost impacts, schedule delays, and change order approval efficiency."
  source: "`feip_eastus_03`.`project`.`change_order`"
  dimensions:
    - name: "change_order_type"
      expr: type
      comment: "Classification of change order by primary nature of change"
    - name: "change_order_status"
      expr: status
      comment: "Current lifecycle status in approval workflow"
    - name: "priority"
      expr: priority
      comment: "Business priority level for processing"
    - name: "reason_code"
      expr: reason_code
      comment: "Standardized root cause or reason code"
    - name: "approval_level"
      expr: approval_level
      comment: "Organizational authority level required for approval"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source covering change order cost"
    - name: "initiated_year"
      expr: YEAR(initiated_date)
      comment: "Year change order was initiated"
    - name: "is_federal_participation"
      expr: federal_participation_flag
      comment: "Whether federal funds participate in change order cost"
    - name: "is_stip_amendment_required"
      expr: stip_amendment_required_flag
      comment: "Whether change requires STIP amendment"
    - name: "is_emergency"
      expr: emergency_flag
      comment: "Whether change order processed under emergency provisions"
    - name: "is_value_engineering"
      expr: value_engineering_flag
      comment: "Whether change resulted from value engineering proposal"
  measures:
    - name: "Total Change Orders"
      expr: COUNT(1)
      comment: "Total number of change orders issued"
    - name: "Total Change Cost Impact"
      expr: SUM(CAST(change_cost_amount AS DOUBLE))
      comment: "Total incremental cost impact from all change orders - portfolio cost growth metric"
    - name: "Avg Change Cost Impact"
      expr: AVG(CAST(change_cost_amount AS DOUBLE))
      comment: "Average cost impact per change order"
    - name: "Total Original Cost"
      expr: SUM(CAST(original_cost_amount AS DOUBLE))
      comment: "Total baseline project costs before change orders"
    - name: "Total Revised Cost"
      expr: SUM(CAST(revised_cost_amount AS DOUBLE))
      comment: "Total project costs after change orders applied"
    - name: "Cost Growth Rate"
      expr: ROUND(100.0 * SUM(CAST(change_cost_amount AS DOUBLE)) / NULLIF(SUM(CAST(original_cost_amount AS DOUBLE)), 0), 2)
      comment: "Percentage cost growth from change orders - project cost control metric"
    - name: "Total Schedule Impact Days"
      expr: SUM(CAST(change_duration_days AS DOUBLE))
      comment: "Total schedule impact in calendar days from all change orders"
    - name: "Avg Schedule Impact Days"
      expr: AVG(CAST(change_duration_days AS DOUBLE))
      comment: "Average schedule impact per change order in days"
    - name: "Schedule Growth Rate"
      expr: ROUND(100.0 * SUM(CAST(change_duration_days AS DOUBLE)) / NULLIF(SUM(CAST(original_duration_days AS DOUBLE)), 0), 2)
      comment: "Percentage schedule growth from change orders - project schedule control metric"
    - name: "Avg Approval Cycle Days"
      expr: AVG(DATEDIFF(approved_date, submitted_date))
      comment: "Average days from submission to approval - change order processing efficiency metric"
    - name: "Avg Execution Cycle Days"
      expr: AVG(DATEDIFF(executed_date, approved_date))
      comment: "Average days from approval to execution - mobilization efficiency"
    - name: "Change Order Approval Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of change orders approved - approval success rate"
    - name: "Unique Projects with Changes"
      expr: COUNT(DISTINCT project_id)
      comment: "Distinct count of projects with change orders"
    - name: "Avg Change Orders Per Project"
      expr: ROUND(CAST(COUNT(1) AS DOUBLE) / NULLIF(COUNT(DISTINCT project_id), 0), 2)
      comment: "Average number of change orders per project - project stability metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_project_issue`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project issue tracking and resolution performance metrics. Used by project managers and quality assurance teams to monitor issue severity, resolution time, and cost impacts."
  source: "`feip_eastus_03`.`project`.`issue`"
  dimensions:
    - name: "issue_type"
      expr: type
      comment: "Classification by primary nature (technical, schedule, budget, safety, environmental)"
    - name: "severity"
      expr: severity
      comment: "Severity level indicating impact and urgency"
    - name: "priority"
      expr: priority
      comment: "Priority ranking for resolution sequencing"
    - name: "issue_status"
      expr: status
      comment: "Current lifecycle status in resolution workflow"
    - name: "project_phase"
      expr: project_phase
      comment: "Project lifecycle phase when issue identified"
    - name: "county"
      expr: county
      comment: "County where issue is located"
    - name: "division"
      expr: division
      comment: "NCDOT division responsible for geographic area"
    - name: "escalation_level"
      expr: escalation_level
      comment: "Management tier involved in issue resolution"
    - name: "reported_year"
      expr: YEAR(reported_date)
      comment: "Year issue was reported"
    - name: "is_contractor_responsibility"
      expr: contractor_responsibility_flag
      comment: "Whether issue attributed to contractor"
    - name: "is_environmental_impact"
      expr: environmental_impact_flag
      comment: "Whether issue has environmental implications"
  measures:
    - name: "Total Issues"
      expr: COUNT(1)
      comment: "Total number of project issues reported"
    - name: "Total Cost Impact"
      expr: SUM(CAST(cost_impact_amount AS DOUBLE))
      comment: "Total financial cost impact from all issues - issue cost burden metric"
    - name: "Avg Cost Impact"
      expr: AVG(CAST(cost_impact_amount AS DOUBLE))
      comment: "Average financial impact per issue"
    - name: "Total Schedule Delay Days"
      expr: SUM(CAST(schedule_delay_days AS DOUBLE))
      comment: "Total calendar days of schedule delay from all issues"
    - name: "Avg Schedule Delay Days"
      expr: AVG(CAST(schedule_delay_days AS DOUBLE))
      comment: "Average schedule delay per issue in days"
    - name: "Avg Resolution Time Days"
      expr: AVG(DATEDIFF(actual_resolution_date, reported_date))
      comment: "Average days from issue report to resolution - issue resolution efficiency metric"
    - name: "Avg Closure Time Days"
      expr: AVG(DATEDIFF(closure_date, reported_date))
      comment: "Average days from issue report to formal closure"
    - name: "Issue Resolution Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN actual_resolution_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of issues with recorded resolution - resolution completion metric"
    - name: "Issue Closure Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN closure_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of issues formally closed"
    - name: "Escalation Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN escalation_level IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of issues requiring escalation - issue severity indicator"
    - name: "Recurrence Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN recurrence_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of issues that are recurrences - process improvement metric"
    - name: "Unique Projects with Issues"
      expr: COUNT(DISTINCT project_id)
      comment: "Distinct count of projects with reported issues"
    - name: "Avg Issues Per Project"
      expr: ROUND(CAST(COUNT(1) AS DOUBLE) / NULLIF(COUNT(DISTINCT project_id), 0), 2)
      comment: "Average number of issues per project - project quality metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_project_risk`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project risk exposure and mitigation effectiveness metrics. Used by risk managers and project leadership to monitor risk levels, mitigation costs, and risk materialization rates."
  source: "`feip_eastus_03`.`project`.`risk`"
  dimensions:
    - name: "risk_category"
      expr: category
      comment: "Risk classification by domain (technical, schedule, cost, environmental, regulatory, safety)"
    - name: "risk_rating"
      expr: rating
      comment: "Qualitative risk rating for prioritization (low, medium, high, critical)"
    - name: "risk_status"
      expr: status
      comment: "Current lifecycle status (identified, assessed, active, mitigated, closed)"
    - name: "response_strategy"
      expr: response_strategy
      comment: "Planned risk response strategy (avoid, mitigate, transfer, accept)"
    - name: "project_phase"
      expr: project_phase
      comment: "Project lifecycle phase when risk identified"
    - name: "division"
      expr: division
      comment: "NCDOT division responsible for project"
    - name: "county"
      expr: county
      comment: "County where project and risk are located"
    - name: "identified_year"
      expr: YEAR(identified_date)
      comment: "Year risk was identified"
    - name: "is_occurred"
      expr: occurred_flag
      comment: "Whether risk event has actually occurred"
    - name: "is_environmental_permit_risk"
      expr: environmental_permit_risk_flag
      comment: "Whether risk relates to environmental permitting"
    - name: "is_row_acquisition_risk"
      expr: row_acquisition_risk_flag
      comment: "Whether risk relates to right-of-way acquisition"
  measures:
    - name: "Total Risks"
      expr: COUNT(1)
      comment: "Total number of identified project risks"
    - name: "Avg Risk Score"
      expr: AVG(CAST(score AS DOUBLE))
      comment: "Average risk score (probability × impact) - portfolio risk exposure metric"
    - name: "Avg Residual Risk Score"
      expr: AVG(CAST(residual_risk_score AS DOUBLE))
      comment: "Average risk score after mitigation - risk reduction effectiveness"
    - name: "Risk Reduction Rate"
      expr: ROUND(100.0 * (AVG(CAST(score AS DOUBLE)) - AVG(CAST(residual_risk_score AS DOUBLE))) / NULLIF(AVG(CAST(score AS DOUBLE)), 0), 2)
      comment: "Percentage reduction in risk score from mitigation - mitigation effectiveness metric"
    - name: "Total Potential Cost Impact"
      expr: SUM(CAST(cost_impact_amount AS DOUBLE))
      comment: "Total potential financial impact if all risks materialize"
    - name: "Total Actual Cost Impact"
      expr: SUM(CAST(actual_cost_impact AS DOUBLE))
      comment: "Total actual financial impact from materialized risks"
    - name: "Total Mitigation Cost"
      expr: SUM(CAST(mitigation_cost AS DOUBLE))
      comment: "Total cost of implementing risk mitigation actions"
    - name: "Mitigation ROI"
      expr: ROUND(100.0 * (SUM(CAST(cost_impact_amount AS DOUBLE)) - SUM(CAST(actual_cost_impact AS DOUBLE))) / NULLIF(SUM(CAST(mitigation_cost AS DOUBLE)), 0), 2)
      comment: "Return on investment for risk mitigation spending - mitigation value metric"
    - name: "Risk Materialization Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN occurred_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of risks that actually occurred - risk forecasting accuracy metric"
    - name: "Risk Closure Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN closure_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of risks formally closed"
    - name: "Avg Mitigation Cycle Days"
      expr: AVG(DATEDIFF(mitigation_actual_date, mitigation_start_date))
      comment: "Average days to complete mitigation actions - mitigation execution speed"
    - name: "Unique Projects with Risks"
      expr: COUNT(DISTINCT project_id)
      comment: "Distinct count of projects with identified risks"
    - name: "Avg Risks Per Project"
      expr: ROUND(CAST(COUNT(1) AS DOUBLE) / NULLIF(COUNT(DISTINCT project_id), 0), 2)
      comment: "Average number of risks per project - project risk profile metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_schedule_activity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project schedule activity performance and critical path metrics. Used by project schedulers and managers to monitor activity completion, schedule variance, and critical path adherence."
  source: "`feip_eastus_03`.`project`.`schedule`"
  dimensions:
    - name: "phase_code"
      expr: phase_code
      comment: "Project phase code (PE, CE, ROW, DESIGN, CONSTRUCTION, CLOSEOUT)"
    - name: "activity_status"
      expr: status
      comment: "Current status (NOT_STARTED, IN_PROGRESS, COMPLETED, ON_HOLD, CANCELLED, DELAYED)"
    - name: "is_milestone"
      expr: milestone_flag
      comment: "Whether activity represents a project milestone"
    - name: "is_critical_path"
      expr: critical_path_flag
      comment: "Whether activity is on project critical path"
    - name: "constraint_type"
      expr: constraint_type
      comment: "Type of scheduling constraint applied"
    - name: "risk_level"
      expr: risk_level
      comment: "Risk level associated with activity (LOW, MEDIUM, HIGH, CRITICAL)"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source for work package"
    - name: "responsible_organization"
      expr: responsible_organization
      comment: "NCDOT division or external organization responsible"
    - name: "is_weather_dependent"
      expr: weather_dependent_flag
      comment: "Whether activity is weather-dependent"
    - name: "is_permit_required"
      expr: permit_required_flag
      comment: "Whether regulatory permits required before activity"
  measures:
    - name: "Total Schedule Activities"
      expr: COUNT(1)
      comment: "Total number of schedule activities"
    - name: "Avg Duration Days"
      expr: AVG(CAST(duration_days AS DOUBLE))
      comment: "Average planned duration per activity in calendar days"
    - name: "Avg Actual Duration Days"
      expr: AVG(CAST(actual_duration_days AS DOUBLE))
      comment: "Average actual duration for completed activities"
    - name: "Avg Remaining Duration Days"
      expr: AVG(CAST(remaining_duration_days AS DOUBLE))
      comment: "Average remaining duration for in-progress activities"
    - name: "Avg Percent Complete"
      expr: AVG(CAST(percent_complete AS DOUBLE))
      comment: "Average completion percentage across activities"
    - name: "Avg Total Float Days"
      expr: AVG(CAST(total_float_days AS DOUBLE))
      comment: "Average total float (slack) available without delaying project - schedule flexibility metric"
    - name: "Avg Schedule Variance Days"
      expr: AVG(CAST(variance_days AS DOUBLE))
      comment: "Average schedule variance in days (positive = ahead, negative = behind) - schedule performance metric"
    - name: "Total Budgeted Cost"
      expr: SUM(CAST(budgeted_cost AS DOUBLE))
      comment: "Total budgeted cost across all activities"
    - name: "Total Actual Cost"
      expr: SUM(CAST(actual_cost AS DOUBLE))
      comment: "Total actual cost incurred to date"
    - name: "Total Cost Variance"
      expr: SUM(CAST(cost_variance AS DOUBLE))
      comment: "Total cost variance (budgeted minus actual) - cost performance metric"
    - name: "Cost Performance Index"
      expr: ROUND(SUM(CAST(budgeted_cost AS DOUBLE)) / NULLIF(SUM(CAST(actual_cost AS DOUBLE)), 0), 2)
      comment: "Ratio of budgeted to actual cost - earned value cost efficiency metric"
    - name: "Schedule Performance Index"
      expr: ROUND(AVG(CAST(percent_complete AS DOUBLE)) / NULLIF(AVG(CAST(duration_days AS DOUBLE)) / NULLIF(AVG(CAST(actual_duration_days AS DOUBLE)), 0), 0), 2)
      comment: "Schedule efficiency ratio - earned value schedule performance metric"
    - name: "On-Time Activity Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN variance_days >= 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of activities on or ahead of schedule"
    - name: "Critical Path Activity Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN critical_path_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of activities on critical path - schedule risk concentration"
    - name: "Unique Projects Scheduled"
      expr: COUNT(DISTINCT project_id)
      comment: "Distinct count of projects with schedule activities"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`project_resource_utilization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Project resource assignment and utilization metrics. Used by resource managers and project managers to monitor resource allocation, cost efficiency, and capacity utilization."
  source: "`feip_eastus_03`.`project`.`resource`"
  dimensions:
    - name: "resource_type"
      expr: type
      comment: "Classification of resource (labor, equipment, material, subcontractor, consultant)"
    - name: "assignment_status"
      expr: assignment_status
      comment: "Current status of resource assignment"
    - name: "approval_status"
      expr: approval_status
      comment: "Approval status by project management"
    - name: "priority"
      expr: priority
      comment: "Priority level of resource assignment"
    - name: "project_phase"
      expr: project_phase
      comment: "Project lifecycle phase during resource assignment"
    - name: "county"
      expr: county
      comment: "County where resource assignment work performed"
    - name: "division"
      expr: division
      comment: "NCDOT division responsible for project"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source for resource costs"
    - name: "billing_type"
      expr: billing_type
      comment: "Method by which resource costs are billed"
    - name: "is_dbe_participation"
      expr: dbe_participation
      comment: "Whether resource provided by DBE certified vendor"
    - name: "is_prevailing_wage"
      expr: prevailing_wage_applicable
      comment: "Whether prevailing wage requirements apply"
  measures:
    - name: "Total Resource Assignments"
      expr: COUNT(1)
      comment: "Total number of resource assignments to projects"
    - name: "Total Planned Quantity"
      expr: SUM(CAST(planned_quantity AS DOUBLE))
      comment: "Total planned quantity of resources across assignments"
    - name: "Total Actual Quantity"
      expr: SUM(CAST(actual_quantity AS DOUBLE))
      comment: "Total actual quantity of resources utilized"
    - name: "Resource Utilization Rate"
      expr: ROUND(100.0 * SUM(CAST(actual_quantity AS DOUBLE)) / NULLIF(SUM(CAST(planned_quantity AS DOUBLE)), 0), 2)
      comment: "Percentage of planned resources actually utilized - resource efficiency metric"
    - name: "Total Planned Hours"
      expr: SUM(CAST(planned_hours AS DOUBLE))
      comment: "Total planned labor hours across assignments"
    - name: "Total Actual Hours"
      expr: SUM(CAST(actual_hours AS DOUBLE))
      comment: "Total actual labor hours worked"
    - name: "Labor Utilization Rate"
      expr: ROUND(100.0 * SUM(CAST(actual_hours AS DOUBLE)) / NULLIF(SUM(CAST(planned_hours AS DOUBLE)), 0), 2)
      comment: "Percentage of planned labor hours actually worked - labor efficiency metric"
    - name: "Avg Utilization Pct"
      expr: AVG(CAST(utilization_rate AS DOUBLE))
      comment: "Average utilization rate across resource assignments"
    - name: "Total Planned Cost"
      expr: SUM(CAST(planned_cost AS DOUBLE))
      comment: "Total planned cost for resource assignments"
    - name: "Total Actual Cost"
      expr: SUM(CAST(actual_cost AS DOUBLE))
      comment: "Total actual cost incurred for resources"
    - name: "Total Cost Variance"
      expr: SUM(CAST(cost_variance AS DOUBLE))
      comment: "Total cost variance (actual minus planned) - resource cost control metric"
    - name: "Resource Cost Performance"
      expr: ROUND(100.0 * SUM(CAST(planned_cost AS DOUBLE)) / NULLIF(SUM(CAST(actual_cost AS DOUBLE)), 0), 2)
      comment: "Ratio of planned to actual cost - resource cost efficiency metric"
    - name: "Avg Unit Rate"
      expr: AVG(CAST(unit_rate AS DOUBLE))
      comment: "Average cost rate per unit of measure for resources"
    - name: "Total Overtime Hours"
      expr: SUM(CAST(overtime_hours AS DOUBLE))
      comment: "Total overtime hours worked by labor resources"
    - name: "Overtime Rate"
      expr: ROUND(100.0 * SUM(CAST(overtime_hours AS DOUBLE)) / NULLIF(SUM(CAST(actual_hours AS DOUBLE)), 0), 2)
      comment: "Percentage of total hours worked as overtime - labor cost pressure metric"
    - name: "Unique Projects with Resources"
      expr: COUNT(DISTINCT project_id)
      comment: "Distinct count of projects with resource assignments"
$$;