-- Metric views for domain: claims | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_adjuster`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Adjuster business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`adjuster`"
  dimensions:
    - name: "Adjuster Type"
      expr: adjuster_type
    - name: "Background Check Date"
      expr: background_check_date
    - name: "Background Check Status"
      expr: background_check_status
    - name: "Ce Due Date"
      expr: ce_due_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Email Address"
      expr: email_address
    - name: "Employment Status"
      expr: employment_status
    - name: "Eo Expiration Date"
      expr: eo_expiration_date
    - name: "Eo Insurance Carrier"
      expr: eo_insurance_carrier
    - name: "Eo Policy Number"
      expr: eo_policy_number
    - name: "Fein"
      expr: fein
    - name: "First Name"
      expr: first_name
    - name: "Hire Date"
      expr: hire_date
    - name: "Home Office Location"
      expr: home_office_location
    - name: "Last Name"
      expr: last_name
    - name: "License Expiration Date"
      expr: license_expiration_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Adjuster"
      expr: COUNT(DISTINCT adjuster_id)
    - name: "Total Continuing Education Hours"
      expr: SUM(continuing_education_hours)
    - name: "Average Continuing Education Hours"
      expr: AVG(continuing_education_hours)
    - name: "Total Current Workload Count"
      expr: SUM(current_workload_count)
    - name: "Average Current Workload Count"
      expr: AVG(current_workload_count)
    - name: "Total Max Workload Capacity"
      expr: SUM(max_workload_capacity)
    - name: "Average Max Workload Capacity"
      expr: AVG(max_workload_capacity)
    - name: "Total Reserve Authority Limit"
      expr: SUM(reserve_authority_limit)
    - name: "Average Reserve Authority Limit"
      expr: AVG(reserve_authority_limit)
    - name: "Total Settlement Authority Limit"
      expr: SUM(settlement_authority_limit)
    - name: "Average Settlement Authority Limit"
      expr: AVG(settlement_authority_limit)
    - name: "Total Years Of Experience"
      expr: SUM(years_of_experience)
    - name: "Average Years Of Experience"
      expr: AVG(years_of_experience)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_adjuster_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Adjuster Assignment business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`adjuster_assignment`"
  dimensions:
    - name: "Assigned By Name"
      expr: assigned_by_name
    - name: "Assignment Date"
      expr: assignment_date
    - name: "Assignment Method"
      expr: assignment_method
    - name: "Assignment Notes"
      expr: assignment_notes
    - name: "Assignment Number"
      expr: assignment_number
    - name: "Assignment Reason"
      expr: assignment_reason
    - name: "Assignment Role"
      expr: assignment_role
    - name: "Assignment Status"
      expr: assignment_status
    - name: "Assignment Timestamp"
      expr: assignment_timestamp
    - name: "Assignment Type"
      expr: assignment_type
    - name: "Cat Code"
      expr: cat_code
    - name: "Complexity Level"
      expr: complexity_level
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "End Date"
      expr: end_date
    - name: "End Reason"
      expr: end_reason
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Adjuster Assignment"
      expr: COUNT(DISTINCT adjuster_assignment_id)
    - name: "Total Actual Hours"
      expr: SUM(actual_hours)
    - name: "Average Actual Hours"
      expr: AVG(actual_hours)
    - name: "Total Assigned By User Code"
      expr: SUM(assigned_by_user_code)
    - name: "Average Assigned By User Code"
      expr: AVG(assigned_by_user_code)
    - name: "Total Estimated Hours"
      expr: SUM(estimated_hours)
    - name: "Average Estimated Hours"
      expr: AVG(estimated_hours)
    - name: "Total Modified By User Code"
      expr: SUM(modified_by_user_code)
    - name: "Average Modified By User Code"
      expr: AVG(modified_by_user_code)
    - name: "Total Sla Target Days"
      expr: SUM(sla_target_days)
    - name: "Average Sla Target Days"
      expr: AVG(sla_target_days)
    - name: "Total Workload Priority"
      expr: SUM(workload_priority)
    - name: "Average Workload Priority"
      expr: AVG(workload_priority)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_attorney`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Attorney business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`attorney`"
  dimensions:
    - name: "Address Line 1"
      expr: address_line_1
    - name: "Address Line 2"
      expr: address_line_2
    - name: "Attorney Type"
      expr: attorney_type
    - name: "Bar Admission Date"
      expr: bar_admission_date
    - name: "Bar Number"
      expr: bar_number
    - name: "Bar State"
      expr: bar_state
    - name: "City"
      expr: city
    - name: "Country Code"
      expr: country_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Email Address"
      expr: email_address
    - name: "Fax Number"
      expr: fax_number
    - name: "First Name"
      expr: first_name
    - name: "Full Name"
      expr: full_name
    - name: "Last Name"
      expr: last_name
    - name: "Law Firm Name"
      expr: law_firm_name
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Attorney"
      expr: COUNT(DISTINCT attorney_id)
    - name: "Total Hourly Rate"
      expr: SUM(hourly_rate)
    - name: "Average Hourly Rate"
      expr: AVG(hourly_rate)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claim`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claim`"
  dimensions:
    - name: "Cat Indicator"
      expr: cat_indicator
    - name: "Claim Status"
      expr: claim_status
    - name: "Claim Type"
      expr: claim_type
    - name: "Closed Date"
      expr: closed_date
    - name: "Closed Reason"
      expr: closed_reason
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Dol"
      expr: dol
    - name: "Fnol Date"
      expr: fnol_date
    - name: "Fnol Timestamp"
      expr: fnol_timestamp
    - name: "Fraud Indicator"
      expr: fraud_indicator
    - name: "Litigation Indicator"
      expr: litigation_indicator
    - name: "Loss Cause"
      expr: loss_cause
    - name: "Loss Description"
      expr: loss_description
    - name: "Loss Time"
      expr: loss_time
    - name: "Modified Timestamp"
      expr: modified_timestamp
    - name: "Number"
      expr: number
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim"
      expr: COUNT(DISTINCT claim_id)
    - name: "Total Alae Paid Amount"
      expr: SUM(alae_paid_amount)
    - name: "Average Alae Paid Amount"
      expr: AVG(alae_paid_amount)
    - name: "Total Alae Reserve Amount"
      expr: SUM(alae_reserve_amount)
    - name: "Average Alae Reserve Amount"
      expr: AVG(alae_reserve_amount)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Outstanding Reserve Amount"
      expr: SUM(outstanding_reserve_amount)
    - name: "Average Outstanding Reserve Amount"
      expr: AVG(outstanding_reserve_amount)
    - name: "Total Paid Loss Amount"
      expr: SUM(paid_loss_amount)
    - name: "Average Paid Loss Amount"
      expr: AVG(paid_loss_amount)
    - name: "Total Reopened Count"
      expr: SUM(reopened_count)
    - name: "Average Reopened Count"
      expr: AVG(reopened_count)
    - name: "Total Salvage Value Amount"
      expr: SUM(salvage_value_amount)
    - name: "Average Salvage Value Amount"
      expr: AVG(salvage_value_amount)
    - name: "Total Subrogation Potential Amount"
      expr: SUM(subrogation_potential_amount)
    - name: "Average Subrogation Potential Amount"
      expr: AVG(subrogation_potential_amount)
    - name: "Total Subrogation Recovered Amount"
      expr: SUM(subrogation_recovered_amount)
    - name: "Average Subrogation Recovered Amount"
      expr: AVG(subrogation_recovered_amount)
    - name: "Total Total Incurred Amount"
      expr: SUM(total_incurred_amount)
    - name: "Average Total Incurred Amount"
      expr: AVG(total_incurred_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claim_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Coverage business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claim_coverage`"
  dimensions:
    - name: "Coverage Basis"
      expr: coverage_basis
    - name: "Coverage Denial Reason Code"
      expr: coverage_denial_reason_code
    - name: "Coverage Denial Reason Description"
      expr: coverage_denial_reason_description
    - name: "Coverage Determination Date"
      expr: coverage_determination_date
    - name: "Coverage Notes"
      expr: coverage_notes
    - name: "Coverage Part"
      expr: coverage_part
    - name: "Coverage Status"
      expr: coverage_status
    - name: "Coverage Trigger Type"
      expr: coverage_trigger_type
    - name: "Created By User Code"
      expr: created_by_user_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deductible Satisfied Date"
      expr: deductible_satisfied_date
    - name: "Deductible Satisfied Flag"
      expr: deductible_satisfied_flag
    - name: "Exclusion Applied Flag"
      expr: exclusion_applied_flag
    - name: "Exclusion Code"
      expr: exclusion_code
    - name: "Loss Date"
      expr: loss_date
    - name: "Policy Effective Date"
      expr: policy_effective_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim Coverage"
      expr: COUNT(DISTINCT claim_coverage_id)
    - name: "Total Applicable Deductible Amount"
      expr: SUM(applicable_deductible_amount)
    - name: "Average Applicable Deductible Amount"
      expr: AVG(applicable_deductible_amount)
    - name: "Total Applicable Limit Amount"
      expr: SUM(applicable_limit_amount)
    - name: "Average Applicable Limit Amount"
      expr: AVG(applicable_limit_amount)
    - name: "Total Applicable Sir Amount"
      expr: SUM(applicable_sir_amount)
    - name: "Average Applicable Sir Amount"
      expr: AVG(applicable_sir_amount)
    - name: "Total Coinsurance Percentage"
      expr: SUM(coinsurance_percentage)
    - name: "Average Coinsurance Percentage"
      expr: AVG(coinsurance_percentage)
    - name: "Total Coverage Alae Amount"
      expr: SUM(coverage_alae_amount)
    - name: "Average Coverage Alae Amount"
      expr: AVG(coverage_alae_amount)
    - name: "Total Coverage Incurred Loss Amount"
      expr: SUM(coverage_incurred_loss_amount)
    - name: "Average Coverage Incurred Loss Amount"
      expr: AVG(coverage_incurred_loss_amount)
    - name: "Total Coverage Outstanding Reserve Amount"
      expr: SUM(coverage_outstanding_reserve_amount)
    - name: "Average Coverage Outstanding Reserve Amount"
      expr: AVG(coverage_outstanding_reserve_amount)
    - name: "Total Coverage Paid Loss Amount"
      expr: SUM(coverage_paid_loss_amount)
    - name: "Average Coverage Paid Loss Amount"
      expr: AVG(coverage_paid_loss_amount)
    - name: "Total Limit Erosion Amount"
      expr: SUM(limit_erosion_amount)
    - name: "Average Limit Erosion Amount"
      expr: AVG(limit_erosion_amount)
    - name: "Total Remaining Limit Amount"
      expr: SUM(remaining_limit_amount)
    - name: "Average Remaining Limit Amount"
      expr: AVG(remaining_limit_amount)
    - name: "Total Sublimit Amount"
      expr: SUM(sublimit_amount)
    - name: "Average Sublimit Amount"
      expr: AVG(sublimit_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claim_document`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Document business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claim_document`"
  dimensions:
    - name: "Approved By User Code"
      expr: approved_by_user_code
    - name: "Approved Date"
      expr: approved_date
    - name: "Approved Flag"
      expr: approved_flag
    - name: "Author Name"
      expr: author_name
    - name: "Author Organization"
      expr: author_organization
    - name: "Confidential Flag"
      expr: confidential_flag
    - name: "Description"
      expr: claim_document_description
    - name: "Document Date"
      expr: document_date
    - name: "Document Number"
      expr: document_number
    - name: "Document Status"
      expr: document_status
    - name: "Document Subtype"
      expr: document_subtype
    - name: "Document Type"
      expr: document_type
    - name: "Ecm Folder Path"
      expr: ecm_folder_path
    - name: "Ecm Repository"
      expr: ecm_repository
    - name: "File Extension"
      expr: file_extension
    - name: "File Name"
      expr: file_name
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
    - name: "Total Uploaded By Party Code"
      expr: SUM(uploaded_by_party_code)
    - name: "Average Uploaded By Party Code"
      expr: AVG(uploaded_by_party_code)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claim_note`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Note business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claim_note`"
  dimensions:
    - name: "Assigned To User Code"
      expr: assigned_to_user_code
    - name: "Author Name"
      expr: author_name
    - name: "Author User Code"
      expr: author_user_code
    - name: "Body Text"
      expr: body_text
    - name: "Confidential Flag"
      expr: confidential_flag
    - name: "Deleted By User Code"
      expr: deleted_by_user_code
    - name: "Deleted Date"
      expr: deleted_date
    - name: "Deleted Flag"
      expr: deleted_flag
    - name: "Editable Flag"
      expr: editable_flag
    - name: "External Reference Code"
      expr: external_reference_code
    - name: "Follow Up Date"
      expr: follow_up_date
    - name: "Follow Up Required Flag"
      expr: follow_up_required_flag
    - name: "Language Code"
      expr: language_code
    - name: "Last Modified By User Code"
      expr: last_modified_by_user_code
    - name: "Last Modified Timestamp"
      expr: last_modified_timestamp
    - name: "Litigation Flag"
      expr: litigation_flag
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim Note"
      expr: COUNT(DISTINCT claim_note_id)
    - name: "Total Activity Code"
      expr: SUM(activity_code)
    - name: "Average Activity Code"
      expr: AVG(activity_code)
    - name: "Total Attachment Count"
      expr: SUM(attachment_count)
    - name: "Average Attachment Count"
      expr: AVG(attachment_count)
    - name: "Total Related Party Code"
      expr: SUM(related_party_code)
    - name: "Average Related Party Code"
      expr: AVG(related_party_code)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claim_peril_causation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Peril Causation business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claim_peril_causation`"
  dimensions:
    - name: "Adjuster Notes"
      expr: adjuster_notes
    - name: "Claim Peril Causation Status"
      expr: claim_peril_causation_status
    - name: "Concurrent Causation Flag"
      expr: concurrent_causation_flag
    - name: "Coverage Applicable Flag"
      expr: coverage_applicable_flag
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Exclusion Applied Flag"
      expr: exclusion_applied_flag
    - name: "Exclusion Reason"
      expr: exclusion_reason
    - name: "Last Updated Timestamp"
      expr: last_updated_timestamp
    - name: "Loss Cause Determination Date"
      expr: loss_cause_determination_date
    - name: "Proximate Cause Flag"
      expr: proximate_cause_flag
    - name: "Subrogation Target Flag"
      expr: subrogation_target_flag
    - name: "Created Timestamp Month"
      expr: DATE_TRUNC('MONTH', created_timestamp)
    - name: "Last Updated Timestamp Month"
      expr: DATE_TRUNC('MONTH', last_updated_timestamp)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim Peril Causation"
      expr: COUNT(DISTINCT claim_peril_causation_id)
    - name: "Total Causation Sequence Order"
      expr: SUM(causation_sequence_order)
    - name: "Average Causation Sequence Order"
      expr: AVG(causation_sequence_order)
    - name: "Total Peril Contribution Percentage"
      expr: SUM(peril_contribution_percentage)
    - name: "Average Peril Contribution Percentage"
      expr: AVG(peril_contribution_percentage)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claim_status_history`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claim Status History business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claim_status_history`"
  dimensions:
    - name: "Acting User Code"
      expr: acting_user_code
    - name: "Acting User Name"
      expr: acting_user_name
    - name: "Acting User Role"
      expr: acting_user_role
    - name: "Approval Required Indicator"
      expr: approval_required_indicator
    - name: "Approval Timestamp"
      expr: approval_timestamp
    - name: "Approval User Code"
      expr: approval_user_code
    - name: "Comments"
      expr: comments
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "New Status"
      expr: new_status
    - name: "Notification Sent Indicator"
      expr: notification_sent_indicator
    - name: "Notification Timestamp"
      expr: notification_timestamp
    - name: "Prior Status"
      expr: prior_status
    - name: "Regulatory Reportable Indicator"
      expr: regulatory_reportable_indicator
    - name: "Sla Compliance Indicator"
      expr: sla_compliance_indicator
    - name: "System Source"
      expr: system_source
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claim Status History"
      expr: COUNT(DISTINCT claim_status_history_id)
    - name: "Total Incurred Amount"
      expr: SUM(incurred_amount)
    - name: "Average Incurred Amount"
      expr: AVG(incurred_amount)
    - name: "Total Paid Amount"
      expr: SUM(paid_amount)
    - name: "Average Paid Amount"
      expr: AVG(paid_amount)
    - name: "Total Reserve Amount"
      expr: SUM(reserve_amount)
    - name: "Average Reserve Amount"
      expr: AVG(reserve_amount)
    - name: "Total Sequence Number"
      expr: SUM(sequence_number)
    - name: "Average Sequence Number"
      expr: AVG(sequence_number)
    - name: "Total Sla Actual Hours"
      expr: SUM(sla_actual_hours)
    - name: "Average Sla Actual Hours"
      expr: AVG(sla_actual_hours)
    - name: "Total Sla Target Hours"
      expr: SUM(sla_target_hours)
    - name: "Average Sla Target Hours"
      expr: AVG(sla_target_hours)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claimant`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claimant business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claimant`"
  dimensions:
    - name: "Address Line1"
      expr: address_line1
    - name: "Address Line2"
      expr: address_line2
    - name: "Body Part Injured"
      expr: body_part_injured
    - name: "City"
      expr: city
    - name: "Claimant Status"
      expr: claimant_status
    - name: "Claimant Type"
      expr: claimant_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Date Of Birth"
      expr: date_of_birth
    - name: "Dba Name"
      expr: dba_name
    - name: "Email Address"
      expr: email_address
    - name: "Fein"
      expr: fein
    - name: "First Name"
      expr: first_name
    - name: "Injury Description"
      expr: injury_description
    - name: "Injury Severity"
      expr: injury_severity
    - name: "Injury Type"
      expr: injury_type
    - name: "Is Represented"
      expr: is_represented
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claimant"
      expr: COUNT(DISTINCT claimant_id)
    - name: "Total Demand Amount"
      expr: SUM(demand_amount)
    - name: "Average Demand Amount"
      expr: AVG(demand_amount)
    - name: "Total Fault Percentage"
      expr: SUM(fault_percentage)
    - name: "Average Fault Percentage"
      expr: AVG(fault_percentage)
    - name: "Total Paid Amount"
      expr: SUM(paid_amount)
    - name: "Average Paid Amount"
      expr: AVG(paid_amount)
    - name: "Total Party Code"
      expr: SUM(party_code)
    - name: "Average Party Code"
      expr: AVG(party_code)
    - name: "Total Reserve Amount"
      expr: SUM(reserve_amount)
    - name: "Average Reserve Amount"
      expr: AVG(reserve_amount)
    - name: "Total Settlement Amount"
      expr: SUM(settlement_amount)
    - name: "Average Settlement Amount"
      expr: AVG(settlement_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claims_claim_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claims Claim Payment business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claims_claim_payment`"
  dimensions:
    - name: "Accounting Date"
      expr: accounting_date
    - name: "Approval Authority"
      expr: approval_authority
    - name: "Approval Date"
      expr: approval_date
    - name: "Catastrophe Code"
      expr: catastrophe_code
    - name: "Check Number"
      expr: check_number
    - name: "Cleared Date"
      expr: cleared_date
    - name: "Created By User"
      expr: created_by_user
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Is Joint Payee"
      expr: is_joint_payee
    - name: "Is Reportable 1099"
      expr: is_reportable_1099
    - name: "Joint Payee Name"
      expr: joint_payee_name
    - name: "Loss Category"
      expr: loss_category
    - name: "Payee Tax Number"
      expr: payee_tax_number
    - name: "Payee Type"
      expr: payee_type
    - name: "Payment Batch Code"
      expr: payment_batch_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claims Claim Payment"
      expr: COUNT(DISTINCT claims_claim_payment_id)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Gross Payment Amount"
      expr: SUM(gross_payment_amount)
    - name: "Average Gross Payment Amount"
      expr: AVG(gross_payment_amount)
    - name: "Total Net Payment Amount"
      expr: SUM(net_payment_amount)
    - name: "Average Net Payment Amount"
      expr: AVG(net_payment_amount)
    - name: "Total Offset Amount"
      expr: SUM(offset_amount)
    - name: "Average Offset Amount"
      expr: AVG(offset_amount)
    - name: "Total Withholding Amount"
      expr: SUM(withholding_amount)
    - name: "Average Withholding Amount"
      expr: AVG(withholding_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claims_loss_reserve`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claims Loss Reserve business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve`"
  dimensions:
    - name: "Actuarial Segment Code"
      expr: actuarial_segment_code
    - name: "Approval Date"
      expr: approval_date
    - name: "Approver User Code"
      expr: approver_user_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Reserve Approval Status"
      expr: reserve_approval_status
    - name: "Reserve Basis"
      expr: reserve_basis
    - name: "Reserve Category"
      expr: reserve_category
    - name: "Reserve Confidence Level"
      expr: reserve_confidence_level
    - name: "Reserve Effective Date"
      expr: reserve_effective_date
    - name: "Reserve Notes"
      expr: reserve_notes
    - name: "Reserve Number"
      expr: reserve_number
    - name: "Reserve Reason Code"
      expr: reserve_reason_code
    - name: "Reserve Set Date"
      expr: reserve_set_date
    - name: "Reserve Source System"
      expr: reserve_source_system
    - name: "Reserve Source System Code"
      expr: reserve_source_system_code
    - name: "Reserve Status"
      expr: reserve_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claims Loss Reserve"
      expr: COUNT(DISTINCT claims_loss_reserve_id)
    - name: "Total Accident Year"
      expr: SUM(accident_year)
    - name: "Average Accident Year"
      expr: AVG(accident_year)
    - name: "Total Paid To Date Amount"
      expr: SUM(paid_to_date_amount)
    - name: "Average Paid To Date Amount"
      expr: AVG(paid_to_date_amount)
    - name: "Total Prior Reserve Amount"
      expr: SUM(prior_reserve_amount)
    - name: "Average Prior Reserve Amount"
      expr: AVG(prior_reserve_amount)
    - name: "Total Report Year"
      expr: SUM(report_year)
    - name: "Average Report Year"
      expr: AVG(report_year)
    - name: "Total Reserve Amount"
      expr: SUM(reserve_amount)
    - name: "Average Reserve Amount"
      expr: AVG(reserve_amount)
    - name: "Total Reserve Change Amount"
      expr: SUM(reserve_change_amount)
    - name: "Average Reserve Change Amount"
      expr: AVG(reserve_change_amount)
    - name: "Total Ultimate Loss Estimate"
      expr: SUM(ultimate_loss_estimate)
    - name: "Average Ultimate Loss Estimate"
      expr: AVG(ultimate_loss_estimate)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_claims_reserve_transaction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claims Reserve Transaction business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction`"
  dimensions:
    - name: "Accounting Period"
      expr: accounting_period
    - name: "Approval Required Flag"
      expr: approval_required_flag
    - name: "Approval Timestamp"
      expr: approval_timestamp
    - name: "Bulk Reserve Flag"
      expr: bulk_reserve_flag
    - name: "Cat Code"
      expr: cat_code
    - name: "Coverage Code"
      expr: coverage_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Notes"
      expr: notes
    - name: "Peril Code"
      expr: peril_code
    - name: "Posting Status"
      expr: posting_status
    - name: "Reason Code"
      expr: reason_code
    - name: "Reason Description"
      expr: reason_description
    - name: "Reserve Category"
      expr: reserve_category
    - name: "Reserve Confidence Level"
      expr: reserve_confidence_level
    - name: "Reserve Method"
      expr: reserve_method
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Claims Reserve Transaction"
      expr: COUNT(DISTINCT claims_reserve_transaction_id)
    - name: "Total Accident Year"
      expr: SUM(accident_year)
    - name: "Average Accident Year"
      expr: AVG(accident_year)
    - name: "Total Loss Development Factor"
      expr: SUM(loss_development_factor)
    - name: "Average Loss Development Factor"
      expr: AVG(loss_development_factor)
    - name: "Total Net Reserve Amount"
      expr: SUM(net_reserve_amount)
    - name: "Average Net Reserve Amount"
      expr: AVG(net_reserve_amount)
    - name: "Total New Reserve Amount"
      expr: SUM(new_reserve_amount)
    - name: "Average New Reserve Amount"
      expr: AVG(new_reserve_amount)
    - name: "Total Prior Reserve Amount"
      expr: SUM(prior_reserve_amount)
    - name: "Average Prior Reserve Amount"
      expr: AVG(prior_reserve_amount)
    - name: "Total Reinsurance Recoverable Amount"
      expr: SUM(reinsurance_recoverable_amount)
    - name: "Average Reinsurance Recoverable Amount"
      expr: AVG(reinsurance_recoverable_amount)
    - name: "Total Report Year"
      expr: SUM(report_year)
    - name: "Average Report Year"
      expr: AVG(report_year)
    - name: "Total Salvage Subrogation Estimate"
      expr: SUM(salvage_subrogation_estimate)
    - name: "Average Salvage Subrogation Estimate"
      expr: AVG(salvage_subrogation_estimate)
    - name: "Total Transaction Amount"
      expr: SUM(transaction_amount)
    - name: "Average Transaction Amount"
      expr: AVG(transaction_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_damage_estimate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Damage Estimate business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`damage_estimate`"
  dimensions:
    - name: "Approval Date"
      expr: approval_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Damage Estimate Status"
      expr: damage_estimate_status
    - name: "Damage Type"
      expr: damage_type
    - name: "Estimate Date"
      expr: estimate_date
    - name: "Estimate Methodology"
      expr: estimate_methodology
    - name: "Estimate Number"
      expr: estimate_number
    - name: "Estimate Software"
      expr: estimate_software
    - name: "Estimate Type"
      expr: estimate_type
    - name: "Estimator License Number"
      expr: estimator_license_number
    - name: "Estimator Type"
      expr: estimator_type
    - name: "Inspection Date"
      expr: inspection_date
    - name: "Loss Description"
      expr: loss_description
    - name: "Notes"
      expr: notes
    - name: "Rejection Reason"
      expr: rejection_reason
    - name: "Repair Vs Total Decision"
      expr: repair_vs_total_decision
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Damage Estimate"
      expr: COUNT(DISTINCT damage_estimate_id)
    - name: "Total Acv Amount"
      expr: SUM(acv_amount)
    - name: "Average Acv Amount"
      expr: AVG(acv_amount)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Depreciation Amount"
      expr: SUM(depreciation_amount)
    - name: "Average Depreciation Amount"
      expr: AVG(depreciation_amount)
    - name: "Total Equipment Amount"
      expr: SUM(equipment_amount)
    - name: "Average Equipment Amount"
      expr: AVG(equipment_amount)
    - name: "Total Estimator Party Code"
      expr: SUM(estimator_party_code)
    - name: "Average Estimator Party Code"
      expr: AVG(estimator_party_code)
    - name: "Total Labor Amount"
      expr: SUM(labor_amount)
    - name: "Average Labor Amount"
      expr: AVG(labor_amount)
    - name: "Total Line Item Count"
      expr: SUM(line_item_count)
    - name: "Average Line Item Count"
      expr: AVG(line_item_count)
    - name: "Total Materials Amount"
      expr: SUM(materials_amount)
    - name: "Average Materials Amount"
      expr: AVG(materials_amount)
    - name: "Total Net Payable Amount"
      expr: SUM(net_payable_amount)
    - name: "Average Net Payable Amount"
      expr: AVG(net_payable_amount)
    - name: "Total Overhead Profit Amount"
      expr: SUM(overhead_profit_amount)
    - name: "Average Overhead Profit Amount"
      expr: AVG(overhead_profit_amount)
    - name: "Total Rcv Amount"
      expr: SUM(rcv_amount)
    - name: "Average Rcv Amount"
      expr: AVG(rcv_amount)
    - name: "Total Salvage Value"
      expr: SUM(salvage_value)
    - name: "Average Salvage Value"
      expr: AVG(salvage_value)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_disbursement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Disbursement business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`disbursement`"
  dimensions:
    - name: "Approval Timestamp"
      expr: approval_timestamp
    - name: "Approval User Code"
      expr: approval_user_code
    - name: "Bank Account Number"
      expr: bank_account_number
    - name: "Bank Name"
      expr: bank_name
    - name: "Bank Routing Number"
      expr: bank_routing_number
    - name: "Check Number"
      expr: check_number
    - name: "Cleared Date"
      expr: cleared_date
    - name: "Coverage Code"
      expr: coverage_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Disbursement Date"
      expr: disbursement_date
    - name: "Disbursement Status"
      expr: disbursement_status
    - name: "Eft Trace Number"
      expr: eft_trace_number
    - name: "Gl Account Code"
      expr: gl_account_code
    - name: "Gl Posting Date"
      expr: gl_posting_date
    - name: "Is Void"
      expr: is_void
    - name: "Issued By User Code"
      expr: issued_by_user_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Disbursement"
      expr: COUNT(DISTINCT disbursement_id)
    - name: "Total Gross Amount"
      expr: SUM(gross_amount)
    - name: "Average Gross Amount"
      expr: AVG(gross_amount)
    - name: "Total Net Amount"
      expr: SUM(net_amount)
    - name: "Average Net Amount"
      expr: AVG(net_amount)
    - name: "Total Offset Amount"
      expr: SUM(offset_amount)
    - name: "Average Offset Amount"
      expr: AVG(offset_amount)
    - name: "Total Withholding Amount"
      expr: SUM(withholding_amount)
    - name: "Average Withholding Amount"
      expr: AVG(withholding_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_fnol`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fnol business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`fnol`"
  dimensions:
    - name: "Cat Code"
      expr: cat_code
    - name: "Claimant Email"
      expr: claimant_email
    - name: "Claimant Phone"
      expr: claimant_phone
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Dol"
      expr: dol
    - name: "Dol Timestamp"
      expr: dol_timestamp
    - name: "Fnol Status"
      expr: fnol_status
    - name: "Fraud Indicator"
      expr: fraud_indicator
    - name: "Injury Indicator"
      expr: injury_indicator
    - name: "Intake Channel"
      expr: intake_channel
    - name: "Intake User Code"
      expr: intake_user_code
    - name: "Is Cat Loss"
      expr: is_cat_loss
    - name: "Loss Description"
      expr: loss_description
    - name: "Number"
      expr: number
    - name: "Peril Code"
      expr: peril_code
    - name: "Police Report Filed"
      expr: police_report_filed
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Fnol"
      expr: COUNT(DISTINCT fnol_id)
    - name: "Total Estimated Loss Amount"
      expr: SUM(estimated_loss_amount)
    - name: "Average Estimated Loss Amount"
      expr: AVG(estimated_loss_amount)
    - name: "Total Loss Location Latitude"
      expr: SUM(loss_location_latitude)
    - name: "Average Loss Location Latitude"
      expr: AVG(loss_location_latitude)
    - name: "Total Loss Location Longitude"
      expr: SUM(loss_location_longitude)
    - name: "Average Loss Location Longitude"
      expr: AVG(loss_location_longitude)
    - name: "Total Reporter Party Code"
      expr: SUM(reporter_party_code)
    - name: "Average Reporter Party Code"
      expr: AVG(reporter_party_code)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_fraud_referral`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fraud Referral business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`fraud_referral`"
  dimensions:
    - name: "Assigned Date"
      expr: assigned_date
    - name: "Created By User Code"
      expr: created_by_user_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Denial Reason Code"
      expr: denial_reason_code
    - name: "Denial Recommended Flag"
      expr: denial_recommended_flag
    - name: "Fraud Confirmed Flag"
      expr: fraud_confirmed_flag
    - name: "Fraud Indicator Code"
      expr: fraud_indicator_code
    - name: "Fraud Indicator Description"
      expr: fraud_indicator_description
    - name: "Fraud Referral Status"
      expr: fraud_referral_status
    - name: "Fraud Type"
      expr: fraud_type
    - name: "Investigation Close Date"
      expr: investigation_close_date
    - name: "Investigation Notes"
      expr: investigation_notes
    - name: "Investigation Start Date"
      expr: investigation_start_date
    - name: "Law Enforcement Agency"
      expr: law_enforcement_agency
    - name: "Law Enforcement Case Number"
      expr: law_enforcement_case_number
    - name: "Law Enforcement Referral Date"
      expr: law_enforcement_referral_date
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Fraud Referral"
      expr: COUNT(DISTINCT fraud_referral_id)
    - name: "Total Confirmed Fraud Amount"
      expr: SUM(confirmed_fraud_amount)
    - name: "Average Confirmed Fraud Amount"
      expr: AVG(confirmed_fraud_amount)
    - name: "Total Estimated Fraud Amount"
      expr: SUM(estimated_fraud_amount)
    - name: "Average Estimated Fraud Amount"
      expr: AVG(estimated_fraud_amount)
    - name: "Total Recovery Amount"
      expr: SUM(recovery_amount)
    - name: "Average Recovery Amount"
      expr: AVG(recovery_amount)
    - name: "Total Referring Party Code"
      expr: SUM(referring_party_code)
    - name: "Average Referring Party Code"
      expr: AVG(referring_party_code)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_litigation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Litigation business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`litigation`"
  dimensions:
    - name: "Appeal Filed Indicator"
      expr: appeal_filed_indicator
    - name: "Bad Faith Indicator"
      expr: bad_faith_indicator
    - name: "Case Description"
      expr: case_description
    - name: "Court County"
      expr: court_county
    - name: "Court Jurisdiction"
      expr: court_jurisdiction
    - name: "Court State"
      expr: court_state
    - name: "Court Type"
      expr: court_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Discovery Deadline Date"
      expr: discovery_deadline_date
    - name: "Dismissal Date"
      expr: dismissal_date
    - name: "Litigation Status"
      expr: litigation_status
    - name: "Litigation Type"
      expr: litigation_type
    - name: "Mediation Scheduled Date"
      expr: mediation_scheduled_date
    - name: "Notes"
      expr: notes
    - name: "Punitive Damages Sought"
      expr: punitive_damages_sought
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Litigation"
      expr: COUNT(DISTINCT litigation_id)
    - name: "Total Alae Incurred"
      expr: SUM(alae_incurred)
    - name: "Average Alae Incurred"
      expr: AVG(alae_incurred)
    - name: "Total Alae Paid"
      expr: SUM(alae_paid)
    - name: "Average Alae Paid"
      expr: AVG(alae_paid)
    - name: "Total Plaintiff Demand Amount"
      expr: SUM(plaintiff_demand_amount)
    - name: "Average Plaintiff Demand Amount"
      expr: AVG(plaintiff_demand_amount)
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

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_medical_bill`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Medical Bill business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`medical_bill`"
  dimensions:
    - name: "Admission Date"
      expr: admission_date
    - name: "Bill Date"
      expr: bill_date
    - name: "Bill Number"
      expr: bill_number
    - name: "Bill Received Date"
      expr: bill_received_date
    - name: "Bill Review Date"
      expr: bill_review_date
    - name: "Bill Review Outcome"
      expr: bill_review_outcome
    - name: "Bill Type Code"
      expr: bill_type_code
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
    - name: "Discharge Date"
      expr: discharge_date
    - name: "Fee Schedule Applied"
      expr: fee_schedule_applied
    - name: "Notes"
      expr: notes
    - name: "Payment Date"
      expr: payment_date
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
    - name: "Total Paid Amount"
      expr: SUM(paid_amount)
    - name: "Average Paid Amount"
      expr: AVG(paid_amount)
    - name: "Total Reduction Amount"
      expr: SUM(reduction_amount)
    - name: "Average Reduction Amount"
      expr: AVG(reduction_amount)
    - name: "Total Service Units"
      expr: SUM(service_units)
    - name: "Average Service Units"
      expr: AVG(service_units)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_service_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Service Assignment business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`service_assignment`"
  dimensions:
    - name: "Assignment Date"
      expr: assignment_date
    - name: "Assignment Status"
      expr: assignment_status
    - name: "Assignment Type"
      expr: assignment_type
    - name: "Completion Date"
      expr: completion_date
    - name: "Sla Compliance Flag"
      expr: sla_compliance_flag
    - name: "Assignment Date Month"
      expr: DATE_TRUNC('MONTH', assignment_date)
    - name: "Completion Date Month"
      expr: DATE_TRUNC('MONTH', completion_date)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Service Assignment"
      expr: COUNT(DISTINCT service_assignment_id)
    - name: "Total Invoice Amount"
      expr: SUM(invoice_amount)
    - name: "Average Invoice Amount"
      expr: AVG(invoice_amount)
    - name: "Total Performance Rating"
      expr: SUM(performance_rating)
    - name: "Average Performance Rating"
      expr: AVG(performance_rating)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_service_vendor`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Service Vendor business metrics"
  source: "`vibe_pc_insurance_v499`.`claims`.`service_vendor`"
  dimensions:
    - name: "Background Check Date"
      expr: background_check_date
    - name: "Background Check Status"
      expr: background_check_status
    - name: "Bank Account Number"
      expr: bank_account_number
    - name: "Bank Routing Number"
      expr: bank_routing_number
    - name: "Business Address Line1"
      expr: business_address_line1
    - name: "Business Address Line2"
      expr: business_address_line2
    - name: "Business City"
      expr: business_city
    - name: "Business Postal Code"
      expr: business_postal_code
    - name: "Contract Effective Date"
      expr: contract_effective_date
    - name: "Contract Expiration Date"
      expr: contract_expiration_date
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Dba Name"
      expr: dba_name
    - name: "Insurance Certificate Number"
      expr: insurance_certificate_number
    - name: "Insurance Expiration Date"
      expr: insurance_expiration_date
    - name: "Licensed States"
      expr: licensed_states
    - name: "Notes"
      expr: notes
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Service Vendor"
      expr: COUNT(DISTINCT service_vendor_id)
    - name: "Total Average Cycle Time Days"
      expr: SUM(average_cycle_time_days)
    - name: "Average Average Cycle Time Days"
      expr: AVG(average_cycle_time_days)
    - name: "Total Customer Satisfaction Score"
      expr: SUM(customer_satisfaction_score)
    - name: "Average Customer Satisfaction Score"
      expr: AVG(customer_satisfaction_score)
    - name: "Total Insurance Coverage Amount"
      expr: SUM(insurance_coverage_amount)
    - name: "Average Insurance Coverage Amount"
      expr: AVG(insurance_coverage_amount)
    - name: "Total Quality Score"
      expr: SUM(quality_score)
    - name: "Average Quality Score"
      expr: AVG(quality_score)
    - name: "Total Service Radius Miles"
      expr: SUM(service_radius_miles)
    - name: "Average Service Radius Miles"
      expr: AVG(service_radius_miles)
    - name: "Total Total Assignments Ytd"
      expr: SUM(total_assignments_ytd)
    - name: "Average Total Assignments Ytd"
      expr: AVG(total_assignments_ytd)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`claims_tpa`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_v499`.`claims`.`tpa`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;