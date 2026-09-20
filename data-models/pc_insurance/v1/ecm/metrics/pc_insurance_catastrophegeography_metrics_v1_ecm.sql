-- Metric views for domain: catastrophegeography | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_accumulation_limit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Accumulation Limit business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit`"
  dimensions:
    - name: "Accumulation Limit Status"
      expr: accumulation_limit_status
    - name: "Approval Authority"
      expr: approval_authority
    - name: "Approval Date"
      expr: approval_date
    - name: "Approved By"
      expr: approved_by
    - name: "Business Justification"
      expr: business_justification
    - name: "Calculation Timestamp"
      expr: calculation_timestamp
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Geographic Scope"
      expr: geographic_scope
    - name: "Last Review Date"
      expr: last_review_date
    - name: "Limit Basis"
      expr: limit_basis
    - name: "Limit Type"
      expr: limit_type
    - name: "Model Vendor"
      expr: model_vendor
    - name: "Model Version"
      expr: model_version
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Accumulation Limit"
      expr: COUNT(DISTINCT accumulation_limit_id)
    - name: "Total Available Capacity"
      expr: SUM(available_capacity)
    - name: "Average Available Capacity"
      expr: AVG(available_capacity)
    - name: "Total Ceded Percent"
      expr: SUM(ceded_percent)
    - name: "Average Ceded Percent"
      expr: AVG(ceded_percent)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Hard Threshold Percent"
      expr: SUM(hard_threshold_percent)
    - name: "Average Hard Threshold Percent"
      expr: AVG(hard_threshold_percent)
    - name: "Total Limit Amount"
      expr: SUM(limit_amount)
    - name: "Average Limit Amount"
      expr: AVG(limit_amount)
    - name: "Total Net Retention Amount"
      expr: SUM(net_retention_amount)
    - name: "Average Net Retention Amount"
      expr: AVG(net_retention_amount)
    - name: "Total Pml Return Period Years"
      expr: SUM(pml_return_period_years)
    - name: "Average Pml Return Period Years"
      expr: AVG(pml_return_period_years)
    - name: "Total Soft Threshold Percent"
      expr: SUM(soft_threshold_percent)
    - name: "Average Soft Threshold Percent"
      expr: AVG(soft_threshold_percent)
    - name: "Total Utilization Amount"
      expr: SUM(utilization_amount)
    - name: "Average Utilization Amount"
      expr: AVG(utilization_amount)
    - name: "Total Utilization Percent"
      expr: SUM(utilization_percent)
    - name: "Average Utilization Percent"
      expr: AVG(utilization_percent)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_cat_event_loss`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cat Event Loss business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss`"
  dimensions:
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Estimate Date"
      expr: estimate_date
    - name: "Estimate Status"
      expr: estimate_status
    - name: "Geography Code"
      expr: geography_code
    - name: "Loss Estimate Type"
      expr: loss_estimate_type
    - name: "Model Vendor"
      expr: model_vendor
    - name: "Model Version"
      expr: model_version
    - name: "Notes"
      expr: notes
    - name: "Peril Code"
      expr: peril_code
    - name: "Updated Timestamp"
      expr: updated_timestamp
    - name: "Created Timestamp Month"
      expr: DATE_TRUNC('MONTH', created_timestamp)
    - name: "Estimate Date Month"
      expr: DATE_TRUNC('MONTH', estimate_date)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Cat Event Loss"
      expr: COUNT(DISTINCT cat_event_loss_id)
    - name: "Total Accident Year"
      expr: SUM(accident_year)
    - name: "Average Accident Year"
      expr: AVG(accident_year)
    - name: "Total Alae Amount"
      expr: SUM(alae_amount)
    - name: "Average Alae Amount"
      expr: AVG(alae_amount)
    - name: "Total Average Annual Loss"
      expr: SUM(average_annual_loss)
    - name: "Average Average Annual Loss"
      expr: AVG(average_annual_loss)
    - name: "Total Ceded Loss Amount"
      expr: SUM(ceded_loss_amount)
    - name: "Average Ceded Loss Amount"
      expr: AVG(ceded_loss_amount)
    - name: "Total Claim Count Estimate"
      expr: SUM(claim_count_estimate)
    - name: "Average Claim Count Estimate"
      expr: AVG(claim_count_estimate)
    - name: "Total Confidence Level Percent"
      expr: SUM(confidence_level_percent)
    - name: "Average Confidence Level Percent"
      expr: AVG(confidence_level_percent)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Gross Loss Amount"
      expr: SUM(gross_loss_amount)
    - name: "Average Gross Loss Amount"
      expr: AVG(gross_loss_amount)
    - name: "Total Ibnr Loading Amount"
      expr: SUM(ibnr_loading_amount)
    - name: "Average Ibnr Loading Amount"
      expr: AVG(ibnr_loading_amount)
    - name: "Total Loss Ratio Percent"
      expr: SUM(loss_ratio_percent)
    - name: "Average Loss Ratio Percent"
      expr: AVG(loss_ratio_percent)
    - name: "Total Net Loss Amount"
      expr: SUM(net_loss_amount)
    - name: "Average Net Loss Amount"
      expr: AVG(net_loss_amount)
    - name: "Total Policy Count"
      expr: SUM(policy_count)
    - name: "Average Policy Count"
      expr: AVG(policy_count)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_cat_event_zone_impact`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cat Event Zone Impact business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact`"
  dimensions:
    - name: "Exposure End Timestamp"
      expr: exposure_end_timestamp
    - name: "Exposure Start Timestamp"
      expr: exposure_start_timestamp
    - name: "Impact Severity Band"
      expr: impact_severity_band
    - name: "Shake Intensity"
      expr: shake_intensity
    - name: "Storm Surge Flag"
      expr: storm_surge_flag
    - name: "Exposure End Timestamp Month"
      expr: DATE_TRUNC('MONTH', exposure_end_timestamp)
    - name: "Exposure Start Timestamp Month"
      expr: DATE_TRUNC('MONTH', exposure_start_timestamp)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Cat Event Zone Impact"
      expr: COUNT(DISTINCT cat_event_zone_impact_id)
    - name: "Total Exposed Policy Count"
      expr: SUM(exposed_policy_count)
    - name: "Average Exposed Policy Count"
      expr: AVG(exposed_policy_count)
    - name: "Total Exposed Tiv Amount"
      expr: SUM(exposed_tiv_amount)
    - name: "Average Exposed Tiv Amount"
      expr: AVG(exposed_tiv_amount)
    - name: "Total Flood Depth Ft"
      expr: SUM(flood_depth_ft)
    - name: "Average Flood Depth Ft"
      expr: AVG(flood_depth_ft)
    - name: "Total Hail Size Inches"
      expr: SUM(hail_size_inches)
    - name: "Average Hail Size Inches"
      expr: AVG(hail_size_inches)
    - name: "Total Modeled Damage Percent"
      expr: SUM(modeled_damage_percent)
    - name: "Average Modeled Damage Percent"
      expr: AVG(modeled_damage_percent)
    - name: "Total Modeled Loss Ratio"
      expr: SUM(modeled_loss_ratio)
    - name: "Average Modeled Loss Ratio"
      expr: AVG(modeled_loss_ratio)
    - name: "Total Rainfall Inches"
      expr: SUM(rainfall_inches)
    - name: "Average Rainfall Inches"
      expr: AVG(rainfall_inches)
    - name: "Total Storm Surge Height Ft"
      expr: SUM(storm_surge_height_ft)
    - name: "Average Storm Surge Height Ft"
      expr: AVG(storm_surge_height_ft)
    - name: "Total Wind Gust Mph"
      expr: SUM(wind_gust_mph)
    - name: "Average Wind Gust Mph"
      expr: AVG(wind_gust_mph)
    - name: "Total Wind Speed Mph"
      expr: SUM(wind_speed_mph)
    - name: "Average Wind Speed Mph"
      expr: AVG(wind_speed_mph)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_cat_event_zone_xref`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cat Event Zone Xref business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref`"
  dimensions:
    - name: "Calculation Timestamp"
      expr: calculation_timestamp
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Data Source"
      expr: data_source
    - name: "Exposure End Timestamp"
      expr: exposure_end_timestamp
    - name: "Exposure Start Timestamp"
      expr: exposure_start_timestamp
    - name: "Fire Perimeter Flag"
      expr: fire_perimeter_flag
    - name: "Geocoding Accuracy"
      expr: geocoding_accuracy
    - name: "Impact Severity Band"
      expr: impact_severity_band
    - name: "Model Vendor"
      expr: model_vendor
    - name: "Model Version"
      expr: model_version
    - name: "Notes"
      expr: notes
    - name: "Peril Code"
      expr: peril_code
    - name: "Regulatory Reporting Flag"
      expr: regulatory_reporting_flag
    - name: "Shake Intensity"
      expr: shake_intensity
    - name: "Storm Surge Flag"
      expr: storm_surge_flag
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Cat Event Zone Xref"
      expr: COUNT(DISTINCT cat_event_zone_xref_id)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Exposed Policy Count"
      expr: SUM(exposed_policy_count)
    - name: "Average Exposed Policy Count"
      expr: AVG(exposed_policy_count)
    - name: "Total Exposed Tiv Amount"
      expr: SUM(exposed_tiv_amount)
    - name: "Average Exposed Tiv Amount"
      expr: AVG(exposed_tiv_amount)
    - name: "Total Fire Proximity Miles"
      expr: SUM(fire_proximity_miles)
    - name: "Average Fire Proximity Miles"
      expr: AVG(fire_proximity_miles)
    - name: "Total Flood Depth Ft"
      expr: SUM(flood_depth_ft)
    - name: "Average Flood Depth Ft"
      expr: AVG(flood_depth_ft)
    - name: "Total Fnol Priority Score"
      expr: SUM(fnol_priority_score)
    - name: "Average Fnol Priority Score"
      expr: AVG(fnol_priority_score)
    - name: "Total Hail Size Inches"
      expr: SUM(hail_size_inches)
    - name: "Average Hail Size Inches"
      expr: AVG(hail_size_inches)
    - name: "Total Modeled Damage Percent"
      expr: SUM(modeled_damage_percent)
    - name: "Average Modeled Damage Percent"
      expr: AVG(modeled_damage_percent)
    - name: "Total Modeled Loss Ratio"
      expr: SUM(modeled_loss_ratio)
    - name: "Average Modeled Loss Ratio"
      expr: AVG(modeled_loss_ratio)
    - name: "Total Peak Ground Acceleration"
      expr: SUM(peak_ground_acceleration)
    - name: "Average Peak Ground Acceleration"
      expr: AVG(peak_ground_acceleration)
    - name: "Total Rainfall Inches"
      expr: SUM(rainfall_inches)
    - name: "Average Rainfall Inches"
      expr: AVG(rainfall_inches)
    - name: "Total Storm Surge Height Ft"
      expr: SUM(storm_surge_height_ft)
    - name: "Average Storm Surge Height Ft"
      expr: AVG(storm_surge_height_ft)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_cat_model_version`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cat Model Version business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`"
  dimensions:
    - name: "Approved Jurisdictions"
      expr: approved_jurisdictions
    - name: "Benchmark Comparison Flag"
      expr: benchmark_comparison_flag
    - name: "Cat Model Version Status"
      expr: cat_model_version_status
    - name: "Climate Scenario"
      expr: climate_scenario
    - name: "Country Codes"
      expr: country_codes
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Documentation Url"
      expr: documentation_url
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Financial Module Version"
      expr: financial_module_version
    - name: "Geographic Coverage"
      expr: geographic_coverage
    - name: "Hazard Module Version"
      expr: hazard_module_version
    - name: "License Expiration Date"
      expr: license_expiration_date
    - name: "Lob Applicability"
      expr: lob_applicability
    - name: "Model Name"
      expr: model_name
    - name: "Model Type"
      expr: model_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Cat Model Version"
      expr: COUNT(DISTINCT cat_model_version_id)
    - name: "Total Event Set Size"
      expr: SUM(event_set_size)
    - name: "Average Event Set Size"
      expr: AVG(event_set_size)
    - name: "Total Simulation Years"
      expr: SUM(simulation_years)
    - name: "Average Simulation Years"
      expr: AVG(simulation_years)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_cat_zone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cat Zone business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`"
  dimensions:
    - name: "Country Code"
      expr: country_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Geographic Scope"
      expr: geographic_scope
    - name: "Iso Territory Code"
      expr: iso_territory_code
    - name: "Last Cat Event Date"
      expr: last_cat_event_date
    - name: "Last Cat Event Name"
      expr: last_cat_event_name
    - name: "Last Updated Timestamp"
      expr: last_updated_timestamp
    - name: "Model Update Date"
      expr: model_update_date
    - name: "Model Version"
      expr: model_version
    - name: "Modeling Vendor"
      expr: modeling_vendor
    - name: "Moratorium End Date"
      expr: moratorium_end_date
    - name: "Moratorium Flag"
      expr: moratorium_flag
    - name: "Moratorium Start Date"
      expr: moratorium_start_date
    - name: "Naic Territory Code"
      expr: naic_territory_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Cat Zone"
      expr: COUNT(DISTINCT cat_zone_id)
    - name: "Total Aal Amount"
      expr: SUM(aal_amount)
    - name: "Average Aal Amount"
      expr: AVG(aal_amount)
    - name: "Total Concentration Threshold Amount"
      expr: SUM(concentration_threshold_amount)
    - name: "Average Concentration Threshold Amount"
      expr: AVG(concentration_threshold_amount)
    - name: "Total Concentration Threshold Percentage"
      expr: SUM(concentration_threshold_percentage)
    - name: "Average Concentration Threshold Percentage"
      expr: AVG(concentration_threshold_percentage)
    - name: "Total Last Cat Event Loss Amount"
      expr: SUM(last_cat_event_loss_amount)
    - name: "Average Last Cat Event Loss Amount"
      expr: AVG(last_cat_event_loss_amount)
    - name: "Total Pml 100 Year Amount"
      expr: SUM(pml_100_year_amount)
    - name: "Average Pml 100 Year Amount"
      expr: AVG(pml_100_year_amount)
    - name: "Total Pml 250 Year Amount"
      expr: SUM(pml_250_year_amount)
    - name: "Average Pml 250 Year Amount"
      expr: AVG(pml_250_year_amount)
    - name: "Total Pml 500 Year Amount"
      expr: SUM(pml_500_year_amount)
    - name: "Average Pml 500 Year Amount"
      expr: AVG(pml_500_year_amount)
    - name: "Total Policy Count"
      expr: SUM(policy_count)
    - name: "Average Policy Count"
      expr: AVG(policy_count)
    - name: "Total Reinsurance Attachment Point"
      expr: SUM(reinsurance_attachment_point)
    - name: "Average Reinsurance Attachment Point"
      expr: AVG(reinsurance_attachment_point)
    - name: "Total Reinsurance Limit"
      expr: SUM(reinsurance_limit)
    - name: "Average Reinsurance Limit"
      expr: AVG(reinsurance_limit)
    - name: "Total Tiv Amount"
      expr: SUM(tiv_amount)
    - name: "Average Tiv Amount"
      expr: AVG(tiv_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_catastrophe_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Catastrophe Event business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`"
  dimensions:
    - name: "Affected Countries"
      expr: affected_countries
    - name: "Affected States"
      expr: affected_states
    - name: "Cat Bond Trigger Flag"
      expr: cat_bond_trigger_flag
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Data Source"
      expr: data_source
    - name: "Declaration Date"
      expr: declaration_date
    - name: "Event Description"
      expr: event_description
    - name: "Event End Date"
      expr: event_end_date
    - name: "Event Name"
      expr: event_name
    - name: "Event Start Date"
      expr: event_start_date
    - name: "Event Status"
      expr: event_status
    - name: "Event Type"
      expr: event_type
    - name: "Federal Disaster Declaration Flag"
      expr: federal_disaster_declaration_flag
    - name: "Fema Disaster Number"
      expr: fema_disaster_number
    - name: "Geographic Footprint Description"
      expr: geographic_footprint_description
    - name: "Industry Loss Estimate Currency"
      expr: industry_loss_estimate_currency
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Catastrophe Event"
      expr: COUNT(DISTINCT catastrophe_event_id)
    - name: "Total Aal Amount"
      expr: SUM(aal_amount)
    - name: "Average Aal Amount"
      expr: AVG(aal_amount)
    - name: "Total Acres Burned"
      expr: SUM(acres_burned)
    - name: "Average Acres Burned"
      expr: AVG(acres_burned)
    - name: "Total Actual Loss Amount"
      expr: SUM(actual_loss_amount)
    - name: "Average Actual Loss Amount"
      expr: AVG(actual_loss_amount)
    - name: "Total Epicenter Latitude"
      expr: SUM(epicenter_latitude)
    - name: "Average Epicenter Latitude"
      expr: AVG(epicenter_latitude)
    - name: "Total Epicenter Longitude"
      expr: SUM(epicenter_longitude)
    - name: "Average Epicenter Longitude"
      expr: AVG(epicenter_longitude)
    - name: "Total Estimated Claim Count"
      expr: SUM(estimated_claim_count)
    - name: "Average Estimated Claim Count"
      expr: AVG(estimated_claim_count)
    - name: "Total Event Duration Days"
      expr: SUM(event_duration_days)
    - name: "Average Event Duration Days"
      expr: AVG(event_duration_days)
    - name: "Total Industry Loss Estimate Amount"
      expr: SUM(industry_loss_estimate_amount)
    - name: "Average Industry Loss Estimate Amount"
      expr: AVG(industry_loss_estimate_amount)
    - name: "Total Loss Development Factor"
      expr: SUM(loss_development_factor)
    - name: "Average Loss Development Factor"
      expr: AVG(loss_development_factor)
    - name: "Total Magnitude Value"
      expr: SUM(magnitude_value)
    - name: "Average Magnitude Value"
      expr: AVG(magnitude_value)
    - name: "Total Modeled Loss Amount"
      expr: SUM(modeled_loss_amount)
    - name: "Average Modeled Loss Amount"
      expr: AVG(modeled_loss_amount)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_catastrophe_event_geography_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Catastrophe Event Geography Exposure business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure`"
  dimensions:
    - name: "As Of Date"
      expr: as_of_date
    - name: "As Of Date Month"
      expr: DATE_TRUNC('MONTH', as_of_date)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Catastrophe Event Geography Exposure"
      expr: COUNT(DISTINCT catastrophe_event_geography_exposure_id)
    - name: "Total Aal Amount"
      expr: SUM(aal_amount)
    - name: "Average Aal Amount"
      expr: AVG(aal_amount)
    - name: "Total Concentration Index"
      expr: SUM(concentration_index)
    - name: "Average Concentration Index"
      expr: AVG(concentration_index)
    - name: "Total Gwp Amount"
      expr: SUM(gwp_amount)
    - name: "Average Gwp Amount"
      expr: AVG(gwp_amount)
    - name: "Total Insured Risk Count"
      expr: SUM(insured_risk_count)
    - name: "Average Insured Risk Count"
      expr: AVG(insured_risk_count)
    - name: "Total Nwp Amount"
      expr: SUM(nwp_amount)
    - name: "Average Nwp Amount"
      expr: AVG(nwp_amount)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
    - name: "Total Policy Count"
      expr: SUM(policy_count)
    - name: "Average Policy Count"
      expr: AVG(policy_count)
    - name: "Total Tiv Amount"
      expr: SUM(tiv_amount)
    - name: "Average Tiv Amount"
      expr: AVG(tiv_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_catastrophegeography_peril`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Catastrophegeography Peril business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`"
  dimensions:
    - name: "Cat Model Peril Code"
      expr: cat_model_peril_code
    - name: "Catastrophegeography Peril Status"
      expr: catastrophegeography_peril_status
    - name: "Category"
      expr: catastrophegeography_peril_category
    - name: "Code"
      expr: catastrophegeography_peril_code
    - name: "Coverage Form Applicability"
      expr: coverage_form_applicability
    - name: "Description"
      expr: catastrophegeography_peril_description
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Required"
      expr: endorsement_required
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fraud Risk Level"
      expr: fraud_risk_level
    - name: "Frequency Classification"
      expr: frequency_classification
    - name: "Geographic Restriction"
      expr: geographic_restriction
    - name: "Is Cat Peril"
      expr: is_cat_peril
    - name: "Is Covered By Standard Policy"
      expr: is_covered_by_standard_policy
    - name: "Is Excluded By Default"
      expr: is_excluded_by_default
    - name: "Is Reportable To Naic"
      expr: is_reportable_to_naic
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Catastrophegeography Peril"
      expr: COUNT(DISTINCT catastrophegeography_peril_id)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_exposure_summary`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Exposure Summary business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary`"
  dimensions:
    - name: "As Of Date"
      expr: as_of_date
    - name: "Calculation Timestamp"
      expr: calculation_timestamp
    - name: "Construction Class"
      expr: construction_class
    - name: "Currency Code"
      expr: currency_code
    - name: "Exposure Basis"
      expr: exposure_basis
    - name: "Geocoding Accuracy"
      expr: geocoding_accuracy
    - name: "Model Version"
      expr: model_version
    - name: "Notes"
      expr: notes
    - name: "Occupancy Class"
      expr: occupancy_class
    - name: "Peril Code"
      expr: peril_code
    - name: "Protection Class"
      expr: protection_class
    - name: "Regulatory Reporting Flag"
      expr: regulatory_reporting_flag
    - name: "Zone Code"
      expr: zone_code
    - name: "As Of Date Month"
      expr: DATE_TRUNC('MONTH', as_of_date)
    - name: "Calculation Timestamp Month"
      expr: DATE_TRUNC('MONTH', calculation_timestamp)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Exposure Summary"
      expr: COUNT(DISTINCT exposure_summary_id)
    - name: "Total Aal Amount"
      expr: SUM(aal_amount)
    - name: "Average Aal Amount"
      expr: AVG(aal_amount)
    - name: "Total Concentration Index"
      expr: SUM(concentration_index)
    - name: "Average Concentration Index"
      expr: AVG(concentration_index)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Gwp Amount"
      expr: SUM(gwp_amount)
    - name: "Average Gwp Amount"
      expr: AVG(gwp_amount)
    - name: "Total Insured Risk Count"
      expr: SUM(insured_risk_count)
    - name: "Average Insured Risk Count"
      expr: AVG(insured_risk_count)
    - name: "Total Nwp Amount"
      expr: SUM(nwp_amount)
    - name: "Average Nwp Amount"
      expr: AVG(nwp_amount)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
    - name: "Total Pml Return Period Years"
      expr: SUM(pml_return_period_years)
    - name: "Average Pml Return Period Years"
      expr: AVG(pml_return_period_years)
    - name: "Total Policy Count"
      expr: SUM(policy_count)
    - name: "Average Policy Count"
      expr: AVG(policy_count)
    - name: "Total Retention Amount"
      expr: SUM(retention_amount)
    - name: "Average Retention Amount"
      expr: AVG(retention_amount)
    - name: "Total Tiv Amount"
      expr: SUM(tiv_amount)
    - name: "Average Tiv Amount"
      expr: AVG(tiv_amount)
    - name: "Total Treaty Share Percent"
      expr: SUM(treaty_share_percent)
    - name: "Average Treaty Share Percent"
      expr: AVG(treaty_share_percent)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_flood_zone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Flood Zone business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone`"
  dimensions:
    - name: "Catastrophe Zone Code"
      expr: catastrophe_zone_code
    - name: "Coastal Barrier Flag"
      expr: coastal_barrier_flag
    - name: "Community Name"
      expr: community_name
    - name: "Community Number"
      expr: community_number
    - name: "County Fips Code"
      expr: county_fips_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Digital Conversion Date"
      expr: digital_conversion_date
    - name: "Effective Date"
      expr: effective_date
    - name: "Elevation Datum"
      expr: elevation_datum
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Firm Panel Number"
      expr: firm_panel_number
    - name: "Flood Hazard Description"
      expr: flood_hazard_description
    - name: "Flood Source"
      expr: flood_source
    - name: "Flood Zone Status"
      expr: flood_zone_status
    - name: "Floodway Flag"
      expr: floodway_flag
    - name: "Geometry Wkt"
      expr: geometry_wkt
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Flood Zone"
      expr: COUNT(DISTINCT flood_zone_id)
    - name: "Total Area Square Miles"
      expr: SUM(area_square_miles)
    - name: "Average Area Square Miles"
      expr: AVG(area_square_miles)
    - name: "Total Base Flood Elevation Feet"
      expr: SUM(base_flood_elevation_feet)
    - name: "Average Base Flood Elevation Feet"
      expr: AVG(base_flood_elevation_feet)
    - name: "Total Base Rate Factor"
      expr: SUM(base_rate_factor)
    - name: "Average Base Rate Factor"
      expr: AVG(base_rate_factor)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Depth Feet"
      expr: SUM(depth_feet)
    - name: "Average Depth Feet"
      expr: AVG(depth_feet)
    - name: "Total Flood Frequency Percent"
      expr: SUM(flood_frequency_percent)
    - name: "Average Flood Frequency Percent"
      expr: AVG(flood_frequency_percent)
    - name: "Total Geocode Latitude"
      expr: SUM(geocode_latitude)
    - name: "Average Geocode Latitude"
      expr: AVG(geocode_latitude)
    - name: "Total Geocode Longitude"
      expr: SUM(geocode_longitude)
    - name: "Average Geocode Longitude"
      expr: AVG(geocode_longitude)
    - name: "Total Static Bfe Feet"
      expr: SUM(static_bfe_feet)
    - name: "Average Static Bfe Feet"
      expr: AVG(static_bfe_feet)
    - name: "Total Velocity Fps"
      expr: SUM(velocity_fps)
    - name: "Average Velocity Fps"
      expr: AVG(velocity_fps)
    - name: "Total Wave Height Feet"
      expr: SUM(wave_height_feet)
    - name: "Average Wave Height Feet"
      expr: AVG(wave_height_feet)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_geography`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_geography_hierarchy`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Geography Hierarchy business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy`"
  dimensions:
    - name: "Ancestor Geography Type"
      expr: ancestor_geography_type
    - name: "Cat Zone Indicator"
      expr: cat_zone_indicator
    - name: "Country Code"
      expr: country_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Descendant Geography Type"
      expr: descendant_geography_type
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Hierarchy Status"
      expr: hierarchy_status
    - name: "Hierarchy Version"
      expr: hierarchy_version
    - name: "Is Leaf Node"
      expr: is_leaf_node
    - name: "Is Root Node"
      expr: is_root_node
    - name: "Iso Territory Code"
      expr: iso_territory_code
    - name: "Lob Code"
      expr: lob_code
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Naic Company Code"
      expr: naic_company_code
    - name: "Notes"
      expr: notes
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Geography Hierarchy"
      expr: COUNT(DISTINCT geography_hierarchy_id)
    - name: "Total Aggregation Weight"
      expr: SUM(aggregation_weight)
    - name: "Average Aggregation Weight"
      expr: AVG(aggregation_weight)
    - name: "Total Depth Level"
      expr: SUM(depth_level)
    - name: "Average Depth Level"
      expr: AVG(depth_level)
    - name: "Total Path Length"
      expr: SUM(path_length)
    - name: "Average Path Length"
      expr: AVG(path_length)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_hazard_score`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Hazard Score business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score`"
  dimensions:
    - name: "Cat Model Vendor"
      expr: cat_model_vendor
    - name: "Construction Type"
      expr: construction_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Eligibility Reason"
      expr: eligibility_reason
    - name: "Flood Zone"
      expr: flood_zone
    - name: "Geocode Quality"
      expr: geocode_quality
    - name: "Hazard Band"
      expr: hazard_band
    - name: "Model Confidence Level"
      expr: model_confidence_level
    - name: "Model Run Date"
      expr: model_run_date
    - name: "Model Version"
      expr: model_version
    - name: "Occupancy Type"
      expr: occupancy_type
    - name: "Peril Code"
      expr: peril_code
    - name: "Protection Class"
      expr: protection_class
    - name: "Score Effective Date"
      expr: score_effective_date
    - name: "Score Expiration Date"
      expr: score_expiration_date
    - name: "Soil Type"
      expr: soil_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Hazard Score"
      expr: COUNT(DISTINCT hazard_score_id)
    - name: "Total Aal Amount"
      expr: SUM(aal_amount)
    - name: "Average Aal Amount"
      expr: AVG(aal_amount)
    - name: "Total Building Area Sqft"
      expr: SUM(building_area_sqft)
    - name: "Average Building Area Sqft"
      expr: AVG(building_area_sqft)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Distance To Coast Miles"
      expr: SUM(distance_to_coast_miles)
    - name: "Average Distance To Coast Miles"
      expr: AVG(distance_to_coast_miles)
    - name: "Total Elevation Feet"
      expr: SUM(elevation_feet)
    - name: "Average Elevation Feet"
      expr: AVG(elevation_feet)
    - name: "Total Exceedance Probability"
      expr: SUM(exceedance_probability)
    - name: "Average Exceedance Probability"
      expr: AVG(exceedance_probability)
    - name: "Total Hazard Score"
      expr: SUM(hazard_score)
    - name: "Average Hazard Score"
      expr: AVG(hazard_score)
    - name: "Total Latitude"
      expr: SUM(latitude)
    - name: "Average Latitude"
      expr: AVG(latitude)
    - name: "Total Longitude"
      expr: SUM(longitude)
    - name: "Average Longitude"
      expr: AVG(longitude)
    - name: "Total Number Of Stories"
      expr: SUM(number_of_stories)
    - name: "Average Number Of Stories"
      expr: AVG(number_of_stories)
    - name: "Total Pml 1000 Year"
      expr: SUM(pml_1000_year)
    - name: "Average Pml 1000 Year"
      expr: AVG(pml_1000_year)
    - name: "Total Pml 100 Year"
      expr: SUM(pml_100_year)
    - name: "Average Pml 100 Year"
      expr: AVG(pml_100_year)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_iso_cat_serial`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Iso Cat Serial business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial`"
  dimensions:
    - name: "Affected Counties"
      expr: affected_counties
    - name: "Affected Lob Codes"
      expr: affected_lob_codes
    - name: "Affected States"
      expr: affected_states
    - name: "Cat Bond Trigger"
      expr: cat_bond_trigger
    - name: "Cat Event Name"
      expr: cat_event_name
    - name: "Data Source"
      expr: data_source
    - name: "Event Category"
      expr: event_category
    - name: "Event End Date"
      expr: event_end_date
    - name: "Event Start Date"
      expr: event_start_date
    - name: "Fema Disaster Number"
      expr: fema_disaster_number
    - name: "Hurricane Category"
      expr: hurricane_category
    - name: "Iso Serial Effective Date"
      expr: iso_serial_effective_date
    - name: "Iso Serial Expiration Date"
      expr: iso_serial_expiration_date
    - name: "Last Updated Timestamp"
      expr: last_updated_timestamp
    - name: "Loss Estimate Date"
      expr: loss_estimate_date
    - name: "Loss Estimate Status"
      expr: loss_estimate_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Iso Cat Serial"
      expr: COUNT(DISTINCT iso_cat_serial_id)
    - name: "Total Earthquake Magnitude"
      expr: SUM(earthquake_magnitude)
    - name: "Average Earthquake Magnitude"
      expr: AVG(earthquake_magnitude)
    - name: "Total Event Duration Days"
      expr: SUM(event_duration_days)
    - name: "Average Event Duration Days"
      expr: AVG(event_duration_days)
    - name: "Total Industry Insured Loss Estimate"
      expr: SUM(industry_insured_loss_estimate)
    - name: "Average Industry Insured Loss Estimate"
      expr: AVG(industry_insured_loss_estimate)
    - name: "Total Pcs Threshold Amount"
      expr: SUM(pcs_threshold_amount)
    - name: "Average Pcs Threshold Amount"
      expr: AVG(pcs_threshold_amount)
    - name: "Total Total Precipitation Inches"
      expr: SUM(total_precipitation_inches)
    - name: "Average Total Precipitation Inches"
      expr: AVG(total_precipitation_inches)
    - name: "Total Wind Speed Mph"
      expr: SUM(wind_speed_mph)
    - name: "Average Wind Speed Mph"
      expr: AVG(wind_speed_mph)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_location_geocode`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Location Geocode business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode`"
  dimensions:
    - name: "Address Line 1"
      expr: address_line_1
    - name: "Address Line 2"
      expr: address_line_2
    - name: "Cat Model Vendor"
      expr: cat_model_vendor
    - name: "Cat Model Version"
      expr: cat_model_version
    - name: "City"
      expr: city
    - name: "Country Code"
      expr: country_code
    - name: "Cresta Zone Code"
      expr: cresta_zone_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fema Firm Panel Number"
      expr: fema_firm_panel_number
    - name: "Fema Flood Zone"
      expr: fema_flood_zone
    - name: "Fips County Code"
      expr: fips_county_code
    - name: "Fips State Code"
      expr: fips_state_code
    - name: "Fire Protection Class"
      expr: fire_protection_class
    - name: "Geocode Match Level"
      expr: geocode_match_level
    - name: "Geocode Source"
      expr: geocode_source
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Location Geocode"
      expr: COUNT(DISTINCT location_geocode_id)
    - name: "Total Base Flood Elevation Ft"
      expr: SUM(base_flood_elevation_ft)
    - name: "Average Base Flood Elevation Ft"
      expr: AVG(base_flood_elevation_ft)
    - name: "Total Earthquake Aal Amount"
      expr: SUM(earthquake_aal_amount)
    - name: "Average Earthquake Aal Amount"
      expr: AVG(earthquake_aal_amount)
    - name: "Total Earthquake Pml Amount"
      expr: SUM(earthquake_pml_amount)
    - name: "Average Earthquake Pml Amount"
      expr: AVG(earthquake_pml_amount)
    - name: "Total Flood Aal Amount"
      expr: SUM(flood_aal_amount)
    - name: "Average Flood Aal Amount"
      expr: AVG(flood_aal_amount)
    - name: "Total Flood Pml Amount"
      expr: SUM(flood_pml_amount)
    - name: "Average Flood Pml Amount"
      expr: AVG(flood_pml_amount)
    - name: "Total Geocode Quality Score"
      expr: SUM(geocode_quality_score)
    - name: "Average Geocode Quality Score"
      expr: AVG(geocode_quality_score)
    - name: "Total Hail Aal Amount"
      expr: SUM(hail_aal_amount)
    - name: "Average Hail Aal Amount"
      expr: AVG(hail_aal_amount)
    - name: "Total Hail Pml Amount"
      expr: SUM(hail_pml_amount)
    - name: "Average Hail Pml Amount"
      expr: AVG(hail_pml_amount)
    - name: "Total Hurricane Aal Amount"
      expr: SUM(hurricane_aal_amount)
    - name: "Average Hurricane Aal Amount"
      expr: AVG(hurricane_aal_amount)
    - name: "Total Hurricane Pml Amount"
      expr: SUM(hurricane_pml_amount)
    - name: "Average Hurricane Pml Amount"
      expr: AVG(hurricane_pml_amount)
    - name: "Total Latitude"
      expr: SUM(latitude)
    - name: "Average Latitude"
      expr: AVG(latitude)
    - name: "Total Longitude"
      expr: SUM(longitude)
    - name: "Average Longitude"
      expr: AVG(longitude)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_pml_return_period`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pml Return Period business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period`"
  dimensions:
    - name: "As Of Date"
      expr: as_of_date
    - name: "Calculation Timestamp"
      expr: calculation_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Geocoding Accuracy"
      expr: geocoding_accuracy
    - name: "Model Vendor"
      expr: model_vendor
    - name: "Model Version"
      expr: model_version
    - name: "Notes"
      expr: notes
    - name: "Orsa Scenario Flag"
      expr: orsa_scenario_flag
    - name: "Peril Code"
      expr: peril_code
    - name: "Pml Return Period Status"
      expr: pml_return_period_status
    - name: "Regulatory Reporting Flag"
      expr: regulatory_reporting_flag
    - name: "Zone Code"
      expr: zone_code
    - name: "As Of Date Month"
      expr: DATE_TRUNC('MONTH', as_of_date)
    - name: "Calculation Timestamp Month"
      expr: DATE_TRUNC('MONTH', calculation_timestamp)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Pml Return Period"
      expr: COUNT(DISTINCT pml_return_period_id)
    - name: "Total Aal Amount"
      expr: SUM(aal_amount)
    - name: "Average Aal Amount"
      expr: AVG(aal_amount)
    - name: "Total Ceded Loss Amount"
      expr: SUM(ceded_loss_amount)
    - name: "Average Ceded Loss Amount"
      expr: AVG(ceded_loss_amount)
    - name: "Total Coefficient Of Variation"
      expr: SUM(coefficient_of_variation)
    - name: "Average Coefficient Of Variation"
      expr: AVG(coefficient_of_variation)
    - name: "Total Confidence Level Percent"
      expr: SUM(confidence_level_percent)
    - name: "Average Confidence Level Percent"
      expr: AVG(confidence_level_percent)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Exceedance Probability"
      expr: SUM(exceedance_probability)
    - name: "Average Exceedance Probability"
      expr: AVG(exceedance_probability)
    - name: "Total Gross Loss Amount"
      expr: SUM(gross_loss_amount)
    - name: "Average Gross Loss Amount"
      expr: AVG(gross_loss_amount)
    - name: "Total Insured Risk Count"
      expr: SUM(insured_risk_count)
    - name: "Average Insured Risk Count"
      expr: AVG(insured_risk_count)
    - name: "Total Loss Ratio"
      expr: SUM(loss_ratio)
    - name: "Average Loss Ratio"
      expr: AVG(loss_ratio)
    - name: "Total Net Retained Loss Amount"
      expr: SUM(net_retained_loss_amount)
    - name: "Average Net Retained Loss Amount"
      expr: AVG(net_retained_loss_amount)
    - name: "Total Percentile Rank"
      expr: SUM(percentile_rank)
    - name: "Average Percentile Rank"
      expr: AVG(percentile_rank)
    - name: "Total Policy Count"
      expr: SUM(policy_count)
    - name: "Average Policy Count"
      expr: AVG(policy_count)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_pml_run`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pml Run business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run`"
  dimensions:
    - name: "Approval Date"
      expr: approval_date
    - name: "Completion Timestamp"
      expr: completion_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Demand Surge Applied"
      expr: demand_surge_applied
    - name: "Event Set Version"
      expr: event_set_version
    - name: "Exposure As Of Date"
      expr: exposure_as_of_date
    - name: "Geography Scope"
      expr: geography_scope
    - name: "Loss Amplification Applied"
      expr: loss_amplification_applied
    - name: "Model Name"
      expr: model_name
    - name: "Model Vendor"
      expr: model_vendor
    - name: "Model Version"
      expr: model_version
    - name: "Notes"
      expr: notes
    - name: "Peril Code"
      expr: peril_code
    - name: "Rating Agency Submission Flag"
      expr: rating_agency_submission_flag
    - name: "Regulatory Filing Flag"
      expr: regulatory_filing_flag
    - name: "Run Date"
      expr: run_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Pml Run"
      expr: COUNT(DISTINCT pml_run_id)
    - name: "Total Aal Gross"
      expr: SUM(aal_gross)
    - name: "Average Aal Gross"
      expr: AVG(aal_gross)
    - name: "Total Aal Net"
      expr: SUM(aal_net)
    - name: "Average Aal Net"
      expr: AVG(aal_net)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Geocoding Accuracy Percent"
      expr: SUM(geocoding_accuracy_percent)
    - name: "Average Geocoding Accuracy Percent"
      expr: AVG(geocoding_accuracy_percent)
    - name: "Total Location Count"
      expr: SUM(location_count)
    - name: "Average Location Count"
      expr: AVG(location_count)
    - name: "Total Policy Count"
      expr: SUM(policy_count)
    - name: "Average Policy Count"
      expr: AVG(policy_count)
    - name: "Total Return Period 1000 Gross Pml"
      expr: SUM(return_period_1000_gross_pml)
    - name: "Average Return Period 1000 Gross Pml"
      expr: AVG(return_period_1000_gross_pml)
    - name: "Total Return Period 1000 Net Pml"
      expr: SUM(return_period_1000_net_pml)
    - name: "Average Return Period 1000 Net Pml"
      expr: AVG(return_period_1000_net_pml)
    - name: "Total Return Period 100 Gross Pml"
      expr: SUM(return_period_100_gross_pml)
    - name: "Average Return Period 100 Gross Pml"
      expr: AVG(return_period_100_gross_pml)
    - name: "Total Return Period 100 Net Pml"
      expr: SUM(return_period_100_net_pml)
    - name: "Average Return Period 100 Net Pml"
      expr: AVG(return_period_100_net_pml)
    - name: "Total Return Period 250 Gross Pml"
      expr: SUM(return_period_250_gross_pml)
    - name: "Average Return Period 250 Gross Pml"
      expr: AVG(return_period_250_gross_pml)
    - name: "Total Return Period 250 Net Pml"
      expr: SUM(return_period_250_net_pml)
    - name: "Average Return Period 250 Net Pml"
      expr: AVG(return_period_250_net_pml)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_policy_cat_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy Cat Exposure business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure`"
  dimensions:
    - name: "As Of Date"
      expr: as_of_date
    - name: "Bordereaux Reporting Flag"
      expr: bordereaux_reporting_flag
    - name: "Cat Model Vendor"
      expr: cat_model_vendor
    - name: "Cat Model Version"
      expr: cat_model_version
    - name: "Construction Class"
      expr: construction_class
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Deductible Type"
      expr: deductible_type
    - name: "Exposure Effective Date"
      expr: exposure_effective_date
    - name: "Exposure Expiration Date"
      expr: exposure_expiration_date
    - name: "Exposure Status"
      expr: exposure_status
    - name: "Fnol Triage Priority"
      expr: fnol_triage_priority
    - name: "Geocode Quality"
      expr: geocode_quality
    - name: "Model Run Date"
      expr: model_run_date
    - name: "Notes"
      expr: notes
    - name: "Occupancy Class"
      expr: occupancy_class
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Policy Cat Exposure"
      expr: COUNT(DISTINCT policy_cat_exposure_id)
    - name: "Total Aal Amount"
      expr: SUM(aal_amount)
    - name: "Average Aal Amount"
      expr: AVG(aal_amount)
    - name: "Total Building Area Sqft"
      expr: SUM(building_area_sqft)
    - name: "Average Building Area Sqft"
      expr: AVG(building_area_sqft)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Estimated Gross Loss Amount"
      expr: SUM(estimated_gross_loss_amount)
    - name: "Average Estimated Gross Loss Amount"
      expr: AVG(estimated_gross_loss_amount)
    - name: "Total Estimated Net Loss Amount"
      expr: SUM(estimated_net_loss_amount)
    - name: "Average Estimated Net Loss Amount"
      expr: AVG(estimated_net_loss_amount)
    - name: "Total Latitude"
      expr: SUM(latitude)
    - name: "Average Latitude"
      expr: AVG(latitude)
    - name: "Total Limit Amount"
      expr: SUM(limit_amount)
    - name: "Average Limit Amount"
      expr: AVG(limit_amount)
    - name: "Total Longitude"
      expr: SUM(longitude)
    - name: "Average Longitude"
      expr: AVG(longitude)
    - name: "Total Number Of Stories"
      expr: SUM(number_of_stories)
    - name: "Average Number Of Stories"
      expr: AVG(number_of_stories)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
    - name: "Total Pml Return Period Years"
      expr: SUM(pml_return_period_years)
    - name: "Average Pml Return Period Years"
      expr: AVG(pml_return_period_years)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_territory`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;