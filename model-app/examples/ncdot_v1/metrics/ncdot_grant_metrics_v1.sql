-- Metric views for domain: grant | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`grant_application`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Grant application performance metrics tracking application volume, funding requests, approval rates, and project readiness for strategic grant program management and resource allocation decisions."
  source: "`feip_eastus_03`.`grant`.`application`"
  dimensions:
    - name: "application_status"
      expr: status
      comment: "Current status of the grant application in the review and approval process (submitted, under review, approved, rejected, withdrawn)"
    - name: "applicant_type"
      expr: applicant_type
      comment: "Classification of the applicant organization type for eligibility and reporting purposes (state agency, local government, MPO, RPO, private entity)"
    - name: "project_type"
      expr: project_type
      comment: "Classification of the project type based on the nature of the transportation improvement (highway, bridge, transit, rail, aviation, multimodal)"
    - name: "project_category"
      expr: project_category
      comment: "Primary category or focus area of the project for prioritization and evaluation purposes (safety, mobility, economic development, environmental)"
    - name: "federal_fiscal_year"
      expr: CAST(federal_fiscal_year AS STRING)
      comment: "Federal fiscal year for which the grant funding is requested, running from October 1 to September 30"
    - name: "state_fiscal_year"
      expr: CAST(state_fiscal_year AS STRING)
      comment: "State fiscal year for which the grant funding is requested, running from July 1 to June 30 for North Carolina"
    - name: "project_county"
      expr: project_county
      comment: "North Carolina county or counties where the project is located"
    - name: "mpo_name"
      expr: mpo_name
      comment: "Name of the MPO responsible for the project area, if located in a metropolitan planning area"
    - name: "rpo_name"
      expr: rpo_name
      comment: "Name of the RPO responsible for the project area, if located in a rural planning area"
    - name: "is_shovel_ready"
      expr: is_shovel_ready
      comment: "Indicator of whether the project has completed all preliminary requirements and is ready to proceed to construction immediately upon funding"
    - name: "submission_year"
      expr: YEAR(submission_date)
      comment: "Year when the grant application was officially submitted to the funding agency"
    - name: "submission_quarter"
      expr: CONCAT('Q', CAST(QUARTER(submission_date) AS STRING), '-', CAST(YEAR(submission_date) AS STRING))
      comment: "Quarter and year when the grant application was submitted for trend analysis"
  measures:
    - name: "total_applications"
      expr: COUNT(1)
      comment: "Total number of grant applications submitted for tracking application volume and program demand"
    - name: "total_requested_amount"
      expr: SUM(CAST(requested_amount AS DOUBLE))
      comment: "Total dollar amount of federal or state grant funding requested across all applications for budget planning and demand forecasting"
    - name: "total_awarded_amount"
      expr: SUM(CAST(awarded_amount AS DOUBLE))
      comment: "Total dollar amount of grant funding awarded to applicants for tracking program disbursement and budget execution"
    - name: "total_match_amount"
      expr: SUM(CAST(match_amount AS DOUBLE))
      comment: "Total dollar amount of local or non-federal matching funds committed by applicants for tracking leveraged investment"
    - name: "total_project_cost"
      expr: SUM(CAST(total_project_cost AS DOUBLE))
      comment: "Total estimated cost of all projects including both requested grant funds and local match for portfolio valuation"
    - name: "avg_requested_amount"
      expr: AVG(CAST(requested_amount AS DOUBLE))
      comment: "Average dollar amount of grant funding requested per application for sizing and benchmarking analysis"
    - name: "avg_review_score"
      expr: AVG(CAST(review_score AS DOUBLE))
      comment: "Average numerical score assigned to applications during evaluation for quality assessment and competitive analysis"
    - name: "avg_benefit_cost_ratio"
      expr: AVG(CAST(benefit_cost_ratio AS DOUBLE))
      comment: "Average calculated ratio of project benefits to costs for portfolio efficiency and prioritization decisions"
    - name: "approval_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applications approved for funding, critical KPI for program effectiveness and applicant success rates"
    - name: "funding_award_rate"
      expr: ROUND(100.0 * SUM(CAST(awarded_amount AS DOUBLE)) / NULLIF(SUM(CAST(requested_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of requested funding actually awarded, key metric for budget adequacy and competitive pressure analysis"
    - name: "avg_match_percentage"
      expr: AVG(CAST(match_percentage AS DOUBLE))
      comment: "Average percentage of total project cost provided as local match for tracking leveraged investment and cost-sharing compliance"
    - name: "shovel_ready_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN is_shovel_ready = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applications that are shovel-ready, critical for rapid deployment and obligation deadline management"
    - name: "distinct_applicants"
      expr: COUNT(DISTINCT applicant_organization_name)
      comment: "Number of unique organizations submitting applications for tracking program reach and diversity of participation"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`grant_award`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Grant award financial and performance metrics tracking obligations, expenditures, remaining balances, and compliance status for portfolio management and federal reporting."
  source: "`feip_eastus_03`.`grant`.`award`"
  dimensions:
    - name: "award_status"
      expr: status
      comment: "Current lifecycle status of the grant award (active, closed, suspended, terminated)"
    - name: "award_type"
      expr: type
      comment: "Type of financial assistance instrument used for the award (grant, cooperative agreement, loan)"
    - name: "federal_fiscal_year"
      expr: CAST(federal_fiscal_year AS STRING)
      comment: "Federal fiscal year in which the grant award was made or is active"
    - name: "state_fiscal_year"
      expr: CAST(state_fiscal_year AS STRING)
      comment: "North Carolina state fiscal year in which the grant award was made or is active"
    - name: "county"
      expr: county
      comment: "North Carolina county in which the funded project is located"
    - name: "division"
      expr: division
      comment: "NCDOT highway division responsible for the project funded by the grant award"
    - name: "mpo_name"
      expr: mpo_name
      comment: "Name of the MPO associated with the project location, if applicable"
    - name: "rpo_name"
      expr: rpo_name
      comment: "Name of the RPO associated with the project location, if applicable"
    - name: "compliance_status"
      expr: compliance_status
      comment: "Current compliance status of the grant award with federal and state regulations"
    - name: "environmental_clearance_type"
      expr: environmental_clearance_type
      comment: "Type of National Environmental Policy Act (NEPA) clearance obtained for the project (CE, EA, EIS, FONSI)"
    - name: "award_year"
      expr: YEAR(date)
      comment: "Year in which the grant award was officially made by the funding agency"
    - name: "award_quarter"
      expr: CONCAT('Q', CAST(QUARTER(date) AS STRING), '-', CAST(YEAR(date) AS STRING))
      comment: "Quarter and year when the grant award was made for trend analysis"
  measures:
    - name: "total_awards"
      expr: COUNT(1)
      comment: "Total number of grant awards for tracking program activity and portfolio size"
    - name: "total_award_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total dollar amount of grant awards approved by funding agencies for budget tracking and portfolio valuation"
    - name: "total_federal_amount"
      expr: SUM(CAST(federal_amount AS DOUBLE))
      comment: "Total federal funding portion of awards for federal budget execution and drawdown tracking"
    - name: "total_state_match_amount"
      expr: SUM(CAST(state_match_amount AS DOUBLE))
      comment: "Total required state matching funds contribution for state budget planning and cost-sharing compliance"
    - name: "total_local_match_amount"
      expr: SUM(CAST(local_match_amount AS DOUBLE))
      comment: "Total required local government matching funds for tracking leveraged investment and partnership contributions"
    - name: "total_obligated_amount"
      expr: SUM(CAST(total_obligated_amount AS DOUBLE))
      comment: "Total amount of federal funds obligated to awards by funding agencies for obligation tracking and lapsing prevention"
    - name: "total_expended_amount"
      expr: SUM(CAST(total_expended_amount AS DOUBLE))
      comment: "Total amount of funds expended to date on grant awards for cash flow management and burn rate analysis"
    - name: "total_remaining_balance"
      expr: SUM(CAST(remaining_balance AS DOUBLE))
      comment: "Total remaining unspent balance across all grant awards for pipeline management and forecasting future expenditures"
    - name: "avg_award_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average dollar amount per grant award for benchmarking and sizing analysis"
    - name: "avg_cost_share_percentage"
      expr: AVG(CAST(cost_share_percentage AS DOUBLE))
      comment: "Average percentage of total project cost provided as matching funds for cost-sharing policy analysis"
    - name: "expenditure_rate"
      expr: ROUND(100.0 * SUM(CAST(total_expended_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_obligated_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of obligated funds that have been expended, critical KPI for drawdown performance and lapsing risk management"
    - name: "federal_share_percentage"
      expr: ROUND(100.0 * SUM(CAST(federal_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Percentage of total award amount provided by federal funding sources for funding mix analysis and federal dependency tracking"
    - name: "avg_dbe_goal_percentage"
      expr: AVG(CAST(dbe_goal_percentage AS DOUBLE))
      comment: "Average target percentage of contract dollars to be awarded to DBE firms for civil rights compliance and equity tracking"
    - name: "avg_dbe_actual_percentage"
      expr: AVG(CAST(dbe_actual_percentage AS DOUBLE))
      comment: "Average actual percentage of contract dollars awarded to DBE firms for performance against equity goals"
    - name: "dbe_goal_attainment_rate"
      expr: ROUND(100.0 * AVG(CAST(dbe_actual_percentage AS DOUBLE)) / NULLIF(AVG(CAST(dbe_goal_percentage AS DOUBLE)), 0), 2)
      comment: "Percentage of DBE goal achieved on average, critical compliance metric for USDOT civil rights requirements and equity performance"
    - name: "distinct_recipients"
      expr: COUNT(DISTINCT applicant_id)
      comment: "Number of unique recipients receiving grant awards for tracking program reach and concentration risk"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`grant_disbursement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Grant disbursement cash flow metrics tracking payment volume, amounts by funding source, and reimbursement processing for treasury management and federal drawdown optimization."
  source: "`feip_eastus_03`.`grant`.`disbursement`"
  dimensions:
    - name: "disbursement_status"
      expr: status
      comment: "Current processing status of the disbursement transaction (pending, approved, processed, cleared, reversed)"
    - name: "disbursement_type"
      expr: type
      comment: "Classification of the disbursement based on payment timing and purpose (advance, reimbursement, final payment)"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary source of funds for this disbursement (FHWA, FTA, FAA, FRA, state funds)"
    - name: "federal_fiscal_year"
      expr: federal_fiscal_year
      comment: "Federal fiscal year associated with the grant funding"
    - name: "state_fiscal_year"
      expr: state_fiscal_year
      comment: "State fiscal year associated with the grant funding"
    - name: "cost_category"
      expr: cost_category
      comment: "Category of project cost covered by this disbursement (construction, engineering, right-of-way, equipment)"
    - name: "expenditure_category"
      expr: expenditure_category
      comment: "Detailed classification of the expenditure type for financial reporting"
    - name: "mpo_name"
      expr: mpo_name
      comment: "Name of the MPO associated with the project funded by this disbursement"
    - name: "rpo_name"
      expr: rpo_name
      comment: "Name of the RPO associated with the project funded by this disbursement"
    - name: "compliance_review_status"
      expr: compliance_review_status
      comment: "Status of compliance review for this disbursement (pending, approved, flagged)"
    - name: "disbursement_year"
      expr: YEAR(date)
      comment: "Year in which the funds were disbursed to the grant awardee"
    - name: "disbursement_quarter"
      expr: CONCAT('Q', CAST(QUARTER(date) AS STRING), '-', CAST(YEAR(date) AS STRING))
      comment: "Quarter and year when the disbursement was made for cash flow trend analysis"
    - name: "disbursement_month"
      expr: DATE_TRUNC('MONTH', date)
      comment: "Month when the disbursement was made for monthly cash flow tracking"
  measures:
    - name: "total_disbursements"
      expr: COUNT(1)
      comment: "Total number of disbursement transactions for tracking payment volume and processing activity"
    - name: "total_disbursement_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total dollar amount disbursed across all transactions for cash flow management and treasury forecasting"
    - name: "total_federal_share_amount"
      expr: SUM(CAST(federal_share_amount AS DOUBLE))
      comment: "Total federal funding portion disbursed for federal drawdown tracking and ASAP reconciliation"
    - name: "total_state_share_amount"
      expr: SUM(CAST(state_share_amount AS DOUBLE))
      comment: "Total state funding portion disbursed for state budget execution and cash management"
    - name: "total_local_share_amount"
      expr: SUM(CAST(local_share_amount AS DOUBLE))
      comment: "Total local government funding portion disbursed for tracking partner contributions and cost-sharing compliance"
    - name: "total_indirect_cost_amount"
      expr: SUM(CAST(indirect_cost_amount AS DOUBLE))
      comment: "Total dollar amount of indirect costs included in disbursements for overhead cost tracking and rate validation"
    - name: "total_direct_cost_amount"
      expr: SUM(CAST(direct_cost_amount AS DOUBLE))
      comment: "Total dollar amount of direct costs included in disbursements for project cost tracking and budget analysis"
    - name: "total_dbe_participation_amount"
      expr: SUM(CAST(dbe_participation_amount AS DOUBLE))
      comment: "Total dollar amount of DBE participation included in disbursements for civil rights compliance and equity tracking"
    - name: "avg_disbursement_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average dollar amount per disbursement transaction for payment sizing and benchmarking analysis"
    - name: "avg_indirect_cost_rate"
      expr: AVG(CAST(indirect_cost_rate AS DOUBLE))
      comment: "Average approved indirect cost rate applied to disbursements for overhead rate benchmarking"
    - name: "avg_dbe_participation_percentage"
      expr: AVG(CAST(dbe_participation_percentage AS DOUBLE))
      comment: "Average percentage of DBE participation in disbursements for equity performance tracking"
    - name: "federal_share_percentage"
      expr: ROUND(100.0 * SUM(CAST(federal_share_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Percentage of total disbursements funded by federal sources for funding mix analysis and federal dependency tracking"
    - name: "indirect_cost_percentage"
      expr: ROUND(100.0 * SUM(CAST(indirect_cost_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Percentage of disbursements allocated to indirect costs for overhead cost analysis and rate validation"
    - name: "distinct_recipients"
      expr: COUNT(DISTINCT applicant_id)
      comment: "Number of unique recipients receiving disbursements for tracking payment distribution and concentration"
    - name: "distinct_awards"
      expr: COUNT(DISTINCT award_id)
      comment: "Number of unique grant awards with disbursement activity for active portfolio tracking"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`grant_expense`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Grant expense tracking metrics for reimbursement claims, cost allocation, and allowability analysis supporting federal audit compliance and financial reporting."
  source: "`feip_eastus_03`.`grant`.`expense`"
  dimensions:
    - name: "expense_type"
      expr: type
      comment: "Category of the expense as defined by federal grant cost principles (personnel, travel, equipment, construction, supplies)"
    - name: "cost_category"
      expr: cost_category
      comment: "Classification of the expense as either direct cost or indirect cost for cost allocation and compliance"
    - name: "approval_status"
      expr: approval_status
      comment: "Current approval status of the expense claim in the reimbursement workflow (pending, approved, rejected)"
    - name: "reimbursement_status"
      expr: reimbursement_status
      comment: "Current status of the reimbursement request for this expense (submitted, approved, paid, denied)"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Federal or state fiscal year in which the expense was incurred"
    - name: "federal_agency_name"
      expr: federal_agency_name
      comment: "Name of the federal agency providing the grant funding (FHWA, FTA, FAA, FRA)"
    - name: "allowable_flag"
      expr: allowable_flag
      comment: "Indicates whether the expense meets federal cost principles and is allowable under the grant agreement"
    - name: "allocable_flag"
      expr: allocable_flag
      comment: "Indicates whether the expense is allocable to the grant project according to the benefit received"
    - name: "reasonable_flag"
      expr: reasonable_flag
      comment: "Indicates whether the expense is reasonable in nature and amount for the goods or services provided"
    - name: "audit_finding_flag"
      expr: audit_finding_flag
      comment: "Indicates whether this expense was identified in a federal or state audit finding"
    - name: "expense_year"
      expr: YEAR(date)
      comment: "Year in which the expense was incurred or the service/goods were received"
    - name: "expense_quarter"
      expr: CONCAT('Q', CAST(QUARTER(date) AS STRING), '-', CAST(YEAR(date) AS STRING))
      comment: "Quarter and year when the expense was incurred for trend analysis"
  measures:
    - name: "total_expenses"
      expr: COUNT(1)
      comment: "Total number of expense records for tracking claim volume and processing activity"
    - name: "total_expense_amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total monetary amount of expenses incurred for budget tracking and cost analysis"
    - name: "total_federal_share_amount"
      expr: SUM(CAST(federal_share_amount AS DOUBLE))
      comment: "Total federal funding portion of expenses for federal reimbursement tracking and budget execution"
    - name: "total_state_match_amount"
      expr: SUM(CAST(state_match_amount AS DOUBLE))
      comment: "Total state matching funds portion of expenses for state budget tracking and cost-sharing compliance"
    - name: "total_local_match_amount"
      expr: SUM(CAST(local_match_amount AS DOUBLE))
      comment: "Total local government matching funds portion of expenses for tracking partner contributions"
    - name: "total_reimbursement_amount"
      expr: SUM(CAST(reimbursement_amount AS DOUBLE))
      comment: "Total amount reimbursed by federal agencies for expenses, critical for cash flow and receivables tracking"
    - name: "total_disallowed_amount"
      expr: SUM(CAST(disallowed_amount AS DOUBLE))
      comment: "Total portion of expenses disallowed by federal agencies, key metric for compliance risk and audit exposure"
    - name: "avg_expense_amount"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average monetary amount per expense record for sizing and benchmarking analysis"
    - name: "reimbursement_rate"
      expr: ROUND(100.0 * SUM(CAST(reimbursement_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Percentage of claimed expenses actually reimbursed, critical KPI for allowability compliance and audit risk management"
    - name: "disallowance_rate"
      expr: ROUND(100.0 * SUM(CAST(disallowed_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Percentage of expenses disallowed by federal agencies, key compliance metric for audit findings and cost principle violations"
    - name: "federal_share_percentage"
      expr: ROUND(100.0 * SUM(CAST(federal_share_amount AS DOUBLE)) / NULLIF(SUM(CAST(amount AS DOUBLE)), 0), 2)
      comment: "Percentage of expenses funded by federal sources for funding mix analysis and cost-sharing validation"
    - name: "allowable_expense_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN allowable_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of expenses meeting federal cost principles, critical compliance metric for allowability and audit readiness"
    - name: "audit_finding_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN audit_finding_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of expenses identified in audit findings, key risk metric for compliance management and corrective action prioritization"
    - name: "distinct_awards"
      expr: COUNT(DISTINCT award_id)
      comment: "Number of unique grant awards with expense activity for active portfolio tracking"
    - name: "distinct_vendors"
      expr: COUNT(DISTINCT vendor_id)
      comment: "Number of unique vendors receiving payments for tracking vendor diversity and concentration"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`grant_compliance_check`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Grant compliance monitoring metrics tracking audit findings, questioned costs, corrective actions, and compliance determinations for risk management and federal oversight."
  source: "`feip_eastus_03`.`grant`.`compliance_check`"
  dimensions:
    - name: "check_type"
      expr: check_type
      comment: "The category or type of compliance monitoring activity being performed (desk review, site visit, single audit, program review)"
    - name: "check_status"
      expr: check_status
      comment: "Current status of the compliance monitoring activity (scheduled, in progress, completed, closed)"
    - name: "risk_level"
      expr: risk_level
      comment: "The assessed risk level of the grant or subrecipient being reviewed (low, medium, high)"
    - name: "compliance_determination"
      expr: compliance_determination
      comment: "The overall determination of compliance status based on the review findings (compliant, non-compliant, qualified)"
    - name: "corrective_action_plan_status"
      expr: corrective_action_plan_status
      comment: "The current status of the corrective action plan (pending, submitted, approved, implemented, verified)"
    - name: "reviewing_organization"
      expr: reviewing_organization
      comment: "The organizational unit or external entity conducting the compliance check (NCDOT, FHWA, FTA, OIG)"
    - name: "compliance_area"
      expr: compliance_area
      comment: "The specific area of compliance being reviewed as defined in the OMB Compliance Supplement (activities allowed, allowable costs, cash management, procurement)"
    - name: "sanctions_imposed"
      expr: sanctions_imposed
      comment: "Indicates whether sanctions were imposed as a result of the compliance check"
    - name: "review_year"
      expr: YEAR(start_date)
      comment: "Year when the compliance check activity began"
    - name: "review_quarter"
      expr: CONCAT('Q', CAST(QUARTER(start_date) AS STRING), '-', CAST(YEAR(start_date) AS STRING))
      comment: "Quarter and year when the compliance check began for trend analysis"
  measures:
    - name: "total_compliance_checks"
      expr: COUNT(1)
      comment: "Total number of compliance monitoring activities for tracking oversight volume and program coverage"
    - name: "total_findings"
      expr: SUM(CAST(finding_count AS DOUBLE))
      comment: "Total number of compliance findings identified across all reviews for risk assessment and corrective action prioritization"
    - name: "total_material_weaknesses"
      expr: SUM(CAST(material_weakness_count AS DOUBLE))
      comment: "Total number of material weaknesses identified in internal controls, critical metric for systemic risk and audit exposure"
    - name: "total_significant_deficiencies"
      expr: SUM(CAST(significant_deficiency_count AS DOUBLE))
      comment: "Total number of significant deficiencies identified in internal controls for control environment assessment"
    - name: "total_questioned_costs"
      expr: SUM(CAST(questioned_cost_amount AS DOUBLE))
      comment: "Total dollar amount of costs questioned during compliance reviews, key financial risk metric for potential disallowances"
    - name: "total_disallowed_costs"
      expr: SUM(CAST(disallowed_cost_amount AS DOUBLE))
      comment: "Total dollar amount of costs disallowed as a result of compliance reviews, critical metric for financial impact and recovery actions"
    - name: "total_federal_expenditures_reviewed"
      expr: SUM(CAST(federal_expenditure_amount AS DOUBLE))
      comment: "Total amount of federal expenditures reviewed during compliance checks for coverage analysis and risk-based monitoring"
    - name: "avg_findings_per_check"
      expr: AVG(CAST(finding_count AS DOUBLE))
      comment: "Average number of findings per compliance check for benchmarking and quality assessment"
    - name: "finding_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN finding_count > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of compliance checks that identified findings, key metric for compliance risk and program health"
    - name: "material_weakness_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN material_weakness_count > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of compliance checks that identified material weaknesses, critical risk indicator for systemic control failures"
    - name: "questioned_cost_rate"
      expr: ROUND(100.0 * SUM(CAST(questioned_cost_amount AS DOUBLE)) / NULLIF(SUM(CAST(federal_expenditure_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of federal expenditures questioned during reviews, key metric for financial risk and allowability compliance"
    - name: "disallowance_rate"
      expr: ROUND(100.0 * SUM(CAST(disallowed_cost_amount AS DOUBLE)) / NULLIF(SUM(CAST(questioned_cost_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of questioned costs ultimately disallowed, critical metric for audit resolution and financial recovery"
    - name: "corrective_action_required_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN corrective_action_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of compliance checks requiring corrective action, key metric for compliance burden and remediation workload"
    - name: "sanction_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN sanctions_imposed = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of compliance checks resulting in sanctions, critical metric for enforcement actions and serious non-compliance"
    - name: "distinct_awards_reviewed"
      expr: COUNT(DISTINCT award_id)
      comment: "Number of unique grant awards subject to compliance checks for monitoring coverage and risk-based selection"
    - name: "distinct_recipients_reviewed"
      expr: COUNT(DISTINCT applicant_id)
      comment: "Number of unique recipients subject to compliance checks for subrecipient monitoring coverage"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`grant_grant_program`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Grant program portfolio metrics tracking budget authority, funding allocations, program status, and policy requirements for strategic program management and federal reporting."
  source: "`feip_eastus_03`.`grant`.`grant_program`"
  dimensions:
    - name: "program_type"
      expr: type
      comment: "Classification of the grant program by funding source level (federal, state, local, private foundation, joint funding)"
    - name: "program_status"
      expr: status
      comment: "Current operational status of the grant program indicating whether it is actively accepting applications and awarding funds"
    - name: "funding_source"
      expr: funding_source
      comment: "Primary federal or state agency or program providing the grant funding (FHWA, FTA, FAA, FRA, BUILD, INFRA, RAISE, CMAQ, HSIP)"
    - name: "federal_agency"
      expr: federal_agency
      comment: "Federal agency administering the grant program (FHWA, FTA, FAA, FRA, NHTSA, USDOT)"
    - name: "application_cycle"
      expr: application_cycle
      comment: "Frequency with which the grant program accepts applications (annual, biennial, quarterly, continuous rolling basis, one-time)"
    - name: "competitive_selection"
      expr: competitive_selection
      comment: "Indicates whether grants under this program are awarded through a competitive selection process or through formula allocation"
    - name: "cost_sharing_required"
      expr: cost_sharing_required
      comment: "Indicates whether cost sharing or matching funds are required for projects funded under this program"
    - name: "dbe_participation_required"
      expr: dbe_participation_required
      comment: "Indicates whether projects funded under this program must meet DBE participation goals or requirements"
    - name: "environmental_review_required"
      expr: environmental_review_required
      comment: "Indicates whether projects funded under this program must complete NEPA environmental review"
    - name: "federal_fiscal_year"
      expr: federal_fiscal_year
      comment: "Federal fiscal year designation for federal grant programs, running October 1 through September 30"
    - name: "state_fiscal_year"
      expr: state_fiscal_year
      comment: "North Carolina state fiscal year designation, running July 1 through June 30"
  measures:
    - name: "total_programs"
      expr: COUNT(1)
      comment: "Total number of grant programs for tracking portfolio size and program diversity"
    - name: "total_budget_authority"
      expr: SUM(CAST(budget_authority AS DOUBLE))
      comment: "Total budget authority allocated to grant programs for current fiscal year budget planning and appropriation tracking"
    - name: "total_program_funding"
      expr: SUM(CAST(total_program_funding AS DOUBLE))
      comment: "Total funding available under grant programs across all fiscal years for multi-year portfolio valuation"
    - name: "total_annual_allocation"
      expr: SUM(CAST(annual_allocation AS DOUBLE))
      comment: "Total annual funding allocation for grant programs in current fiscal year for budget execution tracking"
    - name: "avg_budget_authority"
      expr: AVG(CAST(budget_authority AS DOUBLE))
      comment: "Average budget authority per grant program for program sizing and benchmarking analysis"
    - name: "avg_match_requirement_percentage"
      expr: AVG(CAST(match_requirement_percentage AS DOUBLE))
      comment: "Average percentage of non-federal matching funds required across programs for cost-sharing policy analysis"
    - name: "avg_federal_share_percentage"
      expr: AVG(CAST(federal_share_percentage AS DOUBLE))
      comment: "Average maximum percentage of project costs that can be funded with federal dollars for funding policy analysis"
    - name: "avg_dbe_goal_percentage"
      expr: AVG(CAST(dbe_goal_percentage AS DOUBLE))
      comment: "Average target percentage of contract dollars to be awarded to DBE firms for equity policy benchmarking"
    - name: "avg_single_audit_threshold"
      expr: AVG(CAST(single_audit_threshold AS DOUBLE))
      comment: "Average dollar threshold triggering single audit requirements for compliance policy analysis"
    - name: "avg_indirect_cost_rate_percentage"
      expr: AVG(CAST(indirect_cost_rate_percentage AS DOUBLE))
      comment: "Average maximum allowable indirect cost rate across programs for overhead policy benchmarking"
    - name: "competitive_program_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN competitive_selection = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of programs using competitive selection process for portfolio composition and allocation strategy analysis"
    - name: "cost_sharing_required_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN cost_sharing_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of programs requiring cost sharing or matching funds for leveraging policy analysis"
    - name: "dbe_required_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN dbe_participation_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of programs requiring DBE participation for civil rights policy coverage analysis"
    - name: "environmental_review_required_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN environmental_review_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of programs requiring NEPA environmental review for environmental compliance burden analysis"
    - name: "active_program_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of programs currently active and accepting applications for portfolio health and opportunity availability"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`grant_applicant`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Grant applicant portfolio metrics tracking eligibility status, certification compliance, performance ratings, and active grant counts for subrecipient risk management and capacity assessment."
  source: "`feip_eastus_03`.`grant`.`applicant`"
  dimensions:
    - name: "applicant_type"
      expr: type
      comment: "Classification of the applicant organization type determining eligibility for specific grant programs (state agency, local government, MPO, RPO, transit agency, private entity)"
    - name: "organization_classification"
      expr: organization_classification
      comment: "High-level classification of the applicant organization as public, private, nonprofit, or for-profit entity"
    - name: "eligibility_status"
      expr: eligibility_status
      comment: "Current eligibility status of the applicant to receive federal and state grant funding (eligible, ineligible, suspended, conditional)"
    - name: "sam_registration_status"
      expr: sam_registration_status
      comment: "Current registration status in SAM.gov, required for federal grant eligibility and payment processing (active, expired, pending)"
    - name: "dbe_certification_status"
      expr: dbe_certification_status
      comment: "Certification status as a Disadvantaged Business Enterprise under USDOT DBE program (certified, not certified, pending, expired)"
    - name: "hub_certification_status"
      expr: hub_certification_status
      comment: "Certification status as a Historically Underutilized Business under North Carolina HUB program (certified, not certified, pending, expired)"
    - name: "debarment_status"
      expr: debarment_status
      comment: "Current debarment or suspension status in the federal Excluded Parties List System or SAM.gov (not debarred, debarred, suspended)"
    - name: "performance_rating"
      expr: performance_rating
      comment: "Overall performance rating based on past grant execution, compliance, and reporting quality (excellent, satisfactory, needs improvement, unsatisfactory)"
    - name: "audit_requirement_status"
      expr: audit_requirement_status
      comment: "Indicates whether the applicant is subject to Single Audit requirements under 2 CFR 200 Subpart F (required, not required, exempt)"
    - name: "compliance_issues_flag"
      expr: compliance_issues_flag
      comment: "Indicates whether the applicant has had compliance issues, audit findings, or corrective action plans on previous grants"
    - name: "county_name"
      expr: county_name
      comment: "North Carolina county where the applicant organization is physically located, relevant for regional grant programs"
    - name: "mpo_name"
      expr: mpo_name
      comment: "Name of the Metropolitan Planning Organization jurisdiction where the applicant is located, if applicable"
    - name: "rpo_name"
      expr: rpo_name
      comment: "Name of the Rural Planning Organization jurisdiction where the applicant is located, if applicable"
  measures:
    - name: "total_applicants"
      expr: COUNT(1)
      comment: "Total number of registered grant applicants for tracking subrecipient universe and program reach"
    - name: "total_active_grants"
      expr: SUM(CAST(active_grants_count AS DOUBLE))
      comment: "Total number of active grants across all applicants for portfolio workload and capacity assessment"
    - name: "total_grants_received_historically"
      expr: SUM(CAST(total_grants_received_count AS DOUBLE))
      comment: "Total number of grants received historically across all applicants for program participation and experience tracking"
    - name: "avg_active_grants_per_applicant"
      expr: AVG(CAST(active_grants_count AS DOUBLE))
      comment: "Average number of active grants per applicant for workload distribution and capacity benchmarking"
    - name: "avg_annual_operating_budget"
      expr: AVG(CAST(annual_operating_budget_amount AS DOUBLE))
      comment: "Average annual operating budget of applicant organizations for capacity assessment and risk profiling"
    - name: "avg_indirect_cost_rate_percentage"
      expr: AVG(CAST(indirect_cost_rate_percentage AS DOUBLE))
      comment: "Average approved indirect cost rate across applicants for overhead cost benchmarking"
    - name: "eligible_applicant_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN eligibility_status = 'Eligible' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applicants currently eligible to receive federal and state grant funding for program access and barrier analysis"
    - name: "sam_active_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN sam_registration_status = 'Active' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applicants with active SAM.gov registration, critical compliance metric for federal grant eligibility"
    - name: "dbe_certification_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN dbe_certification_status = 'Certified' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applicants certified as DBE firms for equity program participation and diversity tracking"
    - name: "hub_certification_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN hub_certification_status = 'Certified' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applicants certified as HUB firms for state equity program participation and diversity tracking"
    - name: "debarment_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN debarment_status IN ('Debarred', 'Suspended') THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applicants debarred or suspended, critical risk metric for eligibility screening and award decisions"
    - name: "compliance_issues_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN compliance_issues_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applicants with compliance issues or audit findings, key risk metric for subrecipient monitoring prioritization"
    - name: "audit_findings_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN audit_findings_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applicants with audit findings in most recent audit, critical risk indicator for financial management capacity"
    - name: "previous_recipient_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN previous_grant_recipient_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of applicants who have previously received grants for experience assessment and program familiarity"
$$;