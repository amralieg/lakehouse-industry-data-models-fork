-- Metric views for domain: procurement | Business:  | Version: 1 | Generated on: 2026-03-04 13:29:11

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`procurement_contract`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic contract performance metrics tracking contract value, execution efficiency, diversity participation, and financial performance across NCDOT procurement portfolio"
  source: "`feip_eastus_03`.`procurement`.`contract`"
  dimensions:
    - name: "contract_type"
      expr: type
      comment: "Classification of contract (construction, professional services, maintenance, etc.)"
    - name: "contract_status"
      expr: status
      comment: "Current lifecycle status (active, completed, terminated, etc.)"
    - name: "solicitation_method"
      expr: solicitation_method
      comment: "Procurement method used (IFB, RFP, RFQ)"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division responsible for contract"
    - name: "district_number"
      expr: CAST(district_number AS STRING)
      comment: "NCDOT highway district number (1-14)"
    - name: "county_code"
      expr: county_code
      comment: "North Carolina county where work is performed"
    - name: "federal_funding_flag"
      expr: CASE WHEN federal_funding_flag = true THEN 'Federally Funded' ELSE 'State Funded' END
      comment: "Whether contract is federally funded"
    - name: "award_year"
      expr: YEAR(award_date)
      comment: "Year contract was awarded"
    - name: "award_quarter"
      expr: CONCAT('Q', QUARTER(award_date), ' ', YEAR(award_date))
      comment: "Quarter and year contract was awarded"
    - name: "letting_year"
      expr: YEAR(letting_date)
      comment: "Year contract was let for bidding"
  measures:
    - name: "total_contract_count"
      expr: COUNT(1)
      comment: "Total number of contracts"
    - name: "total_original_value"
      expr: SUM(CAST(original_value AS DOUBLE))
      comment: "Sum of original contract values at award"
    - name: "total_current_value"
      expr: SUM(CAST(current_value AS DOUBLE))
      comment: "Sum of current contract values including amendments"
    - name: "total_paid_amount"
      expr: SUM(CAST(paid_to_date_amount AS DOUBLE))
      comment: "Total amount paid to contractors to date"
    - name: "total_remaining_balance"
      expr: SUM(CAST(remaining_balance AS DOUBLE))
      comment: "Total unpaid balance across all contracts"
    - name: "avg_contract_value"
      expr: AVG(CAST(current_value AS DOUBLE))
      comment: "Average current contract value"
    - name: "contract_growth_rate"
      expr: ROUND(100.0 * (SUM(CAST(current_value AS DOUBLE)) - SUM(CAST(original_value AS DOUBLE))) / NULLIF(SUM(CAST(original_value AS DOUBLE)), 0), 2)
      comment: "Percentage growth from original to current contract value due to amendments and change orders"
    - name: "payment_completion_rate"
      expr: ROUND(100.0 * SUM(CAST(paid_to_date_amount AS DOUBLE)) / NULLIF(SUM(CAST(current_value AS DOUBLE)), 0), 2)
      comment: "Percentage of current contract value that has been paid"
    - name: "avg_dbe_goal_percentage"
      expr: AVG(CAST(dbe_goal_percentage AS DOUBLE))
      comment: "Average DBE participation goal across contracts"
    - name: "avg_dbe_actual_percentage"
      expr: AVG(CAST(dbe_actual_percentage AS DOUBLE))
      comment: "Average actual DBE participation achieved"
    - name: "dbe_goal_attainment_rate"
      expr: ROUND(100.0 * AVG(CAST(dbe_actual_percentage AS DOUBLE)) / NULLIF(AVG(CAST(dbe_goal_percentage AS DOUBLE)), 0), 2)
      comment: "Percentage of DBE goal achieved on average across contracts"
    - name: "avg_completion_percentage"
      expr: AVG(CAST(percent_complete AS DOUBLE))
      comment: "Average completion percentage across active contracts"
    - name: "avg_change_orders_per_contract"
      expr: AVG(CAST(change_order_count AS DOUBLE))
      comment: "Average number of change orders per contract"
    - name: "total_retainage_held"
      expr: SUM(CAST(retainage_amount AS DOUBLE))
      comment: "Total dollar amount held in retainage across all contracts"
    - name: "avg_retainage_percentage"
      expr: AVG(CAST(retainage_percentage AS DOUBLE))
      comment: "Average retainage percentage withheld"
    - name: "federal_funding_percentage"
      expr: AVG(CAST(federal_funding_percentage AS DOUBLE))
      comment: "Average percentage of contract value funded by federal sources"
    - name: "contracts_with_disputes"
      expr: SUM(CASE WHEN dispute_flag = true THEN 1 ELSE 0 END)
      comment: "Number of contracts with active disputes"
    - name: "dispute_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN dispute_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of contracts with disputes"
    - name: "avg_time_extension_days"
      expr: AVG(CAST(time_extension_days AS DOUBLE))
      comment: "Average number of days contracts have been extended beyond original completion date"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`procurement_purchase_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Purchase order execution metrics tracking procurement volume, cycle time, vendor diversity, and compliance across NCDOT purchasing activities"
  source: "`feip_eastus_03`.`procurement`.`purchase_order`"
  dimensions:
    - name: "po_type"
      expr: po_type
      comment: "Classification of purchase order"
    - name: "po_status"
      expr: po_status
      comment: "Current lifecycle status of purchase order"
    - name: "purchasing_organization"
      expr: purchasing_organization
      comment: "Organizational unit responsible for procurement"
    - name: "division"
      expr: division
      comment: "NCDOT division responsible for purchase"
    - name: "county"
      expr: county
      comment: "County where work or delivery occurs"
    - name: "federal_funded"
      expr: CASE WHEN federal_funded = true THEN 'Federal' ELSE 'State' END
      comment: "Whether purchase order is federally funded"
    - name: "hub_certified"
      expr: CASE WHEN hub_certified = true THEN 'HUB Certified' ELSE 'Non-HUB' END
      comment: "Whether vendor is HUB certified"
    - name: "mbe_certified"
      expr: CASE WHEN mbe_certified = true THEN 'MBE Certified' ELSE 'Non-MBE' END
      comment: "Whether vendor is MBE certified"
    - name: "wbe_certified"
      expr: CASE WHEN wbe_certified = true THEN 'WBE Certified' ELSE 'Non-WBE' END
      comment: "Whether vendor is WBE certified"
    - name: "issue_year"
      expr: YEAR(issue_date)
      comment: "Year purchase order was issued"
    - name: "issue_quarter"
      expr: CONCAT('Q', QUARTER(issue_date), ' ', YEAR(issue_date))
      comment: "Quarter and year purchase order was issued"
    - name: "federal_fiscal_year"
      expr: federal_fiscal_year
      comment: "Federal fiscal year for budgeting"
    - name: "state_fiscal_year"
      expr: state_fiscal_year
      comment: "State fiscal year for budgeting"
  measures:
    - name: "total_po_count"
      expr: COUNT(1)
      comment: "Total number of purchase orders"
    - name: "total_po_value"
      expr: SUM(CAST(total_amount AS DOUBLE))
      comment: "Total value of all purchase orders before taxes"
    - name: "total_net_amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net payable amount after taxes and discounts"
    - name: "avg_po_value"
      expr: AVG(CAST(total_amount AS DOUBLE))
      comment: "Average purchase order value"
    - name: "total_tax_amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax amount across all purchase orders"
    - name: "total_freight_amount"
      expr: SUM(CAST(freight_amount AS DOUBLE))
      comment: "Total freight charges across all purchase orders"
    - name: "total_discount_amount"
      expr: SUM(CAST(discount_amount AS DOUBLE))
      comment: "Total discounts applied across all purchase orders"
    - name: "discount_capture_rate"
      expr: ROUND(100.0 * SUM(CAST(discount_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of purchase order value captured as discounts"
    - name: "avg_dbe_goal_percentage"
      expr: AVG(CAST(dbe_goal_percentage AS DOUBLE))
      comment: "Average DBE participation goal"
    - name: "avg_dbe_participation_percentage"
      expr: AVG(CAST(dbe_participation_percentage AS DOUBLE))
      comment: "Average actual DBE participation achieved"
    - name: "dbe_spend_attainment_rate"
      expr: ROUND(100.0 * AVG(CAST(dbe_participation_percentage AS DOUBLE)) / NULLIF(AVG(CAST(dbe_goal_percentage AS DOUBLE)), 0), 2)
      comment: "Percentage of DBE goal achieved on average"
    - name: "hub_spend_amount"
      expr: SUM(CASE WHEN hub_certified = true THEN CAST(total_amount AS DOUBLE) ELSE 0 END)
      comment: "Total spend with HUB certified vendors"
    - name: "hub_spend_percentage"
      expr: ROUND(100.0 * SUM(CASE WHEN hub_certified = true THEN CAST(total_amount AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(total_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of total spend with HUB certified vendors"
    - name: "mbe_spend_amount"
      expr: SUM(CASE WHEN mbe_certified = true THEN CAST(total_amount AS DOUBLE) ELSE 0 END)
      comment: "Total spend with MBE certified vendors"
    - name: "mbe_spend_percentage"
      expr: ROUND(100.0 * SUM(CASE WHEN mbe_certified = true THEN CAST(total_amount AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(total_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of total spend with MBE certified vendors"
    - name: "wbe_spend_amount"
      expr: SUM(CASE WHEN wbe_certified = true THEN CAST(total_amount AS DOUBLE) ELSE 0 END)
      comment: "Total spend with WBE certified vendors"
    - name: "wbe_spend_percentage"
      expr: ROUND(100.0 * SUM(CASE WHEN wbe_certified = true THEN CAST(total_amount AS DOUBLE) ELSE 0 END) / NULLIF(SUM(CAST(total_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of total spend with WBE certified vendors"
    - name: "avg_retention_percentage"
      expr: AVG(CAST(retention_percentage AS DOUBLE))
      comment: "Average retention percentage withheld"
    - name: "cancelled_po_count"
      expr: SUM(CASE WHEN po_status = 'Cancelled' THEN 1 ELSE 0 END)
      comment: "Number of cancelled purchase orders"
    - name: "cancellation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN po_status = 'Cancelled' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of purchase orders that were cancelled"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`procurement_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Invoice processing and payment performance metrics tracking payment velocity, dispute resolution, and accounts payable efficiency"
  source: "`feip_eastus_03`.`procurement`.`invoice`"
  dimensions:
    - name: "invoice_type"
      expr: type
      comment: "Classification of invoice"
    - name: "invoice_status"
      expr: status
      comment: "Current processing status"
    - name: "division_code"
      expr: division_code
      comment: "NCDOT division responsible"
    - name: "fiscal_year"
      expr: fiscal_year
      comment: "Fiscal year for budgeting"
    - name: "payment_method"
      expr: payment_method
      comment: "Method used to remit payment"
    - name: "three_way_match_status"
      expr: three_way_match_status
      comment: "Status of PO-GR-Invoice matching"
    - name: "dispute_flag"
      expr: CASE WHEN dispute_flag = true THEN 'Disputed' ELSE 'Not Disputed' END
      comment: "Whether invoice is under dispute"
    - name: "hold_flag"
      expr: CASE WHEN hold_flag = true THEN 'On Hold' ELSE 'Not On Hold' END
      comment: "Whether invoice is on hold"
    - name: "submission_year"
      expr: YEAR(submission_date)
      comment: "Year invoice was submitted"
    - name: "submission_quarter"
      expr: CONCAT('Q', QUARTER(submission_date), ' ', YEAR(submission_date))
      comment: "Quarter and year invoice was submitted"
    - name: "payment_year"
      expr: YEAR(payment_date)
      comment: "Year payment was issued"
  measures:
    - name: "total_invoice_count"
      expr: COUNT(1)
      comment: "Total number of invoices"
    - name: "total_invoice_value"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net payable amount across all invoices"
    - name: "total_paid_amount"
      expr: SUM(CAST(paid_amount AS DOUBLE))
      comment: "Total amount paid to date"
    - name: "total_outstanding_amount"
      expr: SUM(CAST(outstanding_amount AS DOUBLE))
      comment: "Total unpaid balance across all invoices"
    - name: "avg_invoice_value"
      expr: AVG(CAST(net_amount AS DOUBLE))
      comment: "Average invoice net amount"
    - name: "payment_completion_rate"
      expr: ROUND(100.0 * SUM(CAST(paid_amount AS DOUBLE)) / NULLIF(SUM(CAST(net_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of invoice value that has been paid"
    - name: "total_discount_captured"
      expr: SUM(CAST(discount_amount AS DOUBLE))
      comment: "Total discount amount applied to invoices"
    - name: "total_early_payment_discount"
      expr: SUM(CAST(early_payment_discount_taken AS DOUBLE))
      comment: "Total early payment discounts captured"
    - name: "early_payment_discount_rate"
      expr: ROUND(100.0 * SUM(CAST(early_payment_discount_taken AS DOUBLE)) / NULLIF(SUM(CAST(net_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of invoice value saved through early payment discounts"
    - name: "total_late_payment_penalty"
      expr: SUM(CAST(late_payment_penalty_amount AS DOUBLE))
      comment: "Total penalties assessed for late payments"
    - name: "late_payment_penalty_rate"
      expr: ROUND(100.0 * SUM(CAST(late_payment_penalty_amount AS DOUBLE)) / NULLIF(SUM(CAST(net_amount AS DOUBLE)), 0), 2)
      comment: "Percentage of invoice value incurred as late payment penalties"
    - name: "total_retainage_withheld"
      expr: SUM(CAST(retainage_amount AS DOUBLE))
      comment: "Total retainage amount withheld from payments"
    - name: "avg_retainage_percentage"
      expr: AVG(CAST(retainage_percentage AS DOUBLE))
      comment: "Average retainage percentage withheld"
    - name: "disputed_invoice_count"
      expr: SUM(CASE WHEN dispute_flag = true THEN 1 ELSE 0 END)
      comment: "Number of invoices under dispute"
    - name: "dispute_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN dispute_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of invoices that are disputed"
    - name: "disputed_invoice_value"
      expr: SUM(CASE WHEN dispute_flag = true THEN CAST(net_amount AS DOUBLE) ELSE 0 END)
      comment: "Total value of invoices under dispute"
    - name: "hold_invoice_count"
      expr: SUM(CASE WHEN hold_flag = true THEN 1 ELSE 0 END)
      comment: "Number of invoices on hold"
    - name: "hold_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN hold_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of invoices on hold"
    - name: "three_way_match_success_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN three_way_match_status = 'Matched' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of invoices that successfully matched PO and goods receipt"
    - name: "total_dbe_participation_amount"
      expr: SUM(CAST(dbe_participation_amount AS DOUBLE))
      comment: "Total invoice value attributable to DBE subcontractors"
    - name: "avg_dbe_participation_percentage"
      expr: AVG(CAST(dbe_participation_percentage AS DOUBLE))
      comment: "Average DBE participation percentage across invoices"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`procurement_vendor_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Vendor performance evaluation metrics tracking quality, delivery, compliance, safety, and cost performance to inform vendor selection and contract management decisions"
  source: "`feip_eastus_03`.`procurement`.`vendor_performance`"
  dimensions:
    - name: "assessment_type"
      expr: assessment_type
      comment: "Type or frequency of performance assessment"
    - name: "overall_performance_rating"
      expr: overall_performance_rating
      comment: "Categorical overall performance rating"
    - name: "quality_rating"
      expr: quality_rating
      comment: "Categorical quality performance rating"
    - name: "delivery_rating"
      expr: delivery_rating
      comment: "Categorical delivery performance rating"
    - name: "compliance_rating"
      expr: compliance_rating
      comment: "Categorical compliance performance rating"
    - name: "safety_rating"
      expr: safety_rating
      comment: "Categorical safety performance rating"
    - name: "assessment_fiscal_year"
      expr: assessment_fiscal_year
      comment: "Fiscal year of assessment"
    - name: "assessment_year"
      expr: YEAR(assessment_date)
      comment: "Year assessment was conducted"
    - name: "assessment_quarter"
      expr: CONCAT('Q', QUARTER(assessment_date), ' ', YEAR(assessment_date))
      comment: "Quarter and year assessment was conducted"
    - name: "corrective_actions_required"
      expr: CASE WHEN corrective_actions_required = true THEN 'Required' ELSE 'Not Required' END
      comment: "Whether corrective actions are required"
    - name: "performance_trend"
      expr: performance_trend
      comment: "Trend in vendor performance compared to previous assessments"
  measures:
    - name: "total_assessment_count"
      expr: COUNT(1)
      comment: "Total number of vendor performance assessments"
    - name: "unique_vendor_count"
      expr: COUNT(DISTINCT vendor_id)
      comment: "Number of unique vendors assessed"
    - name: "avg_overall_performance_score"
      expr: AVG(CAST(overall_performance_score AS DOUBLE))
      comment: "Average overall performance score across all assessments"
    - name: "avg_quality_score"
      expr: AVG(CAST(quality_score AS DOUBLE))
      comment: "Average quality performance score"
    - name: "avg_delivery_score"
      expr: AVG(CAST(delivery_score AS DOUBLE))
      comment: "Average delivery performance score"
    - name: "avg_compliance_score"
      expr: AVG(CAST(compliance_score AS DOUBLE))
      comment: "Average compliance performance score"
    - name: "avg_safety_score"
      expr: AVG(CAST(safety_score AS DOUBLE))
      comment: "Average safety performance score"
    - name: "avg_cost_performance_score"
      expr: AVG(CAST(cost_performance_score AS DOUBLE))
      comment: "Average cost performance score"
    - name: "avg_responsiveness_score"
      expr: AVG(CAST(responsiveness_score AS DOUBLE))
      comment: "Average responsiveness score"
    - name: "avg_on_time_delivery_percentage"
      expr: AVG(CAST(on_time_delivery_percentage AS DOUBLE))
      comment: "Average percentage of deliveries completed on time"
    - name: "total_quality_incidents"
      expr: SUM(CAST(quality_incidents_count AS DOUBLE))
      comment: "Total number of quality incidents reported"
    - name: "total_compliance_violations"
      expr: SUM(CAST(compliance_violations_count AS DOUBLE))
      comment: "Total number of compliance violations identified"
    - name: "total_safety_incidents"
      expr: SUM(CAST(safety_incidents_count AS DOUBLE))
      comment: "Total number of safety incidents reported"
    - name: "avg_budget_variance_percentage"
      expr: AVG(CAST(budget_variance_percentage AS DOUBLE))
      comment: "Average budget variance percentage across assessments"
    - name: "avg_dbe_participation_score"
      expr: AVG(CAST(dbe_participation_score AS DOUBLE))
      comment: "Average DBE participation performance score"
    - name: "avg_dbe_commitment_percentage"
      expr: AVG(CAST(dbe_commitment_percentage AS DOUBLE))
      comment: "Average DBE commitment percentage"
    - name: "avg_dbe_actual_percentage"
      expr: AVG(CAST(dbe_actual_percentage AS DOUBLE))
      comment: "Average actual DBE participation achieved"
    - name: "dbe_commitment_attainment_rate"
      expr: ROUND(100.0 * AVG(CAST(dbe_actual_percentage AS DOUBLE)) / NULLIF(AVG(CAST(dbe_commitment_percentage AS DOUBLE)), 0), 2)
      comment: "Percentage of DBE commitment achieved on average"
    - name: "corrective_actions_required_count"
      expr: SUM(CASE WHEN corrective_actions_required = true THEN 1 ELSE 0 END)
      comment: "Number of assessments requiring corrective actions"
    - name: "corrective_action_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN corrective_actions_required = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments requiring corrective actions"
    - name: "total_corrective_actions"
      expr: SUM(CAST(corrective_actions_count AS DOUBLE))
      comment: "Total number of corrective actions identified"
    - name: "dispute_filed_count"
      expr: SUM(CASE WHEN dispute_filed = true THEN 1 ELSE 0 END)
      comment: "Number of assessments where vendor filed a dispute"
    - name: "dispute_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN dispute_filed = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments disputed by vendors"
    - name: "total_contract_value_assessed"
      expr: SUM(CAST(contract_value AS DOUBLE))
      comment: "Total contract value under assessment"
    - name: "avg_contract_value_assessed"
      expr: AVG(CAST(contract_value AS DOUBLE))
      comment: "Average contract value per assessment"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`procurement_purchase_requisition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Purchase requisition workflow efficiency metrics tracking approval cycle time, rejection rates, and procurement planning effectiveness"
  source: "`feip_eastus_03`.`procurement`.`purchase_requisition`"
  dimensions:
    - name: "requisition_type"
      expr: requisition_type
      comment: "Classification of purchase requisition"
    - name: "requisition_status"
      expr: status
      comment: "Current workflow status"
    - name: "approval_status"
      expr: approval_status
      comment: "Specific approval status"
    - name: "priority"
      expr: priority
      comment: "Priority level assigned"
    - name: "budget_year"
      expr: budget_year
      comment: "Fiscal year for budget allocation"
    - name: "budget_source"
      expr: budget_source
      comment: "Primary funding source"
    - name: "solicitation_type"
      expr: solicitation_type
      comment: "Type of solicitation to be issued"
    - name: "contract_type"
      expr: contract_type
      comment: "Type of contract to be established"
    - name: "small_purchase_flag"
      expr: CASE WHEN small_purchase_flag = true THEN 'Small Purchase' ELSE 'Standard Purchase' END
      comment: "Whether requisition qualifies as small purchase"
    - name: "emergency_procurement_flag"
      expr: CASE WHEN emergency_procurement_flag = true THEN 'Emergency' ELSE 'Standard' END
      comment: "Whether requisition is for emergency procurement"
    - name: "sole_source_flag"
      expr: CASE WHEN sole_source_flag = true THEN 'Sole Source' ELSE 'Competitive' END
      comment: "Whether requisition is for sole source procurement"
    - name: "requisition_year"
      expr: YEAR(requisition_date)
      comment: "Year requisition was created"
    - name: "requisition_quarter"
      expr: CONCAT('Q', QUARTER(requisition_date), ' ', YEAR(requisition_date))
      comment: "Quarter and year requisition was created"
  measures:
    - name: "total_requisition_count"
      expr: COUNT(1)
      comment: "Total number of purchase requisitions"
    - name: "total_requisition_value"
      expr: SUM(CAST(total_amount AS DOUBLE))
      comment: "Total estimated value of all requisitions"
    - name: "avg_requisition_value"
      expr: AVG(CAST(total_amount AS DOUBLE))
      comment: "Average requisition value"
    - name: "approved_requisition_count"
      expr: SUM(CASE WHEN approval_status = 'Approved' THEN 1 ELSE 0 END)
      comment: "Number of approved requisitions"
    - name: "approval_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN approval_status = 'Approved' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requisitions approved"
    - name: "rejected_requisition_count"
      expr: SUM(CASE WHEN approval_status = 'Rejected' THEN 1 ELSE 0 END)
      comment: "Number of rejected requisitions"
    - name: "rejection_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN approval_status = 'Rejected' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requisitions rejected"
    - name: "cancelled_requisition_count"
      expr: SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END)
      comment: "Number of cancelled requisitions"
    - name: "cancellation_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requisitions cancelled"
    - name: "avg_estimated_contract_value"
      expr: AVG(CAST(estimated_contract_value AS DOUBLE))
      comment: "Average estimated contract value"
    - name: "avg_dbe_goal_percentage"
      expr: AVG(CAST(dbe_goal_percentage AS DOUBLE))
      comment: "Average DBE participation goal"
    - name: "emergency_procurement_count"
      expr: SUM(CASE WHEN emergency_procurement_flag = true THEN 1 ELSE 0 END)
      comment: "Number of emergency procurement requisitions"
    - name: "emergency_procurement_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN emergency_procurement_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requisitions for emergency procurement"
    - name: "sole_source_count"
      expr: SUM(CASE WHEN sole_source_flag = true THEN 1 ELSE 0 END)
      comment: "Number of sole source requisitions"
    - name: "sole_source_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN sole_source_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requisitions for sole source procurement"
    - name: "small_purchase_count"
      expr: SUM(CASE WHEN small_purchase_flag = true THEN 1 ELSE 0 END)
      comment: "Number of small purchase requisitions"
    - name: "small_purchase_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN small_purchase_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requisitions qualifying as small purchases"
    - name: "federal_aid_requisition_count"
      expr: SUM(CASE WHEN federal_aid_flag = true THEN 1 ELSE 0 END)
      comment: "Number of requisitions involving federal funding"
    - name: "federal_aid_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN federal_aid_flag = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of requisitions involving federal funding"
$$;

CREATE OR REPLACE VIEW `feip_eastus_03`.`_metrics`.`procurement_vendor`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Vendor portfolio metrics tracking vendor diversity, certification status, financial capacity, and vendor base health to inform strategic sourcing decisions"
  source: "`feip_eastus_03`.`procurement`.`vendor`"
  dimensions:
    - name: "vendor_type"
      expr: type
      comment: "Legal structure classification of vendor"
    - name: "vendor_status"
      expr: status
      comment: "Current operational status in procurement system"
    - name: "dbe_certified"
      expr: CASE WHEN dbe_certified = true THEN 'DBE Certified' ELSE 'Non-DBE' END
      comment: "Whether vendor is DBE certified"
    - name: "mbe_certified"
      expr: CASE WHEN mbe_certified = true THEN 'MBE Certified' ELSE 'Non-MBE' END
      comment: "Whether vendor is MBE certified"
    - name: "wbe_certified"
      expr: CASE WHEN wbe_certified = true THEN 'WBE Certified' ELSE 'Non-WBE' END
      comment: "Whether vendor is WBE certified"
    - name: "hub_certified"
      expr: CASE WHEN hub_certified = true THEN 'HUB Certified' ELSE 'Non-HUB' END
      comment: "Whether vendor is HUB certified"
    - name: "small_business_certified"
      expr: CASE WHEN small_business_certified = true THEN 'Small Business' ELSE 'Large Business' END
      comment: "Whether vendor is certified as small business"
    - name: "veteran_owned"
      expr: CASE WHEN veteran_owned = true THEN 'Veteran Owned' ELSE 'Non-Veteran' END
      comment: "Whether vendor is veteran-owned"
    - name: "sam_registration_status"
      expr: sam_registration_status
      comment: "Federal SAM registration status"
    - name: "debarment_status"
      expr: debarment_status
      comment: "Federal or state debarment status"
    - name: "prequalification_status"
      expr: prequalification_status
      comment: "Vendor prequalification status"
    - name: "performance_rating"
      expr: performance_rating
      comment: "Overall performance rating"
    - name: "incorporation_state"
      expr: incorporation_state
      comment: "State where vendor is incorporated"
    - name: "physical_state"
      expr: physical_state
      comment: "State of vendor physical location"
  measures:
    - name: "total_vendor_count"
      expr: COUNT(1)
      comment: "Total number of vendors in system"
    - name: "active_vendor_count"
      expr: SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END)
      comment: "Number of active vendors"
    - name: "dbe_certified_count"
      expr: SUM(CASE WHEN dbe_certified = true THEN 1 ELSE 0 END)
      comment: "Number of DBE certified vendors"
    - name: "dbe_certification_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN dbe_certified = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors that are DBE certified"
    - name: "mbe_certified_count"
      expr: SUM(CASE WHEN mbe_certified = true THEN 1 ELSE 0 END)
      comment: "Number of MBE certified vendors"
    - name: "mbe_certification_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN mbe_certified = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors that are MBE certified"
    - name: "wbe_certified_count"
      expr: SUM(CASE WHEN wbe_certified = true THEN 1 ELSE 0 END)
      comment: "Number of WBE certified vendors"
    - name: "wbe_certification_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN wbe_certified = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors that are WBE certified"
    - name: "hub_certified_count"
      expr: SUM(CASE WHEN hub_certified = true THEN 1 ELSE 0 END)
      comment: "Number of HUB certified vendors"
    - name: "hub_certification_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN hub_certified = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors that are HUB certified"
    - name: "small_business_count"
      expr: SUM(CASE WHEN small_business_certified = true THEN 1 ELSE 0 END)
      comment: "Number of small business certified vendors"
    - name: "small_business_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN small_business_certified = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors that are small businesses"
    - name: "veteran_owned_count"
      expr: SUM(CASE WHEN veteran_owned = true THEN 1 ELSE 0 END)
      comment: "Number of veteran-owned vendors"
    - name: "veteran_owned_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN veteran_owned = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors that are veteran-owned"
    - name: "prequalified_vendor_count"
      expr: SUM(CASE WHEN prequalification_status = 'Prequalified' THEN 1 ELSE 0 END)
      comment: "Number of prequalified vendors"
    - name: "prequalification_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN prequalification_status = 'Prequalified' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors that are prequalified"
    - name: "debarred_vendor_count"
      expr: SUM(CASE WHEN debarment_status = 'Debarred' THEN 1 ELSE 0 END)
      comment: "Number of debarred vendors"
    - name: "debarment_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN debarment_status = 'Debarred' THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors that are debarred"
    - name: "avg_annual_revenue"
      expr: AVG(CAST(annual_revenue AS DOUBLE))
      comment: "Average annual revenue of vendors"
    - name: "total_vendor_capacity"
      expr: SUM(CAST(annual_revenue AS DOUBLE))
      comment: "Total annual revenue capacity across vendor base"
    - name: "avg_number_of_employees"
      expr: AVG(CAST(number_of_employees AS DOUBLE))
      comment: "Average number of employees per vendor"
    - name: "avg_years_in_business"
      expr: AVG(CAST(years_in_business AS DOUBLE))
      comment: "Average years vendors have been in business"
    - name: "avg_minority_owned_percentage"
      expr: AVG(CAST(minority_owned_percentage AS DOUBLE))
      comment: "Average minority ownership percentage across vendors"
    - name: "avg_women_owned_percentage"
      expr: AVG(CAST(women_owned_percentage AS DOUBLE))
      comment: "Average women ownership percentage across vendors"
    - name: "total_active_contract_value"
      expr: SUM(CAST(total_contract_value AS DOUBLE))
      comment: "Total value of active contracts across all vendors"
    - name: "avg_contract_value_per_vendor"
      expr: AVG(CAST(total_contract_value AS DOUBLE))
      comment: "Average active contract value per vendor"
    - name: "payment_blocked_vendor_count"
      expr: SUM(CASE WHEN payment_block_indicator = true THEN 1 ELSE 0 END)
      comment: "Number of vendors with payment blocks"
    - name: "payment_block_rate"
      expr: ROUND(100.0 * SUM(CASE WHEN payment_block_indicator = true THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of vendors with payment blocks"
$$;