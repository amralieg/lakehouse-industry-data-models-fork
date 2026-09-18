-- Metric views for domain: riskexposure | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_cat_zone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cat Zone business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`cat_zone`"
  dimensions:
    - name: "Cat Model Vendor"
      expr: cat_model_vendor
    - name: "Cat Model Version"
      expr: cat_model_version
    - name: "County Fips Code"
      expr: county_fips_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fema Flood Zone Code"
      expr: fema_flood_zone_code
    - name: "Firm Effective Date"
      expr: firm_effective_date
    - name: "Firm Panel Number"
      expr: firm_panel_number
    - name: "Geography Type"
      expr: geography_type
    - name: "Iso Crpc Code"
      expr: iso_crpc_code
    - name: "Last Updated Date"
      expr: last_updated_date
    - name: "Mandatory Flood Purchase Indicator"
      expr: mandatory_flood_purchase_indicator
    - name: "Nfip Community Code"
      expr: nfip_community_code
    - name: "Nfip Participation Status"
      expr: nfip_participation_status
    - name: "Peril Type"
      expr: peril_type
    - name: "Pml Tier"
      expr: pml_tier
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Cat Zone"
      expr: COUNT(DISTINCT cat_zone_id)
    - name: "Total Base Flood Elevation Ft"
      expr: SUM(base_flood_elevation_ft)
    - name: "Average Base Flood Elevation Ft"
      expr: AVG(base_flood_elevation_ft)
    - name: "Total Cat Loading Factor"
      expr: SUM(cat_loading_factor)
    - name: "Average Cat Loading Factor"
      expr: AVG(cat_loading_factor)
    - name: "Total Distance To Coast Miles"
      expr: SUM(distance_to_coast_miles)
    - name: "Average Distance To Coast Miles"
      expr: AVG(distance_to_coast_miles)
    - name: "Total Earthquake Magnitude Scale"
      expr: SUM(earthquake_magnitude_scale)
    - name: "Average Earthquake Magnitude Scale"
      expr: AVG(earthquake_magnitude_scale)
    - name: "Total Hurricane Wind Speed Mph"
      expr: SUM(hurricane_wind_speed_mph)
    - name: "Average Hurricane Wind Speed Mph"
      expr: AVG(hurricane_wind_speed_mph)
    - name: "Total Latitude"
      expr: SUM(latitude)
    - name: "Average Latitude"
      expr: AVG(latitude)
    - name: "Total Longitude"
      expr: SUM(longitude)
    - name: "Average Longitude"
      expr: AVG(longitude)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
    - name: "Total Return Period Years"
      expr: SUM(return_period_years)
    - name: "Average Return Period Years"
      expr: AVG(return_period_years)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_clue_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Clue Report business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`clue_report`"
  dimensions:
    - name: "Adverse Action Required"
      expr: adverse_action_required
    - name: "Adverse Action Sent Date"
      expr: adverse_action_sent_date
    - name: "Catastrophe Loss Indicator"
      expr: catastrophe_loss_indicator
    - name: "Clue Score Tier"
      expr: clue_score_tier
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fraud Indicator"
      expr: fraud_indicator
    - name: "Order Date"
      expr: order_date
    - name: "Prior Carrier Naic Code"
      expr: prior_carrier_naic_code
    - name: "Prior Carrier Name"
      expr: prior_carrier_name
    - name: "Prior Policy Effective Date"
      expr: prior_policy_effective_date
    - name: "Prior Policy Expiration Date"
      expr: prior_policy_expiration_date
    - name: "Prior Policy Number"
      expr: prior_policy_number
    - name: "Provider Name"
      expr: provider_name
    - name: "Provider Transaction Code"
      expr: provider_transaction_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Clue Report"
      expr: COUNT(DISTINCT clue_report_id)
    - name: "Total Auto Loss Count"
      expr: SUM(auto_loss_count)
    - name: "Average Auto Loss Count"
      expr: AVG(auto_loss_count)
    - name: "Total Clue Score"
      expr: SUM(clue_score)
    - name: "Average Clue Score"
      expr: AVG(clue_score)
    - name: "Total Lookback Period Years"
      expr: SUM(lookback_period_years)
    - name: "Average Lookback Period Years"
      expr: AVG(lookback_period_years)
    - name: "Total Property Loss Count"
      expr: SUM(property_loss_count)
    - name: "Average Property Loss Count"
      expr: AVG(property_loss_count)
    - name: "Total Report Cost Amount"
      expr: SUM(report_cost_amount)
    - name: "Average Report Cost Amount"
      expr: AVG(report_cost_amount)
    - name: "Total Total Incurred Amount"
      expr: SUM(total_incurred_amount)
    - name: "Average Total Incurred Amount"
      expr: AVG(total_incurred_amount)
    - name: "Total Total Loss Count"
      expr: SUM(total_loss_count)
    - name: "Average Total Loss Count"
      expr: AVG(total_loss_count)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_driver_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Driver Assignment business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment`"
  dimensions:
    - name: "Assignment Number"
      expr: assignment_number
    - name: "Assignment Status"
      expr: assignment_status
    - name: "Business Use Indicator"
      expr: business_use_indicator
    - name: "Commute Frequency"
      expr: commute_frequency
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Driver Designation"
      expr: driver_designation
    - name: "Driver License Expiration Date"
      expr: driver_license_expiration_date
    - name: "Driver License Number"
      expr: driver_license_number
    - name: "Driver License State"
      expr: driver_license_state
    - name: "Driver License Status"
      expr: driver_license_status
    - name: "Driver Training Completion Date"
      expr: driver_training_completion_date
    - name: "Driver Training Completion Indicator"
      expr: driver_training_completion_indicator
    - name: "Dui Indicator"
      expr: dui_indicator
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Expiration Date"
      expr: expiration_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Driver Assignment"
      expr: COUNT(DISTINCT driver_assignment_id)
    - name: "Total Accident Count 3yr"
      expr: SUM(accident_count_3yr)
    - name: "Average Accident Count 3yr"
      expr: AVG(accident_count_3yr)
    - name: "Total Annual Mileage"
      expr: SUM(annual_mileage)
    - name: "Average Annual Mileage"
      expr: AVG(annual_mileage)
    - name: "Total Commute Distance Miles"
      expr: SUM(commute_distance_miles)
    - name: "Average Commute Distance Miles"
      expr: AVG(commute_distance_miles)
    - name: "Total Mvr Score"
      expr: SUM(mvr_score)
    - name: "Average Mvr Score"
      expr: AVG(mvr_score)
    - name: "Total Usage Percentage"
      expr: SUM(usage_percentage)
    - name: "Average Usage Percentage"
      expr: AVG(usage_percentage)
    - name: "Total Violation Count 3yr"
      expr: SUM(violation_count_3yr)
    - name: "Average Violation Count 3yr"
      expr: AVG(violation_count_3yr)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_experience_mod`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Experience Mod business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`experience_mod`"
  dimensions:
    - name: "Appeal Date"
      expr: appeal_date
    - name: "Appeal Resolution Date"
      expr: appeal_resolution_date
    - name: "Appeal Status"
      expr: appeal_status
    - name: "Bureau Code"
      expr: bureau_code
    - name: "Bureau Name"
      expr: bureau_name
    - name: "Calculation Date"
      expr: calculation_date
    - name: "Class Code"
      expr: class_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Interstate Mod Indicator"
      expr: interstate_mod_indicator
    - name: "Issued Date"
      expr: issued_date
    - name: "Mod Change Reason"
      expr: mod_change_reason
    - name: "Mod Number"
      expr: mod_number
    - name: "Mod Status"
      expr: mod_status
    - name: "Mod Type"
      expr: mod_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Experience Mod"
      expr: COUNT(DISTINCT experience_mod_id)
    - name: "Total Actual Loss Amount"
      expr: SUM(actual_loss_amount)
    - name: "Average Actual Loss Amount"
      expr: AVG(actual_loss_amount)
    - name: "Total Ballast Value"
      expr: SUM(ballast_value)
    - name: "Average Ballast Value"
      expr: AVG(ballast_value)
    - name: "Total Claim Count"
      expr: SUM(claim_count)
    - name: "Average Claim Count"
      expr: AVG(claim_count)
    - name: "Total Credibility Factor"
      expr: SUM(credibility_factor)
    - name: "Average Credibility Factor"
      expr: AVG(credibility_factor)
    - name: "Total Excess Loss Component"
      expr: SUM(excess_loss_component)
    - name: "Average Excess Loss Component"
      expr: AVG(excess_loss_component)
    - name: "Total Expected Excess Loss Amount"
      expr: SUM(expected_excess_loss_amount)
    - name: "Average Expected Excess Loss Amount"
      expr: AVG(expected_excess_loss_amount)
    - name: "Total Expected Loss Amount"
      expr: SUM(expected_loss_amount)
    - name: "Average Expected Loss Amount"
      expr: AVG(expected_loss_amount)
    - name: "Total Expected Primary Loss Amount"
      expr: SUM(expected_primary_loss_amount)
    - name: "Average Expected Primary Loss Amount"
      expr: AVG(expected_primary_loss_amount)
    - name: "Total Indemnity Claim Count"
      expr: SUM(indemnity_claim_count)
    - name: "Average Indemnity Claim Count"
      expr: AVG(indemnity_claim_count)
    - name: "Total Medical Only Claim Count"
      expr: SUM(medical_only_claim_count)
    - name: "Average Medical Only Claim Count"
      expr: AVG(medical_only_claim_count)
    - name: "Total Mod Value"
      expr: SUM(mod_value)
    - name: "Average Mod Value"
      expr: AVG(mod_value)
    - name: "Total Payroll Amount"
      expr: SUM(payroll_amount)
    - name: "Average Payroll Amount"
      expr: AVG(payroll_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_exposure_period`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Exposure Period business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`exposure_period`"
  dimensions:
    - name: "Cancellation Date"
      expr: cancellation_date
    - name: "Cancellation Reason Code"
      expr: cancellation_reason_code
    - name: "Cat Zone"
      expr: cat_zone
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Effective Date"
      expr: endorsement_effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exposure Basis"
      expr: exposure_basis
    - name: "Exposure Status"
      expr: exposure_status
    - name: "Is Cat Exposed"
      expr: is_cat_exposed
    - name: "Number"
      expr: number
    - name: "Reinstatement Date"
      expr: reinstatement_date
    - name: "Territory Code"
      expr: territory_code
    - name: "Transaction Type"
      expr: transaction_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Exposure Period"
      expr: COUNT(DISTINCT exposure_period_id)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Earned Days"
      expr: SUM(earned_days)
    - name: "Average Earned Days"
      expr: AVG(earned_days)
    - name: "Total Earned Exposure Units"
      expr: SUM(earned_exposure_units)
    - name: "Average Earned Exposure Units"
      expr: AVG(earned_exposure_units)
    - name: "Total Earned Premium Amount"
      expr: SUM(earned_premium_amount)
    - name: "Average Earned Premium Amount"
      expr: AVG(earned_premium_amount)
    - name: "Total Exposure Days"
      expr: SUM(exposure_days)
    - name: "Average Exposure Days"
      expr: AVG(exposure_days)
    - name: "Total Exposure Units"
      expr: SUM(exposure_units)
    - name: "Average Exposure Units"
      expr: AVG(exposure_units)
    - name: "Total Limit Amount"
      expr: SUM(limit_amount)
    - name: "Average Limit Amount"
      expr: AVG(limit_amount)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
    - name: "Total Premium Amount"
      expr: SUM(premium_amount)
    - name: "Average Premium Amount"
      expr: AVG(premium_amount)
    - name: "Total Pro Rata Factor"
      expr: SUM(pro_rata_factor)
    - name: "Average Pro Rata Factor"
      expr: AVG(pro_rata_factor)
    - name: "Total Rate Per Unit"
      expr: SUM(rate_per_unit)
    - name: "Average Rate Per Unit"
      expr: AVG(rate_per_unit)
    - name: "Total Sir Amount"
      expr: SUM(sir_amount)
    - name: "Average Sir Amount"
      expr: AVG(sir_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_flood_zone_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Flood Zone Assignment business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment`"
  dimensions:
    - name: "Assignment Status"
      expr: assignment_status
    - name: "Cbrs Unit Code"
      expr: cbrs_unit_code
    - name: "Coastal Barrier System Indicator"
      expr: coastal_barrier_system_indicator
    - name: "Comments"
      expr: comments
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Determination Date"
      expr: determination_date
    - name: "Determination Method"
      expr: determination_method
    - name: "Determination Number"
      expr: determination_number
    - name: "Determination Provider"
      expr: determination_provider
    - name: "Effective Date"
      expr: effective_date
    - name: "Elevation Certificate Available"
      expr: elevation_certificate_available
    - name: "Elevation Certificate Date"
      expr: elevation_certificate_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Firm Panel Effective Date"
      expr: firm_panel_effective_date
    - name: "Firm Panel Number"
      expr: firm_panel_number
    - name: "Firm Panel Revision Date"
      expr: firm_panel_revision_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Flood Zone Assignment"
      expr: COUNT(DISTINCT flood_zone_assignment_id)
    - name: "Total Base Flood Elevation Ft"
      expr: SUM(base_flood_elevation_ft)
    - name: "Average Base Flood Elevation Ft"
      expr: AVG(base_flood_elevation_ft)
    - name: "Total Elevation Difference Ft"
      expr: SUM(elevation_difference_ft)
    - name: "Average Elevation Difference Ft"
      expr: AVG(elevation_difference_ft)
    - name: "Total Flood Zone Rating Factor"
      expr: SUM(flood_zone_rating_factor)
    - name: "Average Flood Zone Rating Factor"
      expr: AVG(flood_zone_rating_factor)
    - name: "Total Lowest Floor Elevation Ft"
      expr: SUM(lowest_floor_elevation_ft)
    - name: "Average Lowest Floor Elevation Ft"
      expr: AVG(lowest_floor_elevation_ft)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_gl_operation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Gl Operation business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`gl_operation`"
  dimensions:
    - name: "Added Date"
      expr: added_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exposure Basis"
      expr: exposure_basis
    - name: "Hazard Grade"
      expr: hazard_grade
    - name: "Iso Gl Class Code"
      expr: iso_gl_class_code
    - name: "Iso Gl Class Description"
      expr: iso_gl_class_description
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Naics Code"
      expr: naics_code
    - name: "Operation Description"
      expr: operation_description
    - name: "Operation Name"
      expr: operation_name
    - name: "Operation Number"
      expr: operation_number
    - name: "Operation Status"
      expr: operation_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Gl Operation"
      expr: COUNT(DISTINCT gl_operation_id)
    - name: "Total Annual Payroll Amount"
      expr: SUM(annual_payroll_amount)
    - name: "Average Annual Payroll Amount"
      expr: AVG(annual_payroll_amount)
    - name: "Total Annual Premium Amount"
      expr: SUM(annual_premium_amount)
    - name: "Average Annual Premium Amount"
      expr: AVG(annual_premium_amount)
    - name: "Total Annual Receipts Amount"
      expr: SUM(annual_receipts_amount)
    - name: "Average Annual Receipts Amount"
      expr: AVG(annual_receipts_amount)
    - name: "Total Area Sqft"
      expr: SUM(area_sqft)
    - name: "Average Area Sqft"
      expr: AVG(area_sqft)
    - name: "Total Number Of Employees"
      expr: SUM(number_of_employees)
    - name: "Average Number Of Employees"
      expr: AVG(number_of_employees)
    - name: "Total Number Of Units"
      expr: SUM(number_of_units)
    - name: "Average Number Of Units"
      expr: AVG(number_of_units)
    - name: "Total Premises Operations Split Pct"
      expr: SUM(premises_operations_split_pct)
    - name: "Average Premises Operations Split Pct"
      expr: AVG(premises_operations_split_pct)
    - name: "Total Products Completed Ops Split Pct"
      expr: SUM(products_completed_ops_split_pct)
    - name: "Average Products Completed Ops Split Pct"
      expr: AVG(products_completed_ops_split_pct)
    - name: "Total Rate Per Exposure Unit"
      expr: SUM(rate_per_exposure_unit)
    - name: "Average Rate Per Exposure Unit"
      expr: AVG(rate_per_exposure_unit)
    - name: "Total Subcontractor Receipts Amount"
      expr: SUM(subcontractor_receipts_amount)
    - name: "Average Subcontractor Receipts Amount"
      expr: AVG(subcontractor_receipts_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_insured_entity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Insured Entity business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`"
  dimensions:
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Dba Name"
      expr: dba_name
    - name: "Effective Date"
      expr: effective_date
    - name: "Entity Number"
      expr: entity_number
    - name: "Entity Status"
      expr: entity_status
    - name: "Entity Type"
      expr: entity_type
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fein"
      expr: fein
    - name: "Is Subsidiary"
      expr: is_subsidiary
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Legal Name"
      expr: legal_name
    - name: "Mailing Address Line1"
      expr: mailing_address_line1
    - name: "Mailing Address Line2"
      expr: mailing_address_line2
    - name: "Mailing City"
      expr: mailing_city
    - name: "Mailing Country Code"
      expr: mailing_country_code
    - name: "Mailing Postal Code"
      expr: mailing_postal_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Insured Entity"
      expr: COUNT(DISTINCT insured_entity_id)
    - name: "Total Annual Revenue Amount"
      expr: SUM(annual_revenue_amount)
    - name: "Average Annual Revenue Amount"
      expr: AVG(annual_revenue_amount)
    - name: "Total Credit Score"
      expr: SUM(credit_score)
    - name: "Average Credit Score"
      expr: AVG(credit_score)
    - name: "Total Loss Free Years"
      expr: SUM(loss_free_years)
    - name: "Average Loss Free Years"
      expr: AVG(loss_free_years)
    - name: "Total Number Of Employees"
      expr: SUM(number_of_employees)
    - name: "Average Number Of Employees"
      expr: AVG(number_of_employees)
    - name: "Total Years In Business"
      expr: SUM(years_in_business)
    - name: "Average Years In Business"
      expr: AVG(years_in_business)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_insured_location`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Insured Location business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`insured_location`"
  dimensions:
    - name: "Address Line1"
      expr: address_line1
    - name: "Address Line2"
      expr: address_line2
    - name: "Alarm Type"
      expr: alarm_type
    - name: "Cat Zone"
      expr: cat_zone
    - name: "City"
      expr: city
    - name: "Construction Type"
      expr: construction_type
    - name: "County"
      expr: county
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Earthquake Zone"
      expr: earthquake_zone
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Flood Zone"
      expr: flood_zone
    - name: "Geocode Quality"
      expr: geocode_quality
    - name: "Location Code"
      expr: location_code
    - name: "Location Name"
      expr: location_name
    - name: "Location Status"
      expr: location_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Insured Location"
      expr: COUNT(DISTINCT insured_location_id)
    - name: "Total Building Value"
      expr: SUM(building_value)
    - name: "Average Building Value"
      expr: AVG(building_value)
    - name: "Total Business Income Value"
      expr: SUM(business_income_value)
    - name: "Average Business Income Value"
      expr: AVG(business_income_value)
    - name: "Total Contents Value"
      expr: SUM(contents_value)
    - name: "Average Contents Value"
      expr: AVG(contents_value)
    - name: "Total Distance To Coast Miles"
      expr: SUM(distance_to_coast_miles)
    - name: "Average Distance To Coast Miles"
      expr: AVG(distance_to_coast_miles)
    - name: "Total Distance To Fire Station Miles"
      expr: SUM(distance_to_fire_station_miles)
    - name: "Average Distance To Fire Station Miles"
      expr: AVG(distance_to_fire_station_miles)
    - name: "Total Itv Ratio"
      expr: SUM(itv_ratio)
    - name: "Average Itv Ratio"
      expr: AVG(itv_ratio)
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
    - name: "Total Roof Year"
      expr: SUM(roof_year)
    - name: "Average Roof Year"
      expr: AVG(roof_year)
    - name: "Total Tiv"
      expr: SUM(tiv)
    - name: "Average Tiv"
      expr: AVG(tiv)
    - name: "Total Total Area Sqft"
      expr: SUM(total_area_sqft)
    - name: "Average Total Area Sqft"
      expr: AVG(total_area_sqft)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_insured_vehicle`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Insured Vehicle business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`"
  dimensions:
    - name: "Anti Theft Device"
      expr: anti_theft_device
    - name: "Body Type"
      expr: body_type
    - name: "Collision Symbol"
      expr: collision_symbol
    - name: "Comp Symbol"
      expr: comp_symbol
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Garaging Address Line1"
      expr: garaging_address_line1
    - name: "Garaging Address Line2"
      expr: garaging_address_line2
    - name: "Garaging City"
      expr: garaging_city
    - name: "Garaging Country Code"
      expr: garaging_country_code
    - name: "Garaging County"
      expr: garaging_county
    - name: "Garaging Postal Code"
      expr: garaging_postal_code
    - name: "Garaging State Code"
      expr: garaging_state_code
    - name: "Is Rideshare Vehicle"
      expr: is_rideshare_vehicle
    - name: "Is Salvage Title"
      expr: is_salvage_title
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Insured Vehicle"
      expr: COUNT(DISTINCT insured_vehicle_id)
    - name: "Total Actual Cash Value Amount"
      expr: SUM(actual_cash_value_amount)
    - name: "Average Actual Cash Value Amount"
      expr: AVG(actual_cash_value_amount)
    - name: "Total Annual Mileage"
      expr: SUM(annual_mileage)
    - name: "Average Annual Mileage"
      expr: AVG(annual_mileage)
    - name: "Total Odometer Reading"
      expr: SUM(odometer_reading)
    - name: "Average Odometer Reading"
      expr: AVG(odometer_reading)
    - name: "Total Purchase Price Amount"
      expr: SUM(purchase_price_amount)
    - name: "Average Purchase Price Amount"
      expr: AVG(purchase_price_amount)
    - name: "Total Stated Value Amount"
      expr: SUM(stated_value_amount)
    - name: "Average Stated Value Amount"
      expr: AVG(stated_value_amount)
    - name: "Total Year"
      expr: SUM(year)
    - name: "Average Year"
      expr: AVG(year)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_location_claimant_interest`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Location Claimant Interest business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest`"
  dimensions:
    - name: "Effective Date"
      expr: effective_date
    - name: "Injury Location Description"
      expr: injury_location_description
    - name: "Location Claimant Interest Status"
      expr: location_claimant_interest_status
    - name: "Property Interest Type"
      expr: property_interest_type
    - name: "Role"
      expr: role
    - name: "Termination Date"
      expr: termination_date
    - name: "Effective Date Month"
      expr: DATE_TRUNC('MONTH', effective_date)
    - name: "Termination Date Month"
      expr: DATE_TRUNC('MONTH', termination_date)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Location Claimant Interest"
      expr: COUNT(DISTINCT location_claimant_interest_id)
    - name: "Total Loss Exposure Percentage"
      expr: SUM(loss_exposure_percentage)
    - name: "Average Loss Exposure Percentage"
      expr: AVG(loss_exposure_percentage)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_mvr_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Mvr Report business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`mvr_report`"
  dimensions:
    - name: "Cost Currency"
      expr: cost_currency
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Is Acceptable For Underwriting"
      expr: is_acceptable_for_underwriting
    - name: "License Class"
      expr: license_class
    - name: "License Expiration Date"
      expr: license_expiration_date
    - name: "License Issue Date"
      expr: license_issue_date
    - name: "License Number"
      expr: license_number
    - name: "License State"
      expr: license_state
    - name: "License Status"
      expr: license_status
    - name: "Mvr Tier"
      expr: mvr_tier
    - name: "Order Date"
      expr: order_date
    - name: "Ordered By User Code"
      expr: ordered_by_user_code
    - name: "Provider Name"
      expr: provider_name
    - name: "Received Date"
      expr: received_date
    - name: "Rejection Reason"
      expr: rejection_reason
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Mvr Report"
      expr: COUNT(DISTINCT mvr_report_id)
    - name: "Total Accident Count"
      expr: SUM(accident_count)
    - name: "Average Accident Count"
      expr: AVG(accident_count)
    - name: "Total At Fault Accident Count"
      expr: SUM(at_fault_accident_count)
    - name: "Average At Fault Accident Count"
      expr: AVG(at_fault_accident_count)
    - name: "Total Cost Amount"
      expr: SUM(cost_amount)
    - name: "Average Cost Amount"
      expr: AVG(cost_amount)
    - name: "Total Dui Count"
      expr: SUM(dui_count)
    - name: "Average Dui Count"
      expr: AVG(dui_count)
    - name: "Total Lookback Period Years"
      expr: SUM(lookback_period_years)
    - name: "Average Lookback Period Years"
      expr: AVG(lookback_period_years)
    - name: "Total Major Violation Count"
      expr: SUM(major_violation_count)
    - name: "Average Major Violation Count"
      expr: AVG(major_violation_count)
    - name: "Total Minor Violation Count"
      expr: SUM(minor_violation_count)
    - name: "Average Minor Violation Count"
      expr: AVG(minor_violation_count)
    - name: "Total Mvr Score"
      expr: SUM(mvr_score)
    - name: "Average Mvr Score"
      expr: AVG(mvr_score)
    - name: "Total Not At Fault Accident Count"
      expr: SUM(not_at_fault_accident_count)
    - name: "Average Not At Fault Accident Count"
      expr: AVG(not_at_fault_accident_count)
    - name: "Total Suspension Count"
      expr: SUM(suspension_count)
    - name: "Average Suspension Count"
      expr: AVG(suspension_count)
    - name: "Total Violation Count"
      expr: SUM(violation_count)
    - name: "Average Violation Count"
      expr: AVG(violation_count)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_pml_estimate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pml Estimate business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate`"
  dimensions:
    - name: "Approved By"
      expr: approved_by
    - name: "Approved Date"
      expr: approved_date
    - name: "Cat Zone Code"
      expr: cat_zone_code
    - name: "Construction Type"
      expr: construction_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Estimate Number"
      expr: estimate_number
    - name: "Estimate Status"
      expr: estimate_status
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Model Run Code"
      expr: model_run_code
    - name: "Model Run Date"
      expr: model_run_date
    - name: "Model Vendor"
      expr: model_vendor
    - name: "Model Version"
      expr: model_version
    - name: "Occupancy Type"
      expr: occupancy_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Pml Estimate"
      expr: COUNT(DISTINCT pml_estimate_id)
    - name: "Total Annual Aggregate Deductible Amount"
      expr: SUM(annual_aggregate_deductible_amount)
    - name: "Average Annual Aggregate Deductible Amount"
      expr: AVG(annual_aggregate_deductible_amount)
    - name: "Total Confidence Level Percentage"
      expr: SUM(confidence_level_percentage)
    - name: "Average Confidence Level Percentage"
      expr: AVG(confidence_level_percentage)
    - name: "Total Exceedance Probability"
      expr: SUM(exceedance_probability)
    - name: "Average Exceedance Probability"
      expr: AVG(exceedance_probability)
    - name: "Total Gross Pml Amount"
      expr: SUM(gross_pml_amount)
    - name: "Average Gross Pml Amount"
      expr: AVG(gross_pml_amount)
    - name: "Total Net Pml Amount"
      expr: SUM(net_pml_amount)
    - name: "Average Net Pml Amount"
      expr: AVG(net_pml_amount)
    - name: "Total Number Of Stories"
      expr: SUM(number_of_stories)
    - name: "Average Number Of Stories"
      expr: AVG(number_of_stories)
    - name: "Total Per Occurrence Limit Amount"
      expr: SUM(per_occurrence_limit_amount)
    - name: "Average Per Occurrence Limit Amount"
      expr: AVG(per_occurrence_limit_amount)
    - name: "Total Pml Percentage"
      expr: SUM(pml_percentage)
    - name: "Average Pml Percentage"
      expr: AVG(pml_percentage)
    - name: "Total Scenario Return Period Years"
      expr: SUM(scenario_return_period_years)
    - name: "Average Scenario Return Period Years"
      expr: AVG(scenario_return_period_years)
    - name: "Total Tiv"
      expr: SUM(tiv)
    - name: "Average Tiv"
      expr: AVG(tiv)
    - name: "Total Year Built"
      expr: SUM(year_built)
    - name: "Average Year Built"
      expr: AVG(year_built)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_risk_change_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Risk Change Event business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event`"
  dimensions:
    - name: "Approved Date"
      expr: approved_date
    - name: "Change Reason Code"
      expr: change_reason_code
    - name: "Change Reason Description"
      expr: change_reason_description
    - name: "Change Status"
      expr: change_status
    - name: "Change Type"
      expr: change_type
    - name: "Changed Attribute Name"
      expr: changed_attribute_name
    - name: "Class Code"
      expr: class_code
    - name: "Created By User"
      expr: created_by_user
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Is Cat Exposed"
      expr: is_cat_exposed
    - name: "Last Modified By User"
      expr: last_modified_by_user
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "New Cat Zone"
      expr: new_cat_zone
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Risk Change Event"
      expr: COUNT(DISTINCT risk_change_event_id)
    - name: "Total New Exposure Units"
      expr: SUM(new_exposure_units)
    - name: "Average New Exposure Units"
      expr: AVG(new_exposure_units)
    - name: "Total New Premium Amount"
      expr: SUM(new_premium_amount)
    - name: "Average New Premium Amount"
      expr: AVG(new_premium_amount)
    - name: "Total New Tiv"
      expr: SUM(new_tiv)
    - name: "Average New Tiv"
      expr: AVG(new_tiv)
    - name: "Total New Value"
      expr: SUM(new_value)
    - name: "Average New Value"
      expr: AVG(new_value)
    - name: "Total Premium Impact Amount"
      expr: SUM(premium_impact_amount)
    - name: "Average Premium Impact Amount"
      expr: AVG(premium_impact_amount)
    - name: "Total Prior Exposure Units"
      expr: SUM(prior_exposure_units)
    - name: "Average Prior Exposure Units"
      expr: AVG(prior_exposure_units)
    - name: "Total Prior Premium Amount"
      expr: SUM(prior_premium_amount)
    - name: "Average Prior Premium Amount"
      expr: AVG(prior_premium_amount)
    - name: "Total Prior Tiv"
      expr: SUM(prior_tiv)
    - name: "Average Prior Tiv"
      expr: AVG(prior_tiv)
    - name: "Total Prior Value"
      expr: SUM(prior_value)
    - name: "Average Prior Value"
      expr: AVG(prior_value)
    - name: "Total Underwriter Code"
      expr: SUM(underwriter_code)
    - name: "Average Underwriter Code"
      expr: AVG(underwriter_code)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_risk_characteristic`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Risk Characteristic business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic`"
  dimensions:
    - name: "Boolean Value"
      expr: boolean_value
    - name: "Change Reason"
      expr: change_reason
    - name: "Characteristic Category"
      expr: characteristic_category
    - name: "Characteristic Code"
      expr: characteristic_code
    - name: "Characteristic Data Type"
      expr: characteristic_data_type
    - name: "Characteristic Name"
      expr: characteristic_name
    - name: "Created By User"
      expr: created_by_user
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Date Value"
      expr: date_value
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Is Mandatory"
      expr: is_mandatory
    - name: "Is Rating Variable"
      expr: is_rating_variable
    - name: "Is Underwriting Factor"
      expr: is_underwriting_factor
    - name: "Iso Class Code"
      expr: iso_class_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Risk Characteristic"
      expr: COUNT(DISTINCT risk_characteristic_id)
    - name: "Total Characteristic Value"
      expr: SUM(characteristic_value)
    - name: "Average Characteristic Value"
      expr: AVG(characteristic_value)
    - name: "Total Numeric Value"
      expr: SUM(numeric_value)
    - name: "Average Numeric Value"
      expr: AVG(numeric_value)
    - name: "Total Rating Impact Factor"
      expr: SUM(rating_impact_factor)
    - name: "Average Rating Impact Factor"
      expr: AVG(rating_impact_factor)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_risk_score`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Risk Score business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`risk_score`"
  dimensions:
    - name: "Adverse Action Required"
      expr: adverse_action_required
    - name: "Cat Zone"
      expr: cat_zone
    - name: "Coverage Type"
      expr: coverage_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Error Code"
      expr: error_code
    - name: "Error Message"
      expr: error_message
    - name: "Lob Code"
      expr: lob_code
    - name: "Model Effective Date"
      expr: model_effective_date
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
    - name: "Override User Code"
      expr: override_user_code
    - name: "Request Reference Number"
      expr: request_reference_number
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Risk Score"
      expr: COUNT(DISTINCT risk_score_id)
    - name: "Total Data Source Count"
      expr: SUM(data_source_count)
    - name: "Average Data Source Count"
      expr: AVG(data_source_count)
    - name: "Total Rate Modifier"
      expr: SUM(rate_modifier)
    - name: "Average Rate Modifier"
      expr: AVG(rate_modifier)
    - name: "Total Score Cost Amount"
      expr: SUM(score_cost_amount)
    - name: "Average Score Cost Amount"
      expr: AVG(score_cost_amount)
    - name: "Total Score Percentile"
      expr: SUM(score_percentile)
    - name: "Average Score Percentile"
      expr: AVG(score_percentile)
    - name: "Total Score Value"
      expr: SUM(score_value)
    - name: "Average Score Value"
      expr: AVG(score_value)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_risk_unit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_scheduled_equipment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Scheduled Equipment business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment`"
  dimensions:
    - name: "Added Date"
      expr: added_date
    - name: "Appraisal Date"
      expr: appraisal_date
    - name: "Appraiser Name"
      expr: appraiser_name
    - name: "Blanket Group Code"
      expr: blanket_group_code
    - name: "Coverage Type"
      expr: coverage_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Equipment Category"
      expr: equipment_category
    - name: "Equipment Description"
      expr: equipment_description
    - name: "Equipment Name"
      expr: equipment_name
    - name: "Equipment Status"
      expr: equipment_status
    - name: "Equipment Type"
      expr: equipment_type
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Is Away From Premises"
      expr: is_away_from_premises
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Scheduled Equipment"
      expr: COUNT(DISTINCT scheduled_equipment_id)
    - name: "Total Acv Amount"
      expr: SUM(acv_amount)
    - name: "Average Acv Amount"
      expr: AVG(acv_amount)
    - name: "Total Agreed Value Amount"
      expr: SUM(agreed_value_amount)
    - name: "Average Agreed Value Amount"
      expr: AVG(agreed_value_amount)
    - name: "Total Annual Premium Amount"
      expr: SUM(annual_premium_amount)
    - name: "Average Annual Premium Amount"
      expr: AVG(annual_premium_amount)
    - name: "Total Appraisal Value Amount"
      expr: SUM(appraisal_value_amount)
    - name: "Average Appraisal Value Amount"
      expr: AVG(appraisal_value_amount)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Purchase Price Amount"
      expr: SUM(purchase_price_amount)
    - name: "Average Purchase Price Amount"
      expr: AVG(purchase_price_amount)
    - name: "Total Rate Per Hundred"
      expr: SUM(rate_per_hundred)
    - name: "Average Rate Per Hundred"
      expr: AVG(rate_per_hundred)
    - name: "Total Rcv Amount"
      expr: SUM(rcv_amount)
    - name: "Average Rcv Amount"
      expr: AVG(rcv_amount)
    - name: "Total Year Manufactured"
      expr: SUM(year_manufactured)
    - name: "Average Year Manufactured"
      expr: AVG(year_manufactured)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_scheduled_item`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Scheduled Item business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`"
  dimensions:
    - name: "Agreed Value Currency"
      expr: agreed_value_currency
    - name: "Appraisal Date"
      expr: appraisal_date
    - name: "Appraisal Expiry Date"
      expr: appraisal_expiry_date
    - name: "Appraiser Certification Number"
      expr: appraiser_certification_number
    - name: "Appraiser Name"
      expr: appraiser_name
    - name: "Blanket Group Code"
      expr: blanket_group_code
    - name: "Coverage Type"
      expr: coverage_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Is Away From Premises"
      expr: is_away_from_premises
    - name: "Is Blanket Covered"
      expr: is_blanket_covered
    - name: "Iso Class Code"
      expr: iso_class_code
    - name: "Item Category"
      expr: item_category
    - name: "Item Description"
      expr: item_description
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Scheduled Item"
      expr: COUNT(DISTINCT scheduled_item_id)
    - name: "Total Actual Cash Value Amount"
      expr: SUM(actual_cash_value_amount)
    - name: "Average Actual Cash Value Amount"
      expr: AVG(actual_cash_value_amount)
    - name: "Total Agreed Value Amount"
      expr: SUM(agreed_value_amount)
    - name: "Average Agreed Value Amount"
      expr: AVG(agreed_value_amount)
    - name: "Total Annual Premium Amount"
      expr: SUM(annual_premium_amount)
    - name: "Average Annual Premium Amount"
      expr: AVG(annual_premium_amount)
    - name: "Total Appraisal Value Amount"
      expr: SUM(appraisal_value_amount)
    - name: "Average Appraisal Value Amount"
      expr: AVG(appraisal_value_amount)
    - name: "Total Item Deductible Amount"
      expr: SUM(item_deductible_amount)
    - name: "Average Item Deductible Amount"
      expr: AVG(item_deductible_amount)
    - name: "Total Purchase Price Amount"
      expr: SUM(purchase_price_amount)
    - name: "Average Purchase Price Amount"
      expr: AVG(purchase_price_amount)
    - name: "Total Rate Per Hundred"
      expr: SUM(rate_per_hundred)
    - name: "Average Rate Per Hundred"
      expr: AVG(rate_per_hundred)
    - name: "Total Replacement Cost Value Amount"
      expr: SUM(replacement_cost_value_amount)
    - name: "Average Replacement Cost Value Amount"
      expr: AVG(replacement_cost_value_amount)
    - name: "Total Year Manufactured"
      expr: SUM(year_manufactured)
    - name: "Average Year Manufactured"
      expr: AVG(year_manufactured)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_sir_retention`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Sir Retention business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`sir_retention`"
  dimensions:
    - name: "Administrator Contact Name"
      expr: administrator_contact_name
    - name: "Administrator Email"
      expr: administrator_email
    - name: "Administrator Name"
      expr: administrator_name
    - name: "Administrator Phone"
      expr: administrator_phone
    - name: "Cancellation Date"
      expr: cancellation_date
    - name: "Cancellation Reason"
      expr: cancellation_reason
    - name: "Claims Handling Arrangement"
      expr: claims_handling_arrangement
    - name: "Collateral Expiration Date"
      expr: collateral_expiration_date
    - name: "Collateral Provider Name"
      expr: collateral_provider_name
    - name: "Collateral Type"
      expr: collateral_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Loss Control Services Included"
      expr: loss_control_services_included
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Sir Retention"
      expr: COUNT(DISTINCT sir_retention_id)
    - name: "Total Aggregate Limit Amount"
      expr: SUM(aggregate_limit_amount)
    - name: "Average Aggregate Limit Amount"
      expr: AVG(aggregate_limit_amount)
    - name: "Total Collateral Amount"
      expr: SUM(collateral_amount)
    - name: "Average Collateral Amount"
      expr: AVG(collateral_amount)
    - name: "Total Loss Fund Amount"
      expr: SUM(loss_fund_amount)
    - name: "Average Loss Fund Amount"
      expr: AVG(loss_fund_amount)
    - name: "Total Sir Amount"
      expr: SUM(sir_amount)
    - name: "Average Sir Amount"
      expr: AVG(sir_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_tiv_schedule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tiv Schedule business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule`"
  dimensions:
    - name: "Appraisal Date"
      expr: appraisal_date
    - name: "Appraisal Expiry Date"
      expr: appraisal_expiry_date
    - name: "Appraiser Certification Number"
      expr: appraiser_certification_number
    - name: "Appraiser Name"
      expr: appraiser_name
    - name: "Blanket Group Code"
      expr: blanket_group_code
    - name: "Construction Type"
      expr: construction_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deductible Type"
      expr: deductible_type
    - name: "Depreciation Basis"
      expr: depreciation_basis
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Is Blanket Covered"
      expr: is_blanket_covered
    - name: "Iso Class Code"
      expr: iso_class_code
    - name: "Item Category"
      expr: item_category
    - name: "Item Description"
      expr: item_description
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Tiv Schedule"
      expr: COUNT(DISTINCT tiv_schedule_id)
    - name: "Total Actual Cash Value Amount"
      expr: SUM(actual_cash_value_amount)
    - name: "Average Actual Cash Value Amount"
      expr: AVG(actual_cash_value_amount)
    - name: "Total Agreed Value Amount"
      expr: SUM(agreed_value_amount)
    - name: "Average Agreed Value Amount"
      expr: AVG(agreed_value_amount)
    - name: "Total Annual Premium Amount"
      expr: SUM(annual_premium_amount)
    - name: "Average Annual Premium Amount"
      expr: AVG(annual_premium_amount)
    - name: "Total Appraisal Value Amount"
      expr: SUM(appraisal_value_amount)
    - name: "Average Appraisal Value Amount"
      expr: AVG(appraisal_value_amount)
    - name: "Total Coinsurance Percentage"
      expr: SUM(coinsurance_percentage)
    - name: "Average Coinsurance Percentage"
      expr: AVG(coinsurance_percentage)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Depreciation Amount"
      expr: SUM(depreciation_amount)
    - name: "Average Depreciation Amount"
      expr: AVG(depreciation_amount)
    - name: "Total Insurance To Value Ratio"
      expr: SUM(insurance_to_value_ratio)
    - name: "Average Insurance To Value Ratio"
      expr: AVG(insurance_to_value_ratio)
    - name: "Total Item Sequence"
      expr: SUM(item_sequence)
    - name: "Average Item Sequence"
      expr: AVG(item_sequence)
    - name: "Total Rate Per Hundred"
      expr: SUM(rate_per_hundred)
    - name: "Average Rate Per Hundred"
      expr: AVG(rate_per_hundred)
    - name: "Total Replacement Cost Value Amount"
      expr: SUM(replacement_cost_value_amount)
    - name: "Average Replacement Cost Value Amount"
      expr: AVG(replacement_cost_value_amount)
    - name: "Total Sum Insured Amount"
      expr: SUM(sum_insured_amount)
    - name: "Average Sum Insured Amount"
      expr: AVG(sum_insured_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_uw_survey`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Uw Survey business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`uw_survey`"
  dimensions:
    - name: "Completed Date"
      expr: completed_date
    - name: "Conditions Imposed"
      expr: conditions_imposed
    - name: "Cope Construction"
      expr: cope_construction
    - name: "Cope Exposure"
      expr: cope_exposure
    - name: "Cope Occupancy"
      expr: cope_occupancy
    - name: "Cope Protection"
      expr: cope_protection
    - name: "Cost Currency"
      expr: cost_currency
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Findings Summary"
      expr: findings_summary
    - name: "Follow Up Date"
      expr: follow_up_date
    - name: "Follow Up Required Flag"
      expr: follow_up_required_flag
    - name: "Hazards Identified"
      expr: hazards_identified
    - name: "Improvement Deadline Date"
      expr: improvement_deadline_date
    - name: "Inspector Code"
      expr: inspector_code
    - name: "Inspector Company"
      expr: inspector_company
    - name: "Inspector Name"
      expr: inspector_name
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Uw Survey"
      expr: COUNT(DISTINCT uw_survey_id)
    - name: "Total Cost Amount"
      expr: SUM(cost_amount)
    - name: "Average Cost Amount"
      expr: AVG(cost_amount)
    - name: "Total Duration Minutes"
      expr: SUM(duration_minutes)
    - name: "Average Duration Minutes"
      expr: AVG(duration_minutes)
    - name: "Total Photos Taken Count"
      expr: SUM(photos_taken_count)
    - name: "Average Photos Taken Count"
      expr: AVG(photos_taken_count)
    - name: "Total Premium Impact Amount"
      expr: SUM(premium_impact_amount)
    - name: "Average Premium Impact Amount"
      expr: AVG(premium_impact_amount)
    - name: "Total Premium Impact Percentage"
      expr: SUM(premium_impact_percentage)
    - name: "Average Premium Impact Percentage"
      expr: AVG(premium_impact_percentage)
    - name: "Total Risk Score"
      expr: SUM(risk_score)
    - name: "Average Risk Score"
      expr: AVG(risk_score)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_vehicle_claimant_involvement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Vehicle Claimant Involvement business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement`"
  dimensions:
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Driver At Time Of Loss"
      expr: driver_at_time_of_loss
    - name: "Injury Caused By Vehicle"
      expr: injury_caused_by_vehicle
    - name: "Relationship To Insured"
      expr: relationship_to_insured
    - name: "Updated Timestamp"
      expr: updated_timestamp
    - name: "Vehicle Occupant Position"
      expr: vehicle_occupant_position
    - name: "Created Timestamp Month"
      expr: DATE_TRUNC('MONTH', created_timestamp)
    - name: "Updated Timestamp Month"
      expr: DATE_TRUNC('MONTH', updated_timestamp)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Vehicle Claimant Involvement"
      expr: COUNT(DISTINCT vehicle_claimant_involvement_id)
    - name: "Total Fault Percentage"
      expr: SUM(fault_percentage)
    - name: "Average Fault Percentage"
      expr: AVG(fault_percentage)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`riskexposure_wc_payroll_class`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Wc Payroll Class business metrics"
  source: "`vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class`"
  dimensions:
    - name: "Audit Type"
      expr: audit_type
    - name: "Catastrophe Code"
      expr: catastrophe_code
    - name: "Class Code"
      expr: class_code
    - name: "Class Description"
      expr: class_description
    - name: "Class Status"
      expr: class_status
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exposure Basis"
      expr: exposure_basis
    - name: "Governing Class Indicator"
      expr: governing_class_indicator
    - name: "Hazard Group"
      expr: hazard_group
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Naics Code"
      expr: naics_code
    - name: "Payroll Currency"
      expr: payroll_currency
    - name: "Premium Basis Type"
      expr: premium_basis_type
    - name: "Sic Code"
      expr: sic_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Wc Payroll Class"
      expr: COUNT(DISTINCT wc_payroll_class_id)
    - name: "Total Audited Payroll Amount"
      expr: SUM(audited_payroll_amount)
    - name: "Average Audited Payroll Amount"
      expr: AVG(audited_payroll_amount)
    - name: "Total Estimated Annual Payroll"
      expr: SUM(estimated_annual_payroll)
    - name: "Average Estimated Annual Payroll"
      expr: AVG(estimated_annual_payroll)
    - name: "Total Executive Officer Payroll"
      expr: SUM(executive_officer_payroll)
    - name: "Average Executive Officer Payroll"
      expr: AVG(executive_officer_payroll)
    - name: "Total Experience Mod"
      expr: SUM(experience_mod)
    - name: "Average Experience Mod"
      expr: AVG(experience_mod)
    - name: "Total Exposure Units"
      expr: SUM(exposure_units)
    - name: "Average Exposure Units"
      expr: AVG(exposure_units)
    - name: "Total Final Rate"
      expr: SUM(final_rate)
    - name: "Average Final Rate"
      expr: AVG(final_rate)
    - name: "Total Full Time Employee Count"
      expr: SUM(full_time_employee_count)
    - name: "Average Full Time Employee Count"
      expr: AVG(full_time_employee_count)
    - name: "Total Increased Limits Factor"
      expr: SUM(increased_limits_factor)
    - name: "Average Increased Limits Factor"
      expr: AVG(increased_limits_factor)
    - name: "Total Loss Cost"
      expr: SUM(loss_cost)
    - name: "Average Loss Cost"
      expr: AVG(loss_cost)
    - name: "Total Loss Cost Multiplier"
      expr: SUM(loss_cost_multiplier)
    - name: "Average Loss Cost Multiplier"
      expr: AVG(loss_cost_multiplier)
    - name: "Total Manual Premium Amount"
      expr: SUM(manual_premium_amount)
    - name: "Average Manual Premium Amount"
      expr: AVG(manual_premium_amount)
    - name: "Total Manual Rate"
      expr: SUM(manual_rate)
    - name: "Average Manual Rate"
      expr: AVG(manual_rate)
$$;