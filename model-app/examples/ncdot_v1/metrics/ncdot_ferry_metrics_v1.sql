-- Metric views for domain: ferry | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`ferry_reservation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key reservation performance metrics tracking booking conversion, revenue, cancellation rates, and capacity utilization for ferry sailings."
  source: "`feip_eastus_03`.`ferry`.`reservation`"
  dimensions:
    - name: "route_code"
      expr: route_code
      comment: "Ferry route identifier for analyzing reservation patterns by route"
    - name: "departure_terminal_code"
      expr: departure_terminal_code
      comment: "Origin terminal for route-level demand analysis"
    - name: "arrival_terminal_code"
      expr: arrival_terminal_code
      comment: "Destination terminal for route-level demand analysis"
    - name: "reservation_status"
      expr: status
      comment: "Current reservation lifecycle status (confirmed, cancelled, completed, no-show)"
    - name: "vehicle_type"
      expr: vehicle_type
      comment: "Type of vehicle reserved (passenger-only, car, truck, RV, etc.)"
    - name: "booking_channel"
      expr: booking_channel
      comment: "Channel through which reservation was created (web, phone, mobile app, terminal)"
    - name: "payment_status"
      expr: payment_status
      comment: "Payment completion status for revenue recognition"
    - name: "reservation_type"
      expr: type
      comment: "Classification of reservation (standard, priority, commercial, emergency)"
    - name: "scheduled_departure_date"
      expr: CAST(scheduled_departure_time AS DATE)
      comment: "Date of scheduled sailing for time-series analysis"
    - name: "scheduled_departure_month"
      expr: DATE_TRUNC('MONTH', scheduled_departure_time)
      comment: "Month of scheduled sailing for seasonal trend analysis"
    - name: "booking_date"
      expr: CAST(created_timestamp AS DATE)
      comment: "Date reservation was created for lead time analysis"
    - name: "cancellation_reason"
      expr: cancellation_reason
      comment: "Reason code for cancelled reservations to identify improvement opportunities"
  measures:
    - name: "total_reservations"
      expr: COUNT(1)
      comment: "Total number of reservation records"
    - name: "confirmed_reservations"
      expr: COUNT(CASE WHEN status = 'confirmed' THEN 1 END)
      comment: "Number of confirmed reservations ready for boarding"
    - name: "cancelled_reservations"
      expr: COUNT(CASE WHEN status IN ('cancelled', 'cancelled by customer') THEN 1 END)
      comment: "Number of cancelled reservations indicating demand volatility"
    - name: "no_show_reservations"
      expr: COUNT(CASE WHEN status = 'no-show' THEN 1 END)
      comment: "Number of no-show reservations representing lost capacity utilization"
    - name: "cancellation_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN status IN ('cancelled', 'cancelled by customer') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reservations cancelled - key service quality and demand stability indicator"
    - name: "no_show_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN status = 'no-show' THEN 1 END) / NULLIF(COUNT(CASE WHEN status IN ('confirmed', 'no-show', 'completed') THEN 1 END), 0), 2)
      comment: "Percentage of confirmed reservations that resulted in no-show - capacity waste metric"
    - name: "total_fare_revenue"
      expr: SUM(CAST(fare_amount AS DOUBLE))
      comment: "Total fare revenue from all reservations in US dollars"
    - name: "confirmed_fare_revenue"
      expr: SUM(CASE WHEN status = 'confirmed' THEN CAST(fare_amount AS DOUBLE) ELSE 0 END)
      comment: "Revenue from confirmed reservations representing committed revenue"
    - name: "total_discount_amount"
      expr: SUM(CAST(discount_amount AS DOUBLE))
      comment: "Total discount amount applied across all reservations"
    - name: "total_refund_amount"
      expr: SUM(CAST(refund_amount AS DOUBLE))
      comment: "Total refund amount processed for cancelled reservations"
    - name: "avg_fare_per_reservation"
      expr: AVG(CAST(fare_amount AS DOUBLE))
      comment: "Average fare amount per reservation - pricing effectiveness indicator"
    - name: "discount_penetration_pct"
      expr: ROUND(100.0 * SUM(CAST(discount_amount AS DOUBLE)) / NULLIF(SUM(CAST(fare_amount AS DOUBLE) + CAST(discount_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of gross revenue given as discounts - pricing strategy metric"
    - name: "total_passengers_reserved"
      expr: SUM(CAST(passenger_count AS BIGINT))
      comment: "Total number of passengers across all reservations"
    - name: "avg_passengers_per_reservation"
      expr: AVG(CAST(passenger_count AS DOUBLE))
      comment: "Average number of passengers per reservation - group size indicator"
    - name: "total_vehicles_reserved"
      expr: COUNT(CASE WHEN vehicle_type IS NOT NULL AND vehicle_type != 'passenger-only' THEN 1 END)
      comment: "Total number of vehicle reservations excluding walk-on passengers"
    - name: "vehicle_reservation_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN vehicle_type IS NOT NULL AND vehicle_type != 'passenger-only' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reservations that include vehicles - capacity planning metric"
    - name: "avg_vehicle_length_feet"
      expr: AVG(CAST(vehicle_length_feet AS DOUBLE))
      comment: "Average vehicle length for capacity planning and deck space allocation"
    - name: "avg_booking_lead_time_days"
      expr: AVG(CAST(DATEDIFF(scheduled_departure_time, created_timestamp) AS DOUBLE))
      comment: "Average number of days between booking and scheduled departure - demand forecasting indicator"
    - name: "unique_passengers"
      expr: COUNT(DISTINCT passenger_id)
      comment: "Number of unique registered passengers making reservations - customer base size"
    - name: "reservations_with_special_needs"
      expr: COUNT(CASE WHEN special_needs_flag = true THEN 1 END)
      comment: "Number of reservations requiring ADA accommodations - accessibility service level"
    - name: "hazmat_reservations"
      expr: COUNT(CASE WHEN hazmat_flag = true THEN 1 END)
      comment: "Number of reservations carrying hazardous materials - safety and compliance metric"
    - name: "priority_boarding_reservations"
      expr: COUNT(CASE WHEN priority_boarding_flag = true THEN 1 END)
      comment: "Number of reservations with priority boarding status - service tier distribution"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`ferry_sailing_schedule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational performance metrics for scheduled ferry sailings including on-time performance, capacity utilization, fuel efficiency, and service reliability."
  source: "`feip_eastus_03`.`ferry`.`sailing_schedule`"
  dimensions:
    - name: "route_code"
      expr: route_code
      comment: "Ferry route identifier for route-level performance analysis"
    - name: "route_name"
      expr: route_name
      comment: "Full route name for reporting and dashboards"
    - name: "origin_terminal_code"
      expr: origin_terminal_code
      comment: "Departure terminal for terminal-level operations analysis"
    - name: "destination_terminal_code"
      expr: destination_terminal_code
      comment: "Arrival terminal for terminal-level operations analysis"
    - name: "sailing_status"
      expr: sailing_status
      comment: "Current operational status (scheduled, in-progress, completed, cancelled, delayed)"
    - name: "sailing_type"
      expr: sailing_type
      comment: "Classification of sailing (regular, extra, charter, maintenance)"
    - name: "service_day_type"
      expr: service_day_type
      comment: "Day classification (weekday, weekend, holiday) for demand pattern analysis"
    - name: "season_code"
      expr: season_code
      comment: "Operational season (summer, winter, peak) for seasonal performance comparison"
    - name: "vessel_id"
      expr: CAST(vessel_id AS STRING)
      comment: "Specific vessel assigned to sailing for vessel-level performance tracking"
    - name: "scheduled_departure_date"
      expr: scheduled_departure_date
      comment: "Date of scheduled departure for time-series analysis"
    - name: "scheduled_departure_month"
      expr: DATE_TRUNC('MONTH', scheduled_departure_time)
      comment: "Month of scheduled departure for monthly trend analysis"
    - name: "weather_condition_code"
      expr: weather_condition_code
      comment: "Weather conditions during sailing for weather impact analysis"
    - name: "cancellation_reason_code"
      expr: cancellation_reason_code
      comment: "Reason for sailing cancellation to identify service disruption patterns"
    - name: "delay_reason_code"
      expr: delay_reason_code
      comment: "Reason for sailing delay to identify operational bottlenecks"
    - name: "fuel_type"
      expr: fuel_type
      comment: "Type of fuel used for environmental and cost analysis"
  measures:
    - name: "total_scheduled_sailings"
      expr: COUNT(1)
      comment: "Total number of scheduled sailing instances"
    - name: "completed_sailings"
      expr: COUNT(CASE WHEN sailing_status = 'completed' THEN 1 END)
      comment: "Number of sailings successfully completed"
    - name: "cancelled_sailings"
      expr: COUNT(CASE WHEN sailing_status = 'cancelled' THEN 1 END)
      comment: "Number of cancelled sailings indicating service disruptions"
    - name: "delayed_sailings"
      expr: COUNT(CASE WHEN sailing_status = 'delayed' OR delay_minutes > 0 THEN 1 END)
      comment: "Number of sailings experiencing delays"
    - name: "service_completion_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN sailing_status = 'completed' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of scheduled sailings completed - primary service reliability KPI"
    - name: "cancellation_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN sailing_status = 'cancelled' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of scheduled sailings cancelled - service disruption indicator"
    - name: "on_time_performance_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN delay_minutes = 0 OR delay_minutes IS NULL THEN 1 END) / NULLIF(COUNT(CASE WHEN sailing_status = 'completed' THEN 1 END), 0), 2)
      comment: "Percentage of completed sailings departing on time - operational efficiency KPI"
    - name: "avg_delay_minutes"
      expr: AVG(CAST(delay_minutes AS DOUBLE))
      comment: "Average delay duration in minutes for delayed sailings"
    - name: "total_delay_minutes"
      expr: SUM(CAST(delay_minutes AS DOUBLE))
      comment: "Total cumulative delay minutes across all sailings - operational cost indicator"
    - name: "total_vehicle_capacity"
      expr: SUM(CAST(vehicle_capacity AS BIGINT))
      comment: "Total vehicle capacity across all scheduled sailings"
    - name: "total_passenger_capacity"
      expr: SUM(CAST(passenger_capacity AS BIGINT))
      comment: "Total passenger capacity across all scheduled sailings"
    - name: "total_actual_vehicles"
      expr: SUM(CAST(actual_vehicle_count AS BIGINT))
      comment: "Total number of vehicles actually transported"
    - name: "total_actual_passengers"
      expr: SUM(CAST(actual_passenger_count AS BIGINT))
      comment: "Total number of passengers actually transported"
    - name: "vehicle_capacity_utilization_pct"
      expr: ROUND(100.0 * SUM(CAST(actual_vehicle_count AS DOUBLE)) / NULLIF(SUM(CAST(vehicle_capacity AS DOUBLE)), 0), 2)
      comment: "Percentage of vehicle capacity utilized - critical capacity planning and revenue optimization KPI"
    - name: "passenger_capacity_utilization_pct"
      expr: ROUND(100.0 * SUM(CAST(actual_passenger_count AS DOUBLE)) / NULLIF(SUM(CAST(passenger_capacity AS DOUBLE)), 0), 2)
      comment: "Percentage of passenger capacity utilized - service demand and capacity planning metric"
    - name: "avg_passengers_per_sailing"
      expr: AVG(CAST(actual_passenger_count AS DOUBLE))
      comment: "Average number of passengers per completed sailing"
    - name: "avg_vehicles_per_sailing"
      expr: AVG(CAST(actual_vehicle_count AS DOUBLE))
      comment: "Average number of vehicles per completed sailing"
    - name: "total_fuel_consumed_gallons"
      expr: SUM(CAST(fuel_consumption_gallons AS DOUBLE))
      comment: "Total fuel consumption across all sailings in gallons - operational cost driver"
    - name: "avg_fuel_per_sailing_gallons"
      expr: AVG(CAST(fuel_consumption_gallons AS DOUBLE))
      comment: "Average fuel consumption per sailing for efficiency benchmarking"
    - name: "fuel_efficiency_gallons_per_vehicle"
      expr: ROUND(SUM(CAST(fuel_consumption_gallons AS DOUBLE)) / NULLIF(SUM(CAST(actual_vehicle_count AS DOUBLE)), 0), 2)
      comment: "Fuel consumption per vehicle transported - operational efficiency metric"
    - name: "total_co2_emissions_kg"
      expr: SUM(CAST(emissions_co2_kg AS DOUBLE))
      comment: "Total carbon dioxide emissions in kilograms - environmental impact KPI"
    - name: "avg_co2_per_sailing_kg"
      expr: AVG(CAST(emissions_co2_kg AS DOUBLE))
      comment: "Average CO2 emissions per sailing for environmental performance tracking"
    - name: "co2_per_passenger_kg"
      expr: ROUND(SUM(CAST(emissions_co2_kg AS DOUBLE)) / NULLIF(SUM(CAST(actual_passenger_count AS DOUBLE)), 0), 2)
      comment: "CO2 emissions per passenger transported - sustainability efficiency metric"
    - name: "total_fare_revenue"
      expr: SUM(CAST(base_vehicle_fare_amount AS DOUBLE) * CAST(actual_vehicle_count AS DOUBLE) + CAST(base_passenger_fare_amount AS DOUBLE) * CAST(actual_passenger_count AS DOUBLE))
      comment: "Estimated total fare revenue from completed sailings based on base fares"
    - name: "avg_revenue_per_sailing"
      expr: AVG(CAST(base_vehicle_fare_amount AS DOUBLE) * CAST(actual_vehicle_count AS DOUBLE) + CAST(base_passenger_fare_amount AS DOUBLE) * CAST(actual_passenger_count AS DOUBLE))
      comment: "Average revenue per sailing for financial performance analysis"
    - name: "sailings_with_incidents"
      expr: COUNT(CASE WHEN incident_flag = true THEN 1 END)
      comment: "Number of sailings with safety or operational incidents"
    - name: "incident_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN incident_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sailings with incidents - safety performance KPI"
    - name: "ada_accessible_sailings"
      expr: COUNT(CASE WHEN ada_accessible_flag = true THEN 1 END)
      comment: "Number of sailings with ADA-compliant vessels"
    - name: "ada_accessibility_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN ada_accessible_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sailings meeting ADA accessibility requirements - compliance metric"
    - name: "total_ada_passengers"
      expr: SUM(CAST(ada_passenger_count AS BIGINT))
      comment: "Total number of passengers requiring ADA accommodations"
    - name: "total_hazmat_vehicles"
      expr: SUM(CAST(hazmat_vehicle_count AS BIGINT))
      comment: "Total number of vehicles carrying hazardous materials - safety and compliance tracking"
    - name: "avg_scheduled_duration_minutes"
      expr: AVG(CAST(scheduled_duration_minutes AS DOUBLE))
      comment: "Average scheduled sailing duration for route planning"
    - name: "avg_actual_duration_minutes"
      expr: AVG(CAST(actual_duration_minutes AS DOUBLE))
      comment: "Average actual sailing duration for operational performance analysis"
    - name: "schedule_adherence_pct"
      expr: ROUND(100.0 * AVG(CAST(scheduled_duration_minutes AS DOUBLE)) / NULLIF(AVG(CAST(actual_duration_minutes AS DOUBLE)), 0), 2)
      comment: "Percentage of scheduled duration achieved - schedule reliability indicator"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`ferry_group_reservation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Group reservation performance metrics tracking large party bookings, group revenue, approval efficiency, and special event transportation."
  source: "`feip_eastus_03`.`ferry`.`group_reservation`"
  dimensions:
    - name: "route_code"
      expr: route_code
      comment: "Ferry route for group reservation demand analysis"
    - name: "departure_terminal"
      expr: departure_terminal
      comment: "Origin terminal for group boarding logistics"
    - name: "arrival_terminal"
      expr: arrival_terminal
      comment: "Destination terminal for group disembarkation planning"
    - name: "group_type"
      expr: group_type
      comment: "Category of group (school, church, corporate, tour operator) for market segmentation"
    - name: "reservation_status"
      expr: status
      comment: "Current status of group reservation (pending, confirmed, cancelled, completed, no-show)"
    - name: "trip_type"
      expr: trip_type
      comment: "One-way or round-trip classification for capacity planning"
    - name: "vehicle_type"
      expr: vehicle_type
      comment: "Primary vehicle type (bus, van, mixed) for deck space allocation"
    - name: "priority_level"
      expr: priority_level
      comment: "Priority classification (standard, high, emergency) for resource allocation"
    - name: "payment_status"
      expr: payment_status
      comment: "Payment completion status for revenue recognition"
    - name: "scheduled_departure_date"
      expr: scheduled_departure_date
      comment: "Date of scheduled group departure for demand forecasting"
    - name: "scheduled_departure_month"
      expr: DATE_TRUNC('MONTH', scheduled_departure_date)
      comment: "Month of scheduled departure for seasonal group travel analysis"
    - name: "reservation_date"
      expr: reservation_date
      comment: "Date group reservation was created for lead time analysis"
    - name: "confirmation_date"
      expr: confirmation_date
      comment: "Date reservation was confirmed for approval process tracking"
  measures:
    - name: "total_group_reservations"
      expr: COUNT(1)
      comment: "Total number of group reservation records"
    - name: "confirmed_group_reservations"
      expr: COUNT(CASE WHEN status = 'confirmed' THEN 1 END)
      comment: "Number of confirmed group reservations ready for service"
    - name: "pending_group_reservations"
      expr: COUNT(CASE WHEN status = 'pending approval' THEN 1 END)
      comment: "Number of group reservations awaiting approval - operational backlog indicator"
    - name: "cancelled_group_reservations"
      expr: COUNT(CASE WHEN status = 'cancelled by customer' THEN 1 END)
      comment: "Number of cancelled group reservations indicating demand volatility"
    - name: "group_confirmation_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN status = 'confirmed' THEN 1 END) / NULLIF(COUNT(CASE WHEN status IN ('confirmed', 'pending approval', 'cancelled by customer') THEN 1 END), 0), 2)
      comment: "Percentage of group reservations confirmed - approval process efficiency KPI"
    - name: "group_cancellation_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN status = 'cancelled by customer' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of group reservations cancelled - group demand stability metric"
    - name: "total_group_passengers"
      expr: SUM(CAST(passenger_count AS BIGINT))
      comment: "Total number of passengers across all group reservations"
    - name: "total_group_vehicles"
      expr: SUM(CAST(vehicle_count AS BIGINT))
      comment: "Total number of vehicles across all group reservations"
    - name: "avg_group_size_passengers"
      expr: AVG(CAST(passenger_count AS DOUBLE))
      comment: "Average number of passengers per group reservation - group size indicator"
    - name: "avg_vehicles_per_group"
      expr: AVG(CAST(vehicle_count AS DOUBLE))
      comment: "Average number of vehicles per group reservation for capacity planning"
    - name: "total_group_fare_revenue"
      expr: SUM(CAST(total_fare_amount AS DOUBLE))
      comment: "Total fare revenue from all group reservations in US dollars"
    - name: "confirmed_group_revenue"
      expr: SUM(CASE WHEN status = 'confirmed' THEN CAST(total_fare_amount AS DOUBLE) ELSE 0 END)
      comment: "Revenue from confirmed group reservations representing committed revenue"
    - name: "avg_fare_per_group"
      expr: AVG(CAST(total_fare_amount AS DOUBLE))
      comment: "Average fare amount per group reservation - group pricing effectiveness"
    - name: "avg_fare_per_group_passenger"
      expr: ROUND(SUM(CAST(total_fare_amount AS DOUBLE)) / NULLIF(SUM(CAST(passenger_count AS DOUBLE)), 0), 2)
      comment: "Average fare per passenger in group reservations - group discount impact metric"
    - name: "groups_with_discount"
      expr: COUNT(CASE WHEN discount_applied = true THEN 1 END)
      comment: "Number of group reservations receiving discounts"
    - name: "group_discount_penetration_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN discount_applied = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of group reservations receiving discounts - pricing strategy metric"
    - name: "avg_advance_notice_days"
      expr: AVG(CAST(advance_notice_days AS DOUBLE))
      comment: "Average number of days groups book in advance - planning horizon indicator"
    - name: "avg_approval_time_days"
      expr: AVG(CAST(DATEDIFF(confirmation_date, reservation_date) AS DOUBLE))
      comment: "Average days from reservation to confirmation - approval process efficiency metric"
    - name: "groups_with_special_requirements"
      expr: COUNT(CASE WHEN special_requirements IS NOT NULL AND special_requirements != '' THEN 1 END)
      comment: "Number of groups requiring special accommodations - service complexity indicator"
    - name: "round_trip_groups"
      expr: COUNT(CASE WHEN trip_type = 'round-trip' THEN 1 END)
      comment: "Number of round-trip group reservations for capacity planning"
    - name: "round_trip_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN trip_type = 'round-trip' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of group reservations that are round-trip - demand pattern metric"
    - name: "high_priority_groups"
      expr: COUNT(CASE WHEN priority_level IN ('high', 'emergency') THEN 1 END)
      comment: "Number of high-priority or emergency group reservations requiring special handling"
    - name: "unique_group_organizations"
      expr: COUNT(DISTINCT group_name)
      comment: "Number of unique organizations making group reservations - customer base diversity"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`ferry_vessel`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Ferry vessel fleet performance metrics tracking vessel utilization, maintenance status, capacity, and asset value for fleet management and capital planning."
  source: "`feip_eastus_03`.`ferry`.`vessel`"
  dimensions:
    - name: "vessel_name"
      expr: name
      comment: "Official vessel name for vessel-specific performance tracking"
    - name: "vessel_type"
      expr: type
      comment: "Classification of vessel (passenger ferry, vehicle ferry, high-speed, etc.)"
    - name: "vessel_class"
      expr: class
      comment: "Specific vessel class for fleet standardization analysis"
    - name: "vessel_status"
      expr: status
      comment: "Current operational status (active, maintenance, drydock, retired)"
    - name: "home_port"
      expr: home_port
      comment: "Primary terminal where vessel is based for fleet deployment analysis"
    - name: "build_year"
      expr: CAST(build_year AS STRING)
      comment: "Year vessel was constructed for age and replacement planning"
    - name: "builder_name"
      expr: builder_name
      comment: "Shipyard that constructed vessel for quality and reliability analysis"
    - name: "propulsion_type"
      expr: propulsion_type
      comment: "Type of propulsion system for operational efficiency comparison"
    - name: "fuel_type"
      expr: fuel_type
      comment: "Type of fuel used for cost and environmental analysis"
    - name: "hull_material"
      expr: hull_material
      comment: "Primary hull construction material for maintenance planning"
    - name: "condition_rating"
      expr: condition_rating
      comment: "Overall vessel condition assessment for maintenance prioritization"
    - name: "environmental_compliance_tier"
      expr: environmental_compliance_tier
      comment: "EPA emissions compliance tier for environmental performance tracking"
  measures:
    - name: "total_vessels"
      expr: COUNT(1)
      comment: "Total number of vessels in the ferry fleet"
    - name: "active_vessels"
      expr: COUNT(CASE WHEN status = 'active' THEN 1 END)
      comment: "Number of vessels currently in active service"
    - name: "vessels_in_maintenance"
      expr: COUNT(CASE WHEN status IN ('maintenance', 'drydock') THEN 1 END)
      comment: "Number of vessels out of service for maintenance - fleet availability indicator"
    - name: "fleet_availability_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN status = 'active' THEN 1 END) / NULLIF(COUNT(CASE WHEN status IN ('active', 'maintenance', 'drydock') THEN 1 END), 0), 2)
      comment: "Percentage of fleet available for service - critical operational capacity KPI"
    - name: "total_passenger_capacity"
      expr: SUM(CAST(passenger_capacity AS BIGINT))
      comment: "Total passenger capacity across entire fleet"
    - name: "total_vehicle_capacity"
      expr: SUM(CAST(vehicle_capacity AS BIGINT))
      comment: "Total vehicle capacity across entire fleet"
    - name: "avg_passenger_capacity_per_vessel"
      expr: AVG(CAST(passenger_capacity AS DOUBLE))
      comment: "Average passenger capacity per vessel for fleet standardization analysis"
    - name: "avg_vehicle_capacity_per_vessel"
      expr: AVG(CAST(vehicle_capacity AS DOUBLE))
      comment: "Average vehicle capacity per vessel for capacity planning"
    - name: "avg_vessel_age_years"
      expr: AVG(CAST(YEAR(CURRENT_DATE()) - build_year AS DOUBLE))
      comment: "Average age of fleet in years - replacement planning indicator"
    - name: "total_fleet_acquisition_cost"
      expr: SUM(CAST(acquisition_cost AS DOUBLE))
      comment: "Total original acquisition cost of entire fleet in US dollars"
    - name: "total_fleet_book_value"
      expr: SUM(CAST(current_book_value AS DOUBLE))
      comment: "Total current depreciated book value of fleet - asset value KPI"
    - name: "total_fleet_replacement_cost"
      expr: SUM(CAST(replacement_cost_estimate AS DOUBLE))
      comment: "Total estimated cost to replace entire fleet - capital planning metric"
    - name: "total_fleet_insurance_value"
      expr: SUM(CAST(insurance_value AS DOUBLE))
      comment: "Total insured value of fleet for risk management"
    - name: "avg_vessel_length_feet"
      expr: AVG(CAST(length_overall_ft AS DOUBLE))
      comment: "Average vessel length for terminal compatibility analysis"
    - name: "avg_vessel_beam_feet"
      expr: AVG(CAST(beam_ft AS DOUBLE))
      comment: "Average vessel width for dock and channel planning"
    - name: "avg_vessel_draft_feet"
      expr: AVG(CAST(draft_ft AS DOUBLE))
      comment: "Average vessel draft for channel depth requirements"
    - name: "total_fleet_horsepower"
      expr: SUM(CAST(total_horsepower AS BIGINT))
      comment: "Total combined horsepower of all fleet propulsion systems"
    - name: "avg_horsepower_per_vessel"
      expr: AVG(CAST(total_horsepower AS DOUBLE))
      comment: "Average horsepower per vessel for performance comparison"
    - name: "total_fuel_capacity_gallons"
      expr: SUM(CAST(fuel_capacity_gallons AS DOUBLE))
      comment: "Total fuel storage capacity across entire fleet"
    - name: "avg_fuel_capacity_per_vessel"
      expr: AVG(CAST(fuel_capacity_gallons AS DOUBLE))
      comment: "Average fuel capacity per vessel for refueling logistics"
    - name: "avg_max_speed_knots"
      expr: AVG(CAST(max_speed_knots AS DOUBLE))
      comment: "Average maximum speed across fleet for route planning"
    - name: "avg_service_speed_knots"
      expr: AVG(CAST(service_speed_knots AS DOUBLE))
      comment: "Average operational cruising speed for schedule planning"
    - name: "ada_compliant_vessels"
      expr: COUNT(CASE WHEN ada_compliant = true THEN 1 END)
      comment: "Number of vessels meeting ADA accessibility requirements"
    - name: "ada_compliance_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN ada_compliant = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of fleet meeting ADA requirements - accessibility compliance KPI"
    - name: "vessels_with_wifi"
      expr: COUNT(CASE WHEN wifi_available = true THEN 1 END)
      comment: "Number of vessels offering passenger WiFi service"
    - name: "vessels_with_elevators"
      expr: COUNT(CASE WHEN elevator_installed = true THEN 1 END)
      comment: "Number of vessels with passenger elevators for accessibility"
    - name: "avg_crew_capacity"
      expr: AVG(CAST(crew_capacity AS DOUBLE))
      comment: "Average crew size required per vessel for staffing planning"
    - name: "avg_useful_life_years"
      expr: AVG(CAST(useful_life_years AS DOUBLE))
      comment: "Average expected operational lifespan for replacement planning"
    - name: "vessels_past_half_life"
      expr: COUNT(CASE WHEN (YEAR(CURRENT_DATE()) - build_year) > (useful_life_years / 2) THEN 1 END)
      comment: "Number of vessels past half their useful life - replacement priority indicator"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`ferry_terminal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Ferry terminal facility performance metrics tracking throughput, capacity utilization, facility condition, and operational readiness for infrastructure planning."
  source: "`feip_eastus_03`.`ferry`.`terminal`"
  dimensions:
    - name: "terminal_code"
      expr: code
      comment: "Short terminal identifier for operational reporting"
    - name: "terminal_name"
      expr: name
      comment: "Official terminal name for public-facing reports"
    - name: "terminal_status"
      expr: status
      comment: "Current operational status (active, closed, under construction, seasonal)"
    - name: "terminal_type"
      expr: type
      comment: "Classification of terminal (passenger-only, vehicle ferry, mixed use, cargo)"
    - name: "county"
      expr: county
      comment: "North Carolina county for regional analysis"
    - name: "water_body_name"
      expr: water_body_name
      comment: "Water body where terminal is located for geographic analysis"
    - name: "ownership_type"
      expr: ownership_type
      comment: "Legal ownership classification for asset management"
    - name: "facility_condition"
      expr: facility_condition
      comment: "Overall condition assessment for maintenance prioritization"
    - name: "construction_year"
      expr: CAST(construction_year AS STRING)
      comment: "Year terminal was built for age and replacement analysis"
    - name: "seasonal_operation_flag"
      expr: CASE WHEN seasonal_operation = true THEN 'Seasonal' ELSE 'Year-Round' END
      comment: "Whether terminal operates seasonally or year-round"
  measures:
    - name: "total_terminals"
      expr: COUNT(1)
      comment: "Total number of ferry terminals in the system"
    - name: "active_terminals"
      expr: COUNT(CASE WHEN status = 'active' THEN 1 END)
      comment: "Number of terminals currently operational"
    - name: "terminals_under_construction"
      expr: COUNT(CASE WHEN status = 'under construction' THEN 1 END)
      comment: "Number of terminals being built or renovated"
    - name: "total_dock_capacity"
      expr: SUM(CAST(dock_count AS BIGINT))
      comment: "Total number of docking berths across all terminals"
    - name: "total_vehicle_staging_capacity"
      expr: SUM(CAST(vehicle_capacity AS BIGINT))
      comment: "Total vehicle staging capacity across all terminals"
    - name: "total_passenger_waiting_capacity"
      expr: SUM(CAST(passenger_capacity AS BIGINT))
      comment: "Total passenger waiting area capacity across all terminals"
    - name: "total_parking_spaces"
      expr: SUM(CAST(parking_spaces AS BIGINT))
      comment: "Total parking spaces available across all terminals"
    - name: "total_ada_parking_spaces"
      expr: SUM(CAST(ada_parking_spaces AS BIGINT))
      comment: "Total ADA-compliant parking spaces for accessibility compliance"
    - name: "avg_vehicle_capacity_per_terminal"
      expr: AVG(CAST(vehicle_capacity AS DOUBLE))
      comment: "Average vehicle staging capacity per terminal for capacity planning"
    - name: "avg_passenger_capacity_per_terminal"
      expr: AVG(CAST(passenger_capacity AS DOUBLE))
      comment: "Average passenger waiting capacity per terminal"
    - name: "ada_compliant_terminals"
      expr: COUNT(CASE WHEN ada_compliant = true THEN 1 END)
      comment: "Number of terminals meeting ADA accessibility requirements"
    - name: "ada_compliance_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN ada_compliant = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of terminals meeting ADA requirements - accessibility compliance KPI"
    - name: "terminals_with_restrooms"
      expr: COUNT(CASE WHEN restroom_facilities = true THEN 1 END)
      comment: "Number of terminals with public restroom facilities"
    - name: "terminals_with_wifi"
      expr: COUNT(CASE WHEN wifi_available = true THEN 1 END)
      comment: "Number of terminals offering public WiFi service"
    - name: "terminals_with_food_service"
      expr: COUNT(CASE WHEN food_service = true THEN 1 END)
      comment: "Number of terminals with food or beverage services"
    - name: "terminals_24_hour_operation"
      expr: COUNT(CASE WHEN operates_24_hours = true THEN 1 END)
      comment: "Number of terminals operating 24 hours per day"
    - name: "avg_terminal_age_years"
      expr: AVG(CAST(YEAR(CURRENT_DATE()) - construction_year AS DOUBLE))
      comment: "Average age of terminals in years - replacement planning indicator"
    - name: "avg_dock_depth_feet"
      expr: AVG(CAST(dock_depth_feet AS DOUBLE))
      comment: "Average water depth at docks for vessel compatibility analysis"
    - name: "avg_approach_channel_depth_feet"
      expr: AVG(CAST(approach_channel_depth_feet AS DOUBLE))
      comment: "Average approach channel depth for navigation planning"
    - name: "terminals_with_fuel_station"
      expr: COUNT(CASE WHEN fuel_station = true THEN 1 END)
      comment: "Number of terminals with vessel fueling facilities"
    - name: "terminals_with_maintenance_facility"
      expr: COUNT(CASE WHEN maintenance_facility = true THEN 1 END)
      comment: "Number of terminals with vessel maintenance capabilities"
    - name: "terminals_with_emergency_generator"
      expr: COUNT(CASE WHEN emergency_generator = true THEN 1 END)
      comment: "Number of terminals with backup power for resilience"
    - name: "avg_generator_capacity_kw"
      expr: AVG(CAST(generator_capacity_kw AS DOUBLE))
      comment: "Average emergency generator capacity for power resilience planning"
    - name: "total_ev_charging_stations"
      expr: SUM(CAST(electric_vehicle_charging_stations AS BIGINT))
      comment: "Total electric vehicle charging stations across all terminals"
    - name: "terminals_with_renewable_energy"
      expr: COUNT(CASE WHEN renewable_energy_system IS NOT NULL AND renewable_energy_system != '' THEN 1 END)
      comment: "Number of terminals with renewable energy systems"
    - name: "total_renewable_capacity_kw"
      expr: SUM(CAST(renewable_energy_capacity_kw AS DOUBLE))
      comment: "Total renewable energy generation capacity across all terminals"
    - name: "terminals_with_weather_station"
      expr: COUNT(CASE WHEN weather_station = true THEN 1 END)
      comment: "Number of terminals with weather monitoring equipment"
    - name: "avg_surveillance_coverage_pct"
      expr: AVG(CAST(surveillance_coverage_percent AS DOUBLE))
      comment: "Average CCTV surveillance coverage across terminals for security assessment"
    - name: "terminals_with_real_time_displays"
      expr: COUNT(CASE WHEN real_time_information_display = true THEN 1 END)
      comment: "Number of terminals with real-time schedule information displays"
    - name: "terminals_with_public_transit_access"
      expr: COUNT(CASE WHEN public_transit_access = true THEN 1 END)
      comment: "Number of terminals accessible by public transit for multimodal connectivity"
    - name: "avg_staff_count_per_terminal"
      expr: AVG(CAST(staff_count AS DOUBLE))
      comment: "Average number of staff per terminal for workforce planning"
    - name: "avg_annual_passenger_volume"
      expr: AVG(CAST(annual_passenger_volume AS DOUBLE))
      comment: "Average annual passenger throughput per terminal"
    - name: "avg_annual_vehicle_volume"
      expr: AVG(CAST(annual_vehicle_volume AS DOUBLE))
      comment: "Average annual vehicle throughput per terminal"
$$;