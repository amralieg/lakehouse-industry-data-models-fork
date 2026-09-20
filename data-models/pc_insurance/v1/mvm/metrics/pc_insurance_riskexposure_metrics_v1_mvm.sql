-- Metric views for domain: riskexposure | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_auto_risk`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Auto Risk business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk`"
  dimensions:
    - name: "Anti Theft Device Code"
      expr: anti_theft_device_code
    - name: "Business Use Class"
      expr: business_use_class
    - name: "Clue Report Date"
      expr: clue_report_date
    - name: "Clue Report Indicator"
      expr: clue_report_indicator
    - name: "Created By User"
      expr: created_by_user
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Garaging State"
      expr: garaging_state
    - name: "Garaging Zip Code"
      expr: garaging_zip_code
    - name: "Modified By User"
      expr: modified_by_user
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Primary Use"
      expr: primary_use
    - name: "Prior Carrier Name"
      expr: prior_carrier_name
    - name: "Prior Expiration Date"
      expr: prior_expiration_date
    - name: "Prior Policy Number"
      expr: prior_policy_number
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Auto Risk"
      expr: COUNT(DISTINCT auto_risk_id)
    - name: "Total Actual Cash Value Amount"
      expr: SUM(actual_cash_value_amount)
    - name: "Average Actual Cash Value Amount"
      expr: AVG(actual_cash_value_amount)
    - name: "Total Annual Mileage"
      expr: SUM(annual_mileage)
    - name: "Average Annual Mileage"
      expr: AVG(annual_mileage)
    - name: "Total Loss Free Years"
      expr: SUM(loss_free_years)
    - name: "Average Loss Free Years"
      expr: AVG(loss_free_years)
    - name: "Total Primary Driver Code"
      expr: SUM(primary_driver_code)
    - name: "Average Primary Driver Code"
      expr: AVG(primary_driver_code)
    - name: "Total Risk Score"
      expr: SUM(risk_score)
    - name: "Average Risk Score"
      expr: AVG(risk_score)
    - name: "Total Stated Value Amount"
      expr: SUM(stated_value_amount)
    - name: "Average Stated Value Amount"
      expr: AVG(stated_value_amount)
    - name: "Total Tiv"
      expr: SUM(tiv)
    - name: "Average Tiv"
      expr: AVG(tiv)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_building`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Building business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`building`"
  dimensions:
    - name: "Basement Finish Type"
      expr: basement_finish_type
    - name: "Basement Indicator"
      expr: basement_indicator
    - name: "Building Status"
      expr: building_status
    - name: "Burglar Alarm Indicator"
      expr: burglar_alarm_indicator
    - name: "Central Station Monitoring Indicator"
      expr: central_station_monitoring_indicator
    - name: "Construction Type"
      expr: construction_type
    - name: "Cooling Type"
      expr: cooling_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Earthquake Retrofit Indicator"
      expr: earthquake_retrofit_indicator
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exterior Wall Material"
      expr: exterior_wall_material
    - name: "Fire Alarm Indicator"
      expr: fire_alarm_indicator
    - name: "Fire Protection Class"
      expr: fire_protection_class
    - name: "Flood Vents Indicator"
      expr: flood_vents_indicator
    - name: "Foundation Type"
      expr: foundation_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Building"
      expr: COUNT(DISTINCT building_id)
    - name: "Total Actual Cash Value"
      expr: SUM(actual_cash_value)
    - name: "Average Actual Cash Value"
      expr: AVG(actual_cash_value)
    - name: "Total Agreed Value Amount"
      expr: SUM(agreed_value_amount)
    - name: "Average Agreed Value Amount"
      expr: AVG(agreed_value_amount)
    - name: "Total Coinsurance Percentage"
      expr: SUM(coinsurance_percentage)
    - name: "Average Coinsurance Percentage"
      expr: AVG(coinsurance_percentage)
    - name: "Total Distance To Fire Hydrant Feet"
      expr: SUM(distance_to_fire_hydrant_feet)
    - name: "Average Distance To Fire Hydrant Feet"
      expr: AVG(distance_to_fire_hydrant_feet)
    - name: "Total Distance To Fire Station Miles"
      expr: SUM(distance_to_fire_station_miles)
    - name: "Average Distance To Fire Station Miles"
      expr: AVG(distance_to_fire_station_miles)
    - name: "Total Electrical System Year"
      expr: SUM(electrical_system_year)
    - name: "Average Electrical System Year"
      expr: AVG(electrical_system_year)
    - name: "Total Hvac System Year"
      expr: SUM(hvac_system_year)
    - name: "Average Hvac System Year"
      expr: AVG(hvac_system_year)
    - name: "Total Number Of Stories"
      expr: SUM(number_of_stories)
    - name: "Average Number Of Stories"
      expr: AVG(number_of_stories)
    - name: "Total Number Of Units"
      expr: SUM(number_of_units)
    - name: "Average Number Of Units"
      expr: AVG(number_of_units)
    - name: "Total Plumbing System Year"
      expr: SUM(plumbing_system_year)
    - name: "Average Plumbing System Year"
      expr: AVG(plumbing_system_year)
    - name: "Total Replacement Cost Value"
      expr: SUM(replacement_cost_value)
    - name: "Average Replacement Cost Value"
      expr: AVG(replacement_cost_value)
    - name: "Total Roof Year"
      expr: SUM(roof_year)
    - name: "Average Roof Year"
      expr: AVG(roof_year)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_driver`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Driver business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`"
  dimensions:
    - name: "Clue Report Order Date"
      expr: clue_report_order_date
    - name: "Clue Report Receipt Date"
      expr: clue_report_receipt_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Date Of Birth"
      expr: date_of_birth
    - name: "Defensive Driving Course Date"
      expr: defensive_driving_course_date
    - name: "Defensive Driving Course Indicator"
      expr: defensive_driving_course_indicator
    - name: "Driver Type"
      expr: driver_type
    - name: "Effective Date"
      expr: effective_date
    - name: "Excluded Driver Indicator"
      expr: excluded_driver_indicator
    - name: "Excluded Driver Reason"
      expr: excluded_driver_reason
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Gender"
      expr: gender
    - name: "Good Student Indicator"
      expr: good_student_indicator
    - name: "License Expiration Date"
      expr: license_expiration_date
    - name: "License Issue Date"
      expr: license_issue_date
    - name: "License Number"
      expr: license_number
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Driver"
      expr: COUNT(DISTINCT driver_id)
    - name: "Total Age"
      expr: SUM(age)
    - name: "Average Age"
      expr: AVG(age)
    - name: "Total Mvr Accident Count"
      expr: SUM(mvr_accident_count)
    - name: "Average Mvr Accident Count"
      expr: AVG(mvr_accident_count)
    - name: "Total Mvr Violation Count"
      expr: SUM(mvr_violation_count)
    - name: "Average Mvr Violation Count"
      expr: AVG(mvr_violation_count)
    - name: "Total Score"
      expr: SUM(score)
    - name: "Average Score"
      expr: AVG(score)
    - name: "Total Years Licensed"
      expr: SUM(years_licensed)
    - name: "Average Years Licensed"
      expr: AVG(years_licensed)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_insured_risk`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Insured Risk business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`"
  dimensions:
    - name: "Construction Code"
      expr: construction_code
    - name: "Created By User Code"
      expr: created_by_user_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deductible Type"
      expr: deductible_type
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exposure Basis"
      expr: exposure_basis
    - name: "Flood Zone Code"
      expr: flood_zone_code
    - name: "Inspection Date"
      expr: inspection_date
    - name: "Inspection Required Flag"
      expr: inspection_required_flag
    - name: "Inspection Status"
      expr: inspection_status
    - name: "Modified By User Code"
      expr: modified_by_user_code
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Occupancy Code"
      expr: occupancy_code
    - name: "Protection Class"
      expr: protection_class
    - name: "Risk Description"
      expr: risk_description
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Insured Risk"
      expr: COUNT(DISTINCT insured_risk_id)
    - name: "Total Coinsurance Percentage"
      expr: SUM(coinsurance_percentage)
    - name: "Average Coinsurance Percentage"
      expr: AVG(coinsurance_percentage)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Exposure Units"
      expr: SUM(exposure_units)
    - name: "Average Exposure Units"
      expr: AVG(exposure_units)
    - name: "Total Geocode Quality Score"
      expr: SUM(geocode_quality_score)
    - name: "Average Geocode Quality Score"
      expr: AVG(geocode_quality_score)
    - name: "Total Hazard Score"
      expr: SUM(hazard_score)
    - name: "Average Hazard Score"
      expr: AVG(hazard_score)
    - name: "Total Itv Percentage"
      expr: SUM(itv_percentage)
    - name: "Average Itv Percentage"
      expr: AVG(itv_percentage)
    - name: "Total Latitude"
      expr: SUM(latitude)
    - name: "Average Latitude"
      expr: AVG(latitude)
    - name: "Total Longitude"
      expr: SUM(longitude)
    - name: "Average Longitude"
      expr: AVG(longitude)
    - name: "Total Prior Loss Amount"
      expr: SUM(prior_loss_amount)
    - name: "Average Prior Loss Amount"
      expr: AVG(prior_loss_amount)
    - name: "Total Prior Loss Count"
      expr: SUM(prior_loss_count)
    - name: "Average Prior Loss Count"
      expr: AVG(prior_loss_count)
    - name: "Total Risk Score"
      expr: SUM(risk_score)
    - name: "Average Risk Score"
      expr: AVG(risk_score)
    - name: "Total Sum Insured Amount"
      expr: SUM(sum_insured_amount)
    - name: "Average Sum Insured Amount"
      expr: AVG(sum_insured_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_location`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`location`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_property_risk`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Property Risk business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`"
  dimensions:
    - name: "Basement Finish Type"
      expr: basement_finish_type
    - name: "Basement Indicator"
      expr: basement_indicator
    - name: "Burglar Alarm Indicator"
      expr: burglar_alarm_indicator
    - name: "Central Station Monitoring Indicator"
      expr: central_station_monitoring_indicator
    - name: "Construction Type"
      expr: construction_type
    - name: "Cooling Type"
      expr: cooling_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Electrical System Type"
      expr: electrical_system_type
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exposure Description"
      expr: exposure_description
    - name: "Fire Alarm Indicator"
      expr: fire_alarm_indicator
    - name: "Foundation Type"
      expr: foundation_type
    - name: "Heating Type"
      expr: heating_type
    - name: "Iso Construction Code"
      expr: iso_construction_code
    - name: "Number"
      expr: number
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Property Risk"
      expr: COUNT(DISTINCT property_risk_id)
    - name: "Total Actual Cash Value"
      expr: SUM(actual_cash_value)
    - name: "Average Actual Cash Value"
      expr: AVG(actual_cash_value)
    - name: "Total Coinsurance Percentage"
      expr: SUM(coinsurance_percentage)
    - name: "Average Coinsurance Percentage"
      expr: AVG(coinsurance_percentage)
    - name: "Total Distance To Fire Hydrant Feet"
      expr: SUM(distance_to_fire_hydrant_feet)
    - name: "Average Distance To Fire Hydrant Feet"
      expr: AVG(distance_to_fire_hydrant_feet)
    - name: "Total Distance To Fire Station Miles"
      expr: SUM(distance_to_fire_station_miles)
    - name: "Average Distance To Fire Station Miles"
      expr: AVG(distance_to_fire_station_miles)
    - name: "Total Insurance To Value Percentage"
      expr: SUM(insurance_to_value_percentage)
    - name: "Average Insurance To Value Percentage"
      expr: AVG(insurance_to_value_percentage)
    - name: "Total Number Of Stories"
      expr: SUM(number_of_stories)
    - name: "Average Number Of Stories"
      expr: AVG(number_of_stories)
    - name: "Total Number Of Units"
      expr: SUM(number_of_units)
    - name: "Average Number Of Units"
      expr: AVG(number_of_units)
    - name: "Total Replacement Cost Value"
      expr: SUM(replacement_cost_value)
    - name: "Average Replacement Cost Value"
      expr: AVG(replacement_cost_value)
    - name: "Total Roof Year"
      expr: SUM(roof_year)
    - name: "Average Roof Year"
      expr: AVG(roof_year)
    - name: "Total Square Footage"
      expr: SUM(square_footage)
    - name: "Average Square Footage"
      expr: AVG(square_footage)
    - name: "Total Total Insured Value"
      expr: SUM(total_insured_value)
    - name: "Average Total Insured Value"
      expr: AVG(total_insured_value)
    - name: "Total Year Built"
      expr: SUM(year_built)
    - name: "Average Year Built"
      expr: AVG(year_built)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_risk_inspection`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Risk Inspection business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection`"
  dimensions:
    - name: "Completed Date"
      expr: completed_date
    - name: "Construction Type"
      expr: construction_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Electrical Condition"
      expr: electrical_condition
    - name: "Exposure Description"
      expr: exposure_description
    - name: "Fire Protection Present"
      expr: fire_protection_present
    - name: "Fire Protection Type"
      expr: fire_protection_type
    - name: "Hazards Identified"
      expr: hazards_identified
    - name: "Hvac Condition"
      expr: hvac_condition
    - name: "Inspection Method"
      expr: inspection_method
    - name: "Inspection Number"
      expr: inspection_number
    - name: "Inspection Purpose"
      expr: inspection_purpose
    - name: "Inspection Report Url"
      expr: inspection_report_url
    - name: "Inspection Status"
      expr: inspection_status
    - name: "Inspection Type"
      expr: inspection_type
    - name: "Inspection Vendor"
      expr: inspection_vendor
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Risk Inspection"
      expr: COUNT(DISTINCT risk_inspection_id)
    - name: "Total Photos Count"
      expr: SUM(photos_count)
    - name: "Average Photos Count"
      expr: AVG(photos_count)
    - name: "Total Roof Age Years"
      expr: SUM(roof_age_years)
    - name: "Average Roof Age Years"
      expr: AVG(roof_age_years)
    - name: "Total Valuation Estimate"
      expr: SUM(valuation_estimate)
    - name: "Average Valuation Estimate"
      expr: AVG(valuation_estimate)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_risk_score`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Risk Score business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score`"
  dimensions:
    - name: "Acceptable Flag"
      expr: acceptable_flag
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Model Name"
      expr: model_name
    - name: "Model Vendor"
      expr: model_vendor
    - name: "Model Version"
      expr: model_version
    - name: "Override Flag"
      expr: override_flag
    - name: "Override Reason"
      expr: override_reason
    - name: "Override Timestamp"
      expr: override_timestamp
    - name: "Referral Flag"
      expr: referral_flag
    - name: "Referral Reason"
      expr: referral_reason
    - name: "Score Date"
      expr: score_date
    - name: "Score Grade"
      expr: score_grade
    - name: "Score Notes"
      expr: score_notes
    - name: "Score Status"
      expr: score_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Risk Score"
      expr: COUNT(DISTINCT risk_score_id)
    - name: "Total Cat Exposure Score"
      expr: SUM(cat_exposure_score)
    - name: "Average Cat Exposure Score"
      expr: AVG(cat_exposure_score)
    - name: "Total Construction Score"
      expr: SUM(construction_score)
    - name: "Average Construction Score"
      expr: AVG(construction_score)
    - name: "Total Credit Score"
      expr: SUM(credit_score)
    - name: "Average Credit Score"
      expr: AVG(credit_score)
    - name: "Total Data Quality Score"
      expr: SUM(data_quality_score)
    - name: "Average Data Quality Score"
      expr: AVG(data_quality_score)
    - name: "Total Driver Score"
      expr: SUM(driver_score)
    - name: "Average Driver Score"
      expr: AVG(driver_score)
    - name: "Total Hazard Score"
      expr: SUM(hazard_score)
    - name: "Average Hazard Score"
      expr: AVG(hazard_score)
    - name: "Total Loss History Score"
      expr: SUM(loss_history_score)
    - name: "Average Loss History Score"
      expr: AVG(loss_history_score)
    - name: "Total Moral Hazard Score"
      expr: SUM(moral_hazard_score)
    - name: "Average Moral Hazard Score"
      expr: AVG(moral_hazard_score)
    - name: "Total Occupancy Score"
      expr: SUM(occupancy_score)
    - name: "Average Occupancy Score"
      expr: AVG(occupancy_score)
    - name: "Total Protection Class Score"
      expr: SUM(protection_class_score)
    - name: "Average Protection Class Score"
      expr: AVG(protection_class_score)
    - name: "Total Score Confidence Level"
      expr: SUM(score_confidence_level)
    - name: "Average Score Confidence Level"
      expr: AVG(score_confidence_level)
    - name: "Total Score Value"
      expr: SUM(score_value)
    - name: "Average Score Value"
      expr: AVG(score_value)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`riskexposure_vehicle`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Vehicle business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`"
  dimensions:
    - name: "Abs Indicator"
      expr: abs_indicator
    - name: "Anti Theft Device Indicator"
      expr: anti_theft_device_indicator
    - name: "Anti Theft Device Type"
      expr: anti_theft_device_type
    - name: "Body Type"
      expr: body_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fuel Type"
      expr: fuel_type
    - name: "Garaging Zip Code"
      expr: garaging_zip_code
    - name: "Iso Symbol"
      expr: iso_symbol
    - name: "License Plate Number"
      expr: license_plate_number
    - name: "License Plate State"
      expr: license_plate_state
    - name: "Lienholder Name"
      expr: lienholder_name
    - name: "Make"
      expr: make
    - name: "Model"
      expr: model
    - name: "Modified Timestamp"
      expr: modified_timestamp
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Vehicle"
      expr: COUNT(DISTINCT vehicle_id)
    - name: "Total Actual Cash Value"
      expr: SUM(actual_cash_value)
    - name: "Average Actual Cash Value"
      expr: AVG(actual_cash_value)
    - name: "Total Airbag Count"
      expr: SUM(airbag_count)
    - name: "Average Airbag Count"
      expr: AVG(airbag_count)
    - name: "Total Annual Mileage"
      expr: SUM(annual_mileage)
    - name: "Average Annual Mileage"
      expr: AVG(annual_mileage)
    - name: "Total Commute Miles"
      expr: SUM(commute_miles)
    - name: "Average Commute Miles"
      expr: AVG(commute_miles)
    - name: "Total Engine Size"
      expr: SUM(engine_size)
    - name: "Average Engine Size"
      expr: AVG(engine_size)
    - name: "Total Gross Vehicle Weight"
      expr: SUM(gross_vehicle_weight)
    - name: "Average Gross Vehicle Weight"
      expr: AVG(gross_vehicle_weight)
    - name: "Total Odometer Reading"
      expr: SUM(odometer_reading)
    - name: "Average Odometer Reading"
      expr: AVG(odometer_reading)
    - name: "Total Purchase Price"
      expr: SUM(purchase_price)
    - name: "Average Purchase Price"
      expr: AVG(purchase_price)
    - name: "Total Seating Capacity"
      expr: SUM(seating_capacity)
    - name: "Average Seating Capacity"
      expr: AVG(seating_capacity)
    - name: "Total Stated Value"
      expr: SUM(stated_value)
    - name: "Average Stated Value"
      expr: AVG(stated_value)
    - name: "Total Year"
      expr: SUM(year)
    - name: "Average Year"
      expr: AVG(year)
$$;