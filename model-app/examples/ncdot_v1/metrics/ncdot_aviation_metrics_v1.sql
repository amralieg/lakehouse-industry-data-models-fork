-- Metric views for domain: aviation | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`aviation_aircraft_fleet`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Aircraft fleet performance and utilization metrics for state-owned and registered aircraft. Tracks airworthiness, operational readiness, and asset value for fleet management and capital planning decisions."
  source: "`feip_eastus_03`.`aviation`.`aircraft`"
  dimensions:
    - name: "aircraft_make"
      expr: make
      comment: "Aircraft manufacturer for fleet composition analysis"
    - name: "aircraft_model"
      expr: model
      comment: "Aircraft model designation for type-specific performance tracking"
    - name: "aircraft_category"
      expr: category
      comment: "Aircraft category classification (airplane, rotorcraft, glider, etc.)"
    - name: "engine_type"
      expr: engine_type
      comment: "Propulsion system type for maintenance planning and fuel cost analysis"
    - name: "owner_type"
      expr: owner_type
      comment: "Legal classification of aircraft owner (individual, corporation, government)"
    - name: "registration_status"
      expr: registration_status
      comment: "Current FAA registration status for compliance monitoring"
    - name: "airworthiness_status"
      expr: airworthiness_status
      comment: "Current airworthiness certificate status for safety oversight"
    - name: "usage_type"
      expr: usage_type
      comment: "Primary operational purpose (personal, business, commercial, government)"
    - name: "base_airport_code"
      expr: base_airport_code
      comment: "Primary base airport for geographic fleet distribution analysis"
    - name: "nc_based_flag"
      expr: nc_based_flag
      comment: "Indicates whether aircraft is based at a North Carolina airport"
    - name: "commercial_operation_flag"
      expr: commercial_operation_flag
      comment: "Indicates whether aircraft is used for commercial operations"
    - name: "registration_year"
      expr: YEAR(registration_expiration_date)
      comment: "Year of registration expiration for renewal planning"
    - name: "inspection_year"
      expr: YEAR(last_inspection_date)
      comment: "Year of last inspection for compliance tracking"
  measures:
    - name: "total_aircraft_count"
      expr: COUNT(1)
      comment: "Total number of aircraft records in the registry"
    - name: "active_aircraft_count"
      expr: COUNT(CASE WHEN registration_status = 'Active' AND airworthiness_status IN ('Standard', 'Special') THEN 1 END)
      comment: "Count of aircraft with active registration and valid airworthiness certificates"
    - name: "nc_based_aircraft_count"
      expr: COUNT(CASE WHEN nc_based_flag = true THEN 1 END)
      comment: "Count of aircraft primarily based at North Carolina airports"
    - name: "total_fleet_airframe_hours"
      expr: SUM(CAST(total_airframe_hours AS DOUBLE))
      comment: "Cumulative flight hours across all aircraft airframes for fleet utilization analysis"
    - name: "avg_airframe_hours_per_aircraft"
      expr: AVG(CAST(total_airframe_hours AS DOUBLE))
      comment: "Average flight hours per aircraft for utilization benchmarking"
    - name: "total_fleet_engine_hours"
      expr: SUM(CAST(total_engine_hours AS DOUBLE))
      comment: "Cumulative engine operating hours across fleet for maintenance planning"
    - name: "avg_engine_hours_per_aircraft"
      expr: AVG(CAST(total_engine_hours AS DOUBLE))
      comment: "Average engine hours per aircraft for overhaul scheduling"
    - name: "total_fleet_market_value"
      expr: SUM(CAST(estimated_market_value AS DOUBLE))
      comment: "Total estimated market value of aircraft fleet for asset valuation and insurance"
    - name: "avg_aircraft_market_value"
      expr: AVG(CAST(estimated_market_value AS DOUBLE))
      comment: "Average market value per aircraft for fleet composition analysis"
    - name: "total_liability_coverage"
      expr: SUM(CAST(liability_coverage_amount AS DOUBLE))
      comment: "Total liability insurance coverage across fleet for risk management"
    - name: "total_hull_coverage"
      expr: SUM(CAST(hull_coverage_amount AS DOUBLE))
      comment: "Total hull insurance coverage across fleet for asset protection"
    - name: "avg_fuel_capacity"
      expr: AVG(CAST(fuel_capacity_gallons AS DOUBLE))
      comment: "Average fuel capacity per aircraft for operational range planning"
    - name: "airworthiness_compliance_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN airworthiness_status IN ('Standard', 'Special') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of aircraft with valid airworthiness certificates for safety compliance monitoring"
    - name: "inspection_currency_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN last_inspection_date >= DATE_SUB(CURRENT_DATE(), 365) THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of aircraft with inspections completed within the last 12 months for regulatory compliance"
    - name: "commercial_operation_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN commercial_operation_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of aircraft used for commercial operations for economic impact analysis"
    - name: "avg_hours_since_overhaul"
      expr: AVG(CAST(hours_since_last_overhaul AS DOUBLE))
      comment: "Average hours since last major overhaul for maintenance scheduling and safety monitoring"
    - name: "incident_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN incident_history_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of aircraft with recorded incident history for safety risk assessment"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`aviation_airport_operations`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Airport operational performance and economic impact metrics for NCDOT-managed airports. Tracks activity levels, infrastructure capacity, and funding eligibility for strategic planning and resource allocation."
  source: "`feip_eastus_03`.`aviation`.`airport`"
  dimensions:
    - name: "airport_name"
      expr: name
      comment: "Official airport name for facility-specific reporting"
    - name: "airport_locid"
      expr: locid
      comment: "FAA location identifier for airport identification"
    - name: "facility_type"
      expr: facility_type
      comment: "Aviation facility classification (airport, heliport, seaplane base)"
    - name: "ownership_type"
      expr: ownership_type
      comment: "Airport ownership classification (public, private, military)"
    - name: "npias_role"
      expr: npias_role
      comment: "FAA National Plan of Integrated Airport Systems classification for funding eligibility"
    - name: "npias_hub_type"
      expr: npias_hub_type
      comment: "Hub classification for commercial service airports based on passenger boardings"
    - name: "county"
      expr: county
      comment: "County location for regional analysis and economic impact assessment"
    - name: "district"
      expr: district
      comment: "NCDOT Aviation Division district for state-level coordination"
    - name: "control_tower_flag"
      expr: control_tower
      comment: "Indicates whether airport has FAA air traffic control tower"
    - name: "part_139_certificate_flag"
      expr: part_139_certificate
      comment: "Indicates whether airport holds FAA Part 139 operating certificate for commercial service"
    - name: "federal_funding_eligible_flag"
      expr: federal_funding_eligible
      comment: "Indicates eligibility for federal Airport Improvement Program grants"
    - name: "state_funding_eligible_flag"
      expr: state_funding_eligible
      comment: "Indicates eligibility for NCDOT Aviation Division state grant funding"
    - name: "activation_year"
      expr: YEAR(activation_date)
      comment: "Year airport was officially opened for operations"
  measures:
    - name: "total_airports"
      expr: COUNT(1)
      comment: "Total number of airports in the NCDOT aviation system"
    - name: "commercial_service_airports"
      expr: COUNT(CASE WHEN part_139_certificate = true THEN 1 END)
      comment: "Count of airports certified for scheduled commercial airline service"
    - name: "towered_airports"
      expr: COUNT(CASE WHEN control_tower = true THEN 1 END)
      comment: "Count of airports with FAA air traffic control towers for capacity analysis"
    - name: "total_based_aircraft"
      expr: SUM(CAST(based_aircraft_count AS DOUBLE))
      comment: "Total number of aircraft permanently based across all airports for economic impact"
    - name: "avg_based_aircraft_per_airport"
      expr: AVG(CAST(based_aircraft_count AS DOUBLE))
      comment: "Average number of based aircraft per airport for capacity planning"
    - name: "total_annual_operations"
      expr: SUM(CAST(annual_operations AS DOUBLE))
      comment: "Total aircraft takeoffs and landings across all airports for system capacity analysis"
    - name: "avg_annual_operations_per_airport"
      expr: AVG(CAST(annual_operations AS DOUBLE))
      comment: "Average annual operations per airport for activity benchmarking"
    - name: "total_annual_enplanements"
      expr: SUM(CAST(annual_enplanements AS DOUBLE))
      comment: "Total passengers boarding commercial flights across all airports for economic impact"
    - name: "avg_enplanements_per_commercial_airport"
      expr: AVG(CAST(annual_enplanements AS DOUBLE))
      comment: "Average annual passenger boardings per airport for hub classification"
    - name: "total_economic_impact_jobs"
      expr: SUM(CAST(economic_impact_jobs AS DOUBLE))
      comment: "Total jobs supported by airport operations statewide for economic development reporting"
    - name: "total_economic_impact_payroll"
      expr: SUM(CAST(economic_impact_payroll AS DOUBLE))
      comment: "Total annual payroll generated by airport-related employment for economic impact analysis"
    - name: "total_economic_impact_output"
      expr: SUM(CAST(economic_impact_output AS DOUBLE))
      comment: "Total annual economic output generated by airports for state economic contribution"
    - name: "avg_economic_impact_per_airport"
      expr: AVG(CAST(economic_impact_output AS DOUBLE))
      comment: "Average economic output per airport for investment prioritization"
    - name: "federal_funding_eligible_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN federal_funding_eligible = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of airports eligible for federal AIP grants for funding strategy"
    - name: "state_funding_eligible_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN state_funding_eligible = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of airports eligible for state grant funding for budget allocation"
    - name: "commercial_operations_rate"
      expr: ROUND(100.0 * SUM(CAST(annual_commercial_operations AS DOUBLE)) / NULLIF(SUM(CAST(annual_operations AS DOUBLE)), 0), 2)
      comment: "Percentage of total operations that are commercial airline flights for service level analysis"
    - name: "jet_aircraft_penetration"
      expr: ROUND(100.0 * SUM(CAST(jet_aircraft AS DOUBLE)) / NULLIF(SUM(CAST(based_aircraft_count AS DOUBLE)), 0), 2)
      comment: "Percentage of based aircraft that are jets for infrastructure planning"
    - name: "customs_service_availability_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN customs_service = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of airports with U.S. Customs services for international connectivity"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`aviation_airport_fees`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Airport fee revenue and billing performance metrics for aeronautical and non-aeronautical services. Tracks revenue collection, payment compliance, and airline financial relationships for airport financial management."
  source: "`feip_eastus_03`.`aviation`.`airport_fee`"
  dimensions:
    - name: "airport_code"
      expr: airport_code
      comment: "Airport identifier for facility-specific revenue analysis"
    - name: "airport_name"
      expr: airport_name
      comment: "Airport name for reporting and presentation"
    - name: "airline_code"
      expr: airline_code
      comment: "Airline designator for carrier-specific billing analysis"
    - name: "airline_name"
      expr: airline_name
      comment: "Airline name for customer relationship management"
    - name: "fee_type"
      expr: fee_type
      comment: "Category of airport service fee (landing, parking, terminal use, fuel flowage)"
    - name: "fee_category"
      expr: fee_category
      comment: "High-level classification as aeronautical or non-aeronautical revenue"
    - name: "payment_status"
      expr: payment_status
      comment: "Current payment status for accounts receivable management"
    - name: "operation_type"
      expr: operation_type
      comment: "Type of aviation operation (scheduled, charter, cargo, general aviation)"
    - name: "flight_type"
      expr: flight_type
      comment: "Classification as domestic, international, or regional for rate differentiation"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "State or federal fiscal year for financial reporting"
    - name: "accounting_period"
      expr: accounting_period
      comment: "Accounting period in YYYYMM format for monthly revenue tracking"
    - name: "transaction_month"
      expr: DATE_TRUNC('MONTH', transaction_date)
      comment: "Month of fee transaction for revenue trending"
    - name: "service_month"
      expr: DATE_TRUNC('MONTH', service_date)
      comment: "Month of service delivery for accrual accounting"
    - name: "dispute_flag"
      expr: dispute_flag
      comment: "Indicates whether airline has disputed the fee charge"
  measures:
    - name: "total_fee_transactions"
      expr: COUNT(1)
      comment: "Total number of airport fee transactions for billing volume analysis"
    - name: "total_fee_revenue"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total fee revenue charged to airlines for financial performance tracking"
    - name: "total_base_fee_revenue"
      expr: SUM(CAST(base_fee_amount AS DOUBLE))
      comment: "Total base fee revenue before adjustments for rate analysis"
    - name: "total_discount_amount"
      expr: SUM(CAST(discount_amount AS DOUBLE))
      comment: "Total discounts applied to fees for incentive program evaluation"
    - name: "total_surcharge_amount"
      expr: SUM(CAST(surcharge_amount AS DOUBLE))
      comment: "Total surcharges added to fees for peak pricing analysis"
    - name: "total_tax_amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax collected on airport fees for tax remittance"
    - name: "total_refund_amount"
      expr: SUM(CAST(refund_amount AS DOUBLE))
      comment: "Total refunds issued to airlines for dispute resolution tracking"
    - name: "total_late_payment_penalties"
      expr: SUM(CAST(late_payment_penalty_amount AS DOUBLE))
      comment: "Total late payment penalties assessed for collections management"
    - name: "total_interest_charges"
      expr: SUM(CAST(interest_amount AS DOUBLE))
      comment: "Total interest charges on overdue payments for revenue recovery"
    - name: "avg_fee_per_transaction"
      expr: AVG(CAST(fee_amount AS DOUBLE))
      comment: "Average fee amount per transaction for pricing benchmarking"
    - name: "total_landing_count"
      expr: SUM(CAST(landing_count AS DOUBLE))
      comment: "Total aircraft landings billed for operational activity tracking"
    - name: "total_parking_hours"
      expr: SUM(CAST(parking_hours AS DOUBLE))
      comment: "Total aircraft parking hours billed for apron utilization analysis"
    - name: "total_passenger_count"
      expr: SUM(CAST(passenger_count AS DOUBLE))
      comment: "Total passengers associated with fee transactions for passenger facility charge analysis"
    - name: "total_fuel_gallons"
      expr: SUM(CAST(fuel_gallons AS DOUBLE))
      comment: "Total fuel gallons dispensed for fuel flowage fee revenue"
    - name: "payment_collection_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN payment_status = 'Paid' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of fees paid for accounts receivable performance monitoring"
    - name: "on_time_payment_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN payment_date <= due_date THEN 1 END) / NULLIF(COUNT(CASE WHEN payment_date IS NOT NULL THEN 1 END), 0), 2)
      comment: "Percentage of fees paid by due date for airline payment compliance"
    - name: "dispute_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN dispute_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of fees disputed by airlines for billing quality assessment"
    - name: "discount_rate"
      expr: ROUND(100.0 * SUM(CAST(discount_amount AS DOUBLE)) / NULLIF(SUM(CAST(base_fee_amount AS DOUBLE)), 0), 2)
      comment: "Percentage discount from base fees for incentive program effectiveness"
    - name: "avg_revenue_per_landing"
      expr: AVG(CASE WHEN landing_count > 0 THEN CAST(fee_amount AS DOUBLE) / CAST(landing_count AS DOUBLE) END)
      comment: "Average fee revenue per aircraft landing for yield management"
    - name: "avg_revenue_per_passenger"
      expr: AVG(CASE WHEN passenger_count > 0 THEN CAST(fee_amount AS DOUBLE) / CAST(passenger_count AS DOUBLE) END)
      comment: "Average fee revenue per passenger for passenger facility charge analysis"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`aviation_flight_schedule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Flight schedule performance and on-time metrics for commercial airline operations at NCDOT-managed airports. Tracks schedule adherence, delays, cancellations, and service reliability for airport operations management."
  source: "`feip_eastus_03`.`aviation`.`flight_schedule`"
  dimensions:
    - name: "airport_name"
      expr: airport_name
      comment: "Airport facility name for location-specific performance analysis"
    - name: "airline_name"
      expr: airline_name
      comment: "Airline operating the flight for carrier performance tracking"
    - name: "flight_type"
      expr: flight_type
      comment: "Indicates whether flight is arriving or departing"
    - name: "flight_status"
      expr: flight_status
      comment: "Current operational status of the scheduled flight"
    - name: "service_type"
      expr: service_type
      comment: "Type of aviation service (scheduled, charter, cargo)"
    - name: "origin_airport_name"
      expr: origin_airport_name
      comment: "Origin airport for route analysis"
    - name: "destination_airport_name"
      expr: destination_airport_name
      comment: "Destination airport for route analysis"
    - name: "aircraft_type"
      expr: aircraft_type
      comment: "ICAO aircraft type designator for fleet mix analysis"
    - name: "international_indicator"
      expr: international_indicator
      comment: "Indicates whether flight crosses international borders"
    - name: "season_code"
      expr: season_code
      comment: "IATA scheduling season (summer or winter) for seasonal analysis"
    - name: "scheduled_month"
      expr: DATE_TRUNC('MONTH', scheduled_date)
      comment: "Month of scheduled flight for monthly performance trending"
    - name: "delay_code"
      expr: delay_code
      comment: "IATA delay code indicating reason for flight delay"
    - name: "cancellation_code"
      expr: cancellation_code
      comment: "Code indicating reason for flight cancellation"
  measures:
    - name: "total_scheduled_flights"
      expr: COUNT(1)
      comment: "Total number of scheduled flights for service level analysis"
    - name: "completed_flights"
      expr: COUNT(CASE WHEN flight_status = 'Completed' THEN 1 END)
      comment: "Count of flights that completed operations for completion rate calculation"
    - name: "cancelled_flights"
      expr: COUNT(CASE WHEN flight_status = 'Cancelled' THEN 1 END)
      comment: "Count of cancelled flights for reliability analysis"
    - name: "delayed_flights"
      expr: COUNT(CASE WHEN delay_minutes > 0 THEN 1 END)
      comment: "Count of flights with any delay for on-time performance tracking"
    - name: "total_delay_minutes"
      expr: SUM(CAST(delay_minutes AS DOUBLE))
      comment: "Total delay minutes across all flights for operational efficiency analysis"
    - name: "avg_delay_minutes"
      expr: AVG(CAST(delay_minutes AS DOUBLE))
      comment: "Average delay per flight for delay severity assessment"
    - name: "avg_delay_minutes_for_delayed_flights"
      expr: AVG(CASE WHEN delay_minutes > 0 THEN CAST(delay_minutes AS DOUBLE) END)
      comment: "Average delay for flights that were delayed (excluding on-time flights)"
    - name: "total_passenger_capacity"
      expr: SUM(CAST(passenger_capacity AS DOUBLE))
      comment: "Total passenger seats available across all scheduled flights for capacity planning"
    - name: "avg_passenger_capacity_per_flight"
      expr: AVG(CAST(passenger_capacity AS DOUBLE))
      comment: "Average passenger capacity per flight for aircraft sizing analysis"
    - name: "total_flight_distance"
      expr: SUM(CAST(distance_miles AS DOUBLE))
      comment: "Total flight distance across all scheduled flights for network analysis"
    - name: "avg_flight_distance"
      expr: AVG(CAST(distance_miles AS DOUBLE))
      comment: "Average flight distance for route length analysis"
    - name: "completion_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN flight_status = 'Completed' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of scheduled flights that completed operations for service reliability"
    - name: "cancellation_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN flight_status = 'Cancelled' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of scheduled flights cancelled for reliability monitoring"
    - name: "on_time_performance_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN delay_minutes <= 15 OR delay_minutes IS NULL THEN 1 END) / NULLIF(COUNT(CASE WHEN flight_status = 'Completed' THEN 1 END), 0), 2)
      comment: "Percentage of completed flights arriving within 15 minutes of schedule (DOT standard)"
    - name: "delay_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN delay_minutes > 0 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of flights with any delay for operational performance tracking"
    - name: "significant_delay_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN delay_minutes > 60 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of flights delayed more than 60 minutes for severe delay monitoring"
    - name: "international_flight_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN international_indicator = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of flights that are international for customs resource planning"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`aviation_runway_infrastructure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Runway infrastructure condition and capacity metrics for airport capital planning and safety management. Tracks pavement condition, operational status, and design standards for maintenance prioritization and FAA compliance."
  source: "`feip_eastus_03`.`aviation`.`runway`"
  dimensions:
    - name: "airport_id"
      expr: CAST(airport_id AS STRING)
      comment: "Airport identifier for facility-specific runway analysis"
    - name: "runway_designation"
      expr: designation
      comment: "Runway identifier based on magnetic heading for specific runway tracking"
    - name: "surface_type"
      expr: surface_type
      comment: "Runway surface material for maintenance planning"
    - name: "surface_condition"
      expr: surface_condition
      comment: "Current assessed condition of runway surface"
    - name: "operational_status"
      expr: operational_status
      comment: "Current operational status indicating availability for aircraft operations"
    - name: "ownership_type"
      expr: ownership_type
      comment: "Ownership classification of runway facility"
    - name: "marking_type"
      expr: marking_type
      comment: "Classification of runway markings based on instrument approach type"
    - name: "edge_lighting_type"
      expr: edge_lighting_type
      comment: "Intensity classification of runway edge lighting system"
    - name: "centerline_lighting_flag"
      expr: centerline_lighting
      comment: "Indicates whether runway has centerline lighting for low-visibility operations"
    - name: "construction_year"
      expr: CAST(construction_year AS STRING)
      comment: "Year runway was originally constructed for age analysis"
    - name: "last_rehab_year"
      expr: CAST(last_major_rehabilitation_year AS STRING)
      comment: "Year of last major rehabilitation for lifecycle tracking"
  measures:
    - name: "total_runways"
      expr: COUNT(1)
      comment: "Total number of runways in the NCDOT aviation system"
    - name: "operational_runways"
      expr: COUNT(CASE WHEN operational_status = 'Open' THEN 1 END)
      comment: "Count of runways currently open for aircraft operations"
    - name: "closed_runways"
      expr: COUNT(CASE WHEN operational_status IN ('Closed', 'Temporarily Closed') THEN 1 END)
      comment: "Count of runways closed or temporarily closed for maintenance impact analysis"
    - name: "total_runway_length"
      expr: SUM(CAST(length_ft AS DOUBLE))
      comment: "Total runway length across all runways for system capacity"
    - name: "avg_runway_length"
      expr: AVG(CAST(length_ft AS DOUBLE))
      comment: "Average runway length for aircraft accommodation analysis"
    - name: "avg_runway_width"
      expr: AVG(CAST(width_ft AS DOUBLE))
      comment: "Average runway width for design standard compliance"
    - name: "avg_pci_score"
      expr: AVG(CAST(pci_score AS DOUBLE))
      comment: "Average Pavement Condition Index score for overall pavement health assessment"
    - name: "poor_condition_runway_count"
      expr: COUNT(CASE WHEN pci_score < 55 THEN 1 END)
      comment: "Count of runways in poor condition (PCI < 55) for maintenance prioritization"
    - name: "good_condition_runway_count"
      expr: COUNT(CASE WHEN pci_score >= 70 THEN 1 END)
      comment: "Count of runways in good condition (PCI >= 70) for asset performance tracking"
    - name: "avg_friction_coefficient"
      expr: AVG(CAST(friction_coefficient AS DOUBLE))
      comment: "Average runway friction coefficient for safety and braking performance"
    - name: "precision_approach_runway_count"
      expr: COUNT(CASE WHEN marking_type = 'Precision' THEN 1 END)
      comment: "Count of runways with precision approach markings for IFR capability"
    - name: "lighted_runway_count"
      expr: COUNT(CASE WHEN edge_lighting_type IS NOT NULL AND edge_lighting_type != 'None' THEN 1 END)
      comment: "Count of runways with edge lighting for night operations capability"
    - name: "centerline_lighting_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN centerline_lighting = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of runways with centerline lighting for low-visibility operations"
    - name: "avg_base_end_elevation"
      expr: AVG(CAST(base_end_elevation_ft AS DOUBLE))
      comment: "Average base end elevation for aircraft performance calculations"
    - name: "avg_runway_age_years"
      expr: AVG(YEAR(CURRENT_DATE()) - construction_year)
      comment: "Average age of runways since original construction for lifecycle planning"
    - name: "pavement_condition_compliance_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN pci_score >= 70 THEN 1 END) / NULLIF(COUNT(CASE WHEN pci_score IS NOT NULL THEN 1 END), 0), 2)
      comment: "Percentage of runways meeting good condition threshold (PCI >= 70) for FAA compliance"
    - name: "obstruction_clearance_compliance_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN obstruction_clearance_compliant = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of runways meeting FAA obstruction clearance standards for safety compliance"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`aviation_pilot_licensing`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pilot license certification and currency metrics for state aviation workforce and safety oversight. Tracks license status, medical fitness, flight experience, and regulatory compliance for pilot qualification management."
  source: "`feip_eastus_03`.`aviation`.`pilot_license`"
  dimensions:
    - name: "license_type"
      expr: license_type
      comment: "Category of pilot license (student, private, commercial, ATP) for qualification analysis"
    - name: "license_class"
      expr: license_class
      comment: "Aircraft class certification (single-engine, multi-engine, helicopter) for operational capability"
    - name: "license_status"
      expr: status
      comment: "Current operational status of pilot license for compliance monitoring"
    - name: "medical_certificate_class"
      expr: medical_certificate_class
      comment: "Class of medical certificate (first, second, third) for medical fitness tracking"
    - name: "medical_certificate_status"
      expr: medical_certificate_status
      comment: "Current status of medical certificate for flight eligibility"
    - name: "instrument_rating_flag"
      expr: instrument_rating_flag
      comment: "Indicates whether pilot holds instrument rating for IFR operations"
    - name: "multi_engine_rating_flag"
      expr: multi_engine_rating_flag
      comment: "Indicates whether pilot holds multi-engine rating"
    - name: "flight_instructor_rating_flag"
      expr: flight_instructor_rating_flag
      comment: "Indicates whether pilot holds CFI rating for instruction capability"
    - name: "nc_aviation_registration_flag"
      expr: nc_aviation_registration_flag
      comment: "Indicates whether pilot is registered with NCDOT Aviation Division"
    - name: "state_code"
      expr: state_code
      comment: "State of pilot residence for geographic distribution analysis"
    - name: "issue_year"
      expr: YEAR(issue_date)
      comment: "Year license was issued for cohort analysis"
    - name: "expiration_year"
      expr: YEAR(expiration_date)
      comment: "Year license expires for renewal planning"
  measures:
    - name: "total_pilot_licenses"
      expr: COUNT(1)
      comment: "Total number of pilot license records for workforce size analysis"
    - name: "active_pilot_licenses"
      expr: COUNT(CASE WHEN status = 'Active' THEN 1 END)
      comment: "Count of active pilot licenses for current workforce capacity"
    - name: "expired_pilot_licenses"
      expr: COUNT(CASE WHEN status = 'Expired' THEN 1 END)
      comment: "Count of expired licenses for renewal outreach"
    - name: "suspended_pilot_licenses"
      expr: COUNT(CASE WHEN status = 'Suspended' THEN 1 END)
      comment: "Count of suspended licenses for safety oversight"
    - name: "instrument_rated_pilots"
      expr: COUNT(CASE WHEN instrument_rating_flag = true THEN 1 END)
      comment: "Count of pilots with instrument ratings for IFR capability assessment"
    - name: "multi_engine_rated_pilots"
      expr: COUNT(CASE WHEN multi_engine_rating_flag = true THEN 1 END)
      comment: "Count of pilots with multi-engine ratings for complex aircraft operations"
    - name: "flight_instructors"
      expr: COUNT(CASE WHEN flight_instructor_rating_flag = true THEN 1 END)
      comment: "Count of certified flight instructors for training capacity"
    - name: "nc_registered_pilots"
      expr: COUNT(CASE WHEN nc_aviation_registration_flag = true THEN 1 END)
      comment: "Count of pilots registered with NCDOT Aviation Division for state coordination"
    - name: "total_flight_hours"
      expr: SUM(CAST(total_flight_hours AS DOUBLE))
      comment: "Cumulative flight hours across all pilots for experience assessment"
    - name: "avg_flight_hours_per_pilot"
      expr: AVG(CAST(total_flight_hours AS DOUBLE))
      comment: "Average flight hours per pilot for experience benchmarking"
    - name: "total_pic_hours"
      expr: SUM(CAST(pilot_in_command_hours AS DOUBLE))
      comment: "Total pilot-in-command hours for command experience tracking"
    - name: "avg_pic_hours_per_pilot"
      expr: AVG(CAST(pilot_in_command_hours AS DOUBLE))
      comment: "Average PIC hours per pilot for command qualification"
    - name: "total_instrument_hours"
      expr: SUM(CAST(instrument_flight_hours AS DOUBLE))
      comment: "Total instrument flight hours for IFR proficiency assessment"
    - name: "avg_instrument_hours_per_pilot"
      expr: AVG(CAST(instrument_flight_hours AS DOUBLE))
      comment: "Average instrument hours per pilot for IFR currency"
    - name: "medical_currency_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN medical_certificate_status = 'Valid' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pilots with valid medical certificates for flight eligibility"
    - name: "instrument_rating_penetration"
      expr: ROUND(100.0 * COUNT(CASE WHEN instrument_rating_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pilots with instrument ratings for IFR capability"
    - name: "flight_instructor_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN flight_instructor_rating_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pilots certified as flight instructors for training capacity"
    - name: "violation_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN violations_count > 0 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pilots with recorded FAR violations for safety oversight"
    - name: "accident_involvement_rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN accidents_count > 0 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pilots involved in reportable accidents for safety risk assessment"
$$;