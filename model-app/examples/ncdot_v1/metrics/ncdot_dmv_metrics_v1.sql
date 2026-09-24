-- Metric views for domain: dmv | Business:  | Version: 1 | Generated on: 2026-03-04 13:37:28

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_appointment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Appointment business metrics"
  source: "`feip_eastus_03`.`dmv`.`appointment`"
  dimensions:
    - name: "Confirmation Number"
      expr: confirmation_number
    - name: "Service Type"
      expr: service_type
    - name: "Service Category"
      expr: service_category
    - name: "Status"
      expr: status
    - name: "Scheduled Date"
      expr: scheduled_date
    - name: "Scheduled Duration Minutes"
      expr: scheduled_duration_minutes
    - name: "Customer Email"
      expr: customer_email
    - name: "Customer Phone"
      expr: customer_phone
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Confirmed Timestamp"
      expr: confirmed_timestamp
    - name: "Checked In Timestamp"
      expr: checked_in_timestamp
    - name: "Service Start Timestamp"
      expr: service_start_timestamp
    - name: "Service End Timestamp"
      expr: service_end_timestamp
    - name: "Cancelled Timestamp"
      expr: cancelled_timestamp
    - name: "Cancellation Reason"
      expr: cancellation_reason
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Appointment"
      expr: COUNT(DISTINCT appointment_id)
    - name: "Total Payment Amount"
      expr: SUM(payment_amount)
    - name: "Average Payment Amount"
      expr: AVG(payment_amount)
    - name: "Total Test Score"
      expr: SUM(test_score)
    - name: "Average Test Score"
      expr: AVG(test_score)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_crash_involvement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Crash Involvement business metrics"
  source: "`feip_eastus_03`.`dmv`.`crash_involvement`"
  dimensions:
    - name: "Driver Role"
      expr: driver_role
    - name: "Injury Severity"
      expr: injury_severity
    - name: "Citation Issued"
      expr: citation_issued
    - name: "Citation Number"
      expr: citation_number
    - name: "Vehicle Unit Number"
      expr: vehicle_unit_number
    - name: "Airbag Deployed"
      expr: airbag_deployed
    - name: "Ejected From Vehicle"
      expr: ejected_from_vehicle
    - name: "Transported To Hospital"
      expr: transported_to_hospital
    - name: "Hospital Name"
      expr: hospital_name
    - name: "Contributing Factors"
      expr: contributing_factors
    - name: "Drug Test Result"
      expr: drug_test_result
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Crash Involvement"
      expr: COUNT(DISTINCT crash_involvement_id)
    - name: "Total Fault Percentage"
      expr: SUM(fault_percentage)
    - name: "Average Fault Percentage"
      expr: AVG(fault_percentage)
    - name: "Total Alcohol Test Result"
      expr: SUM(alcohol_test_result)
    - name: "Average Alcohol Test Result"
      expr: AVG(alcohol_test_result)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_driver`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Driver business metrics"
  source: "`feip_eastus_03`.`dmv`.`driver`"
  dimensions:
    - name: "License Number"
      expr: license_number
    - name: "First Name"
      expr: first_name
    - name: "Middle Name"
      expr: middle_name
    - name: "Last Name"
      expr: last_name
    - name: "Suffix"
      expr: suffix
    - name: "Date Of Birth"
      expr: date_of_birth
    - name: "Gender"
      expr: gender
    - name: "Social Security Number"
      expr: social_security_number
    - name: "Residential Address Line 1"
      expr: residential_address_line_1
    - name: "Residential Address Line 2"
      expr: residential_address_line_2
    - name: "Residential City"
      expr: residential_city
    - name: "Residential State"
      expr: residential_state
    - name: "Residential Zip Code"
      expr: residential_zip_code
    - name: "Residential County"
      expr: residential_county
    - name: "Mailing Address Line 1"
      expr: mailing_address_line_1
    - name: "Mailing Address Line 2"
      expr: mailing_address_line_2
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Driver"
      expr: COUNT(DISTINCT driver_id)
    - name: "Total Reinstatement Fee Paid"
      expr: SUM(reinstatement_fee_paid)
    - name: "Average Reinstatement Fee Paid"
      expr: AVG(reinstatement_fee_paid)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_fee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fee business metrics"
  source: "`feip_eastus_03`.`dmv`.`fee`"
  dimensions:
    - name: "Code"
      expr: code
    - name: "Name"
      expr: name
    - name: "Description"
      expr: description
    - name: "Category"
      expr: category
    - name: "Subcategory"
      expr: subcategory
    - name: "Calculation Method"
      expr: calculation_method
    - name: "Vehicle Class"
      expr: vehicle_class
    - name: "License Type"
      expr: license_type
    - name: "Cdl Indicator"
      expr: cdl_indicator
    - name: "Duration Years"
      expr: duration_years
    - name: "Statutory Reference"
      expr: statutory_reference
    - name: "Revenue Code"
      expr: revenue_code
    - name: "Fund Code"
      expr: fund_code
    - name: "Distribution Method"
      expr: distribution_method
    - name: "Payment Methods Accepted"
      expr: payment_methods_accepted
    - name: "Online Payment Eligible"
      expr: online_payment_eligible
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Fee"
      expr: COUNT(DISTINCT fee_id)
    - name: "Total Amount"
      expr: SUM(amount)
    - name: "Average Amount"
      expr: AVG(amount)
    - name: "Total Minimum Amount"
      expr: SUM(minimum_amount)
    - name: "Average Minimum Amount"
      expr: AVG(minimum_amount)
    - name: "Total Maximum Amount"
      expr: SUM(maximum_amount)
    - name: "Average Maximum Amount"
      expr: AVG(maximum_amount)
    - name: "Total Late Penalty Amount"
      expr: SUM(late_penalty_amount)
    - name: "Average Late Penalty Amount"
      expr: AVG(late_penalty_amount)
    - name: "Total Late Penalty Percentage"
      expr: SUM(late_penalty_percentage)
    - name: "Average Late Penalty Percentage"
      expr: AVG(late_penalty_percentage)
    - name: "Total Vendor Portion Amount"
      expr: SUM(vendor_portion_amount)
    - name: "Average Vendor Portion Amount"
      expr: AVG(vendor_portion_amount)
    - name: "Total State Portion Amount"
      expr: SUM(state_portion_amount)
    - name: "Average State Portion Amount"
      expr: AVG(state_portion_amount)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_license`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "License business metrics"
  source: "`feip_eastus_03`.`dmv`.`license`"
  dimensions:
    - name: "Class"
      expr: class
    - name: "Type"
      expr: type
    - name: "Issue Date"
      expr: issue_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Status"
      expr: status
    - name: "Endorsements"
      expr: endorsements
    - name: "Restrictions"
      expr: restrictions
    - name: "Real Id Compliant"
      expr: real_id_compliant
    - name: "Card Number"
      expr: card_number
    - name: "Document Discriminator"
      expr: document_discriminator
    - name: "Issuing Authority"
      expr: issuing_authority
    - name: "Original Issue Date"
      expr: original_issue_date
    - name: "Previous License Number"
      expr: previous_license_number
    - name: "Previous State"
      expr: previous_state
    - name: "Hazmat Endorsement Expiration Date"
      expr: hazmat_endorsement_expiration_date
    - name: "Medical Certification Status"
      expr: medical_certification_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct License"
      expr: COUNT(DISTINCT license_id)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_license_type`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "License Type business metrics"
  source: "`feip_eastus_03`.`dmv`.`license_type`"
  dimensions:
    - name: "License Class Code"
      expr: license_class_code
    - name: "License Class Name"
      expr: license_class_name
    - name: "License Category"
      expr: license_category
    - name: "Is Cdl"
      expr: is_cdl
    - name: "Minimum Age Years"
      expr: minimum_age_years
    - name: "Maximum Age Years"
      expr: maximum_age_years
    - name: "Vehicle Weight Class Min Lbs"
      expr: vehicle_weight_class_min_lbs
    - name: "Vehicle Weight Class Max Lbs"
      expr: vehicle_weight_class_max_lbs
    - name: "Passenger Capacity Min"
      expr: passenger_capacity_min
    - name: "Passenger Capacity Max"
      expr: passenger_capacity_max
    - name: "Authorized Vehicle Types"
      expr: authorized_vehicle_types
    - name: "Requires Endorsement"
      expr: requires_endorsement
    - name: "Eligible Endorsements"
      expr: eligible_endorsements
    - name: "Requires Medical Certification"
      expr: requires_medical_certification
    - name: "Medical Certification Class"
      expr: medical_certification_class
    - name: "Knowledge Test Required"
      expr: knowledge_test_required
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct License Type"
      expr: COUNT(DISTINCT license_id)
    - name: "Total Application Fee Amount"
      expr: SUM(application_fee_amount)
    - name: "Average Application Fee Amount"
      expr: AVG(application_fee_amount)
    - name: "Total Renewal Fee Amount"
      expr: SUM(renewal_fee_amount)
    - name: "Average Renewal Fee Amount"
      expr: AVG(renewal_fee_amount)
    - name: "Total Duplicate Fee Amount"
      expr: SUM(duplicate_fee_amount)
    - name: "Average Duplicate Fee Amount"
      expr: AVG(duplicate_fee_amount)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_office`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Office business metrics"
  source: "`feip_eastus_03`.`dmv`.`office`"
  dimensions:
    - name: "Code"
      expr: code
    - name: "Name"
      expr: name
    - name: "Type"
      expr: type
    - name: "Status"
      expr: status
    - name: "Address Line 1"
      expr: address_line_1
    - name: "Address Line 2"
      expr: address_line_2
    - name: "City"
      expr: city
    - name: "County"
      expr: county
    - name: "Zip Code"
      expr: zip_code
    - name: "Phone Number"
      expr: phone_number
    - name: "Fax Number"
      expr: fax_number
    - name: "Email Address"
      expr: email_address
    - name: "Website Url"
      expr: website_url
    - name: "Monday Open Time"
      expr: monday_open_time
    - name: "Monday Close Time"
      expr: monday_close_time
    - name: "Tuesday Open Time"
      expr: tuesday_open_time
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Office"
      expr: COUNT(DISTINCT office_id)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_registration`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Registration business metrics"
  source: "`feip_eastus_03`.`dmv`.`registration`"
  dimensions:
    - name: "Plate Number"
      expr: plate_number
    - name: "Plate Type"
      expr: plate_type
    - name: "Vin"
      expr: vin
    - name: "Owner Name"
      expr: owner_name
    - name: "Owner Type"
      expr: owner_type
    - name: "Owner Address Line 1"
      expr: owner_address_line_1
    - name: "Owner Address Line 2"
      expr: owner_address_line_2
    - name: "Owner City"
      expr: owner_city
    - name: "Owner State"
      expr: owner_state
    - name: "Owner Zip Code"
      expr: owner_zip_code
    - name: "Owner Country"
      expr: owner_country
    - name: "Co Owner Name"
      expr: co_owner_name
    - name: "Lienholder Name"
      expr: lienholder_name
    - name: "Lienholder Address"
      expr: lienholder_address
    - name: "Lien Date"
      expr: lien_date
    - name: "Lien Release Date"
      expr: lien_release_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Registration"
      expr: COUNT(DISTINCT registration_id)
    - name: "Total Fee Amount"
      expr: SUM(fee_amount)
    - name: "Average Fee Amount"
      expr: AVG(fee_amount)
    - name: "Total Highway Use Tax Amount"
      expr: SUM(highway_use_tax_amount)
    - name: "Average Highway Use Tax Amount"
      expr: AVG(highway_use_tax_amount)
    - name: "Total Supplemental Fee Amount"
      expr: SUM(supplemental_fee_amount)
    - name: "Average Supplemental Fee Amount"
      expr: AVG(supplemental_fee_amount)
    - name: "Total Total Fee Amount"
      expr: SUM(total_fee_amount)
    - name: "Average Total Fee Amount"
      expr: AVG(total_fee_amount)
    - name: "Total Reinstatement Fee Amount"
      expr: SUM(reinstatement_fee_amount)
    - name: "Average Reinstatement Fee Amount"
      expr: AVG(reinstatement_fee_amount)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_title`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Title business metrics"
  source: "`feip_eastus_03`.`dmv`.`title`"
  dimensions:
    - name: "Number"
      expr: number
    - name: "Status"
      expr: status
    - name: "Type"
      expr: type
    - name: "Issue Date"
      expr: issue_date
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Transfer Date"
      expr: transfer_date
    - name: "Surrender Date"
      expr: surrender_date
    - name: "Holder Name"
      expr: holder_name
    - name: "Holder Type"
      expr: holder_type
    - name: "Holder Address Line1"
      expr: holder_address_line1
    - name: "Holder Address Line2"
      expr: holder_address_line2
    - name: "Holder City"
      expr: holder_city
    - name: "Holder State"
      expr: holder_state
    - name: "Holder Zip Code"
      expr: holder_zip_code
    - name: "Holder Country"
      expr: holder_country
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Title"
      expr: COUNT(DISTINCT title_id)
    - name: "Total Lien Amount"
      expr: SUM(lien_amount)
    - name: "Average Lien Amount"
      expr: AVG(lien_amount)
    - name: "Total Purchase Price"
      expr: SUM(purchase_price)
    - name: "Average Purchase Price"
      expr: AVG(purchase_price)
    - name: "Total Fee Amount"
      expr: SUM(fee_amount)
    - name: "Average Fee Amount"
      expr: AVG(fee_amount)
    - name: "Total Highway Use Tax Amount"
      expr: SUM(highway_use_tax_amount)
    - name: "Average Highway Use Tax Amount"
      expr: AVG(highway_use_tax_amount)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_vehicle`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Vehicle business metrics"
  source: "`feip_eastus_03`.`dmv`.`vehicle`"
  dimensions:
    - name: "Vin"
      expr: vin
    - name: "Make"
      expr: make
    - name: "Model"
      expr: model
    - name: "Model Year"
      expr: model_year
    - name: "Body Type"
      expr: body_type
    - name: "Class"
      expr: class
    - name: "Fuel Type"
      expr: fuel_type
    - name: "Engine Type"
      expr: engine_type
    - name: "Cylinder Count"
      expr: cylinder_count
    - name: "Transmission Type"
      expr: transmission_type
    - name: "Drive Type"
      expr: drive_type
    - name: "Color Primary"
      expr: color_primary
    - name: "Color Secondary"
      expr: color_secondary
    - name: "Gross Vehicle Weight Rating Lbs"
      expr: gross_vehicle_weight_rating_lbs
    - name: "Curb Weight Lbs"
      expr: curb_weight_lbs
    - name: "Seating Capacity"
      expr: seating_capacity
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Vehicle"
      expr: COUNT(DISTINCT vehicle_id)
    - name: "Total Engine Displacement Liters"
      expr: SUM(engine_displacement_liters)
    - name: "Average Engine Displacement Liters"
      expr: AVG(engine_displacement_liters)
    - name: "Total Purchase Price Amount"
      expr: SUM(purchase_price_amount)
    - name: "Average Purchase Price Amount"
      expr: AVG(purchase_price_amount)
    - name: "Total Assessed Value Amount"
      expr: SUM(assessed_value_amount)
    - name: "Average Assessed Value Amount"
      expr: AVG(assessed_value_amount)
    - name: "Total Highway Use Tax Amount"
      expr: SUM(highway_use_tax_amount)
    - name: "Average Highway Use Tax Amount"
      expr: AVG(highway_use_tax_amount)
    - name: "Total Registration Fee Amount"
      expr: SUM(registration_fee_amount)
    - name: "Average Registration Fee Amount"
      expr: AVG(registration_fee_amount)
    - name: "Total Msrp Amount"
      expr: SUM(msrp_amount)
    - name: "Average Msrp Amount"
      expr: AVG(msrp_amount)
    - name: "Total Bed Length Inches"
      expr: SUM(bed_length_inches)
    - name: "Average Bed Length Inches"
      expr: AVG(bed_length_inches)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_vehicle_class`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Vehicle Class business metrics"
  source: "`feip_eastus_03`.`dmv`.`vehicle_class`"
  dimensions:
    - name: "Class Code"
      expr: class_code
    - name: "Class Name"
      expr: class_name
    - name: "Class Description"
      expr: class_description
    - name: "Class Category"
      expr: class_category
    - name: "Fhwa Vehicle Type"
      expr: fhwa_vehicle_type
    - name: "Weight Class"
      expr: weight_class
    - name: "Minimum Weight Lbs"
      expr: minimum_weight_lbs
    - name: "Maximum Weight Lbs"
      expr: maximum_weight_lbs
    - name: "Requires Cdl"
      expr: requires_cdl
    - name: "Cdl Class Required"
      expr: cdl_class_required
    - name: "Requires Inspection"
      expr: requires_inspection
    - name: "Inspection Frequency Months"
      expr: inspection_frequency_months
    - name: "Requires Emissions Test"
      expr: requires_emissions_test
    - name: "Plate Type"
      expr: plate_type
    - name: "Registration Period Months"
      expr: registration_period_months
    - name: "Is Commercial"
      expr: is_commercial
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Vehicle Class"
      expr: COUNT(DISTINCT vehicle_id)
    - name: "Total Registration Fee Amount"
      expr: SUM(registration_fee_amount)
    - name: "Average Registration Fee Amount"
      expr: AVG(registration_fee_amount)
    - name: "Total Title Fee Amount"
      expr: SUM(title_fee_amount)
    - name: "Average Title Fee Amount"
      expr: AVG(title_fee_amount)
    - name: "Total Plate Fee Amount"
      expr: SUM(plate_fee_amount)
    - name: "Average Plate Fee Amount"
      expr: AVG(plate_fee_amount)
    - name: "Total Highway Use Tax Rate"
      expr: SUM(highway_use_tax_rate)
    - name: "Average Highway Use Tax Rate"
      expr: AVG(highway_use_tax_rate)
    - name: "Total Minimum Insurance Amount"
      expr: SUM(minimum_insurance_amount)
    - name: "Average Minimum Insurance Amount"
      expr: AVG(minimum_insurance_amount)
    - name: "Total Property Tax Rate"
      expr: SUM(property_tax_rate)
    - name: "Average Property Tax Rate"
      expr: AVG(property_tax_rate)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_vehicle_crash_involvement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Vehicle Crash Involvement business metrics"
  source: "`feip_eastus_03`.`dmv`.`vehicle_crash_involvement`"
  dimensions:
    - name: "Vehicle Role"
      expr: vehicle_role
    - name: "Damage Severity"
      expr: damage_severity
    - name: "Towed Indicator"
      expr: towed_indicator
    - name: "Occupant Count"
      expr: occupant_count
    - name: "Vehicle Sequence"
      expr: vehicle_sequence
    - name: "Pre Crash Action"
      expr: pre_crash_action
    - name: "Point Of Impact"
      expr: point_of_impact
    - name: "Contributing Factor"
      expr: contributing_factor
    - name: "Recorded Timestamp"
      expr: recorded_timestamp
    - name: "Recorded Timestamp Month"
      expr: DATE_TRUNC('MONTH', recorded_timestamp)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Vehicle Crash Involvement"
      expr: COUNT(DISTINCT vehicle_crash_involvement_id)
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`dmv_violation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Violation business metrics"
  source: "`feip_eastus_03`.`dmv`.`violation`"
  dimensions:
    - name: "Citation Number"
      expr: citation_number
    - name: "Driver License Number"
      expr: driver_license_number
    - name: "Driver Name"
      expr: driver_name
    - name: "Driver Address"
      expr: driver_address
    - name: "Driver City"
      expr: driver_city
    - name: "Driver State"
      expr: driver_state
    - name: "Driver Zip Code"
      expr: driver_zip_code
    - name: "Driver Date Of Birth"
      expr: driver_date_of_birth
    - name: "Time"
      expr: time
    - name: "Location Description"
      expr: location_description
    - name: "Street Address"
      expr: street_address
    - name: "City"
      expr: city
    - name: "County"
      expr: county
    - name: "State"
      expr: state
    - name: "Zip Code"
      expr: zip_code
    - name: "Route Number"
      expr: route_number
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Violation"
      expr: COUNT(DISTINCT violation_id)
    - name: "Total Latitude"
      expr: SUM(latitude)
    - name: "Average Latitude"
      expr: AVG(latitude)
    - name: "Total Longitude"
      expr: SUM(longitude)
    - name: "Average Longitude"
      expr: AVG(longitude)
    - name: "Total Mile Marker"
      expr: SUM(mile_marker)
    - name: "Average Mile Marker"
      expr: AVG(mile_marker)
    - name: "Total Fine Amount"
      expr: SUM(fine_amount)
    - name: "Average Fine Amount"
      expr: AVG(fine_amount)
    - name: "Total Court Costs"
      expr: SUM(court_costs)
    - name: "Average Court Costs"
      expr: AVG(court_costs)
    - name: "Total Total Amount Due"
      expr: SUM(total_amount_due)
    - name: "Average Total Amount Due"
      expr: AVG(total_amount_due)
    - name: "Total Amount Paid"
      expr: SUM(amount_paid)
    - name: "Average Amount Paid"
      expr: AVG(amount_paid)
$$;