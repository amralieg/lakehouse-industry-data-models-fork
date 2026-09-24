-- Metric views for domain: environmental | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`environmental_mitigation_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for environmental mitigation plan performance, cost efficiency, and regulatory compliance tracking. Supports executive oversight of environmental impact offset programs and mitigation bank utilization."
  source: "`feip_eastus_03`.`environmental`.`mitigation_plan`"
  dimensions:
    - name: "mitigation_type"
      expr: mitigation_type
      comment: "Primary mitigation strategy employed (avoidance, minimization, rectification, compensation, restoration, creation, enhancement, preservation, monitoring)"
    - name: "impact_type"
      expr: impact_type
      comment: "Category of environmental impact being mitigated (wetland loss, stream disturbance, endangered species habitat, historic site disturbance)"
    - name: "plan_status"
      expr: plan_status
      comment: "Current lifecycle status of mitigation plan (draft, submitted, approved, in_progress, completed, monitoring, closed, suspended, cancelled)"
    - name: "mitigation_county"
      expr: mitigation_county
      comment: "North Carolina county where mitigation activities are taking place"
    - name: "responsible_division"
      expr: responsible_division
      comment: "NCDOT division responsible for overseeing mitigation plan implementation"
    - name: "permit_issuing_agency"
      expr: permit_issuing_agency
      comment: "Government agency that issued the environmental permit requiring this mitigation (USACE, NCDEQ, EPA, USFWS, SHPO)"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary source of funding for mitigation activities (state funds, federal highway funds, mitigation bank credits, in-lieu fee program)"
    - name: "success_criteria_met"
      expr: success_criteria_met
      comment: "Indicator of whether the mitigation plan has met all defined success criteria (true/false)"
    - name: "approval_year"
      expr: YEAR(approval_date)
      comment: "Year when the mitigation plan was officially approved by the regulatory agency"
    - name: "approval_quarter"
      expr: CONCAT('Q', QUARTER(approval_date), '-', YEAR(approval_date))
      comment: "Quarter and year when the mitigation plan was approved (format: Q1-2024)"
  measures:
    - name: "total_mitigation_plans"
      expr: COUNT(1)
      comment: "Total number of environmental mitigation plans in the system"
    - name: "total_impact_area_acres"
      expr: SUM(CAST(impact_area_acres AS DOUBLE))
      comment: "Total area of environmental impact measured in acres across all mitigation plans"
    - name: "total_mitigation_area_acres"
      expr: SUM(CAST(mitigation_area_acres AS DOUBLE))
      comment: "Total area of mitigation activity measured in acres across all plans"
    - name: "avg_mitigation_ratio"
      expr: AVG(CAST(mitigation_ratio AS DOUBLE))
      comment: "Average ratio of mitigation area to impact area across all plans (e.g., 2.0 means 2:1 mitigation ratio)"
    - name: "total_estimated_cost"
      expr: SUM(CAST(estimated_cost_amount AS DOUBLE))
      comment: "Total estimated cost for implementing all mitigation plans including construction, monitoring, and administrative costs"
    - name: "total_actual_cost"
      expr: SUM(CAST(actual_cost_amount AS DOUBLE))
      comment: "Total actual cost incurred for implementing all mitigation plans"
    - name: "avg_cost_per_acre_mitigated"
      expr: ROUND(SUM(CAST(actual_cost_amount AS DOUBLE)) / NULLIF(SUM(CAST(mitigation_area_acres AS DOUBLE)), 0), 2)
      comment: "Average actual cost per acre of mitigation activity, indicating cost efficiency of environmental offset programs"
    - name: "cost_variance_pct"
      expr: ROUND(100.0 * (SUM(CAST(actual_cost_amount AS DOUBLE)) - SUM(CAST(estimated_cost_amount AS DOUBLE))) / NULLIF(SUM(CAST(estimated_cost_amount AS DOUBLE)), 0), 2)
      comment: "Percentage variance between actual and estimated mitigation costs, indicating budget accuracy and cost control effectiveness"
    - name: "total_mitigation_credits_purchased"
      expr: SUM(CAST(mitigation_credits_purchased AS DOUBLE))
      comment: "Total number of mitigation credits purchased from mitigation banks or in-lieu fee programs"
    - name: "avg_credit_cost_per_unit"
      expr: AVG(CAST(credit_cost_per_unit AS DOUBLE))
      comment: "Average cost per mitigation credit purchased, indicating market pricing trends for environmental offsets"
    - name: "total_performance_bond_amount"
      expr: SUM(CAST(performance_bond_amount AS DOUBLE))
      comment: "Total dollar amount of performance bonds required to guarantee completion of mitigation activities"
    - name: "plans_requiring_corrective_action"
      expr: SUM(CASE WHEN corrective_action_required = true THEN 1 ELSE 0 END)
      comment: "Number of mitigation plans requiring corrective actions based on inspection findings or monitoring results"
    - name: "corrective_action_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN corrective_action_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of mitigation plans requiring corrective action, indicating compliance quality and implementation effectiveness"
    - name: "plans_meeting_success_criteria"
      expr: SUM(CASE WHEN success_criteria_met = true THEN 1 ELSE 0 END)
      comment: "Number of mitigation plans that have met all defined success criteria"
    - name: "success_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN success_criteria_met = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of mitigation plans meeting success criteria, indicating overall program effectiveness in achieving environmental offset goals"
    - name: "avg_monitoring_duration_years"
      expr: AVG(CAST(monitoring_duration_years AS DOUBLE))
      comment: "Average required duration of post-implementation monitoring in years across all mitigation plans"
    - name: "total_impact_linear_feet"
      expr: SUM(CAST(impact_linear_feet AS DOUBLE))
      comment: "Total linear measurement of environmental impact in feet (e.g., feet of stream affected)"
    - name: "total_mitigation_linear_feet"
      expr: SUM(CAST(mitigation_linear_feet AS DOUBLE))
      comment: "Total linear measurement of mitigation activity in feet (e.g., feet of stream restored)"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`environmental_monitoring_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational KPIs for environmental monitoring compliance, exceedance tracking, and corrective action management. Supports regulatory reporting and environmental quality assurance oversight."
  source: "`feip_eastus_03`.`environmental`.`monitoring_event`"
  dimensions:
    - name: "monitoring_type"
      expr: monitoring_type
      comment: "Category of environmental monitoring activity conducted (water quality, air quality, species surveys, noise monitoring)"
    - name: "compliance_status"
      expr: compliance_status
      comment: "Indicates whether the measured value meets regulatory or permit compliance requirements"
    - name: "county"
      expr: county
      comment: "North Carolina county where the monitoring event took place"
    - name: "parameter_measured"
      expr: parameter_measured
      comment: "Specific environmental parameter or indicator being measured (pH, dissolved oxygen, particulate matter, decibels, species count)"
    - name: "permit_type"
      expr: permit_type
      comment: "Category of environmental permit governing the monitoring requirement"
    - name: "monitoring_phase"
      expr: monitoring_phase
      comment: "Project phase during which the monitoring event occurred (pre-construction, construction, post-construction, operational)"
    - name: "exceedance_flag"
      expr: exceedance_flag
      comment: "Boolean indicator of whether the measured value exceeded the regulatory threshold (true/false)"
    - name: "corrective_action_required"
      expr: corrective_action_required
      comment: "Indicates whether corrective action is required based on the monitoring results (true/false)"
    - name: "event_year"
      expr: YEAR(event_date)
      comment: "Year when the environmental monitoring event occurred"
    - name: "event_quarter"
      expr: CONCAT('Q', QUARTER(event_date), '-', YEAR(event_date))
      comment: "Quarter and year when the monitoring event occurred (format: Q1-2024)"
    - name: "event_month"
      expr: DATE_TRUNC('MONTH', event_date)
      comment: "Month when the environmental monitoring event occurred"
  measures:
    - name: "total_monitoring_events"
      expr: COUNT(1)
      comment: "Total number of environmental monitoring events conducted"
    - name: "total_exceedances"
      expr: SUM(CASE WHEN exceedance_flag = true THEN 1 ELSE 0 END)
      comment: "Total number of monitoring events where measured values exceeded regulatory thresholds"
    - name: "exceedance_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN exceedance_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of monitoring events resulting in regulatory threshold exceedances, indicating environmental compliance risk"
    - name: "events_requiring_corrective_action"
      expr: SUM(CASE WHEN corrective_action_required = true THEN 1 ELSE 0 END)
      comment: "Number of monitoring events requiring corrective action based on results"
    - name: "corrective_action_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN corrective_action_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of monitoring events requiring corrective action, indicating environmental management intervention frequency"
    - name: "avg_measured_value"
      expr: AVG(CAST(measured_value AS DOUBLE))
      comment: "Average numeric value observed or measured across all monitoring events for the selected parameter"
    - name: "avg_threshold_value"
      expr: AVG(CAST(threshold_value AS DOUBLE))
      comment: "Average regulatory or permit threshold value across all monitoring events"
    - name: "avg_threshold_margin_pct"
      expr: ROUND(100.0 * AVG((CAST(threshold_value AS DOUBLE) - CAST(measured_value AS DOUBLE)) / NULLIF(CAST(threshold_value AS DOUBLE), 0)), 2)
      comment: "Average percentage margin between measured values and regulatory thresholds, indicating compliance buffer (positive = below threshold, negative = exceedance)"
    - name: "avg_ph_level"
      expr: AVG(CAST(ph_level AS DOUBLE))
      comment: "Average pH measurement across water quality monitoring events, indicating acidity/alkalinity trends"
    - name: "avg_dissolved_oxygen"
      expr: AVG(CAST(dissolved_oxygen AS DOUBLE))
      comment: "Average concentration of dissolved oxygen in water across monitoring events (mg/L), indicating aquatic ecosystem health"
    - name: "avg_turbidity"
      expr: AVG(CAST(turbidity AS DOUBLE))
      comment: "Average water clarity measurement in Nephelometric Turbidity Units (NTU) across monitoring events"
    - name: "avg_total_suspended_solids"
      expr: AVG(CAST(total_suspended_solids AS DOUBLE))
      comment: "Average concentration of suspended particles in water (mg/L) across monitoring events"
    - name: "avg_noise_level_db"
      expr: AVG(CAST(noise_level_db AS DOUBLE))
      comment: "Average sound pressure level in decibels (dB) across noise monitoring events"
    - name: "avg_particulate_matter_pm25"
      expr: AVG(CAST(particulate_matter_pm25 AS DOUBLE))
      comment: "Average concentration of fine particulate matter PM2.5 (micrograms per cubic meter) across air quality monitoring events"
    - name: "avg_particulate_matter_pm10"
      expr: AVG(CAST(particulate_matter_pm10 AS DOUBLE))
      comment: "Average concentration of particulate matter PM10 (micrograms per cubic meter) across air quality monitoring events"
    - name: "avg_temperature"
      expr: AVG(CAST(temperature AS DOUBLE))
      comment: "Average ambient or water temperature in degrees Celsius at time of monitoring"
    - name: "distinct_projects_monitored"
      expr: COUNT(DISTINCT project_number)
      comment: "Number of distinct transportation projects with environmental monitoring activities"
    - name: "distinct_inspectors"
      expr: COUNT(DISTINCT inspector_name)
      comment: "Number of distinct environmental inspectors or monitors conducting field observations"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`environmental_permit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for environmental permit lifecycle management, compliance tracking, and regulatory coordination. Supports executive oversight of permit portfolio risk and processing efficiency."
  source: "`feip_eastus_03`.`environmental`.`permit`"
  dimensions:
    - name: "permit_type"
      expr: type
      comment: "Classification of the environmental permit based on regulatory requirement and environmental resource protected"
    - name: "permit_status"
      expr: status
      comment: "Current lifecycle status of the environmental permit"
    - name: "issuing_agency"
      expr: issuing_agency
      comment: "Regulatory agency or governmental body that issued the environmental permit"
    - name: "county"
      expr: county
      comment: "North Carolina county where the permitted project is located"
    - name: "division"
      expr: division
      comment: "NCDOT highway division responsible for the project covered by the permit"
    - name: "compliance_status"
      expr: compliance_status
      comment: "Current status of compliance with permit conditions and regulatory requirements"
    - name: "impact_type"
      expr: impact_type
      comment: "Type of environmental resource or impact addressed by the permit"
    - name: "mitigation_required"
      expr: mitigation_required
      comment: "Indicates whether environmental mitigation is required as a condition of the permit (true/false)"
    - name: "issue_year"
      expr: YEAR(issue_date)
      comment: "Year when the permit was officially issued by the regulatory agency"
    - name: "issue_quarter"
      expr: CONCAT('Q', QUARTER(issue_date), '-', YEAR(issue_date))
      comment: "Quarter and year when the permit was issued (format: Q1-2024)"
  measures:
    - name: "total_permits"
      expr: COUNT(1)
      comment: "Total number of environmental permits in the system"
    - name: "active_permits"
      expr: SUM(CASE WHEN status IN ('active', 'issued', 'effective') THEN 1 ELSE 0 END)
      comment: "Number of currently active environmental permits"
    - name: "expired_permits"
      expr: SUM(CASE WHEN status = 'expired' THEN 1 ELSE 0 END)
      comment: "Number of expired environmental permits requiring renewal or closure"
    - name: "permits_in_violation"
      expr: SUM(CASE WHEN compliance_status IN ('non-compliant', 'violation', 'enforcement') THEN 1 ELSE 0 END)
      comment: "Number of permits currently in violation or non-compliance status"
    - name: "violation_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_status IN ('non-compliant', 'violation', 'enforcement') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of permits in violation status, indicating regulatory compliance risk exposure"
    - name: "total_violation_count"
      expr: SUM(CAST(violation_count AS DOUBLE))
      comment: "Total number of permit violations or non-compliance incidents recorded across all permits"
    - name: "avg_violations_per_permit"
      expr: ROUND(SUM(CAST(violation_count AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average number of violations per permit, indicating compliance quality and enforcement intensity"
    - name: "total_penalty_amount"
      expr: SUM(CAST(penalty_amount AS DOUBLE))
      comment: "Total monetary penalties assessed for permit violations or non-compliance across all permits"
    - name: "avg_penalty_per_violation"
      expr: ROUND(SUM(CAST(penalty_amount AS DOUBLE)) / NULLIF(SUM(CAST(violation_count AS DOUBLE)), 0), 2)
      comment: "Average monetary penalty per violation incident, indicating financial risk of non-compliance"
    - name: "total_wetland_impact_acres"
      expr: SUM(CAST(wetland_impact_acres AS DOUBLE))
      comment: "Total acreage of wetland impacts authorized across all permits"
    - name: "total_stream_impact_linear_feet"
      expr: SUM(CAST(stream_impact_linear_feet AS DOUBLE))
      comment: "Total linear feet of stream impacts authorized across all permits"
    - name: "total_mitigation_area_acres"
      expr: SUM(CAST(mitigation_area_acres AS DOUBLE))
      comment: "Total acreage of environmental mitigation required across all permits"
    - name: "total_mitigation_credits_purchased"
      expr: SUM(CAST(mitigation_credits_purchased AS DOUBLE))
      comment: "Total number of mitigation credits purchased to satisfy permit requirements"
    - name: "total_bond_amount"
      expr: SUM(CAST(bond_amount AS DOUBLE))
      comment: "Total dollar amount of performance or financial assurance bonds required across all permits"
    - name: "total_fee_amount"
      expr: SUM(CAST(fee_amount AS DOUBLE))
      comment: "Total fees charged by regulatory agencies for processing and issuing permits"
    - name: "permits_requiring_mitigation"
      expr: SUM(CASE WHEN mitigation_required = true THEN 1 ELSE 0 END)
      comment: "Number of permits requiring environmental mitigation as a condition"
    - name: "mitigation_requirement_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN mitigation_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of permits requiring mitigation, indicating environmental impact severity across permit portfolio"
    - name: "permits_with_appeals"
      expr: SUM(CASE WHEN appeal_filed = true THEN 1 ELSE 0 END)
      comment: "Number of permits with appeals filed regarding permit decisions or conditions"
    - name: "appeal_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN appeal_filed = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of permits with appeals filed, indicating regulatory dispute frequency"
    - name: "permits_requiring_consultation"
      expr: SUM(CASE WHEN consultation_required = true THEN 1 ELSE 0 END)
      comment: "Number of permits requiring consultation with other agencies (SHPO, FWS, USACE)"
    - name: "distinct_issuing_agencies"
      expr: COUNT(DISTINCT issuing_agency)
      comment: "Number of distinct regulatory agencies issuing permits, indicating regulatory coordination complexity"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`environmental_permit_application`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational KPIs for environmental permit application processing efficiency, approval rates, and regulatory review cycle times. Supports process improvement and regulatory coordination optimization."
  source: "`feip_eastus_03`.`environmental`.`permit_application`"
  dimensions:
    - name: "permit_type"
      expr: permit_type
      comment: "Category of environmental permit being requested (Section 404 Clean Water Act, air quality, stormwater, erosion control, wetland impact, stream impact, endangered species, historic preservation, noise, hazardous materials)"
    - name: "application_status"
      expr: application_status
      comment: "Current status of the permit application in the review and approval process"
    - name: "regulatory_agency"
      expr: regulatory_agency
      comment: "Primary regulatory agency responsible for reviewing and approving the permit application (USACE, NCDEQ, EPA, SHPO, USFWS, NOAA, FAA, FRA)"
    - name: "project_county"
      expr: project_county
      comment: "North Carolina county where the project and associated environmental impacts are located"
    - name: "project_division"
      expr: project_division
      comment: "NCDOT highway division responsible for the project (Division 1 through Division 14)"
    - name: "priority_level"
      expr: priority_level
      comment: "Priority classification of the permit application based on project urgency and importance"
    - name: "mitigation_required"
      expr: mitigation_required
      comment: "Indicates whether environmental mitigation measures are required as a condition of permit approval (true/false)"
    - name: "submission_year"
      expr: YEAR(submission_date)
      comment: "Year when the permit application was officially submitted to the regulatory agency"
    - name: "submission_quarter"
      expr: CONCAT('Q', QUARTER(submission_date), '-', YEAR(submission_date))
      comment: "Quarter and year when the permit application was submitted (format: Q1-2024)"
  measures:
    - name: "total_applications"
      expr: COUNT(1)
      comment: "Total number of environmental permit applications submitted"
    - name: "approved_applications"
      expr: SUM(CASE WHEN application_status = 'approved' THEN 1 ELSE 0 END)
      comment: "Number of permit applications that have been officially approved by regulatory agencies"
    - name: "denied_applications"
      expr: SUM(CASE WHEN application_status = 'denied' THEN 1 ELSE 0 END)
      comment: "Number of permit applications that have been officially denied by regulatory agencies"
    - name: "approval_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN application_status = 'approved' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN application_status IN ('approved', 'denied') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of permit applications approved out of all decided applications, indicating regulatory approval success rate"
    - name: "avg_review_duration_days"
      expr: AVG(CAST(actual_review_duration_days AS DOUBLE))
      comment: "Average number of days taken by regulatory agencies to complete permit review process, indicating processing efficiency"
    - name: "avg_review_variance_days"
      expr: AVG(CAST(actual_review_duration_days AS DOUBLE) - CAST(estimated_review_duration_days AS DOUBLE))
      comment: "Average variance between actual and estimated review duration in days, indicating schedule predictability"
    - name: "total_wetland_impact_acres"
      expr: SUM(CAST(wetland_impact_acres AS DOUBLE))
      comment: "Total wetland area in acres that will be impacted by projects covered by permit applications"
    - name: "total_stream_impact_linear_feet"
      expr: SUM(CAST(stream_impact_linear_feet AS DOUBLE))
      comment: "Total length of stream in linear feet that will be impacted by projects covered by permit applications"
    - name: "total_mitigation_area_acres"
      expr: SUM(CAST(mitigation_area_acres AS DOUBLE))
      comment: "Total area in acres designated for environmental mitigation activities across all applications"
    - name: "total_mitigation_cost_estimate"
      expr: SUM(CAST(mitigation_cost_estimate AS DOUBLE))
      comment: "Total estimated cost in US dollars for implementing required environmental mitigation measures across all applications"
    - name: "avg_mitigation_cost_per_acre"
      expr: ROUND(SUM(CAST(mitigation_cost_estimate AS DOUBLE)) / NULLIF(SUM(CAST(mitigation_area_acres AS DOUBLE)), 0), 2)
      comment: "Average estimated cost per acre of mitigation activity, indicating mitigation cost efficiency"
    - name: "total_application_fees"
      expr: SUM(CAST(application_fee_amount AS DOUBLE))
      comment: "Total fee amount in US dollars required to be paid for processing all permit applications"
    - name: "applications_requiring_mitigation"
      expr: SUM(CASE WHEN mitigation_required = true THEN 1 ELSE 0 END)
      comment: "Number of permit applications requiring environmental mitigation measures"
    - name: "mitigation_requirement_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN mitigation_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of permit applications requiring mitigation, indicating environmental impact severity across application portfolio"
    - name: "applications_with_public_comment"
      expr: SUM(CASE WHEN public_comment_required = true THEN 1 ELSE 0 END)
      comment: "Number of permit applications requiring a public comment period as part of the review process"
    - name: "applications_with_endangered_species"
      expr: SUM(CASE WHEN endangered_species_present = true THEN 1 ELSE 0 END)
      comment: "Number of permit applications where federally listed endangered or threatened species are present in the project area"
    - name: "applications_with_historic_properties"
      expr: SUM(CASE WHEN historic_properties_present = true THEN 1 ELSE 0 END)
      comment: "Number of permit applications where historic properties or archaeological sites are present requiring Section 106 review"
    - name: "withdrawn_applications"
      expr: SUM(CASE WHEN application_status = 'withdrawn' THEN 1 ELSE 0 END)
      comment: "Number of permit applications withdrawn by the applicant before decision"
    - name: "applications_with_appeals"
      expr: SUM(CASE WHEN appeal_filed = true THEN 1 ELSE 0 END)
      comment: "Number of permit applications with appeals filed in response to denial or conditions"
    - name: "distinct_regulatory_agencies"
      expr: COUNT(DISTINCT regulatory_agency)
      comment: "Number of distinct regulatory agencies processing permit applications, indicating regulatory coordination complexity"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`environmental_nepa_document`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for NEPA environmental review process efficiency, environmental impact assessment, and regulatory approval cycle times. Supports executive oversight of federal environmental compliance and project delivery timelines."
  source: "`feip_eastus_03`.`environmental`.`nepa_document`"
  dimensions:
    - name: "document_type"
      expr: document_type
      comment: "Type of NEPA documentation (Environmental Impact Statement EIS, Environmental Assessment EA, Categorical Exclusion CE, Finding of No Significant Impact FONSI)"
    - name: "approval_status"
      expr: approval_status
      comment: "Current approval status of the NEPA document in the review and approval workflow"
    - name: "county"
      expr: county
      comment: "North Carolina county or counties where the project is located"
    - name: "division"
      expr: division
      comment: "NCDOT division responsible for the project area"
    - name: "environmental_classification"
      expr: environmental_classification
      comment: "FHWA environmental classification level assigned to the project based on anticipated environmental impacts"
    - name: "mitigation_required"
      expr: mitigation_required
      comment: "Indicates whether environmental mitigation measures are required for the project (true/false)"
    - name: "section_404_permit_required"
      expr: section_404_permit_required
      comment: "Indicates whether a Clean Water Act Section 404 permit is required for wetland or water body impacts (true/false)"
    - name: "endangered_species_consultation_required"
      expr: endangered_species_consultation_required
      comment: "Indicates whether Endangered Species Act Section 7 consultation is required for threatened or endangered species (true/false)"
    - name: "approval_year"
      expr: YEAR(approval_date)
      comment: "Year when the NEPA document received official approval from FHWA or delegated authority"
    - name: "approval_quarter"
      expr: CONCAT('Q', QUARTER(approval_date), '-', YEAR(approval_date))
      comment: "Quarter and year when the NEPA document was approved (format: Q1-2024)"
  measures:
    - name: "total_nepa_documents"
      expr: COUNT(1)
      comment: "Total number of NEPA environmental review documents in the system"
    - name: "approved_documents"
      expr: SUM(CASE WHEN approval_status = 'approved' THEN 1 ELSE 0 END)
      comment: "Number of NEPA documents that have received official approval from FHWA or delegated authority"
    - name: "total_public_comments_received"
      expr: SUM(CAST(comments_received_count AS DOUBLE))
      comment: "Total number of public comments received during comment periods across all NEPA documents"
    - name: "avg_comments_per_document"
      expr: ROUND(SUM(CAST(comments_received_count AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average number of public comments received per NEPA document, indicating public engagement intensity"
    - name: "total_project_length_miles"
      expr: SUM(CAST(project_length_miles AS DOUBLE))
      comment: "Total length of project corridors in miles across all NEPA documents"
    - name: "avg_project_length_miles"
      expr: AVG(CAST(project_length_miles AS DOUBLE))
      comment: "Average length of project corridors in miles per NEPA document"
    - name: "total_wetland_impacts_acres"
      expr: SUM(CAST(wetland_impacts_acres AS DOUBLE))
      comment: "Total acreage of wetlands impacted by proposed projects across all NEPA documents"
    - name: "total_stream_impacts_linear_feet"
      expr: SUM(CAST(stream_impacts_linear_feet AS DOUBLE))
      comment: "Total linear feet of streams impacted by proposed projects across all NEPA documents"
    - name: "total_farmland_impacts_acres"
      expr: SUM(CAST(farmland_impacts_acres AS DOUBLE))
      comment: "Total acreage of prime or unique farmland impacted by projects across all NEPA documents"
    - name: "total_estimated_project_cost"
      expr: SUM(CAST(estimated_project_cost AS DOUBLE))
      comment: "Total estimated cost of transportation projects in US dollars across all NEPA documents"
    - name: "avg_estimated_project_cost"
      expr: AVG(CAST(estimated_project_cost AS DOUBLE))
      comment: "Average estimated cost per transportation project covered by NEPA documents"
    - name: "total_right_of_way_parcels_required"
      expr: SUM(CAST(right_of_way_parcels_required AS DOUBLE))
      comment: "Total number of property parcels requiring right-of-way acquisition across all projects"
    - name: "total_residential_relocations_required"
      expr: SUM(CAST(residential_relocations_required AS DOUBLE))
      comment: "Total number of residential properties requiring relocation due to right-of-way acquisition across all projects"
    - name: "total_business_relocations_required"
      expr: SUM(CAST(business_relocations_required AS DOUBLE))
      comment: "Total number of businesses requiring relocation due to right-of-way acquisition across all projects"
    - name: "avg_alternatives_considered"
      expr: AVG(CAST(alternatives_considered_count AS DOUBLE))
      comment: "Average number of project alternatives evaluated per NEPA document, including the no-build alternative"
    - name: "documents_requiring_mitigation"
      expr: SUM(CASE WHEN mitigation_required = true THEN 1 ELSE 0 END)
      comment: "Number of NEPA documents where environmental mitigation measures are required for the project"
    - name: "mitigation_requirement_rate_pct"
      expr: ROUND(100.0 * SUM(CASE WHEN mitigation_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of NEPA documents requiring mitigation, indicating environmental impact severity across project portfolio"
    - name: "documents_requiring_section_404_permit"
      expr: SUM(CASE WHEN section_404_permit_required = true THEN 1 ELSE 0 END)
      comment: "Number of NEPA documents where Clean Water Act Section 404 permit is required for wetland or water body impacts"
    - name: "documents_with_endangered_species"
      expr: SUM(CASE WHEN threatened_endangered_species_present = true THEN 1 ELSE 0 END)
      comment: "Number of NEPA documents where federally listed threatened or endangered species are present in the project area"
    - name: "documents_with_historic_properties"
      expr: SUM(CASE WHEN historic_properties_affected = true THEN 1 ELSE 0 END)
      comment: "Number of NEPA documents where historic properties listed or eligible for the National Register are affected by the project"
    - name: "documents_with_environmental_justice_impacts"
      expr: SUM(CASE WHEN disproportionate_impacts_identified = true THEN 1 ELSE 0 END)
      comment: "Number of NEPA documents where disproportionately high and adverse impacts on minority or low-income populations were identified"
    - name: "documents_requiring_reevaluation"
      expr: SUM(CASE WHEN reevaluation_required = true THEN 1 ELSE 0 END)
      comment: "Number of NEPA documents requiring reevaluation due to significant changes in project scope, design, or environmental conditions"
$$;