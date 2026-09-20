-- Metric views for domain: party | Business: Pc_Insurance | Version: 1 | Generated on: 2026-09-20 14:47:38

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core party metrics tracking entity counts, KYC compliance, fraud indicators, and data quality across individuals and organizations."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`party`"
  dimensions:
    - name: "party_type"
      expr: party_type
      comment: "Type of party: Individual or Organization"
    - name: "party_status"
      expr: party_status
      comment: "Current status of the party record"
    - name: "kyc_status"
      expr: kyc_status
      comment: "Know Your Customer verification status"
    - name: "source_system"
      expr: source_system_code
      comment: "Originating system for the party record"
    - name: "golden_record_flag"
      expr: golden_record_flag
      comment: "Indicates if this is the master golden record"
    - name: "fraud_indicator_flag"
      expr: fraud_indicator_flag
      comment: "Indicates potential fraud risk"
    - name: "ofac_match_flag"
      expr: ofac_match_flag
      comment: "Indicates OFAC watchlist match"
    - name: "do_not_contact_flag"
      expr: do_not_contact_flag
      comment: "Indicates party has opted out of contact"
    - name: "preferred_language"
      expr: preferred_language
      comment: "Party's preferred communication language"
    - name: "country"
      expr: country_code
      comment: "Country code for the party"
    - name: "state"
      expr: state_code
      comment: "State or province code"
    - name: "created_year"
      expr: YEAR(created_timestamp)
      comment: "Year the party record was created"
    - name: "created_month"
      expr: DATE_TRUNC('MONTH', created_timestamp)
      comment: "Month the party record was created"
  measures:
    - name: "total_parties"
      expr: COUNT(DISTINCT party_id)
      comment: "Total unique parties in the system"
    - name: "kyc_verified_parties"
      expr: COUNT(DISTINCT CASE WHEN kyc_status = 'Verified' THEN party_id END)
      comment: "Count of parties with verified KYC status"
    - name: "kyc_verification_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN kyc_status = 'Verified' THEN party_id END) / NULLIF(COUNT(DISTINCT party_id), 0), 2)
      comment: "Percentage of parties with verified KYC status"
    - name: "fraud_flagged_parties"
      expr: COUNT(DISTINCT CASE WHEN fraud_indicator_flag = TRUE THEN party_id END)
      comment: "Count of parties flagged for potential fraud"
    - name: "fraud_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN fraud_indicator_flag = TRUE THEN party_id END) / NULLIF(COUNT(DISTINCT party_id), 0), 2)
      comment: "Percentage of parties flagged for fraud"
    - name: "ofac_match_parties"
      expr: COUNT(DISTINCT CASE WHEN ofac_match_flag = TRUE THEN party_id END)
      comment: "Count of parties with OFAC watchlist matches"
    - name: "ofac_match_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN ofac_match_flag = TRUE THEN party_id END) / NULLIF(COUNT(DISTINCT party_id), 0), 2)
      comment: "Percentage of parties with OFAC matches"
    - name: "golden_record_parties"
      expr: COUNT(DISTINCT CASE WHEN golden_record_flag = TRUE THEN party_id END)
      comment: "Count of master golden record parties"
    - name: "do_not_contact_parties"
      expr: COUNT(DISTINCT CASE WHEN do_not_contact_flag = TRUE THEN party_id END)
      comment: "Count of parties who opted out of contact"
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score across all parties"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_role`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Party role metrics tracking role assignments, effective periods, compliance flags, and role-based risk indicators across policies and claims."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`role`"
  dimensions:
    - name: "role_type"
      expr: type_code
      comment: "Type of role assigned to the party"
    - name: "role_subtype"
      expr: subtype_code
      comment: "Subtype classification of the role"
    - name: "role_status"
      expr: role_status
      comment: "Current status of the role assignment"
    - name: "acord_role_code"
      expr: acord_role_code
      comment: "ACORD standard role code"
    - name: "is_primary_role"
      expr: is_primary_role
      comment: "Indicates if this is the primary role for the party"
    - name: "kyc_verified"
      expr: kyc_verified
      comment: "Indicates if KYC verification is complete for this role"
    - name: "ofac_screened"
      expr: ofac_screened
      comment: "Indicates if OFAC screening was performed"
    - name: "ofac_match_flag"
      expr: ofac_match_flag
      comment: "Indicates OFAC watchlist match for this role"
    - name: "siu_referral_flag"
      expr: siu_referral_flag
      comment: "Indicates referral to Special Investigation Unit"
    - name: "litigation_flag"
      expr: litigation_flag
      comment: "Indicates active litigation involving this role"
    - name: "represented_by_counsel"
      expr: represented_by_counsel
      comment: "Indicates party is represented by legal counsel"
    - name: "tax_reporting_required"
      expr: tax_reporting_required
      comment: "Indicates tax reporting is required for this role"
    - name: "effective_year"
      expr: YEAR(effective_date)
      comment: "Year the role became effective"
    - name: "effective_month"
      expr: DATE_TRUNC('MONTH', effective_date)
      comment: "Month the role became effective"
  measures:
    - name: "total_roles"
      expr: COUNT(DISTINCT role_id)
      comment: "Total unique role assignments"
    - name: "active_roles"
      expr: COUNT(DISTINCT CASE WHEN role_status = 'Active' THEN role_id END)
      comment: "Count of currently active role assignments"
    - name: "kyc_verified_roles"
      expr: COUNT(DISTINCT CASE WHEN kyc_verified = TRUE THEN role_id END)
      comment: "Count of roles with completed KYC verification"
    - name: "kyc_verification_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN kyc_verified = TRUE THEN role_id END) / NULLIF(COUNT(DISTINCT role_id), 0), 2)
      comment: "Percentage of roles with KYC verification complete"
    - name: "ofac_screened_roles"
      expr: COUNT(DISTINCT CASE WHEN ofac_screened = TRUE THEN role_id END)
      comment: "Count of roles that have been OFAC screened"
    - name: "ofac_match_roles"
      expr: COUNT(DISTINCT CASE WHEN ofac_match_flag = TRUE THEN role_id END)
      comment: "Count of roles with OFAC watchlist matches"
    - name: "siu_referral_roles"
      expr: COUNT(DISTINCT CASE WHEN siu_referral_flag = TRUE THEN role_id END)
      comment: "Count of roles referred to Special Investigation Unit"
    - name: "siu_referral_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN siu_referral_flag = TRUE THEN role_id END) / NULLIF(COUNT(DISTINCT role_id), 0), 2)
      comment: "Percentage of roles referred to SIU"
    - name: "litigation_roles"
      expr: COUNT(DISTINCT CASE WHEN litigation_flag = TRUE THEN role_id END)
      comment: "Count of roles involved in litigation"
    - name: "litigation_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN litigation_flag = TRUE THEN role_id END) / NULLIF(COUNT(DISTINCT role_id), 0), 2)
      comment: "Percentage of roles involved in litigation"
    - name: "avg_fraud_score"
      expr: AVG(CAST(fraud_score AS DOUBLE))
      comment: "Average fraud risk score across all roles"
    - name: "unique_parties_in_roles"
      expr: COUNT(DISTINCT party_id)
      comment: "Count of unique parties holding roles"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_individual`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Individual party metrics tracking demographics, credit profiles, compliance screening, and risk indicators for person entities."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`individual`"
  dimensions:
    - name: "gender"
      expr: gender_code
      comment: "Gender classification of the individual"
    - name: "marital_status"
      expr: marital_status_code
      comment: "Marital status of the individual"
    - name: "occupation"
      expr: occupation_code
      comment: "Occupation classification code"
    - name: "kyc_status"
      expr: kyc_status
      comment: "Know Your Customer verification status"
    - name: "credit_score_source"
      expr: credit_score_source
      comment: "Source of the credit score data"
    - name: "residency_state"
      expr: residency_state_code
      comment: "State of residency"
    - name: "residency_country"
      expr: residency_country_code
      comment: "Country of residency"
    - name: "citizenship_country"
      expr: citizenship_country_code
      comment: "Country of citizenship"
    - name: "preferred_language"
      expr: preferred_language_code
      comment: "Preferred communication language"
    - name: "fraud_indicator"
      expr: fraud_indicator_flag
      comment: "Indicates potential fraud risk"
    - name: "ofac_screened"
      expr: ofac_screened_flag
      comment: "Indicates OFAC screening was performed"
    - name: "golden_record"
      expr: golden_record_flag
      comment: "Indicates this is the master golden record"
    - name: "mvr_consent"
      expr: mvr_consent_flag
      comment: "Indicates consent for motor vehicle record check"
    - name: "clue_consent"
      expr: clue_consent_flag
      comment: "Indicates consent for CLUE report"
    - name: "age_band"
      expr: CASE WHEN DATEDIFF(YEAR, birth_date, CURRENT_DATE()) < 25 THEN 'Under 25' WHEN DATEDIFF(YEAR, birth_date, CURRENT_DATE()) BETWEEN 25 AND 34 THEN '25-34' WHEN DATEDIFF(YEAR, birth_date, CURRENT_DATE()) BETWEEN 35 AND 44 THEN '35-44' WHEN DATEDIFF(YEAR, birth_date, CURRENT_DATE()) BETWEEN 45 AND 54 THEN '45-54' WHEN DATEDIFF(YEAR, birth_date, CURRENT_DATE()) BETWEEN 55 AND 64 THEN '55-64' ELSE '65+' END
      comment: "Age band classification"
  measures:
    - name: "total_individuals"
      expr: COUNT(DISTINCT individual_id)
      comment: "Total unique individual parties"
    - name: "kyc_verified_individuals"
      expr: COUNT(DISTINCT CASE WHEN kyc_status = 'Verified' THEN individual_id END)
      comment: "Count of individuals with verified KYC status"
    - name: "kyc_verification_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN kyc_status = 'Verified' THEN individual_id END) / NULLIF(COUNT(DISTINCT individual_id), 0), 2)
      comment: "Percentage of individuals with verified KYC"
    - name: "fraud_flagged_individuals"
      expr: COUNT(DISTINCT CASE WHEN fraud_indicator_flag = TRUE THEN individual_id END)
      comment: "Count of individuals flagged for fraud"
    - name: "fraud_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN fraud_indicator_flag = TRUE THEN individual_id END) / NULLIF(COUNT(DISTINCT individual_id), 0), 2)
      comment: "Percentage of individuals flagged for fraud"
    - name: "ofac_screened_individuals"
      expr: COUNT(DISTINCT CASE WHEN ofac_screened_flag = TRUE THEN individual_id END)
      comment: "Count of individuals screened against OFAC"
    - name: "ofac_screening_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN ofac_screened_flag = TRUE THEN individual_id END) / NULLIF(COUNT(DISTINCT individual_id), 0), 2)
      comment: "Percentage of individuals OFAC screened"
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score across individuals"
    - name: "avg_years_continuously_insured"
      expr: AVG(CAST(years_continuously_insured AS DOUBLE))
      comment: "Average years of continuous insurance coverage"
    - name: "mvr_consent_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN mvr_consent_flag = TRUE THEN individual_id END) / NULLIF(COUNT(DISTINCT individual_id), 0), 2)
      comment: "Percentage of individuals who consented to MVR check"
    - name: "clue_consent_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN clue_consent_flag = TRUE THEN individual_id END) / NULLIF(COUNT(DISTINCT individual_id), 0), 2)
      comment: "Percentage of individuals who consented to CLUE report"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_organization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Organization party metrics tracking business profiles, financial health, compliance status, and risk indicators for commercial entities."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`organization`"
  dimensions:
    - name: "entity_type"
      expr: entity_type
      comment: "Legal entity type of the organization"
    - name: "kyc_status"
      expr: kyc_status
      comment: "Know Your Customer verification status"
    - name: "credit_score_source"
      expr: credit_score_source
      comment: "Source of the credit score data"
    - name: "incorporation_state"
      expr: incorporation_state
      comment: "State of incorporation"
    - name: "incorporation_country"
      expr: incorporation_country
      comment: "Country of incorporation"
    - name: "naics_code"
      expr: naics_code
      comment: "North American Industry Classification System code"
    - name: "sic_code"
      expr: sic_code
      comment: "Standard Industrial Classification code"
    - name: "publicly_traded"
      expr: publicly_traded
      comment: "Indicates if the organization is publicly traded"
    - name: "fraud_indicator"
      expr: fraud_indicator
      comment: "Indicates potential fraud risk"
    - name: "ofac_screened"
      expr: ofac_screened
      comment: "Indicates OFAC screening was performed"
    - name: "employee_size_band"
      expr: CASE WHEN employee_count < 10 THEN 'Micro (1-9)' WHEN employee_count BETWEEN 10 AND 49 THEN 'Small (10-49)' WHEN employee_count BETWEEN 50 AND 249 THEN 'Medium (50-249)' WHEN employee_count BETWEEN 250 AND 999 THEN 'Large (250-999)' ELSE 'Enterprise (1000+)' END
      comment: "Employee count size band"
    - name: "revenue_band"
      expr: CASE WHEN annual_revenue < 1000000 THEN 'Under $1M' WHEN annual_revenue BETWEEN 1000000 AND 9999999 THEN '$1M-$10M' WHEN annual_revenue BETWEEN 10000000 AND 49999999 THEN '$10M-$50M' WHEN annual_revenue BETWEEN 50000000 AND 99999999 THEN '$50M-$100M' ELSE '$100M+' END
      comment: "Annual revenue band"
    - name: "years_in_business_band"
      expr: CASE WHEN years_in_business < 2 THEN 'Startup (0-1)' WHEN years_in_business BETWEEN 2 AND 5 THEN 'Early Stage (2-5)' WHEN years_in_business BETWEEN 6 AND 10 THEN 'Growth (6-10)' WHEN years_in_business BETWEEN 11 AND 20 THEN 'Mature (11-20)' ELSE 'Established (20+)' END
      comment: "Years in business band"
  measures:
    - name: "total_organizations"
      expr: COUNT(DISTINCT organization_id)
      comment: "Total unique organization parties"
    - name: "kyc_verified_organizations"
      expr: COUNT(DISTINCT CASE WHEN kyc_status = 'Verified' THEN organization_id END)
      comment: "Count of organizations with verified KYC status"
    - name: "kyc_verification_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN kyc_status = 'Verified' THEN organization_id END) / NULLIF(COUNT(DISTINCT organization_id), 0), 2)
      comment: "Percentage of organizations with verified KYC"
    - name: "fraud_flagged_organizations"
      expr: COUNT(DISTINCT CASE WHEN fraud_indicator = TRUE THEN organization_id END)
      comment: "Count of organizations flagged for fraud"
    - name: "fraud_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN fraud_indicator = TRUE THEN organization_id END) / NULLIF(COUNT(DISTINCT organization_id), 0), 2)
      comment: "Percentage of organizations flagged for fraud"
    - name: "ofac_screened_organizations"
      expr: COUNT(DISTINCT CASE WHEN ofac_screened = TRUE THEN organization_id END)
      comment: "Count of organizations screened against OFAC"
    - name: "ofac_screening_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN ofac_screened = TRUE THEN organization_id END) / NULLIF(COUNT(DISTINCT organization_id), 0), 2)
      comment: "Percentage of organizations OFAC screened"
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score across organizations"
    - name: "total_annual_revenue"
      expr: SUM(CAST(annual_revenue AS DOUBLE))
      comment: "Total annual revenue across all organizations"
    - name: "avg_annual_revenue"
      expr: AVG(CAST(annual_revenue AS DOUBLE))
      comment: "Average annual revenue per organization"
    - name: "total_employees"
      expr: SUM(CAST(employee_count AS DOUBLE))
      comment: "Total employee count across all organizations"
    - name: "avg_employees"
      expr: AVG(CAST(employee_count AS DOUBLE))
      comment: "Average employee count per organization"
    - name: "avg_years_in_business"
      expr: AVG(CAST(years_in_business AS DOUBLE))
      comment: "Average years in business across organizations"
    - name: "publicly_traded_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN publicly_traded = TRUE THEN organization_id END) / NULLIF(COUNT(DISTINCT organization_id), 0), 2)
      comment: "Percentage of organizations that are publicly traded"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_kyc_verification`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KYC verification metrics tracking compliance screening outcomes, risk tiers, adverse media, PEP status, and SIU referrals for regulatory oversight."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`kyc_verification`"
  dimensions:
    - name: "verification_status"
      expr: verification_status
      comment: "Current status of KYC verification"
    - name: "verification_result"
      expr: verification_result
      comment: "Result of the verification process"
    - name: "verification_type"
      expr: verification_type
      comment: "Type of KYC verification performed"
    - name: "verification_method"
      expr: verification_method
      comment: "Method used for verification"
    - name: "risk_tier"
      expr: risk_tier
      comment: "Risk tier classification from KYC assessment"
    - name: "due_diligence_level"
      expr: due_diligence_level
      comment: "Level of due diligence applied"
    - name: "ofac_screening_status"
      expr: ofac_screening_status
      comment: "Status of OFAC screening"
    - name: "is_pep"
      expr: is_pep
      comment: "Indicates if party is a Politically Exposed Person"
    - name: "pep_category"
      expr: pep_category
      comment: "Category of PEP classification"
    - name: "is_adverse_media"
      expr: is_adverse_media
      comment: "Indicates adverse media findings"
    - name: "watchlist_screened"
      expr: watchlist_screened
      comment: "Indicates watchlist screening was performed"
    - name: "siu_referral"
      expr: siu_referral
      comment: "Indicates referral to Special Investigation Unit"
    - name: "sar_filed"
      expr: sar_filed
      comment: "Indicates Suspicious Activity Report was filed"
    - name: "analyst_decision"
      expr: analyst_decision
      comment: "Final decision by KYC analyst"
    - name: "third_party_provider"
      expr: third_party_provider
      comment: "Third-party verification provider used"
    - name: "verification_year"
      expr: YEAR(verification_date)
      comment: "Year of verification"
    - name: "verification_month"
      expr: DATE_TRUNC('MONTH', verification_date)
      comment: "Month of verification"
  measures:
    - name: "total_verifications"
      expr: COUNT(DISTINCT kyc_verification_id)
      comment: "Total unique KYC verification events"
    - name: "verified_parties"
      expr: COUNT(DISTINCT CASE WHEN verification_status = 'Verified' THEN kyc_party_id END)
      comment: "Count of parties with verified status"
    - name: "verification_success_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN verification_status = 'Verified' THEN kyc_verification_id END) / NULLIF(COUNT(DISTINCT kyc_verification_id), 0), 2)
      comment: "Percentage of verifications that succeeded"
    - name: "pep_identified_count"
      expr: COUNT(DISTINCT CASE WHEN is_pep = TRUE THEN kyc_verification_id END)
      comment: "Count of verifications identifying PEPs"
    - name: "pep_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_pep = TRUE THEN kyc_verification_id END) / NULLIF(COUNT(DISTINCT kyc_verification_id), 0), 2)
      comment: "Percentage of verifications identifying PEPs"
    - name: "adverse_media_count"
      expr: COUNT(DISTINCT CASE WHEN is_adverse_media = TRUE THEN kyc_verification_id END)
      comment: "Count of verifications with adverse media findings"
    - name: "adverse_media_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_adverse_media = TRUE THEN kyc_verification_id END) / NULLIF(COUNT(DISTINCT kyc_verification_id), 0), 2)
      comment: "Percentage of verifications with adverse media"
    - name: "siu_referral_count"
      expr: COUNT(DISTINCT CASE WHEN siu_referral = TRUE THEN kyc_verification_id END)
      comment: "Count of verifications referred to SIU"
    - name: "siu_referral_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN siu_referral = TRUE THEN kyc_verification_id END) / NULLIF(COUNT(DISTINCT kyc_verification_id), 0), 2)
      comment: "Percentage of verifications referred to SIU"
    - name: "sar_filed_count"
      expr: COUNT(DISTINCT CASE WHEN sar_filed = TRUE THEN kyc_verification_id END)
      comment: "Count of verifications resulting in SAR filing"
    - name: "sar_filing_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN sar_filed = TRUE THEN kyc_verification_id END) / NULLIF(COUNT(DISTINCT kyc_verification_id), 0), 2)
      comment: "Percentage of verifications resulting in SAR"
    - name: "watchlist_screened_count"
      expr: COUNT(DISTINCT CASE WHEN watchlist_screened = TRUE THEN kyc_verification_id END)
      comment: "Count of verifications with watchlist screening"
    - name: "watchlist_screening_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN watchlist_screened = TRUE THEN kyc_verification_id END) / NULLIF(COUNT(DISTINCT kyc_verification_id), 0), 2)
      comment: "Percentage of verifications with watchlist screening"
    - name: "avg_beneficial_owner_count"
      expr: AVG(CAST(beneficial_owner_count AS DOUBLE))
      comment: "Average number of beneficial owners per verification"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_consent_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Consent management metrics tracking opt-in rates, consent types, regulatory compliance, revocations, and data use permissions across channels."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`consent_record`"
  dimensions:
    - name: "consent_type"
      expr: consent_type
      comment: "Type of consent obtained"
    - name: "consent_status"
      expr: consent_status
      comment: "Current status of the consent"
    - name: "consent_action"
      expr: consent_action
      comment: "Action taken on the consent"
    - name: "consent_method"
      expr: consent_method
      comment: "Method by which consent was obtained"
    - name: "consent_channel"
      expr: consent_channel
      comment: "Channel through which consent was obtained"
    - name: "regulatory_basis"
      expr: regulatory_basis
      comment: "Regulatory basis for consent requirement"
    - name: "jurisdiction_state"
      expr: jurisdiction_state
      comment: "State jurisdiction for consent"
    - name: "jurisdiction_country"
      expr: jurisdiction_country
      comment: "Country jurisdiction for consent"
    - name: "data_use_purpose"
      expr: data_use_purpose
      comment: "Purpose for which data will be used"
    - name: "do_not_contact_flag"
      expr: do_not_contact_flag
      comment: "Indicates party opted out of contact"
    - name: "third_party_sharing_flag"
      expr: third_party_sharing_flag
      comment: "Indicates consent for third-party data sharing"
    - name: "verified_flag"
      expr: verified_flag
      comment: "Indicates consent has been verified"
    - name: "is_minor"
      expr: is_minor
      comment: "Indicates if consent subject is a minor"
    - name: "consent_year"
      expr: YEAR(consent_timestamp)
      comment: "Year consent was obtained"
    - name: "consent_month"
      expr: DATE_TRUNC('MONTH', consent_timestamp)
      comment: "Month consent was obtained"
  measures:
    - name: "total_consents"
      expr: COUNT(DISTINCT consent_record_id)
      comment: "Total unique consent records"
    - name: "active_consents"
      expr: COUNT(DISTINCT CASE WHEN consent_status = 'Active' THEN consent_record_id END)
      comment: "Count of currently active consents"
    - name: "revoked_consents"
      expr: COUNT(DISTINCT CASE WHEN consent_status = 'Revoked' THEN consent_record_id END)
      comment: "Count of revoked consents"
    - name: "revocation_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN consent_status = 'Revoked' THEN consent_record_id END) / NULLIF(COUNT(DISTINCT consent_record_id), 0), 2)
      comment: "Percentage of consents that were revoked"
    - name: "verified_consents"
      expr: COUNT(DISTINCT CASE WHEN verified_flag = TRUE THEN consent_record_id END)
      comment: "Count of verified consent records"
    - name: "verification_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN verified_flag = TRUE THEN consent_record_id END) / NULLIF(COUNT(DISTINCT consent_record_id), 0), 2)
      comment: "Percentage of consents that are verified"
    - name: "do_not_contact_count"
      expr: COUNT(DISTINCT CASE WHEN do_not_contact_flag = TRUE THEN consent_record_id END)
      comment: "Count of do-not-contact opt-outs"
    - name: "do_not_contact_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN do_not_contact_flag = TRUE THEN consent_record_id END) / NULLIF(COUNT(DISTINCT consent_record_id), 0), 2)
      comment: "Percentage of parties who opted out of contact"
    - name: "third_party_sharing_consents"
      expr: COUNT(DISTINCT CASE WHEN third_party_sharing_flag = TRUE THEN consent_record_id END)
      comment: "Count of consents allowing third-party sharing"
    - name: "third_party_sharing_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN third_party_sharing_flag = TRUE THEN consent_record_id END) / NULLIF(COUNT(DISTINCT consent_record_id), 0), 2)
      comment: "Percentage of consents allowing third-party sharing"
    - name: "minor_consents"
      expr: COUNT(DISTINCT CASE WHEN is_minor = TRUE THEN consent_record_id END)
      comment: "Count of consents involving minors"
    - name: "unique_consenting_parties"
      expr: COUNT(DISTINCT consent_party_id)
      comment: "Count of unique parties who provided consent"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_household`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Household metrics tracking member composition, credit profiles, policy tenure, marketing preferences, and geographic risk concentration."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`household`"
  dimensions:
    - name: "household_type"
      expr: household_type
      comment: "Type classification of the household"
    - name: "household_status"
      expr: household_status
      comment: "Current status of the household"
    - name: "kyc_verification_status"
      expr: kyc_verification_status
      comment: "KYC verification status for the household"
    - name: "catastrophe_zone"
      expr: catastrophe_zone_code
      comment: "Catastrophe zone classification"
    - name: "risk_territory"
      expr: risk_territory_code
      comment: "Risk territory code"
    - name: "primary_language"
      expr: primary_language_code
      comment: "Primary language of the household"
    - name: "do_not_contact_flag"
      expr: do_not_contact_flag
      comment: "Indicates household opted out of contact"
    - name: "marketing_opt_in_flag"
      expr: marketing_opt_in_flag
      comment: "Indicates household opted in to marketing"
    - name: "paperless_delivery_flag"
      expr: paperless_delivery_flag
      comment: "Indicates household uses paperless delivery"
    - name: "member_size_band"
      expr: CASE WHEN member_count = 1 THEN 'Single' WHEN member_count = 2 THEN 'Couple' WHEN member_count BETWEEN 3 AND 4 THEN 'Small Family (3-4)' ELSE 'Large Family (5+)' END
      comment: "Household member size band"
    - name: "established_year"
      expr: YEAR(established_date)
      comment: "Year the household was established"
  measures:
    - name: "total_households"
      expr: COUNT(DISTINCT household_id)
      comment: "Total unique households"
    - name: "kyc_verified_households"
      expr: COUNT(DISTINCT CASE WHEN kyc_verification_status = 'Verified' THEN household_id END)
      comment: "Count of households with verified KYC status"
    - name: "kyc_verification_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN kyc_verification_status = 'Verified' THEN household_id END) / NULLIF(COUNT(DISTINCT household_id), 0), 2)
      comment: "Percentage of households with verified KYC"
    - name: "marketing_opt_in_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN marketing_opt_in_flag = TRUE THEN household_id END) / NULLIF(COUNT(DISTINCT household_id), 0), 2)
      comment: "Percentage of households opted in to marketing"
    - name: "paperless_adoption_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN paperless_delivery_flag = TRUE THEN household_id END) / NULLIF(COUNT(DISTINCT household_id), 0), 2)
      comment: "Percentage of households using paperless delivery"
    - name: "do_not_contact_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN do_not_contact_flag = TRUE THEN household_id END) / NULLIF(COUNT(DISTINCT household_id), 0), 2)
      comment: "Percentage of households who opted out of contact"
    - name: "avg_credit_score"
      expr: AVG(CAST(credit_score AS DOUBLE))
      comment: "Average credit score across households"
    - name: "total_members"
      expr: SUM(CAST(member_count AS DOUBLE))
      comment: "Total members across all households"
    - name: "avg_members_per_household"
      expr: AVG(CAST(member_count AS DOUBLE))
      comment: "Average number of members per household"
    - name: "total_adults"
      expr: SUM(CAST(adult_count AS DOUBLE))
      comment: "Total adults across all households"
    - name: "total_dependents"
      expr: SUM(CAST(dependent_count AS DOUBLE))
      comment: "Total dependents across all households"
    - name: "avg_dependents_per_household"
      expr: AVG(CAST(dependent_count AS DOUBLE))
      comment: "Average number of dependents per household"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_license`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "License metrics tracking producer and adjuster licensing status, continuing education compliance, expiration risk, and disciplinary actions."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`license`"
  dimensions:
    - name: "license_type"
      expr: license_type
      comment: "Type of license held"
    - name: "license_status"
      expr: license_status
      comment: "Current status of the license"
    - name: "license_class"
      expr: class
      comment: "Class of the license"
    - name: "adjuster_type"
      expr: adjuster_type
      comment: "Type of adjuster license"
    - name: "issuing_state"
      expr: issuing_state_code
      comment: "State that issued the license"
    - name: "is_resident_license"
      expr: is_resident_license
      comment: "Indicates if this is a resident license"
    - name: "surplus_lines_authorized"
      expr: surplus_lines_authorized
      comment: "Indicates authorization for surplus lines"
    - name: "disciplinary_action_indicator"
      expr: disciplinary_action_indicator
      comment: "Indicates disciplinary action on record"
    - name: "nipr_verification_status"
      expr: nipr_verification_status
      comment: "NIPR verification status"
    - name: "background_check_status"
      expr: background_check_status
      comment: "Status of background check"
    - name: "ce_compliance_status"
      expr: CASE WHEN ce_credits_completed >= ce_credits_required THEN 'Compliant' WHEN ce_credits_completed < ce_credits_required THEN 'Non-Compliant' ELSE 'Unknown' END
      comment: "Continuing education compliance status"
    - name: "expiration_risk_band"
      expr: CASE WHEN DATEDIFF(DAY, CURRENT_DATE(), expiry_date) < 30 THEN 'Critical (< 30 days)' WHEN DATEDIFF(DAY, CURRENT_DATE(), expiry_date) BETWEEN 30 AND 90 THEN 'High (30-90 days)' WHEN DATEDIFF(DAY, CURRENT_DATE(), expiry_date) BETWEEN 91 AND 180 THEN 'Medium (91-180 days)' ELSE 'Low (> 180 days)' END
      comment: "License expiration risk band"
  measures:
    - name: "total_licenses"
      expr: COUNT(DISTINCT license_id)
      comment: "Total unique licenses"
    - name: "active_licenses"
      expr: COUNT(DISTINCT CASE WHEN license_status = 'Active' THEN license_id END)
      comment: "Count of currently active licenses"
    - name: "expired_licenses"
      expr: COUNT(DISTINCT CASE WHEN license_status = 'Expired' THEN license_id END)
      comment: "Count of expired licenses"
    - name: "expiration_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN license_status = 'Expired' THEN license_id END) / NULLIF(COUNT(DISTINCT license_id), 0), 2)
      comment: "Percentage of licenses that are expired"
    - name: "ce_compliant_licenses"
      expr: COUNT(DISTINCT CASE WHEN ce_credits_completed >= ce_credits_required THEN license_id END)
      comment: "Count of licenses compliant with CE requirements"
    - name: "ce_compliance_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN ce_credits_completed >= ce_credits_required THEN license_id END) / NULLIF(COUNT(DISTINCT license_id), 0), 2)
      comment: "Percentage of licenses compliant with CE"
    - name: "disciplinary_action_licenses"
      expr: COUNT(DISTINCT CASE WHEN disciplinary_action_indicator = TRUE THEN license_id END)
      comment: "Count of licenses with disciplinary actions"
    - name: "disciplinary_action_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN disciplinary_action_indicator = TRUE THEN license_id END) / NULLIF(COUNT(DISTINCT license_id), 0), 2)
      comment: "Percentage of licenses with disciplinary actions"
    - name: "surplus_lines_authorized_count"
      expr: COUNT(DISTINCT CASE WHEN surplus_lines_authorized = TRUE THEN license_id END)
      comment: "Count of licenses authorized for surplus lines"
    - name: "surplus_lines_authorization_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN surplus_lines_authorized = TRUE THEN license_id END) / NULLIF(COUNT(DISTINCT license_id), 0), 2)
      comment: "Percentage of licenses authorized for surplus lines"
    - name: "avg_ce_credits_completed"
      expr: AVG(CAST(ce_credits_completed AS DOUBLE))
      comment: "Average CE credits completed per license"
    - name: "avg_ce_credits_required"
      expr: AVG(CAST(ce_credits_required AS DOUBLE))
      comment: "Average CE credits required per license"
    - name: "unique_licensed_parties"
      expr: COUNT(DISTINCT party_id)
      comment: "Count of unique parties holding licenses"
