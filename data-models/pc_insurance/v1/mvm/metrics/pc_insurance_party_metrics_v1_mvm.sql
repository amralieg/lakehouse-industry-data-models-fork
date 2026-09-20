-- Metric views for domain: party | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 21:49:29

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core party metrics tracking entity counts, fraud indicators, and KYC compliance across individuals and organizations for risk assessment and regulatory reporting."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`party`"
  dimensions:
    - name: "party_type"
      expr: party_type
      comment: "Type of party: individual, organization, or other entity classification"
    - name: "party_status"
      expr: party_status
      comment: "Current status of the party record: active, inactive, suspended, or deceased"
    - name: "kyc_status"
      expr: kyc_status
      comment: "Know Your Customer verification status: verified, pending, failed, or not required"
    - name: "fraud_indicator_flag"
      expr: fraud_indicator_flag
      comment: "Boolean flag indicating whether party has been flagged for potential fraud"
    - name: "ofac_match_flag"
      expr: ofac_match_flag
      comment: "Boolean flag indicating OFAC watchlist match requiring investigation"
    - name: "golden_record_flag"
      expr: golden_record_flag
      comment: "Boolean flag indicating this is the master/golden record after deduplication"
    - name: "do_not_contact_flag"
      expr: do_not_contact_flag
      comment: "Boolean flag indicating party has opted out of contact"
    - name: "source_system_code"
      expr: source_system_code
      comment: "Source system that originated this party record"
    - name: "country_code"
      expr: country_code
      comment: "Country code for party primary address"
    - name: "state_code"
      expr: state_code
      comment: "State or province code for party primary address"
  measures:
    - name: "total_parties"
      expr: COUNT(1)
      comment: "Total count of party records for population sizing and growth tracking"
    - name: "unique_parties"
      expr: COUNT(DISTINCT party_id)
      comment: "Distinct count of parties for deduplication quality assessment"
    - name: "fraud_flagged_party_count"
      expr: COUNT(DISTINCT CASE WHEN fraud_indicator_flag = TRUE THEN party_id END)
      comment: "Count of parties flagged for fraud investigation"
    - name: "ofac_match_party_count"
      expr: COUNT(DISTINCT CASE WHEN ofac_match_flag = TRUE THEN party_id END)
      comment: "Count of parties with OFAC watchlist matches requiring compliance review"
    - name: "kyc_verified_party_count"
      expr: COUNT(DISTINCT CASE WHEN kyc_status = 'verified' THEN party_id END)
      comment: "Count of parties with completed KYC verification for compliance reporting"
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score across parties for portfolio risk assessment"
    - name: "avg_years_in_business"
      expr: AVG(CAST(years_in_business AS DOUBLE))
      comment: "Average years in business for commercial parties for underwriting risk evaluation"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_role`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Party role metrics tracking role assignments, effective periods, and compliance flags across policy and claim contexts for relationship analysis and regulatory adherence."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`role`"
  dimensions:
    - name: "type_code"
      expr: type_code
      comment: "Role type code: policyholder, named insured, additional insured, claimant, producer, adjuster, payee, or other"
    - name: "subtype_code"
      expr: subtype_code
      comment: "Role subtype providing additional classification detail within the primary type"
    - name: "role_status"
      expr: role_status
      comment: "Current status of the role assignment: active, expired, terminated, or pending"
    - name: "acord_role_code"
      expr: acord_role_code
      comment: "ACORD standard role code for industry-standard reporting and data exchange"
    - name: "is_primary_role"
      expr: is_primary_role
      comment: "Boolean flag indicating this is the primary role for the party on this policy or claim"
    - name: "fraud_score_tier"
      expr: CASE WHEN fraud_score >= 0.75 THEN 'High' WHEN fraud_score >= 0.50 THEN 'Medium' WHEN fraud_score >= 0.25 THEN 'Low' ELSE 'Minimal' END
      comment: "Fraud score tier for risk segmentation: High, Medium, Low, or Minimal"
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Boolean flag indicating role has been referred to Special Investigation Unit"
    - name: "litigation_flag"
      expr: litigation_flag
      comment: "Boolean flag indicating role is involved in litigation"
    - name: "represented_by_counsel"
      expr: represented_by_counsel
      comment: "Boolean flag indicating party in this role is represented by legal counsel"
    - name: "kyc_verified"
      expr: kyc_verified
      comment: "Boolean flag indicating KYC verification completed for this role assignment"
  measures:
    - name: "total_role_assignments"
      expr: COUNT(1)
      comment: "Total count of role assignments for relationship complexity analysis"
    - name: "unique_roles"
      expr: COUNT(DISTINCT role_id)
      comment: "Distinct count of role assignments for deduplication quality"
    - name: "unique_parties_with_roles"
      expr: COUNT(DISTINCT party_id)
      comment: "Distinct count of parties holding roles for participation rate analysis"
    - name: "siu_referral_count"
      expr: COUNT(DISTINCT CASE WHEN siu_referral_flag = TRUE THEN role_id END)
      comment: "Count of roles referred to SIU for fraud investigation workload tracking"
    - name: "litigation_role_count"
      expr: COUNT(DISTINCT CASE WHEN litigation_flag = TRUE THEN role_id END)
      comment: "Count of roles involved in litigation for legal exposure assessment"
    - name: "avg_fraud_score"
      expr: AVG(CAST(fraud_score AS DOUBLE))
      comment: "Average fraud score across role assignments for portfolio risk assessment"
    - name: "high_fraud_score_role_count"
      expr: COUNT(DISTINCT CASE WHEN fraud_score >= 0.75 THEN role_id END)
      comment: "Count of roles with high fraud scores requiring immediate investigation"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_individual`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Individual party metrics tracking demographics, credit profiles, MVR consent, and fraud indicators for personal lines underwriting and risk selection."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`individual`"
  dimensions:
    - name: "gender_code"
      expr: gender_code
      comment: "Gender code for demographic analysis and actuarial rating"
    - name: "marital_status_code"
      expr: marital_status_code
      comment: "Marital status code for household composition and rating factors"
    - name: "occupation_code"
      expr: occupation_code
      comment: "Occupation code for risk classification and underwriting rules"
    - name: "kyc_status"
      expr: kyc_status
      comment: "Know Your Customer verification status for compliance and fraud prevention"
    - name: "fraud_indicator_flag"
      expr: fraud_indicator_flag
      comment: "Boolean flag indicating individual has been flagged for potential fraud"
    - name: "ofac_screened_flag"
      expr: ofac_screened_flag
      comment: "Boolean flag indicating OFAC screening has been completed"
    - name: "mvr_consent_flag"
      expr: mvr_consent_flag
      comment: "Boolean flag indicating consent obtained for motor vehicle record check"
    - name: "clue_consent_flag"
      expr: clue_consent_flag
      comment: "Boolean flag indicating consent obtained for CLUE loss history report"
    - name: "golden_record_flag"
      expr: golden_record_flag
      comment: "Boolean flag indicating this is the master record after deduplication"
    - name: "credit_score_tier"
      expr: CASE WHEN credit_score >= 750 THEN 'Excellent' WHEN credit_score >= 700 THEN 'Good' WHEN credit_score >= 650 THEN 'Fair' WHEN credit_score >= 600 THEN 'Poor' ELSE 'Very Poor' END
      comment: "Credit score tier for risk segmentation and pricing"
  measures:
    - name: "total_individuals"
      expr: COUNT(1)
      comment: "Total count of individual party records for population sizing"
    - name: "unique_individuals"
      expr: COUNT(DISTINCT individual_id)
      comment: "Distinct count of individuals for deduplication quality assessment"
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score for portfolio risk assessment and pricing strategy"
    - name: "avg_years_continuously_insured"
      expr: AVG(CAST(years_continuously_insured AS DOUBLE))
      comment: "Average years continuously insured for retention and loyalty analysis"
    - name: "fraud_flagged_individual_count"
      expr: COUNT(DISTINCT CASE WHEN fraud_indicator_flag = TRUE THEN individual_id END)
      comment: "Count of individuals flagged for fraud investigation"
    - name: "mvr_consent_rate_pct"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN mvr_consent_flag = TRUE THEN individual_id END) / NULLIF(COUNT(DISTINCT individual_id), 0), 2)
      comment: "Percentage of individuals providing MVR consent for underwriting data availability"
    - name: "clue_consent_rate_pct"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN clue_consent_flag = TRUE THEN individual_id END) / NULLIF(COUNT(DISTINCT individual_id), 0), 2)
      comment: "Percentage of individuals providing CLUE consent for loss history access"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_organization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Organization party metrics tracking entity profiles, financial strength, employee counts, and compliance status for commercial lines underwriting and risk evaluation."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`organization`"
  dimensions:
    - name: "entity_type"
      expr: entity_type
      comment: "Legal entity type: corporation, LLC, partnership, sole proprietorship, or other"
    - name: "naics_code"
      expr: naics_code
      comment: "North American Industry Classification System code for industry risk classification"
    - name: "sic_code"
      expr: sic_code
      comment: "Standard Industrial Classification code for legacy industry classification"
    - name: "kyc_status"
      expr: kyc_status
      comment: "Know Your Customer verification status for compliance and fraud prevention"
    - name: "fraud_indicator"
      expr: fraud_indicator
      comment: "Boolean flag indicating organization has been flagged for potential fraud"
    - name: "ofac_screened"
      expr: ofac_screened
      comment: "Boolean flag indicating OFAC screening has been completed"
    - name: "publicly_traded"
      expr: publicly_traded
      comment: "Boolean flag indicating organization is publicly traded for financial stability assessment"
    - name: "incorporation_country"
      expr: incorporation_country
      comment: "Country of incorporation for jurisdiction and regulatory compliance"
    - name: "incorporation_state"
      expr: incorporation_state
      comment: "State of incorporation for domestic jurisdiction analysis"
    - name: "revenue_tier"
      expr: CASE WHEN annual_revenue >= 100000000 THEN 'Large' WHEN annual_revenue >= 10000000 THEN 'Medium' WHEN annual_revenue >= 1000000 THEN 'Small' ELSE 'Micro' END
      comment: "Revenue tier for risk segmentation and pricing: Large, Medium, Small, or Micro"
  measures:
    - name: "total_organizations"
      expr: COUNT(1)
      comment: "Total count of organization party records for commercial portfolio sizing"
    - name: "unique_organizations"
      expr: COUNT(DISTINCT organization_id)
      comment: "Distinct count of organizations for deduplication quality assessment"
    - name: "total_annual_revenue"
      expr: SUM(CAST(annual_revenue AS DOUBLE))
      comment: "Total annual revenue across organizations for portfolio exposure assessment"
    - name: "avg_annual_revenue"
      expr: AVG(CAST(annual_revenue AS DOUBLE))
      comment: "Average annual revenue for portfolio risk profile and pricing strategy"
    - name: "total_annual_payroll"
      expr: SUM(CAST(annual_payroll AS DOUBLE))
      comment: "Total annual payroll for workers compensation exposure calculation"
    - name: "avg_employee_count"
      expr: AVG(CAST(employee_count AS DOUBLE))
      comment: "Average employee count for commercial risk sizing and classification"
    - name: "avg_years_in_business"
      expr: AVG(CAST(years_in_business AS DOUBLE))
      comment: "Average years in business for stability and underwriting risk assessment"
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score for commercial financial strength evaluation"
    - name: "fraud_flagged_org_count"
      expr: COUNT(DISTINCT CASE WHEN fraud_indicator = TRUE THEN organization_id END)
      comment: "Count of organizations flagged for fraud investigation"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_household`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Household metrics tracking member composition, credit profiles, policy tenure, and marketing preferences for personal lines cross-sell and retention strategies."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`household`"
  dimensions:
    - name: "household_type"
      expr: household_type
      comment: "Household type classification: single, family, multi-generational, or other"
    - name: "household_status"
      expr: household_status
      comment: "Current status of the household: active, inactive, or dissolved"
    - name: "do_not_contact_flag"
      expr: do_not_contact_flag
      comment: "Boolean flag indicating household has opted out of contact"
    - name: "marketing_opt_in_flag"
      expr: marketing_opt_in_flag
      comment: "Boolean flag indicating household has opted in to marketing communications"
    - name: "paperless_delivery_flag"
      expr: paperless_delivery_flag
      comment: "Boolean flag indicating household prefers paperless document delivery"
    - name: "kyc_verification_status"
      expr: kyc_verification_status
      comment: "Know Your Customer verification status for household compliance"
    - name: "primary_language_code"
      expr: primary_language_code
      comment: "Primary language code for communication and service delivery"
    - name: "credit_score_tier"
      expr: CASE WHEN credit_score >= 750 THEN 'Excellent' WHEN credit_score >= 700 THEN 'Good' WHEN credit_score >= 650 THEN 'Fair' WHEN credit_score >= 600 THEN 'Poor' ELSE 'Very Poor' END
      comment: "Credit score tier for household risk segmentation and pricing"
    - name: "member_count_tier"
      expr: CASE WHEN member_count >= 5 THEN '5+' WHEN member_count >= 3 THEN '3-4' WHEN member_count = 2 THEN '2' ELSE '1' END
      comment: "Member count tier for household size segmentation"
  measures:
    - name: "total_households"
      expr: COUNT(1)
      comment: "Total count of household records for personal lines portfolio sizing"
    - name: "unique_households"
      expr: COUNT(DISTINCT household_id)
      comment: "Distinct count of households for deduplication quality assessment"
    - name: "avg_member_count"
      expr: AVG(CAST(member_count AS DOUBLE))
      comment: "Average household member count for cross-sell opportunity sizing"
    - name: "avg_adult_count"
      expr: AVG(CAST(adult_count AS DOUBLE))
      comment: "Average adult count per household for driver and policyholder analysis"
    - name: "avg_dependent_count"
      expr: AVG(CAST(dependent_count AS DOUBLE))
      comment: "Average dependent count for household composition and risk assessment"
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average household credit score for portfolio risk and pricing strategy"
    - name: "marketing_opt_in_rate_pct"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN marketing_opt_in_flag = TRUE THEN household_id END) / NULLIF(COUNT(DISTINCT household_id), 0), 2)
      comment: "Percentage of households opted in to marketing for campaign reach estimation"
    - name: "paperless_adoption_rate_pct"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN paperless_delivery_flag = TRUE THEN household_id END) / NULLIF(COUNT(DISTINCT household_id), 0), 2)
      comment: "Percentage of households using paperless delivery for cost savings and sustainability"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_kyc_verification`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KYC verification metrics tracking compliance checks, adverse media hits, PEP status, and SIU referrals for regulatory adherence and fraud prevention."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`kyc_verification`"
  dimensions:
    - name: "verification_status"
      expr: verification_status
      comment: "Current verification status: verified, pending, failed, or expired"
    - name: "verification_method"
      expr: verification_method
      comment: "Method used for verification: document, biometric, third-party, or manual"
    - name: "verification_result"
      expr: verification_result
      comment: "Result of verification: pass, fail, inconclusive, or requires review"
    - name: "risk_tier"
      expr: risk_tier
      comment: "Risk tier assigned: low, medium, high, or critical"
    - name: "due_diligence_level"
      expr: due_diligence_level
      comment: "Level of due diligence applied: standard, enhanced, or simplified"
    - name: "ofac_screening_status"
      expr: ofac_screening_status
      comment: "OFAC screening status: clear, hit, pending, or not screened"
    - name: "is_pep"
      expr: is_pep
      comment: "Boolean flag indicating party is a Politically Exposed Person requiring enhanced due diligence"
    - name: "is_adverse_media"
      expr: is_adverse_media
      comment: "Boolean flag indicating adverse media found during screening"
    - name: "siu_referral"
      expr: siu_referral
      comment: "Boolean flag indicating case has been referred to Special Investigation Unit"
    - name: "sar_filed"
      expr: sar_filed
      comment: "Boolean flag indicating Suspicious Activity Report has been filed"
  measures:
    - name: "total_kyc_verifications"
      expr: COUNT(1)
      comment: "Total count of KYC verification records for compliance workload tracking"
    - name: "unique_kyc_verifications"
      expr: COUNT(DISTINCT kyc_verification_id)
      comment: "Distinct count of KYC verifications for deduplication quality"
    - name: "verified_count"
      expr: COUNT(DISTINCT CASE WHEN verification_status = 'verified' THEN kyc_verification_id END)
      comment: "Count of successfully verified KYC checks for compliance rate calculation"
    - name: "pep_count"
      expr: COUNT(DISTINCT CASE WHEN is_pep = TRUE THEN kyc_verification_id END)
      comment: "Count of Politically Exposed Persons requiring enhanced due diligence"
    - name: "adverse_media_count"
      expr: COUNT(DISTINCT CASE WHEN is_adverse_media = TRUE THEN kyc_verification_id END)
      comment: "Count of verifications with adverse media hits for risk assessment"
    - name: "siu_referral_count"
      expr: COUNT(DISTINCT CASE WHEN siu_referral = TRUE THEN kyc_verification_id END)
      comment: "Count of KYC cases referred to SIU for fraud investigation workload"
    - name: "sar_filed_count"
      expr: COUNT(DISTINCT CASE WHEN sar_filed = TRUE THEN kyc_verification_id END)
      comment: "Count of Suspicious Activity Reports filed for regulatory reporting"
    - name: "watchlist_screened_count"
      expr: COUNT(DISTINCT CASE WHEN watchlist_screened = TRUE THEN kyc_verification_id END)
      comment: "Count of verifications with watchlist screening completed for compliance coverage"
    - name: "beneficial_owner_verified_count"
      expr: COUNT(DISTINCT CASE WHEN beneficial_owner_verified = TRUE THEN kyc_verification_id END)
      comment: "Count of verifications with beneficial owner verification completed for transparency"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_license`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "License metrics tracking producer and adjuster licensing status, continuing education compliance, and disciplinary actions for regulatory adherence and appointment management."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`license`"
  dimensions:
    - name: "license_type"
      expr: license_type
      comment: "Type of license: producer, adjuster, surplus lines, or other"
    - name: "license_status"
      expr: license_status
      comment: "Current status of the license: active, expired, suspended, revoked, or pending"
    - name: "adjuster_type"
      expr: adjuster_type
      comment: "Type of adjuster license: staff, independent, public, or catastrophe"
    - name: "issuing_state_code"
      expr: issuing_state_code
      comment: "State code of the issuing jurisdiction for regulatory compliance"
    - name: "resident_state_code"
      expr: resident_state_code
      comment: "Resident state code for home state licensing requirements"
    - name: "is_resident_license"
      expr: is_resident_license
      comment: "Boolean flag indicating this is a resident license in the home state"
    - name: "surplus_lines_authorized"
      expr: surplus_lines_authorized
      comment: "Boolean flag indicating authorization to write surplus lines business"
    - name: "disciplinary_action_indicator"
      expr: disciplinary_action_indicator
      comment: "Boolean flag indicating disciplinary action has been taken against this license"
    - name: "background_check_status"
      expr: background_check_status
      comment: "Status of background check: clear, pending, failed, or not required"
    - name: "nipr_verification_status"
      expr: nipr_verification_status
      comment: "NIPR verification status for national producer registry compliance"
  measures:
    - name: "total_licenses"
      expr: COUNT(1)
      comment: "Total count of license records for producer and adjuster population sizing"
    - name: "unique_licenses"
      expr: COUNT(DISTINCT license_id)
      comment: "Distinct count of licenses for deduplication quality assessment"
    - name: "active_license_count"
      expr: COUNT(DISTINCT CASE WHEN license_status = 'active' THEN license_id END)
      comment: "Count of active licenses for appointment and production capacity planning"
    - name: "expired_license_count"
      expr: COUNT(DISTINCT CASE WHEN license_status = 'expired' THEN license_id END)
      comment: "Count of expired licenses requiring renewal or termination action"
    - name: "disciplinary_action_count"
      expr: COUNT(DISTINCT CASE WHEN disciplinary_action_indicator = TRUE THEN license_id END)
      comment: "Count of licenses with disciplinary actions for compliance risk assessment"
    - name: "surplus_lines_authorized_count"
      expr: COUNT(DISTINCT CASE WHEN surplus_lines_authorized = TRUE THEN license_id END)
      comment: "Count of surplus lines authorized licenses for specialty market capacity"
    - name: "avg_ce_credits_completed"
      expr: AVG(CAST(ce_credits_completed AS DOUBLE))
      comment: "Average continuing education credits completed for compliance tracking"
    - name: "ce_compliance_rate_pct"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN ce_credits_completed >= ce_credits_required THEN license_id END) / NULLIF(COUNT(DISTINCT CASE WHEN ce_credits_required > 0 THEN license_id END), 0), 2)
      comment: "Percentage of licenses meeting CE requirements for regulatory compliance"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_address`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Address metrics tracking location quality, geocoding accuracy, catastrophe exposure, and fire protection for underwriting risk assessment and territory rating."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`address`"
  dimensions:
    - name: "address_type"
      expr: address_type
      comment: "Type of address: mailing, physical, billing, or other"
    - name: "address_status"
      expr: address_status
      comment: "Current status of the address: active, inactive, or invalid"
    - name: "country_code"
      expr: country_code
      comment: "Country code for international address classification"
    - name: "state_code"
      expr: state_code
      comment: "State or province code for territory rating and regulatory compliance"
    - name: "county"
      expr: county
      comment: "County name for sub-state territory and catastrophe zone assignment"
    - name: "fire_protection_class"
      expr: fire_protection_class
      comment: "ISO fire protection class for property rating: 1-10 scale"
    - name: "coastal_indicator"
      expr: coastal_indicator
      comment: "Boolean flag indicating address is in coastal zone for wind and flood exposure"
    - name: "wind_pool_indicator"
      expr: wind_pool_indicator
      comment: "Boolean flag indicating address is in wind pool territory requiring special handling"
    - name: "geocode_quality"
      expr: geocode_quality
      comment: "Quality of geocoding: rooftop, parcel, street, zip, or unknown"
    - name: "usps_standardized_indicator"
      expr: usps_standardized_indicator
      comment: "Boolean flag indicating address has been USPS standardized for deliverability"
  measures:
    - name: "total_addresses"
      expr: COUNT(1)
      comment: "Total count of address records for location data quality assessment"
    - name: "unique_addresses"
      expr: COUNT(DISTINCT address_id)
      comment: "Distinct count of addresses for deduplication quality"
    - name: "coastal_address_count"
      expr: COUNT(DISTINCT CASE WHEN coastal_indicator = TRUE THEN address_id END)
      comment: "Count of coastal addresses for catastrophe exposure aggregation"
    - name: "wind_pool_address_count"
      expr: COUNT(DISTINCT CASE WHEN wind_pool_indicator = TRUE THEN address_id END)
      comment: "Count of wind pool addresses for special program eligibility tracking"
    - name: "usps_standardized_rate_pct"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN usps_standardized_indicator = TRUE THEN address_id END) / NULLIF(COUNT(DISTINCT address_id), 0), 2)
      comment: "Percentage of USPS standardized addresses for data quality and deliverability"
    - name: "avg_distance_to_coast_miles"
      expr: AVG(CAST(distance_to_coast_miles AS DOUBLE))
      comment: "Average distance to coast for wind and flood exposure assessment"
    - name: "avg_distance_to_fire_station_miles"
      expr: AVG(CAST(distance_to_fire_station_miles AS DOUBLE))
      comment: "Average distance to fire station for property fire risk rating"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_relationship`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Party relationship metrics tracking entity connections, ownership structures, and fraud networks for underwriting risk assessment and compliance investigation."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`relationship`"
  dimensions:
    - name: "type_code"
      expr: type_code
      comment: "Relationship type code: spouse, parent, child, business partner, beneficial owner, or other"
    - name: "relationship_category"
      expr: relationship_category
      comment: "Relationship relationship_category: family, business, legal, or financial"
    - name: "relationship_status"
      expr: relationship_status
      comment: "Current status of the relationship: active, inactive, or terminated"
    - name: "role_from"
      expr: role_from
      comment: "Role of the from party in the relationship"
    - name: "role_to"
      expr: role_to
      comment: "Role of the to party in the relationship"
    - name: "is_bidirectional"
      expr: is_bidirectional
      comment: "Boolean flag indicating relationship is bidirectional and symmetric"
    - name: "control_flag"
      expr: control_flag
      comment: "Boolean flag indicating from party has control over to party"
    - name: "fraud_indicator_flag"
      expr: fraud_indicator_flag
      comment: "Boolean flag indicating relationship has been flagged for potential fraud"
    - name: "uw_impact_flag"
      expr: uw_impact_flag
      comment: "Boolean flag indicating relationship impacts underwriting decision"
    - name: "verification_status"
      expr: verification_status
      comment: "Verification status of the relationship: verified, pending, or unverified"
  measures:
    - name: "total_relationships"
      expr: COUNT(1)
      comment: "Total count of party relationships for network complexity analysis"
    - name: "unique_relationships"
      expr: COUNT(DISTINCT relationship_id)
      comment: "Distinct count of relationships for deduplication quality"
    - name: "fraud_flagged_relationship_count"
      expr: COUNT(DISTINCT CASE WHEN fraud_indicator_flag = TRUE THEN relationship_id END)
      comment: "Count of relationships flagged for fraud for network investigation"
    - name: "uw_impact_relationship_count"
      expr: COUNT(DISTINCT CASE WHEN uw_impact_flag = TRUE THEN relationship_id END)
      comment: "Count of relationships impacting underwriting for risk assessment"
    - name: "control_relationship_count"
      expr: COUNT(DISTINCT CASE WHEN control_flag = TRUE THEN relationship_id END)
      comment: "Count of control relationships for ownership structure analysis"
    - name: "avg_ownership_percentage"
      expr: AVG(CAST(ownership_percentage AS DOUBLE))
      comment: "Average ownership percentage for beneficial ownership concentration analysis"
    - name: "verified_relationship_rate_pct"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN verification_status = 'verified' THEN relationship_id END) / NULLIF(COUNT(DISTINCT relationship_id), 0), 2)
      comment: "Percentage of verified relationships for data quality and compliance"
$$;