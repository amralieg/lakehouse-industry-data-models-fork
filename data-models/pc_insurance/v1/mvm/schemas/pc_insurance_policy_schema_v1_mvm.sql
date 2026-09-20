-- Schema for Domain: policy | Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:52

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`policy` COMMENT 'Authoritative record of the insurance contract lifecycle. Owns Policy (one row per policy), Policy Term (one row per policy per term), and Policy Transaction (NB, REN, END, CAN, RI, NR).';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` (
    `policy_id` BIGINT COMMENT 'Unique system identifier for the policy. Primary key. One row per policy.',
    `agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Agency-level book-of-business reporting, contingent commission calculations, and agency performance management require direct policy-to-agency attribution.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Underwriting accumulation management and reinsurance treaty attachment require linking each policy to its cat zone.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Policy issuance and premium booking require the governing commission schedule for producer compensation calculation and finance reconciliation.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Policies issued in multiple currencies require currency master reference for FX conversion, financial consolidation, and multi-currency premium reporting.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Distribution channel governs commission rates, regulatory surplus-lines filing requirements, and market segmentation reporting at the policy level.',
    `household_id` BIGINT COMMENT 'Foreign key linking to party.household. Business justification: Personal lines insurers aggregate all policies under a household for cross-sell, retention scoring, and multi-policy discount pricing.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Policy-level LOB classification drives Schedule P reporting, NAIC annual statement filings, and underwriting appetite controls.',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Policy-level territory assignment is used for premium rating, state regulatory reporting, and producer appointment validation.',
    `type_id` BIGINT COMMENT 'Foreign key linking to policy.policy_type. Business justification: Policy.type (STRING) currently stores policy type codes inline. Normalizing to policy_type reference table eliminates redundancy and enables centralized management of policy type',
    `underwriting_authority_id` BIGINT COMMENT 'Foreign key linking to producers.underwriting_authority. Business justification: E&O compliance and binding authority audits require recording which underwriting authority was in effect when a policy was bound.',
    `auto_renew_flag` BOOLEAN COMMENT 'Flag indicating whether the policy is set to automatically renew at expiration. True if auto-renew enabled.',
    `billing_method` STRING COMMENT 'Method by which premium is billed: direct bill, agency bill, list bill, or account current.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `binding_date` DATE COMMENT 'Date the policy was bound and coverage became contractually obligated.',
    `cancellation_date` DATE COMMENT 'Date the policy was cancelled, if applicable. Null if policy has not been cancelled.',
    `cancellation_reason_code` STRING COMMENT 'Reason for policy cancellation: non-payment, insured request, underwriting decision, fraud, material change, or non-renewal.. Valid values are `non_payment|insured_request|underwriting|fraud|material_change|non_renewal`',
    `carrier_code` STRING COMMENT 'Identifier for the insurance carrier or legal entity issuing the policy.',
    `commission_rate` DECIMAL(5,2) COMMENT 'Commission rate percentage paid to the producer on this policy. Expressed as a percentage.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the policy record was first created in the system.',
    `effective_date` DATE COMMENT 'Date from which the current policy version or transaction is in force. Used for effective dating and loss date reconstruction.',
    `expiration_date` DATE COMMENT 'Date the policy contract expires or is scheduled to expire. End of the current term.',
    `facultative_flag` BOOLEAN COMMENT 'Flag indicating whether facultative reinsurance was placed for this policy. True if facultative coverage exists.',
    `form_code` STRING COMMENT 'ISO or proprietary form code identifying the base policy contract form.',
    `inception_date` DATE COMMENT 'Date the policy contract first becomes effective. Start of the initial term.',
    `issue_date` DATE COMMENT 'Date the policy documents were issued to the policyholder.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the policy record was last modified in the system.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the legal entity issuing the policy.',
    `non_renewal_notice_date` DATE COMMENT 'Date non-renewal notice was sent to the policyholder, if applicable. Null if policy is renewing.',
    `non_renewal_reason_code` STRING COMMENT 'Reason for non-renewal: underwriting decision, loss history, non-payment, program exit, or regulatory requirement.. Valid values are `underwriting|loss_history|non_payment|program_exit|regulatory`',
    `number` STRING COMMENT 'Externally-known unique policy number assigned at issuance. Business identifier for the contract.',
    `payment_plan_code` STRING COMMENT 'Premium payment plan selected by the policyholder: full pay, monthly, quarterly, or semi-annual.. Valid values are `full_pay|monthly|quarterly|semi_annual`',
    `policy_status` STRING COMMENT 'Current lifecycle status of the policy contract. [ENUM-REF-CANDIDATE: draft|quoted|bound|in_force|cancelled|expired|non_renewed — 7 candidates stripped; promote to reference product]',
    `prior_policy_number` STRING COMMENT 'Policy number of the prior term if this is a renewal or rewrite. Null for new business.',
    `producer_code` STRING COMMENT 'Identifier for the producer (agent or broker) who sold the policy.',
    `program_code` STRING COMMENT 'Internal program or product line identifier under which the policy is written.',
    `quote_date` DATE COMMENT 'Date the initial quote was generated for this policy.',
    `reinsurance_treaty_code` STRING COMMENT 'Identifier for the reinsurance treaty under which this policy is ceded, if applicable.',
    `renewal_indicator` BOOLEAN COMMENT 'Flag indicating whether this policy is a renewal of a prior term. True if renewal, false if new business.',
    `risk_score` DECIMAL(5,2) COMMENT 'Numeric risk score assigned by underwriting or rating engine. Higher score indicates higher risk.',
    `state_code` STRING COMMENT 'Two-letter US state code where the policy is domiciled and regulated.',
    `submission_date` DATE COMMENT 'Date the risk submission was received for underwriting evaluation.',
    `term_months` BIGINT COMMENT 'Length of the policy term in months. Typically 12 for annual policies, 6 for semi-annual.',
    `total_insured_value` DECIMAL(15,2) COMMENT 'Total insured value across all coverages and insured risks on the policy. Sum of all limits.',
    `underwriting_tier` STRING COMMENT 'Risk tier assigned during underwriting: preferred, standard, non-standard, or declined.. Valid values are `preferred|standard|non_standard|declined`',
    `written_premium_amount` DECIMAL(15,2) COMMENT 'Total written premium for the policy term. Gross premium before adjustments.',
    CONSTRAINT pk_policy PRIMARY KEY(`policy_id`)
) COMMENT 'Grain: one row per policy. Each record represents a single insurance policy contract identified by policy_id.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` (
    `term_id` BIGINT COMMENT 'Unique identifier for the policy term. Primary key. One row per policy per term.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency representing the producer. Used for agency-level commission and reporting.',
    `calendar_id` BIGINT COMMENT 'Foreign key linking to shared.calendar. Business justification: Policy terms must map to accounting periods for premium earning calculations, reserve valuations, and GAAP/SAP financial statement preparation.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Policy terms track written premium in transaction currency—FK to currency master required for FX conversion to functional currency, multi-currency financial reporting, and consolidation.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Distribution channel can change at renewal (e.g., direct to agency). Term-level channel tracking is required for renewal performance reporting and commission schedule selection',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Policy terms require geography linkage for underwriting territory assignment, rate filing compliance by jurisdiction, exposure aggregation for catastrophe modeling, and',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Policy term is the grain for earned premium and loss ratio reporting by LOB in NAIC Schedule P and statutory filings.',
    `loss_event_id` BIGINT COMMENT 'Foreign key linking to claims.loss_event. Business justification: Loss events occur during policy terms; underwriting renewal decisions, loss ratio analysis, and experience rating require linking loss history to the term in force at loss occurrence date.',
    `party_id` BIGINT COMMENT 'Foreign key to the underwriter who approved this term. Links to party role for underwriter.',
    `policy_id` BIGINT COMMENT 'Foreign key to the parent policy. Links this term to the overarching policy lifecycle.',
    `prior_term_id` BIGINT COMMENT 'Foreign key to the immediately preceding term. Null for new business, populated for renewals.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key to the producer who sold this term. Links to producer for commission calculation.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Each policy term is the direct product of binding a specific quote. Renewal pricing, re-rating audits, and regulatory rate filings require linking the term to the quote that produced it.',
    `type_id` BIGINT COMMENT 'Foreign key linking to policy.policy_type. Business justification: Term.product_code and product_name currently store policy type information redundantly at the term level.',
    `accident_year` BIGINT COMMENT 'Accident year for loss reserving and IBNR calculation. Derived from term effective date.',
    `accounting_date` DATE COMMENT 'Date when the term was recorded in the accounting system. Used for financial reporting cutoffs.',
    `billing_method` STRING COMMENT 'Method by which premium is billed and collected. Determines billing workflow and commission settlement.. Valid values are `direct_bill|agency_bill|list_bill|account_current`',
    `bound_date` DATE COMMENT 'Date when the term was bound and coverage became contractually effective.',
    `calendar_year` BIGINT COMMENT 'Calendar year for statutory and financial reporting. Derived from term effective date.',
    `cancellation_date` DATE COMMENT 'Date when the term was cancelled. Null if term was not cancelled. Used for earned premium calculation.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason for term cancellation. Examples: non-payment, insured request, underwriting.',
    `cancellation_type` STRING COMMENT 'Type of cancellation determining premium return calculation. Flat, short-rate, or pro-rata.. Valid values are `flat|short_rate|pro_rata`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this term record was first created in the system. Audit trail for data lineage.',
    `duration_days` BIGINT COMMENT 'Number of days between term effective and expiration dates. Typically 365 for annual policies.',
    `effective_date` DATE COMMENT 'Date when this policy term becomes effective and coverage begins.',
    `expiration_date` DATE COMMENT 'Date when this policy term expires and coverage ends. Nullable for open-ended terms.',
    `inception_date` DATE COMMENT 'Original inception date of the first term of the policy. Carried forward across all renewals.',
    `is_renewal` BOOLEAN COMMENT 'Indicates whether this term is a renewal of a prior term. False for new business, true for renewals.',
    `issued_date` DATE COMMENT 'Date when the policy documents for this term were issued to the insured.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this term record was last updated. Audit trail for change tracking.',
    `non_renewal_notice_date` DATE COMMENT 'Date when non-renewal notice was sent to the insured. Required by state law for non-renewals.',
    `non_renewal_reason_code` STRING COMMENT 'Code indicating the reason for non-renewal. Must comply with state-specific non-renewal regulations.',
    `number` BIGINT COMMENT 'Sequential term number within the policy lifecycle. First term is 1, increments with each renewal.',
    `payment_plan_code` STRING COMMENT 'Code identifying the premium payment plan. Examples: annual, semi-annual, quarterly, monthly.',
    `policy_year` BIGINT COMMENT 'Policy year for actuarial and loss reserving analysis. Derived from term effective date.',
    `rate_effective_date` DATE COMMENT 'Effective date of the rate table used to price this term. Required for regulatory rate filings.',
    `rate_version` STRING COMMENT 'Version identifier of the rating algorithm used to price this term. Enables rate change analysis.',
    `reinstatement_date` DATE COMMENT 'Date when a cancelled term was reinstated. Null if term was never reinstated.',
    `renewal_accepted_date` DATE COMMENT 'Date when the insured accepted the renewal offer. Null if renewal was not accepted.',
    `renewal_offer_date` DATE COMMENT 'Date when renewal offer was extended to the insured. Used for renewal cycle tracking.',
    `renewal_type` STRING COMMENT 'Classification of the renewal process. Indicates whether renewal was automatic, manual, or conditional.. Valid values are `automatic|manual|conditional|non_renewed`',
    `term_status` STRING COMMENT 'Current lifecycle status of the policy term. Indicates whether the term is active, expired, or cancelled.. Valid values are `in_force|expired|cancelled|non_renewed|pending|bound`',
    `underwriting_company_code` STRING COMMENT 'NAIC company code of the insurer underwriting this term. Used for statutory reporting.',
    `underwriting_company_name` STRING COMMENT 'Legal name of the insurance company underwriting this term.',
    `written_premium_amount` DECIMAL(18,2) COMMENT 'Total written premium for this term. Represents the full premium charged for the term period.',
    CONSTRAINT pk_term PRIMARY KEY(`term_id`)
) COMMENT 'Grain: one row per policy per term. Each record represents a single time-bounded period within a policy lifecycle.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` (
    `policy_transaction_id` BIGINT COMMENT 'Unique identifier for the policy transaction. Primary key. One row per transaction event applied to a policy term.',
    `accounting_period_id` BIGINT COMMENT 'Foreign key linking to claimfinancials.accounting_period. Business justification: Every policy transaction (new business, endorsement, cancellation, reinstatement) must be booked to an accounting period for written/earned premium accounting, statutory',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Post-catastrophe moratoriums, reinstatements, and cancellation holds are policy transactions triggered by specific cat events.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Endorsement and cancellation transactions generate commission impacts (commission_impact_amount).',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Transactions record premium changes in transaction currency—FK to currency master enables FX translation for accounting entries, multi-currency GL posting, and audit trails.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: Surplus lines regulatory filings and commission impact calculations on transactions depend on distribution channel.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Endorsement processing and regulatory audit trails require recording which insured risk was added, removed, or modified by each policy transaction.',
    `party_id` BIGINT COMMENT 'Reference to the underwriter who approved or processed this transaction. Links to party role for audit and workflow tracking.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy contract. Links this transaction to the overarching policy lifecycle.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term period affected by this transaction.',
    `primary_prior_transaction_policy_transaction_id` BIGINT COMMENT 'Reference to the immediately preceding transaction in the policy lifecycle. Enables transaction chain reconstruction.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent of record at the time of this transaction. Used for commission calculation and distribution tracking.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Endorsement and mid-term change transactions originate from re-quotes. Linking the transaction to its driving quote supports endorsement premium audit, commission recalculation, and regulatory',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Transactions requiring underwriting approval (endorsements, reinstatements) must reference the authorizing UW decision for authority-level audit and E&O compliance.',
    `accounting_date` DATE COMMENT 'Date when the transaction is recognized for accounting and statutory reporting purposes. May differ from effective and processed dates.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when the transaction was approved. Distinct from processed and effective timestamps.',
    `cancellation_basis` STRING COMMENT 'Legal or business basis for cancellation. Determines regulatory notice requirements and return premium method. Null for non-cancellation transactions.. Valid values are `insured_request|non_payment|underwriting|fraud|material_misrepresentation|`',
    `cancellation_type_code` STRING COMMENT 'Method used to calculate return premium for cancellations: flat (no return), short_rate (penalty), pro_rata (proportional). Null for non-cancellation transactions.. Valid values are `flat|short_rate|pro_rata|`',
    `commission_impact_amount` DECIMAL(15,2) COMMENT 'Net change in producer commission resulting from this transaction. Used for commission settlement and payables.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this transaction record was first created in the system. Audit trail for record lifecycle.',
    `document_reference_number` STRING COMMENT 'Reference to the generated policy document, declarations page, or endorsement form associated with this transaction.',
    `effective_date` DATE COMMENT 'Date when the transaction becomes effective and changes take effect on the policy. Critical for loss date reconstruction.',
    `endorsement_description` STRING COMMENT 'Business description of the endorsement changes. Summarizes coverage, limit, or risk modifications. Null for non-endorsement transactions.',
    `endorsement_form_number` STRING COMMENT 'ISO or proprietary form number attached to this endorsement transaction. Null for non-endorsement transactions.',
    `expiration_date` DATE COMMENT 'Date when the transaction or its effects expire. Applicable for term-bounded endorsements or temporary changes.',
    `is_backdated_flag` BOOLEAN COMMENT 'Indicates whether the effective date is prior to the processed date. Used for audit and compliance monitoring.',
    `is_midterm_flag` BOOLEAN COMMENT 'Indicates whether this transaction occurred mid-term (between policy inception and expiration). True for endorsements, cancellations, reinstatements.',
    `is_renewal_flag` BOOLEAN COMMENT 'Indicates whether this transaction represents a policy renewal. True for REN transaction type, false otherwise.',
    `issued_timestamp` TIMESTAMP COMMENT 'Date and time when the transaction was issued and documents were generated. Marks final commitment.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this transaction record was last updated. Audit trail for record lifecycle.',
    `policy_year` BIGINT COMMENT 'Policy year in which this transaction occurred. Used for loss ratio analysis and actuarial reserving by policy year cohort.',
    `processed_date` DATE COMMENT 'Date when the transaction was processed and recorded in the system. May differ from effective date.',
    `reason_code` STRING COMMENT 'Standardized code indicating the business reason for the transaction. Type-specific: endorsement reason, cancellation cause, reinstatement justification.',
    `reason_description` STRING COMMENT 'Detailed narrative explanation of why the transaction was initiated. Supplements the reason code with context.',
    `regulatory_filing_date` DATE COMMENT 'Date when regulatory filing was submitted. Null if no filing required or not yet filed.',
    `regulatory_filing_required_flag` BOOLEAN COMMENT 'Indicates whether this transaction requires filing with state Department of Insurance or other regulatory body.',
    `reinstatement_lapse_days` BIGINT COMMENT 'Number of days the policy was lapsed before reinstatement. Used for underwriting and pricing adjustments. Null for non-reinstatement transactions.',
    `reinsurance_cession_required_flag` BOOLEAN COMMENT 'Indicates whether this transaction triggers reinsurance cession under treaty or facultative agreements.',
    `requires_underwriting_review_flag` BOOLEAN COMMENT 'Indicates whether this transaction triggered underwriting referral or manual review based on risk appetite rules.',
    `source_system_code` STRING COMMENT 'Code identifying the originating system for this transaction. Supports multi-system integration and data lineage.',
    `transaction_number` STRING COMMENT 'Business-facing transaction number displayed on declarations pages and endorsements. Externally visible identifier.',
    `transaction_status` STRING COMMENT 'Current workflow status of the transaction. Tracks progression from draft through issuance or reversal.. Valid values are `draft|pending|approved|issued|voided|reversed`',
    `type_code` STRING COMMENT 'Governed enumeration of the policy transaction type. Allowed values: New Business, Renewal, Endorsement, Cancellation, Reinstatement, Non-renewal. Satisfies VREQ-003.. Valid values are `^(New Business|Renewal|Endorsement|Cancellation|Reinstatement|Non-renewal)$`',
    `voided_reason_code` STRING COMMENT 'Standardized code indicating why the transaction was voided. Null for active transactions.',
    `voided_timestamp` TIMESTAMP COMMENT 'Date and time when the transaction was voided or reversed. Null for active transactions.',
    `written_premium_change_amount` DECIMAL(15,2) COMMENT 'Net change in written premium resulting from this transaction. Positive for increases, negative for returns. Used for premium accounting and statutory reporting.',
    CONSTRAINT pk_policy_transaction PRIMARY KEY(`policy_transaction_id`)
) COMMENT 'One row per policy transaction. Records every lifecycle event: New Business, Renewal, Endorsement, Cancellation, Reinstatement, Non-renewal. Effective-dated so in-force state is reconstructable at any point in time.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` (
    `policyholder_id` BIGINT COMMENT 'Unique identifier for the policyholder data product (auto-inserted during validation).',
    `party_id` BIGINT COMMENT 'Reference to the party acting as policyholder or named insured on this policy.',
    `policy_id` BIGINT COMMENT 'Reference to the policy contract to which this policyholder is associated.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: Policyholders can change by term (named insured changes on renewal, ownership transfers). The effective_date and expiration_date attributes on policyholder indicate term-level tracking is needed.',
    `policyholder_policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction that added this policyholder to the policy.',
    `policyholder_removed_by_transaction_policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction that removed this policyholder from the policy. Null if still active.',
    `role_id` BIGINT COMMENT 'Reference to the specific party role record capturing the policyholder relationship with effective dates.',
    `billing_responsibility_flag` BOOLEAN COMMENT 'Indicates whether this policyholder is responsible for premium payment. True if responsible, false otherwise.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason this policyholder association was cancelled or removed from the policy.',
    `certificate_holder_flag` BOOLEAN COMMENT 'Indicates whether this party should receive a Certificate of Insurance. True if certificate holder, false otherwise.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this policyholder record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when this policyholder association becomes active and binding on the policy contract.',
    `expiration_date` DATE COMMENT 'Date when this policyholder association ends. Null for open-ended associations.',
    `holder_sequence` BIGINT COMMENT 'Ordinal position of this policyholder within the policy, used for display and reporting order.',
    `holder_type` STRING COMMENT 'Classification of the policyholder role on the policy contract.. Valid values are `Named Insured|Additional Insured|Additional Interest|Loss Payee|Mortgagee|Lienholder`',
    `interest_type` STRING COMMENT 'Nature of the insurable interest this party holds in the covered risk or property. [ENUM-REF-CANDIDATE: Owner|Lessee|Mortgagee|Lienholder|Bailee|Trustee|Other — 7 candidates stripped; promote to reference product]',
    `is_primary_insured` BOOLEAN COMMENT 'Indicates whether this party is the primary named insured on the policy. True if primary, false otherwise.',
    `loan_number` STRING COMMENT 'Loan or mortgage account number associated with this policyholder when acting as mortgagee or lienholder.',
    `loss_payable_clause_type` STRING COMMENT 'Type of loss payable clause governing payment priority and rights for this policyholder.. Valid values are `Standard Mortgagee|Loss Payee|Lender Loss Payee|Contract of Sale|None`',
    `mailing_address_same_as_primary_flag` BOOLEAN COMMENT 'Indicates whether this policyholder uses the same mailing address as the primary insured. True if same, false otherwise.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this policyholder record was last modified in the system.',
    `notice_required_flag` BOOLEAN COMMENT 'Indicates whether this party must receive policy notices such as cancellation or non-renewal. True if required, false otherwise.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of ownership or interest this policyholder has in the insured risk. Null if not applicable.',
    `policyholder_status` STRING COMMENT 'Current lifecycle status of this policyholder association on the policy contract.. Valid values are `Active|Expired|Cancelled|Pending|Suspended`',
    `rank_order` BIGINT COMMENT 'Priority ranking for loss payment when multiple loss payees or mortgagees exist. Lower numbers indicate higher priority.',
    `relationship_to_primary` STRING COMMENT 'Nature of the relationship between this policyholder and the primary named insured. [ENUM-REF-CANDIDATE: Spouse|Domestic Partner|Child|Parent|Sibling|Business Partner|Landlord|Tenant|Contractor|Vendor|Other — 11 candidates stripped; promote to reference',
    `remarks` STRING COMMENT 'Free-form notes or special instructions related to this policyholder association.',
    `waiver_of_subrogation_flag` BOOLEAN COMMENT 'Indicates whether the insurer has waived subrogation rights against this party. True if waived, false otherwise.',
    CONSTRAINT pk_policyholder PRIMARY KEY(`policyholder_id`)
) COMMENT 'One row per party-policy holder assignment. Links party.role to a policy and term with effective dating, holder type, interest type, billing responsibility, and waiver of subrogation. Supports multiple named insureds.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` (
    `interest_id` BIGINT COMMENT 'Unique identifier for the additional interest record. Primary key.',
    `building_id` BIGINT COMMENT 'Foreign key linking to riskexposure.building. Business justification: Commercial property mortgagees and loss payees attach at building-level granularity for multi-building locations.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Loss payees, mortgagees, and additional insureds attach to specific coverages (e.g., a lender on auto physical damage only).',
    `location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.location. Business justification: Certificate of insurance issuance and loss payee notification workflows require tracking mortgagee/lienholder interests at the location level (e.g., blanket interests covering all',
    `party_id` BIGINT COMMENT 'Reference to the party who holds this interest on the policy.',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: policy_interest already links to term (which carries policy_id), but all peer child tables (line, fee, state_reg, policy_document, policyholder) carry a direct policy_id for efficient',
    `policy_term_id` BIGINT COMMENT 'Reference to the policy term to which this interest is attached.',
    `primary_policy_transaction_id` BIGINT COMMENT 'Reference to the policy transaction that added this interest to the policy term.',
    `property_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.property_risk. Business justification: Mortgagees, loss payees, and additional insureds attach to specific commercial properties for loss payment routing, subrogation waiver, and certificate issuance.',
    `vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.vehicle. Business justification: Lienholders and lessors attach to specific financed or leased vehicles for loss payee endorsements and total loss settlement.',
    `address_line_1` STRING COMMENT 'Primary street address of the interest holder for certificate mailing and notification purposes.',
    `address_line_2` STRING COMMENT 'Secondary address line for suite, unit, or building information.',
    `blanket_additional_insured_flag` BOOLEAN COMMENT 'Indicates whether the interest is covered under a blanket additional insured endorsement.',
    `certificate_issue_date` DATE COMMENT 'Date the certificate of insurance was issued to the interest holder.',
    `certificate_number` STRING COMMENT 'Certificate number issued to the interest holder as evidence of coverage.',
    `city` STRING COMMENT 'City of the interest holders mailing address.',
    `contact_email` STRING COMMENT 'Email address for the interest holder contact for certificate delivery and notifications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_name` STRING COMMENT 'Name of the primary contact person at the interest holder organization for policy and certificate matters.',
    `contact_phone` STRING COMMENT 'Primary phone number for the interest holder contact.',
    `country_code` STRING COMMENT 'Three-letter ISO country code for the interest holders address.. Valid values are `USA|CAN|MEX`',
    `coverage_scope` STRING COMMENT 'Description of the scope of coverage provided to the interest holder, including any limitations or conditions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this interest record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when the interest becomes effective on the policy term.',
    `endorsement_form_number` STRING COMMENT 'ISO or carrier-specific form number of the endorsement that adds this interest to the policy.',
    `expiration_date` DATE COMMENT 'Date when the interest expires or is removed from the policy term. Nullable for open-ended interests.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this interest record was last updated.',
    `loan_number` STRING COMMENT 'Loan or mortgage account number associated with the interest, typically for mortgagees or lienholders.',
    `notification_days` BIGINT COMMENT 'Number of days advance notice required for policy changes or cancellations, typically 10, 30, or 60 days.',
    `notification_required_flag` BOOLEAN COMMENT 'Indicates whether the interest holder must be notified of policy changes, cancellations, or non-renewals.',
    `policy_interest_name` STRING COMMENT 'Full legal name of the party holding the interest as it appears on the policy or certificate.',
    `policy_interest_status` STRING COMMENT 'Current lifecycle status of the interest on the policy.. Valid values are `active|inactive|pending|cancelled`',
    `postal_code` STRING COMMENT 'Postal or ZIP code for the interest holders mailing address.',
    `primary_noncontributory_flag` BOOLEAN COMMENT 'Indicates whether coverage is primary and non-contributory with respect to the interest holders own insurance.',
    `rank_order` BIGINT COMMENT 'Priority ranking of the interest for loss payment purposes. Lower numbers indicate higher priority.',
    `remarks` STRING COMMENT 'Free-form notes or special instructions related to the interest holder, coverage requirements, or certificate issuance.',
    `state_province_code` STRING COMMENT 'Two-letter state or province code for the interest holders address.',
    `type_code` STRING COMMENT 'Type of interest: Additional Insured (AI), Loss Payee (LP), Mortgagee (MORT), Lienholder (LIEN), Lessor, Trustee.. Valid values are `AI|LP|MORT|LIEN|LESSOR|TRUSTEE`',
    `waiver_of_subrogation_flag` BOOLEAN COMMENT 'Indicates whether the insurer has waived subrogation rights against the interest holder.',
    CONSTRAINT pk_interest PRIMARY KEY(`interest_id`)
) COMMENT 'One row per additional interest on a policy term (mortgagee, lienholder, certificate holder). Links party, policy term, and insured risk with effective dating, coverage scope, and notification requirements.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` (
    `form_id` BIGINT COMMENT 'Unique identifier for the policy form attachment record. Primary key.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Endorsement and exclusion forms attach to specific coverages, not just the policy. Regulatory form filing, claims coverage determination, and ISO form tracking all require the',
    `document_id` BIGINT COMMENT 'Reference to the physical or digital document storage location for the form PDF or image.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: ISO and state-specific forms are organized and filed by LOB. Form attachment validation, regulatory form filing, and form library management all require LOB classification.',
    `policy_id` BIGINT COMMENT 'Foreign key linking to policy.policy. Business justification: policy_form links to term and policy_document but lacks a direct policy_id FK. Every other child table in this domain (line, fee, state_reg, policy_document, policyholder) carries a direct',
    `policy_term_id` BIGINT COMMENT 'Reference to the policy term to which this form is attached.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Forms are attached to a policy via a specific transaction (New Business, Endorsement, Renewal).',
    `acord_form_flag` BOOLEAN COMMENT 'Indicates whether this is a standard ACORD form (true) or not (false).',
    `approval_date` DATE COMMENT 'The date the form was approved by the state Department of Insurance for use.',
    `attachment_reason_code` STRING COMMENT 'Coded reason for attaching this form: regulatory requirement, risk mitigation, customer request, underwriting referral, rate modification, or coverage enhancement.. Valid values are `regulatory_requirement|risk_mitigation|customer_request|underwriting_referral|rate_modification|coverage_enhancement`',
    `attachment_sequence` BIGINT COMMENT 'The order in which this form is attached to the policy term, used for precedence and document assembly.',
    `form_category` STRING COMMENT 'High-level category of the form indicating the major coverage area it addresses. [ENUM-REF-CANDIDATE: coverage|liability|property|auto|workers_comp|umbrella|inland_marine|crime|professional_liability — 9 candidates stripped; promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time this form attachment record was first created in the system.',
    `form_description` STRING COMMENT 'Detailed description of the coverage, exclusion, or condition provided by this form.',
    `edition_date` DATE COMMENT 'The edition date of the form as published by ISO or the carrier, indicating the version in use.',
    `effective_date` DATE COMMENT 'The date this form attachment becomes effective on the policy term.',
    `expiration_date` DATE COMMENT 'The date this form attachment expires or is removed from the policy term. Null if still in force.',
    `filing_number` STRING COMMENT 'The state Department of Insurance filing number or SERFF tracking number for this form.',
    `form_number` STRING COMMENT 'The ISO or ACORD form number identifying the specific form or endorsement (e.g., HO-3, CA 00 01, CG 00 01).',
    `form_status` STRING COMMENT 'Current status of the form attachment: active, superseded by a newer edition, withdrawn, or pending approval.. Valid values are `active|superseded|withdrawn|pending_approval`',
    `form_type` STRING COMMENT 'Classification of the form: base policy form, endorsement, exclusion, condition, declaration page, schedule, or certificate of insurance. [ENUM-REF-CANDIDATE: base|endorsement|exclusion|condition|declaration|schedule|certificate — 7 candidates stripped',
    `iso_form_flag` BOOLEAN COMMENT 'Indicates whether this is a standard ISO form (true) or a carrier-proprietary form (false).',
    `language` STRING COMMENT 'The language in which the form is written (e.g., English, Spanish, French).',
    `mandatory_flag` BOOLEAN COMMENT 'Indicates whether this form is mandatory per state filing or carrier underwriting rules (true) or optional (false).',
    `modified_timestamp` TIMESTAMP COMMENT 'The date and time this form attachment record was last modified.',
    `form_name` STRING COMMENT 'The full descriptive name of the form (e.g., Homeowners 3 Special Form, Commercial General Liability Coverage Form).',
    `premium_amount` DECIMAL(15,2) COMMENT 'The additional premium amount charged for this form attachment, if premium-bearing.',
    `premium_bearing_flag` BOOLEAN COMMENT 'Indicates whether this form attachment carries an additional premium charge (true) or is included at no charge (false).',
    `state_code` STRING COMMENT 'Two-letter state code where this form is filed and approved for use (e.g., CA, TX, NY).',
    `superseded_by_form_number` STRING COMMENT 'The form number that supersedes this form, if the form has been replaced by a newer edition.',
    `transaction_effective_date` DATE COMMENT 'The effective date of the policy transaction that attached or modified this form.',
    `transaction_type` STRING COMMENT 'The policy transaction type that triggered this form attachment (NB, REN, END, CAN, RI).. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement`',
    `underwriter_notes` STRING COMMENT 'Free-text notes from the underwriter regarding the reason for attaching this form or special considerations.',
    `version` STRING COMMENT 'Internal version identifier for carrier-proprietary forms, tracking revisions and updates.',
    CONSTRAINT pk_form PRIMARY KEY(`form_id`)
) COMMENT 'One row per form attached to a policy term. Tracks ISO/ACORD form number, edition date, state filing, mandatory flag, premium-bearing flag, and attachment sequence. Links to policy document for the physical artifact.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` (
    `line_id` BIGINT COMMENT 'Primary key for line',
    `line_of_business_id` BIGINT COMMENT 'Unique identifier for the line of business within a policy term. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Per-LOB cat zone assignment drives line-level accumulation tracking, reinsurance cession calculations, and bordereaux reporting.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Underwriting premium allocation and exposure aggregation reports require linking each coverage line directly to the insured risk it rates against.',
    `location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.location. Business justification: Catastrophe exposure aggregation and PML reporting require summing written premium and TIV by location.',
    `party_id` BIGINT COMMENT 'Foreign key to the underwriter who evaluated and approved this line of business.',
    `policy_id` BIGINT COMMENT 'Foreign key to the parent policy record.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term under which this line of business is written.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Line records are created and modified by policy transactions (NB creates lines, endorsements modify coverage/limits/premium).',
    `territory_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.territory. Business justification: Territory drives rating loss costs, base rates, and regulatory rate filings at the line-of-business level.',
    `aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount for this line of business based on catastrophe modeling.',
    `ceded_percentage` DECIMAL(5,2) COMMENT 'Percentage of premium and risk ceded to reinsurers for this line of business under quota share treaties.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Coinsurance percentage applicable to this line of business, representing the insureds share of covered losses.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this line of business record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Standard deductible amount applicable to this line of business. May be overridden at coverage or risk level.',
    `endorsements_attached` STRING COMMENT 'Comma-separated list of endorsement form numbers modifying coverage for this line of business.',
    `experience_mod_factor` DECIMAL(5,4) COMMENT 'Experience modification factor applied to adjust premium based on the insureds historical loss experience. Common in Workers Compensation and Commercial Auto.',
    `forms_attached` STRING COMMENT 'Comma-separated list of ISO or proprietary form numbers attached to this line of business.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this line of business record was last modified.',
    `lob_code` STRING COMMENT 'Standard code identifying the line of business. Examples: HO (Homeowners), PAP (Personal Auto Policy), CGL (Commercial General Liability), WC (Workers Compensation), BOP (Business Owners Policy).',
    `lob_effective_date` DATE COMMENT 'Date when this line of business coverage becomes effective within the policy term.',
    `lob_expiration_date` DATE COMMENT 'Date when this line of business coverage expires within the policy term.',
    `lob_name` STRING COMMENT 'Full descriptive name of the line of business.',
    `lob_status` STRING COMMENT 'Current lifecycle status of this line of business within the policy term.. Valid values are `active|cancelled|expired|suspended|pending`',
    `loss_ratio_target` DECIMAL(5,2) COMMENT 'Target loss ratio for this line of business used in pricing and profitability analysis.',
    `naic_lob_code` STRING COMMENT 'NAIC statutory reporting code for the line of business used in Schedule P and statutory financial statements.',
    `naics_code` STRING COMMENT 'NAICS code for the insured business or risk under this line of business.',
    `package_discount_percentage` DECIMAL(5,2) COMMENT 'Discount percentage applied to this line of business when written as part of a package policy.',
    `package_indicator` BOOLEAN COMMENT 'Indicates whether this line of business is part of a multi-line package policy such as CPP or BOP.',
    `pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for this line of business under catastrophe scenarios.',
    `policy_limit_amount` DECIMAL(18,2) COMMENT 'Maximum aggregate limit of liability for this line of business across all coverages within the policy term.',
    `premium_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the written premium amount.. Valid values are `^[A-Z]{3}$`',
    `program_code` STRING COMMENT 'Internal program or product offering code under which this line of business is written. Used for rate table and underwriting rule selection.',
    `program_name` STRING COMMENT 'Descriptive name of the program or product offering.',
    `rate_basis` STRING COMMENT 'Unit of measure used as the basis for premium rating. Examples: per $1000 of coverage, per vehicle, per employee, per square foot.',
    `rate_factor` DECIMAL(10,6) COMMENT 'Base rate factor applied to the rate basis to calculate premium for this line of business.',
    `reinsurance_treaty_code` STRING COMMENT 'Code identifying the reinsurance treaty under which this line of business is ceded.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Self-insured retention amount for this line of business, applicable before policy coverage attaches.',
    `schedule_credit_percentage` DECIMAL(5,2) COMMENT 'Underwriter-applied schedule credit percentage for this line of business based on risk characteristics.',
    `schedule_debit_percentage` DECIMAL(5,2) COMMENT 'Underwriter-applied schedule debit percentage for this line of business based on adverse risk characteristics.',
    `sic_code` STRING COMMENT 'Standard Industrial Classification code for the insured business or risk under this line of business.',
    `sub_line_code` STRING COMMENT 'Sub-line or product variant code within the primary line of business for granular classification.',
    `sub_line_name` STRING COMMENT 'Descriptive name of the sub-line or product variant.',
    `tiv_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the total insured value amount.. Valid values are `^[A-Z]{3}$`',
    `total_insured_value_amount` DECIMAL(18,2) COMMENT 'Total insured value or sum insured for all risks covered under this line of business. Used for catastrophe exposure aggregation and PML modeling.',
    `underwriting_tier` STRING COMMENT 'Underwriting tier assigned to this line of business based on risk evaluation.. Valid values are `preferred|standard|substandard|declined`',
    `written_premium_amount` DECIMAL(18,2) COMMENT 'Total written premium amount for this line of business within the policy term. Used for statutory Schedule P reporting and premium allocation.',
    CONSTRAINT pk_line PRIMARY KEY(`line_id`)
) COMMENT 'One row per line of business per policy term. Captures LOB-level underwriting attributes: TIV, policy limit, deductible, rate factor, reinsurance treaty, CAT zone, and written premium. Child of policy term.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` (
    `policy_producer_id` BIGINT COMMENT 'Unique identifier for the policy producer association record.',
    `agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Commission statements and agency performance reports require knowing which agency each policy_producer record belongs to.',
    `commission_schedule_id` BIGINT COMMENT 'Foreign key linking to producers.commission_schedule. Business justification: Commission statement reconciliation requires knowing which schedule governs each producer-policy relationship.',
    `distribution_channel_id` BIGINT COMMENT 'Foreign key linking to producers.distribution_channel. Business justification: The producer-policy relationship is channel-specific (e.g., independent agent vs. direct).',
    `license_id` BIGINT COMMENT 'Foreign key linking to party.license. Business justification: Regulatory compliance requires verifying the writing producer held an active, state-appropriate license at policy binding. State DOI audits and E&O reviews depend on this link.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy record this producer is associated with.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the specific policy term this producer association applies to.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Producer assignments on a policy are created or modified by specific lifecycle transactions (New Business binding, mid-term endorsement adding a co-producer, cancellation removing a',
    `producer_appointment_id` BIGINT COMMENT 'Foreign key linking to producers.producer_appointment. Business justification: State DOI regulatory audits require insurers to verify that the producer held a valid carrier appointment when each policy was written.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key to the producer party record representing the agent or broker.',
    `appointment_date` DATE COMMENT 'Date the producer was appointed by the carrier to sell this line of business.',
    `appointment_status` STRING COMMENT 'Current status of the producers appointment with the carrier for this policy.. Valid values are `active|terminated|suspended|pending`',
    `commission_payable_flag` BOOLEAN COMMENT 'Indicates whether commission is payable to this producer for this policy.',
    `commission_rate` DECIMAL(5,2) COMMENT 'Base commission rate percentage applied to premium for this producer.',
    `contact_name` STRING COMMENT 'Name of the individual producer or primary contact at the agency for this policy.',
    `contingent_commission_eligible_flag` BOOLEAN COMMENT 'Indicates whether this producer is eligible for contingent or profit-sharing commission on this policy.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy producer association record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when this producer association became effective for the policy.',
    `email` STRING COMMENT 'Primary email address for the producer contact for policy communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `eo_coverage_verified_flag` BOOLEAN COMMENT 'Indicates whether the producers E&O insurance coverage has been verified for this policy.',
    `eo_expiration_date` DATE COMMENT 'Expiration date of the producers E&O insurance coverage.',
    `eo_policy_number` STRING COMMENT 'Policy number of the producers E&O insurance coverage on file.',
    `expiration_date` DATE COMMENT 'Date when this producer association expires or was terminated.',
    `lob_authority` STRING COMMENT 'Specific lines of business the producer is authorized to write under this association.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy producer association record was last modified.',
    `notes` STRING COMMENT 'Free-form notes or comments regarding this producer association or special arrangements.',
    `npn` STRING COMMENT 'Ten-digit unique identifier assigned by NIPR to licensed insurance producers.. Valid values are `^[0-9]{10}$`',
    `of_record_flag` BOOLEAN COMMENT 'Indicates whether this producer is the official producer of record for the policy.',
    `override_rate` DECIMAL(5,2) COMMENT 'Additional override commission rate for managing general agents or agency principals.',
    `phone` STRING COMMENT 'Primary phone number for the producer contact for policy communications.',
    `producer_tier` STRING COMMENT 'Performance tier classification affecting commission rates and incentives.. Valid values are `platinum|gold|silver|bronze|standard`',
    `referral_source` STRING COMMENT 'Description of how this producer sourced or was referred to this policy opportunity.',
    `role_type` STRING COMMENT 'Classification of the producers role on this policy.. Valid values are `primary|co-producer|servicing|referral|broker_of_record`',
    `servicing_office_code` STRING COMMENT 'Internal code identifying the carrier office or region servicing this producer relationship.',
    `servicing_rights_flag` BOOLEAN COMMENT 'Indicates whether this producer retains servicing rights for the policy.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system that originated this policy producer association record.',
    `split_percentage` DECIMAL(5,2) COMMENT 'Percentage of commission allocated to this producer when multiple producers share commission.',
    `termination_date` DATE COMMENT 'Date the producers appointment with the carrier was terminated.',
    `termination_reason_code` STRING COMMENT 'Code indicating the reason for termination of the producer appointment.. Valid values are `voluntary|for_cause|non_production|license_lapse|regulatory|merger`',
    `writing_company_code` STRING COMMENT 'NAIC company code of the carrier entity this producer represents for this policy.',
    CONSTRAINT pk_policy_producer PRIMARY KEY(`policy_producer_id`)
) COMMENT 'One row per producer-policy assignment. Links producer to policy and term with role type, commission rate, split percentage, license details, and servicing rights. Supports multi-producer and split-commission scenarios.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` (
    `type_id` BIGINT COMMENT 'Unique identifier for the policy_type data product (auto-inserted during validation).',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Policy types are defined within LOBs (e.g., HO-3 belongs to Homeowners LOB). LOB-level product management, minimum premium rules, and reinsurance eligibility all depend on this',
    `acord_form_number` STRING COMMENT 'ACORD standard form number used for applications or certificates for this policy type (e.g., ACORD 125, ACORD 140).. Valid values are `^ACORD [0-9]{2,4}$`',
    `cancellation_allowed_flag` BOOLEAN COMMENT 'Indicates whether policies of this type can be cancelled mid-term by the insurer or insured.',
    `cat_exposure_flag` BOOLEAN COMMENT 'Indicates whether policies of this type carry catastrophe exposure requiring CAT modeling and aggregation.',
    `type_code` STRING COMMENT 'Short alphanumeric code identifying the policy type (e.g., HO3, PAP, BOP, CGL). Used for system integration and reporting.. Valid values are `^[A-Z0-9]{2,10}$`',
    `coverage_basis` STRING COMMENT 'Trigger basis for coverage (Occurrence, Claims-Made, Claims-Made and Reported). Determines when a loss must occur or be reported to be covered.. Valid values are `Occurrence|Claims-Made|Claims-Made and Reported`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy type record was first created in the system.',
    `deductible_required_flag` BOOLEAN COMMENT 'Indicates whether a deductible is required for policies of this type.',
    `type_description` STRING COMMENT 'Detailed description of the policy type, including coverage scope, target market, and key features.',
    `effective_date` DATE COMMENT 'Date when this policy type became available for new business.',
    `endorsement_allowed_flag` BOOLEAN COMMENT 'Indicates whether mid-term endorsements are allowed for this policy type.',
    `expiration_date` DATE COMMENT 'Date when this policy type was discontinued or will be discontinued. Null if still active.',
    `iso_program_code` STRING COMMENT 'ISO program identifier for standardized forms and rating (e.g., HO for Homeowners, CA for Commercial Auto).. Valid values are `^[A-Z0-9]{2,8}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy type record was last modified.',
    `limit_required_flag` BOOLEAN COMMENT 'Indicates whether coverage limits must be specified for policies of this type.',
    `maximum_premium_amount` DECIMAL(15,2) COMMENT 'Maximum premium amount allowed for policies of this type, in USD. Null if no maximum.',
    `minimum_premium_amount` DECIMAL(15,2) COMMENT 'Minimum premium amount required for policies of this type, in USD.',
    `monoline_package_indicator` STRING COMMENT 'Indicates whether the policy type is a monoline (single coverage) or package (multiple coverages bundled) policy.. Valid values are `Monoline|Package`',
    `type_name` STRING COMMENT 'Full business name of the policy type (e.g., Homeowners Special Form, Personal Auto Policy, Business Owners Policy).',
    `personal_commercial_flag` BOOLEAN COMMENT 'Indicates whether the policy type is for personal lines or commercial lines business.',
    `policy_term_length_months` BIGINT COMMENT 'Standard term length in months for this policy type (e.g., 12 for annual, 6 for semi-annual).',
    `policy_type_status` STRING COMMENT 'Current lifecycle status of the policy type. Active types are available for new business.. Valid values are `Active|Inactive|Discontinued|Pending Approval`',
    `producer_commission_schedule_code` STRING COMMENT 'Default commission schedule code for producers selling this policy type.. Valid values are `^[A-Z0-9]{2,10}$`',
    `rating_algorithm_version` STRING COMMENT 'Version identifier of the rating algorithm or pricing model used for this policy type.. Valid values are `^[A-Z0-9._-]{1,20}$`',
    `reinstatement_allowed_flag` BOOLEAN COMMENT 'Indicates whether cancelled policies of this type can be reinstated within a grace period.',
    `reinsurance_eligible_flag` BOOLEAN COMMENT 'Indicates whether policies of this type are eligible for reinsurance cession under treaty or facultative agreements.',
    `renewal_eligible_flag` BOOLEAN COMMENT 'Indicates whether policies of this type are eligible for renewal. False for non-renewable policy types.',
    `risk_appetite_score` DECIMAL(5,2) COMMENT 'Numeric score representing the companys risk appetite for this policy type (0-100 scale). Higher scores indicate greater appetite.',
    `state_filing_required_flag` BOOLEAN COMMENT 'Indicates whether rates and forms for this policy type require state Department of Insurance filing and approval.',
    `target_loss_ratio_percent` DECIMAL(5,2) COMMENT 'Target loss ratio percentage for this policy type, used for pricing and profitability analysis.',
    `underwriting_tier_count` BIGINT COMMENT 'Number of underwriting tiers or risk classes available for this policy type (e.g., Preferred, Standard, Non-Standard).',
    CONSTRAINT pk_type PRIMARY KEY(`type_id`)
) COMMENT 'One row per policy type definition (reference/lookup). Defines LOB category, term length, minimum/maximum premium, rating algorithm version, reinsurance eligibility, and state filing requirements.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` (
    `state_reg_id` BIGINT COMMENT 'Unique identifier for the state regulatory record. Primary key.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: State regulatory records (mandatory PIP, UM/UIM requirements, financial responsibility filings) attach to specific coverages.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: State regulatory filings require geography linkage for jurisdiction-specific compliance reporting, rate filing territorial analysis, and DOI submission by geographic hierarchy.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: State regulatory filings, DOI compliance, and NAIC annual statement exhibits are organized by line of business.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy this state regulatory record applies to.',
    `policy_term_id` BIGINT COMMENT 'Foreign key linking to policy.term. Business justification: State regulatory attributes vary by term in P&C operations (admitted status can change on renewal, stamping fees are per-term).',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: State regulatory attributes are established and modified by policy transactions (admitted status declared at NB, surplus lines stamping occurs at issuance, state tax rates can',
    `admitted_status` STRING COMMENT 'Indicates whether the policy is written on an admitted or surplus lines basis in this state.. Valid values are `admitted|surplus_lines|non_admitted`',
    `assigned_risk_pool_indicator` BOOLEAN COMMENT 'Indicates whether this policy is written through a state-mandated assigned risk pool or residual market mechanism.',
    `assigned_risk_pool_name` STRING COMMENT 'Name of the assigned risk pool or residual market facility through which the policy is written.',
    `compliance_notes` STRING COMMENT 'Free-text notes regarding regulatory compliance issues, exceptions, or special handling for this policy.',
    `compliance_review_date` DATE COMMENT 'Date of the most recent regulatory compliance review for this policy.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this state regulatory record was first created in the system.',
    `doi_filing_number` STRING COMMENT 'State Department of Insurance filing or approval number for the policy form or rate filing.',
    `effective_date` DATE COMMENT 'Date when this state regulatory record becomes effective for the policy.',
    `expiration_date` DATE COMMENT 'Date when this state regulatory record expires or is superseded.',
    `fair_plan_indicator` BOOLEAN COMMENT 'Indicates whether this policy is written through a state FAIR plan for high-risk properties.',
    `fair_plan_name` STRING COMMENT 'Name of the FAIR plan facility through which the policy is written, if applicable.',
    `financial_responsibility_filing_date` DATE COMMENT 'Date the financial responsibility filing was submitted to the state.',
    `financial_responsibility_filing_indicator` BOOLEAN COMMENT 'Indicates whether a financial responsibility filing (e.g., SR-22, FR-44) is required for this policy.',
    `financial_responsibility_filing_type` STRING COMMENT 'Type of financial responsibility filing required by the state (e.g., SR-22, FR-44).. Valid values are `SR-22|FR-44|SR-50|SR-1P|none`',
    `guaranty_fund_assessment_amount` DECIMAL(15,2) COMMENT 'Total state guaranty fund assessment collected for this policy, in USD.',
    `guaranty_fund_assessment_rate` DECIMAL(5,4) COMMENT 'State guaranty fund assessment rate applicable to this policy, expressed as a decimal.',
    `iso_form_edition_date` DATE COMMENT 'Edition date of the ISO standard form used for this policy, if applicable.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this state regulatory record was last updated.',
    `minimum_liability_limit_required` DECIMAL(15,2) COMMENT 'State-mandated minimum liability limit required for this line of business, in USD.',
    `municipal_tax_amount` DECIMAL(15,2) COMMENT 'Total municipal or local premium tax amount collected for this policy, in USD.',
    `municipal_tax_rate` DECIMAL(5,4) COMMENT 'Municipal or local premium tax rate applicable to this policy, expressed as a decimal.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code identifying the insurer writing this policy in this state.. Valid values are `^[0-9]{5}$`',
    `regulatory_compliance_status` STRING COMMENT 'Current compliance status of this policy with state regulatory requirements.. Valid values are `compliant|non_compliant|pending_review|exempt`',
    `stamping_fee_amount` DECIMAL(15,2) COMMENT 'Fee charged by the stamping office for processing the surplus lines filing, in USD.',
    `stamping_office_filing_number` STRING COMMENT 'Filing or stamp number assigned by the surplus lines stamping office for this policy.',
    `state_form_number` STRING COMMENT 'State-specific policy form number or edition approved for use in this jurisdiction.',
    `state_mandated_coverage_indicator` BOOLEAN COMMENT 'Indicates whether this policy includes state-mandated coverage requirements specific to this jurisdiction.',
    `state_mandated_coverage_list` STRING COMMENT 'Comma-separated list of state-mandated coverages included in this policy (e.g., uninsured motorist, personal injury protection).',
    `state_reporting_code` STRING COMMENT 'State-specific reporting code used for statutory financial reporting and NAIC Annual Statement preparation.',
    `state_specific_endorsement_list` STRING COMMENT 'Comma-separated list of state-specific endorsements attached to this policy.',
    `state_tax_amount` DECIMAL(15,2) COMMENT 'Total state premium tax amount collected for this policy, in USD.',
    `state_tax_rate` DECIMAL(5,4) COMMENT 'State premium tax rate applicable to this policy, expressed as a decimal (e.g., 0.0250 for 2.5%).',
    `surplus_lines_stamping_office` STRING COMMENT 'Name of the surplus lines stamping office or service office that processed the filing, if applicable.',
    CONSTRAINT pk_state_reg PRIMARY KEY(`state_reg_id`)
) COMMENT 'One row per state regulatory record per policy transaction. Captures admitted status, DOI filing, surplus lines stamping, state/municipal tax amounts, guaranty fund assessments, and mandated coverage indicators.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` (
    `fee_id` BIGINT COMMENT 'Unique identifier for the fee record. Primary key.',
    `accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this fee is recognized for financial reporting.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Inspection fees, stamping fees, and coverage-specific surcharges are allocated to individual coverages for accurate premium accounting and regulatory remittance.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Fees denominated in multiple currencies require proper foreign exchange handling, financial consolidation, and regulatory reporting in functional currency.',
    `original_fee_id` BIGINT COMMENT 'Foreign key to the original fee record that this record reverses, if this is a reversal transaction.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy to which this fee applies.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this fee was assessed.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key to the policy transaction that triggered this fee (New Business, Renewal, Endorsement, Cancellation, Reinstatement).',
    `amount` DECIMAL(15,2) COMMENT 'Monetary amount of the fee assessed, in the policy currency.',
    `billing_method_code` STRING COMMENT 'Code indicating the billing method under which this fee is collected: direct bill, agency bill, list bill, or account current.. Valid values are `DIRECT_BILL|AGENCY_BILL|LIST_BILL|ACCOUNT_CURRENT`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this fee record was first created in the data warehouse.',
    `fee_description` STRING COMMENT 'Detailed description of the fee, including the reason for assessment and any relevant context.',
    `effective_date` DATE COMMENT 'Date on which the fee becomes effective and is applied to the policy.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this fee is posted for statutory and GAAP accounting.',
    `inspection_bureau_code` STRING COMMENT 'Code identifying the inspection bureau to which inspection fees are remitted.',
    `installment_number` BIGINT COMMENT 'Installment sequence number for installment fees, indicating which payment installment this fee applies to.',
    `payment_plan_code` STRING COMMENT 'Code identifying the payment plan under which this fee is assessed, relevant for installment fees.',
    `refund_date` DATE COMMENT 'Date on which the fee was refunded, if applicable.',
    `refund_reason_code` STRING COMMENT 'Code indicating the reason the fee was refunded, if applicable.. Valid values are `POLICY_CANCELLATION|BILLING_ERROR|CUSTOMER_REQUEST|REGULATORY_REQUIREMENT|OVERPAYMENT`',
    `refunded_flag` BOOLEAN COMMENT 'Indicates whether this fee was refunded to the policyholder. True if refunded, False otherwise.',
    `remittance_destination_code` STRING COMMENT 'Code indicating the entity to which this fee must be remitted: carrier, state Department of Insurance, surplus lines stamping office, inspection bureau, or third party.. Valid values are `CARRIER|STATE_DOI|SURPLUS_LINES_OFFICE|INSPECTION_BUREAU|THIRD_PARTY`',
    `remittance_payee_name` STRING COMMENT 'Name of the entity or organization to which the fee is remitted.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this fee record is a reversal of a previously recorded fee. True if reversal, False otherwise.',
    `reversal_reason_code` STRING COMMENT 'Code indicating the reason this fee was reversed, if applicable.. Valid values are `POLICY_VOID|TRANSACTION_CORRECTION|SYSTEM_ERROR|UNDERWRITING_CHANGE|BILLING_ADJUSTMENT`',
    `source_system_code` STRING COMMENT 'Code identifying the source system that originated this fee record (e.g., PolicyCenter, Duck Creek Policy, Rating Engine).',
    `source_system_fee_code` STRING COMMENT 'Unique identifier for this fee in the source system, used for reconciliation and traceability.',
    `state_code` STRING COMMENT 'Two-letter US state or Canadian province code where the fee applies, relevant for surplus lines and stamping fees.. Valid values are `^[A-Z]{2}$`',
    `surplus_lines_stamping_office_code` STRING COMMENT 'Code identifying the surplus lines stamping office to which surplus lines fees are remitted.',
    `taxable_flag` BOOLEAN COMMENT 'Indicates whether this fee is subject to sales tax or other levies. True if taxable, False otherwise.',
    `transaction_date` DATE COMMENT 'Date on which the fee transaction was recorded in the system.',
    `type_code` STRING COMMENT 'Code representing the type of fee assessed: policy fee, inspection fee, installment fee, surplus lines tax, stamping fee, or late payment fee.. Valid values are `POLICY|INSPECTION|INSTALLMENT|SURPLUS_LINES|STAMPING|LATE_PAYMENT`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this fee record was last updated in the data warehouse.',
    `waived_flag` BOOLEAN COMMENT 'Indicates whether this fee was waived by underwriting or management. True if waived, False otherwise.',
    `waiver_authorized_by` STRING COMMENT 'Name or identifier of the person who authorized the fee waiver.',
    `waiver_reason_code` STRING COMMENT 'Code indicating the reason the fee was waived, if applicable.. Valid values are `CUSTOMER_RETENTION|UNDERWRITING_DISCRETION|BILLING_ERROR|REGULATORY_EXEMPTION|PROMOTIONAL`',
    CONSTRAINT pk_fee PRIMARY KEY(`fee_id`)
) COMMENT 'One row per fee transaction on a policy. Records policy fee, inspection fee, installment fee, and similar charges with amount, type, accounting period, GL account, and refund/waiver tracking.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` (
    `document_id` BIGINT COMMENT 'Unique identifier for the policy document record. Primary key. One row per document generated at a policy transaction.',
    `binder_id` BIGINT COMMENT 'Foreign key linking to coverage.binder. Business justification: Binder documents are a specific document type issued before the formal policy. Linking policy_document to the binder it represents supports binder document retrieval, regulatory',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Coverage-specific endorsement documents, certificates of insurance for specific coverages, and coverage declination notices must be linked to the coverage they govern.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy for which this document was generated.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this document was issued.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key to the policy transaction that triggered document generation (New Business, Renewal, Endorsement, Cancellation, Reinstatement).',
    `recipient_party_id` BIGINT COMMENT 'Foreign key to the party who is the intended recipient of this document (policyholder, named insured, additional insured, loss payee, etc.).',
    `recipient_party_role_id` BIGINT COMMENT 'Foreign key to the party role of the recipient at the time of document issuance.',
    `superseded_document_policy_document_id` BIGINT COMMENT 'Foreign key to the prior document that this document replaces or supersedes, if applicable.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this document record was first created in the system.',
    `delivery_confirmation_flag` BOOLEAN COMMENT 'Indicates whether delivery confirmation was received from the recipient (True) or not (False).',
    `delivery_confirmation_timestamp` TIMESTAMP COMMENT 'Date and time when delivery confirmation was received, if applicable.',
    `delivery_date` DATE COMMENT 'Date the document was delivered or sent to the recipient.',
    `delivery_method` STRING COMMENT 'Method by which the document was delivered to the policyholder or recipient.. Valid values are `mail|email|portal|fax|in_person|electronic_delivery`',
    `document_description` STRING COMMENT 'Detailed description of the document content, purpose, or summary of changes for endorsements.',
    `document_number` STRING COMMENT 'Business-facing unique document number or control number assigned to this document for tracking and reference.',
    `document_status` STRING COMMENT 'Current lifecycle status of the document in the document management workflow. [ENUM-REF-CANDIDATE: draft|pending_approval|approved|issued|delivered|voided|superseded|archived — 8 candidates stripped; promote to reference product]',
    `document_type` STRING COMMENT 'Type of policy document issued. [ENUM-REF-CANDIDATE',
    `effective_date` DATE COMMENT 'Date from which the terms and conditions documented in this record become binding or enforceable.',
    `expiration_date` DATE COMMENT 'Date on which the document or the coverage it represents expires or is no longer valid.',
    `file_format` STRING COMMENT 'File format of the stored document (e.g., PDF, DOCX, HTML).. Valid values are `pdf|docx|html|xml|txt|tiff`',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes.',
    `form_code` STRING COMMENT 'ISO or carrier-specific form code identifying the standard form template used for this document (e.g., ACORD 125, ISO HO-3).',
    `form_edition_date` DATE COMMENT 'Edition date of the form template used, indicating the version of the standard form applied.',
    `generation_timestamp` TIMESTAMP COMMENT 'Date and time when the document was generated by the policy administration or document management system.',
    `hash` STRING COMMENT 'Cryptographic hash (e.g., SHA-256) of the document file for integrity verification and tamper detection.',
    `issue_date` DATE COMMENT 'Official date the document was issued or became effective for business purposes.',
    `language_code` STRING COMMENT 'ISO 639-1 two-letter language code indicating the language in which the document was generated.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this document record was last modified or updated.',
    `page_count` BIGINT COMMENT 'Total number of pages in the generated document.',
    `recipient_address_line1` STRING COMMENT 'First line of the mailing address to which the document was sent.',
    `recipient_address_line2` STRING COMMENT 'Second line of the mailing address (suite, apartment, etc.).',
    `recipient_city` STRING COMMENT 'City of the recipient mailing address.',
    `recipient_country_code` STRING COMMENT 'Three-letter ISO country code of the recipient mailing address.',
    `recipient_email` STRING COMMENT 'Email address to which the document was sent, if delivered electronically.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `recipient_name` STRING COMMENT 'Name of the recipient as it appears on the document for delivery purposes.',
    `recipient_postal_code` STRING COMMENT 'Postal or ZIP code of the recipient mailing address.',
    `recipient_state_code` STRING COMMENT 'Two-letter state or province code of the recipient mailing address.',
    `regulatory_filing_reference` STRING COMMENT 'Reference number or identifier of the regulatory filing or approval associated with this document form.',
    `regulatory_required_flag` BOOLEAN COMMENT 'Indicates whether this document is required by state or federal regulation (True) or is optional/carrier-initiated (False).',
    `state_code` STRING COMMENT 'Two-letter state code for the jurisdiction under which this document was issued and must comply.',
    `storage_location_uri` STRING COMMENT 'URI or path to the document file in the document management system or content repository.',
    `subtype` STRING COMMENT 'Further classification of the document type, such as specific endorsement form code or notice category.',
    `template_version` STRING COMMENT 'Version number of the document template used at the time of generation.',
    `title` STRING COMMENT 'Human-readable title or name of the document as it appears on the document itself.',
    `void_date` DATE COMMENT 'Date on which the document was voided, if applicable.',
    `void_flag` BOOLEAN COMMENT 'Indicates whether this document has been voided and is no longer valid (True) or remains valid (False).',
    `void_reason_code` STRING COMMENT 'Code indicating the reason the document was voided (e.g., error, reissue, policy cancellation).',
    CONSTRAINT pk_document PRIMARY KEY(`document_id`)
) COMMENT 'One row per policy document issued. Tracks document type, delivery method, recipient party, delivery confirmation, storage URI, and supersession chain. Links to policy, term, and transaction for full audit trail.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_type_id` FOREIGN KEY (`type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`type`(`type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_prior_term_id` FOREIGN KEY (`prior_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_type_id` FOREIGN KEY (`type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`type`(`type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_primary_prior_transaction_policy_transaction_id` FOREIGN KEY (`primary_prior_transaction_policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ADD CONSTRAINT `fk_policy_policyholder_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ADD CONSTRAINT `fk_policy_policyholder_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ADD CONSTRAINT `fk_policy_policyholder_policyholder_policy_transaction_id` FOREIGN KEY (`policyholder_policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ADD CONSTRAINT `fk_policy_policyholder_policyholder_removed_by_transaction_policy_transaction_id` FOREIGN KEY (`policyholder_removed_by_transaction_policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_primary_policy_transaction_id` FOREIGN KEY (`primary_policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ADD CONSTRAINT `fk_policy_form_document_id` FOREIGN KEY (`document_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`document`(`document_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ADD CONSTRAINT `fk_policy_form_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ADD CONSTRAINT `fk_policy_form_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ADD CONSTRAINT `fk_policy_form_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ADD CONSTRAINT `fk_policy_state_reg_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ADD CONSTRAINT `fk_policy_state_reg_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ADD CONSTRAINT `fk_policy_state_reg_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_original_fee_id` FOREIGN KEY (`original_fee_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`fee`(`fee_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_superseded_document_policy_document_id` FOREIGN KEY (`superseded_document_policy_document_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`document`(`document_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`policy` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`policy` SET TAGS ('dbx_domain' = 'policy');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` SET TAGS ('dbx_subdomain' = 'contract_lifecycle');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `household_id` SET TAGS ('dbx_business_glossary_term' = 'Household Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `type_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `underwriting_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Authority Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `auto_renew_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto Renew Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `binding_date` SET TAGS ('dbx_business_glossary_term' = 'Binding Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = 'non_payment|insured_request|underwriting|fraud|material_change|non_renewal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `carrier_code` SET TAGS ('dbx_business_glossary_term' = 'Carrier Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Current Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `facultative_flag` SET TAGS ('dbx_business_glossary_term' = 'Facultative Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `form_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Inception Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `non_renewal_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Renewal Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `non_renewal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Non-Renewal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `non_renewal_reason_code` SET TAGS ('dbx_value_regex' = 'underwriting|loss_history|non_payment|program_exit|regulatory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_value_regex' = 'full_pay|monthly|quarterly|semi_annual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_business_glossary_term' = 'Policy Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `producer_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `program_code` SET TAGS ('dbx_business_glossary_term' = 'Program Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `quote_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `reinsurance_treaty_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `renewal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Renewal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `term_months` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `total_insured_value` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` SET TAGS ('dbx_subdomain' = 'contract_lifecycle');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `loss_event_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `prior_term_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `type_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `accounting_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct_bill|agency_bill|list_bill|account_current');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `bound_date` SET TAGS ('dbx_business_glossary_term' = 'Bound Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `calendar_year` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year (CY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_value_regex' = 'flat|short_rate|pro_rata');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `duration_days` SET TAGS ('dbx_business_glossary_term' = 'Term Duration in Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Term Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Term Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Inception Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `is_renewal` SET TAGS ('dbx_business_glossary_term' = 'Renewal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `issued_date` SET TAGS ('dbx_business_glossary_term' = 'Issued Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `non_renewal_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Renewal (NR) Notice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `non_renewal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Non-Renewal (NR) Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Term Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `rate_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `rate_version` SET TAGS ('dbx_business_glossary_term' = 'Rate Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement (RI) Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `renewal_accepted_date` SET TAGS ('dbx_business_glossary_term' = 'Renewal Accepted Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `renewal_offer_date` SET TAGS ('dbx_business_glossary_term' = 'Renewal Offer Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `renewal_type` SET TAGS ('dbx_business_glossary_term' = 'Renewal Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `renewal_type` SET TAGS ('dbx_value_regex' = 'automatic|manual|conditional|non_renewed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `term_status` SET TAGS ('dbx_business_glossary_term' = 'Term Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `term_status` SET TAGS ('dbx_value_regex' = 'in_force|expired|cancelled|non_renewed|pending|bound');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `underwriting_company_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `underwriting_company_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Company Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `underwriting_company_name` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` SET TAGS ('dbx_subdomain' = 'contract_lifecycle');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `primary_prior_transaction_policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `accounting_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approved Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `cancellation_basis` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `cancellation_basis` SET TAGS ('dbx_value_regex' = 'insured_request|non_payment|underwriting|fraud|material_misrepresentation|');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `cancellation_type_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `cancellation_type_code` SET TAGS ('dbx_value_regex' = 'flat|short_rate|pro_rata|');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `commission_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Impact Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `document_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `endorsement_description` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `endorsement_form_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `is_backdated_flag` SET TAGS ('dbx_business_glossary_term' = 'Is Backdated Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `is_midterm_flag` SET TAGS ('dbx_business_glossary_term' = 'Is Midterm Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `is_renewal_flag` SET TAGS ('dbx_business_glossary_term' = 'Is Renewal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `issued_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Issued Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `processed_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Processed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reason Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `regulatory_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `regulatory_filing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `reinstatement_lapse_days` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Lapse Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `reinsurance_cession_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Cession Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `requires_underwriting_review_flag` SET TAGS ('dbx_business_glossary_term' = 'Requires Underwriting Review Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Transaction Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'draft|pending|approved|issued|voided|reversed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = '^(New Business|Renewal|Endorsement|Cancellation|Reinstatement|Non-renewal)$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `voided_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Voided Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `voided_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Voided Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ALTER COLUMN `written_premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Change Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` SET TAGS ('dbx_subdomain' = 'party_assignment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `policyholder_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for policyholder');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `policyholder_policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Added by Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `policyholder_removed_by_transaction_policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Removed by Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `role_id` SET TAGS ('dbx_business_glossary_term' = 'Party Role ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `billing_responsibility_flag` SET TAGS ('dbx_business_glossary_term' = 'Billing Responsibility Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `certificate_holder_flag` SET TAGS ('dbx_business_glossary_term' = 'Certificate Holder Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `holder_sequence` SET TAGS ('dbx_business_glossary_term' = 'Policyholder Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `holder_type` SET TAGS ('dbx_business_glossary_term' = 'Policyholder Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `holder_type` SET TAGS ('dbx_value_regex' = 'Named Insured|Additional Insured|Additional Interest|Loss Payee|Mortgagee|Lienholder');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `interest_type` SET TAGS ('dbx_business_glossary_term' = 'Insurable Interest Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `is_primary_insured` SET TAGS ('dbx_business_glossary_term' = 'Primary Insured Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `loan_number` SET TAGS ('dbx_business_glossary_term' = 'Loan Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `loan_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `loss_payable_clause_type` SET TAGS ('dbx_business_glossary_term' = 'Loss Payable Clause Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `loss_payable_clause_type` SET TAGS ('dbx_value_regex' = 'Standard Mortgagee|Loss Payee|Lender Loss Payee|Contract of Sale|None');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `mailing_address_same_as_primary_flag` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Same as Primary Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `mailing_address_same_as_primary_flag` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `mailing_address_same_as_primary_flag` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `notice_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Notice Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `policyholder_status` SET TAGS ('dbx_business_glossary_term' = 'Policyholder Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `policyholder_status` SET TAGS ('dbx_value_regex' = 'Active|Expired|Cancelled|Pending|Suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `rank_order` SET TAGS ('dbx_business_glossary_term' = 'Rank Order');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `relationship_to_primary` SET TAGS ('dbx_business_glossary_term' = 'Relationship to Primary Insured');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Policyholder Remarks');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ALTER COLUMN `waiver_of_subrogation_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Subrogation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` SET TAGS ('dbx_subdomain' = 'party_assignment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `interest_id` SET TAGS ('dbx_business_glossary_term' = 'Interest Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `building_id` SET TAGS ('dbx_business_glossary_term' = 'Building Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `primary_policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Added By Policy Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `property_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Property Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `address_line_1` SET TAGS ('dbx_business_glossary_term' = 'Interest Holder Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `address_line_2` SET TAGS ('dbx_business_glossary_term' = 'Interest Holder Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `blanket_additional_insured_flag` SET TAGS ('dbx_business_glossary_term' = 'Blanket Additional Insured Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `certificate_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance (COI) Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Interest Holder City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Interest Contact Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_name` SET TAGS ('dbx_business_glossary_term' = 'Interest Contact Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Interest Contact Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = 'USA|CAN|MEX');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_business_glossary_term' = 'Coverage Scope Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Interest Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `endorsement_form_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Interest Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `loan_number` SET TAGS ('dbx_business_glossary_term' = 'Loan or Mortgage Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `notification_days` SET TAGS ('dbx_business_glossary_term' = 'Notification Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `notification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Notification Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `policy_interest_name` SET TAGS ('dbx_business_glossary_term' = 'Interest Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `policy_interest_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `policy_interest_status` SET TAGS ('dbx_business_glossary_term' = 'Interest Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `policy_interest_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `primary_noncontributory_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary and Non-Contributory Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `rank_order` SET TAGS ('dbx_business_glossary_term' = 'Interest Rank Order');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Interest Remarks');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `state_province_code` SET TAGS ('dbx_business_glossary_term' = 'State or Province Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `state_province_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Interest Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = 'AI|LP|MORT|LIEN|LESSOR|TRUSTEE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ALTER COLUMN `waiver_of_subrogation_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Subrogation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` SET TAGS ('dbx_subdomain' = 'product_configuration');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `document_id` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `acord_form_flag` SET TAGS ('dbx_business_glossary_term' = 'Association for Cooperative Operations Research and Development (ACORD) Form Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `attachment_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Attachment Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `attachment_reason_code` SET TAGS ('dbx_value_regex' = 'regulatory_requirement|risk_mitigation|customer_request|underwriting_referral|rate_modification|coverage_enhancement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `attachment_sequence` SET TAGS ('dbx_business_glossary_term' = 'Attachment Sequence');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_category` SET TAGS ('dbx_business_glossary_term' = 'Form Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_description` SET TAGS ('dbx_business_glossary_term' = 'Form Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `edition_date` SET TAGS ('dbx_business_glossary_term' = 'Form Edition Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_number` SET TAGS ('dbx_business_glossary_term' = 'Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_status` SET TAGS ('dbx_business_glossary_term' = 'Form Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_status` SET TAGS ('dbx_value_regex' = 'active|superseded|withdrawn|pending_approval');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_type` SET TAGS ('dbx_business_glossary_term' = 'Form Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `iso_form_flag` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'Form Language');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_name` SET TAGS ('dbx_business_glossary_term' = 'Form Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `form_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Form Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `premium_bearing_flag` SET TAGS ('dbx_business_glossary_term' = 'Premium Bearing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `superseded_by_form_number` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `transaction_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Form Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` SET TAGS ('dbx_subdomain' = 'product_configuration');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `line_id` SET TAGS ('dbx_business_glossary_term' = 'Line Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `ceded_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ceded Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `endorsements_attached` SET TAGS ('dbx_business_glossary_term' = 'Endorsements Attached');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `experience_mod_factor` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification (Mod) Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `forms_attached` SET TAGS ('dbx_business_glossary_term' = 'Forms Attached');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `lob_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `lob_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `lob_name` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `lob_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `lob_status` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `lob_status` SET TAGS ('dbx_value_regex' = 'active|cancelled|expired|suspended|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `loss_ratio_target` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Target');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `naic_lob_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `package_discount_percentage` SET TAGS ('dbx_business_glossary_term' = 'Package Discount Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `package_indicator` SET TAGS ('dbx_business_glossary_term' = 'Package Policy Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `policy_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Policy Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `program_code` SET TAGS ('dbx_business_glossary_term' = 'Program Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'Program Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `program_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `rate_basis` SET TAGS ('dbx_business_glossary_term' = 'Rate Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `rate_factor` SET TAGS ('dbx_business_glossary_term' = 'Rate Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `reinsurance_treaty_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `schedule_credit_percentage` SET TAGS ('dbx_business_glossary_term' = 'Schedule Credit Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `schedule_debit_percentage` SET TAGS ('dbx_business_glossary_term' = 'Schedule Debit Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `sub_line_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Line Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `sub_line_name` SET TAGS ('dbx_business_glossary_term' = 'Sub-Line Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `sub_line_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `tiv_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `tiv_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `total_insured_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` SET TAGS ('dbx_subdomain' = 'party_assignment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `policy_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Commission Schedule Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `distribution_channel_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `license_id` SET TAGS ('dbx_business_glossary_term' = 'License Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `producer_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `appointment_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `appointment_status` SET TAGS ('dbx_value_regex' = 'active|terminated|suspended|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_payable_flag` SET TAGS ('dbx_business_glossary_term' = 'Commission Payable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_name` SET TAGS ('dbx_business_glossary_term' = 'Producer Contact Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `contingent_commission_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Association Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `email` SET TAGS ('dbx_business_glossary_term' = 'Producer Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `eo_coverage_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Verified Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `eo_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `eo_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Association Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `lob_authority` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Authority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Producer Association Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `npn` SET TAGS ('dbx_business_glossary_term' = 'National Producer Number (NPN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `npn` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `of_record_flag` SET TAGS ('dbx_business_glossary_term' = 'Producer of Record Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `override_rate` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `phone` SET TAGS ('dbx_business_glossary_term' = 'Producer Phone Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `producer_tier` SET TAGS ('dbx_business_glossary_term' = 'Producer Performance Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `producer_tier` SET TAGS ('dbx_value_regex' = 'platinum|gold|silver|bronze|standard');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `referral_source` SET TAGS ('dbx_business_glossary_term' = 'Referral Source Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `role_type` SET TAGS ('dbx_business_glossary_term' = 'Producer Role Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `role_type` SET TAGS ('dbx_value_regex' = 'primary|co-producer|servicing|referral|broker_of_record');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `servicing_office_code` SET TAGS ('dbx_business_glossary_term' = 'Servicing Office Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `servicing_rights_flag` SET TAGS ('dbx_business_glossary_term' = 'Servicing Rights Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Appointment Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Appointment Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_value_regex' = 'voluntary|for_cause|non_production|license_lapse|regulatory|merger');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ALTER COLUMN `writing_company_code` SET TAGS ('dbx_business_glossary_term' = 'Writing Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` SET TAGS ('dbx_subdomain' = 'contract_lifecycle');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `type_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for policy_type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `acord_form_number` SET TAGS ('dbx_business_glossary_term' = 'Association for Cooperative Operations Research and Development (ACORD) Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `acord_form_number` SET TAGS ('dbx_value_regex' = '^ACORD [0-9]{2,4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `cancellation_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `cat_exposure_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_business_glossary_term' = 'Coverage Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_value_regex' = 'Occurrence|Claims-Made|Claims-Made and Reported');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `deductible_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Deductible Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `type_description` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `endorsement_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `iso_program_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Program Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `iso_program_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,8}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `limit_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `maximum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `monoline_package_indicator` SET TAGS ('dbx_business_glossary_term' = 'Monoline or Package Policy Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `monoline_package_indicator` SET TAGS ('dbx_value_regex' = 'Monoline|Package');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `type_name` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `type_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `personal_commercial_flag` SET TAGS ('dbx_business_glossary_term' = 'Personal or Commercial Lines Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `policy_term_length_months` SET TAGS ('dbx_business_glossary_term' = 'Standard Policy Term Length in Months');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `policy_type_status` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `policy_type_status` SET TAGS ('dbx_value_regex' = 'Active|Inactive|Discontinued|Pending Approval');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `producer_commission_schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Commission Schedule Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `producer_commission_schedule_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `rating_algorithm_version` SET TAGS ('dbx_business_glossary_term' = 'Rating Algorithm Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `rating_algorithm_version` SET TAGS ('dbx_value_regex' = '^[A-Z0-9._-]{1,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `reinstatement_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `reinsurance_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `renewal_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Renewal Eligible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `risk_appetite_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `state_filing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'State Filing Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `state_filing_required_flag` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `target_loss_ratio_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Loss Ratio Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ALTER COLUMN `underwriting_tier_count` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Tier Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` SET TAGS ('dbx_subdomain' = 'contract_lifecycle');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_reg_id` SET TAGS ('dbx_business_glossary_term' = 'State Regulatory Record Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_reg_id` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `admitted_status` SET TAGS ('dbx_business_glossary_term' = 'Admitted Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `admitted_status` SET TAGS ('dbx_value_regex' = 'admitted|surplus_lines|non_admitted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `assigned_risk_pool_indicator` SET TAGS ('dbx_business_glossary_term' = 'Assigned Risk Pool Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `assigned_risk_pool_name` SET TAGS ('dbx_business_glossary_term' = 'Assigned Risk Pool Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `assigned_risk_pool_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `compliance_notes` SET TAGS ('dbx_business_glossary_term' = 'Compliance Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `compliance_review_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `doi_filing_number` SET TAGS ('dbx_business_glossary_term' = 'Department of Insurance (DOI) Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `fair_plan_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fair Access to Insurance Requirements (FAIR) Plan Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `fair_plan_name` SET TAGS ('dbx_business_glossary_term' = 'Fair Access to Insurance Requirements (FAIR) Plan Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `fair_plan_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `financial_responsibility_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Financial Responsibility Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `financial_responsibility_filing_indicator` SET TAGS ('dbx_business_glossary_term' = 'Financial Responsibility Filing Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `financial_responsibility_filing_type` SET TAGS ('dbx_business_glossary_term' = 'Financial Responsibility Filing Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `financial_responsibility_filing_type` SET TAGS ('dbx_value_regex' = 'SR-22|FR-44|SR-50|SR-1P|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `guaranty_fund_assessment_amount` SET TAGS ('dbx_business_glossary_term' = 'Guaranty Fund Assessment Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `guaranty_fund_assessment_rate` SET TAGS ('dbx_business_glossary_term' = 'Guaranty Fund Assessment Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `iso_form_edition_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Form Edition Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `minimum_liability_limit_required` SET TAGS ('dbx_business_glossary_term' = 'Minimum Liability Limit Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `municipal_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Municipal Tax Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `municipal_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Municipal Tax Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `regulatory_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `regulatory_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending_review|exempt');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `stamping_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Stamping Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `stamping_office_filing_number` SET TAGS ('dbx_business_glossary_term' = 'Stamping Office Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_form_number` SET TAGS ('dbx_business_glossary_term' = 'State Form Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_form_number` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_mandated_coverage_indicator` SET TAGS ('dbx_business_glossary_term' = 'State Mandated Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_mandated_coverage_indicator` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_mandated_coverage_list` SET TAGS ('dbx_business_glossary_term' = 'State Mandated Coverage List');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_mandated_coverage_list` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_reporting_code` SET TAGS ('dbx_business_glossary_term' = 'State Reporting Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_reporting_code` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_specific_endorsement_list` SET TAGS ('dbx_business_glossary_term' = 'State Specific Endorsement List');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_specific_endorsement_list` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'State Tax Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_tax_amount` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'State Tax Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `state_tax_rate` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ALTER COLUMN `surplus_lines_stamping_office` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Stamping Office');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` SET TAGS ('dbx_subdomain' = 'product_configuration');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `fee_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `original_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Original Fee Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `billing_method_code` SET TAGS ('dbx_business_glossary_term' = 'Billing Method Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `billing_method_code` SET TAGS ('dbx_value_regex' = 'DIRECT_BILL|AGENCY_BILL|LIST_BILL|ACCOUNT_CURRENT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `fee_description` SET TAGS ('dbx_business_glossary_term' = 'Fee Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `inspection_bureau_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Bureau Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `installment_number` SET TAGS ('dbx_business_glossary_term' = 'Installment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `refund_date` SET TAGS ('dbx_business_glossary_term' = 'Refund Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `refund_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Refund Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `refund_reason_code` SET TAGS ('dbx_value_regex' = 'POLICY_CANCELLATION|BILLING_ERROR|CUSTOMER_REQUEST|REGULATORY_REQUIREMENT|OVERPAYMENT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `refunded_flag` SET TAGS ('dbx_business_glossary_term' = 'Refunded Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `remittance_destination_code` SET TAGS ('dbx_business_glossary_term' = 'Remittance Destination Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `remittance_destination_code` SET TAGS ('dbx_value_regex' = 'CARRIER|STATE_DOI|SURPLUS_LINES_OFFICE|INSPECTION_BUREAU|THIRD_PARTY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `remittance_payee_name` SET TAGS ('dbx_business_glossary_term' = 'Remittance Payee Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `remittance_payee_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `reversal_reason_code` SET TAGS ('dbx_value_regex' = 'POLICY_VOID|TRANSACTION_CORRECTION|SYSTEM_ERROR|UNDERWRITING_CHANGE|BILLING_ADJUSTMENT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `source_system_fee_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Fee Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `surplus_lines_stamping_office_code` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Stamping Office Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `taxable_flag` SET TAGS ('dbx_business_glossary_term' = 'Taxable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Type Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = 'POLICY|INSPECTION|INSTALLMENT|SURPLUS_LINES|STAMPING|LATE_PAYMENT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `waived_flag` SET TAGS ('dbx_business_glossary_term' = 'Waived Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `waiver_authorized_by` SET TAGS ('dbx_business_glossary_term' = 'Waiver Authorized By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `waiver_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ALTER COLUMN `waiver_reason_code` SET TAGS ('dbx_value_regex' = 'CUSTOMER_RETENTION|UNDERWRITING_DISCRETION|BILLING_ERROR|REGULATORY_EXEMPTION|PROMOTIONAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` SET TAGS ('dbx_subdomain' = 'contract_lifecycle');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `document_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Document Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `binder_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_party_id` SET TAGS ('dbx_business_glossary_term' = 'Recipient Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_party_role_id` SET TAGS ('dbx_business_glossary_term' = 'Recipient Party Role Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `superseded_document_policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded Document Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `delivery_confirmation_flag` SET TAGS ('dbx_business_glossary_term' = 'Delivery Confirmation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `delivery_confirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Delivery Confirmation Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Delivery Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Delivery Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `delivery_method` SET TAGS ('dbx_value_regex' = 'mail|email|portal|fax|in_person|electronic_delivery');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `document_number` SET TAGS ('dbx_business_glossary_term' = 'Document Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Document Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Document Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'File Format');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `file_format` SET TAGS ('dbx_value_regex' = 'pdf|docx|html|xml|txt|tiff');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'File Size in Bytes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `form_code` SET TAGS ('dbx_business_glossary_term' = 'Form Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `form_edition_date` SET TAGS ('dbx_business_glossary_term' = 'Form Edition Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `generation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Document Generation Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `hash` SET TAGS ('dbx_business_glossary_term' = 'Document Hash');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Document Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Language Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Page Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Recipient Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Recipient Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_city` SET TAGS ('dbx_business_glossary_term' = 'Recipient City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_country_code` SET TAGS ('dbx_business_glossary_term' = 'Recipient Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_email` SET TAGS ('dbx_business_glossary_term' = 'Recipient Email Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_name` SET TAGS ('dbx_business_glossary_term' = 'Recipient Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Recipient Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_state_code` SET TAGS ('dbx_business_glossary_term' = 'Recipient State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_state_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `recipient_state_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `regulatory_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `storage_location_uri` SET TAGS ('dbx_business_glossary_term' = 'Storage Location Uniform Resource Identifier (URI)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `storage_location_uri` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `subtype` SET TAGS ('dbx_business_glossary_term' = 'Document Subtype');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `template_version` SET TAGS ('dbx_business_glossary_term' = 'Template Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Document Title');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `void_date` SET TAGS ('dbx_business_glossary_term' = 'Void Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `void_flag` SET TAGS ('dbx_business_glossary_term' = 'Void Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ALTER COLUMN `void_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Void Reason Code');
