-- Metric views for domain: hr | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`hr_employee_workforce`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core workforce metrics tracking headcount, tenure, compensation, and workforce composition for strategic HR planning and budget management."
  source: "`feip_eastus_03`.`hr`.`employee`"
  dimensions:
    - name: "employment_status"
      expr: employment_status
      comment: "Current employment status (active, terminated, on leave, retired) for workforce segmentation"
    - name: "employment_type"
      expr: employment_type
      comment: "Employment classification (full-time, part-time, temporary) for FTE analysis"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code (DOH, DMV, Ferry, Aviation) for organizational analysis"
    - name: "division_name"
      expr: division_name
      comment: "Full division name for reporting"
    - name: "job_title"
      expr: job_title
      comment: "Official job title for role-based analysis"
    - name: "exempt_status"
      expr: exempt_status
      comment: "FLSA exempt/non-exempt status for overtime eligibility analysis"
    - name: "work_location_county"
      expr: work_location_county
      comment: "County of work location for geographic workforce distribution"
    - name: "gender"
      expr: gender
      comment: "Self-identified gender for EEO reporting and diversity analytics"
    - name: "ethnicity"
      expr: ethnicity
      comment: "Ethnicity classification for EEO reporting"
    - name: "veteran_status"
      expr: veteran_status
      comment: "Military veteran status for veteran preference tracking"
    - name: "hire_year"
      expr: YEAR(hire_date)
      comment: "Year of hire for cohort analysis"
    - name: "salary_grade_id"
      expr: CAST(salary_grade_id AS STRING)
      comment: "Salary grade identifier for compensation structure analysis"
  measures:
    - name: "Total Headcount"
      expr: COUNT(1)
      comment: "Total number of employee records - primary workforce size metric"
    - name: "Total FTE"
      expr: SUM(CAST(fte_percentage AS DOUBLE)) / 100.0
      comment: "Total full-time equivalent workforce capacity for budget and resource planning"
    - name: "Average Tenure Years"
      expr: AVG(DATEDIFF(CURRENT_DATE(), hire_date) / 365.25)
      comment: "Average years of service for workforce stability and retention analysis"
    - name: "Total Annual Compensation"
      expr: SUM(CAST(annual_salary AS DOUBLE))
      comment: "Total annual salary expense for budget planning and cost management"
    - name: "Average Annual Salary"
      expr: AVG(CAST(annual_salary AS DOUBLE))
      comment: "Average annual salary for compensation benchmarking and equity analysis"
    - name: "Median Annual Salary"
      expr: PERCENTILE(CAST(annual_salary AS DOUBLE), 0.5)
      comment: "Median annual salary for compensation distribution analysis"
    - name: "Average Hourly Rate"
      expr: AVG(CAST(hourly_rate AS DOUBLE))
      comment: "Average hourly wage for non-exempt workforce cost analysis"
    - name: "Total Annual Leave Balance Hours"
      expr: SUM(CAST(leave_balance_annual AS DOUBLE))
      comment: "Total accrued annual leave liability for financial planning"
    - name: "Total Sick Leave Balance Hours"
      expr: SUM(CAST(leave_balance_sick AS DOUBLE))
      comment: "Total accrued sick leave liability for financial planning"
    - name: "Distinct Job Titles"
      expr: COUNT(DISTINCT job_title)
      comment: "Number of unique job titles for organizational complexity analysis"
    - name: "Distinct Work Locations"
      expr: COUNT(DISTINCT work_location_code)
      comment: "Number of unique work locations for geographic footprint analysis"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`hr_payroll_labor_cost`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Comprehensive labor cost and payroll metrics for financial management, budget variance analysis, and total compensation tracking."
  source: "`feip_eastus_03`.`hr`.`payroll`"
  dimensions:
    - name: "pay_date"
      expr: pay_date
      comment: "Payroll payment date for time-series analysis"
    - name: "pay_period_start_date"
      expr: pay_period_start_date
      comment: "Start of pay period for period-based analysis"
    - name: "fiscal_year"
      expr: CAST(fiscal_year AS STRING)
      comment: "State fiscal year for annual budget tracking"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code for organizational cost allocation"
    - name: "division_name"
      expr: division_name
      comment: "Division name for reporting"
    - name: "cost_center"
      expr: cost_center
      comment: "Financial cost center for budget tracking and expense allocation"
    - name: "employment_type"
      expr: employment_type
      comment: "Employment classification for labor cost segmentation"
    - name: "pay_frequency"
      expr: pay_frequency
      comment: "Pay frequency (biweekly, monthly) for payroll cycle analysis"
    - name: "transaction_type"
      expr: transaction_type
      comment: "Payroll transaction type (regular, supplemental, adjustment) for payment classification"
    - name: "work_location_county"
      expr: county_name
      comment: "County of work location for geographic cost distribution"
  measures:
    - name: "Total Payroll Transactions"
      expr: COUNT(1)
      comment: "Total number of payroll transactions processed"
    - name: "Total Gross Pay"
      expr: SUM(CAST(gross_pay AS DOUBLE))
      comment: "Total gross earnings before deductions - primary labor cost metric"
    - name: "Total Net Pay"
      expr: SUM(CAST(net_pay AS DOUBLE))
      comment: "Total take-home pay disbursed to employees"
    - name: "Total Regular Pay"
      expr: SUM(CAST(regular_pay AS DOUBLE))
      comment: "Total regular hours compensation for baseline labor cost"
    - name: "Total Overtime Pay"
      expr: SUM(CAST(overtime_pay AS DOUBLE))
      comment: "Total overtime compensation for premium labor cost tracking"
    - name: "Overtime Pay Percentage"
      expr: ROUND(100.0 * SUM(CAST(overtime_pay AS DOUBLE)) / NULLIF(SUM(CAST(gross_pay AS DOUBLE)), 0), 2)
      comment: "Overtime as percentage of gross pay for labor efficiency analysis"
    - name: "Total Employer Cost"
      expr: SUM(CAST(total_employer_cost AS DOUBLE))
      comment: "Total cost to employer including gross pay, taxes, and benefits - true labor cost metric"
    - name: "Employer Cost Per Employee"
      expr: AVG(CAST(total_employer_cost AS DOUBLE))
      comment: "Average total employer cost per payroll transaction for cost per FTE analysis"
    - name: "Total Regular Hours"
      expr: SUM(CAST(regular_hours AS DOUBLE))
      comment: "Total regular hours worked for productivity analysis"
    - name: "Total Overtime Hours"
      expr: SUM(CAST(overtime_hours AS DOUBLE))
      comment: "Total overtime hours worked for workload and staffing analysis"
    - name: "Overtime Hours Percentage"
      expr: ROUND(100.0 * SUM(CAST(overtime_hours AS DOUBLE)) / NULLIF(SUM(CAST(total_hours AS DOUBLE)), 0), 2)
      comment: "Overtime hours as percentage of total hours for workforce utilization analysis"
    - name: "Total Federal Tax Withheld"
      expr: SUM(CAST(federal_income_tax AS DOUBLE))
      comment: "Total federal income tax withheld for tax remittance tracking"
    - name: "Total State Tax Withheld"
      expr: SUM(CAST(state_income_tax AS DOUBLE))
      comment: "Total state income tax withheld for tax remittance tracking"
    - name: "Total Retirement Contributions"
      expr: SUM(CAST(retirement_contribution AS DOUBLE))
      comment: "Total employee retirement contributions for benefit plan funding"
    - name: "Total Employer Retirement Contributions"
      expr: SUM(CAST(employer_retirement_contribution AS DOUBLE))
      comment: "Total employer retirement contributions for benefit cost tracking"
    - name: "Total Health Insurance Premiums"
      expr: SUM(CAST(health_insurance_premium AS DOUBLE))
      comment: "Total employee health insurance premiums deducted"
    - name: "Total Employer Health Contributions"
      expr: SUM(CAST(employer_health_contribution AS DOUBLE))
      comment: "Total employer health insurance contributions for benefit cost tracking"
    - name: "Average Gross Pay Per Transaction"
      expr: AVG(CAST(gross_pay AS DOUBLE))
      comment: "Average gross pay per payroll transaction for compensation benchmarking"
    - name: "Distinct Employees Paid"
      expr: COUNT(DISTINCT CAST(employee_id AS STRING))
      comment: "Number of unique employees paid in period for active workforce tracking"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`hr_benefit_enrollment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Benefit enrollment and cost metrics for benefits administration, cost management, and employee participation analysis."
  source: "`feip_eastus_03`.`hr`.`benefit_enrollment`"
  dimensions:
    - name: "benefit_category"
      expr: benefit_category
      comment: "High-level benefit category (health, dental, retirement) for benefit type analysis"
    - name: "benefit_plan_name"
      expr: benefit_plan_name
      comment: "Specific benefit plan name for plan-level analysis"
    - name: "enrollment_status"
      expr: enrollment_status
      comment: "Current enrollment status (active, terminated, pending) for enrollment lifecycle tracking"
    - name: "coverage_level"
      expr: coverage_level
      comment: "Coverage level (employee only, family) for cost tier analysis"
    - name: "enrollment_period_type"
      expr: enrollment_period_type
      comment: "Enrollment period type (open enrollment, qualifying event) for enrollment pattern analysis"
    - name: "enrollment_year"
      expr: CAST(enrollment_period_year AS STRING)
      comment: "Enrollment period year for annual trend analysis"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code for organizational benefit participation analysis"
    - name: "carrier_name"
      expr: carrier_name
      comment: "Insurance carrier name for vendor performance analysis"
    - name: "enrollment_action"
      expr: enrollment_action
      comment: "Enrollment action type (new, change, termination) for transaction classification"
  measures:
    - name: "Total Enrollments"
      expr: COUNT(1)
      comment: "Total number of benefit enrollment transactions"
    - name: "Active Enrollments"
      expr: SUM(CASE WHEN enrollment_status = 'active coverage' THEN 1 ELSE 0 END)
      comment: "Number of active benefit enrollments for current participation tracking"
    - name: "Total Employee Premium Cost"
      expr: SUM(CAST(employee_premium_amount AS DOUBLE))
      comment: "Total employee premium contributions for employee cost burden analysis"
    - name: "Total Employer Premium Cost"
      expr: SUM(CAST(employer_premium_amount AS DOUBLE))
      comment: "Total employer premium contributions for benefit cost management"
    - name: "Total Premium Cost"
      expr: SUM(CAST(total_premium_amount AS DOUBLE))
      comment: "Total combined premium cost for comprehensive benefit expense tracking"
    - name: "Average Employee Premium"
      expr: AVG(CAST(employee_premium_amount AS DOUBLE))
      comment: "Average employee premium per enrollment for cost per participant analysis"
    - name: "Average Employer Premium"
      expr: AVG(CAST(employer_premium_amount AS DOUBLE))
      comment: "Average employer premium per enrollment for cost per participant analysis"
    - name: "Employer Premium Share Percentage"
      expr: ROUND(100.0 * SUM(CAST(employer_premium_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_premium_amount AS DOUBLE)), 0), 2)
      comment: "Employer share of total premium cost for cost-sharing analysis"
    - name: "Total Coverage Amount"
      expr: SUM(CAST(coverage_amount AS DOUBLE))
      comment: "Total benefit coverage amount for risk exposure analysis"
    - name: "Total Dependents Covered"
      expr: SUM(CAST(dependent_count AS STRING))
      comment: "Total number of dependents covered for family coverage analysis"
    - name: "Distinct Employees Enrolled"
      expr: COUNT(DISTINCT CAST(employee_id AS STRING))
      comment: "Number of unique employees with benefit enrollments for participation rate calculation"
    - name: "Waiver Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN enrollment_status = 'waived' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of enrollments waived for opt-out analysis"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`hr_recruitment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Recruitment effectiveness and time-to-fill metrics for talent acquisition performance, hiring velocity, and candidate pipeline management."
  source: "`feip_eastus_03`.`hr`.`job_opening`"
  dimensions:
    - name: "posting_status"
      expr: posting_status
      comment: "Job posting status (open, closed, filled) for recruitment lifecycle tracking"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code for organizational hiring analysis"
    - name: "division_name"
      expr: division_name
      comment: "Division name for reporting"
    - name: "work_county"
      expr: work_county
      comment: "County of work location for geographic hiring analysis"
    - name: "employment_type"
      expr: employment_type
      comment: "Employment type (permanent, temporary) for position classification"
    - name: "posting_type"
      expr: posting_type
      comment: "Posting type (internal, external, both) for candidate source analysis"
    - name: "priority_level"
      expr: priority_level
      comment: "Business priority level for critical hiring tracking"
    - name: "reason_for_opening"
      expr: reason_for_opening
      comment: "Reason for opening (resignation, retirement, new position) for turnover analysis"
    - name: "posting_year"
      expr: YEAR(posting_date)
      comment: "Year of posting for annual hiring trend analysis"
  measures:
    - name: "Total Job Openings"
      expr: COUNT(1)
      comment: "Total number of job opening requisitions"
    - name: "Total Open Positions"
      expr: SUM(CASE WHEN posting_status = 'open' THEN CAST(number_of_openings AS STRING) ELSE '0' END)
      comment: "Total number of open positions for current hiring demand tracking"
    - name: "Total Filled Positions"
      expr: SUM(CASE WHEN posting_status = 'filled' THEN CAST(number_of_openings AS STRING) ELSE '0' END)
      comment: "Total number of filled positions for hiring success tracking"
    - name: "Fill Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN posting_status = 'filled' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of job openings filled for recruitment effectiveness analysis"
    - name: "Average Days to Fill"
      expr: AVG(DATEDIFF(actual_fill_date, posting_date))
      comment: "Average days from posting to fill for hiring velocity analysis"
    - name: "Average Days to Offer"
      expr: AVG(DATEDIFF(offer_date, posting_date))
      comment: "Average days from posting to offer for recruitment cycle time analysis"
    - name: "Total Applicants"
      expr: SUM(CAST(total_applicants AS STRING))
      comment: "Total number of applicants for candidate pipeline volume analysis"
    - name: "Total Qualified Applicants"
      expr: SUM(CAST(qualified_applicants AS STRING))
      comment: "Total number of qualified applicants for candidate quality analysis"
    - name: "Qualification Rate"
      expr: ROUND(100.0 * SUM(CAST(qualified_applicants AS STRING)) / NULLIF(SUM(CAST(total_applicants AS STRING)), 0), 2)
      comment: "Percentage of applicants meeting minimum qualifications for sourcing quality analysis"
    - name: "Total Interviewed Applicants"
      expr: SUM(CAST(interviewed_applicants AS STRING))
      comment: "Total number of applicants interviewed for interview funnel analysis"
    - name: "Interview Rate"
      expr: ROUND(100.0 * SUM(CAST(interviewed_applicants AS STRING)) / NULLIF(SUM(CAST(qualified_applicants AS STRING)), 0), 2)
      comment: "Percentage of qualified applicants interviewed for screening effectiveness analysis"
    - name: "Average Applicants Per Opening"
      expr: AVG(CAST(total_applicants AS STRING))
      comment: "Average number of applicants per job opening for market competitiveness analysis"
    - name: "Distinct Hiring Managers"
      expr: COUNT(DISTINCT CAST(hiring_manager_employee_id AS STRING))
      comment: "Number of unique hiring managers for recruitment workload distribution"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`hr_training_effectiveness`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Training completion, compliance, and investment metrics for workforce development effectiveness and regulatory compliance tracking."
  source: "`feip_eastus_03`.`hr`.`training_record`"
  dimensions:
    - name: "completion_status"
      expr: completion_status
      comment: "Training completion status for completion tracking"
    - name: "assessment_result"
      expr: assessment_result
      comment: "Assessment pass/fail result for training effectiveness analysis"
    - name: "mandatory_flag"
      expr: CAST(mandatory_flag AS STRING)
      comment: "Mandatory training indicator for compliance tracking"
    - name: "compliance_requirement"
      expr: compliance_requirement
      comment: "Regulatory compliance requirement for compliance training analysis"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code for organizational training analysis"
    - name: "training_method"
      expr: training_method
      comment: "Training delivery method for delivery effectiveness analysis"
    - name: "training_provider"
      expr: training_provider
      comment: "Training provider for vendor performance analysis"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year for annual training investment tracking"
    - name: "completion_year"
      expr: YEAR(completion_date)
      comment: "Year of completion for annual trend analysis"
  measures:
    - name: "Total Training Records"
      expr: COUNT(1)
      comment: "Total number of training participation records"
    - name: "Total Completions"
      expr: SUM(CASE WHEN completion_status = 'completed' THEN 1 ELSE 0 END)
      comment: "Number of completed training courses for completion tracking"
    - name: "Completion Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN completion_status = 'completed' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of training courses completed for training effectiveness analysis"
    - name: "Total Training Hours"
      expr: SUM(CAST(actual_hours AS DOUBLE))
      comment: "Total training hours delivered for workforce development investment tracking"
    - name: "Average Training Hours Per Employee"
      expr: AVG(CAST(actual_hours AS DOUBLE))
      comment: "Average training hours per employee for development intensity analysis"
    - name: "Total Training Cost"
      expr: SUM(CAST(training_cost AS DOUBLE))
      comment: "Total training expenditure for budget management"
    - name: "Average Training Cost Per Employee"
      expr: AVG(CAST(training_cost AS DOUBLE))
      comment: "Average training cost per employee for cost per participant analysis"
    - name: "Total CEUs Earned"
      expr: SUM(CAST(continuing_education_units AS DOUBLE))
      comment: "Total continuing education units earned for professional development tracking"
    - name: "Average Assessment Score"
      expr: AVG(CAST(assessment_score AS DOUBLE))
      comment: "Average assessment score for training quality analysis"
    - name: "Pass Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN assessment_result = 'pass' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN assessment_result IN ('pass', 'fail') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of assessments passed for training effectiveness analysis"
    - name: "Mandatory Training Completion Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN mandatory_flag = true AND completion_status = 'completed' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN mandatory_flag = true THEN 1 ELSE 0 END), 0), 2)
      comment: "Completion rate for mandatory training for compliance risk analysis"
    - name: "Distinct Employees Trained"
      expr: COUNT(DISTINCT CAST(employee_id AS STRING))
      comment: "Number of unique employees receiving training for workforce development reach"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`hr_leave_management`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Leave utilization and approval metrics for workforce availability planning, leave balance management, and operational continuity."
  source: "`feip_eastus_03`.`hr`.`leave_request`"
  dimensions:
    - name: "leave_type_code"
      expr: leave_type_code
      comment: "Leave type code for leave category analysis"
    - name: "leave_type_description"
      expr: leave_type_description
      comment: "Leave type description for reporting"
    - name: "request_status"
      expr: request_status
      comment: "Leave request approval status for approval workflow tracking"
    - name: "organizational_unit"
      expr: organizational_unit
      comment: "Division or organizational unit for leave pattern analysis"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "State fiscal year for annual leave utilization tracking"
    - name: "is_paid"
      expr: CAST(is_paid AS STRING)
      comment: "Paid/unpaid leave indicator for cost impact analysis"
    - name: "request_month"
      expr: DATE_TRUNC('MONTH', submission_date)
      comment: "Month of request submission for seasonal pattern analysis"
  measures:
    - name: "Total Leave Requests"
      expr: COUNT(1)
      comment: "Total number of leave requests submitted"
    - name: "Approved Leave Requests"
      expr: SUM(CASE WHEN request_status = 'approved' THEN 1 ELSE 0 END)
      comment: "Number of approved leave requests for approval tracking"
    - name: "Approval Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN request_status = 'approved' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of leave requests approved for approval policy analysis"
    - name: "Total Leave Hours Requested"
      expr: SUM(CAST(total_hours_requested AS DOUBLE))
      comment: "Total leave hours requested for workforce availability impact analysis"
    - name: "Total Leave Days Requested"
      expr: SUM(CAST(total_days_requested AS DOUBLE))
      comment: "Total leave days requested for absence tracking"
    - name: "Average Leave Hours Per Request"
      expr: AVG(CAST(total_hours_requested AS DOUBLE))
      comment: "Average leave hours per request for leave pattern analysis"
    - name: "Average Days to Approval"
      expr: AVG(DATEDIFF(approval_date, submission_date))
      comment: "Average days from submission to approval for approval cycle time analysis"
    - name: "Total Holiday Hours Excluded"
      expr: SUM(CAST(holiday_hours_excluded AS DOUBLE))
      comment: "Total holiday hours excluded from leave deduction for leave balance accuracy"
    - name: "Distinct Employees Requesting Leave"
      expr: COUNT(DISTINCT CAST(employee_id AS STRING))
      comment: "Number of unique employees requesting leave for leave utilization breadth"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`hr_performance_review`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Performance evaluation and talent development metrics for performance management, promotion readiness, and compensation planning."
  source: "`feip_eastus_03`.`hr`.`performance_review`"
  dimensions:
    - name: "review_type"
      expr: review_type
      comment: "Performance review type (annual, probationary, mid-year) for review cycle analysis"
    - name: "review_status"
      expr: review_status
      comment: "Review workflow status for completion tracking"
    - name: "overall_rating_category"
      expr: overall_rating_category
      comment: "Overall performance rating category for performance distribution analysis"
    - name: "employee_division"
      expr: employee_division
      comment: "Employee division for organizational performance analysis"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year of review for annual performance tracking"
    - name: "probationary_status"
      expr: probationary_status
      comment: "Probationary status for new hire performance tracking"
    - name: "review_year"
      expr: YEAR(review_date)
      comment: "Year of review completion for annual trend analysis"
  measures:
    - name: "Total Performance Reviews"
      expr: COUNT(1)
      comment: "Total number of performance reviews conducted"
    - name: "Completed Reviews"
      expr: SUM(CASE WHEN review_status = 'completed' THEN 1 ELSE 0 END)
      comment: "Number of completed performance reviews for completion tracking"
    - name: "Completion Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN review_status = 'completed' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reviews completed for performance management compliance"
    - name: "Average Overall Rating Score"
      expr: AVG(CAST(overall_rating_score AS DOUBLE))
      comment: "Average overall performance rating score for workforce performance analysis"
    - name: "Average Job Knowledge Rating"
      expr: AVG(CAST(job_knowledge_rating AS DOUBLE))
      comment: "Average job knowledge rating for competency assessment"
    - name: "Average Quality of Work Rating"
      expr: AVG(CAST(quality_of_work_rating AS DOUBLE))
      comment: "Average quality of work rating for output quality analysis"
    - name: "Average Productivity Rating"
      expr: AVG(CAST(productivity_rating AS DOUBLE))
      comment: "Average productivity rating for efficiency analysis"
    - name: "Promotion Recommendation Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN promotion_recommendation_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reviews with promotion recommendations for talent pipeline analysis"
    - name: "Salary Increase Recommendation Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN salary_increase_recommendation_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reviews with salary increase recommendations for compensation planning"
    - name: "Average Recommended Salary Increase Percentage"
      expr: AVG(CAST(salary_increase_percentage AS DOUBLE))
      comment: "Average recommended salary increase percentage for merit budget planning"
    - name: "Total Recommended Salary Increase Amount"
      expr: SUM(CAST(salary_increase_amount AS DOUBLE))
      comment: "Total recommended salary increase amount for compensation budget impact"
    - name: "Performance Improvement Plan Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN performance_improvement_plan_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reviews resulting in performance improvement plans for underperformance tracking"
    - name: "Distinct Employees Reviewed"
      expr: COUNT(DISTINCT CAST(employee_id AS STRING))
      comment: "Number of unique employees reviewed for review coverage analysis"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`hr_time_labor_utilization`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Labor utilization and project time allocation metrics for project cost accounting, workforce productivity, and billable utilization analysis."
  source: "`feip_eastus_03`.`hr`.`time_entry`"
  dimensions:
    - name: "work_date"
      expr: work_date
      comment: "Date work was performed for daily time tracking"
    - name: "status"
      expr: status
      comment: "Time entry approval status for approval workflow tracking"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division code for organizational labor distribution"
    - name: "cost_center"
      expr: cost_center
      comment: "Cost center for financial labor allocation"
    - name: "activity_type"
      expr: activity_type
      comment: "Work activity classification for labor distribution analysis"
    - name: "leave_type"
      expr: leave_type
      comment: "Leave type for absence tracking"
    - name: "funding_source"
      expr: funding_source
      comment: "Funding source for grant compliance and cost allocation"
    - name: "is_billable"
      expr: CAST(is_billable AS STRING)
      comment: "Billable indicator for revenue realization analysis"
    - name: "work_month"
      expr: DATE_TRUNC('MONTH', work_date)
      comment: "Month of work for monthly labor trend analysis"
  measures:
    - name: "Total Time Entries"
      expr: COUNT(1)
      comment: "Total number of time entry records"
    - name: "Total Hours Worked"
      expr: SUM(CAST(hours_worked AS DOUBLE))
      comment: "Total hours worked for labor capacity analysis"
    - name: "Total Regular Hours"
      expr: SUM(CAST(regular_hours AS DOUBLE))
      comment: "Total regular hours for baseline labor tracking"
    - name: "Total Overtime Hours"
      expr: SUM(CAST(overtime_hours AS DOUBLE))
      comment: "Total overtime hours for premium labor cost tracking"
    - name: "Overtime Percentage"
      expr: ROUND(100.0 * SUM(CAST(overtime_hours AS DOUBLE)) / NULLIF(SUM(CAST(hours_worked AS DOUBLE)), 0), 2)
      comment: "Overtime as percentage of total hours for labor efficiency analysis"
    - name: "Total Leave Hours"
      expr: SUM(CAST(leave_hours AS DOUBLE))
      comment: "Total leave hours for absence impact analysis"
    - name: "Leave Hours Percentage"
      expr: ROUND(100.0 * SUM(CAST(leave_hours AS DOUBLE)) / NULLIF(SUM(CAST(hours_worked AS DOUBLE)) + SUM(CAST(leave_hours AS DOUBLE)), 0), 2)
      comment: "Leave hours as percentage of total time for workforce availability analysis"
    - name: "Total Labor Cost"
      expr: SUM(CAST(labor_cost AS DOUBLE))
      comment: "Total calculated labor cost for project cost accounting"
    - name: "Average Labor Cost Per Hour"
      expr: AVG(CAST(labor_cost AS DOUBLE) / NULLIF(CAST(hours_worked AS DOUBLE), 0))
      comment: "Average labor cost per hour for cost rate analysis"
    - name: "Total Billable Hours"
      expr: SUM(CASE WHEN is_billable = true THEN CAST(hours_worked AS DOUBLE) ELSE 0 END)
      comment: "Total billable hours for revenue realization tracking"
    - name: "Billable Utilization Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN is_billable = true THEN CAST(hours_worked AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(hours_worked AS DOUBLE)), 0), 2)
      comment: "Billable hours as percentage of total hours for utilization analysis"
    - name: "Distinct Employees Logging Time"
      expr: COUNT(DISTINCT CAST(employee_id AS STRING))
      comment: "Number of unique employees logging time for workforce engagement tracking"
$$;