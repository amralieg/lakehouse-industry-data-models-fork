-- Metric views for domain: rail | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rail_grade_crossing_safety`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Grade crossing safety performance metrics tracking accident rates, hazard indices, and improvement priorities for highway-rail crossings. Used by safety leadership to prioritize Section 130 funding and measure safety program effectiveness."
  source: "`feip_eastus_03`.`rail`.`grade_crossing`"
  dimensions:
    - name: "county"
      expr: county
      comment: "North Carolina county where the crossing is located"
    - name: "ncdot_division"
      expr: ncdot_division
      comment: "NCDOT administrative division responsible for the crossing"
    - name: "protection_type"
      expr: protection_type
      comment: "Type of warning device installed (gates with lights, flashing lights only, crossbucks, stop sign, other, none)"
    - name: "crossing_status"
      expr: crossing_status
      comment: "Current operational status (active, closed, abandoned, proposed)"
    - name: "road_classification"
      expr: road_classification
      comment: "Functional classification of the roadway (interstate, US highway, state highway, county road, city street, private road)"
    - name: "active_warning_device"
      expr: active_warning_device
      comment: "Indicates whether the crossing has active warning devices (gates, flashing lights)"
    - name: "section_130_eligible"
      expr: section_130_eligible
      comment: "Indicates whether the crossing is eligible for federal Section 130 Railway-Highway Crossings Program funding"
    - name: "improvement_project_planned"
      expr: improvement_project_planned
      comment: "Indicates whether a safety improvement project is planned or programmed for this crossing"
  measures:
    - name: "total_crossings"
      expr: COUNT(1)
      comment: "Total number of grade crossings in the inventory"
    - name: "total_accidents_5yr"
      expr: SUM(CAST(accident_count_5yr AS DOUBLE))
      comment: "Total number of reported accidents at crossings over the past five years"
    - name: "total_fatalities_5yr"
      expr: SUM(CAST(fatality_count_5yr AS DOUBLE))
      comment: "Total number of fatalities resulting from crossing accidents over the past five years"
    - name: "total_injuries_5yr"
      expr: SUM(CAST(injury_count_5yr AS DOUBLE))
      comment: "Total number of injuries resulting from crossing accidents over the past five years"
    - name: "accident_rate_per_crossing"
      expr: ROUND(SUM(CAST(accident_count_5yr AS DOUBLE)) / NULLIF(COUNT(1), 0), 3)
      comment: "Average number of accidents per crossing over the past five years - key safety performance indicator"
    - name: "fatality_rate_per_crossing"
      expr: ROUND(SUM(CAST(fatality_count_5yr AS DOUBLE)) / NULLIF(COUNT(1), 0), 3)
      comment: "Average number of fatalities per crossing over the past five years - critical safety metric"
    - name: "avg_hazard_index"
      expr: AVG(CAST(hazard_index AS DOUBLE))
      comment: "Average hazard index score used to prioritize crossing safety improvements based on traffic volume, train frequency, and accident history"
    - name: "crossings_with_accidents"
      expr: COUNT(CASE WHEN accident_count_5yr > 0 THEN 1 END)
      comment: "Number of crossings that have experienced at least one accident in the past five years"
    - name: "crossings_needing_improvement"
      expr: COUNT(CASE WHEN improvement_project_planned = true THEN 1 END)
      comment: "Number of crossings with planned or programmed safety improvement projects"
    - name: "pct_active_warning_devices"
      expr: ROUND(100.0 * COUNT(CASE WHEN active_warning_device = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of crossings equipped with active warning devices (gates, flashing lights) - key safety infrastructure metric"
    - name: "avg_daily_vehicle_exposure"
      expr: AVG(CAST(aadt AS DOUBLE))
      comment: "Average daily vehicle traffic volume across crossings - exposure metric for risk assessment"
    - name: "avg_daily_train_exposure"
      expr: AVG(CAST(train_count_per_day AS DOUBLE))
      comment: "Average number of trains per day across crossings - exposure metric for risk assessment"
    - name: "total_estimated_improvement_cost"
      expr: SUM(CAST(improvement_estimated_cost AS DOUBLE))
      comment: "Total estimated cost for all planned crossing safety improvements - capital planning metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rail_track_segment_condition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Track segment infrastructure condition and maintenance metrics tracking defects, inspection compliance, and asset lifecycle. Used by asset management and maintenance leadership to prioritize capital investment and ensure FRA regulatory compliance."
  source: "`feip_eastus_03`.`rail`.`track_segment`"
  dimensions:
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where the track segment is located"
    - name: "ncdot_division"
      expr: ncdot_division
      comment: "NCDOT highway division number for administrative coordination"
    - name: "track_type"
      expr: track_type
      comment: "Functional classification of the track segment (main line, siding, yard track, etc.)"
    - name: "status"
      expr: status
      comment: "Current operational status of the track segment"
    - name: "service_type"
      expr: service_type
      comment: "Type of rail service provided on the track segment"
    - name: "condition_rating"
      expr: condition_rating
      comment: "Overall condition assessment based on inspection findings and performance metrics"
    - name: "ownership_type"
      expr: ownership_type
      comment: "Classification of ownership structure for the track segment"
    - name: "hazmat_route"
      expr: hazmat_route
      comment: "Indicates whether the track segment is designated as a route for transporting hazardous materials"
    - name: "positive_train_control_equipped"
      expr: positive_train_control_equipped
      comment: "Indicates whether the track segment is equipped with Positive Train Control technology"
    - name: "speed_restriction_active"
      expr: speed_restriction_active
      comment: "Indicates whether temporary speed restrictions are currently in effect due to track conditions"
  measures:
    - name: "total_track_segments"
      expr: COUNT(1)
      comment: "Total number of track segments in the rail network inventory"
    - name: "total_track_miles"
      expr: SUM(CAST(segment_length_miles AS DOUBLE))
      comment: "Total miles of track in the rail network - key infrastructure capacity metric"
    - name: "avg_segment_length_miles"
      expr: AVG(CAST(segment_length_miles AS DOUBLE))
      comment: "Average length of track segments in miles"
    - name: "total_defects"
      expr: SUM(CAST(defect_count AS DOUBLE))
      comment: "Total number of track defects identified requiring monitoring or remediation"
    - name: "total_critical_defects"
      expr: SUM(CAST(critical_defect_count AS DOUBLE))
      comment: "Total number of critical track defects requiring immediate remediation or speed restrictions - safety priority metric"
    - name: "defect_rate_per_mile"
      expr: ROUND(SUM(CAST(defect_count AS DOUBLE)) / NULLIF(SUM(CAST(segment_length_miles AS DOUBLE)), 0), 2)
      comment: "Average number of defects per track mile - key maintenance performance indicator"
    - name: "critical_defect_rate_per_mile"
      expr: ROUND(SUM(CAST(critical_defect_count AS DOUBLE)) / NULLIF(SUM(CAST(segment_length_miles AS DOUBLE)), 0), 3)
      comment: "Average number of critical defects per track mile - critical safety metric for prioritizing urgent repairs"
    - name: "segments_with_speed_restrictions"
      expr: COUNT(CASE WHEN speed_restriction_active = true THEN 1 END)
      comment: "Number of track segments currently under temporary speed restrictions - operational impact metric"
    - name: "pct_segments_with_speed_restrictions"
      expr: ROUND(100.0 * COUNT(CASE WHEN speed_restriction_active = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of track segments under temporary speed restrictions - network reliability indicator"
    - name: "total_grade_crossings"
      expr: SUM(CAST(crossing_count AS DOUBLE))
      comment: "Total number of highway-rail grade crossings across all track segments"
    - name: "total_bridges"
      expr: SUM(CAST(bridge_count AS DOUBLE))
      comment: "Total number of railroad bridges across all track segments"
    - name: "avg_annual_traffic_density_mgt"
      expr: AVG(CAST(annual_traffic_density_mgt AS DOUBLE))
      comment: "Average annual tonnage in million gross tons across track segments - utilization metric"
    - name: "total_replacement_cost"
      expr: SUM(CAST(replacement_cost_estimate AS DOUBLE))
      comment: "Total estimated cost to replace all track segments with equivalent new infrastructure - capital planning metric"
    - name: "avg_remaining_life_years"
      expr: AVG(CAST(estimated_remaining_life_years AS DOUBLE))
      comment: "Average estimated years remaining before track segments require major rehabilitation or replacement - asset lifecycle metric"
    - name: "pct_ptc_equipped"
      expr: ROUND(100.0 * COUNT(CASE WHEN positive_train_control_equipped = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of track segments equipped with Positive Train Control technology - federal mandate compliance metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rail_track_inspection_compliance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Track inspection compliance and defect discovery metrics tracking inspection frequency, compliance status, and defect identification rates. Used by safety and compliance leadership to ensure FRA regulatory compliance and prioritize remediation efforts."
  source: "`feip_eastus_03`.`rail`.`track_inspection`"
  dimensions:
    - name: "inspection_type"
      expr: inspection_type
      comment: "Type of inspection performed (geometry, rail condition, tie condition, etc.)"
    - name: "compliance_status"
      expr: compliance_status
      comment: "Compliance status of the track segment based on inspection findings"
    - name: "corrective_action_required"
      expr: corrective_action_required
      comment: "Indicates whether corrective action is required based on inspection findings"
    - name: "priority"
      expr: priority
      comment: "Priority level for addressing defects found on the track segment"
    - name: "inspection_year"
      expr: YEAR(inspection_date)
      comment: "Year when the inspection was performed"
    - name: "inspection_month"
      expr: DATE_TRUNC('MONTH', inspection_date)
      comment: "Month when the inspection was performed"
  measures:
    - name: "total_inspections"
      expr: COUNT(1)
      comment: "Total number of track segment inspections performed"
    - name: "total_defects_found"
      expr: SUM(CAST(defects_found AS DOUBLE))
      comment: "Total number of defects identified across all inspections"
    - name: "avg_defects_per_inspection"
      expr: ROUND(SUM(CAST(defects_found AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average number of defects found per inspection - defect discovery rate metric"
    - name: "inspections_requiring_action"
      expr: COUNT(CASE WHEN corrective_action_required = true THEN 1 END)
      comment: "Number of inspections that identified defects requiring corrective action"
    - name: "pct_inspections_requiring_action"
      expr: ROUND(100.0 * COUNT(CASE WHEN corrective_action_required = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections requiring corrective action - maintenance demand indicator"
    - name: "compliant_inspections"
      expr: COUNT(CASE WHEN compliance_status = 'Compliant' THEN 1 END)
      comment: "Number of inspections where track segment met compliance standards"
    - name: "pct_compliant_inspections"
      expr: ROUND(100.0 * COUNT(CASE WHEN compliance_status = 'Compliant' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of inspections meeting compliance standards - regulatory compliance metric"
    - name: "high_priority_inspections"
      expr: COUNT(CASE WHEN priority = 'High' THEN 1 END)
      comment: "Number of inspections identifying high-priority defects requiring urgent attention"
    - name: "unique_track_segments_inspected"
      expr: COUNT(DISTINCT track_segment_id)
      comment: "Number of unique track segments that underwent inspection"
    - name: "avg_inspection_segment_length_miles"
      expr: AVG(CAST(segment_end_milepost AS DOUBLE) - CAST(segment_start_milepost AS DOUBLE))
      comment: "Average length of track segment inspected per inspection event in miles"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rail_train_movement_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Real-time train movement operational performance metrics tracking delays, speed compliance, and operational efficiency. Used by operations leadership to monitor service reliability, identify bottlenecks, and optimize dispatching decisions."
  source: "`feip_eastus_03`.`rail`.`train_movement`"
  dimensions:
    - name: "train_type"
      expr: train_type
      comment: "Classification of the train based on its primary operational purpose"
    - name: "operational_status"
      expr: operational_status
      comment: "Current operational state of the train at the time of the movement event"
    - name: "direction"
      expr: direction
      comment: "Cardinal direction in which the train is traveling"
    - name: "hazmat_indicator"
      expr: hazmat_indicator
      comment: "Indicates whether the train is carrying hazardous materials"
    - name: "delay_reason_code"
      expr: delay_reason_code
      comment: "Standardized code indicating the primary cause of any delay"
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where the train movement event occurred"
    - name: "ncdot_rail_division_region"
      expr: ncdot_rail_division_region
      comment: "NCDOT Rail Division administrative region responsible for oversight"
    - name: "movement_date"
      expr: movement_date
      comment: "Calendar date of the train movement event"
    - name: "movement_month"
      expr: DATE_TRUNC('MONTH', movement_date)
      comment: "Month of the train movement event"
  measures:
    - name: "total_movements"
      expr: COUNT(1)
      comment: "Total number of train movement events recorded"
    - name: "unique_trains"
      expr: COUNT(DISTINCT train_identifier)
      comment: "Number of unique trains tracked during the period"
    - name: "avg_speed_mph"
      expr: AVG(CAST(speed_mph AS DOUBLE))
      comment: "Average train speed in miles per hour across all movement events"
    - name: "avg_authorized_speed_mph"
      expr: AVG(CAST(authorized_speed_mph AS DOUBLE))
      comment: "Average maximum authorized speed across all movement events"
    - name: "avg_train_length_feet"
      expr: AVG(CAST(train_length_feet AS DOUBLE))
      comment: "Average train consist length in feet"
    - name: "avg_car_count"
      expr: AVG(CAST(car_count AS DOUBLE))
      comment: "Average number of railcars per train consist"
    - name: "avg_gross_tonnage"
      expr: AVG(CAST(gross_tonnage AS DOUBLE))
      comment: "Average total weight of trains including locomotives, cars, and cargo in tons"
    - name: "total_delay_minutes"
      expr: SUM(CAST(delay_minutes AS DOUBLE))
      comment: "Total minutes of delay across all train movements - key operational performance metric"
    - name: "avg_delay_minutes"
      expr: AVG(CAST(delay_minutes AS DOUBLE))
      comment: "Average delay in minutes per train movement - service reliability indicator"
    - name: "movements_with_delays"
      expr: COUNT(CASE WHEN delay_minutes > 0 THEN 1 END)
      comment: "Number of train movements experiencing delays"
    - name: "pct_movements_delayed"
      expr: ROUND(100.0 * COUNT(CASE WHEN delay_minutes > 0 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of train movements experiencing delays - on-time performance metric"
    - name: "movements_with_hazmat"
      expr: COUNT(CASE WHEN hazmat_indicator = true THEN 1 END)
      comment: "Number of train movements carrying hazardous materials"
    - name: "pct_movements_with_hazmat"
      expr: ROUND(100.0 * COUNT(CASE WHEN hazmat_indicator = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of train movements carrying hazardous materials - safety monitoring metric"
    - name: "movements_with_speed_restrictions"
      expr: COUNT(CASE WHEN temporary_speed_restriction_indicator = true THEN 1 END)
      comment: "Number of train movements operating under temporary speed restrictions"
    - name: "pct_movements_with_speed_restrictions"
      expr: ROUND(100.0 * COUNT(CASE WHEN temporary_speed_restriction_indicator = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of train movements under temporary speed restrictions - network constraint indicator"
    - name: "avg_fuel_level_gallons"
      expr: AVG(CAST(fuel_level_gallons AS DOUBLE))
      comment: "Average fuel level in lead locomotives measured in gallons"
    - name: "avg_fuel_consumption_rate_gph"
      expr: AVG(CAST(fuel_consumption_rate_gph AS DOUBLE))
      comment: "Average fuel consumption rate in gallons per hour - operational efficiency metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rail_rail_operator_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rail operator safety, operational, and financial performance metrics tracking accident rates, service levels, and infrastructure utilization. Used by executive leadership to evaluate operator performance, allocate state subsidies, and ensure regulatory compliance."
  source: "`feip_eastus_03`.`rail`.`operator`"
  dimensions:
    - name: "operator_name"
      expr: name
      comment: "Full legal name of the rail operator"
    - name: "operator_type"
      expr: type
      comment: "Classification of the rail operator (freight carrier, passenger carrier, commuter rail, tourist/excursion, switching/terminal)"
    - name: "operator_class"
      expr: class
      comment: "FRA classification based on annual operating revenue (Class I, Class II, Class III regional/shortline)"
    - name: "status"
      expr: status
      comment: "Current operational status of the rail operator authorization in North Carolina"
    - name: "headquarters_state"
      expr: headquarters_state
      comment: "Two-letter state code for the rail operator headquarters location"
    - name: "safety_certification_status"
      expr: safety_certification_status
      comment: "Current status of operator safety certification and FRA compliance"
    - name: "passenger_service_flag"
      expr: passenger_service_flag
      comment: "Indicates whether the operator provides passenger rail service"
    - name: "freight_service_flag"
      expr: freight_service_flag
      comment: "Indicates whether the operator provides freight rail service"
    - name: "state_subsidy_recipient_flag"
      expr: state_subsidy_recipient_flag
      comment: "Indicates whether the operator receives state funding or subsidies"
    - name: "positive_train_control_equipped_flag"
      expr: positive_train_control_equipped_flag
      comment: "Indicates whether the operator has implemented Positive Train Control safety technology"
  measures:
    - name: "total_operators"
      expr: COUNT(1)
      comment: "Total number of rail operators authorized to operate on North Carolina rail network"
    - name: "total_track_miles_operated"
      expr: SUM(CAST(track_miles_operated AS DOUBLE))
      comment: "Total miles of track operated by all rail operators within North Carolina"
    - name: "avg_track_miles_per_operator"
      expr: AVG(CAST(track_miles_operated AS DOUBLE))
      comment: "Average miles of track operated per rail operator"
    - name: "total_annual_revenue"
      expr: SUM(CAST(annual_revenue_amount AS DOUBLE))
      comment: "Total annual operating revenue across all rail operators - economic impact metric"
    - name: "avg_annual_revenue_per_operator"
      expr: AVG(CAST(annual_revenue_amount AS DOUBLE))
      comment: "Average annual operating revenue per rail operator"
    - name: "total_employees"
      expr: SUM(CAST(employee_count AS DOUBLE))
      comment: "Total number of employees working for all rail operators - employment impact metric"
    - name: "total_locomotives"
      expr: SUM(CAST(locomotive_count AS DOUBLE))
      comment: "Total number of locomotives owned or operated by all rail operators"
    - name: "total_railcars"
      expr: SUM(CAST(railcar_count AS DOUBLE))
      comment: "Total number of railcars owned or operated by all rail operators"
    - name: "avg_accident_rate_per_million_miles"
      expr: AVG(CAST(accident_rate_per_million_miles AS DOUBLE))
      comment: "Average reportable accidents per million train miles operated - key safety performance indicator"
    - name: "operators_with_ptc"
      expr: COUNT(CASE WHEN positive_train_control_equipped_flag = true THEN 1 END)
      comment: "Number of operators that have implemented Positive Train Control technology"
    - name: "pct_operators_with_ptc"
      expr: ROUND(100.0 * COUNT(CASE WHEN positive_train_control_equipped_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of operators with Positive Train Control - federal mandate compliance metric"
    - name: "operators_receiving_state_subsidy"
      expr: COUNT(CASE WHEN state_subsidy_recipient_flag = true THEN 1 END)
      comment: "Number of operators receiving state funding or subsidies"
    - name: "pct_operators_receiving_state_subsidy"
      expr: ROUND(100.0 * COUNT(CASE WHEN state_subsidy_recipient_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of operators receiving state subsidies - public investment metric"
    - name: "passenger_service_operators"
      expr: COUNT(CASE WHEN passenger_service_flag = true THEN 1 END)
      comment: "Number of operators providing passenger rail service"
    - name: "freight_service_operators"
      expr: COUNT(CASE WHEN freight_service_flag = true THEN 1 END)
      comment: "Number of operators providing freight rail service"
    - name: "avg_insurance_coverage_amount"
      expr: AVG(CAST(insurance_coverage_amount AS DOUBLE))
      comment: "Average liability insurance coverage amount maintained by rail operators"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rail_train_schedule_reliability`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Train schedule service reliability and operational planning metrics tracking service frequency, capacity utilization, and on-time performance targets. Used by operations and planning leadership to optimize service delivery and measure customer-facing performance."
  source: "`feip_eastus_03`.`rail`.`train_schedule`"
  dimensions:
    - name: "train_name"
      expr: train_name
      comment: "Descriptive name or designation of the train service"
    - name: "service_type"
      expr: service_type
      comment: "Classification of the train service (passenger, freight, or other operational purposes)"
    - name: "service_category"
      expr: service_category
      comment: "Subcategory of passenger service indicating scope and stopping pattern"
    - name: "origin_state"
      expr: origin_state
      comment: "Two-letter state abbreviation for the origin station location"
    - name: "destination_state"
      expr: destination_state
      comment: "Two-letter state abbreviation for the destination station location"
    - name: "schedule_status"
      expr: schedule_status
      comment: "Current operational status of the train schedule"
    - name: "operating_days"
      expr: operating_days
      comment: "Days of the week on which this train service operates"
    - name: "positive_train_control_equipped"
      expr: positive_train_control_equipped
      comment: "Indicates whether the train is equipped with Positive Train Control safety technology"
    - name: "hazmat_authorized"
      expr: hazmat_authorized
      comment: "Indicates whether the train is authorized to transport hazardous materials"
    - name: "subsidy_required"
      expr: subsidy_required
      comment: "Indicates whether this train service requires public subsidy to operate"
    - name: "seasonal_service"
      expr: seasonal_service
      comment: "Indicates whether this train service operates only during specific seasons"
  measures:
    - name: "total_scheduled_services"
      expr: COUNT(1)
      comment: "Total number of scheduled train services in the system"
    - name: "total_route_miles"
      expr: SUM(CAST(route_distance_miles AS DOUBLE))
      comment: "Total distance in miles of all rail routes from origin to destination"
    - name: "avg_route_distance_miles"
      expr: AVG(CAST(route_distance_miles AS DOUBLE))
      comment: "Average distance in miles of rail routes"
    - name: "avg_scheduled_duration_minutes"
      expr: AVG(CAST(scheduled_duration_minutes AS DOUBLE))
      comment: "Average scheduled travel time in minutes from origin to destination"
    - name: "total_passenger_capacity"
      expr: SUM(CAST(passenger_capacity AS DOUBLE))
      comment: "Total number of passenger seats available across all passenger train services"
    - name: "avg_passenger_capacity_per_train"
      expr: AVG(CAST(passenger_capacity AS DOUBLE))
      comment: "Average number of passenger seats per train service"
    - name: "total_freight_capacity_tons"
      expr: SUM(CAST(freight_capacity_tons AS DOUBLE))
      comment: "Total freight carrying capacity in tons across all freight train services"
    - name: "avg_on_time_performance_target_pct"
      expr: AVG(CAST(on_time_performance_target_pct AS DOUBLE))
      comment: "Average target percentage for on-time performance across all train services - service reliability goal"
    - name: "avg_service_frequency_per_day"
      expr: AVG(CAST(service_frequency_per_day AS DOUBLE))
      comment: "Average number of times train services operate per day on specified routes"
    - name: "services_requiring_subsidy"
      expr: COUNT(CASE WHEN subsidy_required = true THEN 1 END)
      comment: "Number of train services requiring public subsidy to operate"
    - name: "pct_services_requiring_subsidy"
      expr: ROUND(100.0 * COUNT(CASE WHEN subsidy_required = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of train services requiring public subsidy - financial sustainability metric"
    - name: "avg_operating_cost_per_mile"
      expr: AVG(CAST(operating_cost_per_mile AS DOUBLE))
      comment: "Average operating cost in dollars per mile for train services - cost efficiency metric"
    - name: "avg_fare_revenue_per_trip"
      expr: AVG(CAST(fare_revenue_per_trip AS DOUBLE))
      comment: "Average fare revenue collected per trip for passenger services - revenue performance metric"
    - name: "services_with_ptc"
      expr: COUNT(CASE WHEN positive_train_control_equipped = true THEN 1 END)
      comment: "Number of train services equipped with Positive Train Control safety technology"
    - name: "pct_services_with_ptc"
      expr: ROUND(100.0 * COUNT(CASE WHEN positive_train_control_equipped = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of train services with Positive Train Control - safety compliance metric"
    - name: "avg_crew_size"
      expr: AVG(CAST(crew_size AS DOUBLE))
      comment: "Average number of crew members assigned to operate and service trains"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rail_track_structure_lifecycle`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Track structure asset lifecycle and condition metrics tracking inspection compliance, remaining useful life, and capital replacement needs. Used by asset management and capital planning leadership to prioritize infrastructure investment and ensure structural safety."
  source: "`feip_eastus_03`.`rail`.`track_structure`"
  dimensions:
    - name: "structure_type"
      expr: structure_type
      comment: "Classification of the track-related structure (bridge, tunnel, signal cabinet, etc.)"
    - name: "county"
      expr: county
      comment: "North Carolina county where the track structure is located"
    - name: "ncdot_division"
      expr: ncdot_division
      comment: "NCDOT administrative division responsible for oversight"
    - name: "condition_rating"
      expr: condition_rating
      comment: "Overall structural condition assessment based on inspection findings"
    - name: "operational_status"
      expr: operational_status
      comment: "Current operational state of the structure"
    - name: "ownership_type"
      expr: ownership_type
      comment: "Classification of the entity type that owns the structure"
    - name: "maintenance_priority"
      expr: maintenance_priority
      comment: "Priority level assigned for maintenance or repair activities"
    - name: "load_restriction_flag"
      expr: load_restriction_flag
      comment: "Indicator of whether load restrictions are currently in effect"
    - name: "critical_deficiency_flag"
      expr: critical_deficiency_flag
      comment: "Indicator of whether critical safety deficiencies were identified"
    - name: "scour_critical_flag"
      expr: scour_critical_flag
      comment: "Indicator of whether the structure is classified as scour-critical requiring enhanced monitoring"
    - name: "fracture_critical_flag"
      expr: fracture_critical_flag
      comment: "Indicator of whether the structure contains fracture-critical members requiring specialized inspection"
  measures:
    - name: "total_structures"
      expr: COUNT(1)
      comment: "Total number of track-related structures in the rail infrastructure catalog"
    - name: "total_structure_length_feet"
      expr: SUM(CAST(length_feet AS DOUBLE))
      comment: "Total length of all structures measured in feet"
    - name: "total_deck_area_square_feet"
      expr: SUM(CAST(deck_area_square_feet AS DOUBLE))
      comment: "Total surface area of all structure decks measured in square feet"
    - name: "avg_structure_age_years"
      expr: AVG(YEAR(CURRENT_DATE()) - CAST(construction_year AS DOUBLE))
      comment: "Average age of structures in years since original construction"
    - name: "avg_remaining_useful_life_years"
      expr: AVG(CAST(remaining_useful_life_years AS DOUBLE))
      comment: "Average estimated years remaining before structures require major rehabilitation or replacement - asset lifecycle metric"
    - name: "total_replacement_cost"
      expr: SUM(CAST(replacement_cost_estimate AS DOUBLE))
      comment: "Total estimated cost to replace all structures with functionally equivalent new structures - capital planning metric"
    - name: "avg_replacement_cost_per_structure"
      expr: AVG(CAST(replacement_cost_estimate AS DOUBLE))
      comment: "Average estimated replacement cost per structure"
    - name: "total_annual_maintenance_cost"
      expr: SUM(CAST(annual_maintenance_cost AS DOUBLE))
      comment: "Total average annual cost for routine maintenance and upkeep of all structures - operating budget metric"
    - name: "avg_annual_maintenance_cost_per_structure"
      expr: AVG(CAST(annual_maintenance_cost AS DOUBLE))
      comment: "Average annual maintenance cost per structure"
    - name: "avg_condition_score"
      expr: AVG(CAST(condition_score AS DOUBLE))
      comment: "Average numerical condition score on a standardized scale (0-100) - asset health indicator"
    - name: "total_deficiencies"
      expr: SUM(CAST(deficiency_count AS DOUBLE))
      comment: "Total number of deficiencies or issues identified across all structures"
    - name: "avg_deficiencies_per_structure"
      expr: ROUND(SUM(CAST(deficiency_count AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average number of deficiencies per structure - maintenance demand indicator"
    - name: "structures_with_critical_deficiencies"
      expr: COUNT(CASE WHEN critical_deficiency_flag = true THEN 1 END)
      comment: "Number of structures with critical safety deficiencies requiring immediate attention"
    - name: "pct_structures_with_critical_deficiencies"
      expr: ROUND(100.0 * COUNT(CASE WHEN critical_deficiency_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of structures with critical safety deficiencies - safety priority metric"
    - name: "structures_with_load_restrictions"
      expr: COUNT(CASE WHEN load_restriction_flag = true THEN 1 END)
      comment: "Number of structures currently under load restrictions"
    - name: "pct_structures_with_load_restrictions"
      expr: ROUND(100.0 * COUNT(CASE WHEN load_restriction_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of structures under load restrictions - operational constraint indicator"
    - name: "scour_critical_structures"
      expr: COUNT(CASE WHEN scour_critical_flag = true THEN 1 END)
      comment: "Number of structures classified as scour-critical requiring enhanced monitoring"
    - name: "fracture_critical_structures"
      expr: COUNT(CASE WHEN fracture_critical_flag = true THEN 1 END)
      comment: "Number of structures containing fracture-critical members requiring specialized inspection"
    - name: "avg_annual_traffic_mgt"
      expr: AVG(CAST(annual_million_gross_tons AS DOUBLE))
      comment: "Average annual freight tonnage passing over structures measured in millions of gross tons - utilization metric"
$$;