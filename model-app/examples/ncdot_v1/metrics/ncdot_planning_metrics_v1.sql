-- Metric views for domain: planning | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`planning_corridor`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic corridor performance metrics for transportation planning, including infrastructure condition, safety performance, and capacity utilization. Used by planning executives to prioritize corridor investments and evaluate network performance."
  source: "`feip_eastus_03`.`planning`.`corridor`"
  dimensions:
    - name: "corridor_code"
      expr: code
      comment: "Standardized corridor code for STIP and TIP reference"
    - name: "corridor_name"
      expr: name
      comment: "Official corridor designation"
    - name: "corridor_type"
      expr: type
      comment: "Corridor classification by transportation mode and function"
    - name: "functional_classification"
      expr: functional_classification
      comment: "FHWA functional classification defining network hierarchy role"
    - name: "nhs_designation"
      expr: nhs_designation
      comment: "National Highway System designation and category"
    - name: "planning_priority"
      expr: planning_priority
      comment: "Priority ranking for planning, funding, and project development"
    - name: "status"
      expr: status
      comment: "Current planning and development status"
    - name: "county_list"
      expr: county_list
      comment: "Counties through which the corridor passes"
    - name: "division_list"
      expr: division_list
      comment: "NCDOT divisions responsible for corridor maintenance"
    - name: "route_number"
      expr: route_number
      comment: "Primary route number designation"
    - name: "current_los"
      expr: los_current
      comment: "Current Level of Service rating (A-F)"
    - name: "projected_los"
      expr: los_projected
      comment: "Projected future Level of Service rating"
    - name: "hsip_eligible_flag"
      expr: hsip_eligible
      comment: "Highway Safety Improvement Program eligibility indicator"
    - name: "freight_corridor_flag"
      expr: freight_corridor
      comment: "Critical freight corridor designation"
    - name: "strategic_highway_network_flag"
      expr: strategic_highway_network
      comment: "STRAHNET national defense designation"
    - name: "environmental_justice_area_flag"
      expr: environmental_justice_area
      comment: "Environmental justice community impact indicator"
    - name: "lrtp_inclusion_flag"
      expr: lrtp_inclusion
      comment: "Long Range Transportation Plan inclusion indicator"
    - name: "federal_funding_eligible_flag"
      expr: federal_funding_eligible
      comment: "Federal transportation funding eligibility"
  measures:
    - name: "total_corridor_count"
      expr: COUNT(1)
      comment: "Total number of transportation corridors in the planning network"
    - name: "total_corridor_miles"
      expr: SUM(CAST(length_miles AS DOUBLE))
      comment: "Total linear miles of corridor infrastructure under planning management"
    - name: "avg_corridor_length_miles"
      expr: AVG(CAST(length_miles AS DOUBLE))
      comment: "Average corridor length in miles, indicating typical corridor scale"
    - name: "total_estimated_improvement_cost"
      expr: SUM(CAST(estimated_improvement_cost AS DOUBLE))
      comment: "Total estimated capital investment required for planned corridor improvements across the network"
    - name: "avg_pavement_condition_index"
      expr: AVG(CAST(pavement_condition_index AS DOUBLE))
      comment: "Average Pavement Condition Index across corridors (0-100 scale), indicating overall pavement health and maintenance needs"
    - name: "avg_iri_value"
      expr: AVG(CAST(iri_value AS DOUBLE))
      comment: "Average International Roughness Index in inches per mile, measuring ride quality and pavement roughness"
    - name: "total_bridge_count"
      expr: SUM(CAST(bridge_count AS DOUBLE))
      comment: "Total number of bridge structures across all corridors requiring inspection and maintenance"
    - name: "total_structurally_deficient_bridges"
      expr: SUM(CAST(structurally_deficient_bridges AS DOUBLE))
      comment: "Total count of structurally deficient bridges requiring priority rehabilitation or replacement"
    - name: "structurally_deficient_bridge_rate"
      expr: ROUND(100.0 * SUM(CAST(structurally_deficient_bridges AS DOUBLE)) / NULLIF(SUM(CAST(bridge_count AS DOUBLE)), 0), 2)
      comment: "Percentage of bridges classified as structurally deficient, a critical safety and infrastructure investment metric"
    - name: "avg_crash_rate_per_million_vmt"
      expr: AVG(CAST(crash_rate_per_million_vmt AS DOUBLE))
      comment: "Average traffic crash rate per million Vehicle Miles Traveled, indicating corridor safety performance"
    - name: "total_fatality_count_5yr"
      expr: SUM(CAST(fatality_count_5yr AS DOUBLE))
      comment: "Total traffic fatalities across all corridors over the most recent five-year period, driving HSIP prioritization"
    - name: "avg_truck_percentage"
      expr: AVG(CAST(truck_percentage AS DOUBLE))
      comment: "Average percentage of commercial truck traffic, indicating freight corridor importance and pavement loading"
    - name: "total_stip_project_count"
      expr: SUM(CAST(stip_project_count AS DOUBLE))
      comment: "Total number of active STIP projects across corridors, indicating current capital program activity level"
    - name: "hsip_eligible_corridor_count"
      expr: SUM(CASE WHEN hsip_eligible = true THEN 1 ELSE 0 END)
      comment: "Count of corridors eligible for Highway Safety Improvement Program funding based on safety performance"
    - name: "hsip_eligibility_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN hsip_eligible = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of corridors eligible for HSIP funding, indicating safety investment opportunity scope"
    - name: "freight_corridor_count"
      expr: SUM(CASE WHEN freight_corridor = true THEN 1 ELSE 0 END)
      comment: "Count of designated critical freight corridors for commercial goods movement"
    - name: "freight_corridor_miles"
      expr: SUM(CASE WHEN freight_corridor = true THEN CAST(length_miles AS DOUBLE) ELSE 0 END)
      comment: "Total linear miles of designated freight corridors, indicating freight network extent"
    - name: "environmental_justice_corridor_count"
      expr: SUM(CASE WHEN environmental_justice_area = true THEN 1 ELSE 0 END)
      comment: "Count of corridors impacting environmental justice communities requiring special consideration"
    - name: "lrtp_included_corridor_count"
      expr: SUM(CASE WHEN lrtp_inclusion = true THEN 1 ELSE 0 END)
      comment: "Count of corridors included in Long Range Transportation Plans, indicating strategic planning coverage"
    - name: "federal_funding_eligible_corridor_count"
      expr: SUM(CASE WHEN federal_funding_eligible = true THEN 1 ELSE 0 END)
      comment: "Count of corridors eligible for federal transportation funding programs"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`planning_planned_project`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Capital project portfolio metrics for transportation planning, tracking project costs, schedules, funding sources, and strategic priorities. Used by executives to manage STIP/TIP programming, budget allocation, and project delivery performance."
  source: "`feip_eastus_03`.`planning`.`planned_project`"
  dimensions:
    - name: "project_name"
      expr: project_name
      comment: "Descriptive name of the planned transportation project"
    - name: "project_type"
      expr: project_type
      comment: "Classification by primary infrastructure type or improvement category"
    - name: "project_category"
      expr: project_category
      comment: "High-level categorization by primary purpose and investment strategy"
    - name: "project_status"
      expr: project_status
      comment: "Current lifecycle status within planning and programming process"
    - name: "priority_tier"
      expr: priority_tier
      comment: "Categorical priority classification for resource allocation"
    - name: "plan_type"
      expr: plan_type
      comment: "Type of transportation plan (LRTP, CTP, STIP, TIP)"
    - name: "plan_name"
      expr: plan_name
      comment: "Specific transportation plan document name"
    - name: "plan_year"
      expr: CAST(plan_year AS STRING)
      comment: "Fiscal or calendar year of the transportation plan"
    - name: "corridor_name"
      expr: corridor_name
      comment: "Transportation corridor in which project is located"
    - name: "route_number"
      expr: route_number
      comment: "Highway or route number affected by project"
    - name: "route_type"
      expr: route_type
      comment: "Functional classification of the affected route"
    - name: "county"
      expr: county
      comment: "Primary county in which project is located"
    - name: "division"
      expr: division
      comment: "NCDOT highway division responsible for project area"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary source of project funding"
    - name: "federal_funding_program"
      expr: federal_funding_program
      comment: "Specific federal funding program (NHPP, STP, HSIP, CMAQ, TAP)"
    - name: "scheduled_start_year"
      expr: CAST(scheduled_start_year AS STRING)
      comment: "Planned fiscal or calendar year for project initiation"
    - name: "scheduled_completion_year"
      expr: CAST(scheduled_completion_year AS STRING)
      comment: "Planned fiscal or calendar year for project completion"
    - name: "nepa_status"
      expr: nepa_status
      comment: "Current NEPA environmental review status (CE, EA, EIS, FONSI, ROD)"
    - name: "nepa_document_type"
      expr: nepa_document_type
      comment: "Type of NEPA environmental document required (CE, EA, EIS)"
    - name: "nhs_indicator"
      expr: nhs_indicator
      comment: "National Highway System location indicator"
    - name: "safety_improvement_indicator"
      expr: safety_improvement_indicator
      comment: "Safety improvement or HSIP program indicator"
    - name: "congestion_relief_indicator"
      expr: congestion_relief_indicator
      comment: "Traffic congestion reduction intent indicator"
    - name: "economic_development_indicator"
      expr: economic_development_indicator
      comment: "Economic development objective support indicator"
    - name: "multimodal_indicator"
      expr: multimodal_indicator
      comment: "Multiple transportation mode inclusion indicator"
    - name: "bridge_replacement_indicator"
      expr: bridge_replacement_indicator
      comment: "Bridge replacement or major rehabilitation indicator"
    - name: "pavement_improvement_indicator"
      expr: pavement_improvement_indicator
      comment: "Pavement preservation, rehabilitation, or reconstruction indicator"
    - name: "environmental_justice_area_indicator"
      expr: environmental_justice_area_indicator
      comment: "Environmental justice area impact indicator"
    - name: "risk_level"
      expr: risk_level
      comment: "Overall project risk assessment level"
  measures:
    - name: "total_project_count"
      expr: COUNT(1)
      comment: "Total number of planned transportation projects in the capital program portfolio"
    - name: "total_estimated_cost"
      expr: SUM(CAST(estimated_cost AS DOUBLE))
      comment: "Total estimated capital investment across all planned projects, representing full program funding requirement"
    - name: "avg_project_cost"
      expr: AVG(CAST(estimated_cost AS DOUBLE))
      comment: "Average project cost, indicating typical project scale and complexity"
    - name: "total_pe_cost"
      expr: SUM(CAST(pe_cost AS DOUBLE))
      comment: "Total preliminary engineering cost across all projects for design, surveys, and environmental studies"
    - name: "total_row_cost"
      expr: SUM(CAST(row_cost AS DOUBLE))
      comment: "Total right-of-way acquisition cost including property purchases and relocations"
    - name: "total_construction_cost"
      expr: SUM(CAST(construction_cost AS DOUBLE))
      comment: "Total construction phase cost across all projects, representing the largest capital expenditure category"
    - name: "total_ce_cost"
      expr: SUM(CAST(ce_cost AS DOUBLE))
      comment: "Total construction engineering and inspection cost for project oversight"
    - name: "construction_cost_percentage"
      expr: ROUND(100.0 * SUM(CAST(construction_cost AS DOUBLE)) / NULLIF(SUM(CAST(estimated_cost AS DOUBLE)), 0), 2)
      comment: "Construction cost as percentage of total project cost, indicating capital efficiency and project composition"
    - name: "total_federal_funding"
      expr: SUM(CAST(federal_amount AS DOUBLE))
      comment: "Total federal funding allocation across all projects from FHWA, FTA, and other federal sources"
    - name: "total_state_funding"
      expr: SUM(CAST(state_amount AS DOUBLE))
      comment: "Total North Carolina state funding allocation across all projects"
    - name: "total_local_funding"
      expr: SUM(CAST(local_amount AS DOUBLE))
      comment: "Total local government funding contribution from counties and municipalities"
    - name: "total_private_funding"
      expr: SUM(CAST(private_amount AS DOUBLE))
      comment: "Total private sector funding or contributions across all projects"
    - name: "federal_funding_percentage"
      expr: ROUND(100.0 * SUM(CAST(federal_amount AS DOUBLE)) / NULLIF(SUM(CAST(estimated_cost AS DOUBLE)), 0), 2)
      comment: "Federal funding as percentage of total project cost, indicating federal participation rate and funding leverage"
    - name: "state_funding_percentage"
      expr: ROUND(100.0 * SUM(CAST(state_amount AS DOUBLE)) / NULLIF(SUM(CAST(estimated_cost AS DOUBLE)), 0), 2)
      comment: "State funding as percentage of total project cost, indicating state match and investment level"
    - name: "local_funding_percentage"
      expr: ROUND(100.0 * SUM(CAST(local_amount AS DOUBLE)) / NULLIF(SUM(CAST(estimated_cost AS DOUBLE)), 0), 2)
      comment: "Local funding as percentage of total project cost, indicating local government participation and commitment"
    - name: "total_project_length_miles"
      expr: SUM(CAST(project_length_miles AS DOUBLE))
      comment: "Total linear miles of transportation infrastructure improvements across all projects"
    - name: "avg_project_length_miles"
      expr: AVG(CAST(project_length_miles AS DOUBLE))
      comment: "Average project length in miles, indicating typical project geographic scope"
    - name: "avg_project_duration_months"
      expr: AVG(CAST(project_duration_months AS DOUBLE))
      comment: "Average planned project duration from initiation to completion in months, indicating delivery timeline"
    - name: "avg_contingency_percentage"
      expr: AVG(CAST(contingency_percentage AS DOUBLE))
      comment: "Average contingency allocation as percentage of project cost, indicating risk management approach"
    - name: "avg_dbe_goal_percentage"
      expr: AVG(CAST(dbe_goal_percentage AS DOUBLE))
      comment: "Average Disadvantaged Business Enterprise participation goal percentage across projects"
    - name: "safety_improvement_project_count"
      expr: SUM(CASE WHEN safety_improvement_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of projects including safety improvements or HSIP program participation"
    - name: "safety_improvement_investment"
      expr: SUM(CASE WHEN safety_improvement_indicator = true THEN CAST(estimated_cost AS DOUBLE) ELSE 0 END)
      comment: "Total capital investment in safety improvement projects, indicating safety program funding level"
    - name: "congestion_relief_project_count"
      expr: SUM(CASE WHEN congestion_relief_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of projects intended to reduce traffic congestion"
    - name: "congestion_relief_investment"
      expr: SUM(CASE WHEN congestion_relief_indicator = true THEN CAST(estimated_cost AS DOUBLE) ELSE 0 END)
      comment: "Total capital investment in congestion relief projects, indicating mobility improvement funding"
    - name: "bridge_replacement_project_count"
      expr: SUM(CASE WHEN bridge_replacement_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of projects including bridge replacement or major rehabilitation"
    - name: "bridge_replacement_investment"
      expr: SUM(CASE WHEN bridge_replacement_indicator = true THEN CAST(estimated_cost AS DOUBLE) ELSE 0 END)
      comment: "Total capital investment in bridge replacement projects, indicating bridge program funding level"
    - name: "pavement_improvement_project_count"
      expr: SUM(CASE WHEN pavement_improvement_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of projects including pavement preservation, rehabilitation, or reconstruction"
    - name: "pavement_improvement_investment"
      expr: SUM(CASE WHEN pavement_improvement_indicator = true THEN CAST(estimated_cost AS DOUBLE) ELSE 0 END)
      comment: "Total capital investment in pavement improvement projects, indicating pavement program funding level"
    - name: "multimodal_project_count"
      expr: SUM(CASE WHEN multimodal_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of projects including multiple transportation modes (highway, transit, bicycle, pedestrian)"
    - name: "multimodal_investment"
      expr: SUM(CASE WHEN multimodal_indicator = true THEN CAST(estimated_cost AS DOUBLE) ELSE 0 END)
      comment: "Total capital investment in multimodal projects, indicating integrated transportation system funding"
    - name: "environmental_justice_project_count"
      expr: SUM(CASE WHEN environmental_justice_area_indicator = true THEN 1 ELSE 0 END)
      comment: "Count of projects located in or affecting environmental justice areas requiring special consideration"
    - name: "environmental_justice_investment"
      expr: SUM(CASE WHEN environmental_justice_area_indicator = true THEN CAST(estimated_cost AS DOUBLE) ELSE 0 END)
      comment: "Total capital investment in environmental justice areas, indicating equity-focused funding allocation"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`planning_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Transportation plan portfolio metrics tracking plan adoption, funding levels, performance targets, and compliance status. Used by planning executives to manage LRTP, CTP, STIP, and TIP development cycles and ensure federal/state regulatory compliance."
  source: "`feip_eastus_03`.`planning`.`plan`"
  dimensions:
    - name: "plan_name"
      expr: name
      comment: "Official name of the transportation plan"
    - name: "plan_type"
      expr: type
      comment: "Classification of transportation plan (LRTP, CTP, STIP, TIP, MPO Plan, RPO Plan)"
    - name: "geographic_scope"
      expr: geographic_scope
      comment: "Geographic coverage area indicating spatial extent of planning jurisdiction"
    - name: "modal_scope"
      expr: modal_scope
      comment: "Transportation modes addressed (single or multimodal)"
    - name: "base_year"
      expr: CAST(base_year AS STRING)
      comment: "Reference year for existing conditions and baseline data"
    - name: "horizon_year"
      expr: CAST(horizon_year AS STRING)
      comment: "Future target year for plan projections (typically 20-30 years)"
    - name: "federal_fiscal_year"
      expr: CAST(federal_fiscal_year AS STRING)
      comment: "Federal fiscal year for funding coordination (October 1 - September 30)"
    - name: "state_fiscal_year"
      expr: CAST(state_fiscal_year AS STRING)
      comment: "North Carolina state fiscal year for funding coordination (July 1 - June 30)"
    - name: "funding_constraint_status"
      expr: funding_constraint_status
      comment: "Fiscal constraint status (constrained to expected revenues or unconstrained vision)"
    - name: "air_quality_conformity_status"
      expr: air_quality_conformity_status
      comment: "Clean Air Act conformity determination status"
    - name: "nepa_compliance_status"
      expr: nepa_compliance_status
      comment: "NEPA environmental review status (CE, EA, EIS, FONSI, ROD)"
    - name: "performance_measures_included"
      expr: performance_measures_included
      comment: "Performance-based planning measures and targets inclusion indicator"
    - name: "congestion_management_process_integrated"
      expr: congestion_management_process_integrated
      comment: "Congestion Management Process integration indicator for TMAs"
    - name: "freight_planning_integrated"
      expr: freight_planning_integrated
      comment: "Freight transportation planning integration indicator"
    - name: "transit_planning_integrated"
      expr: transit_planning_integrated
      comment: "Public transit planning and FTA coordination integration indicator"
    - name: "bicycle_pedestrian_planning_integrated"
      expr: bicycle_pedestrian_planning_integrated
      comment: "Bicycle and pedestrian infrastructure planning integration indicator"
    - name: "climate_resilience_addressed"
      expr: climate_resilience_addressed
      comment: "Climate change impacts and resilience strategy inclusion indicator"
    - name: "equity_considerations_addressed"
      expr: equity_considerations_addressed
      comment: "Transportation equity and underserved community impact inclusion indicator"
    - name: "environmental_justice_analysis_completed"
      expr: environmental_justice_analysis_completed
      comment: "Environmental justice analysis completion indicator"
  measures:
    - name: "total_plan_count"
      expr: COUNT(1)
      comment: "Total number of transportation plans in the planning portfolio"
    - name: "total_estimated_cost"
      expr: SUM(CAST(total_estimated_cost AS DOUBLE))
      comment: "Total estimated cost across all transportation plans over planning horizons, representing full program funding requirement"
    - name: "avg_plan_cost"
      expr: AVG(CAST(total_estimated_cost AS DOUBLE))
      comment: "Average plan cost, indicating typical plan scale and investment level"
    - name: "total_federal_funding"
      expr: SUM(CAST(federal_funding_amount AS DOUBLE))
      comment: "Total federal funding allocation across all plans from FHWA, FTA, FAA, and other federal sources"
    - name: "total_state_funding"
      expr: SUM(CAST(state_funding_amount AS DOUBLE))
      comment: "Total North Carolina state funding allocation across all plans"
    - name: "total_local_funding"
      expr: SUM(CAST(local_funding_amount AS DOUBLE))
      comment: "Total local government funding contribution from counties and municipalities"
    - name: "total_other_funding"
      expr: SUM(CAST(other_funding_amount AS DOUBLE))
      comment: "Total funding from other sources including private investment, grants, and alternative financing"
    - name: "federal_funding_percentage"
      expr: ROUND(100.0 * SUM(CAST(federal_funding_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_estimated_cost AS DOUBLE)), 0), 2)
      comment: "Federal funding as percentage of total plan cost, indicating federal participation rate and funding leverage"
    - name: "state_funding_percentage"
      expr: ROUND(100.0 * SUM(CAST(state_funding_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_estimated_cost AS DOUBLE)), 0), 2)
      comment: "State funding as percentage of total plan cost, indicating state match and investment level"
    - name: "local_funding_percentage"
      expr: ROUND(100.0 * SUM(CAST(local_funding_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_estimated_cost AS DOUBLE)), 0), 2)
      comment: "Local funding as percentage of total plan cost, indicating local government participation and commitment"
    - name: "avg_update_cycle_years"
      expr: AVG(CAST(update_cycle_years AS DOUBLE))
      comment: "Average required frequency in years for plan updates per federal or state requirements"
    - name: "avg_public_comments_received"
      expr: AVG(CAST(number_of_public_comments_received AS DOUBLE))
      comment: "Average number of public comments received during plan development, indicating public engagement level"
    - name: "total_amendments"
      expr: SUM(CAST(amendment_count AS DOUBLE))
      comment: "Total number of formal amendments across all plans since original adoption"
    - name: "total_administrative_modifications"
      expr: SUM(CAST(administrative_modification_count AS DOUBLE))
      comment: "Total number of administrative modifications across all plans (minor changes not requiring full amendment)"
    - name: "avg_amendments_per_plan"
      expr: AVG(CAST(amendment_count AS DOUBLE))
      comment: "Average number of formal amendments per plan, indicating plan stability and change frequency"
    - name: "performance_measures_included_count"
      expr: SUM(CASE WHEN performance_measures_included = true THEN 1 ELSE 0 END)
      comment: "Count of plans including performance-based planning measures and targets as required by federal regulations"
    - name: "air_quality_conformity_required_count"
      expr: SUM(CASE WHEN air_quality_conformity_required = true THEN 1 ELSE 0 END)
      comment: "Count of plans subject to Clean Air Act transportation conformity requirements"
    - name: "congestion_management_integrated_count"
      expr: SUM(CASE WHEN congestion_management_process_integrated = true THEN 1 ELSE 0 END)
      comment: "Count of plans integrating Congestion Management Process as required for Transportation Management Areas"
    - name: "freight_planning_integrated_count"
      expr: SUM(CASE WHEN freight_planning_integrated = true THEN 1 ELSE 0 END)
      comment: "Count of plans integrating freight transportation planning and considerations"
    - name: "transit_planning_integrated_count"
      expr: SUM(CASE WHEN transit_planning_integrated = true THEN 1 ELSE 0 END)
      comment: "Count of plans integrating public transit planning and FTA coordination"
    - name: "bicycle_pedestrian_integrated_count"
      expr: SUM(CASE WHEN bicycle_pedestrian_planning_integrated = true THEN 1 ELSE 0 END)
      comment: "Count of plans integrating bicycle and pedestrian infrastructure planning"
    - name: "climate_resilience_addressed_count"
      expr: SUM(CASE WHEN climate_resilience_addressed = true THEN 1 ELSE 0 END)
      comment: "Count of plans addressing climate change impacts, adaptation strategies, and system resilience"
    - name: "equity_considerations_addressed_count"
      expr: SUM(CASE WHEN equity_considerations_addressed = true THEN 1 ELSE 0 END)
      comment: "Count of plans explicitly addressing transportation equity, accessibility, and underserved community impacts"
    - name: "environmental_justice_analysis_count"
      expr: SUM(CASE WHEN environmental_justice_analysis_completed = true THEN 1 ELSE 0 END)
      comment: "Count of plans with completed environmental justice analysis assessing impacts on minority and low-income populations"
    - name: "federal_authorization_received_count"
      expr: SUM(CASE WHEN federal_authorization_received = true THEN 1 ELSE 0 END)
      comment: "Count of plans with federal authorization or approval from FHWA, FTA, or other federal agencies"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`planning_funding_source`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Funding source portfolio metrics tracking federal, state, and local funding programs, eligibility criteria, match requirements, and program utilization. Used by finance and planning executives to optimize funding strategy and maximize federal participation."
  source: "`feip_eastus_03`.`planning`.`funding_source`"
  dimensions:
    - name: "source_code"
      expr: source_code
      comment: "Short alphanumeric code representing the funding source type"
    - name: "source_name"
      expr: source_name
      comment: "Full descriptive name of the funding source"
    - name: "source_abbreviation"
      expr: source_abbreviation
      comment: "Standard abbreviation (FHWA, STIP, GARVEE, BUILD, INFRA, RAISE)"
    - name: "category"
      expr: category
      comment: "High-level classification (federal, state, local, private, grant, bond, other)"
    - name: "funding_type"
      expr: funding_type
      comment: "Classification of funding purpose (capital, operating, maintenance, planning, emergency, discretionary, formula-based)"
    - name: "federal_program_code"
      expr: federal_program_code
      comment: "Code identifying specific federal transportation program (HSIP, CMAQ, STP, NHS)"
    - name: "status"
      expr: status
      comment: "Current operational status indicating availability for project programming"
    - name: "state_match_required"
      expr: state_match_required
      comment: "State matching funds requirement indicator"
    - name: "local_match_required"
      expr: local_match_required
      comment: "Local government matching funds requirement indicator"
    - name: "obligation_authority_required"
      expr: obligation_authority_required
      comment: "Federal obligation authority requirement indicator"
    - name: "competitive_application_required"
      expr: competitive_application_required
      comment: "Competitive application process requirement indicator"
    - name: "environmental_compliance_required"
      expr: environmental_compliance_required
      comment: "NEPA or environmental review requirement indicator"
    - name: "dbe_goals_applicable"
      expr: dbe_goals_applicable
      comment: "Disadvantaged Business Enterprise participation goals applicability indicator"
    - name: "prevailing_wage_required"
      expr: prevailing_wage_required
      comment: "Davis-Bacon prevailing wage requirement indicator"
    - name: "buy_america_required"
      expr: buy_america_required
      comment: "Buy America domestic materials requirement indicator"
    - name: "stip_inclusion_required"
      expr: stip_inclusion_required
      comment: "State Transportation Improvement Program inclusion requirement indicator"
    - name: "mpo_coordination_required"
      expr: mpo_coordination_required
      comment: "Metropolitan Planning Organization coordination requirement indicator"
    - name: "is_active"
      expr: is_active
      comment: "Active and available for project programming indicator"
  measures:
    - name: "total_funding_source_count"
      expr: COUNT(1)
      comment: "Total number of funding sources available in the transportation funding portfolio"
    - name: "active_funding_source_count"
      expr: SUM(CASE WHEN is_active = true THEN 1 ELSE 0 END)
      comment: "Count of currently active funding sources available for project programming"
    - name: "avg_federal_share_percentage"
      expr: AVG(CAST(federal_share_percentage AS DOUBLE))
      comment: "Average federal funding participation rate across all funding sources, indicating typical federal leverage"
    - name: "avg_state_match_percentage"
      expr: AVG(CAST(state_match_percentage AS DOUBLE))
      comment: "Average required state matching percentage across funding sources requiring state match"
    - name: "avg_local_match_percentage"
      expr: AVG(CAST(local_match_percentage AS DOUBLE))
      comment: "Average required local matching percentage across funding sources requiring local match"
    - name: "avg_flexibility_score"
      expr: AVG(CAST(flexibility_score AS DOUBLE))
      comment: "Average flexibility score (1-10 scale) indicating ease of use and flexibility across funding sources"
    - name: "state_match_required_count"
      expr: SUM(CASE WHEN state_match_required = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources requiring state matching funds"
    - name: "local_match_required_count"
      expr: SUM(CASE WHEN local_match_required = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources requiring local government matching funds"
    - name: "competitive_application_count"
      expr: SUM(CASE WHEN competitive_application_required = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources requiring competitive application process, indicating discretionary funding opportunities"
    - name: "environmental_compliance_required_count"
      expr: SUM(CASE WHEN environmental_compliance_required = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources requiring NEPA or environmental review compliance"
    - name: "dbe_goals_applicable_count"
      expr: SUM(CASE WHEN dbe_goals_applicable = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources with Disadvantaged Business Enterprise participation goals"
    - name: "prevailing_wage_required_count"
      expr: SUM(CASE WHEN prevailing_wage_required = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources requiring Davis-Bacon prevailing wage compliance"
    - name: "buy_america_required_count"
      expr: SUM(CASE WHEN buy_america_required = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources requiring Buy America domestic materials provisions"
    - name: "stip_inclusion_required_count"
      expr: SUM(CASE WHEN stip_inclusion_required = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources requiring State Transportation Improvement Program inclusion"
    - name: "mpo_coordination_required_count"
      expr: SUM(CASE WHEN mpo_coordination_required = true THEN 1 ELSE 0 END)
      comment: "Count of funding sources requiring Metropolitan Planning Organization coordination"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`planning_stakeholder`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Stakeholder engagement metrics tracking MPO, RPO, local agency, and advisory group participation in transportation planning processes. Used by planning executives to manage stakeholder coordination, meeting frequency, and planning involvement levels."
  source: "`feip_eastus_03`.`planning`.`stakeholder`"
  dimensions:
    - name: "stakeholder_name"
      expr: name
      comment: "Full legal or official name of the stakeholder organization or individual"
    - name: "stakeholder_type"
      expr: type
      comment: "Classification indicating organizational category and role in transportation planning"
    - name: "status"
      expr: status
      comment: "Current operational status of stakeholder relationship with NCDOT planning activities"
    - name: "mpo_designation"
      expr: mpo_designation
      comment: "Official MPO designation name if federally designated metropolitan planning organization"
    - name: "rpo_designation"
      expr: rpo_designation
      comment: "Official RPO designation name if rural planning organization"
    - name: "county"
      expr: county
      comment: "Primary county where stakeholder is located or operates"
    - name: "region"
      expr: region
      comment: "NCDOT administrative region or division for planning coordination"
    - name: "participation_level"
      expr: participation_level
      comment: "Level of formal participation and decision-making authority in planning processes"
    - name: "modal_focus"
      expr: modal_focus
      comment: "Primary transportation modes of focus (highway, transit, rail, aviation, bicycle, pedestrian, multimodal)"
    - name: "agreement_type"
      expr: agreement_type
      comment: "Type of formal agreement governing relationship between NCDOT and stakeholder"
    - name: "meeting_frequency"
      expr: meeting_frequency
      comment: "Regular frequency of scheduled meetings or coordination sessions"
    - name: "communication_preference"
      expr: communication_preference
      comment: "Preferred method of communication for stakeholder engagement"
    - name: "lrtp_involvement_flag"
      expr: lrtp_involvement_flag
      comment: "Long Range Transportation Plan development involvement indicator"
    - name: "ctp_involvement_flag"
      expr: ctp_involvement_flag
      comment: "Comprehensive Transportation Plan development participation indicator"
    - name: "stip_involvement_flag"
      expr: stip_involvement_flag
      comment: "State Transportation Improvement Program development participation indicator"
    - name: "tip_involvement_flag"
      expr: tip_involvement_flag
      comment: "Metropolitan Transportation Improvement Program involvement indicator"
    - name: "funding_source_flag"
      expr: funding_source_flag
      comment: "Funding or financial resources provision indicator"
    - name: "environmental_justice_community_flag"
      expr: environmental_justice_community_flag
      comment: "Environmental justice community representation indicator"
    - name: "data_sharing_agreement_flag"
      expr: data_sharing_agreement_flag
      comment: "Formal data sharing agreement existence indicator"
    - name: "gis_data_provider_flag"
      expr: gis_data_provider_flag
      comment: "GIS data or spatial information provision indicator"
    - name: "travel_demand_model_participant_flag"
      expr: travel_demand_model_participant_flag
      comment: "Travel demand modeling participation or input data provision indicator"
    - name: "influence_level"
      expr: influence_level
      comment: "Assessment of stakeholder influence on transportation planning decisions"
    - name: "interest_level"
      expr: interest_level
      comment: "Assessment of stakeholder interest and engagement level"
  measures:
    - name: "total_stakeholder_count"
      expr: COUNT(1)
      comment: "Total number of stakeholders in the transportation planning engagement portfolio"
    - name: "lrtp_involvement_count"
      expr: SUM(CASE WHEN lrtp_involvement_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders actively involved in Long Range Transportation Plan development"
    - name: "ctp_involvement_count"
      expr: SUM(CASE WHEN ctp_involvement_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders participating in Comprehensive Transportation Plan development"
    - name: "stip_involvement_count"
      expr: SUM(CASE WHEN stip_involvement_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders participating in State Transportation Improvement Program development"
    - name: "tip_involvement_count"
      expr: SUM(CASE WHEN tip_involvement_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders involved in metropolitan Transportation Improvement Program development"
    - name: "lrtp_involvement_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN lrtp_involvement_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stakeholders involved in LRTP development, indicating long-range planning engagement breadth"
    - name: "stip_involvement_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN stip_involvement_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of stakeholders involved in STIP development, indicating capital programming engagement breadth"
    - name: "funding_source_stakeholder_count"
      expr: SUM(CASE WHEN funding_source_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders providing funding or financial resources for transportation planning or projects"
    - name: "environmental_justice_stakeholder_count"
      expr: SUM(CASE WHEN environmental_justice_community_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders representing or serving environmental justice communities requiring special consideration"
    - name: "data_sharing_agreement_count"
      expr: SUM(CASE WHEN data_sharing_agreement_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders with formal data sharing agreements for planning data exchange"
    - name: "gis_data_provider_count"
      expr: SUM(CASE WHEN gis_data_provider_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders providing GIS data or spatial information to support planning activities"
    - name: "travel_demand_model_participant_count"
      expr: SUM(CASE WHEN travel_demand_model_participant_flag = true THEN 1 ELSE 0 END)
      comment: "Count of stakeholders participating in travel demand modeling or providing input data"
$$;