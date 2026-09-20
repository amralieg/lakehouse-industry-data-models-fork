-- Schema for Domain: billing | Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:50

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`billing` COMMENT 'Manages invoicing, collections, disbursements, delinquency, and installment plan processing for policyholders and payees. Owns billing accounts, invoices, payment transactions, payment plans, returned payments, and write-offs.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` (
    `installment_plan_id` BIGINT COMMENT 'Unique identifier for the installment plan. Primary key.',
    `billing_account_id` BIGINT COMMENT 'Foreign key linking to billing.account. Business justification: Installment plan is executed against a billing account. The installment_plan table tracks the elected payment schedule for a policy term, and that schedule is managed within the context of a',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Installment plans span accounting periods. FK enables period-based billing analysis, fiscal year receivables reporting, and ensures plans align with calendar dimensions for financial',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Installment plan amounts denominated in currency. FK enables multi-currency billing, FX conversion for consolidated receivables reporting, and ensures plan amounts reference valid active',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Payment plans vary by line of business. FK enables LOB-specific billing analysis, payment plan management by line, and ensures plans reference valid LOBs for receivables reporting.',
    `payment_id` BIGINT COMMENT 'Unique transaction identifier from the source billing system for this installment plan.',
    `payment_plan_id` BIGINT COMMENT 'Foreign key linking to billing.payment_plan. Business justification: Installment plan is an instance of a payment plan template. The payment_plan table defines the master template (number of installments, down payment rules, fees, etc.), and',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this installment plan was established.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term covered by this installment plan.',
    `policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction that triggered or modified this installment plan.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent who sold the policy and established the installment plan.',
    `amount_outstanding` DECIMAL(18,2) COMMENT 'Remaining unpaid balance on the installment plan, including overdue amounts.',
    `amount_paid_to_date` DECIMAL(18,2) COMMENT 'Cumulative amount paid by the policyholder against this installment plan to date.',
    `auto_pay_flag` BOOLEAN COMMENT 'Indicates whether automatic payment is enabled for this installment plan.',
    `billing_method` STRING COMMENT 'Method by which installments are billed: direct bill, agency bill, list bill, or account current.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `cancellation_effective_date` DATE COMMENT 'Date on which the policy will be cancelled if outstanding installments are not paid.',
    `cancellation_notice_date` DATE COMMENT 'Date on which a notice of cancellation for non-payment was issued to the policyholder.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this installment plan record was first created in the system.',
    `days_delinquent` BIGINT COMMENT 'Number of days the installment plan has been in delinquent status.',
    `delinquency_date` DATE COMMENT 'Date on which the installment plan first became delinquent.',
    `down_payment_amount` DECIMAL(18,2) COMMENT 'Initial down payment amount required at policy binding before installment schedule begins.',
    `down_payment_date` DATE COMMENT 'Date on which the down payment was received or is due.',
    `effective_date` DATE COMMENT 'Date on which the installment plan becomes effective and binding.',
    `expiration_date` DATE COMMENT 'Date on which the installment plan expires or is scheduled to be completed.',
    `final_installment_due_date` DATE COMMENT 'Due date for the last scheduled installment payment under this plan.',
    `first_installment_due_date` DATE COMMENT 'Due date for the first scheduled installment payment after the down payment.',
    `grace_period_days` BIGINT COMMENT 'Number of days after the due date during which payment may be made without penalty or cancellation.',
    `installment_fee_per_payment` DECIMAL(18,2) COMMENT 'Fee charged per installment payment to cover administrative costs of the payment plan.',
    `installments_outstanding` BIGINT COMMENT 'Count of installments that remain unpaid or partially paid.',
    `installments_paid` BIGINT COMMENT 'Count of installments that have been fully paid to date.',
    `is_delinquent` BOOLEAN COMMENT 'Indicates whether the installment plan is currently delinquent due to missed or late payments.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this installment plan record was last updated or modified.',
    `late_fee_amount` DECIMAL(18,2) COMMENT 'Standard late fee charged per installment when payment is received after the grace period.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding special arrangements, waivers, or exceptions for this installment plan.',
    `number_of_installments` BIGINT COMMENT 'Total count of installment payments scheduled under this plan for the policy term.',
    `payment_method` STRING COMMENT 'Primary payment method elected for installment payments: EFT, credit card, check, cash, payroll deduction, or escrow.. Valid values are `eft|credit_card|check|cash|payroll_deduction|escrow`',
    `plan_status` STRING COMMENT 'Current lifecycle status of the installment plan: active, completed, cancelled, suspended, or defaulted.. Valid values are `active|completed|cancelled|suspended|defaulted`',
    `reinstatement_date` DATE COMMENT 'Date on which a previously cancelled or suspended installment plan was reinstated.',
    `reinstatement_fee_amount` DECIMAL(18,2) COMMENT 'Fee charged to reinstate a cancelled or suspended installment plan.',
    `source_system_code` STRING COMMENT 'Code identifying the billing or policy administration system that created this installment plan record.',
    `total_fees_amount` DECIMAL(18,2) COMMENT 'Total installment fees charged across all scheduled payments under this plan.',
    `total_plan_amount` DECIMAL(18,2) COMMENT 'Total amount due under the installment plan, including premium and all fees.',
    `total_premium_amount` DECIMAL(18,2) COMMENT 'Total premium amount to be collected across all installments under this plan.',
    CONSTRAINT pk_installment_plan PRIMARY KEY(`installment_plan_id`)
) COMMENT 'Installment schedule elected for a Policy Term with per-installment lines: number, due dates, billed/paid amounts, fees, and status. Feeds delinquency and cancellation-for-non-payment.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` (
    `account_id` BIGINT COMMENT 'Unique identifier for the billing account. Primary key.',
    `billing_address_id` BIGINT COMMENT 'Foreign key linking to party.address. Business justification: Billing accounts require validated billing address distinct from policyholder address for invoice delivery, collections correspondence, and regulatory cancellation notices.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Billing account next_invoice_date and effective_date must align to fiscal/accounting periods for period-close AR aging, NAIC premium receivable reporting, and billing cycle management.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Billing accounts maintain balances in specific currencies and require currency master data for balance calculations, aging reports, and multi-currency consolidation.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Account billing geography determines tax jurisdiction codes, payment plan regulatory eligibility, escheatment rules, and state-specific billing regulations.',
    `household_id` BIGINT COMMENT 'Foreign key linking to party.household. Business justification: Personal lines billing accounts are consolidated at the household level for multi-policy statements, household-level payment plans, and multi-policy discount eligibility.',
    `party_id` BIGINT COMMENT 'Reference to the party (policyholder or payee) who owns this billing account.',
    `policy_id` BIGINT COMMENT 'Reference to the policy associated with this billing account.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent responsible for this account, used for commission allocation and servicing.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to coverage.submission. Business justification: Billing accounts are often established during underwriting for quoted business to prepare payment collection infrastructure before binding.',
    `account_status` STRING COMMENT 'Current lifecycle status of the billing account indicating whether it is active, suspended, closed, delinquent, pending activation, or cancelled.. Valid values are `active|suspended|closed|delinquent|pending|cancelled`',
    `account_type` STRING COMMENT 'Classification of billing account indicating who collects premium: direct bill (insurer bills policyholder), agency bill (producer collects), list bill, or account current.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `auto_pay_enabled` BOOLEAN COMMENT 'Indicates whether automatic payment processing is enabled for this account. True means payments are automatically withdrawn on due date.',
    `billing_contact_name` STRING COMMENT 'Name of the person or entity designated to receive billing communications and invoices for this account.',
    `billing_email` STRING COMMENT 'Email address for delivery of electronic invoices, payment confirmations, and billing notices.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `billing_frequency` STRING COMMENT 'Frequency at which invoices are generated for this account: monthly, quarterly, semi-annual, annual, or on-demand.. Valid values are `monthly|quarterly|semi_annual|annual|on_demand`',
    `billing_method` STRING COMMENT 'Method by which the policyholder is billed: invoice, automatic payment, payroll deduction, escrow, or mortgagee bill.. Valid values are `invoice|automatic_payment|payroll_deduction|escrow|mortgagee_bill`',
    `billing_phone` STRING COMMENT 'Primary phone number for billing inquiries, payment reminders, and delinquency notifications.',
    `cancellation_date` DATE COMMENT 'Date the billing account was cancelled, either due to policy cancellation, non-payment, or policyholder request.',
    `cancellation_reason` STRING COMMENT 'Business reason for account cancellation: non-payment, policy cancellation, policyholder request, fraud, or other. [ENUM-REF-CANDIDATE: non_payment|policy_cancelled|policyholder_request|fraud|underwriting|rewrite|duplicate|other — promote to reference',
    `commission_payable_flag` BOOLEAN COMMENT 'Indicates whether producer commission is payable on premium collected through this account. False for direct accounts with no producer involvement.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time this billing account record was first created in the system.',
    `credit_balance` DECIMAL(18,2) COMMENT 'Total credit amount available on the account from overpayments, return premiums, or cancellations. Positive value indicates credit owed to policyholder.',
    `current_balance` DECIMAL(18,2) COMMENT 'Current outstanding balance on the account, representing total amount owed by the policyholder. Positive indicates amount due; negative indicates credit.',
    `days_past_due` BIGINT COMMENT 'Number of days the oldest unpaid invoice on this account is overdue. Zero indicates account is current.',
    `delinquency_status` STRING COMMENT 'Classification of account delinquency based on days past due: current, 1-30 days, 31-60 days, 61-90 days, over 90 days, or in collections.. Valid values are `current|past_due_1_30|past_due_31_60|past_due_61_90|past_due_over_90|in_collections`',
    `effective_date` DATE COMMENT 'Date the billing account became active and began accepting charges and payments.',
    `expiration_date` DATE COMMENT 'Date the billing account is scheduled to close or expire, typically aligned with policy expiration or account closure.',
    `grace_period_days` BIGINT COMMENT 'Number of days after payment due date before policy cancellation for non-payment is initiated, as required by state regulation.',
    `last_payment_amount` DECIMAL(18,2) COMMENT 'Monetary amount of the most recent payment received on this account.',
    `last_payment_date` DATE COMMENT 'Date the most recent payment was received and posted to this account.',
    `next_invoice_date` DATE COMMENT 'Scheduled date for the next invoice to be generated for this account based on billing frequency and payment plan.',
    `next_payment_due_date` DATE COMMENT 'Date by which the next payment is due to avoid delinquency or late fees.',
    `number` STRING COMMENT 'Externally visible unique account number assigned to the billing account for customer reference and payment processing.',
    `outstanding_fees` DECIMAL(18,2) COMMENT 'Total unpaid fees currently due on this account, including installment fees, late fees, and service charges.',
    `outstanding_premium` DECIMAL(18,2) COMMENT 'Total unpaid premium amount currently due on this account, excluding fees, taxes, and other charges.',
    `outstanding_taxes` DECIMAL(18,2) COMMENT 'Total unpaid taxes currently due on this account, including premium taxes, surplus lines taxes, and stamping fees.',
    `paperless_billing_flag` BOOLEAN COMMENT 'Indicates whether the policyholder has opted for electronic delivery of invoices and billing statements instead of paper mail.',
    `payment_method` STRING COMMENT 'Preferred payment instrument for this account: credit card, debit card, ACH (Automated Clearing House), check, wire transfer, or cash.. Valid values are `credit_card|debit_card|ach|check|wire_transfer|cash`',
    `payment_plan_type` STRING COMMENT 'Installment plan structure for premium payments: full pay, monthly, quarterly, semi-annual, or custom installment schedule.. Valid values are `full_pay|monthly|quarterly|semi_annual|installment`',
    `unapplied_cash` DECIMAL(18,2) COMMENT 'Amount of cash received but not yet applied to specific invoices or charges, held in suspense pending allocation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time this billing account record was last modified or updated.',
    `write_off_amount` DECIMAL(18,2) COMMENT 'Total amount written off as uncollectible on this account due to bankruptcy, insolvency, or collection failure.',
    `write_off_date` DATE COMMENT 'Date the uncollectible balance was written off and removed from accounts receivable.',
    CONSTRAINT pk_account PRIMARY KEY(`account_id`)
) COMMENT 'Master billing account linking a policyholder or payee to invoicing and collections. One row per billing account. Tracks account type (direct bill, agency bill), status, payment method, and balance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` (
    `invoice_id` BIGINT COMMENT 'Unique identifier for the invoice. Primary key.',
    `agency_id` BIGINT COMMENT 'Reference to the agency associated with this invoice for agency bill scenarios.',
    `bill_to_party_id` BIGINT COMMENT 'Reference to the party to whom this invoice is addressed, may differ from policyholder.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account that owns this invoice.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Invoice GL posting date and billing period must align to fiscal/accounting calendar periods for NAIC statutory reporting, period-close AR reconciliation, and premium written/earned',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Invoices bill claim-related charges: deductible collection from insureds, salvage recovery billing, subrogation reimbursement invoicing.',
    `claim_payment_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.claim_payment. Business justification: Deductible recovery billing: when a claim payment is made, an invoice is generated to recover the insureds deductible.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Commission audit trail: invoice.commission_amount is computed from a commission_schedule.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Invoices are primary financial documents requiring full currency master data for multi-currency operations: exchange rates, rounding rules, display formats, and regulatory reporting.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Invoice-level geography enables jurisdiction-specific tax calculation (state premium tax, municipal fees, surplus lines tax), regulatory reporting by domicile, and multi-state',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Invoices require LOB segmentation for financial reporting, regulatory filings (Schedule P, statutory annual statements), and business analytics.',
    `payment_plan_id` BIGINT COMMENT 'Reference to the payment plan or installment schedule associated with this invoice.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this invoice was generated.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term covered by this invoice.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: P&C invoices are generated by policy transactions (new business, endorsement, renewal, cancellation).',
    `policyholder_id` BIGINT COMMENT 'Reference to the party responsible for payment of this invoice.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent associated with this invoice for commission purposes.',
    `ri_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_agreement. Business justification: Bordereaux and ceded-premium settlement invoices are issued under a specific reinsurance agreement.',
    `risk_inspection_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_inspection. Business justification: Inspection fees are billed as separate invoices tied to a specific risk inspection order.',
    `amount_paid` DECIMAL(18,2) COMMENT 'Total amount paid against this invoice to date.',
    `billing_method` STRING COMMENT 'Method by which the invoice is billed: direct to policyholder or through agency.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `billing_period_end_date` DATE COMMENT 'End date of the coverage or billing period represented by this invoice.',
    `billing_period_start_date` DATE COMMENT 'Start date of the coverage or billing period represented by this invoice.',
    `cancellation_notice_date` DATE COMMENT 'Date on which a cancellation notice was sent due to non-payment of this invoice.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Total commission payable to the producer or agency on this invoice.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice record was first created in the billing system.',
    `delinquency_status` STRING COMMENT 'Current delinquency status of this invoice for collections management.. Valid values are `current|grace_period|delinquent|notice_sent|cancellation_pending`',
    `invoice_description` STRING COMMENT 'Free-text description or memo providing additional context about this invoice.',
    `due_date` DATE COMMENT 'Date by which payment is due for this invoice.',
    `fee_amount` DECIMAL(18,2) COMMENT 'Total fees and surcharges included in this invoice.',
    `gl_posting_date` DATE COMMENT 'Date on which this invoice was posted to the general ledger for accounting purposes.',
    `installment_number` BIGINT COMMENT 'Sequence number of this invoice within a multi-installment payment plan.',
    `invoice_date` DATE COMMENT 'Date the invoice was issued to the policyholder or agency.',
    `invoice_status` STRING COMMENT 'Current lifecycle status of the invoice in the billing workflow. [ENUM-REF-CANDIDATE: draft|issued|billed|paid|partially_paid|overdue|cancelled|written_off — 8 candidates stripped; promote to reference product]',
    `invoice_type` STRING COMMENT 'Type of invoice based on the underlying policy transaction or billing event. [ENUM-REF-CANDIDATE: new_business|renewal|endorsement|cancellation|reinstatement|audit|installment|commission — 8 candidates stripped; promote to reference product]',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice record was last updated in the billing system.',
    `number` STRING COMMENT 'Externally visible unique invoice number assigned by the billing system.',
    `outstanding_balance` DECIMAL(18,2) COMMENT 'Remaining unpaid balance on this invoice.',
    `paid_date` DATE COMMENT 'Date on which this invoice was fully paid.',
    `payment_method` STRING COMMENT 'Preferred or expected payment method for this invoice. [ENUM-REF-CANDIDATE: check|ach|credit_card|debit_card|wire_transfer|cash|payroll_deduction — 7 candidates stripped; promote to reference product]',
    `premium_amount` DECIMAL(18,2) COMMENT 'Total premium charges included in this invoice before taxes and fees.',
    `reversal_date` DATE COMMENT 'Date on which this invoice was reversed or voided.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this invoice has been reversed or voided.',
    `reversal_reason` STRING COMMENT 'Business reason or code explaining why this invoice was reversed.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax charges included in this invoice.',
    `total_amount_due` DECIMAL(18,2) COMMENT 'Total amount due on this invoice including premium, taxes, and fees.',
    `total_installments` BIGINT COMMENT 'Total number of installments in the payment plan for this policy term.',
    `write_off_reason` STRING COMMENT 'Business reason or code explaining why this invoice balance was written off.',
    `written_off_date` DATE COMMENT 'Date on which the outstanding balance of this invoice was written off as uncollectible.',
    CONSTRAINT pk_invoice PRIMARY KEY(`invoice_id`)
) COMMENT 'Billing document issued to a policyholder or agency for premium charges, fees, and taxes due. One row per invoice. Grain: one invoice per billing cycle per billing account. Tracks due date, amount billed, and status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` (
    `invoice_item_id` BIGINT COMMENT 'Unique identifier for the invoice item. Primary key.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period this item is recognized in for financial reporting and statutory filings.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Wind pool assessments, coastal surcharges, and cat-zone-specific fees appear as invoice line items requiring cat zone attribution.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Cat assessment fees, FHCF surcharges, and cat-specific premium endorsements appear as invoice line items tied to specific cat events.',
    `cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.cession. Business justification: Invoice items for ceded policies must track which cession applies to calculate net premium due after reinsurance credit.',
    `charge_id` BIGINT COMMENT 'Reference to the premium charge record this item bills. Null for taxes, fees, or commissions.',
    `claim_expense_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.claim_expense. Business justification: LAE expense billing reconciliation: vendor invoices for DCC/LAE expenses (legal, medical, expert) generate invoice line items referencing the specific claim_expense record',
    `claim_payment_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.claim_payment. Business justification: Line-level deductible billing reconciliation: each invoice line for a deductible charge references the specific claim payment that generated it, enabling precise cash',
    `coverage_id` BIGINT COMMENT 'Reference to the coverage this item charges for. Null for policy-level fees or taxes.',
    `driver_id` BIGINT COMMENT 'Foreign key linking to riskexposure.driver. Business justification: Driver-specific billing line items — SR-22 filing fees, driver surcharges, and DUI-related premium loads — must reference the specific driver.',
    `invoice_id` BIGINT COMMENT 'Reference to the parent invoice header. Links this line item to its containing invoice.',
    `payment_plan_id` BIGINT COMMENT 'Reference to the payment plan this item is billed under. Null for full-pay or direct-bill policies.',
    `policy_id` BIGINT COMMENT 'Reference to the policy this invoice item relates to. Enables reconciliation to policy contract.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term period this charge applies to. Supports effective dating.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Invoice line items in P&C are generated by policy transactions (premium changes, endorsements, cancellations).',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent earning the commission. Populated only when item_type is commission.',
    `property_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.property_risk. Business justification: Commercial property premium allocation requires billing line items tied to specific property risks.',
    `reinsurance_recovery_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.reinsurance_recovery. Business justification: Line-level reinsurance recovery billing: invoice line items for ceded loss and LAE reference specific reinsurance_recovery records, enabling per-line reconciliation of',
    `reversed_item_invoice_item_id` BIGINT COMMENT 'Reference to the original invoice item this item reverses. Populated only when reversal_flag is true.',
    `ri_claim_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_claim_cession. Business justification: Invoice line items for reinsurance loss recovery billings reference the specific ri_claim_cession being billed.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Commercial lines billing often requires risk-level premium detail for schedule-rated policies with multiple locations/buildings.',
    `tax_levy_id` BIGINT COMMENT 'Foreign key linking to premium.tax_levy. Business justification: Invoice items for taxes must reference the specific tax_levy record that calculated the tax amount.',
    `vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.vehicle. Business justification: Auto insurance billing allocates premium line items per vehicle (VIN-level). Vehicle-specific surcharges, endorsement fees, and per-vehicle installment schedules require this FK.',
    `billing_method` STRING COMMENT 'Method by which this item is billed: direct to policyholder, agency bill, list bill, or account current.. Valid values are `direct|agency|list|account_current`',
    `commission_rate` DECIMAL(7,5) COMMENT 'Commission rate applied to calculate the commission amount. Expressed as a decimal. Populated only when item_type is commission.',
    `created_by_user` STRING COMMENT 'User identifier or system process that created this invoice item record. Supports audit and compliance.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice item record was first created in the billing system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the item amount. Typically USD for US-domiciled insurers.. Valid values are `^[A-Z]{3}$`',
    `due_date` DATE COMMENT 'Date payment for this invoice item is due from the policyholder. Inherited from invoice header but may vary by item.',
    `effective_date` DATE COMMENT 'Date this invoice item becomes effective. Aligns with the policy transaction or coverage effective date.',
    `expiration_date` DATE COMMENT 'Date this invoice item expires. Aligns with the policy term or coverage expiration date.',
    `gl_account_code` STRING COMMENT 'General ledger account code this item posts to. Enables financial statement reconciliation and statutory reporting.',
    `installment_number` BIGINT COMMENT 'Installment sequence number if this item is part of an installment payment plan. Null for full-pay policies.',
    `item_amount` DECIMAL(15,2) COMMENT 'Monetary amount of this invoice line item in the invoice currency. Positive for charges, negative for credits or refunds.',
    `item_category` STRING COMMENT 'Further categorization of the item within its type. For premium: written, earned, unearned, return. For fees: installment, surcharge, penalty. [ENUM-REF-CANDIDATE: written|earned|unearned|return|installment|surcharge|penalty — 7 candidates stripped',
    `item_code` STRING COMMENT 'Internal billing code or accounting code for the item type. Used for general ledger posting and reporting.',
    `item_description` STRING COMMENT 'Human-readable description of the invoice item displayed to the policyholder. Explains what is being charged.',
    `item_type` STRING COMMENT 'Classification of the invoice line item indicating what is being billed: premium charge, tax, fee, commission, adjustment, or refund.. Valid values are `premium|tax|fee|commission|adjustment|refund`',
    `line_number` BIGINT COMMENT 'Sequential line number within the invoice for ordering and display purposes.',
    `outstanding_amount` DECIMAL(15,2) COMMENT 'Remaining unpaid balance for this invoice item. Calculated as item_amount minus paid_amount.',
    `paid_amount` DECIMAL(15,2) COMMENT 'Amount of this invoice item that has been paid by the policyholder. Updated as payments are applied.',
    `proration_factor` DECIMAL(9,6) COMMENT 'Decimal factor applied to calculate prorated premium for mid-term endorsements or cancellations.',
    `proration_method` STRING COMMENT 'Method used to prorate premium for mid-term changes. Daily, monthly, short-rate, pro-rata, or full-term.. Valid values are `daily|monthly|short_rate|pro_rata|full_term`',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this invoice item reverses a prior item due to cancellation, endorsement, or correction. True if reversal, false otherwise.',
    `tax_jurisdiction` STRING COMMENT 'State, county, or municipal jurisdiction imposing the tax. Populated only when item_type is tax.',
    `tax_rate` DECIMAL(7,5) COMMENT 'Tax rate applied to calculate the tax amount. Expressed as a decimal (e.g., 0.06 for 6%). Populated only when item_type is tax.',
    `taxable_base_amount` DECIMAL(15,2) COMMENT 'Base premium amount the tax is calculated on. Populated only when item_type is tax.',
    `transaction_date` DATE COMMENT 'Date the underlying premium or billing transaction occurred that generated this invoice item.',
    `updated_by_user` STRING COMMENT 'User identifier or system process that last modified this invoice item record. Supports audit and compliance.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice item record was last modified. Supports audit trail and change tracking.',
    `waived_flag` BOOLEAN COMMENT 'Indicates whether this fee or charge was waived by underwriting or management approval. True if waived, false otherwise.',
    `waiver_reason` STRING COMMENT 'Business reason the fee or charge was waived. Populated only when waived_flag is true.',
    `write_off_amount` DECIMAL(15,2) COMMENT 'Amount of this invoice item written off as uncollectible. Reduces outstanding balance without payment.',
    CONSTRAINT pk_invoice_item PRIMARY KEY(`invoice_item_id`)
) COMMENT 'Line-level detail on an invoice representing a single charge, tax, fee, or commission amount. One row per line item per invoice. Links to premium charge, coverage, and policy term for reconciliation.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` (
    `payment_id` BIGINT COMMENT 'Unique identifier for the payment transaction. Primary key.',
    `agency_id` BIGINT COMMENT 'Reference to the agency associated with this payment, if applicable.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account against which this payment is applied.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Payment receipt and GL posting dates must tie to fiscal/accounting periods for cash-basis premium reporting, NAIC Schedule T, and period-close cash reconciliation.',
    `commission_statement_id` BIGINT COMMENT 'Foreign key linking to producers.commission_statement. Business justification: Agency-bill remittance reconciliation: agencies remit premium net of commission, and the payment corresponds to a specific commission_statement.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Payments received in multiple currencies require currency master data for foreign exchange processing, bank reconciliation, and treasury operations.',
    `invoice_id` BIGINT COMMENT 'Reference to the invoice this payment is applied against, if applicable.',
    `payer_party_id` BIGINT COMMENT 'Reference to the party (person or organization) who made the payment.',
    `payment_method_id` BIGINT COMMENT 'Foreign key linking to billing.payment_method. Business justification: payment.method (STRING) is a denormalized copy of the payment instrument type that is authoritatively stored in payment_method.',
    `payment_plan_id` BIGINT COMMENT 'Reference to the payment plan or installment schedule this payment is part of, if applicable.',
    `policy_id` BIGINT COMMENT 'Reference to the policy associated with this payment.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: In P&C, premium payments must be allocated to specific policy terms for earned/unearned premium accounting, reinsurance treaty settlement, and policy year loss ratio reporting.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent associated with this payment, if applicable.',
    `ri_premium_transaction_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_premium_transaction. Business justification: Outgoing payments to reinsurers for ceded premium remittance must reference the ri_premium_transaction being settled.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to coverage.submission. Business justification: Down payments or good-faith deposits may be collected at submission stage before binding, particularly for commercial lines or high-value personal lines.',
    `amount` DECIMAL(18,2) COMMENT 'Total monetary amount of the payment received.',
    `applied_amount` DECIMAL(18,2) COMMENT 'Portion of the payment amount that has been applied to outstanding invoices or charges.',
    `applied_date` DATE COMMENT 'Date the payment was applied to the billing account or invoice.',
    `authorization_code` STRING COMMENT 'Authorization code provided by the payment processor for card transactions.',
    `bank_account_last_four` STRING COMMENT 'Last four digits of the bank account used for ACH or wire transfer payments.. Valid values are `^[0-9]{4}$`',
    `bank_routing_number` STRING COMMENT 'Nine-digit ABA routing number for ACH or wire transfer payments.. Valid values are `^[0-9]{9}$`',
    `card_last_four` STRING COMMENT 'Last four digits of the payment card used, for identification purposes only.. Valid values are `^[0-9]{4}$`',
    `card_type` STRING COMMENT 'Type of payment card used (Visa, MasterCard, American Express, Discover).. Valid values are `visa|mastercard|amex|discover`',
    `channel` STRING COMMENT 'Interface or channel through which the payment was received (web, mobile, agent portal, mail, phone, in-person).. Valid values are `web|mobile_app|agent_portal|mail|phone|in_person`',
    `check_number` STRING COMMENT 'Check number for payments made by check.',
    `cleared_date` DATE COMMENT 'Date the payment cleared through the financial institution and funds were confirmed.',
    `created_by_user` STRING COMMENT 'User identifier of the person or system that created the payment record.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the payment record was first created in the system.',
    `effective_date` DATE COMMENT 'Date from which the payment is considered effective for policy coverage and billing purposes.',
    `installment_number` BIGINT COMMENT 'Sequential number of this installment within the payment plan (e.g., 1 of 12).',
    `is_returned` BOOLEAN COMMENT 'Indicates whether the payment was returned due to insufficient funds or other reasons.',
    `modified_by_user` STRING COMMENT 'User identifier of the person or system that last modified the payment record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the payment record was last modified.',
    `notes` STRING COMMENT 'Free-text notes or comments about the payment transaction.',
    `nsf_fee_amount` DECIMAL(18,2) COMMENT 'Fee charged to the policyholder for a returned payment due to insufficient funds.',
    `number` STRING COMMENT 'Externally visible unique business identifier for the payment transaction.',
    `payment_status` STRING COMMENT 'Current lifecycle status of the payment transaction.. Valid values are `pending|applied|cleared|reversed|returned|voided`',
    `payment_type` STRING COMMENT 'Classification of the payment purpose (premium, down payment, installment, reinstatement, endorsement, refund).. Valid values are `premium|down_payment|installment|reinstatement|endorsement|refund`',
    `processor` STRING COMMENT 'Name of the payment gateway or processor that handled the transaction.',
    `receipt_date` DATE COMMENT 'Date the payment was received by the insurer.',
    `receipt_timestamp` TIMESTAMP COMMENT 'Precise date and time the payment was received and recorded in the billing system.',
    `reference_number` STRING COMMENT 'External reference number provided by the payer or payment processor (e.g., check number, confirmation number).',
    `return_reason_code` STRING COMMENT 'Code indicating the reason for payment return (e.g., NSF, account closed, stop payment).',
    `return_reason_description` STRING COMMENT 'Detailed explanation of why the payment was returned.',
    `returned_date` DATE COMMENT 'Date the payment was returned by the financial institution.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for payment reversal (e.g., NSF, stop payment, dispute).',
    `reversal_reason_description` STRING COMMENT 'Detailed explanation of why the payment was reversed.',
    `reversed_date` DATE COMMENT 'Date the payment was reversed, if applicable.',
    `source` STRING COMMENT 'Origin or source of the payment (policyholder, agency, third party, escrow, reinsurer).. Valid values are `policyholder|agency|third_party|escrow|reinsurer`',
    `unapplied_amount` DECIMAL(18,2) COMMENT 'Portion of the payment amount that remains unapplied and available for future allocation.',
    CONSTRAINT pk_payment PRIMARY KEY(`payment_id`)
) COMMENT 'Record of a payment received from a policyholder, agency, or third party against a billing account. One row per payment transaction. Captures payment method, amount, receipt date, and application status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` (
    `payment_application_id` BIGINT COMMENT 'Unique identifier for the payment application record. Primary key.',
    `accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this payment application was recognized for financial reporting.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account for which this payment application or suspense holding is recorded.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Payment application GL posting date must align to fiscal/accounting periods for general ledger period-close reconciliation and unapplied cash reporting.',
    `claim_payment_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.claim_payment. Business justification: Deductible cash application: when an insured pays their deductible, the payment application offsets a specific claim payment.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Payment applications allocate received funds to specific coverages when policies have multiple coverage parts with separate billing.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: payment_application carries denormalized currency_code. Multi-currency cash application and GL reconciliation require a proper FK to currency for FX reporting and period-close.',
    `installment_schedule_id` BIGINT COMMENT 'Foreign key linking to billing.installment_schedule. Business justification: A payment_application records how a payment is allocated. Linking it to the specific installment_schedule row being satisfied closes the reconciliation loop: the scheduled',
    `invoice_id` BIGINT COMMENT 'Reference to the invoice to which this payment is applied. Null if unapplied or suspense.',
    `invoice_item_id` BIGINT COMMENT 'Reference to the specific invoice line item to which this payment is applied. Null if applied at invoice level or unapplied.',
    `payment_id` BIGINT COMMENT 'Reference to the payment transaction being applied or held in suspense.',
    `policy_id` BIGINT COMMENT 'Reference to the policy associated with this payment application. Null if payment is not policy-specific.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Payment applications allocate cash to specific policy terms for earned premium recognition, unearned premium reserve management, and reinsurance accounting.',
    `reversed_application_payment_application_id` BIGINT COMMENT 'Reference to the original payment application record that this reversal is correcting. Null if not a reversal.',
    `ri_recovery_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_recovery. Business justification: When a reinsurer remits a recovery payment, the cash application team applies it via payment_application.',
    `allocation_priority` BIGINT COMMENT 'Numeric priority order for applying this payment when multiple invoices or items are eligible. Lower numbers indicate higher priority.',
    `allocation_rule_code` STRING COMMENT 'Code identifying the business rule used to allocate this payment across invoices or items.',
    `application_date` DATE COMMENT 'Date on which the payment was applied to the invoice or moved to suspense.',
    `application_method` STRING COMMENT 'Method by which the payment was applied: automatic matching, manual user action, system rule, batch process, or override.. Valid values are `automatic|manual|system_rule|batch|override`',
    `application_number` STRING COMMENT 'Business-readable identifier for this payment application transaction.',
    `application_reason_code` STRING COMMENT 'Code indicating the reason for the application, unapplied status, or suspense holding.',
    `application_reason_description` STRING COMMENT 'Detailed explanation of why the payment was applied, held unapplied, or placed in suspense.',
    `application_status` STRING COMMENT 'Current status of the payment application in the billing lifecycle.. Valid values are `pending|posted|reversed|voided|cleared`',
    `application_timestamp` TIMESTAMP COMMENT 'Precise date and time when the payment application was recorded in the billing system.',
    `application_type` STRING COMMENT 'Type of payment application: applied to invoice, held as unapplied cash, held in suspense, reversal of prior application, or adjustment.. Valid values are `applied|unapplied|suspense|reversal|adjustment`',
    `applied_amount` DECIMAL(18,2) COMMENT 'Monetary amount applied to the invoice or invoice item from the payment. Zero if unapplied or suspense.',
    `applied_by_user_code` STRING COMMENT 'User identifier of the billing representative who manually applied this payment. Null if automatic.',
    `commission_payable_flag` BOOLEAN COMMENT 'Indicates whether this payment application triggers a commission payable to a producer or agent.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this payment application record was first created in the billing system.',
    `delinquency_flag` BOOLEAN COMMENT 'Indicates whether this payment application was made to cure a delinquent account or invoice.',
    `effective_date` DATE COMMENT 'Date from which this payment application is effective for billing and financial reporting purposes.',
    `expiration_date` DATE COMMENT 'Date on which this payment application record expires or is superseded. Null if currently active.',
    `external_reference_code` STRING COMMENT 'External system identifier for this payment application, used for cross-system reconciliation.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this payment application amount was posted.',
    `gl_posting_date` DATE COMMENT 'Date on which this payment application was posted to the general ledger for financial reporting.',
    `installment_number` BIGINT COMMENT 'Sequence number of the installment within the payment plan to which this application applies. Null if not part of a plan.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this payment application record was last updated in the billing system.',
    `notes` STRING COMMENT 'Free-text notes or comments recorded by billing staff regarding this payment application or suspense holding.',
    `reversal_date` DATE COMMENT 'Date on which this payment application was reversed. Null if not reversed.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this application record represents a reversal of a prior payment application.',
    `reversal_reason` STRING COMMENT 'Explanation of why this payment application was reversed.',
    `source_system_code` STRING COMMENT 'Code identifying the billing or payment system from which this payment application record originated.',
    `suspense_amount` DECIMAL(18,2) COMMENT 'Monetary amount held in suspense pending resolution of account or invoice discrepancies.',
    `suspense_cleared_by_user_code` STRING COMMENT 'User identifier of the billing representative who cleared the suspense and applied the payment.',
    `suspense_cleared_date` DATE COMMENT 'Date on which the suspense holding was resolved and the payment was applied. Null if still in suspense.',
    `suspense_reason_code` STRING COMMENT 'Code indicating the specific reason why this payment was placed in suspense rather than applied.',
    `unapplied_amount` DECIMAL(18,2) COMMENT 'Monetary amount held as unapplied cash pending identification of the correct invoice or account.',
    `write_off_flag` BOOLEAN COMMENT 'Indicates whether this application record represents a write-off of uncollectible amounts rather than a cash payment.',
    `write_off_reason_code` STRING COMMENT 'Code indicating the reason for writing off the amount. Null if not a write-off.',
    CONSTRAINT pk_payment_application PRIMARY KEY(`payment_application_id`)
) COMMENT 'Links a payment to one or more invoices or invoice items, and holds all unapplied/suspense cash pending identification of the correct account or invoice. One row per application or suspense holding.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` (
    `payment_plan_id` BIGINT COMMENT 'Unique identifier for the payment plan. Primary key.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Payment plans vary significantly by line of business: personal auto typically offers more flexible installment options than commercial property; workers comp requires specific payment',
    `type_id` BIGINT COMMENT 'Foreign key linking to policy.policy_type. Business justification: Payment plan eligibility in P&C is governed by policy type (e.g., personal auto allows monthly installments; surplus lines may require full pay).',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether underwriter or management approval is required before a policy can be bound with this plan.',
    `auto_pay_eligible_flag` BOOLEAN COMMENT 'Indicates whether this payment plan allows policyholders to enroll in automatic recurring payment processing.',
    `billing_method` STRING COMMENT 'Method by which invoices are generated and payments collected indicating whether insurer or producer handles billing.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `cancellation_short_rate_penalty_percentage` DECIMAL(5,2) COMMENT 'Percentage penalty applied to unearned premium when policyholder cancels mid-term under installment plan.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the payment plan record was first created in the billing system.',
    `payment_plan_description` STRING COMMENT 'Detailed explanation of the payment plan terms, conditions, and intended use for underwriter and agent reference.',
    `display_order` BIGINT COMMENT 'Numeric sequence controlling the presentation order of payment plans in user interfaces and quote proposals.',
    `down_payment_minimum_amount` DECIMAL(15,2) COMMENT 'Minimum dollar amount required for down payment regardless of percentage calculation.',
    `down_payment_percentage` DECIMAL(5,2) COMMENT 'Percentage of total premium required as initial down payment at policy binding expressed as decimal.',
    `effective_date` DATE COMMENT 'Date when the payment plan becomes available for use on new or renewing policies.',
    `expiration_date` DATE COMMENT 'Date when the payment plan is no longer available for new policies. Null indicates no expiration.',
    `external_plan_code` STRING COMMENT 'Third-party or legacy system payment plan identifier used for integration and data migration mapping.',
    `grace_period_days` BIGINT COMMENT 'Number of days after installment due date during which payment may be received without penalty or cancellation.',
    `installment_fee_amount` DECIMAL(10,2) COMMENT 'Fixed dollar fee charged per installment payment to cover administrative and processing costs.',
    `installment_fee_percentage` DECIMAL(5,2) COMMENT 'Percentage-based fee applied to each installment amount expressed as decimal for proportional billing.',
    `installment_frequency` STRING COMMENT 'Recurring interval at which installment payments are scheduled and invoiced to the policyholder.. Valid values are `monthly|quarterly|semi_annual|annual|bi_weekly`',
    `late_payment_fee_amount` DECIMAL(10,2) COMMENT 'Fixed dollar penalty assessed when an installment payment is received after the grace period expires.',
    `maximum_premium_amount` DECIMAL(15,2) COMMENT 'Maximum total policy premium allowed for this payment plan. Policies exceeding this may require different terms.',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'Minimum total policy premium required to qualify for this payment plan. Policies below this threshold must pay in full.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the payment plan record was last updated reflecting configuration or status changes.',
    `number_of_installments` BIGINT COMMENT 'Total count of scheduled payment installments in the plan excluding the down payment.',
    `plan_code` STRING COMMENT 'Business identifier code for the payment plan template used for external reference and billing system integration.. Valid values are `^[A-Z0-9]{2,20}$`',
    `plan_name` STRING COMMENT 'Descriptive name of the payment plan displayed to policyholders and agents.',
    `plan_status` STRING COMMENT 'Current lifecycle status of the payment plan indicating availability for new policies.. Valid values are `active|inactive|suspended|archived`',
    `plan_type` STRING COMMENT 'Classification of the payment plan structure indicating how premium is collected.. Valid values are `installment|full_pay|recurring|custom`',
    `producer_commission_impact_flag` BOOLEAN COMMENT 'Indicates whether installment fees affect producer commission calculation or are retained entirely by the insurer.',
    `regulatory_filing_reference` STRING COMMENT 'State Department of Insurance filing number or reference for approved payment plan terms and fee schedules.',
    `reinstatement_fee_amount` DECIMAL(10,2) COMMENT 'Fixed dollar fee charged to reinstate a policy that was cancelled for non-payment under this plan.',
    `returned_payment_fee_amount` DECIMAL(10,2) COMMENT 'Fixed dollar fee assessed when a payment is returned due to insufficient funds or account closure.',
    CONSTRAINT pk_payment_plan PRIMARY KEY(`payment_plan_id`)
) COMMENT 'Installment plan template defining the number of installments, down payment percentage, installment frequency, and applicable fees for a billing account or policy. Master record for plan configuration.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` (
    `installment_schedule_id` BIGINT COMMENT 'Unique identifier for the installment schedule record. Primary key.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account under which this installment is scheduled.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Installment scheduled_due_date and billing periods must align to fiscal/accounting calendar for delinquency aging reports, NAIC premium receivable reporting, and period-close installment',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: installment_schedule carries denormalized currency_code. Multi-currency installment billing requires a proper FK to currency for FX translation and regulatory reporting.',
    `installment_plan_id` BIGINT COMMENT 'Foreign key linking to billing.installment_plan. Business justification: installment_schedule rows are the individual installment lines generated under an elected installment_plan instance.',
    `invoice_id` BIGINT COMMENT 'Reference to the invoice that includes this installment charge.',
    `payment_id` BIGINT COMMENT 'Foreign key linking to billing.payment. Business justification: installment_schedule already tracks payment_received_date and paid_amount, indicating a payment was received against the scheduled installment.',
    `payment_plan_id` BIGINT COMMENT 'Reference to the payment plan that generated this installment schedule.',
    `policy_term_id` BIGINT COMMENT 'Reference to the policy term for which this installment applies.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Installment schedules are created or restructured by policy transactions (endorsements changing premium, renewals, reinstatements).',
    `auto_pay_flag` BOOLEAN COMMENT 'Indicates whether this installment is enrolled in automatic payment processing.',
    `billing_period_end_date` DATE COMMENT 'End date of the billing period covered by this installment.',
    `billing_period_start_date` DATE COMMENT 'Start date of the billing period covered by this installment.',
    `cancellation_date` DATE COMMENT 'Date on which this installment was cancelled. Null if not cancelled.',
    `cancellation_reason` STRING COMMENT 'Business reason for cancelling this installment. Null if not cancelled.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this installment schedule record was first created in the system.',
    `delinquency_days` BIGINT COMMENT 'Number of days this installment is past due. Zero if paid on time or not yet due.',
    `down_payment_flag` BOOLEAN COMMENT 'Indicates whether this installment represents the initial down payment for the policy term.',
    `fee_allocation_amount` DECIMAL(18,2) COMMENT 'Portion of the installment amount allocated to fees such as policy fees or installment fees.',
    `final_installment_flag` BOOLEAN COMMENT 'Indicates whether this is the final installment in the payment plan.',
    `grace_period_end_date` DATE COMMENT 'Date after which the installment is considered past due if unpaid. Typically scheduled due date plus grace period days.',
    `installment_fee_amount` DECIMAL(18,2) COMMENT 'Fee charged for paying in installments rather than in full. Zero if no installment fee applies.',
    `installment_number` BIGINT COMMENT 'Sequential number of this installment within the payment plan. First installment is 1.',
    `installment_status` STRING COMMENT 'Current status of the installment in its lifecycle.. Valid values are `scheduled|due|paid|past_due|waived|cancelled`',
    `late_fee_amount` DECIMAL(18,2) COMMENT 'Late fee assessed if payment is received after grace period. Zero if paid on time or waived.',
    `modified_by_user` STRING COMMENT 'User ID or name of the person or system that last modified this installment record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this installment schedule record was last modified.',
    `notice_sent_date` DATE COMMENT 'Date on which a payment reminder or delinquency notice was sent for this installment. Null if no notice sent.',
    `notice_type` STRING COMMENT 'Type of notice sent to the policyholder regarding this installment. Null if no notice sent.. Valid values are `reminder|first_notice|final_notice|cancellation_warning`',
    `outstanding_amount` DECIMAL(18,2) COMMENT 'The remaining unpaid balance on this installment. Calculated as scheduled amount minus paid amount.',
    `paid_amount` DECIMAL(18,2) COMMENT 'The actual amount paid against this installment. May differ from scheduled amount due to partial payments or adjustments.',
    `payment_channel` STRING COMMENT 'Channel through which the payment was or is expected to be received. [ENUM-REF-CANDIDATE: web|mobile_app|phone|mail|agent|branch|auto_pay — 7 candidates stripped; promote to reference product]',
    `payment_method` STRING COMMENT 'Payment instrument used or expected for this installment. [ENUM-REF-CANDIDATE: credit_card|debit_card|ach|check|cash|wire_transfer|payroll_deduction|escrow — 8 candidates stripped; promote to reference product]',
    `payment_received_date` DATE COMMENT 'Date on which payment was actually received for this installment. Null if unpaid.',
    `premium_allocation_amount` DECIMAL(18,2) COMMENT 'Portion of the installment amount allocated to premium charges.',
    `returned_payment_date` DATE COMMENT 'Date on which a payment for this installment was returned. Null if no return occurred.',
    `returned_payment_flag` BOOLEAN COMMENT 'Indicates whether a payment for this installment was returned or reversed due to insufficient funds or other reason.',
    `returned_payment_reason` STRING COMMENT 'Reason code or description for why the payment was returned. Null if no return occurred.',
    `scheduled_amount` DECIMAL(18,2) COMMENT 'The amount scheduled to be paid for this installment as originally calculated.',
    `scheduled_due_date` DATE COMMENT 'Date on which the installment payment is scheduled to be due.',
    `tax_allocation_amount` DECIMAL(18,2) COMMENT 'Portion of the installment amount allocated to taxes and surcharges.',
    `waived_amount` DECIMAL(18,2) COMMENT 'Portion of the installment amount that has been waived or forgiven. Zero if no waiver applied.',
    `waiver_reason` STRING COMMENT 'Business reason for waiving all or part of the installment. Null if no waiver applied.',
    CONSTRAINT pk_installment_schedule PRIMARY KEY(`installment_schedule_id`)
) COMMENT 'Scheduled installment records generated for a billing account under a payment plan. One row per installment. Tracks scheduled due date, scheduled amount, actual paid amount, and installment status (due, paid, past due).';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` (
    `delinquency_id` BIGINT COMMENT 'Unique identifier for the delinquency event. Primary key.',
    `billing_account_id` BIGINT COMMENT 'Billing account that entered delinquency status.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Delinquency start_date and grace_period_end_date must align to fiscal periods for collections aging reports, state regulatory cancellation notice compliance, and period-close delinquency',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Catastrophe-triggered delinquencies require event linkage for regulatory forbearance programs, loss mitigation tracking, and state-mandated grace period extensions.',
    `claim_payment_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.claim_payment. Business justification: Deductible delinquency tracking: delinquency on deductible obligations originates from a specific claim payment.',
    `contact_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Collections outreach requires identifying the responsible party (named insured, guarantor) directly on the delinquency record.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: delinquency carries denormalized currency_code. Multi-currency P&C operations require a proper FK to currency for past_due_amount and write_off_amount FX reporting and regulatory filings.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: State regulators require delinquency statistics reported by geography for market conduct exams.',
    `installment_schedule_id` BIGINT COMMENT 'Foreign key linking to billing.installment_schedule. Business justification: A delinquency lifecycle is triggered by a missed installment. Linking delinquency to the specific installment_schedule row that was missed provides precise traceability: which',
    `payment_plan_id` BIGINT COMMENT 'Payment plan that was in effect when the delinquency occurred, if applicable.',
    `policy_id` BIGINT COMMENT 'Policy associated with the delinquent billing account.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Delinquency tracking in P&C is term-specific: state-mandated cancellation notice periods, reinstatement deadlines, and earned premium calculations are all term-level events.',
    `assigned_collector_user_code` BIGINT COMMENT 'User ID of the collections specialist assigned to work this delinquency case.',
    `cancellation_effective_date` DATE COMMENT 'Date the policy will be or was cancelled due to non-payment if the delinquency is not cured.',
    `cancellation_notice_date` DATE COMMENT 'Date the notice of intent to cancel for non-payment was sent to the policyholder, per statutory requirements.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the specific cancellation reason, typically non-payment or payment plan default.',
    `collections_agency_flag` BOOLEAN COMMENT 'Indicates whether the delinquent account was referred to an external collections agency.',
    `collections_agency_name` STRING COMMENT 'Name of the external collections agency to which the account was referred.',
    `collections_referral_date` DATE COMMENT 'Date the delinquent account was referred to the collections agency.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this delinquency record was first created in the system.',
    `days_past_due` BIGINT COMMENT 'Number of calendar days the account has been delinquent since the first missed installment due date.',
    `delinquency_status` STRING COMMENT 'Current lifecycle state of the delinquency event in the collections workflow. [ENUM-REF-CANDIDATE: open|past_due|notice_sent|pending_cancellation|cancelled|reinstated|closed|written_off — 8 candidates stripped; promote to reference product]',
    `external_reference_code` STRING COMMENT 'External identifier used by collections agencies or third-party systems to reference this delinquency.',
    `first_missed_installment_date` DATE COMMENT 'Due date of the first installment that was not paid, initiating the delinquency.',
    `first_notice_date` DATE COMMENT 'Date the first delinquency notice was sent to the policyholder.',
    `grace_period_days` BIGINT COMMENT 'Number of days allowed after the due date before the account is marked delinquent, per policy terms and state law.',
    `grace_period_end_date` DATE COMMENT 'Date the grace period expired, after which the account was marked delinquent.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this delinquency record was last updated.',
    `last_notice_date` DATE COMMENT 'Date the most recent delinquency or cancellation notice was sent.',
    `late_fee_amount` DECIMAL(15,2) COMMENT 'Late payment fees assessed during the delinquency period, per state regulations and policy terms.',
    `notes` STRING COMMENT 'Free-text notes documenting collections actions, policyholder communications, and resolution details.',
    `notice_sent_count` BIGINT COMMENT 'Total number of delinquency notices sent to the policyholder during this delinquency event.',
    `number` STRING COMMENT 'Business identifier for the delinquency event, used in collections correspondence and workflow tracking.',
    `past_due_amount` DECIMAL(15,2) COMMENT 'Portion of the total amount due that is overdue and subject to collections action.',
    `payment_plan_default_flag` BOOLEAN COMMENT 'Indicates whether the delinquency was caused by a payment plan default.',
    `penalty_amount` DECIMAL(15,2) COMMENT 'Additional penalties or interest charges applied to the delinquent balance.',
    `reason_code` STRING COMMENT 'Code indicating the root cause of delinquency, such as missed payment, returned check, or payment plan default.',
    `reason_description` STRING COMMENT 'Detailed explanation of why the account became delinquent.',
    `reinstatement_amount` DECIMAL(15,2) COMMENT 'Total amount paid to reinstate the policy, including past-due premium, fees, and penalties.',
    `reinstatement_date` DATE COMMENT 'Date the policy was reinstated after the delinquency was cured and all past-due amounts were paid.',
    `resolution_method` STRING COMMENT 'Method by which the delinquency was resolved.. Valid values are `payment_received|reinstated|cancelled|written_off|payment_plan_established`',
    `resolved_date` DATE COMMENT 'Date the delinquency was fully resolved through payment, reinstatement, cancellation, or write-off.',
    `returned_payment_flag` BOOLEAN COMMENT 'Indicates whether the delinquency was triggered by a returned or dishonored payment.',
    `returned_payment_reason` STRING COMMENT 'Reason the payment was returned, such as insufficient funds, closed account, or stop payment.',
    `source_system_code` STRING COMMENT 'Code identifying the billing system that originated this delinquency record.',
    `start_date` DATE COMMENT 'Date the billing account first became delinquent, typically the day after the grace period expired.',
    `start_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the delinquency event was triggered in the billing system.',
    `total_amount_due` DECIMAL(15,2) COMMENT 'Total outstanding balance owed on the billing account at the time of delinquency, including premium, fees, and penalties.',
    `write_off_amount` DECIMAL(15,2) COMMENT 'Amount of the delinquent balance that was written off as bad debt.',
    `write_off_date` DATE COMMENT 'Date the delinquent balance was written off as uncollectible, per accounting policy.',
    `write_off_reason_code` STRING COMMENT 'Code indicating the reason for write-off, such as bankruptcy, deceased, or uncollectible.',
    CONSTRAINT pk_delinquency PRIMARY KEY(`delinquency_id`)
) COMMENT 'Delinquency lifecycle for a billing account that missed installments, including all workflow actions (past-due, cancellation, reinstatement, write-off trigger) and notices issued during collections. One row per delinquency event per account.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` (
    `delinquency_action_id` BIGINT COMMENT 'Unique identifier for each delinquency action record. Primary key.',
    `billing_account_id` BIGINT COMMENT 'Foreign key to the billing account associated with this delinquency action.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Delinquency actions (cancellation notices, reinstatement deadlines) must align to fiscal/accounting periods for state regulatory compliance tracking, period-close cancellation reporting, and',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Post-catastrophe grace period extensions and collection forbearance actions are tied to declared catastrophe events.',
    `delinquency_id` BIGINT COMMENT 'Foreign key to the parent delinquency process that this action belongs to.',
    `invoice_id` BIGINT COMMENT 'Foreign key linking to billing.billing_notice. Business justification: Delinquency actions often generate billing notices (cancellation notice, reinstatement offer, final demand).',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy affected by this delinquency action.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Cancellation and reinstatement actions are term-specific operations in P&C. State DOI compliance requires linking each delinquency action (cancellation notice, reinstatement offer) to the exact',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Delinquency actions (cancellation execution, reinstatement) directly generate or correspond to policy transactions.',
    `reversed_action_delinquency_action_id` BIGINT COMMENT 'Foreign key to the original delinquency action that this action reverses, if applicable.',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Cancellation for non-payment may trigger reinstatement underwriting review or conditional reinstatement decisions.',
    `action_date` DATE COMMENT 'Business date when the delinquency action was initiated or executed.',
    `action_outcome_code` STRING COMMENT 'Result or outcome of the delinquency action after execution.. Valid values are `SUCCESS|PARTIAL|FAILED|PENDING|REVERSED`',
    `action_reason_code` STRING COMMENT 'Coded reason or trigger that caused this delinquency action to be initiated.',
    `action_reason_description` STRING COMMENT 'Detailed narrative explanation of why this delinquency action was taken.',
    `action_sequence_number` BIGINT COMMENT 'Sequential order of this action within the parent delinquency process.',
    `action_status` STRING COMMENT 'Current status of the delinquency action in its workflow lifecycle.. Valid values are `PENDING|COMPLETED|FAILED|CANCELLED|REVERSED`',
    `action_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the delinquency action was initiated or executed.',
    `action_type_code` STRING COMMENT 'Type of delinquency action taken: notice issued, reminder sent, cancellation initiated, reinstatement offered, write-off triggered, or referral to collections.. Valid values are `NOTICE|REMINDER|CANCELLATION|REINSTATEMENT|WRITEOFF|REFERRAL`',
    `approval_date` DATE COMMENT 'Date when this delinquency action was approved or authorized for execution.',
    `approved_by_user_code` STRING COMMENT 'Identifier of the system user who approved or authorized this delinquency action, if approval required.',
    `cancellation_effective_date` DATE COMMENT 'Date when the policy cancellation becomes effective if this action is a cancellation.',
    `cancellation_type_code` STRING COMMENT 'Type of cancellation initiated if action type is cancellation, such as non-payment cancellation or flat cancellation.',
    `collections_agency_code` STRING COMMENT 'Identifier of the external collections agency to which the account was referred, if applicable.',
    `collections_referral_date` DATE COMMENT 'Date when the delinquent account was referred to external collections agency.',
    `collections_referral_flag` BOOLEAN COMMENT 'Indicates whether the delinquent account was referred to external collections agency as part of this action.',
    `completed_date` DATE COMMENT 'Date when the delinquency action was fully completed or finalized.',
    `effective_date` DATE COMMENT 'Date when the delinquency action becomes effective for policy or billing purposes.',
    `external_reference_code` STRING COMMENT 'External system identifier or reference number for this delinquency action, used for cross-system reconciliation.',
    `grace_period_days` BIGINT COMMENT 'Number of days allowed for policyholder response or payment before next action is triggered.',
    `grace_period_end_date` DATE COMMENT 'Date when the grace period expires and next delinquency action may be triggered.',
    `initiated_by_user_code` STRING COMMENT 'Identifier of the system user or automated process that initiated this delinquency action.',
    `notes` STRING COMMENT 'Free-form text notes or comments about this delinquency action for internal reference.',
    `regulatory_compliance_flag` BOOLEAN COMMENT 'Indicates whether this delinquency action complies with all applicable state and federal regulatory requirements.',
    `reinstatement_deadline_date` DATE COMMENT 'Last date by which the policyholder can accept the reinstatement offer and restore coverage.',
    `reinstatement_offered_flag` BOOLEAN COMMENT 'Indicates whether a reinstatement offer was extended to the policyholder as part of this action.',
    `reversal_date` DATE COMMENT 'Date when this delinquency action was reversed or undone.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this delinquency action was subsequently reversed or undone.',
    `reversal_reason_code` STRING COMMENT 'Coded reason why this delinquency action was reversed, such as payment received or error correction.',
    `scheduled_date` DATE COMMENT 'Planned date for the delinquency action to be executed, if scheduled in advance.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that originated this delinquency action record, such as billing system or collections module.',
    `state_code` STRING COMMENT 'Two-letter state code where the delinquency action is governed, determining applicable regulatory rules.',
    `write_off_amount` DECIMAL(15,2) COMMENT 'Dollar amount written off if this action is a write-off, representing uncollectible balance.',
    `write_off_reason_code` STRING COMMENT 'Coded reason for the write-off if this action is a write-off, such as bankruptcy or uncollectible.',
    CONSTRAINT pk_delinquency_action PRIMARY KEY(`delinquency_action_id`)
) COMMENT 'Individual workflow action taken within a delinquency process (notice issued, cancellation initiated, reinstatement offered, write-off triggered). One row per action per delinquency. Tracks action type, action date, and outcome.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` (
    `disbursement_id` BIGINT COMMENT 'Unique identifier for the disbursement transaction. Primary key.',
    `accounting_period_id` BIGINT COMMENT 'Accounting period in which the disbursement is recognized for financial and statutory reporting.',
    `billing_account_id` BIGINT COMMENT 'Billing account from which the disbursement originates or to which it relates.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Disbursement GL posting date must align to fiscal/accounting periods for claims payment reporting, NAIC Schedule P loss payment triangles, and period-close cash disbursement reconciliation.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Claim disbursements must be attributed to catastrophe events for cat loss payment aggregation, reinsurance recovery calculations, and regulatory cat loss reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Foreign key linking to claims.claim_exposure. Business justification: Claim disbursements (payments, settlements) are issued at the per-coverage-line (claim_exposure) level.',
    `claim_id` BIGINT COMMENT 'Claim associated with the disbursement, if payment relates to claim settlement or recovery.',
    `claim_payment_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.claim_payment. Business justification: Disbursements execute claim payments via check/EFT. Linking disbursement to the specific claim_payment record enables reconciliation of authorized claim payments vs actual cash',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to claims.claimant. Business justification: Settlement and indemnity disbursements are issued to specific claimants. This FK supports claimant-level payment tracking, 1099 tax reporting, settlement agreement reconciliation, and',
    `commission_statement_id` BIGINT COMMENT 'Foreign key linking to producers.commission_statement. Business justification: Agency commission statement settlement: a single disbursement pays an entire commission statement (bulk remittance).',
    `commission_transaction_id` BIGINT COMMENT 'Foreign key linking to producers.commission_transaction. Business justification: Commission settlement process: a disbursement check to a producer settles a specific commission_transaction.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Disbursements carry denormalized currency_code. Multi-currency P&C operations (e.g., Canadian or Lloyds business) require a proper FK to currency for FX translation, regulatory reporting',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: State regulatory reporting requires cat loss disbursements aggregated by geography.',
    `litigation_id` BIGINT COMMENT 'Foreign key linking to claims.litigation. Business justification: Defense cost and settlement disbursements must be tracked against specific litigation records for legal expense management, outside counsel billing reconciliation, and litigation reserve',
    `payee_address_id` BIGINT COMMENT 'Foreign key linking to party.address. Business justification: Commission and claim disbursement checks require USPS-validated payee address for delivery. Denormalized address fields should reference party.address master to leverage geocoding, DPV',
    `payee_agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Agency commission disbursement: checks are cut to agencies (not individual producers) for agency-bill commission settlements.',
    `payee_party_id` BIGINT COMMENT 'Party receiving the disbursement payment, linking to the party master.',
    `policy_id` BIGINT COMMENT 'Policy associated with the disbursement transaction.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Return premium disbursements and producer commission disbursements are reconciled at the policy term level for earned premium accounting, reinsurance settlement, and statutory financial',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Return premium disbursements are triggered by specific policy transactions (cancellation, mid-term endorsement).',
    `producers_producer_id` BIGINT COMMENT 'Producer associated with commission disbursement, if applicable.',
    `reversed_disbursement_id` BIGINT COMMENT 'Identifier of the original disbursement being reversed, if this is a reversal transaction.',
    `ri_premium_transaction_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_premium_transaction. Business justification: Disbursements remitting ceded premium or ceding commission to reinsurers reference the underlying ri_premium_transaction.',
    `ri_recovery_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_recovery. Business justification: Reinsurance recovery receipts are posted as cash receipts in billing. Linking disbursement to ri_recovery enables the reinsurance cash reconciliation process, allowing finance to',
    `salvage_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.salvage. Business justification: Salvage proceeds disbursement: auction or sale proceeds for salvaged property are disbursed through billing.',
    `subrogation_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.subrogation. Business justification: Subrogation proceeds disbursement: collected subrogation amounts are disbursed to the insured (made-whole reimbursement) or retained.',
    `approval_date` DATE COMMENT 'Date the disbursement was approved for payment by authorized personnel.',
    `approved_by_user_code` STRING COMMENT 'User identifier of the person who approved the disbursement for payment.',
    `check_number` STRING COMMENT 'Physical check number if the disbursement was issued via check.',
    `cleared_date` DATE COMMENT 'Date the disbursement cleared the bank or payment processor.',
    `commission_basis_amount` DECIMAL(18,2) COMMENT 'Base premium or transaction amount on which the commission was calculated.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission rate applied to calculate the disbursement amount, if applicable to producer commission.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the disbursement record was first created in the system.',
    `disbursement_date` DATE COMMENT 'Date the disbursement was issued or scheduled for payment.',
    `disbursement_status` STRING COMMENT 'Current lifecycle status of the disbursement transaction.. Valid values are `pending|approved|issued|cleared|voided|cancelled`',
    `disbursement_type` STRING COMMENT 'Classification of the disbursement purpose: commission payable, premium refund, return premium, claim payment, or recovery. [ENUM-REF-CANDIDATE',
    `external_reference_code` STRING COMMENT 'External system reference identifier for cross-system reconciliation and tracking.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which the disbursement is posted for financial reporting.',
    `gl_posting_date` DATE COMMENT 'Date the disbursement transaction was posted to the general ledger.',
    `gross_amount` DECIMAL(18,2) COMMENT 'Total gross amount of the disbursement before any withholdings or adjustments.',
    `issued_by_user_code` STRING COMMENT 'User identifier of the person who issued or processed the disbursement.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the disbursement record was last modified or updated.',
    `net_amount` DECIMAL(18,2) COMMENT 'Net amount disbursed to the payee after all withholdings and adjustments.',
    `notes` STRING COMMENT 'Free-text notes or comments related to the disbursement transaction.',
    `number` STRING COMMENT 'Business-facing unique identifier or check number for the disbursement.',
    `payee_name` STRING COMMENT 'Full legal name of the payee receiving the disbursement.',
    `payee_tax_number` STRING COMMENT 'Tax identification number (TIN, EIN, or SSN) of the payee for IRS reporting and withholding.',
    `payment_method` STRING COMMENT 'Method or instrument used for the disbursement: check, ACH, wire transfer, EFT, card, or cash.. Valid values are `check|ach|wire|eft|card|cash`',
    `payment_reference_number` STRING COMMENT 'External reference number from the payment processor or bank for tracking and reconciliation.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this disbursement is a reversal of a prior disbursement transaction.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason for reversing the disbursement, if applicable. [ENUM-REF-CANDIDATE: stop_payment|incorrect_amount|duplicate|payee_error|policy_cancelled|claim_denied|other — promote to reference product]',
    `reversal_reason_description` STRING COMMENT 'Detailed explanation of why the disbursement was reversed.',
    `source_system_code` STRING COMMENT 'Code identifying the originating system that created the disbursement record.',
    `timestamp` TIMESTAMP COMMENT 'Precise date and time the disbursement transaction was created or issued.',
    `void_date` DATE COMMENT 'Date the disbursement was voided or cancelled, if applicable.',
    `withheld_amount` DECIMAL(18,2) COMMENT 'Amount withheld from the disbursement for tax, offset, or other deductions.',
    CONSTRAINT pk_disbursement PRIMARY KEY(`disbursement_id`)
) COMMENT 'Outbound payment to a producer, claimant, or payee, including producer commission payable pending settlement. One row per disbursement. Captures payee party, producer, policy, disbursement type (commission, refund, return premium), earned/withheld amount.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` (
    `payment_method_id` BIGINT COMMENT 'Unique identifier for the payment method record. Primary key.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account that owns this payment method.',
    `billing_address_id` BIGINT COMMENT 'Foreign key linking to party.address. Business justification: Payment processors require validated billing address for AVS (Address Verification System) fraud checks on card transactions and ACH verification.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: payment_method carries denormalized currency_code. Payment methods are currency-specific (USD ACH vs.',
    `party_id` BIGINT COMMENT 'Reference to the party (person or organization) who owns this payment instrument.',
    `autopay_enrollment_date` DATE COMMENT 'Date when the payment method was enrolled in automatic payment processing.',
    `bank_account_last_four` STRING COMMENT 'Last four digits of the bank account number for identification purposes. Masked for security and compliance.. Valid values are `^[0-9]{4}$`',
    `bank_account_type` STRING COMMENT 'Type of bank account: checking, savings, business checking, or business savings.. Valid values are `checking|savings|business_checking|business_savings`',
    `bank_name` STRING COMMENT 'Name of the financial institution for Automated Clearing House (ACH) or Electronic Funds Transfer (EFT) payment methods.',
    `bank_routing_number` STRING COMMENT 'Nine-digit American Bankers Association (ABA) routing transit number for ACH or EFT transactions.. Valid values are `^[0-9]{9}$`',
    `card_expiry_month` BIGINT COMMENT 'Expiration month of the credit or debit card (1-12). Populated only for card-based methods.',
    `card_expiry_year` BIGINT COMMENT 'Expiration year of the credit or debit card (four-digit year). Populated only for card-based methods.',
    `card_last_four` STRING COMMENT 'Last four digits of the credit or debit card number for identification purposes. Masked for Payment Card Industry (PCI) compliance.. Valid values are `^[0-9]{4}$`',
    `card_type` STRING COMMENT 'Brand of credit or debit card (Visa, MasterCard, American Express, Discover, Diners Club, JCB). Populated only for card-based methods.. Valid values are `visa|mastercard|amex|discover|diners|jcb`',
    `cardholder_name` STRING COMMENT 'Name of the cardholder as it appears on the credit or debit card.',
    `created_by_user_code` STRING COMMENT 'Identifier of the user or system process that created the payment method record.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the payment method record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when the payment method becomes active and available for use.',
    `eft_authorization_date` DATE COMMENT 'Date when the Electronic Funds Transfer authorization was granted by the account holder.',
    `eft_authorization_reference` STRING COMMENT 'Reference number or identifier for the EFT authorization agreement or signed form.',
    `eft_authorization_status` STRING COMMENT 'Status of the Electronic Funds Transfer authorization indicating whether the account holder has granted permission for automatic debits.. Valid values are `authorized|pending|declined|revoked|expired`',
    `expiration_date` DATE COMMENT 'Date when the payment method expires or is no longer valid for use. Nullable for methods without expiration.',
    `external_reference_code` STRING COMMENT 'External identifier or reference number from a third-party system, payment processor, or legacy system for cross-system reconciliation.',
    `is_autopay_enabled` BOOLEAN COMMENT 'Indicates whether this payment method is enrolled in automatic payment processing for recurring invoices.',
    `is_default` BOOLEAN COMMENT 'Indicates whether this is the default payment method for the billing account.',
    `last_verification_date` DATE COMMENT 'Date when the payment method was last verified or validated by the payment processor or financial institution.',
    `method_name` STRING COMMENT 'User-friendly display name or nickname for the payment method (e.g., Personal Visa, Business Checking).',
    `method_status` STRING COMMENT 'Current lifecycle status of the payment method indicating whether it is available for use.. Valid values are `active|inactive|expired|suspended|pending_verification|declined`',
    `method_type` STRING COMMENT 'Type of payment instrument: credit card, debit card, Automated Clearing House (ACH), Electronic Funds Transfer (EFT), check, escrow, or wire transfer. [ENUM-REF-CANDIDATE: credit_card|debit_card|ach|eft|check|escrow|wire_transfer — 7 candidates stripped',
    `notes` STRING COMMENT 'Free-form text field for additional comments, instructions, or special handling requirements related to the payment method.',
    `payment_token` STRING COMMENT 'Tokenized representation of the payment instrument provided by the payment processor for secure storage and recurring transactions.',
    `priority_rank` BIGINT COMMENT 'Numeric ranking indicating the order of preference for this payment method when multiple methods are available (1 = highest priority).',
    `processor_merchant_code` STRING COMMENT 'Merchant identifier assigned by the payment processor for transaction routing and reconciliation.',
    `processor_name` STRING COMMENT 'Name of the third-party payment processor or gateway handling transactions for this payment method (e.g., Stripe, PayPal, Authorize.Net).',
    `source_system_code` STRING COMMENT 'Code identifying the originating system or module where the payment method was captured (e.g., BillingCenter, PolicyCenter, Customer Portal).',
    `updated_by_user_code` STRING COMMENT 'Identifier of the user or system process that last modified the payment method record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the payment method record was last modified.',
    `usage_limit_amount` DECIMAL(15,2) COMMENT 'Maximum transaction amount allowed for a single payment using this method. Nullable if no limit is imposed.',
    `verification_status` STRING COMMENT 'Status of the payment method verification process indicating whether the instrument has been validated.. Valid values are `verified|pending|failed|not_required`',
    CONSTRAINT pk_payment_method PRIMARY KEY(`payment_method_id`)
) COMMENT 'Stored payment instrument on file for a billing account (credit card, ACH/EFT, check, escrow). One row per payment method per billing account. Captures instrument type, masked account details, expiry, and EFT authorization status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` (
    `account_policy_id` BIGINT COMMENT 'Unique identifier for the billing account to policy association. One row per billing-account-to-policy relationship.',
    `agency_id` BIGINT COMMENT 'Reference to the agency responsible for this policy within the billing account context.',
    `bill_to_party_id` BIGINT COMMENT 'Reference to the party who receives invoices for this policy. May differ from policyholder in agency bill scenarios.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account that owns this policy relationship.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Cat event moratoriums prohibit policy cancellation for affected policyholders.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Account-policy commission governance: the commission_schedule applicable to a policy on a billing account drives commission calculation for all transactions on that',
    `payment_plan_id` BIGINT COMMENT 'Reference to the payment plan governing this policy on the billing account.',
    `policy_id` BIGINT COMMENT 'Reference to the policy associated with this billing account.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Billing account-to-policy relationships in P&C are term-specific: a policy may move to a different billing account at renewal or mid-term endorsement.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Policies are added to or removed from billing accounts as a result of specific policy transactions (new business binding, cancellation, transfer).',
    `policyholder_id` BIGINT COMMENT 'Reference to the policyholder party for this policy. Captured for reporting and reconciliation purposes.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer responsible for this policy within the billing account context.',
    `added_by_user_code` STRING COMMENT 'Identifier of the user who added this policy to the billing account.',
    `allocation_method` STRING COMMENT 'Method used to allocate payments across policies on this billing account.. Valid values are `proportional|priority|equal|custom`',
    `allocation_percentage` DECIMAL(5,2) COMMENT 'Percentage of account-level payments to allocate to this policy. Used for proportional allocation rules.',
    `allocation_priority` BIGINT COMMENT 'Priority order for allocating payments when multiple policies exist on the same billing account. Lower numbers indicate higher priority.',
    `billing_method` STRING COMMENT 'Method by which this policy is billed within the account. Supports agency bill and direct bill splits.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `cancellation_notice_date` DATE COMMENT 'Date when a cancellation notice was issued for this policy due to non-payment on the billing account.',
    `cancellation_pending_flag` BOOLEAN COMMENT 'Indicates whether this policy is pending cancellation due to billing account delinquency.',
    `commission_payable_flag` BOOLEAN COMMENT 'Indicates whether producer commission is payable for this policy on this billing account. Supports agency bill scenarios where commission handling differs.',
    `consolidation_flag` BOOLEAN COMMENT 'Indicates whether this policy is part of a multi-policy consolidated billing arrangement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this account-policy relationship record was first created in the system.',
    `delinquency_flag` BOOLEAN COMMENT 'Indicates whether this policy is currently delinquent on the billing account.',
    `effective_date` DATE COMMENT 'Date when this policy was added to the billing account.',
    `expiration_date` DATE COMMENT 'Date when this policy was removed from the billing account. Null for active relationships.',
    `external_reference_code` STRING COMMENT 'External system reference identifier for this account-policy relationship. Used for integration and reconciliation.',
    `installment_billing_flag` BOOLEAN COMMENT 'Indicates whether this policy is billed on an installment basis within the billing account.',
    `notes` STRING COMMENT 'Free-form notes regarding this account-policy relationship. Used for special billing instructions or exceptions.',
    `relationship_status` STRING COMMENT 'Current lifecycle status of the account-to-policy association.. Valid values are `active|inactive|suspended|pending|terminated`',
    `relationship_type` STRING COMMENT 'Type of relationship between the billing account and policy. Supports multi-policy consolidation and split billing scenarios.. Valid values are `primary|secondary|consolidated|split`',
    `removed_by_user_code` STRING COMMENT 'Identifier of the user who removed this policy from the billing account.',
    `source_system_code` STRING COMMENT 'Code identifying the source billing system that created this account-policy relationship.',
    `split_billing_flag` BOOLEAN COMMENT 'Indicates whether this policy uses split billing between direct bill and agency bill methods.',
    `termination_date` DATE COMMENT 'Date when the account-policy relationship was terminated due to cancellation, non-renewal, or account closure.',
    `termination_reason_code` STRING COMMENT 'Code indicating why the account-policy relationship was terminated.',
    `termination_reason_description` STRING COMMENT 'Detailed explanation of why the account-policy relationship was terminated.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this account-policy relationship record was last modified.',
    CONSTRAINT pk_account_policy PRIMARY KEY(`account_policy_id`)
) COMMENT 'Association linking a billing account to one or more policies. One row per billing-account-to-policy relationship. Supports agency bill and direct bill splits, and multi-policy billing account consolidation.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_payment_id` FOREIGN KEY (`payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment`(`payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_reversed_item_invoice_item_id` FOREIGN KEY (`reversed_item_invoice_item_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item`(`invoice_item_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_payment_method_id` FOREIGN KEY (`payment_method_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_method`(`payment_method_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_installment_schedule_id` FOREIGN KEY (`installment_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule`(`installment_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_invoice_item_id` FOREIGN KEY (`invoice_item_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item`(`invoice_item_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_payment_id` FOREIGN KEY (`payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment`(`payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_reversed_application_payment_application_id` FOREIGN KEY (`reversed_application_payment_application_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_application`(`payment_application_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_installment_plan_id` FOREIGN KEY (`installment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan`(`installment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_payment_id` FOREIGN KEY (`payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment`(`payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_installment_schedule_id` FOREIGN KEY (`installment_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule`(`installment_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_delinquency_id` FOREIGN KEY (`delinquency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`delinquency`(`delinquency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_reversed_action_delinquency_action_id` FOREIGN KEY (`reversed_action_delinquency_action_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action`(`delinquency_action_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_reversed_disbursement_id` FOREIGN KEY (`reversed_disbursement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`disbursement`(`disbursement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ADD CONSTRAINT `fk_billing_payment_method_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`account`(`account_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`billing` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`billing` SET TAGS ('dbx_domain' = 'billing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` SET TAGS ('dbx_subdomain' = 'installment_scheduling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `installment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Plan Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `amount_outstanding` SET TAGS ('dbx_business_glossary_term' = 'Amount Outstanding');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `amount_paid_to_date` SET TAGS ('dbx_business_glossary_term' = 'Amount Paid to Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `auto_pay_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto Pay Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `cancellation_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `cancellation_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `days_delinquent` SET TAGS ('dbx_business_glossary_term' = 'Days Delinquent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `delinquency_date` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `down_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `down_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Installment Plan Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Installment Plan Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `final_installment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Final Installment Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `first_installment_due_date` SET TAGS ('dbx_business_glossary_term' = 'First Installment Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `installment_fee_per_payment` SET TAGS ('dbx_business_glossary_term' = 'Installment Fee Per Payment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `installments_outstanding` SET TAGS ('dbx_business_glossary_term' = 'Installments Outstanding Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `installments_paid` SET TAGS ('dbx_business_glossary_term' = 'Installments Paid Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `is_delinquent` SET TAGS ('dbx_business_glossary_term' = 'Is Delinquent Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `late_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Installment Plan Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `number_of_installments` SET TAGS ('dbx_business_glossary_term' = 'Number of Installments');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'eft|credit_card|check|cash|payroll_deduction|escrow');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Installment Plan Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'active|completed|cancelled|suspended|defaulted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `reinstatement_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `total_fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Fees Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `total_plan_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Plan Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ALTER COLUMN `total_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` SET TAGS ('dbx_subdomain' = 'account_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `account_id` SET TAGS ('dbx_business_glossary_term' = 'Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_address_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Address Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `household_id` SET TAGS ('dbx_business_glossary_term' = 'Household Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `account_status` SET TAGS ('dbx_business_glossary_term' = 'Account Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `account_status` SET TAGS ('dbx_value_regex' = 'active|suspended|closed|delinquent|pending|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `account_type` SET TAGS ('dbx_business_glossary_term' = 'Account Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `account_type` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `auto_pay_enabled` SET TAGS ('dbx_business_glossary_term' = 'Auto Pay Enabled Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Billing Contact Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_email` SET TAGS ('dbx_business_glossary_term' = 'Billing Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Billing Frequency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|on_demand');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'invoice|automatic_payment|payroll_deduction|escrow|mortgagee_bill');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_phone` SET TAGS ('dbx_business_glossary_term' = 'Billing Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `billing_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `commission_payable_flag` SET TAGS ('dbx_business_glossary_term' = 'Commission Payable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `credit_balance` SET TAGS ('dbx_business_glossary_term' = 'Credit Balance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `current_balance` SET TAGS ('dbx_business_glossary_term' = 'Current Balance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `days_past_due` SET TAGS ('dbx_business_glossary_term' = 'Days Past Due');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `delinquency_status` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `delinquency_status` SET TAGS ('dbx_value_regex' = 'current|past_due_1_30|past_due_31_60|past_due_61_90|past_due_over_90|in_collections');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `last_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Last Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `last_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `next_invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Next Invoice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `next_payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Payment Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Account Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `outstanding_fees` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Fees');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `outstanding_premium` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `outstanding_taxes` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Taxes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `paperless_billing_flag` SET TAGS ('dbx_business_glossary_term' = 'Paperless Billing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'credit_card|debit_card|ach|check|wire_transfer|cash');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `payment_plan_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `payment_plan_type` SET TAGS ('dbx_value_regex' = 'full_pay|monthly|quarterly|semi_annual|installment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `unapplied_cash` SET TAGS ('dbx_business_glossary_term' = 'Unapplied Cash');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ALTER COLUMN `write_off_date` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` SET TAGS ('dbx_subdomain' = 'invoice_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `bill_to_party_id` SET TAGS ('dbx_business_glossary_term' = 'Bill To Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `policyholder_id` SET TAGS ('dbx_business_glossary_term' = 'Policyholder Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `risk_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Inspection Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `amount_paid` SET TAGS ('dbx_business_glossary_term' = 'Amount Paid');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `billing_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `billing_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `cancellation_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `delinquency_status` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `delinquency_status` SET TAGS ('dbx_value_regex' = 'current|grace_period|delinquent|notice_sent|cancellation_pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `invoice_description` SET TAGS ('dbx_business_glossary_term' = 'Invoice Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `installment_number` SET TAGS ('dbx_business_glossary_term' = 'Installment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `invoice_status` SET TAGS ('dbx_business_glossary_term' = 'Invoice Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `invoice_type` SET TAGS ('dbx_business_glossary_term' = 'Invoice Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Balance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `paid_date` SET TAGS ('dbx_business_glossary_term' = 'Paid Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `total_amount_due` SET TAGS ('dbx_business_glossary_term' = 'Total Amount Due');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `total_installments` SET TAGS ('dbx_business_glossary_term' = 'Total Installments');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `write_off_reason` SET TAGS ('dbx_business_glossary_term' = 'Write Off Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ALTER COLUMN `written_off_date` SET TAGS ('dbx_business_glossary_term' = 'Written Off Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` SET TAGS ('dbx_subdomain' = 'invoice_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `invoice_item_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Item Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `charge_id` SET TAGS ('dbx_business_glossary_term' = 'Charge Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `claim_expense_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Expense Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `driver_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `property_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Property Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `reinsurance_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recovery Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `reversed_item_invoice_item_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Item Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Claim Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `tax_levy_id` SET TAGS ('dbx_business_glossary_term' = 'Tax Levy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct|agency|list|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `installment_number` SET TAGS ('dbx_business_glossary_term' = 'Installment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `item_amount` SET TAGS ('dbx_business_glossary_term' = 'Item Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `item_category` SET TAGS ('dbx_business_glossary_term' = 'Item Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `item_code` SET TAGS ('dbx_business_glossary_term' = 'Item Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `item_description` SET TAGS ('dbx_business_glossary_term' = 'Item Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `item_type` SET TAGS ('dbx_business_glossary_term' = 'Item Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `item_type` SET TAGS ('dbx_value_regex' = 'premium|tax|fee|commission|adjustment|refund');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `line_number` SET TAGS ('dbx_business_glossary_term' = 'Line Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `outstanding_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `proration_factor` SET TAGS ('dbx_business_glossary_term' = 'Proration Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `proration_method` SET TAGS ('dbx_business_glossary_term' = 'Proration Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `proration_method` SET TAGS ('dbx_value_regex' = 'daily|monthly|short_rate|pro_rata|full_term');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Tax Jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `taxable_base_amount` SET TAGS ('dbx_business_glossary_term' = 'Taxable Base Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `waived_flag` SET TAGS ('dbx_business_glossary_term' = 'Waived Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` SET TAGS ('dbx_subdomain' = 'invoice_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `commission_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `payer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Payer Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `payment_method_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Method Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `ri_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Premium Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `applied_amount` SET TAGS ('dbx_business_glossary_term' = 'Applied Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `applied_date` SET TAGS ('dbx_business_glossary_term' = 'Applied Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `authorization_code` SET TAGS ('dbx_business_glossary_term' = 'Authorization Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `bank_account_last_four` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Last Four Digits');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `bank_account_last_four` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `bank_account_last_four` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `bank_account_last_four` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `card_last_four` SET TAGS ('dbx_business_glossary_term' = 'Card Last Four Digits');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `card_last_four` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `card_last_four` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `card_last_four` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `card_type` SET TAGS ('dbx_business_glossary_term' = 'Card Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `card_type` SET TAGS ('dbx_value_regex' = 'visa|mastercard|amex|discover');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Channel');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `channel` SET TAGS ('dbx_value_regex' = 'web|mobile_app|agent_portal|mail|phone|in_person');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Check Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Cleared Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `installment_number` SET TAGS ('dbx_business_glossary_term' = 'Installment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `is_returned` SET TAGS ('dbx_business_glossary_term' = 'Is Returned Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `nsf_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Non-Sufficient Funds (NSF) Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Payment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|applied|cleared|reversed|returned|voided');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_value_regex' = 'premium|down_payment|installment|reinstatement|endorsement|refund');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `processor` SET TAGS ('dbx_business_glossary_term' = 'Payment Processor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Receipt Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `receipt_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Receipt Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `return_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Return Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `return_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Return Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `returned_date` SET TAGS ('dbx_business_glossary_term' = 'Returned Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `reversal_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `reversed_date` SET TAGS ('dbx_business_glossary_term' = 'Reversed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Payment Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'policyholder|agency|third_party|escrow|reinsurer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ALTER COLUMN `unapplied_amount` SET TAGS ('dbx_business_glossary_term' = 'Unapplied Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` SET TAGS ('dbx_subdomain' = 'invoice_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `payment_application_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `installment_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `invoice_item_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Item Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `reversed_application_payment_application_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Payment Application Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `ri_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Recovery Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `allocation_priority` SET TAGS ('dbx_business_glossary_term' = 'Allocation Priority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `allocation_rule_code` SET TAGS ('dbx_business_glossary_term' = 'Allocation Rule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_method` SET TAGS ('dbx_value_regex' = 'automatic|manual|system_rule|batch|override');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_status` SET TAGS ('dbx_value_regex' = 'pending|posted|reversed|voided|cleared');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `application_type` SET TAGS ('dbx_value_regex' = 'applied|unapplied|suspense|reversal|adjustment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `applied_amount` SET TAGS ('dbx_business_glossary_term' = 'Applied Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Applied By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `commission_payable_flag` SET TAGS ('dbx_business_glossary_term' = 'Commission Payable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `delinquency_flag` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `installment_number` SET TAGS ('dbx_business_glossary_term' = 'Installment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Application Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `suspense_amount` SET TAGS ('dbx_business_glossary_term' = 'Suspense Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `suspense_cleared_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Suspense Cleared By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `suspense_cleared_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `suspense_cleared_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `suspense_cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Suspense Cleared Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `suspense_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Suspense Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `unapplied_amount` SET TAGS ('dbx_business_glossary_term' = 'Unapplied Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `write_off_flag` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ALTER COLUMN `write_off_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` SET TAGS ('dbx_subdomain' = 'installment_scheduling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `type_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `auto_pay_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto Pay Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `cancellation_short_rate_penalty_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Short Rate Penalty Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `payment_plan_description` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `display_order` SET TAGS ('dbx_business_glossary_term' = 'Display Order');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `down_payment_minimum_amount` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Minimum Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `down_payment_percentage` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `external_plan_code` SET TAGS ('dbx_business_glossary_term' = 'External Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `installment_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `installment_fee_percentage` SET TAGS ('dbx_business_glossary_term' = 'Installment Fee Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `installment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Installment Frequency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `installment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|bi_weekly');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `late_payment_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Payment Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `maximum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `number_of_installments` SET TAGS ('dbx_business_glossary_term' = 'Number of Installments');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `plan_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|archived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'installment|full_pay|recurring|custom');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `producer_commission_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Producer Commission Impact Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `reinstatement_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ALTER COLUMN `returned_payment_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Returned Payment Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` SET TAGS ('dbx_subdomain' = 'installment_scheduling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `installment_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Schedule ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `installment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Plan Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `auto_pay_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto Pay Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `billing_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `billing_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `delinquency_days` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `down_payment_flag` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `fee_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Allocation Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `final_installment_flag` SET TAGS ('dbx_business_glossary_term' = 'Final Installment Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `grace_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Grace Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `installment_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `installment_number` SET TAGS ('dbx_business_glossary_term' = 'Installment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `installment_status` SET TAGS ('dbx_business_glossary_term' = 'Installment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `installment_status` SET TAGS ('dbx_value_regex' = 'scheduled|due|paid|past_due|waived|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `late_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `notice_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Notice Sent Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `notice_type` SET TAGS ('dbx_business_glossary_term' = 'Notice Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `notice_type` SET TAGS ('dbx_value_regex' = 'reminder|first_notice|final_notice|cancellation_warning');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `outstanding_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `payment_channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Channel');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `payment_received_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `premium_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Allocation Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `returned_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Returned Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `returned_payment_flag` SET TAGS ('dbx_business_glossary_term' = 'Returned Payment Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `returned_payment_reason` SET TAGS ('dbx_business_glossary_term' = 'Returned Payment Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `scheduled_amount` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `scheduled_due_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `tax_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Allocation Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `waived_amount` SET TAGS ('dbx_business_glossary_term' = 'Waived Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` SET TAGS ('dbx_subdomain' = 'delinquency_workflow');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `delinquency_id` SET TAGS ('dbx_business_glossary_term' = 'Delinquency ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `contact_party_id` SET TAGS ('dbx_business_glossary_term' = 'Contact Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `installment_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Installment Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `assigned_collector_user_code` SET TAGS ('dbx_business_glossary_term' = 'Assigned Collector User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `assigned_collector_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `assigned_collector_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `cancellation_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `cancellation_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `collections_agency_flag` SET TAGS ('dbx_business_glossary_term' = 'Collections Agency Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `collections_agency_name` SET TAGS ('dbx_business_glossary_term' = 'Collections Agency Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `collections_agency_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `collections_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Collections Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `days_past_due` SET TAGS ('dbx_business_glossary_term' = 'Days Past Due');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `delinquency_status` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `first_missed_installment_date` SET TAGS ('dbx_business_glossary_term' = 'First Missed Installment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `first_notice_date` SET TAGS ('dbx_business_glossary_term' = 'First Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `grace_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Grace Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `last_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Last Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `late_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `notice_sent_count` SET TAGS ('dbx_business_glossary_term' = 'Notice Sent Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `past_due_amount` SET TAGS ('dbx_business_glossary_term' = 'Past Due Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `payment_plan_default_flag` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Default Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `reinstatement_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `resolution_method` SET TAGS ('dbx_business_glossary_term' = 'Resolution Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `resolution_method` SET TAGS ('dbx_value_regex' = 'payment_received|reinstated|cancelled|written_off|payment_plan_established');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `resolved_date` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Resolved Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `returned_payment_flag` SET TAGS ('dbx_business_glossary_term' = 'Returned Payment Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `returned_payment_reason` SET TAGS ('dbx_business_glossary_term' = 'Returned Payment Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Start Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `total_amount_due` SET TAGS ('dbx_business_glossary_term' = 'Total Amount Due');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `write_off_date` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ALTER COLUMN `write_off_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` SET TAGS ('dbx_subdomain' = 'delinquency_workflow');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `delinquency_action_id` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Action Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `delinquency_id` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Notice Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `reversed_action_delinquency_action_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Action Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_date` SET TAGS ('dbx_business_glossary_term' = 'Action Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_outcome_code` SET TAGS ('dbx_business_glossary_term' = 'Action Outcome Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_outcome_code` SET TAGS ('dbx_value_regex' = 'SUCCESS|PARTIAL|FAILED|PENDING|REVERSED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Action Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Action Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Action Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_status` SET TAGS ('dbx_business_glossary_term' = 'Action Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_status` SET TAGS ('dbx_value_regex' = 'PENDING|COMPLETED|FAILED|CANCELLED|REVERSED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Action Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_type_code` SET TAGS ('dbx_business_glossary_term' = 'Action Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `action_type_code` SET TAGS ('dbx_value_regex' = 'NOTICE|REMINDER|CANCELLATION|REINSTATEMENT|WRITEOFF|REFERRAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `cancellation_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `cancellation_type_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `collections_agency_code` SET TAGS ('dbx_business_glossary_term' = 'Collections Agency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `collections_referral_date` SET TAGS ('dbx_business_glossary_term' = 'Collections Referral Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `collections_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Collections Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `completed_date` SET TAGS ('dbx_business_glossary_term' = 'Completed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `grace_period_days` SET TAGS ('dbx_business_glossary_term' = 'Grace Period Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `grace_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Grace Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Initiated By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `regulatory_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `reinstatement_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Deadline Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `reinstatement_offered_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Offered Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ALTER COLUMN `write_off_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` SET TAGS ('dbx_subdomain' = 'invoice_processing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `disbursement_id` SET TAGS ('dbx_business_glossary_term' = 'Disbursement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `claim_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Claimant Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `commission_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `commission_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `litigation_id` SET TAGS ('dbx_business_glossary_term' = 'Litigation Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_address_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Address Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_party_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `reversed_disbursement_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Disbursement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `ri_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Premium Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `ri_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Recovery Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `salvage_id` SET TAGS ('dbx_business_glossary_term' = 'Salvage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `subrogation_id` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `check_number` SET TAGS ('dbx_business_glossary_term' = 'Check Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Cleared Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `commission_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `disbursement_date` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `disbursement_status` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `disbursement_status` SET TAGS ('dbx_value_regex' = 'pending|approved|issued|cleared|voided|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `disbursement_type` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Issued By User ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `issued_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_name` SET TAGS ('dbx_business_glossary_term' = 'Payee Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_business_glossary_term' = 'Payee Tax ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payee_tax_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'check|ach|wire|eft|card|cash');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `reversal_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Disbursement Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Void Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ALTER COLUMN `withheld_amount` SET TAGS ('dbx_business_glossary_term' = 'Withheld Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` SET TAGS ('dbx_subdomain' = 'account_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `payment_method_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Method Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `billing_address_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Address Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `billing_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `billing_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `autopay_enrollment_date` SET TAGS ('dbx_business_glossary_term' = 'Autopay Enrollment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_account_last_four` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Last Four Digits');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_account_last_four` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_account_last_four` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_account_last_four` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_value_regex' = 'checking|savings|business_checking|business_savings');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_account_type` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_name` SET TAGS ('dbx_business_glossary_term' = 'Bank Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Routing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `card_expiry_month` SET TAGS ('dbx_business_glossary_term' = 'Card Expiration Month');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `card_expiry_year` SET TAGS ('dbx_business_glossary_term' = 'Card Expiration Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `card_last_four` SET TAGS ('dbx_business_glossary_term' = 'Card Last Four Digits');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `card_last_four` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `card_last_four` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `card_last_four` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `card_type` SET TAGS ('dbx_business_glossary_term' = 'Credit Card Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `card_type` SET TAGS ('dbx_value_regex' = 'visa|mastercard|amex|discover|diners|jcb');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `cardholder_name` SET TAGS ('dbx_business_glossary_term' = 'Cardholder Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `cardholder_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `cardholder_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `eft_authorization_date` SET TAGS ('dbx_business_glossary_term' = 'Electronic Funds Transfer (EFT) Authorization Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `eft_authorization_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Funds Transfer (EFT) Authorization Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `eft_authorization_status` SET TAGS ('dbx_business_glossary_term' = 'Electronic Funds Transfer (EFT) Authorization Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `eft_authorization_status` SET TAGS ('dbx_value_regex' = 'authorized|pending|declined|revoked|expired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `is_autopay_enabled` SET TAGS ('dbx_business_glossary_term' = 'Is Autopay Enabled Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Is Default Payment Method Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `last_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Last Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `method_name` SET TAGS ('dbx_business_glossary_term' = 'Payment Method Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `method_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `method_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Method Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `method_status` SET TAGS ('dbx_value_regex' = 'active|inactive|expired|suspended|pending_verification|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `method_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Method Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `payment_token` SET TAGS ('dbx_business_glossary_term' = 'Payment Token');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `payment_token` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `payment_token` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `priority_rank` SET TAGS ('dbx_business_glossary_term' = 'Priority Rank');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `processor_merchant_code` SET TAGS ('dbx_business_glossary_term' = 'Processor Merchant Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `processor_name` SET TAGS ('dbx_business_glossary_term' = 'Payment Processor Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `processor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `updated_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `usage_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Usage Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'verified|pending|failed|not_required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` SET TAGS ('dbx_subdomain' = 'account_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `account_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Account Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `bill_to_party_id` SET TAGS ('dbx_business_glossary_term' = 'Bill To Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `policyholder_id` SET TAGS ('dbx_business_glossary_term' = 'Policyholder Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `added_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Added By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `added_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `added_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Allocation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'proportional|priority|equal|custom');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Payment Allocation Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `allocation_priority` SET TAGS ('dbx_business_glossary_term' = 'Payment Allocation Priority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `cancellation_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `cancellation_pending_flag` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Pending Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `commission_payable_flag` SET TAGS ('dbx_business_glossary_term' = 'Commission Payable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `consolidation_flag` SET TAGS ('dbx_business_glossary_term' = 'Multi-Policy Consolidation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `delinquency_flag` SET TAGS ('dbx_business_glossary_term' = 'Delinquency Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `installment_billing_flag` SET TAGS ('dbx_business_glossary_term' = 'Installment Billing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Account Policy Relationship Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Account Policy Relationship Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `relationship_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|terminated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Account Policy Relationship Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `relationship_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|consolidated|split');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `removed_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Removed By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `removed_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `removed_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `split_billing_flag` SET TAGS ('dbx_business_glossary_term' = 'Split Billing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `termination_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
