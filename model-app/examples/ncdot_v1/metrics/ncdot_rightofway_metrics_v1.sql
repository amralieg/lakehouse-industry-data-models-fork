-- Metric views for domain: rightofway | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rightofway_acquisition_request`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for right-of-way acquisition request performance, cost estimation accuracy, and project delivery risk. Used by ROW leadership to prioritize acquisitions, allocate resources, and identify bottlenecks in the acquisition pipeline."
  source: "`feip_eastus_03`.`rightofway`.`acquisition_request`"
  dimensions:
    - name: "request_year"
      expr: YEAR(request_date)
      comment: "Calendar year when the acquisition request was submitted, used for annual planning and trend analysis."
    - name: "request_quarter"
      expr: CONCAT('Q', QUARTER(request_date), '-', YEAR(request_date))
      comment: "Fiscal quarter of request submission for quarterly performance reviews and resource allocation."
    - name: "request_type"
      expr: request_type
      comment: "Type of right-of-way interest being requested (fee simple, easement, lease, license) for acquisition strategy analysis."
    - name: "priority_level"
      expr: priority_level
      comment: "Priority classification of the acquisition request based on project urgency and strategic importance."
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code responsible for the project, used for regional performance comparison and resource allocation."
    - name: "county_code"
      expr: county_code
      comment: "North Carolina county code where the right-of-way acquisition is located, used for geographic analysis and local impact assessment."
    - name: "federal_aid_project_flag"
      expr: federal_aid_project_flag
      comment: "Indicates whether this acquisition is part of a federal-aid project subject to FHWA requirements, critical for compliance tracking."
    - name: "relocation_required_flag"
      expr: relocation_required_flag
      comment: "Indicates whether property owner or tenant relocation assistance will be required, impacting cost and timeline."
    - name: "condemnation_anticipated_flag"
      expr: condemnation_anticipated_flag
      comment: "Indicates whether eminent domain condemnation proceedings are anticipated, signaling higher legal risk and cost."
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "State fiscal year in which the acquisition request was submitted or is planned for execution."
  measures:
    - name: "total_acquisition_requests"
      expr: COUNT(1)
      comment: "Total number of right-of-way acquisition requests submitted, baseline volume metric for workload planning."
    - name: "total_parcels_required"
      expr: SUM(CAST(total_parcels_required AS DOUBLE))
      comment: "Total number of individual parcels or properties that need to be acquired across all requests, key capacity planning metric."
    - name: "total_area_required_acres"
      expr: SUM(CAST(total_area_required_acres AS DOUBLE))
      comment: "Total land area in acres required to be acquired across all requests, used for environmental impact and cost estimation."
    - name: "total_estimated_cost"
      expr: SUM(CAST(estimated_total_cost AS DOUBLE))
      comment: "Total estimated cost in US dollars for acquiring all required right-of-way interests, critical for budget planning and funding allocation."
    - name: "total_estimated_property_cost"
      expr: SUM(CAST(estimated_property_cost AS DOUBLE))
      comment: "Total estimated cost for property or land interests excluding damages, used for property value analysis."
    - name: "total_estimated_damages_cost"
      expr: SUM(CAST(estimated_damages_cost AS DOUBLE))
      comment: "Total estimated cost for damages to remaining property and business losses, key risk metric for acquisition complexity."
    - name: "avg_estimated_cost_per_request"
      expr: AVG(CAST(estimated_total_cost AS DOUBLE))
      comment: "Average estimated cost per acquisition request, used for benchmarking and cost forecasting."
    - name: "avg_estimated_cost_per_acre"
      expr: ROUND(SUM(CAST(estimated_total_cost AS DOUBLE)) / NULLIF(SUM(CAST(total_area_required_acres AS DOUBLE)), 0), 2)
      comment: "Average estimated cost per acre of land acquired, critical KPI for cost efficiency and market rate comparison."
    - name: "relocation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN relocation_required_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of acquisition requests requiring relocation assistance, key metric for social impact and cost planning."
    - name: "condemnation_risk_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN condemnation_anticipated_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of acquisition requests anticipated to require condemnation proceedings, critical risk indicator for legal resource planning."
    - name: "federal_aid_participation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN federal_aid_project_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of acquisition requests part of federal-aid projects, important for compliance workload and funding mix analysis."
    - name: "avg_parcels_per_request"
      expr: ROUND(SUM(CAST(total_parcels_required AS DOUBLE)) / NULLIF(COUNT(1), 0), 2)
      comment: "Average number of parcels per acquisition request, indicator of acquisition complexity and negotiation workload."
    - name: "total_estimated_utility_relocation_cost"
      expr: SUM(CAST(estimated_utility_relocation_cost AS DOUBLE))
      comment: "Total estimated cost for relocating utilities within acquired right-of-way, critical for project budget completeness."
    - name: "utility_relocation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN utility_relocation_required_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of acquisition requests requiring utility relocation, key metric for project complexity and coordination needs."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rightofway_compensation_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Financial performance and compliance KPIs for landowner compensation payments. Used by finance and ROW leadership to monitor disbursement efficiency, cost accuracy, litigation risk, and federal compliance. Critical for audit readiness and budget variance analysis."
  source: "`feip_eastus_03`.`rightofway`.`compensation_payment`"
  dimensions:
    - name: "payment_year"
      expr: YEAR(sap_posting_date)
      comment: "Calendar year when the compensation payment was posted to the general ledger, used for annual financial reporting."
    - name: "payment_quarter"
      expr: CONCAT('Q', QUARTER(sap_posting_date), '-', YEAR(sap_posting_date))
      comment: "Fiscal quarter of payment posting for quarterly financial reviews and cash flow analysis."
    - name: "payment_type"
      expr: payment_type
      comment: "Classification of compensation payment based on the nature of property impact and acquisition type."
    - name: "payment_category"
      expr: payment_category
      comment: "Broad category of compensation payment aligned with federal and state right-of-way acquisition regulations."
    - name: "acquisition_type"
      expr: acquisition_type
      comment: "Legal classification of property rights being acquired from the landowner for the transportation project."
    - name: "property_county"
      expr: property_county
      comment: "North Carolina county in which the acquired property is located, used for geographic cost analysis."
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT geographic division number responsible for the transportation project and right-of-way acquisition."
    - name: "funding_source"
      expr: funding_source
      comment: "Primary source of funds used for the compensation payment, indicating federal, state, local, or mixed funding."
    - name: "federal_program_code"
      expr: federal_program_code
      comment: "Federal funding program code when federal funds are used for the compensation payment (e.g., NHPP, STP, HSIP, CMAQ)."
    - name: "condemnation_flag"
      expr: condemnation_flag
      comment: "Boolean flag indicating whether the property acquisition required condemnation proceedings through eminent domain authority."
    - name: "settlement_flag"
      expr: settlement_flag
      comment: "Boolean flag indicating whether the compensation payment represents an administrative settlement reached outside of court proceedings."
    - name: "relocation_assistance_flag"
      expr: relocation_assistance_flag
      comment: "Boolean flag indicating whether this payment includes relocation assistance benefits under the Uniform Relocation Act."
    - name: "fiscal_year"
      expr: CAST(fiscal_year AS STRING)
      comment: "State or federal fiscal year in which the compensation payment was budgeted and disbursed."
  measures:
    - name: "total_compensation_payments"
      expr: COUNT(1)
      comment: "Total number of compensation payment transactions issued to landowners, baseline volume metric for payment processing workload."
    - name: "total_negotiated_amount"
      expr: SUM(CAST(negotiated_amount AS DOUBLE))
      comment: "Total final compensation amount agreed upon through negotiation, key metric for acquisition cost management."
    - name: "total_net_payment_amount"
      expr: SUM(CAST(net_payment_amount AS DOUBLE))
      comment: "Total net compensation amount disbursed to payees after all deductions and withholdings, critical for cash flow and budget tracking."
    - name: "total_federal_share_amount"
      expr: SUM(CAST(federal_share_amount AS DOUBLE))
      comment: "Total portion of compensation payments funded by federal transportation funds, critical for federal reimbursement tracking."
    - name: "total_state_share_amount"
      expr: SUM(CAST(state_share_amount AS DOUBLE))
      comment: "Total portion of compensation payments funded by North Carolina state transportation funds, key for state budget management."
    - name: "total_local_share_amount"
      expr: SUM(CAST(local_share_amount AS DOUBLE))
      comment: "Total portion of compensation payments funded by local government or municipal funds, used for local partnership analysis."
    - name: "avg_negotiated_amount"
      expr: AVG(CAST(negotiated_amount AS DOUBLE))
      comment: "Average final compensation amount per payment, used for benchmarking and cost forecasting."
    - name: "total_court_award_amount"
      expr: SUM(CAST(court_award_amount AS DOUBLE))
      comment: "Total compensation amount determined by courts in condemnation proceedings, key metric for litigation cost impact."
    - name: "total_relocation_assistance_amount"
      expr: SUM(CAST(relocation_assistance_amount AS DOUBLE))
      comment: "Total portion of compensation allocated for relocation assistance benefits, critical for Uniform Relocation Act compliance."
    - name: "total_business_damages_amount"
      expr: SUM(CAST(business_damages_amount AS DOUBLE))
      comment: "Total compensation paid for business losses or damages, key metric for economic impact assessment."
    - name: "total_severance_damages_amount"
      expr: SUM(CAST(severance_damages_amount AS DOUBLE))
      comment: "Total compensation paid for diminished value of remaining property after partial acquisition, indicator of acquisition complexity."
    - name: "total_interest_amount"
      expr: SUM(CAST(interest_amount AS DOUBLE))
      comment: "Total interest amount paid to property owners for delayed compensation payments, key metric for payment timeliness and cost of delay."
    - name: "total_attorney_fees_amount"
      expr: SUM(CAST(attorney_fees_amount AS DOUBLE))
      comment: "Total amount paid for property owners attorney fees in condemnation proceedings, indicator of litigation cost."
    - name: "condemnation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN condemnation_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of compensation payments resulting from condemnation proceedings, critical risk indicator for negotiation effectiveness."
    - name: "settlement_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN settlement_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of compensation payments representing administrative settlements, indicator of negotiation success and litigation avoidance."
    - name: "relocation_assistance_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN relocation_assistance_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of payments including relocation assistance benefits, key metric for social impact and Uniform Relocation Act compliance."
    - name: "federal_funding_participation_rate"
      expr: ROUND(100.0 * SUM(CAST(federal_share_amount AS DOUBLE)) / NULLIF(SUM(CAST(net_payment_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of total compensation funded by federal sources, critical for federal reimbursement maximization and funding mix strategy."
    - name: "total_acreage_acquired"
      expr: SUM(CAST(acreage_acquired AS DOUBLE))
      comment: "Total land area in acres acquired across all compensation payments, used for environmental impact and land use analysis."
    - name: "avg_cost_per_acre"
      expr: ROUND(SUM(CAST(negotiated_amount AS DOUBLE)) / NULLIF(SUM(CAST(acreage_acquired AS DOUBLE)), 0), 2)
      comment: "Average compensation cost per acre of land acquired, critical KPI for cost efficiency and market rate benchmarking."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rightofway_parcel`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for right-of-way parcel acquisition performance, cost accuracy, and project delivery risk. Used by ROW leadership to monitor acquisition progress, appraisal accuracy, negotiation effectiveness, and identify high-risk parcels requiring management attention."
  source: "`feip_eastus_03`.`rightofway`.`parcel`"
  dimensions:
    - name: "acquisition_year"
      expr: YEAR(closing_date)
      comment: "Calendar year when the property transaction was closed and title transferred to the agency, used for annual performance tracking."
    - name: "acquisition_quarter"
      expr: CONCAT('Q', QUARTER(closing_date), '-', YEAR(closing_date))
      comment: "Fiscal quarter of property closing for quarterly performance reviews and acquisition velocity analysis."
    - name: "county_name"
      expr: county_name
      comment: "Name of the North Carolina county where the parcel is located, used for geographic cost and performance comparison."
    - name: "division_number"
      expr: CAST(division_number AS STRING)
      comment: "NCDOT division number responsible for managing this parcel, used for regional performance comparison."
    - name: "acquisition_type"
      expr: acquisition_type
      comment: "Type of property interest being acquired by the agency (fee simple, easement, lease, etc.)."
    - name: "acquisition_method"
      expr: acquisition_method
      comment: "Method used to acquire the property interest from the owner (negotiated purchase, condemnation, donation, etc.)."
    - name: "land_use_code"
      expr: land_use_code
      comment: "Standardized code representing the current use classification of the parcel, used for land use impact analysis."
    - name: "relocation_required_flag"
      expr: relocation_required_flag
      comment: "Indicates whether the property owner or tenant requires relocation assistance under the Uniform Relocation Act."
    - name: "improvements_present_flag"
      expr: improvements_present_flag
      comment: "Indicates whether buildings, structures, or other improvements exist on the parcel, impacting cost and complexity."
    - name: "federal_participation_flag"
      expr: federal_participation_flag
      comment: "Indicates whether federal funds are being used for the parcel acquisition, triggering federal compliance requirements."
    - name: "access_control_flag"
      expr: access_control_flag
      comment: "Indicates whether access control rights were acquired with the parcel, restricting direct access to the highway."
    - name: "priority_code"
      expr: priority_code
      comment: "Priority level assigned to the parcel acquisition based on project schedule and construction needs."
  measures:
    - name: "total_parcels"
      expr: COUNT(1)
      comment: "Total number of land parcels in the right-of-way inventory, baseline volume metric for acquisition workload."
    - name: "total_area_acres"
      expr: SUM(CAST(total_area_acres AS DOUBLE))
      comment: "Total land area of all parcels measured in acres, used for environmental impact and land use analysis."
    - name: "total_acquired_area_acres"
      expr: SUM(CAST(acquired_area_acres AS DOUBLE))
      comment: "Total portion of parcel area acquired by the agency in acres, key metric for acquisition progress tracking."
    - name: "total_appraised_value"
      expr: SUM(CAST(appraised_value AS DOUBLE))
      comment: "Total fair market value of property interests as determined by certified appraisers, baseline for cost estimation."
    - name: "total_offer_amount"
      expr: SUM(CAST(offer_amount AS DOUBLE))
      comment: "Total dollar amount offered to property owners for acquisition, used for initial budget planning."
    - name: "total_settlement_amount"
      expr: SUM(CAST(settlement_amount AS DOUBLE))
      comment: "Total final negotiated or adjudicated amount paid to property owners, critical for actual cost tracking and budget variance."
    - name: "avg_appraised_value"
      expr: AVG(CAST(appraised_value AS DOUBLE))
      comment: "Average fair market value per parcel, used for benchmarking and cost forecasting."
    - name: "avg_settlement_amount"
      expr: AVG(CAST(settlement_amount AS DOUBLE))
      comment: "Average final settlement amount per parcel, key metric for negotiation effectiveness and cost control."
    - name: "avg_cost_per_acre"
      expr: ROUND(SUM(CAST(settlement_amount AS DOUBLE)) / NULLIF(SUM(CAST(acquired_area_acres AS DOUBLE)), 0), 2)
      comment: "Average settlement cost per acre of land acquired, critical KPI for cost efficiency and market rate comparison."
    - name: "appraisal_to_settlement_variance_pct"
      expr: ROUND(100.0 * (SUM(CAST(settlement_amount AS DOUBLE)) - SUM(CAST(appraised_value AS DOUBLE))) / NULLIF(SUM(CAST(appraised_value AS DOUBLE)), 0), 2)
      comment: "Percentage variance between appraised value and final settlement amount, critical KPI for appraisal accuracy and negotiation effectiveness."
    - name: "offer_to_settlement_variance_pct"
      expr: ROUND(100.0 * (SUM(CAST(settlement_amount AS DOUBLE)) - SUM(CAST(offer_amount AS DOUBLE))) / NULLIF(SUM(CAST(offer_amount AS DOUBLE)), 0), 2)
      comment: "Percentage variance between initial offer and final settlement, key indicator of negotiation outcomes and cost overruns."
    - name: "relocation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN relocation_required_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of parcels requiring relocation assistance, key metric for social impact and cost planning."
    - name: "improvements_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN improvements_present_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of parcels with buildings or structures, indicator of acquisition complexity and cost."
    - name: "federal_participation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN federal_participation_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of parcels with federal funding participation, important for compliance workload and funding mix analysis."
    - name: "access_control_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN access_control_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of parcels with access control rights acquired, key metric for highway safety and access management strategy."
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`rightofway_easement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic KPIs for easement acquisition performance, cost efficiency, and portfolio management. Used by ROW leadership to monitor easement costs, appraisal accuracy, and identify high-value easement corridors requiring strategic management."
  source: "`feip_eastus_03`.`rightofway`.`easement`"
  dimensions:
    - name: "acquisition_year"
      expr: YEAR(acquisition_date)
      comment: "Calendar year when the easement was legally acquired by NCDOT, used for annual performance tracking."
    - name: "acquisition_quarter"
      expr: CONCAT('Q', QUARTER(acquisition_date), '-', YEAR(acquisition_date))
      comment: "Fiscal quarter of easement acquisition for quarterly performance reviews."
    - name: "easement_type"
      expr: type
      comment: "Classification of the easement based on duration and purpose (permanent, temporary, perpetual, term)."
    - name: "purpose"
      expr: purpose
      comment: "Detailed description of the intended use and purpose of the easement (highway construction, utility installation, drainage, etc.)."
    - name: "county"
      expr: county
      comment: "North Carolina county where the easement property is located, used for geographic cost analysis."
    - name: "acquisition_method"
      expr: acquisition_method
      comment: "Method by which the easement was acquired from the property owner (negotiated purchase, condemnation, donation, etc.)."
    - name: "federal_participation_flag"
      expr: federal_participation_flag
      comment: "Indicates whether federal funds are being used for the project requiring this easement, triggering additional compliance requirements."
  measures:
    - name: "total_easements"
      expr: COUNT(1)
      comment: "Total number of easement rights granted on parcels, baseline volume metric for easement portfolio management."
    - name: "total_easement_area_acres"
      expr: SUM(CAST(area_acres AS DOUBLE))
      comment: "Total area of all easement parcels measured in acres, used for land use and environmental impact analysis."
    - name: "total_easement_length_feet"
      expr: SUM(CAST(length_feet AS DOUBLE))
      comment: "Total length of all easement corridors in feet, key metric for linear infrastructure planning."
    - name: "total_compensation_amount"
      expr: SUM(CAST(compensation_amount AS DOUBLE))
      comment: "Total monetary compensation paid to grantors for granting easement rights, critical for budget tracking and cost management."
    - name: "total_appraised_value"
      expr: SUM(CAST(appraised_value AS DOUBLE))
      comment: "Total fair market value of easements as determined by certified appraisers, baseline for cost estimation."
    - name: "avg_compensation_amount"
      expr: AVG(CAST(compensation_amount AS DOUBLE))
      comment: "Average monetary compensation per easement, used for benchmarking and cost forecasting."
    - name: "avg_cost_per_acre"
      expr: ROUND(SUM(CAST(compensation_amount AS DOUBLE)) / NULLIF(SUM(CAST(area_acres AS DOUBLE)), 0), 2)
      comment: "Average compensation cost per acre of easement area, critical KPI for cost efficiency and market rate comparison."
    - name: "avg_cost_per_linear_foot"
      expr: ROUND(SUM(CAST(compensation_amount AS DOUBLE)) / NULLIF(SUM(CAST(length_feet AS DOUBLE)), 0), 2)
      comment: "Average compensation cost per linear foot of easement corridor, key metric for linear infrastructure cost benchmarking."
    - name: "appraisal_to_compensation_variance_pct"
      expr: ROUND(100.0 * (SUM(CAST(compensation_amount AS DOUBLE)) - SUM(CAST(appraised_value AS DOUBLE))) / NULLIF(SUM(CAST(appraised_value AS DOUBLE)), 0), 2)
      comment: "Percentage variance between appraised value and actual compensation paid, critical KPI for appraisal accuracy and negotiation effectiveness."
    - name: "federal_participation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN federal_participation_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of easements with federal funding participation, important for compliance workload and funding mix analysis."
    - name: "avg_easement_width_feet"
      expr: AVG(CAST(width_feet AS DOUBLE))
      comment: "Average width of easement corridors in feet, used for corridor design standards and right-of-way planning."
$$;