$$;

CREATE OR REPLACE VIEW `vibe_pc_insurance_blog_v499`.`_metrics`.`party_address`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Address metrics tracking geographic distribution, catastrophe exposure, geocoding quality, coastal risk, and fire protection class for underwriting."
  source: "`vibe_pc_insurance_blog_v499`.`party`.`address`"
  dimensions:
    - name: "address_type"
      expr: address_type
      comment: "Type of address"
    - name: "address_status"
      expr: address_status
      comment: "Current status of the address"
    - name: "country"
      expr: country_code
      comment: "Country code"
    - name: "state"
      expr: state_code
      comment: "State code"
    - name: "county"
      expr: county
      comment: "County name"
    - name: "fire_protection_class"
      expr: fire_protection_class
      comment: "Fire protection class rating"
    - name: "iso_territory"
      expr: iso_territory_code
      comment: "ISO territory code"
    - name: "coastal_indicator"
      expr: coastal_indicator
      comment: "Indicates coastal location"
    - name: "wind_pool_indicator"
      expr: wind_pool_indicator
      comment: "Indicates wind pool eligibility"
    - name: "seasonal_indicator"
      expr: seasonal_indicator
      comment: "Indicates seasonal occupancy"
    - name: "primary_indicator"
      expr: primary_indicator
      comment: "Indicates primary address"
    - name: "geocode_quality"
      expr: geocode_quality
      comment: "Quality of geocoding"
    - name: "usps_standardized"
      expr: usps_standardized_indicator
      comment: "Indicates USPS standardization"
    - name: "do_not_mail"
      expr: do_not_mail_indicator
      comment: "Indicates do-not-mail flag"
    - name: "distance_to_coast_band"
      expr: CASE WHEN distance_to_coast_miles < 1 THEN 'Immediate (< 1 mi)' WHEN distance_to_coast_miles BETWEEN 1 AND 5 THEN 'Near (1-5 mi)' WHEN distance_to_coast_miles BETWEEN 5 AND 10 THEN 'Moderate (5-10 mi)' ELSE 'Inland (> 10 mi)' END
      comment: "Distance to coast band"
    - name: "distance_to_fire_station_band"
      expr: CASE WHEN distance_to_fire_station_miles < 1 THEN 'Excellent (< 1 mi)' WHEN distance_to_fire_station_miles BETWEEN 1 AND 3 THEN 'Good (1-3 mi)' WHEN distance_to_fire_station_miles BETWEEN 3 AND 5 THEN 'Fair (3-5 mi)' ELSE 'Poor (> 5 mi)' END
      comment: "Distance to fire station band"
  measures:
    - name: "total_addresses"
      expr: COUNT(DISTINCT address_id)
      comment: "Total unique addresses"
    - name: "active_addresses"
      expr: COUNT(DISTINCT CASE WHEN address_status = 'Active' THEN address_id END)
      comment: "Count of currently active addresses"
    - name: "coastal_addresses"
      expr: COUNT(DISTINCT CASE WHEN coastal_indicator = TRUE THEN address_id END)
      comment: "Count of addresses in coastal locations"
    - name: "coastal_exposure_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN coastal_indicator = TRUE THEN address_id END) / NULLIF(COUNT(DISTINCT address_id), 0), 2)
      comment: "Percentage of addresses in coastal locations"
    - name: "wind_pool_addresses"
      expr: COUNT(DISTINCT CASE WHEN wind_pool_indicator = TRUE THEN address_id END)
      comment: "Count of addresses eligible for wind pool"
    - name: "wind_pool_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN wind_pool_indicator = TRUE THEN address_id END) / NULLIF(COUNT(DISTINCT address_id), 0), 2)
      comment: "Percentage of addresses eligible for wind pool"
    - name: "seasonal_addresses"
      expr: COUNT(DISTINCT CASE WHEN seasonal_indicator = TRUE THEN address_id END)
      comment: "Count of seasonal occupancy addresses"
    - name: "usps_standardized_addresses"
      expr: COUNT(DISTINCT CASE WHEN usps_standardized_indicator = TRUE THEN address_id END)
      comment: "Count of USPS standardized addresses"
    - name: "usps_standardization_rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN usps_standardized_indicator = TRUE THEN address_id END) / NULLIF(COUNT(DISTINCT address_id), 0), 2)
      comment: "Percentage of addresses USPS standardized"
    - name: "avg_distance_to_coast"
      expr: AVG(CAST(distance_to_coast_miles AS DOUBLE))
      comment: "Average distance to coast in miles"
    - name: "avg_distance_to_fire_station"
      expr: AVG(CAST(distance_to_fire_station_miles AS DOUBLE))
      comment: "Average distance to fire station in miles"
    - name: "unique_parties_with_addresses"
      expr: COUNT(DISTINCT party_id)
      comment: "Count of unique parties with addresses"
$$;