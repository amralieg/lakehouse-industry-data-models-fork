-- Metric views for domain: traffic | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`traffic_alert`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Traffic alert performance metrics tracking incident response effectiveness, public notification reach, and operational impact on the transportation network."
  source: "`feip_eastus_03`.`traffic`.`alert`"
  dimensions:
    - name: "severity_level"
      expr: severity_level
      comment: "Traffic impact severity classification (low, moderate, major, critical) used to prioritize response and resource allocation."
    - name: "status"
      expr: status
      comment: "Current lifecycle status of the alert (active, resolved, cleared) for operational tracking."
    - name: "county"
      expr: county
      comment: "North Carolina county where the alert is located for geographic analysis and resource deployment."
    - name: "route_name"
      expr: route_name
      comment: "Roadway route designation (I-40, US-1, NC-55) for corridor-level impact analysis."
    - name: "direction"
      expr: direction
      comment: "Direction of travel affected by the alert for directional traffic management."
    - name: "source"
      expr: source
      comment: "Origin of the alert (TMC operator, IMAP patrol, automated detection) for data quality and response time analysis."
    - name: "verification_status"
      expr: verification_status
      comment: "Confirmation status of the alert (verified, unverified) for accuracy tracking."
    - name: "priority"
      expr: priority
      comment: "Priority level assigned for TMC operator attention and public dissemination urgency."
    - name: "responding_agency"
      expr: responding_agency
      comment: "Primary agency responding to the incident for coordination and accountability tracking."
    - name: "weather_condition"
      expr: weather_condition
      comment: "Prevailing weather condition at the time of the alert for weather-related incident analysis."
    - name: "functional_class"
      expr: functional_class
      comment: "FHWA functional classification of the affected roadway for network criticality assessment."
    - name: "alert_year"
      expr: YEAR(start_timestamp)
      comment: "Year when the alert was first detected for annual trend analysis."
    - name: "alert_month"
      expr: DATE_TRUNC('MONTH', start_timestamp)
      comment: "Month when the alert was first detected for seasonal pattern analysis."
    - name: "alert_day_of_week"
      expr: DAYOFWEEK(start_timestamp)
      comment: "Day of week when the alert was first detected for weekly pattern analysis."
  measures:
    - name: "Total Alerts"
      expr: COUNT(1)
      comment: "Total number of traffic alerts issued by TMC for workload and incident frequency tracking."
    - name: "Avg Alert Duration Minutes"
      expr: AVG(CAST(expected_duration_minutes AS DOUBLE))
      comment: "Average expected duration of traffic alerts in minutes for incident clearance planning."
    - name: "Avg Delay Minutes"
      expr: AVG(CAST(delay_minutes AS DOUBLE))
      comment: "Average travel delay in minutes caused by traffic alerts for mobility impact assessment."
    - name: "Avg Lanes Closed"
      expr: AVG(CAST(lanes_closed_count AS DOUBLE))
      comment: "Average number of lanes closed per alert for capacity impact analysis."
    - name: "Mobile App Publication Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN published_to_mobile_app = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of alerts disseminated via mobile applications for public notification effectiveness tracking."
    - name: "Web Portal Publication Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN published_to_web_portal = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of alerts published to web portals for traveler information reach assessment."
    - name: "DMS Publication Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN published_to_dms = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of alerts displayed on Dynamic Message Signs for real-time roadside notification effectiveness."
    - name: "511 Publication Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN published_to_511 = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of alerts disseminated through NC 511 system for traveler information system coverage."
    - name: "Verified Alert Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN verification_status = 'verified' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of alerts confirmed by TMC operators or field personnel for data quality assessment."
    - name: "NHS Roadway Alert Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN nhs_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of alerts on National Highway System roadways for federal reporting and network criticality analysis."
    - name: "Detour Available Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN detour_available = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of alerts with available alternate routes for traffic management effectiveness."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`traffic_detector`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Traffic detector asset performance metrics tracking operational reliability, data quality, maintenance effectiveness, and lifecycle management for ITS infrastructure."
  source: "`feip_eastus_03`.`traffic`.`detector`"
  dimensions:
    - name: "detector_type"
      expr: type
      comment: "Technology type of the detection device (inductive loop, radar, video) for technology performance comparison."
    - name: "status"
      expr: status
      comment: "Current operational status of the detector (active, inactive, failed) for availability tracking."
    - name: "lane_type"
      expr: lane_type
      comment: "Functional classification of the monitored lane (mainline, ramp, HOV) for deployment analysis."
    - name: "direction"
      expr: direction
      comment: "Direction of traffic flow monitored for directional coverage assessment."
    - name: "mounting_type"
      expr: mounting_type
      comment: "Physical mounting method (in-pavement, overhead, side-mounted) for installation strategy analysis."
    - name: "communication_method"
      expr: communication_method
      comment: "Data transmission technology (fiber, wireless, cellular) for network infrastructure planning."
    - name: "ownership"
      expr: ownership
      comment: "Entity that owns the detector equipment for asset management and funding accountability."
    - name: "responsible_division"
      expr: responsible_division
      comment: "NCDOT division responsible for detector operations for regional performance tracking."
    - name: "atms_integration_status"
      expr: atms_integration_status
      comment: "Integration status with ATMS for centralized traffic management capability assessment."
    - name: "hpms_reporting_station"
      expr: CASE WHEN hpms_reporting_station = true THEN 'Yes' ELSE 'No' END
      comment: "Indicator of HPMS reporting station status for federal data submission compliance."
    - name: "installation_year"
      expr: YEAR(activation_date)
      comment: "Year when the detector was activated for age-based lifecycle analysis."
  measures:
    - name: "Total Detectors"
      expr: COUNT(1)
      comment: "Total number of traffic detectors deployed for network coverage assessment."
    - name: "Active Detector Count"
      expr: SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END)
      comment: "Number of operational detectors currently collecting data for availability tracking."
    - name: "Detector Availability Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of detectors in active operational status for system reliability assessment."
    - name: "Avg Uptime Percentage"
      expr: AVG(CAST(uptime_percentage AS DOUBLE))
      comment: "Average percentage of time detectors are operational and collecting data for reliability performance tracking."
    - name: "Avg Data Quality Score"
      expr: AVG(CAST(data_quality_score AS DOUBLE))
      comment: "Average quality score of detector data for data reliability and accuracy assessment."
    - name: "Avg Accuracy Rating Percent"
      expr: AVG(CAST(accuracy_rating_percent AS DOUBLE))
      comment: "Average accuracy rating of detector measurements for calibration effectiveness tracking."
    - name: "MTBF Days"
      expr: AVG(CAST(mean_time_between_failures_days AS DOUBLE))
      comment: "Mean time between failures in days for reliability engineering and maintenance planning."
    - name: "MTTR Hours"
      expr: AVG(CAST(mean_time_to_repair_hours AS DOUBLE))
      comment: "Mean time to repair in hours for maintenance efficiency and response time assessment."
    - name: "Total Acquisition Cost"
      expr: SUM(CAST(acquisition_cost AS DOUBLE))
      comment: "Total cost to acquire detector equipment for capital investment tracking."
    - name: "Total Installation Cost"
      expr: SUM(CAST(installation_cost AS DOUBLE))
      comment: "Total cost to install detectors for project cost analysis."
    - name: "Total Annual Maintenance Cost"
      expr: SUM(CAST(annual_maintenance_cost AS DOUBLE))
      comment: "Total annual maintenance cost for operational budget planning."
    - name: "Avg Annual Maintenance Cost Per Detector"
      expr: AVG(CAST(annual_maintenance_cost AS DOUBLE))
      comment: "Average annual maintenance cost per detector for cost efficiency benchmarking."
    - name: "ATMS Integration Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN atms_integration_status = 'integrated' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of detectors integrated with ATMS for centralized traffic management capability."
    - name: "TMC Monitoring Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN tmc_monitoring_enabled = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of detectors actively monitored by TMC for operational oversight coverage."
    - name: "HPMS Reporting Station Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN hpms_reporting_station = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of detectors serving as HPMS reporting stations for federal data submission compliance."
    - name: "Speed Measurement Capability Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN speed_measurement_capability = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of detectors with speed measurement capability for traffic performance monitoring."
    - name: "Vehicle Classification Capability Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN vehicle_classification_capability = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of detectors with vehicle classification capability for freight and truck traffic analysis."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`traffic_flow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Traffic flow performance metrics tracking volume, speed, congestion, and level of service for mobility analysis, capacity planning, and operational decision-making."
  source: "`feip_eastus_03`.`traffic`.`flow`"
  dimensions:
    - name: "route_type"
      expr: route_type
      comment: "Functional classification of the route (Interstate, Principal Arterial) for network performance comparison."
    - name: "direction"
      expr: direction
      comment: "Cardinal direction of traffic flow for directional analysis and capacity assessment."
    - name: "lane_type"
      expr: lane_type
      comment: "Functional classification of the lane (mainline, ramp, HOV) for lane-specific performance tracking."
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where measurement was taken for geographic performance analysis."
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT Division number responsible for the roadway segment for regional performance tracking."
    - name: "mpo_name"
      expr: mpo_name
      comment: "Metropolitan Planning Organization jurisdiction for urban mobility analysis."
    - name: "peak_period_indicator"
      expr: peak_period_indicator
      comment: "Peak travel period classification (AM peak, PM peak, off-peak) for time-of-day analysis."
    - name: "day_of_week"
      expr: day_of_week
      comment: "Day of the week for weekly traffic pattern analysis."
    - name: "congestion_level"
      expr: congestion_level
      comment: "Qualitative congestion assessment (free flow, moderate, heavy, severe) for operational monitoring."
    - name: "level_of_service"
      expr: level_of_service
      comment: "Highway Capacity Manual LOS grade (A-F) for traffic flow quality assessment."
    - name: "weather_condition"
      expr: weather_condition
      comment: "Prevailing weather condition for weather impact analysis on traffic flow."
    - name: "incident_indicator"
      expr: CASE WHEN incident_indicator = true THEN 'Yes' ELSE 'No' END
      comment: "Indicator of active traffic incident for incident impact analysis."
    - name: "work_zone_indicator"
      expr: CASE WHEN work_zone_indicator = true THEN 'Yes' ELSE 'No' END
      comment: "Indicator of active work zone for construction impact analysis."
    - name: "functional_class_code"
      expr: functional_class_code
      comment: "FHWA functional classification code for federal reporting and network analysis."
    - name: "nhs_indicator"
      expr: CASE WHEN nhs_indicator = true THEN 'Yes' ELSE 'No' END
      comment: "National Highway System designation for federal performance monitoring."
    - name: "measurement_year"
      expr: YEAR(measurement_date)
      comment: "Year of measurement for annual trend analysis."
    - name: "measurement_month"
      expr: DATE_TRUNC('MONTH', measurement_date)
      comment: "Month of measurement for seasonal pattern analysis."
    - name: "measurement_hour"
      expr: HOUR(measurement_timestamp)
      comment: "Hour of day for hourly traffic pattern analysis."
  measures:
    - name: "Total Flow Records"
      expr: COUNT(1)
      comment: "Total number of traffic flow measurement records for data coverage assessment."
    - name: "Total Vehicle Count"
      expr: SUM(CAST(vehicle_count AS DOUBLE))
      comment: "Total number of vehicles detected for traffic volume analysis."
    - name: "Avg Speed MPH"
      expr: AVG(CAST(average_speed_mph AS DOUBLE))
      comment: "Average vehicle speed in miles per hour for mobility and congestion assessment."
    - name: "Avg Occupancy Percent"
      expr: AVG(CAST(occupancy_percent AS DOUBLE))
      comment: "Average lane occupancy percentage for traffic density and congestion monitoring."
    - name: "Total Volume Per Hour"
      expr: SUM(CAST(volume_per_hour AS DOUBLE))
      comment: "Total traffic volume extrapolated to vehicles per hour for capacity utilization analysis."
    - name: "Avg Heavy Vehicle Percent"
      expr: AVG(CAST(heavy_vehicle_percent AS DOUBLE))
      comment: "Average percentage of heavy vehicles (trucks and buses) for freight traffic analysis."
    - name: "Avg Travel Time Index"
      expr: AVG(CAST(travel_time_index AS DOUBLE))
      comment: "Average ratio of actual to free-flow travel time for congestion severity assessment (1.0 = free flow)."
    - name: "Total VMT"
      expr: SUM(CAST(vmt_vehicle_miles_traveled AS DOUBLE))
      comment: "Total vehicle miles traveled for mobility and environmental impact analysis."
    - name: "Avg Density Vehicles Per Mile"
      expr: AVG(CAST(density_vehicles_per_mile AS DOUBLE))
      comment: "Average traffic density in vehicles per mile for congestion and capacity analysis."
    - name: "Avg Data Quality Score"
      expr: AVG(CAST(data_quality_score AS DOUBLE))
      comment: "Average quality score of flow measurement data for data reliability assessment."
    - name: "Avg Data Completeness Percent"
      expr: AVG(CAST(data_completeness_percent AS DOUBLE))
      comment: "Average percentage of expected data points captured for data collection effectiveness."
    - name: "Congestion Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN congestion_level IN ('heavy', 'severe') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of measurements with heavy or severe congestion for congestion frequency tracking."
    - name: "LOS D or Worse Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN level_of_service IN ('D', 'E', 'F') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of measurements with LOS D or worse for performance monitoring and capacity planning."
    - name: "Incident Impact Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN incident_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of measurements affected by traffic incidents for incident impact assessment."
    - name: "Work Zone Impact Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN work_zone_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of measurements affected by work zones for construction impact analysis."
    - name: "Speed Compliance Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(average_speed_mph AS DOUBLE) <= CAST(speed_limit_mph AS DOUBLE) THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of measurements where average speed is at or below posted speed limit for safety and enforcement analysis."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`traffic_signal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Traffic signal asset performance metrics tracking operational status, maintenance effectiveness, technology deployment, and safety outcomes for intersection management and capital planning."
  source: "`feip_eastus_03`.`traffic`.`signal`"
  dimensions:
    - name: "operational_status"
      expr: operational_status
      comment: "Current operational state of the signal controller (normal, flash, dark, maintenance, failed) for availability tracking."
    - name: "communication_status"
      expr: communication_status
      comment: "Status of communication link with TMC or ATMS for connectivity monitoring."
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where the signal is located for geographic analysis."
    - name: "municipality_name"
      expr: municipality_name
      comment: "City or town jurisdiction for municipal coordination and funding analysis."
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT Division responsible for the signal for regional performance tracking."
    - name: "ownership_type"
      expr: ownership_type
      comment: "Entity that owns the signal infrastructure (NCDOT, municipal, private) for asset management."
    - name: "maintenance_responsibility"
      expr: maintenance_responsibility
      comment: "Entity responsible for signal maintenance for accountability and cost allocation."
    - name: "functional_classification"
      expr: functional_classification
      comment: "FHWA functional classification of the primary roadway for network criticality assessment."
    - name: "nhs_designation"
      expr: CASE WHEN nhs_designation = true THEN 'Yes' ELSE 'No' END
      comment: "National Highway System designation for federal performance monitoring."
    - name: "atms_integration_enabled"
      expr: CASE WHEN atms_integration_enabled = true THEN 'Yes' ELSE 'No' END
      comment: "ATMS integration status for centralized traffic management capability."
    - name: "tmc_monitored"
      expr: CASE WHEN tmc_monitored = true THEN 'Yes' ELSE 'No' END
      comment: "TMC monitoring status for operational oversight coverage."
    - name: "preemption_type"
      expr: preemption_type
      comment: "Type of preemption configured (none, EVP, RRP, both) for emergency response capability."
    - name: "transit_priority_enabled"
      expr: CASE WHEN transit_priority_enabled = true THEN 'Yes' ELSE 'No' END
      comment: "Transit signal priority status for public transportation support."
    - name: "detection_type"
      expr: detection_type
      comment: "Vehicle detection technology type for technology deployment analysis."
    - name: "led_conversion_complete"
      expr: CASE WHEN led_conversion_complete = true THEN 'Yes' ELSE 'No' END
      comment: "LED conversion status for energy efficiency and sustainability tracking."
    - name: "hsip_eligible"
      expr: CASE WHEN hsip_eligible = true THEN 'Yes' ELSE 'No' END
      comment: "Highway Safety Improvement Program eligibility for safety funding prioritization."
    - name: "asset_condition_rating"
      expr: asset_condition_rating
      comment: "Overall condition assessment for lifecycle management and replacement planning."
    - name: "installation_year"
      expr: YEAR(installation_date)
      comment: "Year of installation for age-based lifecycle analysis."
  measures:
    - name: "Total Signals"
      expr: COUNT(1)
      comment: "Total number of traffic signal controllers for network coverage assessment."
    - name: "Operational Signal Count"
      expr: SUM(CASE WHEN operational_status = 'normal' THEN 1 ELSE 0 END)
      comment: "Number of signals operating normally for availability tracking."
    - name: "Signal Availability Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN operational_status = 'normal' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals in normal operational status for system reliability assessment."
    - name: "Communication Success Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN communication_status = 'connected' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals with successful TMC/ATMS communication for connectivity performance."
    - name: "ATMS Integration Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN atms_integration_enabled = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals integrated with ATMS for centralized traffic management capability."
    - name: "TMC Monitoring Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN tmc_monitored = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals actively monitored by TMC for operational oversight coverage."
    - name: "LED Conversion Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN led_conversion_complete = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals with complete LED conversion for energy efficiency and sustainability tracking."
    - name: "Preemption Enabled Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN preemption_enabled = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals with emergency vehicle or railroad preemption for emergency response capability."
    - name: "Transit Priority Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN transit_priority_enabled = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals with transit signal priority for public transportation support."
    - name: "Pedestrian Phase Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN pedestrian_phases_enabled = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals with pedestrian phases for pedestrian safety and accessibility."
    - name: "APS Installation Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN aps_installed = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals with Accessible Pedestrian Signals for ADA compliance and accessibility."
    - name: "HSIP Eligible Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN hsip_eligible = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of signals eligible for Highway Safety Improvement Program funding for safety investment prioritization."
    - name: "Total Installation Cost"
      expr: SUM(CAST(installation_cost_amount AS DOUBLE))
      comment: "Total cost for signal installation for capital investment tracking."
    - name: "Total Annual Maintenance Cost"
      expr: SUM(CAST(annual_maintenance_cost_amount AS DOUBLE))
      comment: "Total annual maintenance cost for operational budget planning."
    - name: "Avg Annual Maintenance Cost Per Signal"
      expr: AVG(CAST(annual_maintenance_cost_amount AS DOUBLE))
      comment: "Average annual maintenance cost per signal for cost efficiency benchmarking."
    - name: "Avg Replacement Priority Score"
      expr: AVG(CAST(replacement_priority_score AS DOUBLE))
      comment: "Average replacement priority score for capital planning and asset lifecycle management."
    - name: "Avg Crash History 3yr"
      expr: AVG(CAST(crash_history_3yr_count AS DOUBLE))
      comment: "Average number of crashes at signalized intersections over 3 years for safety performance assessment."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`traffic_toll_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Toll transaction revenue and operational metrics tracking collection performance, payment methods, violation rates, and customer service for toll facility financial management and operational optimization."
  source: "`feip_eastus_03`.`traffic`.`toll_transaction`"
  dimensions:
    - name: "route_name"
      expr: route_name
      comment: "Common name of the toll route or facility for route-level revenue analysis."
    - name: "toll_plaza_name"
      expr: toll_plaza_name
      comment: "Business name of the toll plaza for plaza-level performance tracking."
    - name: "lane_type"
      expr: lane_type
      comment: "Type of toll collection lane (electronic, manual, mixed mode) for lane efficiency analysis."
    - name: "direction"
      expr: direction
      comment: "Direction of travel for directional revenue and volume analysis."
    - name: "vehicle_class"
      expr: vehicle_class
      comment: "Vehicle classification code (Class 1-9) for rate structure and revenue analysis."
    - name: "transaction_type"
      expr: transaction_type
      comment: "Type of toll transaction (revenue, violation, adjustment) for operational categorization."
    - name: "transponder_agency"
      expr: transponder_agency
      comment: "Agency that issued the transponder for interoperability and reciprocity analysis."
    - name: "time_of_day_period"
      expr: time_of_day_period
      comment: "Time period classification (peak, off-peak) for dynamic pricing and demand analysis."
    - name: "revenue_category"
      expr: revenue_category
      comment: "Revenue classification category for financial reporting and analysis."
    - name: "collection_status"
      expr: collection_status
      comment: "Current status of collection efforts for unpaid transactions for accounts receivable management."
    - name: "violation_flag"
      expr: CASE WHEN violation_flag = true THEN 'Yes' ELSE 'No' END
      comment: "Indicator of toll violation for violation rate tracking and enforcement analysis."
    - name: "violation_type"
      expr: violation_type
      comment: "Type of toll violation for violation pattern analysis and enforcement strategy."
    - name: "dynamic_pricing_flag"
      expr: CASE WHEN dynamic_pricing_flag = true THEN 'Yes' ELSE 'No' END
      comment: "Indicator of dynamic pricing application for congestion pricing effectiveness analysis."
    - name: "hov_eligible_flag"
      expr: CASE WHEN hov_eligible_flag = true THEN 'Yes' ELSE 'No' END
      comment: "Indicator of HOV eligibility for carpool incentive program analysis."
    - name: "exemption_flag"
      expr: CASE WHEN exemption_flag = true THEN 'Yes' ELSE 'No' END
      comment: "Indicator of toll exemption for exemption policy impact analysis."
    - name: "dispute_flag"
      expr: CASE WHEN dispute_flag = true THEN 'Yes' ELSE 'No' END
      comment: "Indicator of customer dispute for customer service and dispute resolution tracking."
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year of transaction for annual financial reporting."
    - name: "fiscal_period"
      expr: fiscal_period
      comment: "Fiscal period (month) for monthly financial reporting."
    - name: "transaction_year"
      expr: YEAR(transaction_date)
      comment: "Year of transaction for annual trend analysis."
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month of transaction for seasonal pattern analysis."
    - name: "transaction_day_of_week"
      expr: DAYOFWEEK(transaction_date)
      comment: "Day of week for weekly traffic pattern analysis."
    - name: "transaction_hour"
      expr: HOUR(transaction_timestamp)
      comment: "Hour of day for hourly demand analysis."
  measures:
    - name: "Total Transactions"
      expr: COUNT(1)
      comment: "Total number of toll transactions for volume and throughput tracking."
    - name: "Total Toll Revenue"
      expr: SUM(CAST(total_amount AS DOUBLE))
      comment: "Total toll revenue collected including base toll, discounts, and surcharges for financial performance tracking."
    - name: "Total Base Toll Amount"
      expr: SUM(CAST(toll_amount AS DOUBLE))
      comment: "Total base toll amount before adjustments for rate structure analysis."
    - name: "Total Discount Amount"
      expr: SUM(CAST(discount_amount AS DOUBLE))
      comment: "Total discount amount applied for discount program cost analysis."
    - name: "Total Surcharge Amount"
      expr: SUM(CAST(surcharge_amount AS DOUBLE))
      comment: "Total surcharge amount collected for surcharge revenue tracking."
    - name: "Avg Transaction Amount"
      expr: AVG(CAST(total_amount AS DOUBLE))
      comment: "Average toll amount per transaction for pricing and revenue analysis."
    - name: "Avg Vehicle Speed MPH"
      expr: AVG(CAST(vehicle_speed AS DOUBLE))
      comment: "Average vehicle speed at toll point for throughput and safety analysis."
    - name: "Violation Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN violation_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of transactions that are toll violations for enforcement effectiveness and revenue leakage assessment."
    - name: "Electronic Payment Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN transponder_equipment_id IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of transactions using electronic toll collection for operational efficiency and customer convenience tracking."
    - name: "Dynamic Pricing Application Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN dynamic_pricing_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of transactions with dynamic pricing applied for congestion pricing program effectiveness."
    - name: "HOV Eligible Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN hov_eligible_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of transactions eligible for HOV discount for carpool incentive program participation."
    - name: "Exemption Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN exemption_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of transactions with toll exemption for exemption policy impact on revenue."
    - name: "Dispute Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN dispute_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of transactions disputed by customers for customer service quality and billing accuracy assessment."
    - name: "Image Capture Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN image_captured_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of transactions with photographic evidence captured for video tolling and violation enforcement capability."
    - name: "Total Distance Traveled Miles"
      expr: SUM(CAST(distance_traveled AS DOUBLE))
      comment: "Total distance traveled on toll facility for distance-based tolling analysis."
    - name: "Avg Trip Duration Minutes"
      expr: AVG(CAST(trip_duration_minutes AS DOUBLE))
      comment: "Average trip duration on toll facility for travel time and congestion analysis."
    - name: "Total Refund Amount"
      expr: SUM(CAST(refund_amount AS DOUBLE))
      comment: "Total amount refunded to customers for dispute resolution and customer service cost tracking."
$$;