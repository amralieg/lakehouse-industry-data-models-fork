-- Metric views for domain: transit | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`transit_route_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic route performance metrics for service planning, funding allocation, and operational efficiency analysis. Tracks ridership, cost efficiency, on-time performance, and accessibility compliance at the route level."
  source: "`feip_eastus_03`.`transit`.`route`"
  dimensions:
    - name: "route_short_name"
      expr: short_name
      comment: "Public-facing route number or identifier used on signage and schedules"
    - name: "route_long_name"
      expr: long_name
      comment: "Full descriptive route name including origin and destination"
    - name: "route_type"
      expr: type
      comment: "Transit service mode (bus, rail, ferry) for mode-specific analysis"
    - name: "service_level"
      expr: service_level
      comment: "Service classification (local, express, rapid) affecting stop frequency and speed"
    - name: "operator_name"
      expr: operator_name
      comment: "Transit agency or contractor operating the route"
    - name: "mpo_name"
      expr: mpo_name
      comment: "Metropolitan Planning Organization responsible for regional coordination"
    - name: "rpo_name"
      expr: rpo_name
      comment: "Rural Planning Organization for rural area coordination"
    - name: "service_area"
      expr: service_area
      comment: "Geographic area served by the route"
    - name: "fta_grant_program"
      expr: fta_grant_program
      comment: "Federal Transit Administration grant program funding the route"
    - name: "route_status"
      expr: status
      comment: "Current operational status of the route"
    - name: "ada_compliant_flag"
      expr: ada_compliant_flag
      comment: "Whether route meets ADA accessibility requirements"
    - name: "environmental_justice_route_flag"
      expr: environmental_justice_route_flag
      comment: "Whether route primarily serves environmental justice communities"
    - name: "title_vi_protected_flag"
      expr: title_vi_protected_flag
      comment: "Whether route serves Title VI protected populations"
    - name: "vehicle_type"
      expr: vehicle_type
      comment: "Type of vehicle typically used on the route"
    - name: "fuel_type"
      expr: fuel_type
      comment: "Primary fuel type for route vehicles"
  measures:
    - name: "total_routes"
      expr: COUNT(1)
      comment: "Total number of transit routes in the system"
    - name: "total_route_miles"
      expr: SUM(CAST(length_miles AS DOUBLE))
      comment: "Total route miles across all routes for network coverage analysis"
    - name: "avg_route_length_miles"
      expr: AVG(CAST(length_miles AS DOUBLE))
      comment: "Average route length in miles for service design benchmarking"
    - name: "total_annual_operating_cost"
      expr: SUM(CAST(annual_operating_cost AS DOUBLE))
      comment: "Total annual operating cost across all routes for budget planning"
    - name: "avg_annual_operating_cost_per_route"
      expr: AVG(CAST(annual_operating_cost AS DOUBLE))
      comment: "Average annual operating cost per route for cost benchmarking"
    - name: "total_annual_ridership"
      expr: SUM(CAST(annual_ridership AS BIGINT))
      comment: "Total annual passenger boardings across all routes for demand analysis"
    - name: "avg_daily_ridership_per_route"
      expr: AVG(CAST(average_daily_ridership AS DOUBLE))
      comment: "Average daily ridership per route for service frequency planning"
    - name: "cost_per_passenger_trip"
      expr: ROUND(SUM(CAST(annual_operating_cost AS DOUBLE)) / NULLIF(SUM(CAST(annual_ridership AS BIGINT)), 0), 2)
      comment: "Average operating cost per passenger trip - key efficiency metric for FTA reporting and funding justification"
    - name: "avg_on_time_performance_pct"
      expr: AVG(CAST(on_time_performance_percentage AS DOUBLE))
      comment: "Average on-time performance percentage across routes for service reliability assessment"
    - name: "routes_meeting_otp_standard"
      expr: SUM(CASE WHEN CAST(on_time_performance_percentage AS DOUBLE) >= 80.0 THEN 1 ELSE 0 END)
      comment: "Count of routes meeting 80% on-time performance standard for service quality monitoring"
    - name: "otp_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(on_time_performance_percentage AS DOUBLE) >= 80.0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of routes meeting on-time performance standard - executive KPI for service quality"
    - name: "ada_compliant_routes"
      expr: SUM(CASE WHEN ada_compliant_flag = true THEN 1 ELSE 0 END)
      comment: "Count of ADA-compliant routes for civil rights compliance tracking"
    - name: "ada_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN ada_compliant_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of routes meeting ADA requirements - critical for federal funding eligibility"
    - name: "fta_grant_funded_routes"
      expr: SUM(CASE WHEN fta_grant_funded_flag = true THEN 1 ELSE 0 END)
      comment: "Count of routes receiving FTA grant funding for grant portfolio management"
    - name: "avg_base_fare_amount"
      expr: AVG(CAST(base_fare_amount AS DOUBLE))
      comment: "Average base fare across routes for fare policy analysis"
    - name: "total_safety_incidents"
      expr: SUM(CAST(safety_incident_count_annual AS BIGINT))
      comment: "Total annual safety incidents across all routes for safety program evaluation"
    - name: "safety_incident_rate_per_route"
      expr: ROUND(SUM(CAST(safety_incident_count_annual AS BIGINT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average safety incidents per route for risk assessment and resource allocation"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`transit_trip_operations`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational trip-level metrics for real-time service monitoring, schedule adherence, ridership tracking, and resource utilization. Critical for daily operations management and performance reporting."
  source: "`feip_eastus_03`.`transit`.`trip`"
  dimensions:
    - name: "service_date"
      expr: service_date
      comment: "Operating date for the trip following transit day convention"
    - name: "trip_status"
      expr: status
      comment: "Current operational status of the trip"
    - name: "trip_type"
      expr: type
      comment: "Service type classification indicating stop pattern"
    - name: "peak_indicator"
      expr: peak_indicator
      comment: "Whether trip operates during peak commute hours"
    - name: "fare_class"
      expr: fare_class
      comment: "Fare category or pricing tier for the trip"
    - name: "on_time_performance_status"
      expr: on_time_performance_status
      comment: "Whether trip met on-time performance standards"
    - name: "transit_agency_name"
      expr: transit_agency_name
      comment: "Transit agency or operator providing the trip service"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source category for the trip"
    - name: "service_area_type"
      expr: service_area_type
      comment: "Geographic service area classification"
    - name: "fuel_type"
      expr: fuel_type
      comment: "Fuel or energy source used by the vehicle"
    - name: "weather_condition"
      expr: weather_condition
      comment: "Weather conditions during the trip affecting operations"
    - name: "traffic_condition"
      expr: traffic_condition
      comment: "Traffic conditions encountered during the trip"
    - name: "incident_flag"
      expr: incident_flag
      comment: "Whether any safety or operational incident occurred"
    - name: "incident_type"
      expr: incident_type
      comment: "Classification of incident that occurred"
    - name: "cancellation_reason"
      expr: cancellation_reason
      comment: "Reason for trip cancellation if applicable"
  measures:
    - name: "total_trips"
      expr: COUNT(1)
      comment: "Total number of transit trips operated"
    - name: "completed_trips"
      expr: SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)
      comment: "Count of successfully completed trips for service reliability tracking"
    - name: "cancelled_trips"
      expr: SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)
      comment: "Count of cancelled trips for service disruption analysis"
    - name: "trip_completion_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of trips completed as scheduled - key service reliability KPI"
    - name: "total_passenger_boardings"
      expr: SUM(CAST(boarding_count AS BIGINT))
      comment: "Total passenger boardings across all trips for ridership reporting"
    - name: "total_passenger_alightings"
      expr: SUM(CAST(alighting_count AS BIGINT))
      comment: "Total passenger alightings across all trips for demand pattern analysis"
    - name: "avg_passengers_per_trip"
      expr: AVG(CAST(passenger_count AS DOUBLE))
      comment: "Average passengers per trip for capacity planning"
    - name: "avg_max_load_per_trip"
      expr: AVG(CAST(max_load AS DOUBLE))
      comment: "Average peak load per trip for vehicle capacity assessment"
    - name: "vehicle_utilization_rate"
      expr: ROUND(100.0 * AVG(CAST(max_load AS DOUBLE)) / NULLIF(AVG(CAST(vehicle_capacity AS DOUBLE)), 0), 2)
      comment: "Average vehicle capacity utilization percentage - critical for fleet sizing and service frequency decisions"
    - name: "total_revenue_miles"
      expr: SUM(CAST(revenue_miles AS DOUBLE))
      comment: "Total miles in revenue service for FTA National Transit Database reporting"
    - name: "total_deadhead_miles"
      expr: SUM(CAST(deadhead_miles AS DOUBLE))
      comment: "Total non-revenue miles for operational efficiency analysis"
    - name: "deadhead_ratio"
      expr: ROUND(100.0 * SUM(CAST(deadhead_miles AS DOUBLE)) / NULLIF(SUM(CAST(revenue_miles AS DOUBLE)) + SUM(CAST(deadhead_miles AS DOUBLE)), 0), 2)
      comment: "Percentage of total miles that are non-revenue - key efficiency metric for route optimization"
    - name: "total_revenue_hours"
      expr: SUM(CAST(revenue_hours AS DOUBLE))
      comment: "Total hours in revenue service for labor cost analysis and FTA reporting"
    - name: "avg_revenue_hours_per_trip"
      expr: AVG(CAST(revenue_hours AS DOUBLE))
      comment: "Average revenue hours per trip for schedule efficiency assessment"
    - name: "total_fare_revenue"
      expr: SUM(CAST(fare_revenue AS DOUBLE))
      comment: "Total fare revenue collected from passengers for financial performance tracking"
    - name: "total_operating_cost"
      expr: SUM(CAST(operating_cost AS DOUBLE))
      comment: "Total operating cost across all trips for budget management"
    - name: "farebox_recovery_ratio"
      expr: ROUND(100.0 * SUM(CAST(fare_revenue AS DOUBLE)) / NULLIF(SUM(CAST(operating_cost AS DOUBLE)), 0), 2)
      comment: "Percentage of operating costs covered by fare revenue - critical financial sustainability metric for grant applications"
    - name: "cost_per_revenue_mile"
      expr: ROUND(SUM(CAST(operating_cost AS DOUBLE)) / NULLIF(SUM(CAST(revenue_miles AS DOUBLE)), 0), 2)
      comment: "Operating cost per revenue mile - standard FTA efficiency metric"
    - name: "cost_per_revenue_hour"
      expr: ROUND(SUM(CAST(operating_cost AS DOUBLE)) / NULLIF(SUM(CAST(revenue_hours AS DOUBLE)), 0), 2)
      comment: "Operating cost per revenue hour - key labor efficiency metric"
    - name: "cost_per_passenger"
      expr: ROUND(SUM(CAST(operating_cost AS DOUBLE)) / NULLIF(SUM(CAST(passenger_count AS BIGINT)), 0), 2)
      comment: "Operating cost per passenger - fundamental efficiency metric for service evaluation"
    - name: "passengers_per_revenue_mile"
      expr: ROUND(SUM(CAST(passenger_count AS BIGINT)) / NULLIF(SUM(CAST(revenue_miles AS DOUBLE)), 0), 2)
      comment: "Passengers per revenue mile - productivity metric for route performance comparison"
    - name: "passengers_per_revenue_hour"
      expr: ROUND(SUM(CAST(passenger_count AS BIGINT)) / NULLIF(SUM(CAST(revenue_hours AS DOUBLE)), 0), 2)
      comment: "Passengers per revenue hour - service productivity metric for schedule optimization"
    - name: "on_time_trips"
      expr: SUM(CASE WHEN on_time_performance_status = 'on_time' THEN 1 ELSE 0 END)
      comment: "Count of trips meeting on-time performance standards"
    - name: "on_time_performance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN on_time_performance_status = 'on_time' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of trips on time - primary service quality KPI for customer satisfaction"
    - name: "avg_delay_minutes"
      expr: AVG(CAST(delay_minutes AS DOUBLE))
      comment: "Average delay in minutes for schedule adherence analysis"
    - name: "total_fuel_consumed_gallons"
      expr: SUM(CAST(fuel_consumed_gallons AS DOUBLE))
      comment: "Total fuel consumption for environmental reporting and cost management"
    - name: "fuel_efficiency_mpg"
      expr: ROUND(SUM(CAST(revenue_miles AS DOUBLE)) / NULLIF(SUM(CAST(fuel_consumed_gallons AS DOUBLE)), 0), 2)
      comment: "Miles per gallon fuel efficiency - environmental and cost efficiency metric"
    - name: "total_co2_emissions_kg"
      expr: SUM(CAST(emissions_co2_kg AS DOUBLE))
      comment: "Total carbon dioxide emissions for environmental impact reporting"
    - name: "co2_per_passenger_mile"
      expr: ROUND(SUM(CAST(emissions_co2_kg AS DOUBLE)) / NULLIF(SUM(CAST(passenger_count AS BIGINT)) * SUM(CAST(revenue_miles AS DOUBLE)), 0), 4)
      comment: "CO2 emissions per passenger-mile - environmental efficiency metric for sustainability reporting"
    - name: "trips_with_incidents"
      expr: SUM(CASE WHEN incident_flag = true THEN 1 ELSE 0 END)
      comment: "Count of trips with safety or operational incidents"
    - name: "incident_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN incident_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of trips with incidents - safety performance indicator"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`transit_ticket_revenue`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fare revenue and ticketing transaction metrics for financial reporting, fare policy analysis, and subsidy program evaluation. Supports revenue forecasting and fare equity analysis."
  source: "`feip_eastus_03`.`transit`.`ticket`"
  dimensions:
    - name: "ticket_type"
      expr: type
      comment: "Classification of ticket product purchased"
    - name: "fare_type"
      expr: fare_type
      comment: "Pricing category applied to the ticket"
    - name: "payment_channel"
      expr: payment_channel
      comment: "Interface or location where ticket was purchased"
    - name: "ticket_status"
      expr: status
      comment: "Current lifecycle status of the ticket"
    - name: "service_type"
      expr: service_type
      comment: "Mode of transportation service provided"
    - name: "operator_name"
      expr: operator_name
      comment: "Transit agency or ferry operator providing service"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source or grant program"
    - name: "subsidy_program"
      expr: subsidy_program
      comment: "Subsidy or assistance program applied to fare"
    - name: "mpo_name"
      expr: mpo_name
      comment: "MPO or RPO jurisdiction where service operates"
    - name: "service_area"
      expr: service_area
      comment: "Geographic service area covered by ticket"
    - name: "purchase_date"
      expr: CAST(purchase_timestamp AS DATE)
      comment: "Date when ticket was purchased"
    - name: "trip_date"
      expr: trip_date
      comment: "Scheduled date of travel for the ticket"
    - name: "cancellation_reason"
      expr: cancellation_reason
      comment: "Reason for ticket cancellation if applicable"
  measures:
    - name: "total_tickets_sold"
      expr: COUNT(1)
      comment: "Total number of tickets sold for sales volume tracking"
    - name: "total_fare_revenue"
      expr: SUM(CAST(fare_amount AS DOUBLE))
      comment: "Total base fare revenue before discounts for gross revenue analysis"
    - name: "total_discount_amount"
      expr: SUM(CAST(discount_amount AS DOUBLE))
      comment: "Total discounts applied for fare equity program evaluation"
    - name: "total_subsidy_amount"
      expr: SUM(CAST(subsidy_amount AS DOUBLE))
      comment: "Total subsidy funding applied to fares for grant program tracking"
    - name: "total_tax_amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax collected on ticket sales for tax remittance"
    - name: "total_fee_amount"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total fees collected for processing and service charges"
    - name: "total_ticket_revenue"
      expr: SUM(CAST(total_amount AS DOUBLE))
      comment: "Total ticket revenue including all charges - primary revenue metric for financial reporting"
    - name: "avg_fare_amount"
      expr: AVG(CAST(fare_amount AS DOUBLE))
      comment: "Average base fare per ticket for pricing analysis"
    - name: "avg_ticket_value"
      expr: AVG(CAST(total_amount AS DOUBLE))
      comment: "Average total ticket value for revenue per transaction analysis"
    - name: "discount_rate"
      expr: ROUND(100.0 * SUM(CAST(discount_amount AS DOUBLE)) / NULLIF(SUM(CAST(fare_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of base fare discounted - fare equity and subsidy program effectiveness metric"
    - name: "subsidy_rate"
      expr: ROUND(100.0 * SUM(CAST(subsidy_amount AS DOUBLE)) / NULLIF(SUM(CAST(fare_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of fare covered by subsidy - grant program impact metric"
    - name: "tickets_with_discount"
      expr: SUM(CASE WHEN CAST(discount_amount AS DOUBLE) > 0 THEN 1 ELSE 0 END)
      comment: "Count of tickets with discounts applied for program participation tracking"
    - name: "discount_utilization_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(discount_amount AS DOUBLE) > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of tickets using discount programs - fare equity program reach metric"
    - name: "tickets_with_subsidy"
      expr: SUM(CASE WHEN CAST(subsidy_amount AS DOUBLE) > 0 THEN 1 ELSE 0 END)
      comment: "Count of tickets with subsidy applied for grant program tracking"
    - name: "subsidy_utilization_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(subsidy_amount AS DOUBLE) > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of tickets using subsidy programs - grant program effectiveness metric"
    - name: "cancelled_tickets"
      expr: SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)
      comment: "Count of cancelled tickets for refund liability tracking"
    - name: "total_refund_amount"
      expr: SUM(CAST(refund_amount AS DOUBLE))
      comment: "Total refunds issued for financial reconciliation"
    - name: "cancellation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of tickets cancelled - customer behavior and service disruption indicator"
    - name: "refund_rate"
      expr: ROUND(100.0 * SUM(CAST(refund_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of revenue refunded - financial risk and customer satisfaction metric"
    - name: "total_passengers"
      expr: SUM(CAST(passenger_count AS BIGINT))
      comment: "Total passengers covered by tickets for ridership correlation"
    - name: "avg_passengers_per_ticket"
      expr: AVG(CAST(passenger_count AS DOUBLE))
      comment: "Average passengers per ticket for group travel analysis"
    - name: "revenue_per_passenger"
      expr: ROUND(SUM(CAST(total_amount AS DOUBLE)) / NULLIF(SUM(CAST(passenger_count AS BIGINT)), 0), 2)
      comment: "Average revenue per passenger - key yield metric for pricing strategy"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`transit_stop_infrastructure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Transit stop infrastructure and accessibility metrics for capital planning, ADA compliance monitoring, and service equity analysis. Tracks amenity availability and condition ratings."
  source: "`feip_eastus_03`.`transit`.`stop`"
  dimensions:
    - name: "stop_name"
      expr: name
      comment: "Name of the transit stop as displayed to riders"
    - name: "location_type"
      expr: location_type
      comment: "Type of location (stop, station, entrance/exit)"
    - name: "transit_agency_name"
      expr: transit_agency_name
      comment: "Transit agency or operator responsible for the stop"
    - name: "ownership_type"
      expr: ownership_type
      comment: "Ownership of stop infrastructure"
    - name: "service_type"
      expr: service_type
      comment: "Type of transit service provided at stop"
    - name: "ridership_category"
      expr: ridership_category
      comment: "Classification based on ridership volume"
    - name: "condition_rating"
      expr: condition_rating
      comment: "Overall condition assessment of stop infrastructure"
    - name: "ada_compliant"
      expr: ada_compliant
      comment: "Whether stop meets ADA accessibility requirements"
    - name: "environmental_justice_area"
      expr: environmental_justice_area
      comment: "Whether stop is in environmental justice area"
    - name: "title_vi_protected"
      expr: title_vi_protected
      comment: "Whether stop serves Title VI protected population"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source for stop construction"
    - name: "grant_program"
      expr: grant_program
      comment: "Federal grant program that funded the stop"
    - name: "state"
      expr: state
      comment: "State where stop is located"
    - name: "zip_code"
      expr: zip_code
      comment: "ZIP code for demographic analysis"
  measures:
    - name: "total_stops"
      expr: COUNT(1)
      comment: "Total number of transit stops in the network"
    - name: "ada_compliant_stops"
      expr: SUM(CASE WHEN ada_compliant = true THEN 1 ELSE 0 END)
      comment: "Count of ADA-compliant stops for accessibility compliance tracking"
    - name: "ada_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN ada_compliant = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops meeting ADA requirements - critical compliance metric for federal funding"
    - name: "stops_with_shelter"
      expr: SUM(CASE WHEN shelter_present = true THEN 1 ELSE 0 END)
      comment: "Count of stops with shelter for rider comfort assessment"
    - name: "shelter_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN shelter_present = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops with shelter - amenity coverage metric for capital planning"
    - name: "stops_with_bench"
      expr: SUM(CASE WHEN bench_present = true THEN 1 ELSE 0 END)
      comment: "Count of stops with seating for accessibility support"
    - name: "bench_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN bench_present = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops with seating - accessibility amenity metric"
    - name: "stops_with_lighting"
      expr: SUM(CASE WHEN lighting_present = true THEN 1 ELSE 0 END)
      comment: "Count of stops with lighting for safety assessment"
    - name: "lighting_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN lighting_present = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops with lighting - safety infrastructure metric"
    - name: "stops_with_realtime_display"
      expr: SUM(CASE WHEN real_time_display_present = true THEN 1 ELSE 0 END)
      comment: "Count of stops with real-time information displays"
    - name: "realtime_display_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN real_time_display_present = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops with real-time displays - technology deployment metric for rider experience"
    - name: "stops_with_bike_rack"
      expr: SUM(CASE WHEN bike_rack_present = true THEN 1 ELSE 0 END)
      comment: "Count of stops with bicycle parking for multimodal integration"
    - name: "bike_rack_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN bike_rack_present = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops with bike parking - multimodal connectivity metric"
    - name: "total_bike_rack_capacity"
      expr: SUM(CAST(bike_rack_capacity AS BIGINT))
      comment: "Total bicycle parking capacity across all stops"
    - name: "stops_with_sidewalk"
      expr: SUM(CASE WHEN sidewalk_connection = true THEN 1 ELSE 0 END)
      comment: "Count of stops with sidewalk connection for pedestrian safety"
    - name: "sidewalk_connectivity_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN sidewalk_connection = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops with sidewalk access - critical ADA compliance and safety metric"
    - name: "stops_with_crosswalk"
      expr: SUM(CASE WHEN crosswalk_present = true THEN 1 ELSE 0 END)
      comment: "Count of stops with marked crosswalk for pedestrian safety"
    - name: "crosswalk_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN crosswalk_present = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops with crosswalk - pedestrian safety infrastructure metric"
    - name: "park_and_ride_stops"
      expr: SUM(CASE WHEN park_and_ride = true THEN 1 ELSE 0 END)
      comment: "Count of park-and-ride facilities for commuter service analysis"
    - name: "total_parking_capacity"
      expr: SUM(CAST(parking_capacity AS BIGINT))
      comment: "Total parking spaces at park-and-ride facilities for capacity planning"
    - name: "transfer_point_stops"
      expr: SUM(CASE WHEN transfer_point = true THEN 1 ELSE 0 END)
      comment: "Count of designated transfer points for network connectivity analysis"
    - name: "avg_routes_per_stop"
      expr: AVG(CAST(route_count AS DOUBLE))
      comment: "Average routes serving each stop - network connectivity metric"
    - name: "stops_in_ej_areas"
      expr: SUM(CASE WHEN environmental_justice_area = true THEN 1 ELSE 0 END)
      comment: "Count of stops in environmental justice areas for equity analysis"
    - name: "ej_area_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN environmental_justice_area = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops serving environmental justice communities - Title VI equity metric"
    - name: "title_vi_protected_stops"
      expr: SUM(CASE WHEN title_vi_protected = true THEN 1 ELSE 0 END)
      comment: "Count of stops serving Title VI protected populations"
    - name: "title_vi_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN title_vi_protected = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stops serving Title VI populations - civil rights compliance metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`transit_block_efficiency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Block-level operational efficiency metrics for driver scheduling, vehicle assignment optimization, and service productivity analysis. Tracks revenue vs deadhead miles and block utilization."
  source: "`feip_eastus_03`.`transit`.`block`"
  dimensions:
    - name: "service_date"
      expr: service_date
      comment: "Calendar date on which block is scheduled to operate"
    - name: "vehicle_type"
      expr: vehicle_type
      comment: "Type of vehicle assigned to operate the block"
    - name: "depot_location"
      expr: depot_location
      comment: "Depot or garage where vehicle begins and ends block"
    - name: "service_type"
      expr: service_type
      comment: "Classification of transit service provided during block"
    - name: "operator_name"
      expr: operator_name
      comment: "Transit agency or contractor operating the block"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source for block operation"
    - name: "mpo_rpo_region"
      expr: mpo_rpo_region
      comment: "MPO or RPO planning region where block operates"
    - name: "ada_accessible"
      expr: ada_accessible
      comment: "Whether block is operated with ADA-compliant vehicles"
    - name: "peak_period_indicator"
      expr: peak_period_indicator
      comment: "Classification of when block operates relative to peak demand"
    - name: "block_status"
      expr: status
      comment: "Current operational status of the block"
    - name: "cancellation_reason"
      expr: cancellation_reason
      comment: "Reason for block cancellation if applicable"
  measures:
    - name: "total_blocks"
      expr: COUNT(1)
      comment: "Total number of scheduled blocks for resource planning"
    - name: "completed_blocks"
      expr: SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)
      comment: "Count of successfully completed blocks for reliability tracking"
    - name: "cancelled_blocks"
      expr: SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)
      comment: "Count of cancelled blocks for service disruption analysis"
    - name: "block_completion_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of blocks completed as scheduled - operational reliability KPI"
    - name: "avg_block_duration_minutes"
      expr: AVG(CAST(duration_minutes AS DOUBLE))
      comment: "Average block duration for driver scheduling and labor planning"
    - name: "avg_routes_per_block"
      expr: AVG(CAST(route_count AS DOUBLE))
      comment: "Average routes served per block for schedule complexity assessment"
    - name: "avg_trips_per_block"
      expr: AVG(CAST(trip_count AS DOUBLE))
      comment: "Average trips per block for vehicle utilization analysis"
    - name: "total_revenue_miles"
      expr: SUM(CAST(revenue_miles AS DOUBLE))
      comment: "Total revenue miles across all blocks for service output measurement"
    - name: "total_deadhead_miles"
      expr: SUM(CAST(deadhead_miles AS DOUBLE))
      comment: "Total deadhead miles for operational efficiency analysis"
    - name: "avg_revenue_miles_per_block"
      expr: AVG(CAST(revenue_miles AS DOUBLE))
      comment: "Average revenue miles per block for productivity benchmarking"
    - name: "avg_deadhead_miles_per_block"
      expr: AVG(CAST(deadhead_miles AS DOUBLE))
      comment: "Average deadhead miles per block for efficiency assessment"
    - name: "deadhead_ratio"
      expr: ROUND(100.0 * SUM(CAST(deadhead_miles AS DOUBLE)) / NULLIF(SUM(CAST(revenue_miles AS DOUBLE)) + SUM(CAST(deadhead_miles AS DOUBLE)), 0), 2)
      comment: "Percentage of total miles that are non-revenue - critical efficiency metric for block optimization and depot location planning"
    - name: "revenue_mile_efficiency"
      expr: ROUND(100.0 * SUM(CAST(revenue_miles AS DOUBLE)) / NULLIF(SUM(CAST(revenue_miles AS DOUBLE)) + SUM(CAST(deadhead_miles AS DOUBLE)), 0), 2)
      comment: "Percentage of total miles in revenue service - operational efficiency KPI for schedule design"
    - name: "ada_accessible_blocks"
      expr: SUM(CASE WHEN ada_accessible = true THEN 1 ELSE 0 END)
      comment: "Count of blocks with ADA-compliant vehicles for accessibility compliance"
    - name: "ada_block_coverage_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN ada_accessible = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of blocks operated with accessible vehicles - ADA compliance metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`transit_rider_demographics`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rider demographic and eligibility metrics for fare equity analysis, Title VI compliance reporting, and service planning. Tracks eligibility program participation and accessibility needs."
  source: "`feip_eastus_03`.`transit`.`rider`"
  dimensions:
    - name: "eligibility_type"
      expr: eligibility_type
      comment: "Primary eligibility category determining fare discount eligibility"
    - name: "eligibility_verification_status"
      expr: eligibility_verification_status
      comment: "Current status of eligibility verification"
    - name: "ada_eligible"
      expr: ada_eligible
      comment: "Whether rider is eligible for ADA paratransit services"
    - name: "disability_type"
      expr: disability_type
      comment: "Type of disability affecting the rider"
    - name: "mobility_aid_required"
      expr: mobility_aid_required
      comment: "Whether rider requires mobility aid for transit use"
    - name: "mobility_aid_type"
      expr: mobility_aid_type
      comment: "Type of mobility aid used by rider"
    - name: "preferred_language"
      expr: preferred_language
      comment: "Preferred language for rider communication"
    - name: "fare_card_type"
      expr: fare_card_type
      comment: "Type of fare card issued to rider"
    - name: "fare_card_status"
      expr: fare_card_status
      comment: "Current status of rider fare card"
    - name: "loyalty_program_member"
      expr: loyalty_program_member
      comment: "Whether rider is enrolled in loyalty program"
    - name: "loyalty_program_tier"
      expr: loyalty_program_tier
      comment: "Current tier level in loyalty program"
    - name: "registration_channel"
      expr: registration_channel
      comment: "Channel through which rider registered"
    - name: "rider_status"
      expr: status
      comment: "Current status of rider account"
    - name: "county"
      expr: county
      comment: "County of rider residential address"
    - name: "state_code"
      expr: state_code
      comment: "State of rider residential address"
    - name: "low_income_verified"
      expr: low_income_verified
      comment: "Whether rider verified as low-income for reduced fare"
    - name: "student_enrollment_status"
      expr: student_enrollment_status
      comment: "Current enrollment status of student rider"
    - name: "veteran_status"
      expr: veteran_status
      comment: "Whether rider is military veteran"
    - name: "employer_subsidy_eligible"
      expr: employer_subsidy_eligible
      comment: "Whether rider eligible for employer-subsidized benefits"
  measures:
    - name: "total_registered_riders"
      expr: COUNT(1)
      comment: "Total number of registered riders in the system"
    - name: "active_riders"
      expr: SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END)
      comment: "Count of active rider accounts for engagement tracking"
    - name: "active_rider_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of riders with active accounts - engagement metric"
    - name: "ada_eligible_riders"
      expr: SUM(CASE WHEN ada_eligible = true THEN 1 ELSE 0 END)
      comment: "Count of ADA paratransit eligible riders for service capacity planning"
    - name: "ada_eligibility_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN ada_eligible = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of riders eligible for ADA paratransit - service demand metric"
    - name: "riders_requiring_mobility_aid"
      expr: SUM(CASE WHEN mobility_aid_required = true THEN 1 ELSE 0 END)
      comment: "Count of riders requiring mobility aids for vehicle capacity planning"
    - name: "mobility_aid_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN mobility_aid_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of riders requiring mobility aids - accessibility planning metric"
    - name: "low_income_riders"
      expr: SUM(CASE WHEN low_income_verified = true THEN 1 ELSE 0 END)
      comment: "Count of verified low-income riders for fare equity program sizing"
    - name: "low_income_rider_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN low_income_verified = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of riders verified as low-income - fare equity and Title VI metric"
    - name: "veteran_riders"
      expr: SUM(CASE WHEN veteran_status = true THEN 1 ELSE 0 END)
      comment: "Count of veteran riders for veteran discount program tracking"
    - name: "veteran_rider_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN veteran_status = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of riders who are veterans - veteran program participation metric"
    - name: "employer_subsidy_eligible_riders"
      expr: SUM(CASE WHEN employer_subsidy_eligible = true THEN 1 ELSE 0 END)
      comment: "Count of riders eligible for employer subsidies for partnership program sizing"
    - name: "employer_subsidy_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN employer_subsidy_eligible = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of riders with employer subsidy eligibility - employer partnership metric"
    - name: "loyalty_program_members"
      expr: SUM(CASE WHEN loyalty_program_member = true THEN 1 ELSE 0 END)
      comment: "Count of loyalty program members for program engagement tracking"
    - name: "loyalty_enrollment_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN loyalty_program_member = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of riders enrolled in loyalty program - customer engagement metric"
    - name: "avg_auto_reload_threshold"
      expr: AVG(CAST(auto_reload_threshold_amount AS DOUBLE))
      comment: "Average auto-reload threshold for fare card management analysis"
    - name: "avg_auto_reload_amount"
      expr: AVG(CAST(auto_reload_amount AS DOUBLE))
      comment: "Average auto-reload amount for revenue forecasting"
    - name: "riders_with_auto_reload"
      expr: SUM(CASE WHEN auto_reload_enabled = true THEN 1 ELSE 0 END)
      comment: "Count of riders with auto-reload enabled for payment convenience tracking"
    - name: "auto_reload_adoption_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN auto_reload_enabled = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of riders using auto-reload - payment technology adoption metric"
$$;