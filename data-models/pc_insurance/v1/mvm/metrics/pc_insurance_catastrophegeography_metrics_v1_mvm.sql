-- Metric views for domain: catastrophegeography | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_cat_event_loss`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Catastrophe event loss estimates and actuals by peril, zone, line of business, and treaty. Grain: one row per catastrophe event loss estimate or actual."
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss`"
  dimensions:
    - name: "loss_estimate_type"
      expr: loss_estimate_type
      comment: "Type of loss estimate: modeled, actual, preliminary, final, IBNR."
    - name: "estimate_status"
      expr: estimate_status
      comment: "Status of the loss estimate: draft, approved, superseded, final."
    - name: "model_vendor"
      expr: model_vendor
      comment: "Vendor of the catastrophe model used for loss estimation."
    - name: "accident_year"
      expr: accident_year
      comment: "Accident year of the catastrophe event loss."
    - name: "report_year"
      expr: report_year
      comment: "Report year of the catastrophe event loss."
    - name: "estimate_date"
      expr: estimate_date
      comment: "Date the loss estimate was produced."
  measures:
    - name: "total_gross_loss_amount"
      expr: SUM(CAST(gross_loss_amount AS DOUBLE))
      comment: "Total gross loss amount before reinsurance recoveries."
    - name: "total_net_loss_amount"
      expr: SUM(CAST(net_loss_amount AS DOUBLE))
      comment: "Total net loss amount after reinsurance recoveries."
    - name: "total_ceded_loss_amount"
      expr: SUM(CAST(ceded_loss_amount AS DOUBLE))
      comment: "Total ceded loss amount to reinsurers."
    - name: "total_alae_amount"
      expr: SUM(CAST(alae_amount AS DOUBLE))
      comment: "Total allocated loss adjustment expense."
    - name: "total_ulae_amount"
      expr: SUM(CAST(ulae_amount AS DOUBLE))
      comment: "Total unallocated loss adjustment expense."
    - name: "total_ibnr_loading_amount"
      expr: SUM(CAST(ibnr_loading_amount AS DOUBLE))
      comment: "Total incurred but not reported loading amount."
    - name: "total_probable_maximum_loss"
      expr: SUM(CAST(probable_maximum_loss AS DOUBLE))
      comment: "Total probable maximum loss across all events."
    - name: "total_claim_count_estimate"
      expr: SUM(CAST(claim_count_estimate AS BIGINT))
      comment: "Total estimated claim count for catastrophe events."
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS BIGINT))
      comment: "Total policy count exposed to catastrophe events."
    - name: "avg_loss_ratio_percent"
      expr: AVG(CAST(loss_ratio_percent AS DOUBLE))
      comment: "Average loss ratio percentage across catastrophe events."
    - name: "ceded_loss_ratio"
      expr: ROUND(100.0 * SUM(CAST(ceded_loss_amount AS DOUBLE)) / NULLIF(SUM(CAST(gross_loss_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of gross loss ceded to reinsurers."
    - name: "net_retention_ratio"
      expr: ROUND(100.0 * SUM(CAST(net_loss_amount AS DOUBLE)) / NULLIF(SUM(CAST(gross_loss_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of gross loss retained net after reinsurance."
    - name: "avg_loss_per_claim"
      expr: ROUND(SUM(CAST(gross_loss_amount AS DOUBLE)) / NULLIF(SUM(CAST(claim_count_estimate AS BIGINT)), 0), 2)
      comment: "Average gross loss amount per estimated claim."
    - name: "avg_loss_per_policy"
      expr: ROUND(SUM(CAST(gross_loss_amount AS DOUBLE)) / NULLIF(SUM(CAST(policy_count AS BIGINT)), 0), 2)
      comment: "Average gross loss amount per exposed policy."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_cat_zone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Catastrophe zone exposure, PML, and concentration metrics by peril and geography. Grain: one row per catastrophe zone."
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`"
  dimensions:
    - name: "zone_name"
      expr: zone_name
      comment: "Name of the catastrophe zone."
    - name: "zone_code"
      expr: zone_code
      comment: "Code identifying the catastrophe zone."
    - name: "zone_status"
      expr: zone_status
      comment: "Status of the catastrophe zone: active, inactive, moratorium."
    - name: "zone_tier"
      expr: zone_tier
      comment: "Tier classification of the catastrophe zone for risk stratification."
    - name: "peril_type"
      expr: peril_type
      comment: "Type of peril covered by the zone: hurricane, earthquake, flood, wildfire."
    - name: "state_code"
      expr: state_code
      comment: "State code of the catastrophe zone."
    - name: "country_code"
      expr: country_code
      comment: "Country code of the catastrophe zone."
    - name: "modeling_vendor"
      expr: modeling_vendor
      comment: "Vendor providing the catastrophe modeling for the zone."
    - name: "moratorium_flag"
      expr: moratorium_flag
      comment: "Indicates whether a moratorium is in effect for the zone."
    - name: "underwriting_restriction_flag"
      expr: underwriting_restriction_flag
      comment: "Indicates whether underwriting restrictions apply to the zone."
  measures:
    - name: "total_tiv_amount"
      expr: SUM(CAST(tiv_amount AS DOUBLE))
      comment: "Total insured value exposed in the catastrophe zone."
    - name: "total_pml_100_year_amount"
      expr: SUM(CAST(pml_100_year_amount AS DOUBLE))
      comment: "Total probable maximum loss at 100-year return period."
    - name: "total_pml_250_year_amount"
      expr: SUM(CAST(pml_250_year_amount AS DOUBLE))
      comment: "Total probable maximum loss at 250-year return period."
    - name: "total_pml_500_year_amount"
      expr: SUM(CAST(pml_500_year_amount AS DOUBLE))
      comment: "Total probable maximum loss at 500-year return period."
    - name: "total_aal_amount"
      expr: SUM(CAST(aal_amount AS DOUBLE))
      comment: "Total average annual loss for the catastrophe zone."
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS BIGINT))
      comment: "Total policy count exposed in the catastrophe zone."
    - name: "pml_100_to_tiv_ratio"
      expr: ROUND(100.0 * SUM(CAST(pml_100_year_amount AS DOUBLE)) / NULLIF(SUM(CAST(tiv_amount AS DOUBLE)), 0), 2)
      comment: "100-year PML as a percentage of total insured value."
    - name: "pml_250_to_tiv_ratio"
      expr: ROUND(100.0 * SUM(CAST(pml_250_year_amount AS DOUBLE)) / NULLIF(SUM(CAST(tiv_amount AS DOUBLE)), 0), 2)
      comment: "250-year PML as a percentage of total insured value."
    - name: "pml_500_to_tiv_ratio"
      expr: ROUND(100.0 * SUM(CAST(pml_500_year_amount AS DOUBLE)) / NULLIF(SUM(CAST(tiv_amount AS DOUBLE)), 0), 2)
      comment: "500-year PML as a percentage of total insured value."
    - name: "aal_to_tiv_ratio"
      expr: ROUND(100.0 * SUM(CAST(aal_amount AS DOUBLE)) / NULLIF(SUM(CAST(tiv_amount AS DOUBLE)), 0), 2)
      comment: "Average annual loss as a percentage of total insured value."
    - name: "avg_tiv_per_policy"
      expr: ROUND(SUM(CAST(tiv_amount AS DOUBLE)) / NULLIF(SUM(CAST(policy_count AS BIGINT)), 0), 2)
      comment: "Average total insured value per policy in the zone."
    - name: "concentration_threshold_utilization"
      expr: ROUND(100.0 * SUM(CAST(tiv_amount AS DOUBLE)) / NULLIF(SUM(CAST(concentration_threshold_amount AS DOUBLE)), 0), 2)
      comment: "TIV as a percentage of concentration threshold amount."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_catastrophe_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Catastrophe event characteristics, loss estimates, and industry impact. Grain: one row per catastrophe event."
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`"
  dimensions:
    - name: "event_name"
      expr: event_name
      comment: "Name of the catastrophe event."
    - name: "event_type"
      expr: event_type
      comment: "Type of catastrophe event: hurricane, earthquake, flood, wildfire, tornado."
    - name: "event_status"
      expr: event_status
      comment: "Status of the catastrophe event: active, closed, under review."
    - name: "peril_type"
      expr: peril_type
      comment: "Peril type associated with the catastrophe event."
    - name: "pml_class"
      expr: pml_class
      comment: "PML classification of the event: minor, moderate, major, catastrophic."
    - name: "federal_disaster_declaration_flag"
      expr: federal_disaster_declaration_flag
      comment: "Indicates whether a federal disaster was declared for the event."
    - name: "cat_bond_trigger_flag"
      expr: cat_bond_trigger_flag
      comment: "Indicates whether the event triggered a catastrophe bond."
    - name: "reinsurance_trigger_flag"
      expr: reinsurance_trigger_flag
      comment: "Indicates whether the event triggered reinsurance coverage."
    - name: "event_start_date"
      expr: event_start_date
      comment: "Start date of the catastrophe event."
    - name: "event_end_date"
      expr: event_end_date
      comment: "End date of the catastrophe event."
  measures:
    - name: "total_actual_loss_amount"
      expr: SUM(CAST(actual_loss_amount AS DOUBLE))
      comment: "Total actual loss amount reported for catastrophe events."
    - name: "total_modeled_loss_amount"
      expr: SUM(CAST(modeled_loss_amount AS DOUBLE))
      comment: "Total modeled loss amount for catastrophe events."
    - name: "total_industry_loss_estimate_amount"
      expr: SUM(CAST(industry_loss_estimate_amount AS DOUBLE))
      comment: "Total industry-wide loss estimate for catastrophe events."
    - name: "total_pml_amount"
      expr: SUM(CAST(pml_amount AS DOUBLE))
      comment: "Total probable maximum loss for catastrophe events."
    - name: "total_aal_amount"
      expr: SUM(CAST(aal_amount AS DOUBLE))
      comment: "Total average annual loss for catastrophe events."
    - name: "total_estimated_claim_count"
      expr: SUM(CAST(estimated_claim_count AS BIGINT))
      comment: "Total estimated claim count for catastrophe events."
    - name: "avg_event_duration_days"
      expr: AVG(CAST(event_duration_days AS BIGINT))
      comment: "Average duration in days of catastrophe events."
    - name: "avg_magnitude_value"
      expr: AVG(CAST(magnitude_value AS DOUBLE))
      comment: "Average magnitude value of catastrophe events."
    - name: "avg_wind_speed_mph"
      expr: AVG(CAST(wind_speed_mph AS BIGINT))
      comment: "Average wind speed in miles per hour for catastrophe events."
    - name: "modeled_to_actual_loss_ratio"
      expr: ROUND(100.0 * SUM(CAST(modeled_loss_amount AS DOUBLE)) / NULLIF(SUM(CAST(actual_loss_amount AS DOUBLE)), 0), 2)
      comment: "Modeled loss as a percentage of actual loss for accuracy assessment."
    - name: "avg_loss_per_claim"
      expr: ROUND(SUM(CAST(actual_loss_amount AS DOUBLE)) / NULLIF(SUM(CAST(estimated_claim_count AS BIGINT)), 0), 2)
      comment: "Average actual loss amount per estimated claim."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_pml_run`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "PML modeling run results by return period, peril, zone, and treaty. Grain: one row per PML modeling run."
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run`"
  dimensions:
    - name: "run_name"
      expr: run_name
      comment: "Name of the PML modeling run."
    - name: "run_status"
      expr: run_status
      comment: "Status of the PML run: in progress, completed, approved, rejected."
    - name: "run_type"
      expr: run_type
      comment: "Type of PML run: regulatory, rating agency, internal, treaty renewal."
    - name: "model_vendor"
      expr: model_vendor
      comment: "Vendor of the catastrophe model used in the PML run."
    - name: "model_name"
      expr: model_name
      comment: "Name of the catastrophe model used in the PML run."
    - name: "model_version"
      expr: model_version
      comment: "Version of the catastrophe model used in the PML run."
    - name: "geography_scope"
      expr: geography_scope
      comment: "Geographic scope of the PML run: national, regional, state, zone."
    - name: "regulatory_filing_flag"
      expr: regulatory_filing_flag
      comment: "Indicates whether the PML run is for regulatory filing."
    - name: "rating_agency_submission_flag"
      expr: rating_agency_submission_flag
      comment: "Indicates whether the PML run is for rating agency submission."
    - name: "run_date"
      expr: run_date
      comment: "Date the PML run was executed."
  measures:
    - name: "total_tiv_amount"
      expr: SUM(CAST(tiv_amount AS DOUBLE))
      comment: "Total insured value modeled in PML runs."
    - name: "total_aal_gross"
      expr: SUM(CAST(aal_gross AS DOUBLE))
      comment: "Total gross average annual loss across PML runs."
    - name: "total_aal_net"
      expr: SUM(CAST(aal_net AS DOUBLE))
      comment: "Total net average annual loss after reinsurance across PML runs."
    - name: "total_pml_100_gross"
      expr: SUM(CAST(return_period_100_gross_pml AS DOUBLE))
      comment: "Total gross PML at 100-year return period."
    - name: "total_pml_100_net"
      expr: SUM(CAST(return_period_100_net_pml AS DOUBLE))
      comment: "Total net PML at 100-year return period after reinsurance."
    - name: "total_pml_250_gross"
      expr: SUM(CAST(return_period_250_gross_pml AS DOUBLE))
      comment: "Total gross PML at 250-year return period."
    - name: "total_pml_250_net"
      expr: SUM(CAST(return_period_250_net_pml AS DOUBLE))
      comment: "Total net PML at 250-year return period after reinsurance."
    - name: "total_pml_500_gross"
      expr: SUM(CAST(return_period_500_gross_pml AS DOUBLE))
      comment: "Total gross PML at 500-year return period."
    - name: "total_pml_500_net"
      expr: SUM(CAST(return_period_500_net_pml AS DOUBLE))
      comment: "Total net PML at 500-year return period after reinsurance."
    - name: "total_pml_1000_gross"
      expr: SUM(CAST(return_period_1000_gross_pml AS DOUBLE))
      comment: "Total gross PML at 1000-year return period."
    - name: "total_pml_1000_net"
      expr: SUM(CAST(return_period_1000_net_pml AS DOUBLE))
      comment: "Total net PML at 1000-year return period after reinsurance."
    - name: "total_location_count"
      expr: SUM(CAST(location_count AS BIGINT))
      comment: "Total location count modeled in PML runs."
    - name: "total_policy_count"
      expr: SUM(CAST(policy_count AS BIGINT))
      comment: "Total policy count modeled in PML runs."
    - name: "avg_run_duration_minutes"
      expr: AVG(CAST(run_duration_minutes AS BIGINT))
      comment: "Average duration in minutes of PML modeling runs."
    - name: "pml_100_ceded_ratio"
      expr: ROUND(100.0 * (SUM(CAST(return_period_100_gross_pml AS DOUBLE)) - SUM(CAST(return_period_100_net_pml AS DOUBLE))) / NULLIF(SUM(CAST(return_period_100_gross_pml AS DOUBLE)), 0), 2)
      comment: "Percentage of 100-year PML ceded to reinsurers."
    - name: "pml_250_ceded_ratio"
      expr: ROUND(100.0 * (SUM(CAST(return_period_250_gross_pml AS DOUBLE)) - SUM(CAST(return_period_250_net_pml AS DOUBLE))) / NULLIF(SUM(CAST(return_period_250_gross_pml AS DOUBLE)), 0), 2)
      comment: "Percentage of 250-year PML ceded to reinsurers."
    - name: "pml_500_ceded_ratio"
      expr: ROUND(100.0 * (SUM(CAST(return_period_500_gross_pml AS DOUBLE)) - SUM(CAST(return_period_500_net_pml AS DOUBLE))) / NULLIF(SUM(CAST(return_period_500_gross_pml AS DOUBLE)), 0), 2)
      comment: "Percentage of 500-year PML ceded to reinsurers."
    - name: "aal_ceded_ratio"
      expr: ROUND(100.0 * (SUM(CAST(aal_gross AS DOUBLE)) - SUM(CAST(aal_net AS DOUBLE))) / NULLIF(SUM(CAST(aal_gross AS DOUBLE)), 0), 2)
      comment: "Percentage of average annual loss ceded to reinsurers."
    - name: "pml_100_to_tiv_ratio"
      expr: ROUND(100.0 * SUM(CAST(return_period_100_gross_pml AS DOUBLE)) / NULLIF(SUM(CAST(tiv_amount AS DOUBLE)), 0), 2)
      comment: "100-year gross PML as a percentage of total insured value."
    - name: "aal_to_tiv_ratio"
      expr: ROUND(100.0 * SUM(CAST(aal_gross AS DOUBLE)) / NULLIF(SUM(CAST(tiv_amount AS DOUBLE)), 0), 2)
      comment: "Gross average annual loss as a percentage of total insured value."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_policy_cat_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Policy-level catastrophe exposure by location, peril, zone, and coverage. Grain: one row per policy catastrophe exposure."
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure`"
  dimensions:
    - name: "exposure_status"
      expr: exposure_status
      comment: "Status of the catastrophe exposure: active, expired, cancelled."
    - name: "cat_model_vendor"
      expr: cat_model_vendor
      comment: "Vendor of the catastrophe model used for exposure assessment."
    - name: "construction_class"
      expr: construction_class
      comment: "Construction class of the insured property."
    - name: "occupancy_class"
      expr: occupancy_class
      comment: "Occupancy class of the insured property."
    - name: "protection_class"
      expr: protection_class
      comment: "Fire protection class of the insured property."
    - name: "deductible_type"
      expr: deductible_type
      comment: "Type of deductible applied to the catastrophe exposure."
    - name: "reinsurance_program_code"
      expr: reinsurance_program_code
      comment: "Code identifying the reinsurance program covering the exposure."
    - name: "fnol_triage_priority"
      expr: fnol_triage_priority
      comment: "First notice of loss triage priority for the exposure."
    - name: "bordereaux_reporting_flag"
      expr: bordereaux_reporting_flag
      comment: "Indicates whether the exposure is reported via bordereaux."
    - name: "exposure_effective_date"
      expr: exposure_effective_date
      comment: "Effective date of the catastrophe exposure."
  measures:
    - name: "total_tiv_amount"
      expr: SUM(CAST(tiv_amount AS DOUBLE))
      comment: "Total insured value exposed to catastrophe perils."
    - name: "total_limit_amount"
      expr: SUM(CAST(limit_amount AS DOUBLE))
      comment: "Total policy limit amount for catastrophe exposures."
    - name: "total_deductible_amount"
      expr: SUM(CAST(deductible_amount AS DOUBLE))
      comment: "Total deductible amount for catastrophe exposures."
    - name: "total_retention_amount"
      expr: SUM(CAST(retention_amount AS DOUBLE))
      comment: "Total retention amount before reinsurance applies."
    - name: "total_pml_amount"
      expr: SUM(CAST(pml_amount AS DOUBLE))
      comment: "Total probable maximum loss for policy catastrophe exposures."
    - name: "total_aal_amount"
      expr: SUM(CAST(aal_amount AS DOUBLE))
      comment: "Total average annual loss for policy catastrophe exposures."
    - name: "total_estimated_gross_loss_amount"
      expr: SUM(CAST(estimated_gross_loss_amount AS DOUBLE))
      comment: "Total estimated gross loss amount for catastrophe exposures."
    - name: "total_estimated_net_loss_amount"
      expr: SUM(CAST(estimated_net_loss_amount AS DOUBLE))
      comment: "Total estimated net loss amount after reinsurance."
    - name: "total_building_area_sqft"
      expr: SUM(CAST(building_area_sqft AS DOUBLE))
      comment: "Total building area in square feet exposed to catastrophe perils."
    - name: "avg_treaty_share_percent"
      expr: AVG(CAST(treaty_share_percent AS DOUBLE))
      comment: "Average treaty share percentage for catastrophe exposures."
    - name: "pml_to_tiv_ratio"
      expr: ROUND(100.0 * SUM(CAST(pml_amount AS DOUBLE)) / NULLIF(SUM(CAST(tiv_amount AS DOUBLE)), 0), 2)
      comment: "Probable maximum loss as a percentage of total insured value."
    - name: "aal_to_tiv_ratio"
      expr: ROUND(100.0 * SUM(CAST(aal_amount AS DOUBLE)) / NULLIF(SUM(CAST(tiv_amount AS DOUBLE)), 0), 2)
      comment: "Average annual loss as a percentage of total insured value."
    - name: "deductible_to_limit_ratio"
      expr: ROUND(100.0 * SUM(CAST(deductible_amount AS DOUBLE)) / NULLIF(SUM(CAST(limit_amount AS DOUBLE)), 0), 2)
      comment: "Deductible as a percentage of policy limit."
    - name: "net_to_gross_loss_ratio"
      expr: ROUND(100.0 * SUM(CAST(estimated_net_loss_amount AS DOUBLE)) / NULLIF(SUM(CAST(estimated_gross_loss_amount AS DOUBLE)), 0), 2)
      comment: "Net loss as a percentage of gross loss after reinsurance."
    - name: "avg_tiv_per_sqft"
      expr: ROUND(SUM(CAST(tiv_amount AS DOUBLE)) / NULLIF(SUM(CAST(building_area_sqft AS DOUBLE)), 0), 2)
      comment: "Average total insured value per square foot of building area."
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`catastrophegeography_accumulation_limit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Catastrophe accumulation limits, utilization, and threshold monitoring by zone and peril. Grain: one row per accumulation limit."
  source: "`vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit`"
  dimensions:
    - name: "accumulation_limit_status"
      expr: accumulation_limit_status
      comment: "Status of the accumulation limit: active, breached, suspended, expired."
    - name: "limit_type"
      expr: limit_type
      comment: "Type of accumulation limit: PML, AAL, TIV, exposure count."
    - name: "limit_basis"
      expr: limit_basis
      comment: "Basis for the accumulation limit: gross, net, ceded."
    - name: "geographic_scope"
      expr: geographic_scope
      comment: "Geographic scope of the accumulation limit: zone, state, region, national."
    - name: "threshold_action"
      expr: threshold_action
      comment: "Action to take when threshold is breached: alert, suspend, escalate."
    - name: "override_allowed_flag"
      expr: override_allowed_flag
      comment: "Indicates whether the accumulation limit can be overridden."
    - name: "regulatory_requirement_flag"
      expr: regulatory_requirement_flag
      comment: "Indicates whether the limit is a regulatory requirement."
    - name: "model_vendor"
      expr: model_vendor
      comment: "Vendor of the catastrophe model used for limit calculation."
    - name: "approval_authority"
      expr: approval_authority
      comment: "Authority level required to approve limit changes or overrides."
    - name: "effective_date"
      expr: effective_date
      comment: "Effective date of the accumulation limit."
  measures:
    - name: "total_limit_amount"
      expr: SUM(CAST(limit_amount AS DOUBLE))
      comment: "Total accumulation limit amount across all limits."
    - name: "total_utilization_amount"
      expr: SUM(CAST(utilization_amount AS DOUBLE))
      comment: "Total utilization amount against accumulation limits."
    - name: "total_available_capacity"
      expr: SUM(CAST(available_capacity AS DOUBLE))
      comment: "Total available capacity remaining under accumulation limits."
    - name: "total_net_retention_amount"
      expr: SUM(CAST(net_retention_amount AS DOUBLE))
      comment: "Total net retention amount after reinsurance."
    - name: "avg_utilization_percent"
      expr: AVG(CAST(utilization_percent AS DOUBLE))
      comment: "Average utilization percentage of accumulation limits."
    - name: "avg_ceded_percent"
      expr: AVG(CAST(ceded_percent AS DOUBLE))
      comment: "Average percentage of accumulation limit ceded to reinsurers."
    - name: "avg_hard_threshold_percent"
      expr: AVG(CAST(hard_threshold_percent AS DOUBLE))
      comment: "Average hard threshold percentage for accumulation limits."
    - name: "avg_soft_threshold_percent"
      expr: AVG(CAST(soft_threshold_percent AS DOUBLE))
      comment: "Average soft threshold percentage for accumulation limits."
    - name: "utilization_rate"
      expr: ROUND(100.0 * SUM(CAST(utilization_amount AS DOUBLE)) / NULLIF(SUM(CAST(limit_amount AS DOUBLE)), 0), 2)
      comment: "Utilization amount as a percentage of total limit amount."
    - name: "available_capacity_rate"
      expr: ROUND(100.0 * SUM(CAST(available_capacity AS DOUBLE)) / NULLIF(SUM(CAST(limit_amount AS DOUBLE)), 0), 2)
      comment: "Available capacity as a percentage of total limit amount."
    - name: "net_retention_rate"
      expr: ROUND(100.0 * SUM(CAST(net_retention_amount AS DOUBLE)) / NULLIF(SUM(CAST(limit_amount AS DOUBLE)), 0), 2)
      comment: "Net retention as a percentage of total limit amount."
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