-- Metric views for domain: gis | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`gis_geocode_request`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Geocoding service performance and quality metrics tracking address matching accuracy, processing efficiency, and data quality for location intelligence operations supporting NCDOT planning, incident response, and asset management."
  source: "`feip_eastus_03`.`gis`.`geocode_request`"
  dimensions:
    - name: "request_status"
      expr: request_status
      comment: "Processing status of the geocoding request (success, failed, pending) enabling analysis of service reliability and error patterns."
    - name: "match_type"
      expr: match_type
      comment: "Classification of geocoding match quality (exact, interpolated, approximate, unmatched) indicating how coordinates were determined and reliability level."
    - name: "locator_name"
      expr: locator_name
      comment: "Name of the geocoding locator or service used, enabling performance comparison across different geocoding engines and reference datasets."
    - name: "request_purpose"
      expr: request_purpose
      comment: "Business purpose or use case for the geocoding request (project planning, asset location, incident mapping) enabling workload analysis by functional area."
    - name: "requestor_application"
      expr: requestor_application
      comment: "Name of the application or system that initiated the geocoding request, supporting usage tracking and integration monitoring."
    - name: "matched_county"
      expr: matched_county
      comment: "County name associated with the matched address location, enabling geographic distribution analysis of geocoding activity."
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT highway division number (1-14) where the geocoded location resides, supporting workload analysis by organizational unit."
    - name: "quality_flag"
      expr: quality_flag
      comment: "Overall quality assessment flag for the geocoding result based on match score and validation rules, enabling quality monitoring."
    - name: "request_date"
      expr: DATE(request_timestamp)
      comment: "Date when the geocoding request was submitted, enabling time-series analysis of service usage patterns."
    - name: "request_year_month"
      expr: DATE_TRUNC('MONTH', request_timestamp)
      comment: "Year-month of geocoding request submission for monthly trend analysis and capacity planning."
    - name: "is_batch_request"
      expr: is_batch_request
      comment: "Indicates whether this geocoding request was part of a batch processing job, enabling workload segmentation analysis."
  measures:
    - name: "total_geocode_requests"
      expr: COUNT(1)
      comment: "Total number of geocoding requests submitted to the GIS system, measuring overall service demand and usage volume."
    - name: "successful_geocode_count"
      expr: COUNT(CASE WHEN request_status = 'success' THEN 1 END)
      comment: "Number of geocoding requests that completed successfully, measuring service reliability and operational effectiveness."
    - name: "geocode_success_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN request_status = 'success' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of geocoding requests that completed successfully, a critical KPI for service quality and data reliability that directly impacts operational decision-making."
    - name: "high_quality_match_count"
      expr: COUNT(CASE WHEN match_score >= 80 THEN 1 END)
      comment: "Number of geocoding results with match score 80 or above, indicating high-confidence location matches suitable for operational use."
    - name: "high_quality_match_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN match_score >= 80 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of geocoding requests achieving high-quality matches (score >= 80), a key quality metric determining data fitness for planning and emergency response decisions."
    - name: "avg_match_score"
      expr: ROUND(AVG(CAST(match_score AS DOUBLE)), 2)
      comment: "Average confidence score across all geocoding matches, measuring overall geocoding accuracy and reference data quality."
    - name: "avg_processing_time_ms"
      expr: ROUND(AVG(CAST(processing_time_ms AS DOUBLE)), 2)
      comment: "Average processing time in milliseconds per geocoding request, a critical performance metric for service responsiveness and user experience."
    - name: "median_processing_time_ms"
      expr: PERCENTILE(CAST(processing_time_ms AS DOUBLE), 0.5)
      comment: "Median processing time in milliseconds, providing a robust measure of typical geocoding performance less affected by outliers."
    - name: "p95_processing_time_ms"
      expr: PERCENTILE(CAST(processing_time_ms AS DOUBLE), 0.95)
      comment: "95th percentile processing time in milliseconds, measuring worst-case performance for capacity planning and SLA monitoring."
    - name: "manual_review_required_count"
      expr: COUNT(CASE WHEN manual_review_required = true THEN 1 END)
      comment: "Number of geocoding results requiring manual review due to low match scores or ambiguous results, measuring data quality workload."
    - name: "manual_review_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN manual_review_required = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of geocoding requests requiring manual review, a key efficiency metric indicating reference data quality and operational overhead."
    - name: "cache_hit_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN cache_hit = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of geocoding requests served from cache rather than real-time processing, measuring system efficiency and infrastructure optimization."
    - name: "unique_addresses_geocoded"
      expr: COUNT(DISTINCT input_address)
      comment: "Number of distinct addresses geocoded, measuring data diversity and reference coverage across NCDOT service area."
    - name: "unique_requestor_applications"
      expr: COUNT(DISTINCT requestor_application)
      comment: "Number of distinct applications using the geocoding service, measuring integration breadth and enterprise adoption."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`gis_map_layer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "GIS map layer inventory and quality metrics tracking data currency, completeness, and service availability for ArcGIS Enterprise layers supporting transportation planning, asset management, and public information services."
  source: "`feip_eastus_03`.`gis`.`map_layer`"
  dimensions:
    - name: "layer_type"
      expr: layer_type
      comment: "Technical type of the map layer (Feature Layer, Map Image Layer, Vector Tile Layer) indicating data structure and rendering method."
    - name: "status"
      expr: status
      comment: "Current operational status of the map layer (active, inactive, deprecated) enabling availability monitoring and lifecycle management."
    - name: "owner_division"
      expr: owner_division
      comment: "NCDOT division responsible for maintaining and updating this map layer, enabling workload and accountability analysis by organizational unit."
    - name: "visibility"
      expr: visibility
      comment: "Access visibility level (public, internal, restricted) determining who can discover and view this map layer, supporting security and access governance."
    - name: "data_classification"
      expr: data_classification
      comment: "Security classification level of the data contained in this layer, determining access controls and handling requirements."
    - name: "update_frequency"
      expr: update_frequency
      comment: "Expected frequency at which the source data for this layer is refreshed (real-time, daily, weekly, monthly), informing users about data currency."
    - name: "domain"
      expr: domain
      comment: "NCDOT business domain that this map layer primarily supports (highway, dmv, ferry, aviation), aligning with organizational divisions and functional areas."
    - name: "category"
      expr: category
      comment: "Business or functional category (Transportation, Infrastructure, Environmental, Administrative Boundaries) for layer organization and discovery."
    - name: "supports_editing"
      expr: supports_editing
      comment: "Indicates whether this layer allows users to create, update, or delete features through web editing interfaces, enabling capability analysis."
    - name: "tile_cache_enabled"
      expr: tile_cache_enabled
      comment: "Indicates whether pre-generated map tiles are cached for this layer to improve performance and reduce server load."
    - name: "publication_year"
      expr: YEAR(publication_date)
      comment: "Year when this map layer was first published to ArcGIS Enterprise, enabling age and lifecycle analysis."
  measures:
    - name: "total_map_layers"
      expr: COUNT(1)
      comment: "Total number of map layers published in ArcGIS Enterprise, measuring GIS data inventory size and enterprise footprint."
    - name: "active_layer_count"
      expr: COUNT(CASE WHEN status = 'active' THEN 1 END)
      comment: "Number of map layers currently active and available for use, measuring operational GIS service availability."
    - name: "active_layer_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN status = 'active' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of map layers that are active and operational, a key availability metric for GIS service reliability and user access."
    - name: "public_accessible_layer_count"
      expr: COUNT(CASE WHEN visibility = 'public' THEN 1 END)
      comment: "Number of map layers available for public access and distribution, measuring transparency and open data commitment."
    - name: "editable_layer_count"
      expr: COUNT(CASE WHEN supports_editing = true THEN 1 END)
      comment: "Number of map layers that support web editing, measuring collaborative data maintenance capability and workflow enablement."
    - name: "cached_layer_count"
      expr: COUNT(CASE WHEN tile_cache_enabled = true THEN 1 END)
      comment: "Number of map layers with tile caching enabled, measuring performance optimization coverage and infrastructure efficiency."
    - name: "avg_quality_score"
      expr: ROUND(AVG(CAST(quality_score AS DOUBLE)), 2)
      comment: "Average data quality score (0-100) across all map layers, measuring overall GIS data quality and fitness for operational use."
    - name: "high_quality_layer_count"
      expr: COUNT(CASE WHEN quality_score >= 80 THEN 1 END)
      comment: "Number of map layers with quality score 80 or above, indicating high-quality data suitable for critical decision-making."
    - name: "high_quality_layer_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN quality_score >= 80 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of map layers meeting high quality standards (score >= 80), a strategic KPI for data governance and operational readiness."
    - name: "avg_completeness_pct"
      expr: ROUND(AVG(CAST(completeness_percentage AS DOUBLE)), 2)
      comment: "Average completeness percentage across all map layers, measuring data population and attribute coverage quality."
    - name: "avg_positional_accuracy_meters"
      expr: ROUND(AVG(CAST(positional_accuracy_meters AS DOUBLE)), 2)
      comment: "Average horizontal positional accuracy in meters across all map layers, measuring spatial precision and survey quality."
    - name: "total_cache_size_gb"
      expr: ROUND(SUM(CAST(cache_size_mb AS DOUBLE)) / 1024.0, 2)
      comment: "Total storage size in gigabytes of all tile caches, measuring infrastructure capacity requirements and storage costs."
    - name: "avg_cache_size_mb"
      expr: ROUND(AVG(CAST(cache_size_mb AS DOUBLE)), 2)
      comment: "Average tile cache size in megabytes per layer, measuring typical storage footprint for capacity planning."
    - name: "layers_requiring_update"
      expr: COUNT(CASE WHEN DATEDIFF(CURRENT_DATE(), last_update_date) > 90 THEN 1 END)
      comment: "Number of map layers not updated in the last 90 days, identifying stale data requiring refresh and measuring data currency risk."
    - name: "stale_data_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN DATEDIFF(CURRENT_DATE(), last_update_date) > 90 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of map layers with data older than 90 days, a critical data currency metric impacting decision quality and operational risk."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`gis_feature`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Geographic feature inventory and asset condition metrics tracking transportation infrastructure status, maintenance needs, and asset valuation for NCDOT highway system management and capital planning."
  source: "`feip_eastus_03`.`gis`.`feature`"
  dimensions:
    - name: "type"
      expr: type
      comment: "Geometric type of the feature (point, line, polygon) representing its spatial structure and infrastructure category."
    - name: "class_name"
      expr: class_name
      comment: "Name of the feature class or layer (Road Centerline, Bridge, Sign, Guardrail) to which this feature belongs within the GIS database."
    - name: "status"
      expr: status
      comment: "Current lifecycle status of the feature (active, proposed, under construction, retired) enabling project tracking and inventory management."
    - name: "county_name"
      expr: county_name
      comment: "Name of the North Carolina county where the feature is located, enabling geographic distribution analysis and regional planning."
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT division number (1-14) responsible for the geographic area containing the feature, supporting workload and accountability analysis."
    - name: "ownership_type"
      expr: ownership_type
      comment: "Type of ownership or jurisdiction (state, federal, county, municipal, private) determining maintenance responsibility and funding eligibility."
    - name: "functional_class_code"
      expr: functional_class_code
      comment: "Functional classification code for transportation features according to FHWA standards (interstate, principal arterial, collector) determining funding and design standards."
    - name: "asset_condition_rating"
      expr: asset_condition_rating
      comment: "Overall condition rating of the asset (excellent, good, fair, poor, critical) driving maintenance prioritization and capital planning decisions."
    - name: "surface_type"
      expr: surface_type
      comment: "Type of surface material for transportation features (asphalt, concrete, gravel, unpaved) affecting maintenance strategies and lifecycle costs."
    - name: "nhs_indicator"
      expr: nhs_indicator
      comment: "Indicator whether the feature is part of the National Highway System, determining federal funding eligibility and reporting requirements."
    - name: "federal_aid_eligible_indicator"
      expr: federal_aid_eligible_indicator
      comment: "Indicator whether the feature is eligible for federal transportation funding, critical for capital planning and project prioritization."
    - name: "construction_decade"
      expr: CONCAT(CAST(FLOOR(construction_year / 10) * 10 AS STRING), 's')
      comment: "Decade when the feature was originally constructed, enabling age-based analysis and lifecycle planning."
  measures:
    - name: "total_features"
      expr: COUNT(1)
      comment: "Total number of geographic features in the GIS system, measuring infrastructure inventory size and asset management scope."
    - name: "active_feature_count"
      expr: COUNT(CASE WHEN status = 'active' THEN 1 END)
      comment: "Number of features currently active and operational, measuring in-service infrastructure inventory."
    - name: "total_centerline_miles"
      expr: ROUND(SUM(CAST(length_meters AS DOUBLE)) / 1609.34, 2)
      comment: "Total length of linear features in miles (roads, routes), a fundamental measure of NCDOT highway system size and maintenance responsibility."
    - name: "total_area_acres"
      expr: ROUND(SUM(CAST(area_square_meters AS DOUBLE)) / 4046.86, 2)
      comment: "Total area of polygon features in acres, measuring spatial extent of facilities, right-of-way, and land assets."
    - name: "avg_pavement_condition_index"
      expr: ROUND(AVG(CAST(pavement_condition_index AS DOUBLE)), 2)
      comment: "Average Pavement Condition Index (PCI) score across all roadway features, a critical KPI for pavement management and capital planning decisions."
    - name: "poor_condition_feature_count"
      expr: COUNT(CASE WHEN asset_condition_rating IN ('poor', 'critical') THEN 1 END)
      comment: "Number of features rated in poor or critical condition, identifying immediate maintenance needs and safety risks."
    - name: "poor_condition_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN asset_condition_rating IN ('poor', 'critical') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of features in poor or critical condition, a strategic KPI for asset management performance and capital investment prioritization."
    - name: "total_replacement_value_millions"
      expr: ROUND(SUM(CAST(replacement_cost_usd AS DOUBLE)) / 1000000.0, 2)
      comment: "Total estimated replacement cost of all features in millions of dollars, measuring total asset value and financial risk exposure for insurance and capital planning."
    - name: "avg_replacement_cost_usd"
      expr: ROUND(AVG(CAST(replacement_cost_usd AS DOUBLE)), 2)
      comment: "Average replacement cost per feature in US dollars, measuring typical asset value and capital intensity."
    - name: "nhs_centerline_miles"
      expr: ROUND(SUM(CASE WHEN nhs_indicator = true THEN CAST(length_meters AS DOUBLE) ELSE 0 END) / 1609.34, 2)
      comment: "Total miles of National Highway System routes, measuring federally significant infrastructure and funding eligibility scope."
    - name: "nhs_coverage_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN nhs_indicator = true THEN CAST(length_meters AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(length_meters AS DOUBLE)), 0), 2)
      comment: "Percentage of total centerline miles on the National Highway System, measuring federal funding eligibility and strategic network coverage."
    - name: "avg_annual_daily_traffic"
      expr: ROUND(AVG(CAST(aadt AS DOUBLE)), 0)
      comment: "Average Annual Average Daily Traffic (AADT) across all roadway features, measuring typical traffic volume and system utilization."
    - name: "total_vehicle_miles_traveled_millions"
      expr: ROUND(SUM(CAST(aadt AS DOUBLE) * CAST(length_meters AS DOUBLE) / 1609.34) * 365 / 1000000.0, 2)
      comment: "Total annual vehicle miles traveled in millions across all roadway features, a fundamental transportation demand metric for capacity planning and economic impact analysis."
    - name: "avg_data_quality_score"
      expr: ROUND(AVG(CAST(data_quality_score AS DOUBLE)), 2)
      comment: "Average composite data quality score (0-100) across all features, measuring GIS data reliability and fitness for operational decision-making."
    - name: "features_requiring_inspection"
      expr: COUNT(CASE WHEN next_inspection_date <= CURRENT_DATE() THEN 1 END)
      comment: "Number of features with inspections due or overdue, measuring inspection workload and compliance risk."
    - name: "overdue_inspection_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN next_inspection_date <= CURRENT_DATE() THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of features with overdue inspections, a critical compliance and safety metric driving resource allocation and risk management decisions."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`gis_routing_result`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Transportation routing performance and efficiency metrics tracking route optimization, travel time accuracy, and network analysis quality for fleet management, emergency response, and transportation planning applications."
  source: "`feip_eastus_03`.`gis`.`routing_result`"
  dimensions:
    - name: "travel_mode"
      expr: travel_mode
      comment: "Mode of transportation used for the routing calculation (driving, truck, emergency) enabling mode-specific performance analysis."
    - name: "route_type"
      expr: route_type
      comment: "Type of routing optimization applied (fastest, shortest, avoid tolls) indicating routing strategy and user preferences."
    - name: "calculation_status"
      expr: calculation_status
      comment: "Status of the routing calculation execution (success, failed, timeout) enabling service reliability monitoring."
    - name: "origin_county"
      expr: origin_county
      comment: "North Carolina county where the routing origin is located, enabling geographic demand analysis and service coverage assessment."
    - name: "destination_county"
      expr: destination_county
      comment: "North Carolina county where the routing destination is located, enabling origin-destination flow analysis."
    - name: "business_unit"
      expr: business_unit
      comment: "NCDOT business unit or division that requested the routing calculation, supporting workload analysis by organizational function."
    - name: "purpose_code"
      expr: purpose_code
      comment: "Business purpose or use case for the routing calculation (emergency response, maintenance routing, planning analysis) enabling application-specific performance tracking."
    - name: "includes_toll_roads_flag"
      expr: includes_toll_roads_flag
      comment: "Indicates whether the route includes any toll roads, enabling cost analysis and routing preference assessment."
    - name: "traffic_condition"
      expr: traffic_condition
      comment: "Overall traffic condition along the route at calculation time (free flow, moderate, congested) enabling traffic impact analysis."
    - name: "calculation_date"
      expr: DATE(calculation_timestamp)
      comment: "Date when the routing calculation was performed, enabling time-series analysis of routing service usage."
    - name: "calculation_year_month"
      expr: DATE_TRUNC('MONTH', calculation_timestamp)
      comment: "Year-month of routing calculation for monthly trend analysis and capacity planning."
  measures:
    - name: "total_routing_requests"
      expr: COUNT(1)
      comment: "Total number of routing calculations performed, measuring routing service demand and usage volume."
    - name: "successful_routing_count"
      expr: COUNT(CASE WHEN calculation_status = 'success' THEN 1 END)
      comment: "Number of routing calculations that completed successfully, measuring service reliability and operational effectiveness."
    - name: "routing_success_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN calculation_status = 'success' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of routing requests that completed successfully, a critical service quality KPI impacting operational efficiency and user satisfaction."
    - name: "total_route_miles"
      expr: ROUND(SUM(CAST(route_distance_miles AS DOUBLE)), 2)
      comment: "Total distance of all calculated routes in miles, measuring routing service scope and transportation network utilization."
    - name: "avg_route_distance_miles"
      expr: ROUND(AVG(CAST(route_distance_miles AS DOUBLE)), 2)
      comment: "Average route distance in miles, measuring typical trip length and service area coverage."
    - name: "avg_travel_time_minutes"
      expr: ROUND(AVG(CAST(travel_time_minutes AS DOUBLE)), 2)
      comment: "Average estimated travel time in minutes under normal traffic conditions, measuring typical trip duration and network efficiency."
    - name: "avg_travel_time_with_traffic_minutes"
      expr: ROUND(AVG(CAST(travel_time_with_traffic_minutes AS DOUBLE)), 2)
      comment: "Average estimated travel time accounting for current traffic conditions, measuring real-world trip duration and congestion impact."
    - name: "traffic_delay_minutes"
      expr: ROUND(AVG(CAST(travel_time_with_traffic_minutes AS DOUBLE) - CAST(travel_time_minutes AS DOUBLE)), 2)
      comment: "Average additional travel time due to traffic congestion in minutes, a key congestion metric for transportation planning and operational response."
    - name: "traffic_delay_rate_pct"
      expr: ROUND(100.0 * AVG((CAST(travel_time_with_traffic_minutes AS DOUBLE) - CAST(travel_time_minutes AS DOUBLE)) / NULLIF(CAST(travel_time_minutes AS DOUBLE), 0)), 2)
      comment: "Average percentage increase in travel time due to traffic congestion, measuring congestion severity and network performance degradation."
    - name: "avg_route_speed_mph"
      expr: ROUND(AVG(CAST(average_speed_mph AS DOUBLE)), 2)
      comment: "Average travel speed along routes in miles per hour, measuring network operating speed and efficiency."
    - name: "avg_calculation_time_seconds"
      expr: ROUND(AVG(CAST(calculation_duration_seconds AS DOUBLE)), 2)
      comment: "Average time to complete routing calculations in seconds, a critical performance metric for service responsiveness and user experience."
    - name: "p95_calculation_time_seconds"
      expr: PERCENTILE(CAST(calculation_duration_seconds AS DOUBLE), 0.95)
      comment: "95th percentile routing calculation time in seconds, measuring worst-case performance for SLA monitoring and capacity planning."
    - name: "total_toll_cost_usd"
      expr: ROUND(SUM(CAST(toll_cost_usd AS DOUBLE)), 2)
      comment: "Total estimated toll costs across all routes in US dollars, measuring toll road usage and transportation cost impact."
    - name: "avg_toll_cost_per_route_usd"
      expr: ROUND(AVG(CAST(toll_cost_usd AS DOUBLE)), 2)
      comment: "Average toll cost per route in US dollars, measuring typical toll expense and cost-benefit of toll avoidance strategies."
    - name: "routes_with_tolls_count"
      expr: COUNT(CASE WHEN includes_toll_roads_flag = true THEN 1 END)
      comment: "Number of routes including toll roads, measuring toll road utilization and routing preference patterns."
    - name: "toll_route_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN includes_toll_roads_flag = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of routes including toll roads, measuring toll road dependency and cost-benefit trade-offs in route optimization."
    - name: "avg_route_confidence_score"
      expr: ROUND(AVG(CAST(route_confidence_score AS DOUBLE)), 2)
      comment: "Average confidence score for routing calculation accuracy (0-100), measuring routing quality and network data reliability."
    - name: "high_confidence_route_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN route_confidence_score >= 80 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of routes with high confidence scores (>= 80), a quality metric for routing reliability and operational decision support."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`gis_project_boundary`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Transportation project spatial extent and planning metrics tracking project boundaries, environmental compliance, and right-of-way requirements for STIP project management and capital program delivery."
  source: "`feip_eastus_03`.`gis`.`project_boundary`"
  dimensions:
    - name: "project_type"
      expr: project_type
      comment: "Primary category or type of transportation improvement project (highway widening, bridge replacement, intersection improvement) enabling project portfolio analysis."
    - name: "project_phase"
      expr: project_phase
      comment: "Current phase of the project lifecycle (planning, design, construction, complete) enabling project status tracking and delivery monitoring."
    - name: "boundary_status"
      expr: boundary_status
      comment: "Current approval and lifecycle status of the project boundary definition (draft, approved, superseded) enabling boundary governance and version control."
    - name: "county"
      expr: county
      comment: "Primary North Carolina county where the project is located, enabling geographic distribution analysis and regional planning."
    - name: "mpo_name"
      expr: mpo_name
      comment: "Name of the MPO responsible for transportation planning in the project area, supporting metropolitan planning coordination."
    - name: "environmental_classification"
      expr: environmental_classification
      comment: "NEPA environmental review classification (CE, EA, EIS) determining environmental compliance requirements and project complexity."
    - name: "functional_classification"
      expr: functional_classification
      comment: "Functional classification of the roadway within the project boundary (interstate, principal arterial, collector) determining design standards and funding eligibility."
    - name: "nhs_indicator"
      expr: nhs_indicator
      comment: "Indicates whether the project is located on the National Highway System, determining federal funding eligibility and reporting requirements."
    - name: "row_acquisition_required"
      expr: row_acquisition_required
      comment: "Indicates whether right-of-way acquisition is required for the project, identifying projects with property acquisition complexity and cost."
    - name: "federal_program"
      expr: federal_program
      comment: "Specific federal funding program supporting the project (HSIP, CMAQ, STP, BUILD) enabling funding source analysis and compliance tracking."
    - name: "approved_year"
      expr: YEAR(approved_date)
      comment: "Year when the project boundary was officially approved, enabling project age and delivery timeline analysis."
  measures:
    - name: "total_project_boundaries"
      expr: COUNT(1)
      comment: "Total number of transportation project boundaries defined in the GIS system, measuring capital program scope and project inventory size."
    - name: "approved_boundary_count"
      expr: COUNT(CASE WHEN boundary_status = 'approved' THEN 1 END)
      comment: "Number of project boundaries with approved status, measuring project readiness and planning maturity."
    - name: "total_project_length_miles"
      expr: ROUND(SUM(CAST(project_length_miles AS DOUBLE)), 2)
      comment: "Total linear length of all project corridors in miles, measuring capital program geographic scope and infrastructure improvement extent."
    - name: "avg_project_length_miles"
      expr: ROUND(AVG(CAST(project_length_miles AS DOUBLE)), 2)
      comment: "Average project corridor length in miles, measuring typical project size and delivery complexity."
    - name: "total_project_area_acres"
      expr: ROUND(SUM(CAST(boundary_area_acres AS DOUBLE)), 2)
      comment: "Total area enclosed by all project boundaries in acres, measuring total project footprint and land impact."
    - name: "avg_project_area_acres"
      expr: ROUND(AVG(CAST(boundary_area_acres AS DOUBLE)), 2)
      comment: "Average project boundary area in acres, measuring typical project spatial extent and environmental impact scope."
    - name: "total_estimated_cost_millions"
      expr: ROUND(SUM(CAST(estimated_cost AS DOUBLE)) / 1000000.0, 2)
      comment: "Total estimated cost of all transportation projects in millions of dollars, measuring capital program investment value and financial commitment."
    - name: "avg_estimated_cost_millions"
      expr: ROUND(AVG(CAST(estimated_cost AS DOUBLE)) / 1000000.0, 2)
      comment: "Average estimated project cost in millions of dollars, measuring typical project investment size and capital intensity."
    - name: "cost_per_mile_millions"
      expr: ROUND(SUM(CAST(estimated_cost AS DOUBLE)) / NULLIF(SUM(CAST(project_length_miles AS DOUBLE)), 0) / 1000000.0, 2)
      comment: "Average project cost per mile in millions of dollars, a key efficiency metric for capital program cost-effectiveness and project prioritization."
    - name: "row_acquisition_project_count"
      expr: COUNT(CASE WHEN row_acquisition_required = true THEN 1 END)
      comment: "Number of projects requiring right-of-way acquisition, measuring property acquisition workload and project complexity."
    - name: "row_acquisition_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN row_acquisition_required = true THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of projects requiring right-of-way acquisition, measuring property impact scope and acquisition program workload."
    - name: "total_row_parcels"
      expr: SUM(CAST(row_parcels_count AS DOUBLE))
      comment: "Total number of property parcels requiring right-of-way acquisition across all projects, measuring acquisition program scope and negotiation workload."
    - name: "avg_row_parcels_per_project"
      expr: ROUND(AVG(CAST(row_parcels_count AS DOUBLE)), 2)
      comment: "Average number of parcels requiring acquisition per project, measuring typical property impact and acquisition complexity."
    - name: "environmental_review_project_count"
      expr: COUNT(CASE WHEN environmental_classification IN ('EA', 'EIS') THEN 1 END)
      comment: "Number of projects requiring formal environmental review (EA or EIS), measuring environmental compliance workload and regulatory complexity."
    - name: "environmental_review_rate_pct"
      expr: ROUND(100.0 * COUNT(CASE WHEN environmental_classification IN ('EA', 'EIS') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of projects requiring formal environmental review, a key compliance metric for environmental stewardship and regulatory risk management."
    - name: "nhs_project_count"
      expr: COUNT(CASE WHEN nhs_indicator = true THEN 1 END)
      comment: "Number of projects on the National Highway System, measuring federally significant infrastructure investment and funding eligibility."
    - name: "nhs_project_investment_millions"
      expr: ROUND(SUM(CASE WHEN nhs_indicator = true THEN CAST(estimated_cost AS DOUBLE) ELSE 0 END) / 1000000.0, 2)
      comment: "Total estimated cost of NHS projects in millions of dollars, measuring federal-aid eligible investment and strategic network improvement value."
    - name: "nhs_investment_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN nhs_indicator = true THEN CAST(estimated_cost AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(estimated_cost AS DOUBLE)), 0), 2)
      comment: "Percentage of total project investment on the National Highway System, measuring federal funding leverage and strategic network focus."
$$;