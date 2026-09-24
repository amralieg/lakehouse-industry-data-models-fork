-- Metric views for domain: highway | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`highway_construction_activity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Construction activity performance metrics tracking project execution, cost efficiency, schedule adherence, and safety outcomes for highway construction operations"
  source: "`feip_eastus_03`.`highway`.`construction_activity`"
  dimensions:
    - name: "activity_type"
      expr: activity_type
      comment: "Classification of construction activity (earthwork, paving, bridge work, drainage)"
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where construction activity is located"
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT Division of Highways regional division number (1-14)"
    - name: "contractor_name"
      expr: contractor_name
      comment: "Legal name of the contractor performing the construction activity"
    - name: "status"
      expr: status
      comment: "Current status of construction activity (planned, active, completed, suspended)"
    - name: "federal_aid_project"
      expr: CASE WHEN federal_aid_project = true THEN 'Federal Aid' ELSE 'State Funded' END
      comment: "Indicates whether construction activity is federally funded"
    - name: "actual_start_year"
      expr: YEAR(actual_start_date)
      comment: "Year when construction activity actually commenced"
    - name: "actual_start_month"
      expr: DATE_TRUNC('MONTH', actual_start_date)
      comment: "Month when construction activity actually commenced"
  measures:
    - name: "total_construction_activities"
      expr: COUNT(1)
      comment: "Total number of construction activities tracked in the system"
    - name: "total_actual_cost"
      expr: SUM(CAST(actual_cost AS DOUBLE))
      comment: "Total actual cost incurred across all construction activities in dollars"
    - name: "total_estimated_cost"
      expr: SUM(CAST(estimated_cost AS DOUBLE))
      comment: "Total estimated cost for all construction activities in dollars"
    - name: "cost_variance_pct"
      expr: ROUND(100.0 * (SUM(CAST(actual_cost AS DOUBLE)) - SUM(CAST(estimated_cost AS DOUBLE))) / NULLIF(SUM(CAST(estimated_cost AS DOUBLE)), 0), 2)
      comment: "Percentage variance between actual and estimated costs - key metric for budget control and contractor performance"
    - name: "avg_completion_percentage"
      expr: AVG(CAST(completion_percentage AS DOUBLE))
      comment: "Average completion percentage across construction activities - indicates overall project portfolio progress"
    - name: "total_labor_cost"
      expr: SUM(CAST(labor_cost AS DOUBLE))
      comment: "Total labor cost across all construction activities in dollars"
    - name: "total_material_cost"
      expr: SUM(CAST(material_cost AS DOUBLE))
      comment: "Total material cost across all construction activities in dollars"
    - name: "total_equipment_cost"
      expr: SUM(CAST(equipment_cost AS DOUBLE))
      comment: "Total equipment cost across all construction activities in dollars"
    - name: "labor_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(labor_cost AS DOUBLE)) / NULLIF(SUM(CAST(actual_cost AS DOUBLE)), 0), 2)
      comment: "Labor cost as percentage of total actual cost - key metric for resource allocation and productivity analysis"
    - name: "material_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(material_cost AS DOUBLE)) / NULLIF(SUM(CAST(actual_cost AS DOUBLE)), 0), 2)
      comment: "Material cost as percentage of total actual cost - indicates material efficiency and procurement effectiveness"
    - name: "equipment_cost_pct"
      expr: ROUND(100.0 * SUM(CAST(equipment_cost AS DOUBLE)) / NULLIF(SUM(CAST(actual_cost AS DOUBLE)), 0), 2)
      comment: "Equipment cost as percentage of total actual cost - measures equipment utilization efficiency"
    - name: "total_weather_delay_hours"
      expr: SUM(CAST(weather_delay_hours AS DOUBLE))
      comment: "Total hours of work delay attributed to adverse weather conditions"
    - name: "avg_weather_delay_hours"
      expr: AVG(CAST(weather_delay_hours AS DOUBLE))
      comment: "Average weather delay hours per construction activity - indicates climate impact on project schedules"
    - name: "total_equipment_hours"
      expr: SUM(CAST(equipment_hours AS DOUBLE))
      comment: "Total hours of equipment operation across all construction activities"
    - name: "equipment_utilization_rate"
      expr: ROUND(SUM(CAST(equipment_hours AS DOUBLE)) / NULLIF(SUM(CAST(duration_days AS DOUBLE)) * 24, 0), 4)
      comment: "Equipment utilization rate as ratio of equipment hours to total available hours - key efficiency metric for asset management"
    - name: "total_safety_incidents"
      expr: SUM(CAST(safety_incident_count AS DOUBLE))
      comment: "Total number of safety incidents across all construction activities"
    - name: "safety_incident_rate"
      expr: ROUND(SUM(CAST(safety_incident_count AS DOUBLE)) / NULLIF(COUNT(1), 0), 4)
      comment: "Average safety incidents per construction activity - critical safety performance indicator for risk management"
    - name: "osha_recordable_incident_count"
      expr: SUM(CASE WHEN osha_recordable_incident = true THEN 1 ELSE 0 END)
      comment: "Total number of OSHA-recordable safety incidents - regulatory compliance metric"
    - name: "osha_incident_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN osha_recordable_incident = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of construction activities with OSHA-recordable incidents - key safety compliance metric"
    - name: "dbe_participation_avg"
      expr: AVG(CAST(dbe_participation_percentage AS DOUBLE))
      comment: "Average DBE participation percentage across construction activities - federal compliance and equity metric"
    - name: "quality_assurance_pass_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN quality_assurance_passed = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of construction activities passing quality assurance - indicates construction quality and contractor performance"
    - name: "stormwater_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN stormwater_compliance = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of construction activities in stormwater compliance - environmental regulatory metric"
    - name: "avg_quantity_completion_rate"
      expr: ROUND(100.0 * AVG(CAST(quantity_completed AS DOUBLE) / NULLIF(CAST(quantity_planned AS DOUBLE), 0)), 2)
      comment: "Average percentage of planned quantity completed - measures project execution effectiveness"
    - name: "total_lane_closures"
      expr: SUM(CAST(lane_closure_count AS DOUBLE))
      comment: "Total number of lane closures across all construction activities - traffic impact metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`highway_pavement_condition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pavement condition assessment metrics tracking infrastructure health, deterioration rates, and maintenance needs for highway asset management and capital planning"
  source: "`feip_eastus_03`.`highway`.`pavement_condition`"
  dimensions:
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where pavement section is located"
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT highway division number responsible for maintaining pavement section"
    - name: "functional_class"
      expr: functional_class
      comment: "FHWA functional classification of the roadway section"
    - name: "surface_type"
      expr: surface_type
      comment: "Type of pavement surface material (asphalt, concrete, composite)"
    - name: "pci_rating"
      expr: pci_rating
      comment: "Qualitative pavement condition rating (Excellent, Very Good, Good, Fair, Poor, Very Poor, Serious, Failed)"
    - name: "iri_rating"
      expr: iri_rating
      comment: "Qualitative ride quality rating based on IRI value (Very Good, Good, Fair, Poor, Very Poor)"
    - name: "inspection_year"
      expr: CAST(inspection_year AS STRING)
      comment: "Calendar year in which pavement condition assessment was conducted"
    - name: "inspection_month"
      expr: DATE_TRUNC('MONTH', inspection_date)
      comment: "Month when pavement condition assessment was performed"
    - name: "nhs_indicator"
      expr: CASE WHEN nhs_indicator = true THEN 'NHS' ELSE 'Non-NHS' END
      comment: "Indicates whether pavement section is part of National Highway System"
    - name: "treatment_priority"
      expr: treatment_priority
      comment: "Priority level for implementing recommended pavement treatment"
    - name: "recommended_treatment"
      expr: recommended_treatment
      comment: "Recommended maintenance or rehabilitation treatment based on condition assessment"
  measures:
    - name: "total_pavement_sections_assessed"
      expr: COUNT(1)
      comment: "Total number of pavement condition assessments performed"
    - name: "total_section_miles"
      expr: SUM(CAST(section_length_miles AS DOUBLE))
      comment: "Total centerline miles of pavement sections assessed"
    - name: "avg_pci_score"
      expr: AVG(CAST(pci_score AS DOUBLE))
      comment: "Average Pavement Condition Index score - primary metric for overall pavement network health"
    - name: "avg_iri_value"
      expr: AVG(CAST(iri_value AS DOUBLE))
      comment: "Average International Roughness Index - measures ride quality and user comfort"
    - name: "pct_excellent_condition"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(pci_score AS DOUBLE) >= 85 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pavement sections in excellent condition (PCI >= 85) - key performance target for asset management"
    - name: "pct_good_or_better"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(pci_score AS DOUBLE) >= 55 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pavement sections in good or better condition (PCI >= 55) - strategic performance measure"
    - name: "pct_poor_or_worse"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(pci_score AS DOUBLE) < 40 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pavement sections in poor or worse condition (PCI < 40) - indicates backlog and funding needs"
    - name: "avg_rutting_depth"
      expr: AVG(CAST(rutting_depth_inches AS DOUBLE))
      comment: "Average rutting depth in inches - indicates structural distress and safety concerns"
    - name: "avg_alligator_cracking_pct"
      expr: AVG(CAST(alligator_cracking_percent AS DOUBLE))
      comment: "Average percentage of pavement area with alligator cracking - indicates structural failure"
    - name: "avg_patching_pct"
      expr: AVG(CAST(patching_percent AS DOUBLE))
      comment: "Average percentage of pavement area that has been patched - indicates maintenance history and deterioration"
    - name: "total_potholes"
      expr: SUM(CAST(pothole_count AS DOUBLE))
      comment: "Total number of potholes identified across all pavement sections"
    - name: "avg_potholes_per_mile"
      expr: ROUND(SUM(CAST(pothole_count AS DOUBLE)) / NULLIF(SUM(CAST(section_length_miles AS DOUBLE)), 0), 2)
      comment: "Average potholes per mile - indicates pavement distress density and maintenance needs"
    - name: "total_estimated_treatment_cost"
      expr: SUM(CAST(estimated_treatment_cost AS DOUBLE))
      comment: "Total estimated cost to implement recommended pavement treatments - capital planning metric"
    - name: "avg_treatment_cost_per_mile"
      expr: ROUND(SUM(CAST(estimated_treatment_cost AS DOUBLE)) / NULLIF(SUM(CAST(section_length_miles AS DOUBLE)), 0), 2)
      comment: "Average treatment cost per mile - unit cost metric for budget planning and resource allocation"
    - name: "avg_remaining_service_life"
      expr: AVG(CAST(remaining_service_life_years AS DOUBLE))
      comment: "Average remaining service life in years before major rehabilitation required - asset lifecycle metric"
    - name: "pct_critical_service_life"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(remaining_service_life_years AS DOUBLE) <= 3 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sections with 3 or fewer years remaining service life - indicates urgent capital needs"
    - name: "avg_pavement_age"
      expr: AVG(CAST(pavement_age_years AS DOUBLE))
      comment: "Average pavement age in years since construction or reconstruction"
    - name: "avg_years_since_overlay"
      expr: AVG(CAST(years_since_overlay AS DOUBLE))
      comment: "Average years since last overlay or resurfacing treatment"
    - name: "avg_skid_resistance"
      expr: AVG(CAST(skid_resistance_number AS DOUBLE))
      comment: "Average skid resistance measurement - critical safety metric for friction and crash prevention"
    - name: "pct_federal_aid_eligible"
      expr: ROUND(100.0 * SUM(CASE WHEN federal_aid_eligible = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of pavement sections eligible for federal funding assistance"
    - name: "avg_aadt"
      expr: AVG(CAST(aadt AS DOUBLE))
      comment: "Average Annual Average Daily Traffic across assessed sections - indicates traffic loading"
    - name: "avg_truck_aadt"
      expr: AVG(CAST(truck_aadt AS DOUBLE))
      comment: "Average truck traffic volume - indicates heavy vehicle loading impact on pavement"
    - name: "quality_assurance_pass_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN quality_assurance_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments passing quality assurance review - data quality metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`highway_pavement_section`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pavement section inventory and performance metrics tracking asset characteristics, structural capacity, and lifecycle status for strategic asset management and investment planning"
  source: "`feip_eastus_03`.`highway`.`pavement_section`"
  dimensions:
    - name: "county_code"
      expr: county_code
      comment: "North Carolina county code where pavement section is located"
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT Division of Highways division number responsible for maintenance"
    - name: "surface_type_code"
      expr: surface_type_code
      comment: "Code representing pavement surface type (AC, PCC, COMP, UNPAVED)"
    - name: "pavement_structure_type"
      expr: pavement_structure_type
      comment: "Classification of pavement structural design (FLEXIBLE, RIGID, COMPOSITE)"
    - name: "functional_class_code"
      expr: functional_class_code
      comment: "FHWA functional classification code (1=Interstate to 9=Local)"
    - name: "nhs_indicator"
      expr: CASE WHEN nhs_indicator = true THEN 'NHS' ELSE 'Non-NHS' END
      comment: "Indicates whether pavement section is part of National Highway System"
    - name: "urban_rural_designation"
      expr: urban_rural_designation
      comment: "Classification as urban, rural, or small urban area"
    - name: "median_type"
      expr: median_type
      comment: "Type of median separating opposing traffic (NONE, PAINTED, RAISED, BARRIER, DEPRESSED)"
    - name: "construction_year"
      expr: CAST(construction_year AS STRING)
      comment: "Year when pavement section was originally constructed"
    - name: "climate_zone"
      expr: climate_zone
      comment: "North Carolina climate zone (COASTAL, PIEDMONT, MOUNTAIN)"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary funding source (STATE, FEDERAL, LOCAL, MIXED)"
    - name: "status"
      expr: status
      comment: "Current operational status (ACTIVE, INACTIVE, PLANNED, UNDER_CONSTRUCTION, DECOMMISSIONED)"
    - name: "overall_condition_rating"
      expr: overall_condition_rating
      comment: "Composite overall condition rating for prioritization"
  measures:
    - name: "total_pavement_sections"
      expr: COUNT(1)
      comment: "Total number of pavement sections in the highway network inventory"
    - name: "total_centerline_miles"
      expr: SUM(CAST(section_length_miles AS DOUBLE))
      comment: "Total centerline miles of pavement sections - primary asset inventory metric"
    - name: "total_lane_miles"
      expr: SUM(CAST(section_length_miles AS DOUBLE) * CAST(number_of_lanes AS DOUBLE))
      comment: "Total lane miles across all pavement sections - capacity and maintenance workload metric"
    - name: "avg_pci_value"
      expr: AVG(CAST(pci_value AS DOUBLE))
      comment: "Average Pavement Condition Index across all sections - network-wide health indicator"
    - name: "avg_iri_value"
      expr: AVG(CAST(iri_value AS DOUBLE))
      comment: "Average International Roughness Index - network-wide ride quality metric"
    - name: "avg_structural_number"
      expr: AVG(CAST(structural_number AS DOUBLE))
      comment: "Average AASHTO Structural Number - indicates overall pavement structural capacity"
    - name: "avg_design_thickness"
      expr: AVG(CAST(design_thickness_inches AS DOUBLE))
      comment: "Average total design thickness in inches across pavement sections"
    - name: "avg_pavement_age"
      expr: AVG(CAST(pavement_age_years AS DOUBLE))
      comment: "Average pavement age in years - indicates asset maturity and replacement needs"
    - name: "avg_remaining_service_life"
      expr: AVG(CAST(remaining_service_life_years AS DOUBLE))
      comment: "Average remaining service life in years - critical for capital planning and budget forecasting"
    - name: "pct_beyond_design_life"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(pavement_age_years AS DOUBLE) > CAST(design_life_years AS DOUBLE) THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sections beyond design life - indicates deferred maintenance and replacement backlog"
    - name: "total_aadt"
      expr: SUM(CAST(aadt AS DOUBLE))
      comment: "Total Annual Average Daily Traffic across all sections"
    - name: "avg_aadt"
      expr: AVG(CAST(aadt AS DOUBLE))
      comment: "Average Annual Average Daily Traffic per section - indicates traffic loading"
    - name: "avg_truck_percentage"
      expr: AVG(CAST(truck_percentage AS DOUBLE))
      comment: "Average truck percentage across sections - indicates heavy vehicle impact on pavement deterioration"
    - name: "total_estimated_treatment_cost"
      expr: SUM(CAST(estimated_treatment_cost AS DOUBLE))
      comment: "Total estimated cost for recommended treatments - capital needs assessment metric"
    - name: "avg_treatment_cost_per_mile"
      expr: ROUND(SUM(CAST(estimated_treatment_cost AS DOUBLE)) / NULLIF(SUM(CAST(section_length_miles AS DOUBLE)), 0), 2)
      comment: "Average treatment cost per centerline mile - unit cost for budget planning"
    - name: "avg_friction_number"
      expr: AVG(CAST(friction_number AS DOUBLE))
      comment: "Average skid resistance measurement - network-wide safety metric"
    - name: "avg_noise_level"
      expr: AVG(CAST(noise_level_db AS DOUBLE))
      comment: "Average tire-pavement noise level in decibels - environmental impact metric"
    - name: "pct_warranty_sections"
      expr: ROUND(100.0 * SUM(CASE WHEN warranty_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sections under warranty - indicates recent construction and contractor accountability"
    - name: "total_construction_cost"
      expr: SUM(CAST(construction_cost AS DOUBLE))
      comment: "Total historical construction cost across all sections - asset valuation metric"
    - name: "avg_construction_cost_per_mile"
      expr: ROUND(SUM(CAST(construction_cost AS DOUBLE)) / NULLIF(SUM(CAST(section_length_miles AS DOUBLE)), 0), 2)
      comment: "Average construction cost per mile - historical unit cost for benchmarking"
    - name: "pct_federal_funded"
      expr: ROUND(100.0 * SUM(CASE WHEN funding_source IN ('FEDERAL', 'MIXED') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sections with federal funding - indicates federal aid dependency"
    - name: "pct_stip_projects"
      expr: ROUND(100.0 * SUM(CASE WHEN stip_project_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sections in State Transportation Improvement Program - indicates planned investment"
    - name: "avg_rutting_depth"
      expr: AVG(CAST(rutting_depth_inches AS DOUBLE))
      comment: "Average rutting depth in inches - structural distress indicator"
    - name: "avg_alligator_cracking_pct"
      expr: AVG(CAST(alligator_cracking_percent AS DOUBLE))
      comment: "Average percentage of area with alligator cracking - structural failure indicator"
    - name: "avg_patching_pct"
      expr: AVG(CAST(patching_percent AS DOUBLE))
      comment: "Average percentage of area patched - maintenance history indicator"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`highway_segment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Highway segment inventory and operational metrics tracking network characteristics, traffic volumes, condition ratings, and infrastructure features for system-wide performance monitoring and planning"
  source: "`feip_eastus_03`.`highway`.`segment`"
  dimensions:
    - name: "functional_class_code"
      expr: functional_class_code
      comment: "FHWA functional classification code (1=Interstate to 7=Local)"
    - name: "jurisdiction_name"
      expr: jurisdiction_name
      comment: "Governmental entity responsible for maintaining and operating the segment"
    - name: "county_name"
      expr: county_name
      comment: "Name of the county in which the segment is located"
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT Division number responsible for maintenance (1-14)"
    - name: "nhs_indicator"
      expr: CASE WHEN nhs_indicator = true THEN 'NHS' ELSE 'Non-NHS' END
      comment: "Indicates whether segment is part of National Highway System"
    - name: "surface_type"
      expr: surface_type
      comment: "Type of pavement surface material (Asphalt, Concrete, Composite, Unpaved)"
    - name: "median_type"
      expr: median_type
      comment: "Type of median separating opposing traffic flows"
    - name: "access_control"
      expr: access_control
      comment: "Level of access control (Full, Partial, None)"
    - name: "terrain_type"
      expr: terrain_type
      comment: "General terrain classification (Flat, Rolling, Mountainous)"
    - name: "urban_code"
      expr: urban_code
      comment: "Census-defined urban area code if located within urbanized area"
    - name: "facility_type"
      expr: facility_type
      comment: "Type of highway facility (mainline, ramp, collector-distributor)"
    - name: "status"
      expr: status
      comment: "Current operational status of the highway segment"
    - name: "maintenance_priority"
      expr: maintenance_priority
      comment: "Priority level for maintenance planning and resource allocation"
    - name: "construction_year"
      expr: CAST(construction_year AS STRING)
      comment: "Year when segment was originally constructed"
  measures:
    - name: "total_segments"
      expr: COUNT(1)
      comment: "Total number of highway segments in the network inventory"
    - name: "total_centerline_miles"
      expr: SUM(CAST(length_miles AS DOUBLE))
      comment: "Total centerline miles of highway segments - primary network size metric"
    - name: "total_lane_miles"
      expr: SUM(CAST(length_miles AS DOUBLE) * CAST(through_lanes AS DOUBLE))
      comment: "Total lane miles across all segments - capacity and maintenance workload metric"
    - name: "avg_pavement_condition_rating"
      expr: AVG(CAST(pavement_condition_rating AS DOUBLE))
      comment: "Average pavement condition rating across segments - network health indicator"
    - name: "avg_iri_value"
      expr: AVG(CAST(iri_value AS DOUBLE))
      comment: "Average International Roughness Index - network-wide ride quality metric"
    - name: "avg_psi_value"
      expr: AVG(CAST(psi_value AS DOUBLE))
      comment: "Average Present Serviceability Index - user comfort metric"
    - name: "total_vehicle_miles_traveled"
      expr: SUM(CAST(aadt AS DOUBLE) * CAST(length_miles AS DOUBLE) * 365)
      comment: "Total annual vehicle miles traveled across network - primary mobility and usage metric for system performance"
    - name: "avg_aadt"
      expr: AVG(CAST(aadt AS DOUBLE))
      comment: "Average Annual Average Daily Traffic per segment - traffic loading indicator"
    - name: "total_aadt"
      expr: SUM(CAST(aadt AS DOUBLE))
      comment: "Total Annual Average Daily Traffic across all segments"
    - name: "avg_truck_percentage"
      expr: AVG(CAST(truck_percentage AS DOUBLE))
      comment: "Average truck percentage across segments - freight mobility and pavement loading metric"
    - name: "avg_k_factor"
      expr: AVG(CAST(k_factor AS DOUBLE))
      comment: "Average peak hour factor - indicates traffic peaking characteristics for capacity planning"
    - name: "avg_d_factor"
      expr: AVG(CAST(d_factor AS DOUBLE))
      comment: "Average directional distribution factor - indicates directional traffic imbalance"
    - name: "pct_nhs_miles"
      expr: ROUND(100.0 * SUM(CASE WHEN nhs_indicator = true THEN CAST(length_miles AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(length_miles AS DOUBLE)), 0), 2)
      comment: "Percentage of centerline miles on National Highway System - strategic network composition metric"
    - name: "pct_interstate_miles"
      expr: ROUND(100.0 * SUM(CASE WHEN functional_class_code = '1' THEN CAST(length_miles AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(length_miles AS DOUBLE)), 0), 2)
      comment: "Percentage of centerline miles on Interstate system - highest priority network metric"
    - name: "avg_rutting_depth"
      expr: AVG(CAST(rutting_depth_inches AS DOUBLE))
      comment: "Average rutting depth in inches - structural distress indicator"
    - name: "avg_cracking_percent"
      expr: AVG(CAST(cracking_percent AS DOUBLE))
      comment: "Average percentage of pavement surface with cracking - deterioration indicator"
    - name: "pct_segments_with_lighting"
      expr: ROUND(100.0 * SUM(CASE WHEN lighting_type IS NOT NULL AND lighting_type != 'none' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of segments with roadway lighting - safety infrastructure metric"
    - name: "pct_segments_with_barriers"
      expr: ROUND(100.0 * SUM(CASE WHEN barrier_type IS NOT NULL AND barrier_type != 'none' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of segments with safety barriers - safety infrastructure metric"
    - name: "pct_segments_with_bike_lanes"
      expr: ROUND(100.0 * SUM(CASE WHEN bike_lane_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of segments with bicycle lanes - multimodal infrastructure metric"
    - name: "pct_segments_with_sidewalks"
      expr: ROUND(100.0 * SUM(CASE WHEN sidewalk_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of segments with sidewalks - pedestrian infrastructure metric"
    - name: "pct_ada_compliant"
      expr: ROUND(100.0 * SUM(CASE WHEN ada_compliant_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of segments meeting ADA accessibility requirements - compliance metric"
    - name: "total_bridges"
      expr: SUM(CAST(bridge_count AS DOUBLE))
      comment: "Total number of bridges across all segments"
    - name: "total_culverts"
      expr: SUM(CAST(culvert_count AS DOUBLE))
      comment: "Total number of culverts across all segments"
    - name: "pct_toll_segments"
      expr: ROUND(100.0 * SUM(CASE WHEN toll_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of segments that are toll facilities"
    - name: "pct_its_equipped"
      expr: ROUND(100.0 * SUM(CASE WHEN its_equipped_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of segments equipped with ITS infrastructure - technology deployment metric"
    - name: "pct_emergency_routes"
      expr: ROUND(100.0 * SUM(CASE WHEN emergency_route_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of segments designated as emergency evacuation routes - resilience metric"
    - name: "avg_median_width"
      expr: AVG(CAST(median_width_feet AS DOUBLE))
      comment: "Average median width in feet - safety and design standard metric"
    - name: "avg_shoulder_width_right"
      expr: AVG(CAST(shoulder_width_right_feet AS DOUBLE))
      comment: "Average right shoulder width in feet - safety and design standard metric"
    - name: "avg_lane_width"
      expr: AVG(CAST(lane_width_feet AS DOUBLE))
      comment: "Average lane width in feet - design standard metric"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`highway_service_request`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Citizen service request performance metrics tracking response times, resolution efficiency, service quality, and operational effectiveness for public-facing highway maintenance operations"
  source: "`feip_eastus_03`.`highway`.`service_request`"
  dimensions:
    - name: "request_type"
      expr: request_type
      comment: "Category of service request (pothole, signage, debris, drainage, etc.)"
    - name: "priority"
      expr: priority
      comment: "Priority level based on safety impact and urgency"
    - name: "status"
      expr: status
      comment: "Current lifecycle status (submitted, acknowledged, assigned, in progress, completed, closed)"
    - name: "county"
      expr: county
      comment: "North Carolina county where service request issue is located"
    - name: "division"
      expr: CAST(division AS STRING)
      comment: "NCDOT highway division number responsible for the area"
    - name: "requester_type"
      expr: requester_type
      comment: "Type of individual or entity submitting the request"
    - name: "submission_channel"
      expr: submission_channel
      comment: "Channel through which request was submitted (web, phone, mobile app, email)"
    - name: "safety_impact"
      expr: safety_impact
      comment: "Assessment of safety impact or hazard level"
    - name: "traffic_impact"
      expr: traffic_impact
      comment: "Type of traffic impact or disruption"
    - name: "resolution_code"
      expr: resolution_code
      comment: "Standardized code indicating outcome or resolution"
    - name: "submitted_year"
      expr: YEAR(submitted_date)
      comment: "Year when service request was submitted"
    - name: "submitted_month"
      expr: DATE_TRUNC('MONTH', submitted_date)
      comment: "Month when service request was submitted"
    - name: "functional_class"
      expr: functional_class
      comment: "Functional classification of roadway where request is located"
  measures:
    - name: "total_service_requests"
      expr: COUNT(1)
      comment: "Total number of service requests submitted - workload volume metric"
    - name: "total_completed_requests"
      expr: SUM(CASE WHEN status IN ('completed', 'closed') THEN 1 ELSE 0 END)
      comment: "Total number of service requests completed or closed"
    - name: "completion_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status IN ('completed', 'closed') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of service requests completed - operational effectiveness metric"
    - name: "avg_response_time_hours"
      expr: AVG(CAST(DATEDIFF(HOUR, submitted_timestamp, acknowledged_timestamp) AS DOUBLE))
      comment: "Average hours from submission to acknowledgment - customer service responsiveness metric"
    - name: "avg_assignment_time_hours"
      expr: AVG(CAST(DATEDIFF(HOUR, acknowledged_timestamp, assigned_timestamp) AS DOUBLE))
      comment: "Average hours from acknowledgment to crew assignment - dispatch efficiency metric"
    - name: "avg_resolution_time_hours"
      expr: AVG(CAST(DATEDIFF(HOUR, submitted_timestamp, completed_timestamp) AS DOUBLE))
      comment: "Average hours from submission to completion - end-to-end service delivery performance metric"
    - name: "sla_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN sla_met = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of service requests meeting SLA targets - service level performance metric"
    - name: "total_actual_cost"
      expr: SUM(CAST(actual_cost AS DOUBLE))
      comment: "Total actual cost incurred to complete service requests in dollars"
    - name: "avg_cost_per_request"
      expr: ROUND(SUM(CAST(actual_cost AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average cost per service request - unit cost efficiency metric for budget planning"
    - name: "total_labor_hours"
      expr: SUM(CAST(labor_hours AS DOUBLE))
      comment: "Total labor hours expended to complete service requests"
    - name: "avg_labor_hours_per_request"
      expr: AVG(CAST(labor_hours AS DOUBLE))
      comment: "Average labor hours per service request - productivity metric"
    - name: "avg_citizen_satisfaction"
      expr: AVG(CAST(citizen_satisfaction_rating AS DOUBLE))
      comment: "Average citizen satisfaction rating on 1-5 scale - customer experience quality metric"
    - name: "pct_highly_satisfied"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(citizen_satisfaction_rating AS DOUBLE) >= 4 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN citizen_satisfaction_rating IS NOT NULL THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of requests with satisfaction rating 4 or 5 - customer satisfaction target metric"
    - name: "escalation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN escalated = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of service requests escalated to higher management - indicates service delivery issues"
    - name: "duplicate_request_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN duplicate_of_request_id IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of duplicate service requests - indicates communication effectiveness and data quality"
    - name: "inspection_required_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN inspection_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requests requiring formal inspection before work - complexity indicator"
    - name: "permit_required_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN permit_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requests requiring environmental or regulatory permits - regulatory complexity metric"
    - name: "pct_with_photos"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(photo_count AS DOUBLE) > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requests with photo documentation - indicates citizen engagement and data quality"
    - name: "avg_photo_count"
      expr: AVG(CAST(photo_count AS DOUBLE))
      comment: "Average number of photos per service request"
    - name: "pct_high_priority"
      expr: ROUND(100.0 * SUM(CASE WHEN priority IN ('high', 'critical', 'emergency') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of high priority service requests - indicates safety and urgency workload"
    - name: "pct_nhs_locations"
      expr: ROUND(100.0 * SUM(CASE WHEN nhs_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requests on National Highway System - strategic network focus metric"
    - name: "avg_pavement_condition_index"
      expr: AVG(CAST(pavement_condition_index AS DOUBLE))
      comment: "Average pavement condition at service request locations - indicates correlation between condition and citizen complaints"
    - name: "avg_aadt"
      expr: AVG(CAST(aadt AS DOUBLE))
      comment: "Average traffic volume at service request locations - indicates impact visibility"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`highway_traffic_count`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Traffic volume and classification metrics tracking vehicle counts, truck percentages, speed characteristics, and temporal patterns for transportation planning, capacity analysis, and system performance monitoring"
  source: "`feip_eastus_03`.`highway`.`traffic_count`"
  dimensions:
    - name: "county_name"
      expr: county_name
      comment: "Name of the county where counting station is located"
    - name: "division"
      expr: CAST(division AS STRING)
      comment: "NCDOT Division of Highways division number responsible for roadway"
    - name: "functional_class"
      expr: functional_class
      comment: "FHWA functional classification of roadway"
    - name: "nhs_indicator"
      expr: CASE WHEN nhs_indicator = true THEN 'NHS' ELSE 'Non-NHS' END
      comment: "Indicates whether roadway is part of National Highway System"
    - name: "urban_rural_designation"
      expr: urban_rural_designation
      comment: "Designation of roadway location as urban or rural"
    - name: "count_type"
      expr: count_type
      comment: "Type of traffic count collection method (continuous, short-duration, coverage, special)"
    - name: "count_method"
      expr: count_method
      comment: "Method or technology used to collect traffic count data"
    - name: "direction"
      expr: direction
      comment: "Direction of traffic flow for the count"
    - name: "count_year"
      expr: CAST(count_year AS STRING)
      comment: "Year in which traffic count was collected"
    - name: "count_month"
      expr: DATE_TRUNC('MONTH', count_date)
      comment: "Month when traffic count was collected"
    - name: "day_of_week"
      expr: day_of_week
      comment: "Day of the week when traffic count was collected"
    - name: "weekday_weekend_indicator"
      expr: weekday_weekend_indicator
      comment: "Indicates whether count was collected on weekday or weekend"
    - name: "median_type"
      expr: median_type
      comment: "Type of median present at counting station location"
    - name: "weather_condition"
      expr: weather_condition
      comment: "Weather conditions during traffic count period"
  measures:
    - name: "total_traffic_counts"
      expr: COUNT(1)
      comment: "Total number of traffic count records collected"
    - name: "total_vehicle_volume"
      expr: SUM(CAST(total_volume AS DOUBLE))
      comment: "Total number of vehicles counted across all count periods"
    - name: "avg_aadt"
      expr: AVG(CAST(aadt AS DOUBLE))
      comment: "Average Annual Average Daily Traffic - primary traffic volume metric for planning and design"
    - name: "total_aadt"
      expr: SUM(CAST(aadt AS DOUBLE))
      comment: "Total Annual Average Daily Traffic across all counting stations"
    - name: "avg_peak_hour_volume"
      expr: AVG(CAST(peak_hour_volume AS DOUBLE))
      comment: "Average peak hour traffic volume - capacity planning metric"
    - name: "avg_k_factor"
      expr: AVG(CAST(k_factor AS DOUBLE))
      comment: "Average proportion of AADT occurring during peak hour - design hour volume metric"
    - name: "avg_d_factor"
      expr: AVG(CAST(d_factor AS DOUBLE))
      comment: "Average directional distribution factor - indicates directional traffic imbalance for capacity analysis"
    - name: "total_passenger_vehicles"
      expr: SUM(CAST(passenger_vehicle_count AS DOUBLE))
      comment: "Total count of passenger vehicles (motorcycles, cars, light trucks)"
    - name: "total_commercial_vehicles"
      expr: SUM(CAST(commercial_vehicle_count AS DOUBLE))
      comment: "Total count of commercial vehicles (buses and trucks)"
    - name: "avg_truck_percentage"
      expr: AVG(CAST(truck_percentage AS DOUBLE))
      comment: "Average truck percentage across counts - freight mobility and pavement design metric"
    - name: "truck_volume_share"
      expr: ROUND(100.0 * SUM(CAST(commercial_vehicle_count AS DOUBLE)) / NULLIF(SUM(CAST(total_volume AS DOUBLE)), 0), 2)
      comment: "Percentage of total traffic volume consisting of commercial vehicles - freight system performance metric"
    - name: "avg_speed"
      expr: AVG(CAST(average_speed AS DOUBLE))
      comment: "Average vehicle speed in miles per hour - mobility and safety metric"
    - name: "avg_85th_percentile_speed"
      expr: AVG(CAST(_85th_percentile_speed AS DOUBLE))
      comment: "Average 85th percentile speed - used for speed limit setting and safety analysis"
    - name: "speed_compliance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN CAST(average_speed AS DOUBLE) <= CAST(speed_limit AS DOUBLE) THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of count periods where average speed is at or below speed limit - safety compliance metric"
    - name: "total_class_5_trucks"
      expr: SUM(CAST(vehicle_class_5_count AS DOUBLE))
      comment: "Total count of Class 5 trucks (two-axle, six-tire single-unit trucks)"
    - name: "total_class_9_trucks"
      expr: SUM(CAST(vehicle_class_9_count AS DOUBLE))
      comment: "Total count of Class 9 trucks (five-axle single-trailer trucks) - most common tractor-trailer configuration"
    - name: "heavy_truck_percentage"
      expr: ROUND(100.0 * (SUM(CAST(vehicle_class_8_count AS DOUBLE)) + SUM(CAST(vehicle_class_9_count AS DOUBLE)) + SUM(CAST(vehicle_class_10_count AS DOUBLE)) + SUM(CAST(vehicle_class_11_count AS DOUBLE)) + SUM(CAST(vehicle_class_12_count AS DOUBLE)) + SUM(CAST(vehicle_class_13_count AS DOUBLE))) / NULLIF(SUM(CAST(total_volume AS DOUBLE)), 0), 2)
      comment: "Percentage of traffic consisting of heavy trucks (Classes 8-13) - pavement loading and freight corridor identification metric"
    - name: "avg_seasonal_factor"
      expr: AVG(CAST(seasonal_factor AS DOUBLE))
      comment: "Average seasonal adjustment factor - used to convert short-duration counts to annual estimates"
    - name: "pct_holiday_counts"
      expr: ROUND(100.0 * SUM(CASE WHEN holiday_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of counts collected on holidays - data quality and representativeness metric"
    - name: "pct_incident_affected"
      expr: ROUND(100.0 * SUM(CASE WHEN incident_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of counts affected by traffic incidents - data quality metric"
    - name: "pct_construction_affected"
      expr: ROUND(100.0 * SUM(CASE WHEN construction_activity_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of counts affected by construction activity - data quality metric"
    - name: "data_quality_pass_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN validation_status = 'validated' OR validation_status = 'approved' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of traffic counts passing validation and quality assurance - data reliability metric"
    - name: "avg_count_duration_hours"
      expr: AVG(CAST(count_duration_hours AS DOUBLE))
      comment: "Average duration of traffic count collection in hours"
    - name: "pct_continuous_counts"
      expr: ROUND(100.0 * SUM(CASE WHEN count_type = 'continuous' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of counts from continuous counting stations - indicates permanent monitoring coverage"
    - name: "pct_hpms_sample"
      expr: ROUND(100.0 * SUM(CASE WHEN hpms_sample_type IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of counts in HPMS sample - federal reporting coverage metric"
$$;