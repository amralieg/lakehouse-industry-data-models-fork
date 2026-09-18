-- Metric views for domain: coverage | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-18 02:41:20

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_additional_insured`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Additional Insured business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`additional_insured`"
  dimensions:
    - name: "Added By User"
      expr: added_by_user
    - name: "Added Date"
      expr: added_date
    - name: "Ai Address Line1"
      expr: ai_address_line1
    - name: "Ai Address Line2"
      expr: ai_address_line2
    - name: "Ai City"
      expr: ai_city
    - name: "Ai Country Code"
      expr: ai_country_code
    - name: "Ai Name"
      expr: ai_name
    - name: "Ai Number"
      expr: ai_number
    - name: "Ai Postal Code"
      expr: ai_postal_code
    - name: "Ai State Code"
      expr: ai_state_code
    - name: "Ai Status"
      expr: ai_status
    - name: "Ai Type"
      expr: ai_type
    - name: "Auto Cert Issuance Flag"
      expr: auto_cert_issuance_flag
    - name: "Cancellation Date"
      expr: cancellation_date
    - name: "Cancellation Reason"
      expr: cancellation_reason
    - name: "Certificate Holder Flag"
      expr: certificate_holder_flag
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Additional Insured"
      expr: COUNT(DISTINCT additional_insured_id)
    - name: "Total Additional Premium"
      expr: SUM(additional_premium)
    - name: "Average Additional Premium"
      expr: AVG(additional_premium)
    - name: "Total Aggregate Limit"
      expr: SUM(aggregate_limit)
    - name: "Average Aggregate Limit"
      expr: AVG(aggregate_limit)
    - name: "Total Notice Of Cancellation Days"
      expr: SUM(notice_of_cancellation_days)
    - name: "Average Notice Of Cancellation Days"
      expr: AVG(notice_of_cancellation_days)
    - name: "Total Occurrence Limit"
      expr: SUM(occurrence_limit)
    - name: "Average Occurrence Limit"
      expr: AVG(occurrence_limit)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_amendment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Amendment business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`amendment`"
  dimensions:
    - name: "Amendment Number"
      expr: amendment_number
    - name: "Amendment Status"
      expr: amendment_status
    - name: "Amendment Type"
      expr: amendment_type
    - name: "Applied Timestamp"
      expr: applied_timestamp
    - name: "Approved Timestamp"
      expr: approved_timestamp
    - name: "Change Reason Code"
      expr: change_reason_code
    - name: "Change Reason Description"
      expr: change_reason_description
    - name: "Coverage Form Number"
      expr: coverage_form_number
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Lob Code"
      expr: lob_code
    - name: "Notes"
      expr: notes
    - name: "Premium Impact Type"
      expr: premium_impact_type
    - name: "Regulatory Filing Reference"
      expr: regulatory_filing_reference
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Amendment"
      expr: COUNT(DISTINCT amendment_id)
    - name: "Total Itv Ratio"
      expr: SUM(itv_ratio)
    - name: "Average Itv Ratio"
      expr: AVG(itv_ratio)
    - name: "Total New Deductible Amount"
      expr: SUM(new_deductible_amount)
    - name: "Average New Deductible Amount"
      expr: AVG(new_deductible_amount)
    - name: "Total New Limit Amount"
      expr: SUM(new_limit_amount)
    - name: "Average New Limit Amount"
      expr: AVG(new_limit_amount)
    - name: "Total New Sir Amount"
      expr: SUM(new_sir_amount)
    - name: "Average New Sir Amount"
      expr: AVG(new_sir_amount)
    - name: "Total New Tiv Amount"
      expr: SUM(new_tiv_amount)
    - name: "Average New Tiv Amount"
      expr: AVG(new_tiv_amount)
    - name: "Total Premium Impact Amount"
      expr: SUM(premium_impact_amount)
    - name: "Average Premium Impact Amount"
      expr: AVG(premium_impact_amount)
    - name: "Total Prior Deductible Amount"
      expr: SUM(prior_deductible_amount)
    - name: "Average Prior Deductible Amount"
      expr: AVG(prior_deductible_amount)
    - name: "Total Prior Limit Amount"
      expr: SUM(prior_limit_amount)
    - name: "Average Prior Limit Amount"
      expr: AVG(prior_limit_amount)
    - name: "Total Prior Sir Amount"
      expr: SUM(prior_sir_amount)
    - name: "Average Prior Sir Amount"
      expr: AVG(prior_sir_amount)
    - name: "Total Prior Tiv Amount"
      expr: SUM(prior_tiv_amount)
    - name: "Average Prior Tiv Amount"
      expr: AVG(prior_tiv_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_cession`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cession business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`cession`"
  dimensions:
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Facultative Certificate Number"
      expr: facultative_certificate_number
    - name: "Participation Status"
      expr: participation_status
    - name: "Settlement Status"
      expr: settlement_status
    - name: "Effective Date Month"
      expr: DATE_TRUNC('MONTH', effective_date)
    - name: "Expiration Date Month"
      expr: DATE_TRUNC('MONTH', expiration_date)
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Cession"
      expr: COUNT(DISTINCT cession_id)
    - name: "Total Ceded Limit Amount"
      expr: SUM(ceded_limit_amount)
    - name: "Average Ceded Limit Amount"
      expr: AVG(ceded_limit_amount)
    - name: "Total Ceded Premium Amount"
      expr: SUM(ceded_premium_amount)
    - name: "Average Ceded Premium Amount"
      expr: AVG(ceded_premium_amount)
    - name: "Total Ceded Share Pct"
      expr: SUM(ceded_share_pct)
    - name: "Average Ceded Share Pct"
      expr: AVG(ceded_share_pct)
    - name: "Total Collateral Held Amount"
      expr: SUM(collateral_held_amount)
    - name: "Average Collateral Held Amount"
      expr: AVG(collateral_held_amount)
    - name: "Total Commission Pct"
      expr: SUM(commission_pct)
    - name: "Average Commission Pct"
      expr: AVG(commission_pct)
    - name: "Total Recoverable Balance"
      expr: SUM(recoverable_balance)
    - name: "Average Recoverable Balance"
      expr: AVG(recoverable_balance)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_coverage_form`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Coverage Form business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`coverage_form`"
  dimensions:
    - name: "Aggregate Limit Applicable"
      expr: aggregate_limit_applicable
    - name: "Approval Date"
      expr: approval_date
    - name: "Cat Exposed"
      expr: cat_exposed
    - name: "Coverage Category"
      expr: coverage_category
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Document Template Code"
      expr: document_template_code
    - name: "Edition Date"
      expr: edition_date
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Filing Date"
      expr: filing_date
    - name: "Filing Jurisdiction"
      expr: filing_jurisdiction
    - name: "Filing Status"
      expr: filing_status
    - name: "Form Description"
      expr: form_description
    - name: "Form Name"
      expr: form_name
    - name: "Form Number"
      expr: form_number
    - name: "Form Status"
      expr: form_status
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Coverage Form"
      expr: COUNT(DISTINCT coverage_form_id)
    - name: "Total Coinsurance Percent"
      expr: SUM(coinsurance_percent)
    - name: "Average Coinsurance Percent"
      expr: AVG(coinsurance_percent)
    - name: "Total Default Deductible Amount"
      expr: SUM(default_deductible_amount)
    - name: "Average Default Deductible Amount"
      expr: AVG(default_deductible_amount)
    - name: "Total Default Limit Amount"
      expr: SUM(default_limit_amount)
    - name: "Average Default Limit Amount"
      expr: AVG(default_limit_amount)
    - name: "Total Extended Reporting Period Days"
      expr: SUM(extended_reporting_period_days)
    - name: "Average Extended Reporting Period Days"
      expr: AVG(extended_reporting_period_days)
    - name: "Total Minimum Premium Amount"
      expr: SUM(minimum_premium_amount)
    - name: "Average Minimum Premium Amount"
      expr: AVG(minimum_premium_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_coverage_peril`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Coverage Peril business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`coverage_peril`"
  dimensions:
    - name: "Association Status"
      expr: association_status
    - name: "Cat Designation Flag"
      expr: cat_designation_flag
    - name: "Cat Event Type"
      expr: cat_event_type
    - name: "Cat Peril Code"
      expr: cat_peril_code
    - name: "Cat Peril Flag"
      expr: cat_peril_flag
    - name: "Cat Xl Applicable Flag"
      expr: cat_xl_applicable_flag
    - name: "Category"
      expr: coverage_peril_category
    - name: "Code"
      expr: source_system_record_code
    - name: "Coverage Form Edition Date"
      expr: coverage_form_edition_date
    - name: "Coverage Form Number"
      expr: coverage_form_number
    - name: "Coverage Peril Status"
      expr: coverage_peril_status
    - name: "Coverage Trigger"
      expr: coverage_trigger
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Deductible Basis"
      expr: deductible_basis
    - name: "Deductible Type"
      expr: deductible_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Coverage Peril"
      expr: COUNT(DISTINCT coverage_peril_id)
    - name: "Total Aggregate Deductible Amount"
      expr: SUM(aggregate_deductible_amount)
    - name: "Average Aggregate Deductible Amount"
      expr: AVG(aggregate_deductible_amount)
    - name: "Total Coinsurance Percentage"
      expr: SUM(coinsurance_percentage)
    - name: "Average Coinsurance Percentage"
      expr: AVG(coinsurance_percentage)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Deductible Percentage"
      expr: SUM(deductible_percentage)
    - name: "Average Deductible Percentage"
      expr: AVG(deductible_percentage)
    - name: "Total Premium Amount"
      expr: SUM(premium_amount)
    - name: "Average Premium Amount"
      expr: AVG(premium_amount)
    - name: "Total Rate"
      expr: SUM(rate)
    - name: "Average Rate"
      expr: AVG(rate)
    - name: "Total Sir Amount"
      expr: SUM(sir_amount)
    - name: "Average Sir Amount"
      expr: AVG(sir_amount)
    - name: "Total Sublimit Amount"
      expr: SUM(sublimit_amount)
    - name: "Average Sublimit Amount"
      expr: AVG(sublimit_amount)
    - name: "Total Waiting Period Days"
      expr: SUM(waiting_period_days)
    - name: "Average Waiting Period Days"
      expr: AVG(waiting_period_days)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_coverage_policy_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Coverage Policy Coverage business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`"
  dimensions:
    - name: "Cancellation Date"
      expr: cancellation_date
    - name: "Cancellation Reason Code"
      expr: cancellation_reason_code
    - name: "Cat Exposed Flag"
      expr: cat_exposed_flag
    - name: "Coverage Basis"
      expr: coverage_basis
    - name: "Coverage Status"
      expr: coverage_status
    - name: "Coverage Type Code"
      expr: coverage_type_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Deductible Type"
      expr: deductible_type
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Flag"
      expr: endorsement_flag
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Exclusion Codes"
      expr: exclusion_codes
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Lob Code"
      expr: lob_code
    - name: "Mandatory Coverage Flag"
      expr: mandatory_coverage_flag
    - name: "Policy Transaction Type"
      expr: policy_transaction_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Coverage Policy Coverage"
      expr: COUNT(DISTINCT coverage_policy_coverage_id)
    - name: "Total Aggregate Limit"
      expr: SUM(aggregate_limit)
    - name: "Average Aggregate Limit"
      expr: AVG(aggregate_limit)
    - name: "Total Coinsurance Percentage"
      expr: SUM(coinsurance_percentage)
    - name: "Average Coinsurance Percentage"
      expr: AVG(coinsurance_percentage)
    - name: "Total Coverage Sequence Number"
      expr: SUM(coverage_sequence_number)
    - name: "Average Coverage Sequence Number"
      expr: AVG(coverage_sequence_number)
    - name: "Total Deductible Amount"
      expr: SUM(deductible_amount)
    - name: "Average Deductible Amount"
      expr: AVG(deductible_amount)
    - name: "Total Earned Premium Amount"
      expr: SUM(earned_premium_amount)
    - name: "Average Earned Premium Amount"
      expr: AVG(earned_premium_amount)
    - name: "Total Extended Reporting Period Days"
      expr: SUM(extended_reporting_period_days)
    - name: "Average Extended Reporting Period Days"
      expr: AVG(extended_reporting_period_days)
    - name: "Total Itv Ratio"
      expr: SUM(itv_ratio)
    - name: "Average Itv Ratio"
      expr: AVG(itv_ratio)
    - name: "Total Occurrence Limit"
      expr: SUM(occurrence_limit)
    - name: "Average Occurrence Limit"
      expr: AVG(occurrence_limit)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
    - name: "Total Sir Amount"
      expr: SUM(sir_amount)
    - name: "Average Sir Amount"
      expr: AVG(sir_amount)
    - name: "Total Sublimit Amount"
      expr: SUM(sublimit_amount)
    - name: "Average Sublimit Amount"
      expr: AVG(sublimit_amount)
    - name: "Total Tiv Amount"
      expr: SUM(tiv_amount)
    - name: "Average Tiv Amount"
      expr: AVG(tiv_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_deductible`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Deductible business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`deductible`"
  dimensions:
    - name: "Application Method"
      expr: application_method
    - name: "Buyback Available Flag"
      expr: buyback_available_flag
    - name: "Cat Deductible Flag"
      expr: cat_deductible_flag
    - name: "Cat Peril Type"
      expr: cat_peril_type
    - name: "Code"
      expr: source_system_ref_code
    - name: "Coverage Form Code"
      expr: coverage_form_code
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Deductible Status"
      expr: deductible_status
    - name: "Deductible Type"
      expr: deductible_type
    - name: "Defense Inside Sir Flag"
      expr: defense_inside_sir_flag
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Erosion Basis"
      expr: erosion_basis
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Lob Code"
      expr: lob_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Deductible"
      expr: COUNT(DISTINCT deductible_id)
    - name: "Total Aggregate Deductible Amount"
      expr: SUM(aggregate_deductible_amount)
    - name: "Average Aggregate Deductible Amount"
      expr: AVG(aggregate_deductible_amount)
    - name: "Total Buyback Premium Amount"
      expr: SUM(buyback_premium_amount)
    - name: "Average Buyback Premium Amount"
      expr: AVG(buyback_premium_amount)
    - name: "Total Disappearing Max Amount"
      expr: SUM(disappearing_max_amount)
    - name: "Average Disappearing Max Amount"
      expr: AVG(disappearing_max_amount)
    - name: "Total Disappearing Min Amount"
      expr: SUM(disappearing_min_amount)
    - name: "Average Disappearing Min Amount"
      expr: AVG(disappearing_min_amount)
    - name: "Total Flat Amount"
      expr: SUM(flat_amount)
    - name: "Average Flat Amount"
      expr: AVG(flat_amount)
    - name: "Total Maximum Deductible Amount"
      expr: SUM(maximum_deductible_amount)
    - name: "Average Maximum Deductible Amount"
      expr: AVG(maximum_deductible_amount)
    - name: "Total Minimum Deductible Amount"
      expr: SUM(minimum_deductible_amount)
    - name: "Average Minimum Deductible Amount"
      expr: AVG(minimum_deductible_amount)
    - name: "Total Percentage Rate"
      expr: SUM(percentage_rate)
    - name: "Average Percentage Rate"
      expr: AVG(percentage_rate)
    - name: "Total Rate Credit Factor"
      expr: SUM(rate_credit_factor)
    - name: "Average Rate Credit Factor"
      expr: AVG(rate_credit_factor)
    - name: "Total Sir Aggregate Cap"
      expr: SUM(sir_aggregate_cap)
    - name: "Average Sir Aggregate Cap"
      expr: AVG(sir_aggregate_cap)
    - name: "Total Sir Amount"
      expr: SUM(sir_amount)
    - name: "Average Sir Amount"
      expr: AVG(sir_amount)
    - name: "Total Split Aggregate Amount"
      expr: SUM(split_aggregate_amount)
    - name: "Average Split Aggregate Amount"
      expr: AVG(split_aggregate_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_endorsement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Endorsement business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`endorsement`"
  dimensions:
    - name: "Beneficiary Name"
      expr: beneficiary_name
    - name: "Beneficiary Type"
      expr: beneficiary_type
    - name: "Coverage Territory"
      expr: coverage_territory
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Description"
      expr: endorsement_description
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Endorsement Status"
      expr: endorsement_status
    - name: "Endorsement Type"
      expr: endorsement_type
    - name: "Exclusion Description"
      expr: exclusion_description
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Issued Date"
      expr: issued_date
    - name: "Lob Code"
      expr: lob_code
    - name: "Policy Transaction Type"
      expr: policy_transaction_type
    - name: "Premium Impact Type"
      expr: premium_impact_type
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Endorsement"
      expr: COUNT(DISTINCT endorsement_id)
    - name: "Total Aggregate Limit Amount"
      expr: SUM(aggregate_limit_amount)
    - name: "Average Aggregate Limit Amount"
      expr: AVG(aggregate_limit_amount)
    - name: "Total Itv Ratio"
      expr: SUM(itv_ratio)
    - name: "Average Itv Ratio"
      expr: AVG(itv_ratio)
    - name: "Total New Deductible Amount"
      expr: SUM(new_deductible_amount)
    - name: "Average New Deductible Amount"
      expr: AVG(new_deductible_amount)
    - name: "Total New Limit Amount"
      expr: SUM(new_limit_amount)
    - name: "Average New Limit Amount"
      expr: AVG(new_limit_amount)
    - name: "Total Occurrence Limit Amount"
      expr: SUM(occurrence_limit_amount)
    - name: "Average Occurrence Limit Amount"
      expr: AVG(occurrence_limit_amount)
    - name: "Total Premium Impact Amount"
      expr: SUM(premium_impact_amount)
    - name: "Average Premium Impact Amount"
      expr: AVG(premium_impact_amount)
    - name: "Total Prior Deductible Amount"
      expr: SUM(prior_deductible_amount)
    - name: "Average Prior Deductible Amount"
      expr: AVG(prior_deductible_amount)
    - name: "Total Prior Limit Amount"
      expr: SUM(prior_limit_amount)
    - name: "Average Prior Limit Amount"
      expr: AVG(prior_limit_amount)
    - name: "Total Sir Amount"
      expr: SUM(sir_amount)
    - name: "Average Sir Amount"
      expr: AVG(sir_amount)
    - name: "Total Tiv Impact Amount"
      expr: SUM(tiv_impact_amount)
    - name: "Average Tiv Impact Amount"
      expr: AVG(tiv_impact_amount)
    - name: "Total Version Number"
      expr: SUM(version_number)
    - name: "Average Version Number"
      expr: AVG(version_number)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_exclusion`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Exclusion business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`exclusion`"
  dimensions:
    - name: "Bureau Filed Flag"
      expr: bureau_filed_flag
    - name: "Cat Peril Flag"
      expr: cat_peril_flag
    - name: "Claims Handling Note"
      expr: claims_handling_note
    - name: "Clause Name"
      expr: clause_name
    - name: "Clause Status"
      expr: clause_status
    - name: "Clause Summary"
      expr: clause_summary
    - name: "Clause Text"
      expr: clause_text
    - name: "Clause Type"
      expr: clause_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Cyber Flag"
      expr: cyber_flag
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Itv Impact Flag"
      expr: itv_impact_flag
    - name: "Lob Code"
      expr: lob_code
    - name: "Manuscript Flag"
      expr: manuscript_flag
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Exclusion"
      expr: COUNT(DISTINCT exclusion_id)
    - name: "Total Sir Amount"
      expr: SUM(sir_amount)
    - name: "Average Sir Amount"
      expr: AVG(sir_amount)
    - name: "Total Sublimit Amount"
      expr: SUM(sublimit_amount)
    - name: "Average Sublimit Amount"
      expr: AVG(sublimit_amount)
    - name: "Total Tiv Reduction Amount"
      expr: SUM(tiv_reduction_amount)
    - name: "Average Tiv Reduction Amount"
      expr: AVG(tiv_reduction_amount)
    - name: "Total Version Number"
      expr: SUM(version_number)
    - name: "Average Version Number"
      expr: AVG(version_number)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Exposure business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`exposure`"
  dimensions:
    - name: "Cat Exposed Flag"
      expr: cat_exposed_flag
    - name: "Construction Type"
      expr: construction_type
    - name: "Coverage Scope"
      expr: coverage_scope
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Exclusion Codes"
      expr: exclusion_codes
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Exposure Status"
      expr: exposure_status
    - name: "Exposure Type"
      expr: exposure_type
    - name: "Lob Code"
      expr: lob_code
    - name: "Occupancy Code"
      expr: occupancy_code
    - name: "Premium Currency Code"
      expr: premium_currency_code
    - name: "Protection Class"
      expr: protection_class
    - name: "Reference Number"
      expr: reference_number
    - name: "Reinsurance Eligible Flag"
      expr: reinsurance_eligible_flag
    - name: "Source System Code"
      expr: source_system_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Exposure"
      expr: COUNT(DISTINCT exposure_id)
    - name: "Total Coinsurance Percentage"
      expr: SUM(coinsurance_percentage)
    - name: "Average Coinsurance Percentage"
      expr: AVG(coinsurance_percentage)
    - name: "Total Earned Premium Amount"
      expr: SUM(earned_premium_amount)
    - name: "Average Earned Premium Amount"
      expr: AVG(earned_premium_amount)
    - name: "Total Itv Ratio"
      expr: SUM(itv_ratio)
    - name: "Average Itv Ratio"
      expr: AVG(itv_ratio)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
    - name: "Total Tiv Amount"
      expr: SUM(tiv_amount)
    - name: "Average Tiv Amount"
      expr: AVG(tiv_amount)
    - name: "Total Unearned Premium Amount"
      expr: SUM(unearned_premium_amount)
    - name: "Average Unearned Premium Amount"
      expr: AVG(unearned_premium_amount)
    - name: "Total Waiting Period Days"
      expr: SUM(waiting_period_days)
    - name: "Average Waiting Period Days"
      expr: AVG(waiting_period_days)
    - name: "Total Written Premium Amount"
      expr: SUM(written_premium_amount)
    - name: "Average Written Premium Amount"
      expr: AVG(written_premium_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_itv_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Itv Assessment business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`itv_assessment`"
  dimensions:
    - name: "Agreed Value Flag"
      expr: agreed_value_flag
    - name: "Assessment Date"
      expr: assessment_date
    - name: "Assessment Method"
      expr: assessment_method
    - name: "Assessment Number"
      expr: assessment_number
    - name: "Assessment Status"
      expr: assessment_status
    - name: "Assessment Type"
      expr: assessment_type
    - name: "Assessor Credential"
      expr: assessor_credential
    - name: "Assessor Name"
      expr: assessor_name
    - name: "Coinsurance Penalty Flag"
      expr: coinsurance_penalty_flag
    - name: "Construction Type"
      expr: construction_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Data Source"
      expr: data_source
    - name: "Effective Date"
      expr: effective_date
    - name: "Expiry Date"
      expr: expiry_date
    - name: "Occupancy Code"
      expr: occupancy_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Itv Assessment"
      expr: COUNT(DISTINCT itv_assessment_id)
    - name: "Total Acv Estimate"
      expr: SUM(acv_estimate)
    - name: "Average Acv Estimate"
      expr: AVG(acv_estimate)
    - name: "Total Assessed Rcv"
      expr: SUM(assessed_rcv)
    - name: "Average Assessed Rcv"
      expr: AVG(assessed_rcv)
    - name: "Total Coinsurance Pct"
      expr: SUM(coinsurance_pct)
    - name: "Average Coinsurance Pct"
      expr: AVG(coinsurance_pct)
    - name: "Total Cost Index Factor"
      expr: SUM(cost_index_factor)
    - name: "Average Cost Index Factor"
      expr: AVG(cost_index_factor)
    - name: "Total Inflation Guard Pct"
      expr: SUM(inflation_guard_pct)
    - name: "Average Inflation Guard Pct"
      expr: AVG(inflation_guard_pct)
    - name: "Total Itv Ratio"
      expr: SUM(itv_ratio)
    - name: "Average Itv Ratio"
      expr: AVG(itv_ratio)
    - name: "Total Number Of Stories"
      expr: SUM(number_of_stories)
    - name: "Average Number Of Stories"
      expr: AVG(number_of_stories)
    - name: "Total Reported Tiv"
      expr: SUM(reported_tiv)
    - name: "Average Reported Tiv"
      expr: AVG(reported_tiv)
    - name: "Total Roof Year"
      expr: SUM(roof_year)
    - name: "Average Roof Year"
      expr: AVG(roof_year)
    - name: "Total Total Area Sqft"
      expr: SUM(total_area_sqft)
    - name: "Average Total Area Sqft"
      expr: AVG(total_area_sqft)
    - name: "Total Underinsurance Gap"
      expr: SUM(underinsurance_gap)
    - name: "Average Underinsurance Gap"
      expr: AVG(underinsurance_gap)
    - name: "Total Year Built"
      expr: SUM(year_built)
    - name: "Average Year Built"
      expr: AVG(year_built)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_limit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Limit business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`limit`"
  dimensions:
    - name: "Application"
      expr: application
    - name: "Basis"
      expr: basis
    - name: "Cat Exposed Flag"
      expr: cat_exposed_flag
    - name: "Code"
      expr: source_system_limit_code
    - name: "Coverage Form Code"
      expr: coverage_form_code
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
    - name: "Iso Limit Symbol"
      expr: iso_limit_symbol
    - name: "Jurisdiction State Code"
      expr: jurisdiction_state_code
    - name: "Limit Status"
      expr: limit_status
    - name: "Limit Type"
      expr: limit_type
    - name: "Lob Code"
      expr: lob_code
    - name: "Naic Coverage Code"
      expr: naic_coverage_code
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Limit"
      expr: COUNT(DISTINCT limit_id)
    - name: "Total Aggregate Limit Amount"
      expr: SUM(aggregate_limit_amount)
    - name: "Average Aggregate Limit Amount"
      expr: AVG(aggregate_limit_amount)
    - name: "Total Amount"
      expr: SUM(amount)
    - name: "Average Amount"
      expr: AVG(amount)
    - name: "Total Amount 2"
      expr: SUM(amount_2)
    - name: "Average Amount 2"
      expr: AVG(amount_2)
    - name: "Total Amount 3"
      expr: SUM(amount_3)
    - name: "Average Amount 3"
      expr: AVG(amount_3)
    - name: "Total Coinsurance Pct"
      expr: SUM(coinsurance_pct)
    - name: "Average Coinsurance Pct"
      expr: AVG(coinsurance_pct)
    - name: "Total Itv Ratio"
      expr: SUM(itv_ratio)
    - name: "Average Itv Ratio"
      expr: AVG(itv_ratio)
    - name: "Total Med Expense Limit"
      expr: SUM(med_expense_limit)
    - name: "Average Med Expense Limit"
      expr: AVG(med_expense_limit)
    - name: "Total Personal Adv Injury Limit"
      expr: SUM(personal_adv_injury_limit)
    - name: "Average Personal Adv Injury Limit"
      expr: AVG(personal_adv_injury_limit)
    - name: "Total Pml Amount"
      expr: SUM(pml_amount)
    - name: "Average Pml Amount"
      expr: AVG(pml_amount)
    - name: "Total Products Completed Ops Aggregate"
      expr: SUM(products_completed_ops_aggregate)
    - name: "Average Products Completed Ops Aggregate"
      expr: AVG(products_completed_ops_aggregate)
    - name: "Total Reinstatement Premium Pct"
      expr: SUM(reinstatement_premium_pct)
    - name: "Average Reinstatement Premium Pct"
      expr: AVG(reinstatement_premium_pct)
    - name: "Total Ri Retention Amount"
      expr: SUM(ri_retention_amount)
    - name: "Average Ri Retention Amount"
      expr: AVG(ri_retention_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_named_insured`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Named Insured business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`named_insured`"
  dimensions:
    - name: "Consent To Electronic Delivery"
      expr: consent_to_electronic_delivery
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Credit Score Tier"
      expr: credit_score_tier
    - name: "Date Of Birth"
      expr: date_of_birth
    - name: "Date Of Incorporation"
      expr: date_of_incorporation
    - name: "Dba Name"
      expr: dba_name
    - name: "Effective Date"
      expr: effective_date
    - name: "Email"
      expr: email
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Fein"
      expr: fein
    - name: "Gender"
      expr: gender
    - name: "Insured Role"
      expr: insured_role
    - name: "Insured Type"
      expr: insured_type
    - name: "Is First Named"
      expr: is_first_named
    - name: "Is Primary Contact"
      expr: is_primary_contact
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Named Insured"
      expr: COUNT(DISTINCT named_insured_id)
    - name: "Total Annual Payroll"
      expr: SUM(annual_payroll)
    - name: "Average Annual Payroll"
      expr: AVG(annual_payroll)
    - name: "Total Annual Revenue"
      expr: SUM(annual_revenue)
    - name: "Average Annual Revenue"
      expr: AVG(annual_revenue)
    - name: "Total Num Employees"
      expr: SUM(num_employees)
    - name: "Average Num Employees"
      expr: AVG(num_employees)
    - name: "Total Sequence Number"
      expr: SUM(sequence_number)
    - name: "Average Sequence Number"
      expr: AVG(sequence_number)
    - name: "Total Years In Business"
      expr: SUM(years_in_business)
    - name: "Average Years In Business"
      expr: AVG(years_in_business)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_part`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`vibe_pc_insurance_v499`.`coverage`.`part`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_peril`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Peril business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`peril`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Peril"
      expr: COUNT(DISTINCT peril_id)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_product`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Product business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`product`"
  dimensions:
    - name: "Aggregate Limit Applies"
      expr: aggregate_limit_applies
    - name: "Audit Required"
      expr: audit_required
    - name: "Cancellation Allowed"
      expr: cancellation_allowed
    - name: "Catastrophe Exposure Flag"
      expr: catastrophe_exposure_flag
    - name: "Claims Made Retroactive Date"
      expr: claims_made_retroactive_date
    - name: "Coverage Basis"
      expr: coverage_basis
    - name: "Created By User"
      expr: created_by_user
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Endorsement Allowed"
      expr: endorsement_allowed
    - name: "Filing Effective Date"
      expr: filing_effective_date
    - name: "Filing Expiration Date"
      expr: filing_expiration_date
    - name: "Form Edition Date"
      expr: form_edition_date
    - name: "Form Number"
      expr: form_number
    - name: "Installment Billing Allowed"
      expr: installment_billing_allowed
    - name: "Iso Class Code"
      expr: iso_class_code
    - name: "Line Of Business"
      expr: line_of_business
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Product"
      expr: COUNT(DISTINCT product_id)
    - name: "Total Commission Rate Percent"
      expr: SUM(commission_rate_percent)
    - name: "Average Commission Rate Percent"
      expr: AVG(commission_rate_percent)
    - name: "Total Default Deductible Amount"
      expr: SUM(default_deductible_amount)
    - name: "Average Default Deductible Amount"
      expr: AVG(default_deductible_amount)
    - name: "Total Default Limit Amount"
      expr: SUM(default_limit_amount)
    - name: "Average Default Limit Amount"
      expr: AVG(default_limit_amount)
    - name: "Total Extended Reporting Period Months"
      expr: SUM(extended_reporting_period_months)
    - name: "Average Extended Reporting Period Months"
      expr: AVG(extended_reporting_period_months)
    - name: "Total Maximum Premium Amount"
      expr: SUM(maximum_premium_amount)
    - name: "Average Maximum Premium Amount"
      expr: AVG(maximum_premium_amount)
    - name: "Total Minimum Premium Amount"
      expr: SUM(minimum_premium_amount)
    - name: "Average Minimum Premium Amount"
      expr: AVG(minimum_premium_amount)
    - name: "Total Policy Term Months"
      expr: SUM(policy_term_months)
    - name: "Average Policy Term Months"
      expr: AVG(policy_term_months)
    - name: "Total Self Insured Retention Amount"
      expr: SUM(self_insured_retention_amount)
    - name: "Average Self Insured Retention Amount"
      expr: AVG(self_insured_retention_amount)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_sir_layer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Sir Layer business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`sir_layer`"
  dimensions:
    - name: "Alae Treatment"
      expr: alae_treatment
    - name: "Claims Made Flag"
      expr: claims_made_flag
    - name: "Collateral Expiry Date"
      expr: collateral_expiry_date
    - name: "Collateral Required"
      expr: collateral_required
    - name: "Collateral Type"
      expr: collateral_type
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Currency Code"
      expr: currency_code
    - name: "Defense Inside Sir"
      expr: defense_inside_sir
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Number"
      expr: endorsement_number
    - name: "Erosion Basis"
      expr: erosion_basis
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Form Edition Date"
      expr: form_edition_date
    - name: "Form Number"
      expr: form_number
    - name: "Insured Defense Obligation"
      expr: insured_defense_obligation
    - name: "Insured Financial Rating"
      expr: insured_financial_rating
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Sir Layer"
      expr: COUNT(DISTINCT sir_layer_id)
    - name: "Total Aggregate Limit"
      expr: SUM(aggregate_limit)
    - name: "Average Aggregate Limit"
      expr: AVG(aggregate_limit)
    - name: "Total Aggregate Sir Cap"
      expr: SUM(aggregate_sir_cap)
    - name: "Average Aggregate Sir Cap"
      expr: AVG(aggregate_sir_cap)
    - name: "Total Collateral Amount"
      expr: SUM(collateral_amount)
    - name: "Average Collateral Amount"
      expr: AVG(collateral_amount)
    - name: "Total Extended Reporting Period Days"
      expr: SUM(extended_reporting_period_days)
    - name: "Average Extended Reporting Period Days"
      expr: AVG(extended_reporting_period_days)
    - name: "Total Minimum Sir Premium"
      expr: SUM(minimum_sir_premium)
    - name: "Average Minimum Sir Premium"
      expr: AVG(minimum_sir_premium)
    - name: "Total Occurrence Limit"
      expr: SUM(occurrence_limit)
    - name: "Average Occurrence Limit"
      expr: AVG(occurrence_limit)
    - name: "Total Ri Attachment Point"
      expr: SUM(ri_attachment_point)
    - name: "Average Ri Attachment Point"
      expr: AVG(ri_attachment_point)
    - name: "Total Sir Aggregate Eroded Amount"
      expr: SUM(sir_aggregate_eroded_amount)
    - name: "Average Sir Aggregate Eroded Amount"
      expr: AVG(sir_aggregate_eroded_amount)
    - name: "Total Sir Amount"
      expr: SUM(sir_amount)
    - name: "Average Sir Amount"
      expr: AVG(sir_amount)
    - name: "Total Sir Per Occurrence Eroded Amount"
      expr: SUM(sir_per_occurrence_eroded_amount)
    - name: "Average Sir Per Occurrence Eroded Amount"
      expr: AVG(sir_per_occurrence_eroded_amount)
    - name: "Total Sir Premium Credit"
      expr: SUM(sir_premium_credit)
    - name: "Average Sir Premium Credit"
      expr: AVG(sir_premium_credit)
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_v499`.`_metrics`.`coverage_waiver_of_subrogation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Waiver Of Subrogation business metrics"
  source: "`vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation`"
  dimensions:
    - name: "Beneficiary Fein"
      expr: beneficiary_fein
    - name: "Beneficiary Name"
      expr: beneficiary_name
    - name: "Beneficiary Relationship"
      expr: beneficiary_relationship
    - name: "Beneficiary Type"
      expr: beneficiary_type
    - name: "Blanket Waiver Flag"
      expr: blanket_waiver_flag
    - name: "Cancellation Date"
      expr: cancellation_date
    - name: "Cancellation Reason"
      expr: cancellation_reason
    - name: "Contractual Requirement Flag"
      expr: contractual_requirement_flag
    - name: "Coverage Scope"
      expr: coverage_scope
    - name: "Created Timestamp"
      expr: created_timestamp
    - name: "Effective Date"
      expr: effective_date
    - name: "Endorsement Status"
      expr: endorsement_status
    - name: "Exclusion Notes"
      expr: exclusion_notes
    - name: "Expiration Date"
      expr: expiration_date
    - name: "Lob Code"
      expr: lob_code
    - name: "Location Description"
      expr: location_description
  measures:
    - name: "Row Count"
      expr: COUNT(1)
    - name: "Distinct Waiver Of Subrogation"
      expr: COUNT(DISTINCT waiver_of_subrogation_id)
    - name: "Total Additional Premium"
      expr: SUM(additional_premium)
    - name: "Average Additional Premium"
      expr: AVG(additional_premium)
$$;