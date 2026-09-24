-- Metric views for domain: claims | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claim`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core claim lifecycle KPIs: claim counts, catastrophe exposure, litigation and fraud rates, and loss reporting lag. Grain: one row per reported claim."
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claim`"
  dimensions:
    - name: "claim_status"
      expr: claim_status
      comment: "Current status of the claim (Open, Closed, Reopened, Denied)."
    - name: "catastrophe_flag"
      expr: catastrophe_flag
      comment: "Indicates whether the claim is associated with a catastrophe event."
    - name: "litigation_flag"
      expr: litigation_flag
      comment: "Indicates whether the claim is in litigation."
    - name: "siu_flag"
      expr: siu_flag
      comment: "Special Investigation Unit flag indicating potential fraud."
    - name: "subrogation_flag"
      expr: subrogation_flag
      comment: "Indicates whether subrogation recovery is being pursued."
    - name: "salvage_flag"
      expr: salvage_flag
      comment: "Indicates whether salvage recovery is expected."
    - name: "reinsurance_flag"
      expr: reinsurance_flag
      comment: "Indicates whether the claim is ceded to reinsurance."
    - name: "accident_year"
      expr: accident_year
      comment: "Year in which the loss occurred, used for loss development and reserving."
    - name: "report_year"
      expr: report_year
      comment: "Year in which the claim was reported, used for IBNR and lag analysis."
    - name: "policy_year"
      expr: policy_year
      comment: "Policy year associated with the claim, used for underwriting year analysis."
    - name: "loss_date"
      expr: loss_date
      comment: "Date the loss occurred."
    - name: "fnol_date"
      expr: fnol_date
      comment: "First Notice of Loss date, when the claim was first reported."
    - name: "close_date"
      expr: close_date
      comment: "Date the claim was closed."
  measures:
    - name: "total_claims"
      expr: COUNT(1)
      comment: "Total number of claims reported."
    - name: "catastrophe_claim_count"
      expr: SUM(CAST(CASE WHEN catastrophe_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claims associated with catastrophe events."
    - name: "litigation_claim_count"
      expr: SUM(CAST(CASE WHEN litigation_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claims in litigation."
    - name: "fraud_referral_count"
      expr: SUM(CAST(CASE WHEN siu_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claims referred to Special Investigation Unit for fraud review."
    - name: "subrogation_claim_count"
      expr: SUM(CAST(CASE WHEN subrogation_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claims with subrogation recovery potential."
    - name: "reinsurance_ceded_claim_count"
      expr: SUM(CAST(CASE WHEN reinsurance_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claims ceded to reinsurance."
    - name: "catastrophe_claim_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN catastrophe_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claims that are catastrophe-related, key for exposure management."
    - name: "litigation_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN litigation_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claims in litigation, key driver of defense costs and settlement strategy."
    - name: "fraud_referral_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN siu_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claims referred for fraud investigation, indicator of fraud exposure."
    - name: "subrogation_pursuit_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN subrogation_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claims with subrogation potential, impacts net incurred loss."
    - name: "reinsurance_cession_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN reinsurance_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claims ceded to reinsurance, key for capital and risk transfer analysis."
    - name: "distinct_accident_years"
      expr: COUNT(DISTINCT accident_year)
      comment: "Number of distinct accident years with claims, used for loss development trending."
    - name: "distinct_policies"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of distinct policies with claims, used for claim frequency analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claim_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Per-coverage claim exposure KPIs: incurred loss, paid loss, outstanding reserves, LAE, recoveries, and loss ratios. Grain: one row per coverage line per claim."
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`"
  dimensions:
    - name: "exposure_status"
      expr: exposure_status
      comment: "Status of the claim exposure (Open, Closed, Denied, Settled)."
    - name: "coverage_type"
      expr: coverage_type
      comment: "Type of coverage (e.g., Property Damage, Bodily Injury, Collision, Comprehensive)."
    - name: "catastrophe_flag"
      expr: catastrophe_flag
      comment: "Indicates whether the exposure is catastrophe-related."
    - name: "fraud_flag"
      expr: fraud_flag
      comment: "Indicates potential fraud on this exposure."
    - name: "litigation_flag"
      expr: litigation_flag
      comment: "Indicates whether this exposure is in litigation."
    - name: "subrogation_potential_flag"
      expr: subrogation_potential_flag
      comment: "Indicates subrogation recovery potential for this exposure."
    - name: "salvage_potential_flag"
      expr: salvage_potential_flag
      comment: "Indicates salvage recovery potential for this exposure."
    - name: "reinsurance_ceded_flag"
      expr: reinsurance_ceded_flag
      comment: "Indicates whether this exposure is ceded to reinsurance."
    - name: "liability_indicator"
      expr: liability_indicator
      comment: "Indicates whether this is a liability exposure (vs. property)."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year for loss development and reserving analysis."
    - name: "report_year"
      expr: report_year
      comment: "Report year for IBNR and lag analysis."
    - name: "loss_date"
      expr: loss_date
      comment: "Date the loss occurred."
    - name: "reported_date"
      expr: reported_date
      comment: "Date the exposure was reported."
    - name: "closed_date"
      expr: closed_date
      comment: "Date the exposure was closed."
  measures:
    - name: "total_exposures"
      expr: COUNT(1)
      comment: "Total number of claim exposures (coverage lines within claims)."
    - name: "total_incurred_amount"
      expr: SUM(CAST(incurred_amount AS DOUBLE))
      comment: "Total incurred loss (paid + outstanding reserves), the primary loss metric for reserving and profitability."
    - name: "total_paid_amount"
      expr: SUM(CAST(paid_amount AS DOUBLE))
      comment: "Total paid loss, key for cash flow and settlement analysis."
    - name: "total_outstanding_reserve"
      expr: SUM(CAST(outstanding_reserve_amount AS DOUBLE))
      comment: "Total outstanding case reserves, key for reserve adequacy and IBNR estimation."
    - name: "total_lae_paid"
      expr: SUM(CAST(lae_paid_amount AS DOUBLE))
      comment: "Total Loss Adjustment Expense paid, key component of total claim cost."
    - name: "total_lae_reserve"
      expr: SUM(CAST(lae_reserve_amount AS DOUBLE))
      comment: "Total Loss Adjustment Expense reserved, key for total incurred LAE."
    - name: "total_recovery_amount"
      expr: SUM(CAST(recovery_amount AS DOUBLE))
      comment: "Total recoveries (subrogation, salvage, reinsurance), reduces net incurred loss."
    - name: "total_deductible_amount"
      expr: SUM(CAST(deductible_amount AS DOUBLE))
      comment: "Total deductibles applied, reduces insurer net loss."
    - name: "total_coverage_limit"
      expr: SUM(CAST(coverage_limit_amount AS DOUBLE))
      comment: "Total coverage limits across exposures, used for exposure and adequacy analysis."
    - name: "avg_incurred_per_exposure"
      expr: AVG(CAST(incurred_amount AS DOUBLE))
      comment: "Average incurred loss per exposure, key severity metric for pricing and reserving."
    - name: "avg_paid_per_exposure"
      expr: AVG(CAST(paid_amount AS DOUBLE))
      comment: "Average paid loss per exposure, key for settlement pattern analysis."
    - name: "avg_reserve_per_exposure"
      expr: AVG(CAST(outstanding_reserve_amount AS DOUBLE))
      comment: "Average outstanding reserve per exposure, indicator of reserve adequacy."
    - name: "catastrophe_exposure_count"
      expr: SUM(CAST(CASE WHEN catastrophe_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of catastrophe-related exposures."
    - name: "fraud_exposure_count"
      expr: SUM(CAST(CASE WHEN fraud_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of exposures flagged for fraud."
    - name: "litigation_exposure_count"
      expr: SUM(CAST(CASE WHEN litigation_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of exposures in litigation."
    - name: "subrogation_exposure_count"
      expr: SUM(CAST(CASE WHEN subrogation_potential_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of exposures with subrogation potential."
    - name: "reinsurance_ceded_exposure_count"
      expr: SUM(CAST(CASE WHEN reinsurance_ceded_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of exposures ceded to reinsurance."
    - name: "catastrophe_incurred_amount"
      expr: SUM(CASE WHEN catastrophe_flag = TRUE THEN CAST(incurred_amount AS DOUBLE) ELSE 0 END)
      comment: "Total incurred loss for catastrophe exposures, key for cat modeling and reinsurance."
    - name: "litigation_incurred_amount"
      expr: SUM(CASE WHEN litigation_flag = TRUE THEN CAST(incurred_amount AS DOUBLE) ELSE 0 END)
      comment: "Total incurred loss for litigated exposures, key for defense cost and settlement strategy."
    - name: "fraud_incurred_amount"
      expr: SUM(CASE WHEN fraud_flag = TRUE THEN CAST(incurred_amount AS DOUBLE) ELSE 0 END)
      comment: "Total incurred loss for fraud-flagged exposures, key for fraud impact analysis."
    - name: "distinct_claims"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with exposures, used for claim complexity analysis."
    - name: "distinct_coverages"
      expr: COUNT(DISTINCT coverage_id)
      comment: "Number of distinct coverages involved, used for coverage mix analysis."
    - name: "distinct_policies"
      expr: COUNT(DISTINCT policy_term_id)
      comment: "Number of distinct policy terms with exposures, used for policy-level loss analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_loss_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Loss event KPIs: event counts, catastrophe events, large loss events, injury and fatality rates, and estimated loss severity. Grain: one row per loss event."
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`loss_event`"
  dimensions:
    - name: "loss_event_status"
      expr: loss_event_status
      comment: "Status of the loss event (Open, Closed, Under Investigation)."
    - name: "loss_event_type"
      expr: loss_event_type
      comment: "Type of loss event (e.g., Auto Accident, Fire, Theft, Weather)."
    - name: "is_catastrophe_loss"
      expr: is_catastrophe_loss
      comment: "Indicates whether the loss event is a catastrophe."
    - name: "is_large_loss"
      expr: is_large_loss
      comment: "Indicates whether the loss event exceeds the large loss threshold."
    - name: "injury_occurred"
      expr: injury_occurred
      comment: "Indicates whether injuries occurred in the loss event."
    - name: "fatality_occurred"
      expr: fatality_occurred
      comment: "Indicates whether fatalities occurred in the loss event."
    - name: "fraud_indicator"
      expr: fraud_indicator
      comment: "Indicates potential fraud associated with the loss event."
    - name: "subrogation_potential"
      expr: subrogation_potential
      comment: "Indicates subrogation recovery potential for the loss event."
    - name: "salvage_potential"
      expr: salvage_potential
      comment: "Indicates salvage recovery potential for the loss event."
    - name: "third_party_involved"
      expr: third_party_involved
      comment: "Indicates whether third parties are involved in the loss event."
    - name: "police_report_filed"
      expr: police_report_filed
      comment: "Indicates whether a police report was filed for the loss event."
    - name: "fire_department_notified"
      expr: fire_department_notified
      comment: "Indicates whether the fire department was notified."
    - name: "loss_severity_code"
      expr: loss_severity_code
      comment: "Severity classification of the loss (Minor, Moderate, Major, Catastrophic)."
    - name: "loss_complexity_code"
      expr: loss_complexity_code
      comment: "Complexity classification of the loss (Simple, Moderate, Complex)."
    - name: "loss_occurrence_date"
      expr: loss_occurrence_date
      comment: "Date the loss occurred."
    - name: "loss_reported_date"
      expr: loss_reported_date
      comment: "Date the loss was reported."
  measures:
    - name: "total_loss_events"
      expr: COUNT(1)
      comment: "Total number of loss events."
    - name: "catastrophe_event_count"
      expr: SUM(CAST(CASE WHEN is_catastrophe_loss = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of catastrophe loss events, key for cat exposure and reinsurance."
    - name: "large_loss_event_count"
      expr: SUM(CAST(CASE WHEN is_large_loss = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of large loss events exceeding threshold, key for excess reinsurance and capital."
    - name: "injury_event_count"
      expr: SUM(CAST(CASE WHEN injury_occurred = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of loss events with injuries, key for bodily injury exposure."
    - name: "fatality_event_count"
      expr: SUM(CAST(CASE WHEN fatality_occurred = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of loss events with fatalities, key for high-severity liability exposure."
    - name: "fraud_event_count"
      expr: SUM(CAST(CASE WHEN fraud_indicator = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of loss events with fraud indicators."
    - name: "subrogation_potential_event_count"
      expr: SUM(CAST(CASE WHEN subrogation_potential = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of loss events with subrogation potential."
    - name: "third_party_event_count"
      expr: SUM(CAST(CASE WHEN third_party_involved = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of loss events involving third parties, key for liability exposure."
    - name: "police_report_event_count"
      expr: SUM(CAST(CASE WHEN police_report_filed = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of loss events with police reports filed."
    - name: "total_estimated_loss"
      expr: SUM(CAST(estimated_total_loss_amount AS DOUBLE))
      comment: "Total estimated loss amount across all events, key for initial reserve setting."
    - name: "avg_estimated_loss_per_event"
      expr: AVG(CAST(estimated_total_loss_amount AS DOUBLE))
      comment: "Average estimated loss per event, key severity indicator for loss forecasting."
    - name: "total_injuries"
      expr: SUM(CAST(number_of_injuries AS BIGINT))
      comment: "Total number of injuries across all loss events."
    - name: "total_fatalities"
      expr: SUM(CAST(number_of_fatalities AS BIGINT))
      comment: "Total number of fatalities across all loss events."
    - name: "catastrophe_event_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_catastrophe_loss = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of loss events that are catastrophes, key for cat exposure management."
    - name: "large_loss_event_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_large_loss = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of loss events that are large losses, key for excess reinsurance strategy."
    - name: "injury_event_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN injury_occurred = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of loss events with injuries, key for bodily injury pricing."
    - name: "fatality_event_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN fatality_occurred = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of loss events with fatalities, key for high-severity liability risk."
    - name: "fraud_event_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN fraud_indicator = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of loss events with fraud indicators, key for fraud prevention strategy."
    - name: "third_party_event_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN third_party_involved = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of loss events involving third parties, key for liability exposure."
    - name: "distinct_catastrophe_events"
      expr: COUNT(DISTINCT catastrophe_event_id)
      comment: "Number of distinct catastrophe events, used for cat event aggregation."
    - name: "distinct_perils"
      expr: COUNT(DISTINCT peril_id)
      comment: "Number of distinct perils involved, used for peril mix analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_adjuster`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Adjuster performance and capacity KPIs: caseload, capacity utilization, authority limits, and adjuster qualifications. Grain: one row per adjuster."
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`adjuster`"
  dimensions:
    - name: "adjuster_status"
      expr: adjuster_status
      comment: "Current status of the adjuster (Active, Inactive, On Leave, Terminated)."
    - name: "adjuster_type"
      expr: adjuster_type
      comment: "Type of adjuster (Staff, Independent, Vendor, Catastrophe)."
    - name: "catastrophe_qualified_flag"
      expr: catastrophe_qualified_flag
      comment: "Indicates whether the adjuster is qualified for catastrophe assignments."
    - name: "field_adjuster_flag"
      expr: field_adjuster_flag
      comment: "Indicates whether the adjuster is a field adjuster (vs. desk adjuster)."
    - name: "multi_state_licensed_flag"
      expr: multi_state_licensed_flag
      comment: "Indicates whether the adjuster is licensed in multiple states."
    - name: "performance_rating"
      expr: performance_rating
      comment: "Performance rating of the adjuster (Excellent, Good, Satisfactory, Needs Improvement)."
    - name: "service_territory"
      expr: service_territory
      comment: "Geographic service territory assigned to the adjuster."
    - name: "specialty_lines"
      expr: specialty_lines
      comment: "Specialty lines of business the adjuster handles (e.g., Auto, Property, Liability)."
    - name: "home_office_location"
      expr: home_office_location
      comment: "Home office location of the adjuster."
    - name: "hire_date"
      expr: hire_date
      comment: "Date the adjuster was hired."
    - name: "termination_date"
      expr: termination_date
      comment: "Date the adjuster was terminated (if applicable)."
  measures:
    - name: "total_adjusters"
      expr: COUNT(1)
      comment: "Total number of adjusters."
    - name: "active_adjuster_count"
      expr: SUM(CAST(CASE WHEN adjuster_status = 'Active' THEN 1 ELSE 0 END AS INT))
      comment: "Number of active adjusters, key for capacity planning."
    - name: "catastrophe_qualified_adjuster_count"
      expr: SUM(CAST(CASE WHEN catastrophe_qualified_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of catastrophe-qualified adjusters, key for cat response capacity."
    - name: "field_adjuster_count"
      expr: SUM(CAST(CASE WHEN field_adjuster_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of field adjusters, key for field inspection capacity."
    - name: "multi_state_licensed_adjuster_count"
      expr: SUM(CAST(CASE WHEN multi_state_licensed_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of multi-state licensed adjusters, key for geographic flexibility."
    - name: "total_current_caseload"
      expr: SUM(CAST(current_caseload_count AS BIGINT))
      comment: "Total current caseload across all adjusters, key for workload management."
    - name: "total_max_capacity"
      expr: SUM(CAST(max_caseload_capacity AS BIGINT))
      comment: "Total maximum caseload capacity across all adjusters, key for capacity planning."
    - name: "avg_current_caseload"
      expr: AVG(CAST(current_caseload_count AS DOUBLE))
      comment: "Average current caseload per adjuster, key workload indicator."
    - name: "avg_max_capacity"
      expr: AVG(CAST(max_caseload_capacity AS DOUBLE))
      comment: "Average maximum caseload capacity per adjuster."
    - name: "avg_years_experience"
      expr: AVG(CAST(years_experience AS DOUBLE))
      comment: "Average years of experience across adjusters, indicator of adjuster quality."
    - name: "total_max_claim_authority"
      expr: SUM(CAST(max_claim_authority AS DOUBLE))
      comment: "Total maximum claim settlement authority across all adjusters."
    - name: "avg_max_claim_authority"
      expr: AVG(CAST(max_claim_authority AS DOUBLE))
      comment: "Average maximum claim settlement authority per adjuster, key for delegation strategy."
    - name: "distinct_service_territories"
      expr: COUNT(DISTINCT service_territory)
      comment: "Number of distinct service territories covered by adjusters."
    - name: "distinct_specialty_lines"
      expr: COUNT(DISTINCT specialty_lines)
      comment: "Number of distinct specialty lines covered by adjusters."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_claimant`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Claimant KPIs: claimant counts, attorney representation rate, settlement demand vs offer analysis, and fraud indicators. Grain: one row per claimant per claim."
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`claimant`"
  dimensions:
    - name: "claimant_status"
      expr: claimant_status
      comment: "Status of the claimant (Active, Settled, Denied, Withdrawn)."
    - name: "claimant_type"
      expr: claimant_type
      comment: "Type of claimant (First Party, Third Party, Subrogation)."
    - name: "relationship_to_insured"
      expr: relationship_to_insured
      comment: "Relationship of the claimant to the insured (Insured, Spouse, Passenger, Other Driver, Pedestrian)."
    - name: "represented_by_attorney_flag"
      expr: represented_by_attorney_flag
      comment: "Indicates whether the claimant is represented by an attorney."
    - name: "fraud_indicator_flag"
      expr: fraud_indicator_flag
      comment: "Indicates potential fraud associated with the claimant."
    - name: "subrogation_potential_flag"
      expr: subrogation_potential_flag
      comment: "Indicates subrogation potential against the claimant."
    - name: "minor_flag"
      expr: minor_flag
      comment: "Indicates whether the claimant is a minor."
    - name: "hospitalization_flag"
      expr: hospitalization_flag
      comment: "Indicates whether the claimant was hospitalized."
    - name: "medical_treatment_required_flag"
      expr: medical_treatment_required_flag
      comment: "Indicates whether medical treatment was required."
    - name: "release_signed_flag"
      expr: release_signed_flag
      comment: "Indicates whether the claimant has signed a release."
    - name: "injury_type"
      expr: injury_type
      comment: "Type of injury sustained by the claimant (e.g., Soft Tissue, Fracture, Head Injury)."
    - name: "injury_severity_code"
      expr: injury_severity_code
      comment: "Severity code of the injury (Minor, Moderate, Severe, Critical)."
    - name: "fault_indicator"
      expr: fault_indicator
      comment: "Indicates whether the claimant is at fault."
    - name: "date_of_injury"
      expr: date_of_injury
      comment: "Date the claimant was injured."
    - name: "settlement_date"
      expr: settlement_date
      comment: "Date the claimant settlement was finalized."
  measures:
    - name: "total_claimants"
      expr: COUNT(1)
      comment: "Total number of claimants."
    - name: "attorney_represented_claimant_count"
      expr: SUM(CAST(CASE WHEN represented_by_attorney_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claimants represented by attorneys, key driver of settlement cost and litigation."
    - name: "fraud_claimant_count"
      expr: SUM(CAST(CASE WHEN fraud_indicator_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claimants with fraud indicators."
    - name: "minor_claimant_count"
      expr: SUM(CAST(CASE WHEN minor_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of minor claimants, key for guardian and settlement approval processes."
    - name: "hospitalized_claimant_count"
      expr: SUM(CAST(CASE WHEN hospitalization_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claimants who were hospitalized, indicator of injury severity."
    - name: "medical_treatment_claimant_count"
      expr: SUM(CAST(CASE WHEN medical_treatment_required_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claimants requiring medical treatment."
    - name: "release_signed_claimant_count"
      expr: SUM(CAST(CASE WHEN release_signed_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of claimants who have signed releases, key for claim closure."
    - name: "total_settlement_demand"
      expr: SUM(CAST(settlement_demand_amount AS DOUBLE))
      comment: "Total settlement demand amount across all claimants."
    - name: "total_settlement_offer"
      expr: SUM(CAST(settlement_offer_amount AS DOUBLE))
      comment: "Total settlement offer amount across all claimants."
    - name: "avg_settlement_demand"
      expr: AVG(CAST(settlement_demand_amount AS DOUBLE))
      comment: "Average settlement demand per claimant, key for settlement negotiation strategy."
    - name: "avg_settlement_offer"
      expr: AVG(CAST(settlement_offer_amount AS DOUBLE))
      comment: "Average settlement offer per claimant, key for settlement cost forecasting."
    - name: "avg_liability_percentage"
      expr: AVG(CAST(liability_percentage AS DOUBLE))
      comment: "Average liability percentage assigned to claimants, key for comparative negligence analysis."
    - name: "attorney_representation_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN represented_by_attorney_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claimants represented by attorneys, key driver of defense costs and settlement amounts."
    - name: "fraud_claimant_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN fraud_indicator_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claimants with fraud indicators, key for fraud prevention strategy."
    - name: "hospitalization_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN hospitalization_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claimants hospitalized, indicator of injury severity and cost."
    - name: "release_signed_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN release_signed_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of claimants who have signed releases, key for claim closure efficiency."
    - name: "distinct_claims"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with claimants, used for multi-claimant claim analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_fnol`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "First Notice of Loss KPIs: FNOL counts, triage priority distribution, fraud indicators, and claim conversion rate. Grain: one row per FNOL report."
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`fnol`"
  dimensions:
    - name: "fnol_status"
      expr: fnol_status
      comment: "Status of the FNOL (Pending, Claim Opened, Rejected, Under Review)."
    - name: "report_channel"
      expr: report_channel
      comment: "Channel through which the FNOL was reported (Phone, Web, Mobile App, Agent, Email)."
    - name: "triage_priority"
      expr: triage_priority
      comment: "Triage priority assigned to the FNOL (High, Medium, Low, Urgent)."
    - name: "cat_event_flag"
      expr: cat_event_flag
      comment: "Indicates whether the FNOL is associated with a catastrophe event."
    - name: "fraud_indicator_flag"
      expr: fraud_indicator_flag
      comment: "Indicates potential fraud associated with the FNOL."
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Indicates whether the FNOL was referred to SIU."
    - name: "claim_opened_flag"
      expr: claim_opened_flag
      comment: "Indicates whether a claim was opened from the FNOL."
    - name: "injury_flag"
      expr: injury_flag
      comment: "Indicates whether injuries were reported in the FNOL."
    - name: "fatality_flag"
      expr: fatality_flag
      comment: "Indicates whether fatalities were reported in the FNOL."
    - name: "property_damage_flag"
      expr: property_damage_flag
      comment: "Indicates whether property damage was reported in the FNOL."
    - name: "third_party_involved_flag"
      expr: third_party_involved_flag
      comment: "Indicates whether third parties are involved in the FNOL."
    - name: "police_report_filed_flag"
      expr: police_report_filed_flag
      comment: "Indicates whether a police report was filed."
    - name: "loss_cause"
      expr: loss_cause
      comment: "Cause of the loss reported in the FNOL (e.g., Collision, Fire, Theft, Weather)."
    - name: "loss_date"
      expr: loss_date
      comment: "Date the loss occurred."
    - name: "report_date"
      expr: report_date
      comment: "Date the FNOL was reported."
  measures:
    - name: "total_fnol_reports"
      expr: COUNT(1)
      comment: "Total number of FNOL reports received."
    - name: "claim_opened_count"
      expr: SUM(CAST(CASE WHEN claim_opened_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs that resulted in opened claims."
    - name: "cat_event_fnol_count"
      expr: SUM(CAST(CASE WHEN cat_event_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs associated with catastrophe events."
    - name: "fraud_indicator_fnol_count"
      expr: SUM(CAST(CASE WHEN fraud_indicator_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs with fraud indicators."
    - name: "siu_referral_fnol_count"
      expr: SUM(CAST(CASE WHEN siu_referral_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs referred to SIU."
    - name: "injury_fnol_count"
      expr: SUM(CAST(CASE WHEN injury_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs reporting injuries."
    - name: "fatality_fnol_count"
      expr: SUM(CAST(CASE WHEN fatality_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs reporting fatalities."
    - name: "property_damage_fnol_count"
      expr: SUM(CAST(CASE WHEN property_damage_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs reporting property damage."
    - name: "third_party_fnol_count"
      expr: SUM(CAST(CASE WHEN third_party_involved_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs involving third parties."
    - name: "police_report_fnol_count"
      expr: SUM(CAST(CASE WHEN police_report_filed_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of FNOLs with police reports filed."
    - name: "total_estimated_loss"
      expr: SUM(CAST(estimated_loss_amount AS DOUBLE))
      comment: "Total estimated loss amount reported in FNOLs."
    - name: "avg_estimated_loss"
      expr: AVG(CAST(estimated_loss_amount AS DOUBLE))
      comment: "Average estimated loss per FNOL, key for initial reserve setting."
    - name: "claim_conversion_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN claim_opened_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of FNOLs that convert to opened claims, key for intake efficiency and fraud detection."
    - name: "fraud_indicator_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN fraud_indicator_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of FNOLs with fraud indicators, key for fraud prevention strategy."
    - name: "siu_referral_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN siu_referral_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of FNOLs referred to SIU, indicator of fraud exposure."
    - name: "injury_fnol_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN injury_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of FNOLs reporting injuries, key for bodily injury exposure."
    - name: "fatality_fnol_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN fatality_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of FNOLs reporting fatalities, key for high-severity liability exposure."
    - name: "third_party_fnol_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN third_party_involved_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of FNOLs involving third parties, key for liability exposure."
    - name: "distinct_policies"
      expr: COUNT(DISTINCT policy_id)
      comment: "Number of distinct policies with FNOLs, used for policy-level FNOL frequency analysis."
    - name: "distinct_reporters"
      expr: COUNT(DISTINCT reporter_party_id)
      comment: "Number of distinct reporters, used for reporter pattern analysis."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`claims_litigation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Litigation KPIs: lawsuit counts, defense costs, settlement vs verdict analysis, and litigation outcome rates. Grain: one row per lawsuit."
  source: "`vibe_pc_insurance_blog_v499`.`claims`.`litigation`"
  dimensions:
    - name: "litigation_status"
      expr: litigation_status
      comment: "Status of the litigation (Active, Settled, Dismissed, Verdict, Appeal)."
    - name: "litigation_type"
      expr: litigation_type
      comment: "Type of litigation (Civil, Arbitration, Mediation, Small Claims)."
    - name: "court_type"
      expr: court_type
      comment: "Type of court (District, Superior, Federal, Appellate)."
    - name: "verdict_type"
      expr: verdict_type
      comment: "Type of verdict (Plaintiff, Defense, Split, Hung Jury)."
    - name: "appeal_filed_flag"
      expr: appeal_filed_flag
      comment: "Indicates whether an appeal has been filed."
    - name: "confidentiality_flag"
      expr: confidentiality_flag
      comment: "Indicates whether the litigation is subject to confidentiality."
    - name: "cause_of_action"
      expr: cause_of_action
      comment: "Legal cause of action (e.g., Negligence, Breach of Contract, Bad Faith)."
    - name: "venue_state"
      expr: venue_state
      comment: "State where the litigation is filed."
    - name: "venue_county"
      expr: venue_county
      comment: "County where the litigation is filed."
    - name: "filing_date"
      expr: filing_date
      comment: "Date the lawsuit was filed."
    - name: "trial_date"
      expr: trial_date
      comment: "Date of the trial."
    - name: "settlement_date"
      expr: settlement_date
      comment: "Date the litigation was settled."
    - name: "verdict_date"
      expr: verdict_date
      comment: "Date the verdict was rendered."
  measures:
    - name: "total_lawsuits"
      expr: COUNT(1)
      comment: "Total number of lawsuits."
    - name: "active_lawsuit_count"
      expr: SUM(CAST(CASE WHEN litigation_status = 'Active' THEN 1 ELSE 0 END AS INT))
      comment: "Number of active lawsuits, key for litigation exposure and defense cost forecasting."
    - name: "settled_lawsuit_count"
      expr: SUM(CAST(CASE WHEN litigation_status = 'Settled' THEN 1 ELSE 0 END AS INT))
      comment: "Number of settled lawsuits."
    - name: "verdict_lawsuit_count"
      expr: SUM(CAST(CASE WHEN litigation_status = 'Verdict' THEN 1 ELSE 0 END AS INT))
      comment: "Number of lawsuits that went to verdict."
    - name: "dismissed_lawsuit_count"
      expr: SUM(CAST(CASE WHEN litigation_status = 'Dismissed' THEN 1 ELSE 0 END AS INT))
      comment: "Number of dismissed lawsuits."
    - name: "appeal_filed_count"
      expr: SUM(CAST(CASE WHEN appeal_filed_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Number of lawsuits with appeals filed."
    - name: "total_defense_cost"
      expr: SUM(CAST(defense_cost_incurred AS DOUBLE))
      comment: "Total defense costs incurred across all lawsuits, key component of total claim cost."
    - name: "total_demand_amount"
      expr: SUM(CAST(demand_amount AS DOUBLE))
      comment: "Total demand amount across all lawsuits."
    - name: "total_settlement_amount"
      expr: SUM(CAST(settlement_amount AS DOUBLE))
      comment: "Total settlement amount across all lawsuits."
    - name: "total_verdict_amount"
      expr: SUM(CAST(verdict_amount AS DOUBLE))
      comment: "Total verdict amount across all lawsuits."
    - name: "total_reserve_amount"
      expr: SUM(CAST(reserve_amount AS DOUBLE))
      comment: "Total reserve amount for litigation."
    - name: "avg_defense_cost"
      expr: AVG(CAST(defense_cost_incurred AS DOUBLE))
      comment: "Average defense cost per lawsuit, key for litigation cost management."
    - name: "avg_demand_amount"
      expr: AVG(CAST(demand_amount AS DOUBLE))
      comment: "Average demand amount per lawsuit."
    - name: "avg_settlement_amount"
      expr: AVG(CAST(settlement_amount AS DOUBLE))
      comment: "Average settlement amount per lawsuit, key for settlement strategy."
    - name: "avg_verdict_amount"
      expr: AVG(CAST(verdict_amount AS DOUBLE))
      comment: "Average verdict amount per lawsuit, key for trial risk assessment."
    - name: "settlement_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN litigation_status = 'Settled' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of lawsuits that settle, key for litigation strategy and cost control."
    - name: "verdict_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN litigation_status = 'Verdict' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of lawsuits that go to verdict, indicator of trial risk."
    - name: "dismissal_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN litigation_status = 'Dismissed' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of lawsuits dismissed, indicator of defense effectiveness."
    - name: "appeal_rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN appeal_filed_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of lawsuits with appeals filed, indicator of verdict dispute."
    - name: "distinct_claims"
      expr: COUNT(DISTINCT claim_id)
      comment: "Number of distinct claims with litigation, used for litigation frequency analysis."
    - name: "distinct_exposures"
      expr: COUNT(DISTINCT claim_exposure_id)
      comment: "Number of distinct claim exposures with litigation."
    - name: "distinct_defense_counsel"
      expr: COUNT(DISTINCT defense_counsel_party_id)
      comment: "Number of distinct defense counsel firms, used for counsel performance analysis."
$$;