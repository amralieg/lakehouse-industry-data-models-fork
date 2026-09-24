-- Metric views for domain: maintenance | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`maintenance_work_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for maintenance work order execution, cost performance, and operational efficiency. Tracks work order completion rates, cost variance, schedule adherence, and resource utilization to inform maintenance budget allocation and operational improvement decisions."
  source: "`feip_eastus_03`.`maintenance`.`work_order`"
  dimensions:
    - name: "order_type"
      expr: order_type
      comment: "Classification of work order (preventive, corrective, emergency, routine, winter weather, vegetation management, pavement preservation, bridge maintenance)"
    - name: "priority"
      expr: priority
      comment: "Priority level indicating urgency and resource allocation requirements"
    - name: "status"
      expr: status
      comment: "Current lifecycle status from creation through completion and closure"
    - name: "division"
      expr: division
      comment: "NCDOT geographic division (1-14) responsible for the maintenance work"
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where maintenance work is performed"
    - name: "asset_type"
      expr: asset_type
      comment: "Category of transportation infrastructure asset or equipment being maintained"
    - name: "work_category"
      expr: work_category
      comment: "Specific category of maintenance activity being performed"
    - name: "federal_funding_source"
      expr: federal_funding_source
      comment: "Federal funding program supporting work order costs (FHWA, FTA, HSIP, CMAQ, STP, BUILD, INFRA, RAISE, or state/local funds)"
    - name: "emergency_response_flag"
      expr: emergency_response_flag
      comment: "Indicates whether work order is part of emergency response operations"
    - name: "budget_year"
      expr: budget_year
      comment: "Federal Fiscal Year (FFY) or State Fiscal Year (SFY) for which the work order is budgeted"
    - name: "created_year"
      expr: YEAR(created_date)
      comment: "Year when work order was created"
    - name: "created_quarter"
      expr: CONCAT('Q', QUARTER(created_date))
      comment: "Quarter when work order was created"
    - name: "planned_start_year"
      expr: YEAR(planned_start_date)
      comment: "Year when maintenance work is planned to begin"
  measures:
    - name: "total_work_orders"
      expr: COUNT(1)
      comment: "Total number of maintenance work orders issued"
    - name: "total_estimated_cost"
      expr: SUM(CAST(estimated_cost AS DOUBLE))
      comment: "Total estimated cost for all work orders including labor, materials, and equipment"
    - name: "total_actual_cost"
      expr: SUM(CAST(actual_cost AS DOUBLE))
      comment: "Total actual cost incurred for completed work orders"
    - name: "cost_variance_pct"
      expr: ROUND(100.0 * (SUM(CAST(actual_cost AS DOUBLE)) - SUM(CAST(estimated_cost AS DOUBLE))) / NULLIF(SUM(CAST(estimated_cost AS DOUBLE)), 0), 2)
      comment: "Percentage variance between actual and estimated costs - key metric for budget accuracy and cost control"
    - name: "total_labor_cost"
      expr: SUM(CAST(labor_cost AS DOUBLE))
      comment: "Total labor cost including wages and benefits for maintenance personnel"
    - name: "total_material_cost"
      expr: SUM(CAST(material_cost AS DOUBLE))
      comment: "Total cost of materials consumed in completing work orders"
    - name: "total_equipment_cost"
      expr: SUM(CAST(equipment_cost AS DOUBLE))
      comment: "Total equipment usage cost including rental, fuel, and operating costs"
    - name: "total_contractor_cost"
      expr: SUM(CAST(contractor_cost AS DOUBLE))
      comment: "Total cost paid to external contractors for work performed"
    - name: "labor_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(labor_cost AS DOUBLE)) / NULLIF(SUM(CAST(actual_cost AS DOUBLE)), 0), 2)
      comment: "Labor cost as percentage of total actual cost - key metric for workforce efficiency"
    - name: "contractor_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(contractor_cost AS DOUBLE)) / NULLIF(SUM(CAST(actual_cost AS DOUBLE)), 0), 2)
      comment: "Contractor cost as percentage of total actual cost - key metric for outsourcing strategy"
    - name: "avg_estimated_duration_hours"
      expr: AVG(CAST(estimated_duration_hours AS DOUBLE))
      comment: "Average estimated labor hours per work order"
    - name: "avg_actual_duration_hours"
      expr: AVG(CAST(actual_duration_hours AS DOUBLE))
      comment: "Average actual labor hours per work order"
    - name: "schedule_variance_pct"
      expr: ROUND(100.0 * (SUM(CAST(actual_duration_hours AS DOUBLE)) - SUM(CAST(estimated_duration_hours AS DOUBLE))) / NULLIF(SUM(CAST(estimated_duration_hours AS DOUBLE)), 0), 2)
      comment: "Percentage variance between actual and estimated duration - key metric for schedule adherence and resource planning"
    - name: "avg_cost_per_work_order"
      expr: AVG(CAST(actual_cost AS DOUBLE))
      comment: "Average actual cost per work order - key metric for maintenance efficiency benchmarking"
    - name: "total_equipment_hours"
      expr: SUM(CAST(equipment_hours AS DOUBLE))
      comment: "Total equipment operating hours logged across all work orders"
    - name: "total_vehicle_miles"
      expr: SUM(CAST(vehicle_miles AS DOUBLE))
      comment: "Total vehicle miles traveled during work order execution"
    - name: "work_orders_with_safety_incidents"
      expr: SUM(CASE WHEN safety_incident_flag = true THEN 1 ELSE 0 END)
      comment: "Count of work orders where safety incidents occurred"
    - name: "safety_incident_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN safety_incident_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of work orders with safety incidents - critical safety performance metric"
    - name: "emergency_work_orders"
      expr: SUM(CASE WHEN emergency_response_flag = true THEN 1 ELSE 0 END)
      comment: "Count of emergency response work orders"
    - name: "emergency_work_order_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN emergency_response_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of work orders classified as emergency response - key metric for reactive vs preventive maintenance balance"
    - name: "work_orders_requiring_permits"
      expr: SUM(CASE WHEN permit_required = true THEN 1 ELSE 0 END)
      comment: "Count of work orders requiring environmental or regulatory permits"
    - name: "work_orders_with_deficiencies"
      expr: SUM(CASE WHEN deficiency_identified_flag = true THEN 1 ELSE 0 END)
      comment: "Count of work orders where deficiencies or additional work needs were identified"
    - name: "deficiency_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN deficiency_identified_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of work orders with identified deficiencies - key quality metric"
    - name: "fema_eligible_work_orders"
      expr: SUM(CASE WHEN fema_eligible_flag = true THEN 1 ELSE 0 END)
      comment: "Count of work orders eligible for FEMA reimbursement"
    - name: "fema_eligible_cost"
      expr: SUM(CASE WHEN fema_eligible_flag = true THEN CAST(actual_cost AS DOUBLE) ELSE 0 END)
      comment: "Total actual cost for FEMA-eligible work orders - critical for disaster recovery funding"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`maintenance_crew_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational KPIs for crew utilization, labor productivity, and workforce deployment efficiency. Tracks crew hours, overtime rates, labor costs, and assignment completion to inform staffing decisions and workforce optimization."
  source: "`feip_eastus_03`.`maintenance`.`crew_assignment`"
  dimensions:
    - name: "crew_type"
      expr: crew_type
      comment: "Classification of crew based on work type (paving, bridge, electrical, structural, painting, ferry operations)"
    - name: "crew_role"
      expr: crew_role
      comment: "Role or function the crew performs on work order (lead, operator, laborer, specialist)"
    - name: "assignment_status"
      expr: assignment_status
      comment: "Current status of crew assignment (scheduled, active, completed, cancelled)"
    - name: "completion_status"
      expr: completion_status
      comment: "Status of crews work on work order (not started, in progress, completed, on hold)"
    - name: "shift_type"
      expr: shift_type
      comment: "Classification of work shift (regular, overtime, night, weekend, emergency)"
    - name: "county"
      expr: county
      comment: "North Carolina county where crew assignment work is performed"
    - name: "division"
      expr: division
      comment: "NCDOT organizational division responsible for crew assignment"
    - name: "district"
      expr: district
      comment: "Geographic district or maintenance unit within NCDOT division"
    - name: "priority"
      expr: priority
      comment: "Priority level assigned to crew assignment or work order"
    - name: "emergency_response_flag"
      expr: emergency_response_flag
      comment: "Indicates whether crew assignment is part of emergency response operation"
    - name: "assignment_year"
      expr: YEAR(assignment_date)
      comment: "Year when crew was assigned to work order"
    - name: "assignment_quarter"
      expr: CONCAT('Q', QUARTER(assignment_date))
      comment: "Quarter when crew was assigned to work order"
  measures:
    - name: "total_crew_assignments"
      expr: COUNT(1)
      comment: "Total number of crew assignments to work orders"
    - name: "total_hours_worked"
      expr: SUM(CAST(hours_worked AS DOUBLE))
      comment: "Total labor hours worked across all crew assignments"
    - name: "total_actual_hours_worked"
      expr: SUM(CAST(actual_hours_worked AS DOUBLE))
      comment: "Total actual hours worked by individual employees during crew assignments"
    - name: "total_overtime_hours"
      expr: SUM(CAST(overtime_hours AS DOUBLE))
      comment: "Total overtime hours worked across all crew assignments"
    - name: "overtime_rate_pct"
      expr: ROUND(100.0 * SUM(CAST(overtime_hours AS DOUBLE)) / NULLIF(SUM(CAST(actual_hours_worked AS DOUBLE)), 0), 2)
      comment: "Overtime hours as percentage of total actual hours - key metric for workforce planning and cost control"
    - name: "total_labor_cost"
      expr: SUM(CAST(labor_cost AS DOUBLE))
      comment: "Total labor cost including regular and overtime pay across all crew assignments"
    - name: "avg_labor_cost_per_assignment"
      expr: AVG(CAST(labor_cost AS DOUBLE))
      comment: "Average labor cost per crew assignment"
    - name: "avg_hours_per_assignment"
      expr: AVG(CAST(hours_worked AS DOUBLE))
      comment: "Average labor hours per crew assignment - key productivity metric"
    - name: "avg_shift_duration_hours"
      expr: AVG(CAST(shift_duration_hours AS DOUBLE))
      comment: "Average shift duration in hours across all crew assignments"
    - name: "avg_completion_percentage"
      expr: AVG(CAST(completion_percentage AS DOUBLE))
      comment: "Average percentage of work completed during crew assignments"
    - name: "completed_assignments"
      expr: SUM(CASE WHEN completion_status = 'completed' THEN 1 ELSE 0 END)
      comment: "Count of crew assignments with completed status"
    - name: "completion_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN completion_status = 'completed' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crew assignments completed - key operational efficiency metric"
    - name: "emergency_assignments"
      expr: SUM(CASE WHEN emergency_response_flag = true THEN 1 ELSE 0 END)
      comment: "Count of crew assignments for emergency response operations"
    - name: "emergency_assignment_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN emergency_response_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crew assignments classified as emergency response - key metric for reactive workforce deployment"
    - name: "assignments_requiring_traffic_control"
      expr: SUM(CASE WHEN traffic_control_required = true THEN 1 ELSE 0 END)
      comment: "Count of crew assignments requiring traffic control measures"
    - name: "assignments_with_safety_briefing"
      expr: SUM(CASE WHEN safety_briefing_completed = true THEN 1 ELSE 0 END)
      comment: "Count of crew assignments where required safety briefing was completed"
    - name: "safety_briefing_compliance_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN safety_briefing_completed = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crew assignments with completed safety briefings - critical safety compliance metric"
    - name: "total_material_quantity"
      expr: SUM(CAST(material_quantity AS DOUBLE))
      comment: "Total quantity of materials used during crew assignments"
    - name: "unique_crews_assigned"
      expr: COUNT(DISTINCT crew_id)
      comment: "Number of distinct crews assigned to work orders"
    - name: "unique_employees_assigned"
      expr: COUNT(DISTINCT employee_id)
      comment: "Number of distinct employees assigned to crew work"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`maintenance_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for maintenance event execution, asset condition improvement, and treatment effectiveness. Tracks event costs, duration, material usage, and asset condition changes to inform maintenance strategy and investment prioritization."
  source: "`feip_eastus_03`.`maintenance`.`event`"
  dimensions:
    - name: "event_type"
      expr: type
      comment: "Classification of maintenance event (preventive, corrective, emergency, routine, seasonal, inspection, repair, replacement, rehabilitation, preservation)"
    - name: "work_type_code"
      expr: work_type_code
      comment: "Standardized code identifying specific type of maintenance work performed"
    - name: "priority"
      expr: priority
      comment: "Priority level assigned to maintenance event indicating urgency"
    - name: "status"
      expr: status
      comment: "Current lifecycle status of maintenance event"
    - name: "division"
      expr: division
      comment: "NCDOT geographic division (Division 1 through Division 14) responsible for maintenance event"
    - name: "county"
      expr: county
      comment: "North Carolina county where maintenance event occurred"
    - name: "functional_class"
      expr: functional_class
      comment: "FHWA functional classification of roadway where maintenance was performed"
    - name: "asset_type"
      expr: asset_type
      comment: "Type of transportation asset being maintained"
    - name: "treatment_type"
      expr: treatment_type
      comment: "Specific maintenance treatment or intervention applied to asset"
    - name: "service_provider_type"
      expr: service_provider_type
      comment: "Classification of entity performing maintenance work (internal NCDOT staff, external contractor, vendor, mutual aid)"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary source of funding for maintenance event (state, federal, local, grant, emergency funds)"
    - name: "federal_program"
      expr: federal_program
      comment: "Specific federal funding program if federal funds were used"
    - name: "emergency_response"
      expr: emergency_response
      comment: "Flag indicating whether maintenance event was emergency response to incident or hazardous condition"
    - name: "winter_weather_event"
      expr: winter_weather_event
      comment: "Flag indicating whether maintenance event was part of winter weather operations"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year in which maintenance event occurred"
    - name: "actual_start_year"
      expr: YEAR(actual_start_date)
      comment: "Year when maintenance work actually began"
    - name: "actual_start_quarter"
      expr: CONCAT('Q', QUARTER(actual_start_date))
      comment: "Quarter when maintenance work actually began"
  measures:
    - name: "total_maintenance_events"
      expr: COUNT(1)
      comment: "Total number of maintenance events performed"
    - name: "total_duration_hours"
      expr: SUM(CAST(duration_hours AS DOUBLE))
      comment: "Total duration of all maintenance events in hours"
    - name: "total_labor_hours"
      expr: SUM(CAST(labor_hours AS DOUBLE))
      comment: "Total labor hours expended across all crew members for maintenance events"
    - name: "total_equipment_hours"
      expr: SUM(CAST(equipment_hours AS DOUBLE))
      comment: "Total equipment usage hours for all machinery and vehicles used during maintenance events"
    - name: "total_material_cost"
      expr: SUM(CAST(material_cost AS DOUBLE))
      comment: "Total cost of materials consumed during maintenance events"
    - name: "total_labor_cost"
      expr: SUM(CAST(labor_cost AS DOUBLE))
      comment: "Total labor cost including wages and benefits for all crew members"
    - name: "total_equipment_cost"
      expr: SUM(CAST(equipment_cost AS DOUBLE))
      comment: "Total equipment cost including machinery rental or usage charges"
    - name: "total_contractor_cost"
      expr: SUM(CAST(contractor_cost AS DOUBLE))
      comment: "Total cost paid to external contractors or vendors for performing maintenance work"
    - name: "total_event_cost"
      expr: SUM(CAST(total_cost AS DOUBLE))
      comment: "Total cost of all maintenance events including materials, labor, equipment, and contractor expenses"
    - name: "avg_cost_per_event"
      expr: AVG(CAST(total_cost AS DOUBLE))
      comment: "Average total cost per maintenance event - key efficiency benchmark"
    - name: "material_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(material_cost AS DOUBLE)) / NULLIF(SUM(CAST(total_cost AS DOUBLE)), 0), 2)
      comment: "Material cost as percentage of total event cost - key metric for cost structure analysis"
    - name: "labor_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(labor_cost AS DOUBLE)) / NULLIF(SUM(CAST(total_cost AS DOUBLE)), 0), 2)
      comment: "Labor cost as percentage of total event cost - key metric for workforce efficiency"
    - name: "contractor_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(contractor_cost AS DOUBLE)) / NULLIF(SUM(CAST(total_cost AS DOUBLE)), 0), 2)
      comment: "Contractor cost as percentage of total event cost - key metric for outsourcing strategy"
    - name: "avg_duration_hours"
      expr: AVG(CAST(duration_hours AS DOUBLE))
      comment: "Average duration per maintenance event in hours"
    - name: "avg_labor_hours_per_event"
      expr: AVG(CAST(labor_hours AS DOUBLE))
      comment: "Average labor hours per maintenance event - key productivity metric"
    - name: "total_material_quantity"
      expr: SUM(CAST(material_quantity AS DOUBLE))
      comment: "Total quantity of primary material consumed during maintenance events"
    - name: "avg_pavement_condition_improvement"
      expr: AVG(CAST(pavement_condition_index_after AS DOUBLE) - CAST(pavement_condition_index_before AS DOUBLE))
      comment: "Average improvement in Pavement Condition Index from maintenance events - key effectiveness metric for pavement preservation strategy"
    - name: "events_with_safety_incidents"
      expr: SUM(CASE WHEN safety_incident = true THEN 1 ELSE 0 END)
      comment: "Count of maintenance events where safety incidents or injuries occurred"
    - name: "safety_incident_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN safety_incident = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of maintenance events with safety incidents - critical safety performance metric"
    - name: "emergency_response_events"
      expr: SUM(CASE WHEN emergency_response = true THEN 1 ELSE 0 END)
      comment: "Count of maintenance events classified as emergency response"
    - name: "emergency_response_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN emergency_response = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of maintenance events classified as emergency response - key metric for reactive vs preventive maintenance balance"
    - name: "winter_weather_events"
      expr: SUM(CASE WHEN winter_weather_event = true THEN 1 ELSE 0 END)
      comment: "Count of maintenance events for winter weather operations"
    - name: "events_requiring_mot"
      expr: SUM(CASE WHEN mot_required = true THEN 1 ELSE 0 END)
      comment: "Count of maintenance events requiring Maintenance of Traffic measures"
    - name: "events_with_qa_performed"
      expr: SUM(CASE WHEN quality_assurance_performed = true THEN 1 ELSE 0 END)
      comment: "Count of maintenance events where quality assurance inspection was performed"
    - name: "qa_compliance_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN quality_assurance_performed = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of maintenance events with quality assurance inspection - key quality compliance metric"
    - name: "events_with_warranty"
      expr: SUM(CASE WHEN warranty_applicable = true THEN 1 ELSE 0 END)
      comment: "Count of maintenance events where warranty coverage applies"
    - name: "unique_contractors"
      expr: COUNT(DISTINCT contractor_name)
      comment: "Number of distinct contractors performing maintenance work"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`maintenance_crew`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for maintenance crew capacity, certification compliance, and operational readiness. Tracks crew capabilities, service area coverage, certification status, and performance ratings to inform workforce planning and training investment decisions."
  source: "`feip_eastus_03`.`maintenance`.`crew`"
  dimensions:
    - name: "crew_type"
      expr: type
      comment: "Classification of crew based on primary maintenance function and specialization"
    - name: "crew_status"
      expr: status
      comment: "Current operational status of maintenance crew"
    - name: "division"
      expr: division
      comment: "NCDOT Division of Highways division to which crew is assigned (Division 1 through Division 14)"
    - name: "district"
      expr: district
      comment: "Maintenance district within division responsible for crews geographic area of operations"
    - name: "county"
      expr: county
      comment: "Primary North Carolina county where crew is based and performs maintenance operations"
    - name: "primary_specialization"
      expr: primary_specialization
      comment: "Primary area of technical specialization or expertise for crew"
    - name: "shift_pattern"
      expr: shift_pattern
      comment: "Standard work shift pattern for crew (day shift, night shift, rotating, on-call)"
    - name: "emergency_response_capable"
      expr: emergency_response_capable
      comment: "Indicates whether crew is equipped and trained for emergency response operations"
    - name: "winter_operations_capable"
      expr: winter_operations_capable
      comment: "Indicates whether crew is equipped and trained for winter weather operations"
    - name: "seasonal_crew"
      expr: seasonal_crew
      comment: "Indicates whether crew operates on seasonal basis"
    - name: "contract_crew"
      expr: contract_crew
      comment: "Indicates whether crew is contracted external crew rather than NCDOT employees"
    - name: "performance_rating"
      expr: performance_rating
      comment: "Overall performance rating for crew based on work quality, productivity, and service delivery metrics"
    - name: "safety_record_rating"
      expr: safety_record_rating
      comment: "Overall safety performance rating for crew based on incident history and safety compliance"
  measures:
    - name: "total_crews"
      expr: COUNT(1)
      comment: "Total number of maintenance crews"
    - name: "total_crew_size"
      expr: SUM(CAST(size AS DOUBLE))
      comment: "Total number of personnel across all crews including crew leaders"
    - name: "avg_crew_size"
      expr: AVG(CAST(size AS DOUBLE))
      comment: "Average number of personnel per crew - key metric for crew composition planning"
    - name: "total_service_area_mileage"
      expr: SUM(CAST(service_area_mileage AS DOUBLE))
      comment: "Total centerline miles of roadway within all crews assigned maintenance service areas"
    - name: "total_service_area_lane_miles"
      expr: SUM(CAST(service_area_lane_miles AS DOUBLE))
      comment: "Total lane miles within all crews assigned maintenance service areas"
    - name: "avg_service_area_mileage"
      expr: AVG(CAST(service_area_mileage AS DOUBLE))
      comment: "Average centerline miles per crew - key metric for workload distribution"
    - name: "avg_service_area_lane_miles"
      expr: AVG(CAST(service_area_lane_miles AS DOUBLE))
      comment: "Average lane miles per crew - key metric for capacity planning"
    - name: "total_operational_hours_per_week"
      expr: SUM(CAST(operational_hours_per_week AS DOUBLE))
      comment: "Total standard operational hours per week across all crews"
    - name: "avg_operational_hours_per_week"
      expr: AVG(CAST(operational_hours_per_week AS DOUBLE))
      comment: "Average operational hours per week per crew"
    - name: "total_work_orders_completed_ytd"
      expr: SUM(CAST(work_orders_completed_ytd AS DOUBLE))
      comment: "Total work orders completed by all crews in current fiscal year"
    - name: "avg_work_orders_completed_ytd"
      expr: AVG(CAST(work_orders_completed_ytd AS DOUBLE))
      comment: "Average work orders completed per crew in current fiscal year - key productivity metric"
    - name: "total_active_work_orders"
      expr: SUM(CAST(active_work_orders AS DOUBLE))
      comment: "Total active work orders currently assigned to all crews"
    - name: "avg_active_work_orders"
      expr: AVG(CAST(active_work_orders AS DOUBLE))
      comment: "Average active work orders per crew - key metric for workload management"
    - name: "crews_with_cdl_required"
      expr: SUM(CASE WHEN cdl_required = true THEN 1 ELSE 0 END)
      comment: "Count of crews requiring Commercial Driver License for operating maintenance vehicles"
    - name: "crews_hazmat_certified"
      expr: SUM(CASE WHEN hazmat_certified = true THEN 1 ELSE 0 END)
      comment: "Count of crews certified to handle hazardous materials"
    - name: "hazmat_certification_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN hazmat_certified = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crews certified for hazardous materials handling - key capability metric"
    - name: "crews_mot_certified"
      expr: SUM(CASE WHEN mot_certified = true THEN 1 ELSE 0 END)
      comment: "Count of crews certified for Maintenance of Traffic operations"
    - name: "mot_certification_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN mot_certified = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crews certified for Maintenance of Traffic operations - critical safety capability metric"
    - name: "crews_emergency_response_capable"
      expr: SUM(CASE WHEN emergency_response_capable = true THEN 1 ELSE 0 END)
      comment: "Count of crews equipped and trained for emergency response operations"
    - name: "emergency_response_capability_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN emergency_response_capable = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crews capable of emergency response - key metric for emergency preparedness"
    - name: "crews_winter_operations_capable"
      expr: SUM(CASE WHEN winter_operations_capable = true THEN 1 ELSE 0 END)
      comment: "Count of crews equipped and trained for winter weather operations"
    - name: "winter_operations_capability_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN winter_operations_capable = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crews capable of winter operations - key metric for seasonal readiness"
    - name: "crews_with_gps_tracking"
      expr: SUM(CASE WHEN gps_tracking_enabled = true THEN 1 ELSE 0 END)
      comment: "Count of crews with GPS tracking through Automatic Vehicle Location systems"
    - name: "gps_tracking_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN gps_tracking_enabled = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crews with GPS tracking enabled - key metric for fleet management and accountability"
    - name: "seasonal_crews"
      expr: SUM(CASE WHEN seasonal_crew = true THEN 1 ELSE 0 END)
      comment: "Count of crews operating on seasonal basis"
    - name: "contract_crews"
      expr: SUM(CASE WHEN contract_crew = true THEN 1 ELSE 0 END)
      comment: "Count of contracted external crews rather than NCDOT employees"
    - name: "contract_crew_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN contract_crew = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crews that are contracted external crews - key metric for workforce composition strategy"
    - name: "total_equipment_assigned"
      expr: SUM(CAST(equipment_assigned_count AS DOUBLE))
      comment: "Total vehicles and equipment units assigned to all crews"
    - name: "avg_equipment_per_crew"
      expr: AVG(CAST(equipment_assigned_count AS DOUBLE))
      comment: "Average equipment units per crew - key metric for equipment allocation"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`maintenance_material`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for maintenance material inventory management, procurement efficiency, and cost control. Tracks stock levels, consumption patterns, reorder triggers, and material costs to inform procurement strategy and inventory optimization decisions."
  source: "`feip_eastus_03`.`maintenance`.`material`"
  dimensions:
    - name: "material_type"
      expr: type
      comment: "Classification of material based on usage category in maintenance operations"
    - name: "material_group"
      expr: group
      comment: "Hierarchical grouping code for procurement and reporting purposes"
    - name: "material_status"
      expr: status
      comment: "Current lifecycle status indicating whether material is available for use in work orders and procurement"
    - name: "procurement_type"
      expr: procurement_type
      comment: "Indicates how material is typically procured (externally from vendors, internally produced, or both)"
    - name: "abc_indicator"
      expr: abc_indicator
      comment: "ABC analysis classification based on consumption value and criticality (A=high value/critical, B=moderate, C=low value/routine, X=no movement)"
    - name: "xyz_indicator"
      expr: xyz_indicator
      comment: "XYZ analysis classification based on consumption variability (X=constant demand, Y=variable demand, Z=sporadic demand)"
    - name: "seasonal_material"
      expr: seasonal_material
      comment: "Flag indicating whether material has seasonal demand patterns"
    - name: "critical_material"
      expr: critical_material
      comment: "Flag indicating whether material is critical for emergency response, safety operations, or high-priority maintenance"
    - name: "hazardous_material_indicator"
      expr: hazardous_material_indicator
      comment: "Flag indicating whether material is classified as hazardous requiring special handling"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code indicating which organizational division primarily uses or manages material"
    - name: "district_code"
      expr: district_code
      comment: "NCDOT highway district code if material is managed at district level"
  measures:
    - name: "total_materials"
      expr: COUNT(1)
      comment: "Total number of distinct materials in maintenance inventory"
    - name: "total_stock_on_hand"
      expr: SUM(CAST(stock_on_hand AS DOUBLE))
      comment: "Total current available inventory quantity across all materials"
    - name: "total_reserved_stock"
      expr: SUM(CAST(reserved_stock AS DOUBLE))
      comment: "Total quantity of material reserved for specific work orders but not yet issued"
    - name: "total_available_stock"
      expr: SUM(CAST(available_stock AS DOUBLE))
      comment: "Total unreserved inventory quantity available for new work order assignments"
    - name: "total_inventory_value"
      expr: SUM(CAST(stock_on_hand AS DOUBLE) * CAST(moving_average_price AS DOUBLE))
      comment: "Total value of inventory on hand using moving average price - key metric for working capital management"
    - name: "total_annual_consumption_quantity"
      expr: SUM(CAST(annual_consumption_quantity AS DOUBLE))
      comment: "Total quantity consumed across all materials in previous 12 months"
    - name: "total_annual_consumption_value"
      expr: SUM(CAST(annual_consumption_quantity AS DOUBLE) * CAST(moving_average_price AS DOUBLE))
      comment: "Total value of materials consumed in previous 12 months - key metric for procurement budget planning"
    - name: "materials_below_minimum_stock"
      expr: SUM(CASE WHEN CAST(stock_on_hand AS DOUBLE) < CAST(minimum_stock_level AS DOUBLE) THEN 1 ELSE 0 END)
      comment: "Count of materials with inventory below minimum stock level"
    - name: "stockout_risk_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(stock_on_hand AS DOUBLE) < CAST(minimum_stock_level AS DOUBLE) THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of materials below minimum stock level - critical metric for stockout risk management"
    - name: "materials_at_reorder_point"
      expr: SUM(CASE WHEN CAST(stock_on_hand AS DOUBLE) <= CAST(reorder_point AS DOUBLE) THEN 1 ELSE 0 END)
      comment: "Count of materials at or below reorder point requiring procurement action"
    - name: "materials_above_maximum_stock"
      expr: SUM(CASE WHEN CAST(stock_on_hand AS DOUBLE) > CAST(maximum_stock_level AS DOUBLE) THEN 1 ELSE 0 END)
      comment: "Count of materials with inventory above maximum stock level"
    - name: "overstock_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(stock_on_hand AS DOUBLE) > CAST(maximum_stock_level AS DOUBLE) THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of materials above maximum stock level - key metric for excess inventory management"
    - name: "avg_lead_time_days"
      expr: AVG(CAST(lead_time_days AS DOUBLE))
      comment: "Average procurement lead time in days from purchase order to material receipt - key metric for supply chain efficiency"
    - name: "materials_requiring_quality_inspection"
      expr: SUM(CASE WHEN quality_inspection_required = true THEN 1 ELSE 0 END)
      comment: "Count of materials requiring quality inspection before use"
    - name: "hazardous_materials"
      expr: SUM(CASE WHEN hazardous_material_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of materials classified as hazardous"
    - name: "hazardous_material_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN hazardous_material_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of materials classified as hazardous - key metric for safety and compliance management"
    - name: "critical_materials"
      expr: SUM(CASE WHEN critical_material = true THEN 1 ELSE 0 END)
      comment: "Count of materials critical for emergency response or high-priority maintenance"
    - name: "seasonal_materials"
      expr: SUM(CASE WHEN seasonal_material = true THEN 1 ELSE 0 END)
      comment: "Count of materials with seasonal demand patterns"
    - name: "materials_with_expiration"
      expr: SUM(CASE WHEN CAST(shelf_life_days AS DOUBLE) > 0 THEN 1 ELSE 0 END)
      comment: "Count of materials with defined shelf life requiring expiration tracking"
    - name: "avg_standard_cost"
      expr: AVG(CAST(standard_cost AS DOUBLE))
      comment: "Average standard unit cost across all materials"
    - name: "avg_moving_average_price"
      expr: AVG(CAST(moving_average_price AS DOUBLE))
      comment: "Average moving average price across all materials"
    - name: "inventory_turnover_ratio"
      expr: ROUND(SUM(CAST(annual_consumption_quantity AS DOUBLE)) / NULLIF(SUM(CAST(stock_on_hand AS DOUBLE)), 0), 2)
      comment: "Ratio of annual consumption to current inventory - key metric for inventory efficiency and working capital optimization"
    - name: "materials_buy_america_compliant"
      expr: SUM(CASE WHEN buy_america_compliant = true THEN 1 ELSE 0 END)
      comment: "Count of materials meeting Buy America requirements for federally funded projects"
    - name: "buy_america_compliance_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN buy_america_compliant = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of materials meeting Buy America requirements - key metric for federal funding compliance"
    - name: "materials_dbe_eligible"
      expr: SUM(CASE WHEN dbe_eligible = true THEN 1 ELSE 0 END)
      comment: "Count of materials that can be sourced from DBE-certified vendors"
    - name: "unique_manufacturers"
      expr: COUNT(DISTINCT manufacturer_name)
      comment: "Number of distinct manufacturers supplying materials"
$$;