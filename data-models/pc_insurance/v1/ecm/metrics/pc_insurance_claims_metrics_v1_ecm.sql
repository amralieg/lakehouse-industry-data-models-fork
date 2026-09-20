-- Metric views for domain: claims | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_adjuster`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Adjuster business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`adjuster`"
  dimensions:
    - name: "Adjuster Status"
      expr: adjuster_status
    - name: "Adjuster Type"
      expr: adjuster_type
    - name: "Background Check Date"
      expr: background_check_date
    - name: "Background Check Status"
      expr: background_check_status
    - name: "Catastrophe Qualified Flag"
      expr: catastrophe_qualified_flag
    - name: "Certification Designations"
      expr: certification_designations
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Field Adjuster Flag"
      expr: field_adjuster_flag
    - name: "Hire Date"
      expr: hire_date
    - name: "Home Office Location"
      expr: home_office_location
    - name: "Language Skills"
      expr: language_skills
    - name: "Last Performance Review Date"
      expr: last_performance_review_date
    - name: "Last Updated Timestamp"
      expr: last_updated_timestamp
    - name: "License Expiration Date"
      expr: license_expiration_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Adjuster"
      expr: COUNT(DISTINCT adjuster_id)
    - name: "Total Current Caseload Count"
      expr: SUM(current_caseload_count)
    - name: "Average Current Caseload Count"
      expr: AVG(current_caseload_count)
    - name: "Total Max Caseload Capacity"
      expr: SUM(max_caseload_capacity)
    - name: "Average Max Caseload Capacity"
      expr: AVG(max_caseload_capacity)
    - name: "Total Max Claim Authority"
      expr: SUM(max_claim_authority)
    - name: "Average Max Claim Authority"
      expr: AVG(max_claim_authority)
    - name: "Total Years Experience"
      expr: SUM(years_experience)
    - name: "Average Years Experience"
      expr: AVG(years_experience)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_adjuster_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Adjuster Assignment business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment`"
  dimensions:
    - name: "Assigned By User Code"
      expr: assigned_by_user_code
    - name: "Assignment Authority Level"
      expr: assignment_authority_level
    - name: "Assignment Date"
      expr: assignment_date
    - name: "Assignment Method"
      expr: assignment_method
    - name: "Assignment Notes"
      expr: assignment_notes
    - name: "Assignment Number"
      expr: assignment_number
    - name: "Assignment Role"
      expr: assignment_role
    - name: "Assignment Source System"
      expr: assignment_source_system
    - name: "Assignment Source System Code"
      expr: assignment_source_system_code
    - name: "Assignment Status"
      expr: assignment_status
    - name: "Assignment Timestamp"
      expr: assignment_timestamp
    - name: "Assignment Type"
      expr: assignment_type
    - name: "Completion Date"
      expr: completion_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Expected Completion Date"
      expr: expected_completion_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Adjuster Assignment"
      expr: COUNT(DISTINCT adjuster_assignment_id)
    - name: "Total Reserve Authority Limit"
      expr: SUM(reserve_authority_limit)
    - name: "Average Reserve Authority Limit"
      expr: AVG(reserve_authority_limit)
    - name: "Total Service Level Agreement Days"
      expr: SUM(service_level_agreement_days)
    - name: "Average Service Level Agreement Days"
      expr: AVG(service_level_agreement_days)
    - name: "Total Settlement Authority Limit"
      expr: SUM(settlement_authority_limit)
    - name: "Average Settlement Authority Limit"
      expr: AVG(settlement_authority_limit)
    - name: "Total Workload At Assignment"
      expr: SUM(workload_at_assignment)
    - name: "Average Workload At Assignment"
      expr: AVG(workload_at_assignment)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claim`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claim`"
  dimensions:
    - name: "Adjuster Type"
      expr: adjuster_type
    - name: "Catastrophe Flag"
      expr: catastrophe_flag
    - name: "Claim Status"
      expr: claim_status
    - name: "Claimant Type"
      expr: claimant_type
    - name: "Close Date"
      expr: close_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Fnol Date"
      expr: fnol_date
    - name: "Fnol Timestamp"
      expr: fnol_timestamp
    - name: "Iso Cat Serial Number"
      expr: iso_cat_serial_number
    - name: "Litigation Date"
      expr: litigation_date
    - name: "Litigation Flag"
      expr: litigation_flag
    - name: "Lob Description"
      expr: lob_description
    - name: "Loss Date"
      expr: loss_date
    - name: "Loss Description"
      expr: loss_description
    - name: "Loss Location Address"
      expr: loss_location_address
    - name: "Loss Location City"
      expr: loss_location_city
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim"
      expr: COUNT(DISTINCT claim_id)
    - name: "Total Accident Year"
      expr: SUM(accident_year)
    - name: "Average Accident Year"
      expr: AVG(accident_year)
    - name: "Total Policy Year"
      expr: SUM(policy_year)
    - name: "Average Policy Year"
      expr: AVG(policy_year)
    - name: "Total Report Year"
      expr: SUM(report_year)
    - name: "Average Report Year"
      expr: AVG(report_year)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claim_document`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Document business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claim_document`"
  dimensions:
    - name: "Access Level"
      expr: access_level
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Document Category"
      expr: document_category
    - name: "Document Date"
      expr: document_date
    - name: "Document Description"
      expr: document_description
    - name: "Document Number"
      expr: document_number
    - name: "Document Status"
      expr: document_status
    - name: "Document Title"
      expr: document_title
    - name: "Document Type"
      expr: document_type
    - name: "File Format"
      expr: file_format
    - name: "File Name"
      expr: file_name
    - name: "Is Confidential"
      expr: is_confidential
    - name: "Is Required"
      expr: is_required
    - name: "Is Verified"
      expr: is_verified
    - name: "Notes"
      expr: notes
    - name: "Received Date"
      expr: received_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim Document"
      expr: COUNT(DISTINCT claim_document_id)
    - name: "Total File Size Bytes"
      expr: SUM(file_size_bytes)
    - name: "Average File Size Bytes"
      expr: AVG(file_size_bytes)
    - name: "Total Page Count"
      expr: SUM(page_count)
    - name: "Average Page Count"
      expr: AVG(page_count)
    - name: "Total Retention Period Years"
      expr: SUM(retention_period_years)
    - name: "Average Retention Period Years"
      expr: AVG(retention_period_years)
    - name: "Total Reviewed By User Code"
      expr: SUM(reviewed_by_user_code)
    - name: "Average Reviewed By User Code"
      expr: AVG(reviewed_by_user_code)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claim_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Exposure business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`"
  dimensions:
    - name: "Catastrophe Flag"
      expr: catastrophe_flag
    - name: "Claim Party Role"
      expr: claim_party_role
    - name: "Closed Date"
      expr: closed_date
    - name: "Coverage Type"
      expr: coverage_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Denial Reason"
      expr: denial_reason
    - name: "Exposure Description"
      expr: exposure_description
    - name: "Exposure Number"
      expr: exposure_number
    - name: "Exposure Status"
      expr: exposure_status
    - name: "Fraud Flag"
      expr: fraud_flag
    - name: "Liability Indicator"
      expr: liability_indicator
    - name: "Litigation Flag"
      expr: litigation_flag
    - name: "Loss Cause"
      expr: loss_cause
    - name: "Loss Date"
      expr: loss_date
    - name: "Reinsurance Ceded Flag"
      expr: reinsurance_ceded_flag
    - name: "Reopened Date"
      expr: reopened_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim Exposure"
      expr: COUNT(DISTINCT claim_exposure_id)
    - name: "Total Accident Year"
      expr: SUM(accident_year)
    - name: "Average Accident Year"
      expr: AVG(accident_year)
    - name: "Total Coverage Limit Amount"
      expr: SUM(coverage_limit_amount)
    - name: "Average Coverage Limit Amount"
      expr: AVG(coverage_limit_amount)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Incurred Amount"
      expr: SUM(incurred_amount)
    - name: "Average Incurred Amount"
      expr: AVG(incurred_amount)
    - name: "Total Lae Paid Amount"
      expr: SUM(lae_paid_amount)
    - name: "Average Lae Paid Amount"
      expr: AVG(lae_paid_amount)
    - name: "Total Lae Reserve Amount"
      expr: SUM(lae_reserve_amount)
    - name: "Average Lae Reserve Amount"
      expr: AVG(lae_reserve_amount)
    - name: "Total Outstanding Reserve Amount"
      expr: SUM(outstanding_reserve_amount)
    - name: "Average Outstanding Reserve Amount"
      expr: AVG(outstanding_reserve_amount)
    - name: "Total Paid Amount"
      expr: SUM(paid_amount)
    - name: "Average Paid Amount"
      expr: AVG(paid_amount)
    - name: "Total Recovery Amount"
      expr: SUM(recovery_amount)
    - name: "Average Recovery Amount"
      expr: AVG(recovery_amount)
    - name: "Total Report Year"
      expr: SUM(report_year)
    - name: "Average Report Year"
      expr: AVG(report_year)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claim_note`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Note business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claim_note`"
  dimensions:
    - name: "Activity Code"
      expr: activity_code
    - name: "Attorney Client Privilege Flag"
      expr: attorney_client_privilege_flag
    - name: "Author Name"
      expr: author_name
    - name: "Author Role"
      expr: author_role
    - name: "Confidential Flag"
      expr: confidential_flag
    - name: "Coverage Analysis Flag"
      expr: coverage_analysis_flag
    - name: "Diary Completed Flag"
      expr: diary_completed_flag
    - name: "Diary Completed Timestamp"
      expr: diary_completed_timestamp
    - name: "Diary Due Date"
      expr: diary_due_date
    - name: "Diary Flag"
      expr: diary_flag
    - name: "Entry Timestamp"
      expr: entry_timestamp
    - name: "External Communication Flag"
      expr: external_communication_flag
    - name: "Fraud Indicator Flag"
      expr: fraud_indicator_flag
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Liability Analysis Flag"
      expr: liability_analysis_flag
    - name: "Loss Description Flag"
      expr: loss_description_flag
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim Note"
      expr: COUNT(DISTINCT claim_note_id)
    - name: "Total Sequence Number"
      expr: SUM(sequence_number)
    - name: "Average Sequence Number"
      expr: AVG(sequence_number)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claim_status`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Status business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claim_status`"
  dimensions:
    - name: "Approval Required Flag"
      expr: approval_required_flag
    - name: "Approval Timestamp"
      expr: approval_timestamp
    - name: "Approved By User Code"
      expr: approved_by_user_code
    - name: "Approved By User Name"
      expr: approved_by_user_name
    - name: "Cat Serial Number"
      expr: cat_serial_number
    - name: "Catastrophe Flag"
      expr: catastrophe_flag
    - name: "Closure Type Code"
      expr: closure_type_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Timestamp"
      expr: effective_timestamp
    - name: "Expiration Timestamp"
      expr: expiration_timestamp
    - name: "Fraud Investigation Flag"
      expr: fraud_investigation_flag
    - name: "Is Current Status"
      expr: is_current_status
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Litigation Flag"
      expr: litigation_flag
    - name: "Litigation Start Date"
      expr: litigation_start_date
    - name: "Previous Status Code"
      expr: previous_status_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim Status"
      expr: COUNT(DISTINCT claim_status_id)
    - name: "Total Incurred Amount"
      expr: SUM(incurred_amount)
    - name: "Average Incurred Amount"
      expr: AVG(incurred_amount)
    - name: "Total Paid Amount"
      expr: SUM(paid_amount)
    - name: "Average Paid Amount"
      expr: AVG(paid_amount)
    - name: "Total Reopen Count"
      expr: SUM(reopen_count)
    - name: "Average Reopen Count"
      expr: AVG(reopen_count)
    - name: "Total Reserve Amount"
      expr: SUM(reserve_amount)
    - name: "Average Reserve Amount"
      expr: AVG(reserve_amount)
    - name: "Total Status Duration Days"
      expr: SUM(status_duration_days)
    - name: "Average Status Duration Days"
      expr: AVG(status_duration_days)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claimant`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claimant business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claimant`"
  dimensions:
    - name: "Attorney Contact Email"
      expr: attorney_contact_email
    - name: "Attorney Contact Phone"
      expr: attorney_contact_phone
    - name: "Attorney Name"
      expr: attorney_name
    - name: "Claimant Status"
      expr: claimant_status
    - name: "Claimant Type"
      expr: claimant_type
    - name: "Contact Preference"
      expr: contact_preference
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Date Of Death"
      expr: date_of_death
    - name: "Date Of Injury"
      expr: date_of_injury
    - name: "Fault Indicator"
      expr: fault_indicator
    - name: "Fraud Indicator Flag"
      expr: fraud_indicator_flag
    - name: "Guardian Contact Phone"
      expr: guardian_contact_phone
    - name: "Guardian Name"
      expr: guardian_name
    - name: "Hospital Name"
      expr: hospital_name
    - name: "Hospitalization Flag"
      expr: hospitalization_flag
    - name: "Injury Description"
      expr: injury_description
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claimant"
      expr: COUNT(DISTINCT claimant_id)
    - name: "Total Liability Percentage"
      expr: SUM(liability_percentage)
    - name: "Average Liability Percentage"
      expr: AVG(liability_percentage)
    - name: "Total Settlement Demand Amount"
      expr: SUM(settlement_demand_amount)
    - name: "Average Settlement Demand Amount"
      expr: AVG(settlement_demand_amount)
    - name: "Total Settlement Offer Amount"
      expr: SUM(settlement_offer_amount)
    - name: "Average Settlement Offer Amount"
      expr: AVG(settlement_offer_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_fnol`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fnol business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`fnol`"
  dimensions:
    - name: "Cat Event Flag"
      expr: cat_event_flag
    - name: "Claim Opened Flag"
      expr: claim_opened_flag
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Fatality Flag"
      expr: fatality_flag
    - name: "Fnol Status"
      expr: fnol_status
    - name: "Fraud Indicator Flag"
      expr: fraud_indicator_flag
    - name: "Injury Flag"
      expr: injury_flag
    - name: "Iso Cat Serial Number"
      expr: iso_cat_serial_number
    - name: "Lob"
      expr: lob
    - name: "Loss Cause"
      expr: loss_cause
    - name: "Loss Date"
      expr: loss_date
    - name: "Loss Description"
      expr: loss_description
    - name: "Loss Location Address"
      expr: loss_location_address
    - name: "Loss Location City"
      expr: loss_location_city
    - name: "Loss Location Country"
      expr: loss_location_country
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Fnol"
      expr: COUNT(DISTINCT fnol_id)
    - name: "Total Estimated Loss Amount"
      expr: SUM(estimated_loss_amount)
    - name: "Average Estimated Loss Amount"
      expr: AVG(estimated_loss_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_litigation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Litigation business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`litigation`"
  dimensions:
    - name: "Appeal Date"
      expr: appeal_date
    - name: "Appeal Filed Flag"
      expr: appeal_filed_flag
    - name: "Cause Of Action"
      expr: cause_of_action
    - name: "Closure Date"
      expr: closure_date
    - name: "Confidentiality Flag"
      expr: confidentiality_flag
    - name: "Court Jurisdiction"
      expr: court_jurisdiction
    - name: "Court Type"
      expr: court_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Dismissal Date"
      expr: dismissal_date
    - name: "Dismissal Reason"
      expr: dismissal_reason
    - name: "Filing Date"
      expr: filing_date
    - name: "Lawsuit Number"
      expr: lawsuit_number
    - name: "Litigation Status"
      expr: litigation_status
    - name: "Litigation Type"
      expr: litigation_type
    - name: "Mediation Date"
      expr: mediation_date
    - name: "Notes"
      expr: notes
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Litigation"
      expr: COUNT(DISTINCT litigation_id)
    - name: "Total Defense Cost Incurred"
      expr: SUM(defense_cost_incurred)
    - name: "Average Defense Cost Incurred"
      expr: AVG(defense_cost_incurred)
    - name: "Total Demand Amount"
      expr: SUM(demand_amount)
    - name: "Average Demand Amount"
      expr: AVG(demand_amount)
    - name: "Total Reserve Amount"
      expr: SUM(reserve_amount)
    - name: "Average Reserve Amount"
      expr: AVG(reserve_amount)
    - name: "Total Settlement Amount"
      expr: SUM(settlement_amount)
    - name: "Average Settlement Amount"
      expr: AVG(settlement_amount)
    - name: "Total Verdict Amount"
      expr: SUM(verdict_amount)
    - name: "Average Verdict Amount"
      expr: AVG(verdict_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_loss_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Loss Event business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`loss_event`"
  dimensions:
    - name: "Cat Serial Number"
      expr: cat_serial_number
    - name: "Closed Date"
      expr: closed_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Fatality Occurred"
      expr: fatality_occurred
    - name: "Fire Department Notified"
      expr: fire_department_notified
    - name: "Fire Report Number"
      expr: fire_report_number
    - name: "Fraud Indicator"
      expr: fraud_indicator
    - name: "Injury Occurred"
      expr: injury_occurred
    - name: "Is Catastrophe Loss"
      expr: is_catastrophe_loss
    - name: "Is Large Loss"
      expr: is_large_loss
    - name: "Loss Complexity Code"
      expr: loss_complexity_code
    - name: "Loss Description"
      expr: loss_description
    - name: "Loss Discovery Date"
      expr: loss_discovery_date
    - name: "Loss Event Status"
      expr: loss_event_status
    - name: "Loss Event Type"
      expr: loss_event_type
    - name: "Loss Location Address"
      expr: loss_location_address
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Loss Event"
      expr: COUNT(DISTINCT loss_event_id)
    - name: "Total Estimated Total Loss Amount"
      expr: SUM(estimated_total_loss_amount)
    - name: "Average Estimated Total Loss Amount"
      expr: AVG(estimated_total_loss_amount)
    - name: "Total Large Loss Threshold Amount"
      expr: SUM(large_loss_threshold_amount)
    - name: "Average Large Loss Threshold Amount"
      expr: AVG(large_loss_threshold_amount)
    - name: "Total Loss Location Latitude"
      expr: SUM(loss_location_latitude)
    - name: "Average Loss Location Latitude"
      expr: AVG(loss_location_latitude)
    - name: "Total Loss Location Longitude"
      expr: SUM(loss_location_longitude)
    - name: "Average Loss Location Longitude"
      expr: AVG(loss_location_longitude)
    - name: "Total Number Of Fatalities"
      expr: SUM(number_of_fatalities)
    - name: "Average Number Of Fatalities"
      expr: AVG(number_of_fatalities)
    - name: "Total Number Of Injuries"
      expr: SUM(number_of_injuries)
    - name: "Average Number Of Injuries"
      expr: AVG(number_of_injuries)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_medical_bill`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Medical Bill business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`medical_bill`"
  dimensions:
    - name: "Bill Date"
      expr: bill_date
    - name: "Bill Number"
      expr: bill_number
    - name: "Bill Received Date"
      expr: bill_received_date
    - name: "Bill Review Notes"
      expr: bill_review_notes
    - name: "Bill Review Outcome"
      expr: bill_review_outcome
    - name: "Bill Source"
      expr: bill_source
    - name: "Bill Status"
      expr: bill_status
    - name: "Bill Type"
      expr: bill_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Denial Reason Code"
      expr: denial_reason_code
    - name: "Denial Reason Description"
      expr: denial_reason_description
    - name: "Diagnosis Code Primary"
      expr: diagnosis_code_primary
    - name: "Diagnosis Code Secondary"
      expr: diagnosis_code_secondary
    - name: "Is Duplicate"
      expr: is_duplicate
    - name: "Patient Dob"
      expr: patient_dob
    - name: "Patient Name"
      expr: patient_name
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Medical Bill"
      expr: COUNT(DISTINCT medical_bill_id)
    - name: "Total Allowed Amount"
      expr: SUM(allowed_amount)
    - name: "Average Allowed Amount"
      expr: AVG(allowed_amount)
    - name: "Total Billed Amount"
      expr: SUM(billed_amount)
    - name: "Average Billed Amount"
      expr: AVG(billed_amount)
    - name: "Total Coinsurance Amount"
      expr: SUM(coinsurance_amount)
    - name: "Average Coinsurance Amount"
      expr: AVG(coinsurance_amount)
    - name: "Total Copay Amount"
      expr: SUM(copay_amount)
    - name: "Average Copay Amount"
      expr: AVG(copay_amount)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Paid Amount"
      expr: SUM(paid_amount)
    - name: "Average Paid Amount"
      expr: AVG(paid_amount)
    - name: "Total Reduction Amount"
      expr: SUM(reduction_amount)
    - name: "Average Reduction Amount"
      expr: AVG(reduction_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_repair_estimate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Repair Estimate business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`repair_estimate`"
  dimensions:
    - name: "Approval Date"
      expr: approval_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Damage Description"
      expr: damage_description
    - name: "Document Reference"
      expr: document_reference
    - name: "Estimate Date"
      expr: estimate_date
    - name: "Estimate Method"
      expr: estimate_method
    - name: "Estimate Notes"
      expr: estimate_notes
    - name: "Estimate Number"
      expr: estimate_number
    - name: "Estimate Status"
      expr: estimate_status
    - name: "Estimate Type"
      expr: estimate_type
    - name: "Estimating Software"
      expr: estimating_software
    - name: "Estimator Type"
      expr: estimator_type
    - name: "Inspection Date"
      expr: inspection_date
    - name: "Parts Source"
      expr: parts_source
    - name: "Repair Facility Address"
      expr: repair_facility_address
    - name: "Repair Facility Name"
      expr: repair_facility_name
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Repair Estimate"
      expr: COUNT(DISTINCT repair_estimate_id)
    - name: "Total Agreed Amount"
      expr: SUM(agreed_amount)
    - name: "Average Agreed Amount"
      expr: AVG(agreed_amount)
    - name: "Total Betterment Amount"
      expr: SUM(betterment_amount)
    - name: "Average Betterment Amount"
      expr: AVG(betterment_amount)
    - name: "Total Deductible Applied Amount"
      expr: SUM(deductible_applied_amount)
    - name: "Average Deductible Applied Amount"
      expr: AVG(deductible_applied_amount)
    - name: "Total Depreciation Amount"
      expr: SUM(depreciation_amount)
    - name: "Average Depreciation Amount"
      expr: AVG(depreciation_amount)
    - name: "Total Labor Cost Amount"
      expr: SUM(labor_cost_amount)
    - name: "Average Labor Cost Amount"
      expr: AVG(labor_cost_amount)
    - name: "Total Labor Hours"
      expr: SUM(labor_hours)
    - name: "Average Labor Hours"
      expr: AVG(labor_hours)
    - name: "Total Labor Rate Per Hour"
      expr: SUM(labor_rate_per_hour)
    - name: "Average Labor Rate Per Hour"
      expr: AVG(labor_rate_per_hour)
    - name: "Total Net Payable Amount"
      expr: SUM(net_payable_amount)
    - name: "Average Net Payable Amount"
      expr: AVG(net_payable_amount)
    - name: "Total Paint Materials Cost Amount"
      expr: SUM(paint_materials_cost_amount)
    - name: "Average Paint Materials Cost Amount"
      expr: AVG(paint_materials_cost_amount)
    - name: "Total Parts Cost Amount"
      expr: SUM(parts_cost_amount)
    - name: "Average Parts Cost Amount"
      expr: AVG(parts_cost_amount)
    - name: "Total Photo Count"
      expr: SUM(photo_count)
    - name: "Average Photo Count"
      expr: AVG(photo_count)
    - name: "Total Sublet Cost Amount"
      expr: SUM(sublet_cost_amount)
    - name: "Average Sublet Cost Amount"
      expr: AVG(sublet_cost_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_salvage_disposition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Salvage Disposition business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`salvage_disposition`"
  dimensions:
    - name: "Abandonment Reason"
      expr: abandonment_reason
    - name: "Buyer Name"
      expr: buyer_name
    - name: "Closed Date"
      expr: closed_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Disposition Notes"
      expr: disposition_notes
    - name: "Disposition Number"
      expr: disposition_number
    - name: "Disposition Status"
      expr: disposition_status
    - name: "Litigation Filed Date"
      expr: litigation_filed_date
    - name: "Litigation Status"
      expr: litigation_status
    - name: "Opened Date"
      expr: opened_date
    - name: "Recovery Type"
      expr: recovery_type
    - name: "Sale Date"
      expr: sale_date
    - name: "Sale Method"
      expr: sale_method
    - name: "Salvage Item Description"
      expr: salvage_item_description
    - name: "Salvage Item Type"
      expr: salvage_item_type
    - name: "Settlement Date"
      expr: settlement_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Salvage Disposition"
      expr: COUNT(DISTINCT salvage_disposition_id)
    - name: "Total Actual Salvage Value"
      expr: SUM(actual_salvage_value)
    - name: "Average Actual Salvage Value"
      expr: AVG(actual_salvage_value)
    - name: "Total Estimated Salvage Value"
      expr: SUM(estimated_salvage_value)
    - name: "Average Estimated Salvage Value"
      expr: AVG(estimated_salvage_value)
    - name: "Total Net Recovery Amount"
      expr: SUM(net_recovery_amount)
    - name: "Average Net Recovery Amount"
      expr: AVG(net_recovery_amount)
    - name: "Total Recovery Expenses"
      expr: SUM(recovery_expenses)
    - name: "Average Recovery Expenses"
      expr: AVG(recovery_expenses)
    - name: "Total Subrogation Demand Amount"
      expr: SUM(subrogation_demand_amount)
    - name: "Average Subrogation Demand Amount"
      expr: AVG(subrogation_demand_amount)
    - name: "Total Subrogation Recovered Amount"
      expr: SUM(subrogation_recovered_amount)
    - name: "Average Subrogation Recovered Amount"
      expr: AVG(subrogation_recovered_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_siu_referral`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Siu Referral business metrics"
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`siu_referral`"
  dimensions:
    - name: "Assignment Date"
      expr: assignment_date
    - name: "Case Number"
      expr: case_number
    - name: "Clue Report Ordered Flag"
      expr: clue_report_ordered_flag
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Disposition"
      expr: disposition
    - name: "Evidence Summary"
      expr: evidence_summary
    - name: "External Database Check Flag"
      expr: external_database_check_flag
    - name: "Fraud Indicator Code"
      expr: fraud_indicator_code
    - name: "Fraud Indicator Description"
      expr: fraud_indicator_description
    - name: "Fraud Scheme Category"
      expr: fraud_scheme_category
    - name: "Fraud Type"
      expr: fraud_type
    - name: "Investigation Close Date"
      expr: investigation_close_date
    - name: "Investigation Notes"
      expr: investigation_notes
    - name: "Investigation Outcome"
      expr: investigation_outcome
    - name: "Investigation Start Date"
      expr: investigation_start_date
    - name: "Iso Claim Search Flag"
      expr: iso_claim_search_flag
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Siu Referral"
      expr: COUNT(DISTINCT siu_referral_id)
    - name: "Total Confirmed Fraud Amount"
      expr: SUM(confirmed_fraud_amount)
    - name: "Average Confirmed Fraud Amount"
      expr: AVG(confirmed_fraud_amount)
    - name: "Total Estimated Fraud Amount"
      expr: SUM(estimated_fraud_amount)
    - name: "Average Estimated Fraud Amount"
      expr: AVG(estimated_fraud_amount)
    - name: "Total Savings Amount"
      expr: SUM(savings_amount)
    - name: "Average Savings Amount"
      expr: AVG(savings_amount)
$$;