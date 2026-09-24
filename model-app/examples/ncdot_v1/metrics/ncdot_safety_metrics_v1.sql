-- Metric views for domain: safety | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`safety_crash_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic crash metrics for safety program prioritization, HSIP funding decisions, and statewide safety performance monitoring. Tracks fatality and injury trends, crash severity patterns, and high-risk contributing factors that drive executive safety investment decisions."
  source: "`feip_eastus_03`.`safety`.`crash_report`"
  dimensions:
    - name: "crash_date"
      expr: crash_date
      comment: "Date when the crash occurred, used for temporal trend analysis and year-over-year safety performance comparison"
    - name: "crash_year"
      expr: YEAR(crash_date)
      comment: "Calendar year of crash occurrence for annual safety reporting and multi-year trend analysis"
    - name: "crash_month"
      expr: DATE_TRUNC('MONTH', crash_date)
      comment: "Month of crash occurrence for seasonal pattern identification and monthly safety performance tracking"
    - name: "crash_severity"
      expr: crash_severity
      comment: "Classification of crash severity (Fatal, Serious Injury, Minor Injury, PDO) used for prioritizing safety interventions and HSIP eligibility"
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where crash occurred, used for geographic safety program targeting and regional performance comparison"
    - name: "route_number"
      expr: route_number
      comment: "Highway route number where crash occurred, used for corridor-level safety analysis and route-specific countermeasure planning"
    - name: "functional_class"
      expr: functional_class
      comment: "Functional classification of roadway (Interstate, Principal Arterial, etc.) used for safety performance benchmarking by facility type"
    - name: "crash_type"
      expr: crash_type
      comment: "General classification of crash (Vehicle-Vehicle, Vehicle-Pedestrian, Single Vehicle) used for countermeasure selection and program design"
    - name: "collision_type"
      expr: collision_type
      comment: "Manner of collision (Rear-End, Angle, Head-On, Sideswipe) used for engineering countermeasure identification and crash pattern analysis"
    - name: "location_type"
      expr: location_type
      comment: "Classification of roadway location (Intersection, Midblock, Ramp, Interchange) used for location-specific safety program targeting"
    - name: "intersection_type"
      expr: intersection_type
      comment: "Type of intersection where crash occurred (Signalized, Stop-Controlled, Unsignalized) used for intersection safety improvement prioritization"
    - name: "traffic_control_device"
      expr: traffic_control_device
      comment: "Type of traffic control device present at crash location used for evaluating control effectiveness and upgrade needs"
    - name: "light_condition"
      expr: light_condition
      comment: "Ambient light conditions at time of crash (Daylight, Dark-Lighted, Dark-Unlighted) used for lighting improvement program targeting"
    - name: "weather_condition"
      expr: weather_condition
      comment: "Prevailing weather conditions at time of crash used for weather-related safety analysis and winter maintenance program evaluation"
    - name: "roadway_surface_condition"
      expr: roadway_surface_condition
      comment: "Condition of roadway surface at time of crash (Dry, Wet, Ice, Snow) used for pavement safety and drainage improvement prioritization"
    - name: "contributing_factor_primary"
      expr: contributing_factor_primary
      comment: "Primary factor that contributed to crash occurrence used for behavioral and engineering countermeasure selection"
    - name: "alcohol_involved_indicator"
      expr: alcohol_involved_indicator
      comment: "Indicator whether alcohol was a contributing factor, used for DUI enforcement program targeting and GHSP coordination"
    - name: "speeding_indicator"
      expr: speeding_indicator
      comment: "Indicator whether speeding was a contributing factor, used for speed management program targeting and enforcement prioritization"
    - name: "work_zone_indicator"
      expr: work_zone_indicator
      comment: "Indicator whether crash occurred in work zone, used for work zone safety program evaluation and MOT plan improvement"
    - name: "pedestrian_involved_indicator"
      expr: pedestrian_involved_indicator
      comment: "Indicator whether pedestrian was involved, used for pedestrian safety program targeting and Complete Streets prioritization"
    - name: "bicycle_involved_indicator"
      expr: bicycle_involved_indicator
      comment: "Indicator whether bicycle was involved, used for bicycle safety program targeting and infrastructure improvement prioritization"
    - name: "motorcycle_involved_indicator"
      expr: motorcycle_involved_indicator
      comment: "Indicator whether motorcycle was involved, used for motorcycle safety program targeting and rider education initiatives"
    - name: "hsip_eligible_indicator"
      expr: hsip_eligible_indicator
      comment: "Indicator whether crash location is eligible for HSIP funding, used for federal safety funding allocation and project prioritization"
  measures:
    - name: "total_crashes"
      expr: COUNT(1)
      comment: "Total number of crash reports, baseline measure for crash frequency analysis and safety performance trending"
    - name: "total_fatalities"
      expr: SUM(CAST(fatality_count AS DOUBLE))
      comment: "Total number of fatalities across all crashes, primary safety performance measure for Toward Zero Deaths initiative and federal reporting"
    - name: "total_injuries"
      expr: SUM(CAST(injury_count AS DOUBLE))
      comment: "Total number of injuries across all crashes, key safety outcome measure for program effectiveness evaluation and resource allocation"
    - name: "total_vehicles_involved"
      expr: SUM(CAST(vehicle_count AS DOUBLE))
      comment: "Total number of vehicles involved in crashes, used for exposure-based crash rate calculations and multi-vehicle crash pattern analysis"
    - name: "total_persons_involved"
      expr: SUM(CAST(person_count AS DOUBLE))
      comment: "Total number of persons involved in crashes (drivers, passengers, pedestrians, cyclists), used for comprehensive safety impact assessment"
    - name: "fatal_crash_count"
      expr: SUM(CASE WHEN crash_severity = 'Fatal' THEN 1 ELSE 0 END)
      comment: "Number of crashes resulting in at least one fatality, critical KPI for Toward Zero Deaths program and executive safety reporting"
    - name: "serious_injury_crash_count"
      expr: SUM(CASE WHEN crash_severity IN ('Serious Injury', 'A-Injury', 'Incapacitating Injury') THEN 1 ELSE 0 END)
      comment: "Number of crashes resulting in serious injuries (KABCO A-level), key federal performance measure (PM1) for safety program evaluation"
    - name: "fatality_rate_per_100_crashes"
      expr: ROUND(100.0 * SUM(CAST(fatality_count AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Fatalities per 100 crashes, severity indicator used for comparing crash lethality across locations and identifying high-severity corridors"
    - name: "injury_rate_per_100_crashes"
      expr: ROUND(100.0 * SUM(CAST(injury_count AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Injuries per 100 crashes, severity indicator used for evaluating crash severity patterns and safety countermeasure effectiveness"
    - name: "avg_vehicles_per_crash"
      expr: ROUND(SUM(CAST(vehicle_count AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average number of vehicles involved per crash, used for understanding crash complexity and multi-vehicle collision patterns"
    - name: "total_estimated_property_damage"
      expr: SUM(CAST(estimated_property_damage AS DOUBLE))
      comment: "Total estimated property damage in dollars across all crashes, economic impact measure for cost-benefit analysis of safety programs"
    - name: "alcohol_involved_crash_count"
      expr: SUM(CASE WHEN alcohol_involved_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of crashes involving alcohol impairment, critical measure for DUI enforcement program targeting and GHSP coordination"
    - name: "alcohol_involved_crash_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN alcohol_involved_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crashes involving alcohol, key behavioral safety indicator for impaired driving countermeasure effectiveness evaluation"
    - name: "speeding_involved_crash_count"
      expr: SUM(CASE WHEN speeding_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of crashes involving speeding, used for speed management program targeting and enforcement resource allocation"
    - name: "speeding_involved_crash_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN speeding_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crashes involving speeding, behavioral safety indicator for speed-related countermeasure prioritization and program evaluation"
    - name: "work_zone_crash_count"
      expr: SUM(CASE WHEN work_zone_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of crashes occurring in work zones, critical measure for work zone safety program evaluation and MOT plan effectiveness"
    - name: "pedestrian_involved_crash_count"
      expr: SUM(CASE WHEN pedestrian_involved_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of crashes involving pedestrians, key vulnerable road user safety measure for Complete Streets and pedestrian safety program targeting"
    - name: "bicycle_involved_crash_count"
      expr: SUM(CASE WHEN bicycle_involved_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of crashes involving bicycles, vulnerable road user safety measure for bicycle infrastructure improvement prioritization"
    - name: "motorcycle_involved_crash_count"
      expr: SUM(CASE WHEN motorcycle_involved_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of crashes involving motorcycles, vulnerable road user safety measure for motorcycle safety program targeting and rider education"
    - name: "hsip_eligible_crash_count"
      expr: SUM(CASE WHEN hsip_eligible_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of crashes at HSIP-eligible locations, used for federal safety funding allocation and project prioritization decisions"
    - name: "intersection_crash_count"
      expr: SUM(CASE WHEN location_type IN ('Intersection', 'Intersection-Related') THEN 1 ELSE 0 END)
      comment: "Number of crashes at intersections, used for intersection safety improvement program targeting and signal upgrade prioritization"
    - name: "intersection_crash_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN location_type IN ('Intersection', 'Intersection-Related') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crashes occurring at intersections, location pattern indicator for intersection safety program resource allocation"
    - name: "nighttime_crash_count"
      expr: SUM(CASE WHEN light_condition IN ('Dark - Lighted', 'Dark - Not Lighted', 'Dark - Unknown Lighting', 'Dawn', 'Dusk') THEN 1 ELSE 0 END)
      comment: "Number of crashes occurring during nighttime or low-light conditions, used for roadway lighting improvement program prioritization"
    - name: "adverse_weather_crash_count"
      expr: SUM(CASE WHEN weather_condition NOT IN ('Clear', 'Cloudy') THEN 1 ELSE 0 END)
      comment: "Number of crashes occurring during adverse weather conditions, used for weather-related safety countermeasure evaluation and winter maintenance program assessment"
    - name: "wet_pavement_crash_count"
      expr: SUM(CASE WHEN roadway_surface_condition IN ('Wet', 'Water (Standing, Moving)', 'Slush') THEN 1 ELSE 0 END)
      comment: "Number of crashes on wet pavement, used for drainage improvement prioritization and pavement friction enhancement program targeting"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`safety_incident`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational incident response performance metrics for IMAP program evaluation, emergency response effectiveness, and traffic incident management optimization. Drives resource allocation decisions and response protocol improvements."
  source: "`feip_eastus_03`.`safety`.`incident`"
  dimensions:
    - name: "occurred_date"
      expr: occurred_date
      comment: "Date when incident occurred, used for temporal trend analysis and daily incident volume tracking"
    - name: "occurred_year"
      expr: YEAR(occurred_date)
      comment: "Calendar year of incident occurrence for annual incident management performance reporting"
    - name: "occurred_month"
      expr: DATE_TRUNC('MONTH', occurred_date)
      comment: "Month of incident occurrence for seasonal pattern identification and monthly operational performance tracking"
    - name: "incident_type"
      expr: type
      comment: "Classification of incident (crash, hazmat spill, debris, disabled vehicle) used for response protocol selection and resource allocation"
    - name: "severity_level"
      expr: severity_level
      comment: "Assessment of incident severity (Critical, High, Medium, Low) used for response prioritization and resource deployment decisions"
    - name: "status"
      expr: status
      comment: "Current lifecycle status of incident (Open, Responding, Cleared, Closed) used for operational status monitoring and response tracking"
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where incident occurred, used for geographic incident pattern analysis and regional resource allocation"
    - name: "route_number"
      expr: route_number
      comment: "Highway route number where incident occurred, used for corridor-level incident management analysis and IMAP deployment optimization"
    - name: "route_type"
      expr: route_type
      comment: "Classification of route (Interstate, US Highway, State Highway) used for incident management performance benchmarking by facility type"
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT highway division number responsible for incident area, used for divisional performance comparison and resource allocation"
    - name: "responding_agency_primary"
      expr: responding_agency_primary
      comment: "Primary agency that responded to incident (NCDOT, State Highway Patrol, local police) used for multi-agency coordination analysis"
    - name: "imap_unit_dispatched_flag"
      expr: imap_unit_dispatched_flag
      comment: "Indicator whether IMAP unit was dispatched, used for IMAP program coverage evaluation and deployment effectiveness analysis"
    - name: "hazmat_involved_flag"
      expr: hazmat_involved_flag
      comment: "Indicator whether hazardous materials were involved, used for specialized response resource planning and training needs assessment"
    - name: "work_zone_related_flag"
      expr: work_zone_related_flag
      comment: "Indicator whether incident occurred in work zone, used for work zone safety program evaluation and MOT plan effectiveness"
    - name: "weather_condition"
      expr: weather_condition
      comment: "Weather conditions at time of incident, used for weather-related incident pattern analysis and winter operations planning"
  measures:
    - name: "total_incidents"
      expr: COUNT(1)
      comment: "Total number of incidents, baseline measure for incident volume trending and operational workload assessment"
    - name: "total_fatalities"
      expr: SUM(CAST(fatality_count AS DOUBLE))
      comment: "Total number of fatalities across all incidents, critical safety outcome measure for incident management program evaluation"
    - name: "total_injuries"
      expr: SUM(CAST(injury_count AS DOUBLE))
      comment: "Total number of injuries across all incidents, safety outcome measure for emergency response effectiveness evaluation"
    - name: "avg_response_time_minutes"
      expr: ROUND(AVG(CAST(response_time_minutes AS DOUBLE)), 2)
      comment: "Average time from incident detection to first responder arrival, critical operational performance measure for IMAP program effectiveness and resource deployment optimization"
    - name: "avg_clearance_time_minutes"
      expr: ROUND(AVG(CAST(clearance_time_minutes AS DOUBLE)), 2)
      comment: "Average time from incident occurrence to full clearance, key traffic operations measure for incident management efficiency and congestion mitigation effectiveness"
    - name: "avg_roadway_clearance_time_minutes"
      expr: ROUND(AVG(CAST(roadway_clearance_time_minutes AS DOUBLE)), 2)
      comment: "Average time to remove vehicles and debris from travel lanes, operational efficiency measure for quick clearance program evaluation"
    - name: "total_delay_vehicle_hours"
      expr: SUM(CAST(delay_vehicle_hours AS DOUBLE))
      comment: "Total vehicle delay caused by incidents measured in vehicle-hours, economic impact measure for incident management program cost-benefit analysis"
    - name: "avg_delay_vehicle_hours_per_incident"
      expr: ROUND(SUM(CAST(delay_vehicle_hours AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average vehicle delay per incident, efficiency indicator for incident management effectiveness and congestion impact assessment"
    - name: "avg_queue_length_miles"
      expr: ROUND(AVG(CAST(queue_length_miles AS DOUBLE)), 2)
      comment: "Average maximum traffic queue length caused by incidents, congestion impact measure for incident management program evaluation"
    - name: "total_lanes_blocked"
      expr: SUM(CAST(lanes_blocked_count AS DOUBLE))
      comment: "Total number of lane blockages across all incidents, capacity impact measure for incident severity assessment and response resource planning"
    - name: "avg_lanes_blocked_per_incident"
      expr: ROUND(SUM(CAST(lanes_blocked_count AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average number of lanes blocked per incident, severity indicator for incident impact assessment and response protocol evaluation"
    - name: "incidents_requiring_detour"
      expr: SUM(CASE WHEN detour_required_flag = true THEN 1 ELSE 0 END)
      comment: "Number of incidents requiring traffic detour, severity measure for major incident frequency and traffic management complexity assessment"
    - name: "detour_required_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN detour_required_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of incidents requiring detour, severity indicator for major incident frequency and emergency response resource needs"
    - name: "imap_response_count"
      expr: SUM(CASE WHEN imap_unit_dispatched_flag = true THEN 1 ELSE 0 END)
      comment: "Number of incidents with IMAP unit response, program coverage measure for IMAP deployment effectiveness and resource utilization"
    - name: "imap_response_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN imap_unit_dispatched_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of incidents with IMAP response, program coverage indicator for IMAP deployment strategy evaluation and resource allocation decisions"
    - name: "hazmat_incident_count"
      expr: SUM(CASE WHEN hazmat_involved_flag = true THEN 1 ELSE 0 END)
      comment: "Number of incidents involving hazardous materials, specialized response measure for hazmat program planning and training needs assessment"
    - name: "work_zone_incident_count"
      expr: SUM(CASE WHEN work_zone_related_flag = true THEN 1 ELSE 0 END)
      comment: "Number of incidents in work zones, work zone safety measure for MOT plan effectiveness evaluation and contractor safety performance"
    - name: "fatal_incident_count"
      expr: SUM(CASE WHEN fatality_count > 0 THEN 1 ELSE 0 END)
      comment: "Number of incidents resulting in fatalities, critical safety outcome measure for emergency response effectiveness and incident management program evaluation"
    - name: "injury_incident_count"
      expr: SUM(CASE WHEN injury_count > 0 THEN 1 ELSE 0 END)
      comment: "Number of incidents resulting in injuries, safety outcome measure for emergency medical response coordination and incident severity assessment"
    - name: "total_estimated_damage"
      expr: SUM(CAST(estimated_damage_amount AS DOUBLE))
      comment: "Total estimated property damage across all incidents, economic impact measure for incident cost assessment and infrastructure damage tracking"
    - name: "infrastructure_damage_incident_count"
      expr: SUM(CASE WHEN infrastructure_damage_flag = true THEN 1 ELSE 0 END)
      comment: "Number of incidents causing NCDOT infrastructure damage, asset management measure for maintenance needs assessment and cost recovery prioritization"
    - name: "environmental_impact_incident_count"
      expr: SUM(CASE WHEN environmental_impact_flag = true THEN 1 ELSE 0 END)
      comment: "Number of incidents with environmental damage, environmental compliance measure for spill response program evaluation and regulatory reporting"
    - name: "total_spill_volume_gallons"
      expr: SUM(CAST(spill_volume_gallons AS DOUBLE))
      comment: "Total volume of material spilled across environmental incidents, environmental impact measure for spill response resource planning and cleanup cost estimation"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`safety_corrective_action`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Corrective action tracking and completion performance metrics for safety compliance monitoring, inspection follow-up effectiveness, and regulatory accountability. Drives safety program management and resource allocation decisions."
  source: "`feip_eastus_03`.`safety`.`corrective_action`"
  dimensions:
    - name: "assigned_date"
      expr: assigned_date
      comment: "Date when corrective action was assigned, used for action age tracking and assignment volume trending"
    - name: "assigned_year"
      expr: YEAR(assigned_date)
      comment: "Calendar year of corrective action assignment for annual safety compliance performance reporting"
    - name: "assigned_month"
      expr: DATE_TRUNC('MONTH', assigned_date)
      comment: "Month of corrective action assignment for monthly compliance tracking and workload assessment"
    - name: "due_date"
      expr: due_date
      comment: "Target completion date for corrective action, used for deadline tracking and overdue action identification"
    - name: "completed_date"
      expr: completed_date
      comment: "Actual completion date of corrective action, used for completion rate analysis and timeliness assessment"
    - name: "action_type"
      expr: type
      comment: "Classification of corrective action (Immediate, Preventive, Corrective) used for action prioritization and resource allocation"
    - name: "priority"
      expr: priority
      comment: "Priority level (Critical, High, Medium, Low) used for action sequencing and resource deployment decisions"
    - name: "status"
      expr: status
      comment: "Current status (Open, In Progress, Completed, Verified, Closed) used for action tracking and completion monitoring"
    - name: "source_type"
      expr: source_type
      comment: "Type of source event generating action (Inspection, Incident, Audit, Complaint) used for root cause analysis and program evaluation"
    - name: "responsible_division"
      expr: responsible_division
      comment: "NCDOT division responsible for implementing action, used for divisional accountability tracking and resource allocation"
    - name: "responsible_unit"
      expr: responsible_unit
      comment: "Specific unit assigned to execute action, used for unit-level performance tracking and workload balancing"
    - name: "severity_level"
      expr: severity_level
      comment: "Severity of safety issue addressed (Critical, High, Medium, Low) used for risk-based prioritization and resource allocation"
    - name: "county"
      expr: county
      comment: "North Carolina county where action is implemented, used for geographic compliance tracking and regional performance comparison"
    - name: "funding_source"
      expr: funding_source
      comment: "Source of funding for action implementation (HSIP, operational budget, federal grant) used for financial tracking and program cost allocation"
    - name: "hsip_eligible"
      expr: hsip_eligible
      comment: "Indicator whether action is eligible for HSIP funding, used for federal funding allocation and project prioritization"
    - name: "effectiveness_rating"
      expr: effectiveness_rating
      comment: "Assessment of action effectiveness (Highly Effective, Effective, Partially Effective, Ineffective) used for program evaluation and continuous improvement"
    - name: "recurrence_indicator"
      expr: recurrence_indicator
      comment: "Flag indicating whether safety issue recurred after action, used for action effectiveness evaluation and root cause re-analysis"
  measures:
    - name: "total_corrective_actions"
      expr: COUNT(1)
      comment: "Total number of corrective actions, baseline measure for safety compliance workload assessment and inspection follow-up volume"
    - name: "completed_actions"
      expr: SUM(CASE WHEN status IN ('Completed', 'Verified', 'Closed') THEN 1 ELSE 0 END)
      comment: "Number of corrective actions completed, performance measure for safety compliance execution and inspection follow-up effectiveness"
    - name: "completion_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status IN ('Completed', 'Verified', 'Closed') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of corrective actions completed, key compliance performance indicator for safety program management and regulatory accountability"
    - name: "open_actions"
      expr: SUM(CASE WHEN status IN ('Open', 'Assigned', 'In Progress') THEN 1 ELSE 0 END)
      comment: "Number of corrective actions currently open, workload measure for resource planning and compliance risk assessment"
    - name: "overdue_actions"
      expr: SUM(CASE WHEN status IN ('Open', 'Assigned', 'In Progress') AND due_date < CURRENT_DATE THEN 1 ELSE 0 END)
      comment: "Number of corrective actions past due date, critical compliance risk indicator for management escalation and resource reallocation decisions"
    - name: "overdue_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status IN ('Open', 'Assigned', 'In Progress') AND due_date < CURRENT_DATE THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Open', 'Assigned', 'In Progress') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of open actions that are overdue, compliance risk indicator for management attention and process improvement prioritization"
    - name: "critical_priority_actions"
      expr: SUM(CASE WHEN priority IN ('Critical', 'High') THEN 1 ELSE 0 END)
      comment: "Number of critical and high priority actions, risk exposure measure for safety management attention and resource prioritization"
    - name: "critical_priority_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN priority IN ('Critical', 'High') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of actions with critical or high priority, risk profile indicator for safety program severity assessment and resource allocation"
    - name: "avg_days_to_complete"
      expr: ROUND(AVG(DATEDIFF(completed_date, assigned_date)), 2)
      comment: "Average number of days from assignment to completion, efficiency measure for corrective action process performance and resource adequacy assessment"
    - name: "total_estimated_cost"
      expr: SUM(CAST(estimated_cost AS DOUBLE))
      comment: "Total estimated cost of all corrective actions, financial planning measure for safety program budgeting and resource allocation decisions"
    - name: "total_actual_cost"
      expr: SUM(CAST(actual_cost AS DOUBLE))
      comment: "Total actual cost incurred for corrective actions, financial tracking measure for safety program cost management and budget variance analysis"
    - name: "avg_cost_per_action"
      expr: ROUND(SUM(CAST(actual_cost AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average actual cost per corrective action, cost efficiency indicator for safety program financial performance and resource optimization"
    - name: "cost_variance"
      expr: ROUND(SUM(CAST(actual_cost AS DOUBLE)) - SUM(CAST(estimated_cost AS DOUBLE)), 2)
      comment: "Total difference between actual and estimated costs, budget accuracy measure for financial planning improvement and cost estimation refinement"
    - name: "cost_variance_rate"
      expr: ROUND(100.0 * (SUM(CAST(actual_cost AS DOUBLE)) - SUM(CAST(estimated_cost AS DOUBLE))) / NULLIF(SUM(CAST(estimated_cost AS DOUBLE)), 0), 2)
      comment: "Percentage variance between actual and estimated costs, budget accuracy indicator for cost estimation process improvement and financial planning"
    - name: "actions_from_inspections"
      expr: SUM(CASE WHEN source_type IN ('Inspection', 'Safety Inspection', 'Field Inspection') THEN 1 ELSE 0 END)
      comment: "Number of actions generated from inspections, inspection program effectiveness measure for proactive safety issue identification"
    - name: "actions_from_incidents"
      expr: SUM(CASE WHEN source_type IN ('Incident', 'Crash', 'Accident') THEN 1 ELSE 0 END)
      comment: "Number of actions generated from incidents, reactive safety response measure for incident follow-up effectiveness and root cause remediation"
    - name: "verified_actions"
      expr: SUM(CASE WHEN status IN ('Verified', 'Closed') THEN 1 ELSE 0 END)
      comment: "Number of actions verified as effective, quality assurance measure for corrective action effectiveness and compliance closure validation"
    - name: "verification_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status IN ('Verified', 'Closed') THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Verified', 'Closed') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of completed actions that have been verified, quality assurance indicator for corrective action validation process effectiveness"
    - name: "recurrence_count"
      expr: SUM(CASE WHEN recurrence_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of actions where safety issue recurred, effectiveness failure measure for root cause analysis and corrective action redesign prioritization"
    - name: "recurrence_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN recurrence_indicator = true THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Verified', 'Closed') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of verified actions with issue recurrence, effectiveness indicator for corrective action quality and root cause analysis adequacy"
    - name: "hsip_eligible_actions"
      expr: SUM(CASE WHEN hsip_eligible = true THEN 1 ELSE 0 END)
      comment: "Number of actions eligible for HSIP funding, federal funding opportunity measure for safety program financial planning and grant application prioritization"
    - name: "actions_requiring_extension"
      expr: SUM(CASE WHEN extended_due_date IS NOT NULL THEN 1 ELSE 0 END)
      comment: "Number of actions requiring due date extension, schedule risk indicator for resource adequacy assessment and process improvement needs"
    - name: "extension_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN extended_due_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of actions requiring extension, schedule performance indicator for resource planning and corrective action process efficiency evaluation"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`safety_safety_inspection`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Safety inspection performance and compliance metrics for regulatory accountability, inspection program effectiveness, and deficiency identification. Drives inspection resource allocation and compliance management decisions."
  source: "`feip_eastus_03`.`safety`.`safety_inspection`"
  dimensions:
    - name: "inspection_date"
      expr: date
      comment: "Date when safety inspection was conducted, used for inspection frequency tracking and compliance schedule monitoring"
    - name: "inspection_year"
      expr: YEAR(date)
      comment: "Calendar year of inspection for annual compliance reporting and multi-year inspection program evaluation"
    - name: "inspection_month"
      expr: DATE_TRUNC('MONTH', date)
      comment: "Month of inspection for monthly inspection volume tracking and seasonal pattern analysis"
    - name: "inspection_type"
      expr: type
      comment: "Category of safety inspection (Airport, Roadway, Bridge, Rail, Work Zone) used for inspection program segmentation and resource allocation"
    - name: "status"
      expr: status
      comment: "Current status of inspection (Scheduled, In Progress, Completed, Reviewed) used for inspection workflow tracking and completion monitoring"
    - name: "result"
      expr: result
      comment: "Overall outcome of inspection (Pass, Pass with Deficiencies, Fail) used for compliance performance assessment and deficiency trending"
    - name: "inspector_name"
      expr: inspector_name
      comment: "Name of certified inspector who performed inspection, used for inspector workload tracking and quality assurance evaluation"
    - name: "agency"
      expr: agency
      comment: "Agency or organization that conducted inspection (NCDOT division, contractor, third party) used for inspection program coordination and accountability"
    - name: "county"
      expr: county
      comment: "North Carolina county where inspection was conducted, used for geographic inspection coverage analysis and regional compliance tracking"
    - name: "division"
      expr: division
      comment: "NCDOT operational division responsible for inspected asset, used for divisional compliance performance comparison and resource allocation"
    - name: "compliance_status"
      expr: compliance_status
      comment: "Indicates whether inspected asset meets safety standards (Compliant, Non-Compliant, Conditional) used for regulatory compliance tracking and enforcement prioritization"
    - name: "regulatory_standard"
      expr: regulatory_standard
      comment: "Specific regulatory standard against which inspection was conducted (MUTCD, FAA Part 139, FRA Track Safety) used for compliance program segmentation"
    - name: "corrective_action_priority"
      expr: corrective_action_priority
      comment: "Priority level assigned to corrective actions (Critical, High, Medium, Low) used for deficiency remediation prioritization and resource allocation"
    - name: "hsip_eligible"
      expr: hsip_eligible
      comment: "Indicator whether deficiencies are eligible for HSIP funding, used for federal funding allocation and safety project prioritization"
    - name: "mutcd_compliance"
      expr: mutcd_compliance
      comment: "Indicator whether traffic control devices comply with MUTCD standards, used for traffic control device upgrade program targeting"
    - name: "ada_compliance"
      expr: ada_compliance
      comment: "Indicator whether facility complies with ADA accessibility requirements, used for accessibility improvement program prioritization"
  measures:
    - name: "total_inspections"
      expr: COUNT(1)
      comment: "Total number of safety inspections conducted, baseline measure for inspection program volume and resource utilization assessment"
    - name: "completed_inspections"
      expr: SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END)
      comment: "Number of inspections completed, performance measure for inspection program execution and compliance schedule adherence"
    - name: "completion_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections completed, program performance indicator for inspection schedule compliance and resource adequacy assessment"
    - name: "pass_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN result IN ('Pass', 'Passed', 'Satisfactory') THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of completed inspections with passing result, compliance performance indicator for asset safety condition and maintenance program effectiveness"
    - name: "fail_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN result IN ('Fail', 'Failed', 'Unsatisfactory') THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of completed inspections with failing result, compliance risk indicator for asset condition deterioration and maintenance backlog assessment"
    - name: "total_deficiencies"
      expr: SUM(CAST(deficiency_count AS DOUBLE))
      comment: "Total number of safety deficiencies identified across all inspections, deficiency volume measure for maintenance workload and compliance risk assessment"
    - name: "total_critical_deficiencies"
      expr: SUM(CAST(critical_deficiency_count AS DOUBLE))
      comment: "Total number of critical safety deficiencies requiring immediate attention, critical risk measure for emergency response prioritization and resource allocation"
    - name: "avg_deficiencies_per_inspection"
      expr: ROUND(SUM(CAST(deficiency_count AS DOUBLE)) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Average number of deficiencies per completed inspection, asset condition indicator for maintenance program effectiveness and deterioration rate assessment"
    - name: "avg_critical_deficiencies_per_inspection"
      expr: ROUND(SUM(CAST(critical_deficiency_count AS DOUBLE)) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Average number of critical deficiencies per inspection, risk severity indicator for asset safety condition and emergency maintenance needs"
    - name: "inspections_requiring_corrective_action"
      expr: SUM(CASE WHEN corrective_action_required = true THEN 1 ELSE 0 END)
      comment: "Number of inspections requiring corrective action, compliance workload measure for maintenance resource planning and follow-up tracking"
    - name: "corrective_action_required_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN corrective_action_required = true THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of inspections requiring corrective action, deficiency frequency indicator for asset maintenance needs and compliance risk assessment"
    - name: "compliant_inspections"
      expr: SUM(CASE WHEN compliance_status IN ('Compliant', 'Meets Standards', 'Satisfactory') THEN 1 ELSE 0 END)
      comment: "Number of inspections with compliant result, regulatory compliance measure for safety program effectiveness and asset condition assessment"
    - name: "compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_status IN ('Compliant', 'Meets Standards', 'Satisfactory') THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of inspections meeting regulatory compliance standards, key regulatory performance indicator for safety program accountability and enforcement risk"
    - name: "non_compliant_inspections"
      expr: SUM(CASE WHEN compliance_status IN ('Non-Compliant', 'Does Not Meet Standards', 'Unsatisfactory') THEN 1 ELSE 0 END)
      comment: "Number of inspections with non-compliant result, regulatory risk measure for enforcement exposure and corrective action prioritization"
    - name: "avg_inspection_duration_minutes"
      expr: ROUND(AVG(CAST(duration_minutes AS DOUBLE)), 2)
      comment: "Average time spent conducting inspections, efficiency measure for inspection resource planning and inspector productivity assessment"
    - name: "inspections_with_photos"
      expr: SUM(CASE WHEN photos_attached = true THEN 1 ELSE 0 END)
      comment: "Number of inspections with photographic documentation, quality assurance measure for inspection documentation completeness and evidence collection"
    - name: "photo_documentation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN photos_attached = true THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of inspections with photo documentation, documentation quality indicator for inspection process compliance and evidence adequacy"
    - name: "hsip_eligible_inspections"
      expr: SUM(CASE WHEN hsip_eligible = true THEN 1 ELSE 0 END)
      comment: "Number of inspections identifying HSIP-eligible deficiencies, federal funding opportunity measure for safety program financial planning and grant prioritization"
    - name: "mutcd_compliant_inspections"
      expr: SUM(CASE WHEN mutcd_compliance = true THEN 1 ELSE 0 END)
      comment: "Number of inspections with MUTCD-compliant traffic control devices, traffic control compliance measure for device upgrade program evaluation"
    - name: "mutcd_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN mutcd_compliance = true THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of inspections meeting MUTCD standards, traffic control compliance indicator for device upgrade program prioritization and regulatory risk"
    - name: "ada_compliant_inspections"
      expr: SUM(CASE WHEN ada_compliance = true THEN 1 ELSE 0 END)
      comment: "Number of inspections with ADA-compliant facilities, accessibility compliance measure for ADA improvement program evaluation and legal risk assessment"
    - name: "ada_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN ada_compliance = true THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Reviewed', 'Approved') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of inspections meeting ADA accessibility requirements, accessibility compliance indicator for improvement program prioritization and legal compliance"
    - name: "inspections_with_crash_history"
      expr: SUM(CASE WHEN crash_history_flag = true THEN 1 ELSE 0 END)
      comment: "Number of inspections at locations with documented crash history, safety risk indicator for inspection prioritization and crash pattern correlation analysis"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`safety_program`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "HSIP safety program performance and effectiveness metrics for program evaluation, crash reduction goal tracking, and federal reporting. Drives safety program investment decisions and resource allocation."
  source: "`feip_eastus_03`.`safety`.`program`"
  dimensions:
    - name: "program_name"
      expr: name
      comment: "Official name of safety program initiative, used for program identification and performance tracking"
    - name: "program_code"
      expr: code
      comment: "Unique alphanumeric code assigned to safety program, used for financial tracking and reporting"
    - name: "program_type"
      expr: type
      comment: "Classification of safety program (HSIP infrastructure, GHSP behavioral, systemic safety) used for program portfolio management and resource allocation"
    - name: "status"
      expr: status
      comment: "Current operational status of safety program (Planning, Active, Completed, Evaluated) used for program lifecycle tracking and portfolio management"
    - name: "priority_level"
      expr: priority_level
      comment: "Priority ranking (Critical, High, Medium, Low) used for program sequencing and resource allocation decisions"
    - name: "start_year"
      expr: YEAR(start_date)
      comment: "Calendar year of program start for multi-year program tracking and cohort analysis"
    - name: "responsible_division"
      expr: responsible_division
      comment: "NCDOT division administering safety program, used for divisional accountability tracking and resource allocation"
    - name: "target_population"
      expr: target_population
      comment: "Specific population targeted by program (pedestrians, bicyclists, teen drivers) used for program segmentation and effectiveness evaluation"
    - name: "geographic_scope"
      expr: geographic_scope
      comment: "Geographic coverage area (statewide, regional, corridor, intersection) used for program scope analysis and resource distribution"
    - name: "county_name"
      expr: county_name
      comment: "County where program is implemented, used for geographic program distribution and regional performance comparison"
    - name: "route_number"
      expr: route_number
      comment: "Highway route where program is implemented, used for corridor-level program tracking and route safety performance evaluation"
    - name: "crash_type_targeted"
      expr: crash_type_targeted
      comment: "Specific crash type program aims to address (rear-end, angle, roadway departure) used for countermeasure effectiveness evaluation"
    - name: "countermeasure_type"
      expr: countermeasure_type
      comment: "Classification of safety countermeasure (Engineering, Enforcement, Education, Emergency Response) used for program strategy analysis"
    - name: "implementation_phase"
      expr: implementation_phase
      comment: "Current phase of program implementation (Design, Construction, Operational, Evaluation) used for program progress tracking and milestone monitoring"
    - name: "evaluation_status"
      expr: evaluation_status
      comment: "Status of post-implementation evaluation (Not Started, In Progress, Completed) used for program effectiveness assessment tracking"
    - name: "mpo_name"
      expr: mpo_name
      comment: "Metropolitan Planning Organization coordinating program, used for MPO coordination tracking and regional program distribution"
  measures:
    - name: "total_programs"
      expr: COUNT(1)
      comment: "Total number of safety programs, baseline measure for program portfolio size and investment volume assessment"
    - name: "active_programs"
      expr: SUM(CASE WHEN status IN ('Active', 'In Progress', 'Operational') THEN 1 ELSE 0 END)
      comment: "Number of currently active safety programs, portfolio management measure for resource allocation and program coordination"
    - name: "completed_programs"
      expr: SUM(CASE WHEN status IN ('Completed', 'Closed') THEN 1 ELSE 0 END)
      comment: "Number of completed safety programs, program delivery measure for implementation effectiveness and portfolio turnover"
    - name: "total_target_fatality_reduction"
      expr: SUM(CAST(target_fatality_reduction AS DOUBLE))
      comment: "Total target fatalities to be prevented across all programs, strategic goal measure for Toward Zero Deaths initiative and federal performance targets"
    - name: "total_target_serious_injury_reduction"
      expr: SUM(CAST(target_serious_injury_reduction AS DOUBLE))
      comment: "Total target serious injuries to be prevented, federal performance measure (PM1) for safety program goal setting and HSIP reporting"
    - name: "total_baseline_crashes"
      expr: SUM(CAST(baseline_crash_count AS DOUBLE))
      comment: "Total baseline crashes across all program locations, baseline measure for program effectiveness evaluation and crash reduction calculation"
    - name: "total_baseline_fatalities"
      expr: SUM(CAST(baseline_fatality_count AS DOUBLE))
      comment: "Total baseline fatalities across all program locations, baseline measure for fatality reduction effectiveness evaluation"
    - name: "total_baseline_serious_injuries"
      expr: SUM(CAST(baseline_serious_injury_count AS DOUBLE))
      comment: "Total baseline serious injuries across all program locations, baseline measure for serious injury reduction effectiveness evaluation"
    - name: "avg_target_crash_reduction_pct"
      expr: ROUND(AVG(CAST(target_crash_reduction_percentage AS DOUBLE)), 2)
      comment: "Average target crash reduction percentage across programs, program ambition indicator for goal setting and performance expectation assessment"
    - name: "avg_crash_modification_factor"
      expr: ROUND(AVG(CAST(crash_modification_factor AS DOUBLE)), 3)
      comment: "Average crash modification factor across programs, countermeasure effectiveness indicator for program design and expected safety benefit"
    - name: "avg_benefit_cost_ratio"
      expr: ROUND(AVG(CAST(benefit_cost_ratio AS DOUBLE)), 2)
      comment: "Average benefit-cost ratio across programs, economic efficiency indicator for program investment prioritization and resource allocation decisions"
    - name: "programs_with_positive_bcr"
      expr: SUM(CASE WHEN benefit_cost_ratio > 1.0 THEN 1 ELSE 0 END)
      comment: "Number of programs with benefit-cost ratio greater than 1.0, economic viability measure for program justification and investment decision support"
    - name: "positive_bcr_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN benefit_cost_ratio > 1.0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of programs with positive benefit-cost ratio, portfolio economic efficiency indicator for program selection quality and investment effectiveness"
    - name: "evaluated_programs"
      expr: SUM(CASE WHEN evaluation_status IN ('Completed', 'Final') THEN 1 ELSE 0 END)
      comment: "Number of programs with completed effectiveness evaluation, program accountability measure for evidence-based decision making and continuous improvement"
    - name: "evaluation_completion_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN evaluation_status IN ('Completed', 'Final') THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Completed', 'Closed') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of completed programs with finished evaluation, program accountability indicator for evaluation process compliance and learning effectiveness"
    - name: "total_actual_fatality_reduction"
      expr: SUM(CAST(actual_fatality_reduction AS DOUBLE))
      comment: "Total actual fatalities prevented based on evaluation, program effectiveness measure for safety benefit realization and Toward Zero Deaths progress"
    - name: "total_actual_serious_injury_reduction"
      expr: SUM(CAST(actual_serious_injury_reduction AS DOUBLE))
      comment: "Total actual serious injuries prevented based on evaluation, federal performance measure for PM1 reporting and program effectiveness validation"
    - name: "avg_actual_crash_reduction_pct"
      expr: ROUND(AVG(CAST(actual_crash_reduction_percentage AS DOUBLE)), 2)
      comment: "Average actual crash reduction percentage achieved, program effectiveness indicator for countermeasure performance and goal achievement assessment"
    - name: "fatality_goal_achievement_rate"
      expr: ROUND(100.0 * SUM(CAST(actual_fatality_reduction AS DOUBLE)) / NULLIF(SUM(CAST(target_fatality_reduction AS DOUBLE)), 0), 2)
      comment: "Percentage of target fatality reduction achieved, strategic goal performance indicator for Toward Zero Deaths progress and program effectiveness"
    - name: "serious_injury_goal_achievement_rate"
      expr: ROUND(100.0 * SUM(CAST(actual_serious_injury_reduction AS DOUBLE)) / NULLIF(SUM(CAST(target_serious_injury_reduction AS DOUBLE)), 0), 2)
      comment: "Percentage of target serious injury reduction achieved, federal performance indicator for PM1 goal attainment and program effectiveness validation"
    - name: "crash_reduction_goal_achievement_rate"
      expr: ROUND(100.0 * AVG(CAST(actual_crash_reduction_percentage AS DOUBLE)) / NULLIF(AVG(CAST(target_crash_reduction_percentage AS DOUBLE)), 0), 2)
      comment: "Percentage of target crash reduction achieved, program effectiveness indicator for goal attainment and countermeasure performance assessment"
    - name: "programs_meeting_goals"
      expr: SUM(CASE WHEN actual_crash_reduction_percentage >= target_crash_reduction_percentage THEN 1 ELSE 0 END)
      comment: "Number of programs meeting or exceeding crash reduction goals, program success measure for effectiveness validation and best practice identification"
    - name: "goal_achievement_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN actual_crash_reduction_percentage >= target_crash_reduction_percentage THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN evaluation_status IN ('Completed', 'Final') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of evaluated programs meeting crash reduction goals, portfolio effectiveness indicator for program design quality and countermeasure selection"
$$;