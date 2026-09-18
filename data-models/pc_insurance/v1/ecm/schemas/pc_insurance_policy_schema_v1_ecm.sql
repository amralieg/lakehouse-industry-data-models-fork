-- Schema for Domain: policy | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:17

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`policy` COMMENT 'SSOT for the policy lifecycle across personal and commercial lines: issuance, endorsements (ENDT), cancellations (CANC), renewals (REN), reinstatements, and declarations (DEC). Anchors the core lineage policy to coverage to insured risk and exposure.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`policy` (
    `policy_id` BIGINT COMMENT 'Unique system identifier for the P&C policy record. Primary key.',
    `agency_id` BIGINT COMMENT 'Foreign key to the agency organization that placed this policy.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Policies denominate premium (gwp_amount, nwp_amount) in a specific currency. Replacing currency_code with FK to shared.currency enforces referential integrity for financial reporting and',
    `regulatory_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Regulatory state governs rate filing, form approval, premium tax, and statutory reporting requirements. FK to shared.state enables compliance reporting and DOI filings by jurisdiction.',
    `source_policy_id` BIGINT COMMENT 'Native policy identifier from the source system. Used for reconciliation and lineage.',
    `audit_type` STRING COMMENT 'Type of premium audit required at policy expiration: none, physical, financial, or payroll audit.. Valid values are `none|physical|financial|payroll`',
    `billing_method` STRING COMMENT 'Method by which premium is billed: direct (carrier bills insured), agency (agent bills insured), or list (reported on bordereaux).. Valid values are `direct|agency|list`',
    `bind_date` DATE COMMENT 'Date the policy was bound, establishing the carriers commitment to provide coverage.',
    `business_type` STRING COMMENT 'Transaction business type: NB (New Business), REN (Renewal), ENDT (Endorsement), CANC (Cancellation), REINST (Reinstatement).. Valid values are `NB|REN|ENDT|CANC|REINST`',
    `cancellation_date` DATE COMMENT 'Effective date of policy cancellation if the policy was cancelled before expiration. Null if not cancelled.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason for policy cancellation: non-payment, underwriting, insured request, etc.. Valid values are `^[A-Z0-9]{2,6}$`',
    `cancellation_type` STRING COMMENT 'Method of premium calculation upon cancellation: flat (no earned premium), short-rate (penalty), or pro-rata (proportional).. Valid values are `flat|short_rate|pro_rata`',
    `cat_exposure_flag` BOOLEAN COMMENT 'Indicates whether this policy has exposure to catastrophe perils (hurricane, earthquake, flood, wildfire).',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission rate percentage paid to the producer on this policy. Expressed as a decimal (e.g., 0.1500 for 15%).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy record was first created in the system.',
    `effective_date` DATE COMMENT 'Date the policy coverage begins. Start of the policy term.',
    `expiration_date` DATE COMMENT 'Date the policy coverage ends. End of the policy term.',
    `gwp_amount` DECIMAL(15,2) COMMENT 'Total gross written premium for the policy term before any reinsurance cessions.',
    `issue_date` DATE COMMENT 'Date the policy was officially issued by the carrier.',
    `lob_code` STRING COMMENT 'Line of business code: GL, WC, CPP, BOP, AUTO, PROP, etc. Identifies the primary insurance product line.. Valid values are `^[A-Z]{2,6}$`',
    `mailing_address_line1` STRING COMMENT 'First line of the policy mailing address for correspondence and declarations.',
    `mailing_address_line2` STRING COMMENT 'Second line of the policy mailing address (suite, unit, etc.).',
    `mailing_city` STRING COMMENT 'City of the policy mailing address.',
    `mailing_postal_code` STRING COMMENT 'ZIP or postal code of the policy mailing address.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `mailing_state_code` STRING COMMENT 'Two-letter state code of the policy mailing address.. Valid values are `^[A-Z]{2}$`',
    `module` STRING COMMENT 'Module or sequence number component of the policy identifier used in some carrier numbering schemes.. Valid values are `^[0-9]{3,6}$`',
    `naic_line_code` STRING COMMENT 'NAIC statutory reporting line code for regulatory and financial reporting.. Valid values are `^[0-9]{2,3}$`',
    `named_insured_name` STRING COMMENT 'Full legal name of the primary named insured on the policy.',
    `number` STRING COMMENT 'Externally visible unique policy number assigned at issuance. Business identifier for the policy across all systems and communications.. Valid values are `^[A-Z0-9]{8,20}$`',
    `nwp_amount` DECIMAL(15,2) COMMENT 'Net written premium after reinsurance cessions. Amount retained by the carrier.',
    `payment_plan_code` STRING COMMENT 'Code identifying the premium payment plan: full-pay, installment, agency-bill, direct-bill, etc.. Valid values are `^[A-Z0-9]{2,6}$`',
    `pml_amount` DECIMAL(15,2) COMMENT 'Estimated probable maximum loss for catastrophe modeling and reinsurance placement.',
    `policy_status` STRING COMMENT 'Current lifecycle status of the policy: quoted, bound, issued, inforce, cancelled, expired, nonrenewed, or reinstated. [ENUM-REF-CANDIDATE: quoted|bound|issued|inforce|cancelled|expired|nonrenewed|reinstated — 8 candidates stripped; promote to reference',
    `policy_type` STRING COMMENT 'High-level policy classification: personal lines, commercial lines, or specialty.. Valid values are `personal|commercial|specialty`',
    `prior_policy_number` STRING COMMENT 'Policy number of the prior term if this is a renewal. Links to the previous term.. Valid values are `^[A-Z0-9]{8,20}$`',
    `quote_date` DATE COMMENT 'Date the initial quote was generated for this policy.',
    `renewal_policy_number` STRING COMMENT 'Policy number of the renewal policy if this policy was renewed. Links to the subsequent term.. Valid values are `^[A-Z0-9]{8,20}$`',
    `source_system_code` STRING COMMENT 'Code identifying the source system of record: PolicyCenter, Duck Creek Policy, Sapiens IDIT, etc.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `symbol` STRING COMMENT 'ISO or carrier-specific policy symbol code identifying the product line and rating program.. Valid values are `^[A-Z0-9]{2,6}$`',
    `term_months` BIGINT COMMENT 'Duration of the policy term expressed in months. Typically 6 or 12 months for standard policies.',
    `total_insured_value` DECIMAL(15,2) COMMENT 'Total insured value across all covered property and exposures on this policy.',
    `underwriter_code` BIGINT COMMENT 'Foreign key to the employee or user who underwrote this policy.',
    `underwriting_company_code` STRING COMMENT 'Code identifying the legal entity (insurance company) that underwrites and bears the risk for this policy.. Valid values are `^[A-Z0-9]{2,6}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy record was last updated.',
    CONSTRAINT pk_policy PRIMARY KEY(`policy_id`)
) COMMENT 'Master record for a P&C policy across personal and commercial lines. SSOT for policy identity, LOB and NAIC line code, term dates, and status. Anchors the lifecycle: NB, REN, ENDT, CANC, reinstatement, non-renewal.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`version` (
    `version_id` BIGINT COMMENT 'Unique identifier for this immutable policy version snapshot. Primary key.',
    `agency_id` BIGINT COMMENT 'Reference to the agency or brokerage firm associated with this policy version.',
    `billing_account_id` BIGINT COMMENT 'Reference to the billing account used for premium collection on this policy version.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Version-level premium amounts (gwp_amount, nwp_amount, tax_amount, fee_amount, total_premium_amount) require currency FK for accurate financial consolidation and multi-currency policy',
    `named_insured_id` BIGINT COMMENT 'Reference to the primary named insured party on this policy version.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy container that this version belongs to.',
    `prior_version_id` BIGINT COMMENT 'Reference to the immediately preceding policy version, enabling full audit lineage.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the agent or broker who sold or services this policy version.',
    `regulatory_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Version-level regulatory state tracking is required for mid-term changes that cross state jurisdictions or trigger state-specific endorsement filing and premium tax recalculation.',
    `booking_date` DATE COMMENT 'Accounting date when this version was booked for financial and statutory reporting purposes.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason for cancellation if this version represents a cancellation.',
    `cancellation_type` STRING COMMENT 'Type of cancellation applied if this version represents a cancellation transaction.. Valid values are `FLAT|SHORT_RATE|PRO_RATA|NON_PAYMENT`',
    `commission_amount` DECIMAL(18,2) COMMENT 'Total commission amount payable to the producer for this policy version.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission rate percentage paid to the producer for this policy version.',
    `created_by_user_code` STRING COMMENT 'User identifier of the person or system that created this policy version.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy version record was first created in the system.',
    `declaration_page_generated_flag` BOOLEAN COMMENT 'Indicates whether a declarations page document was generated for this policy version.',
    `declaration_page_url` STRING COMMENT 'URL or document reference to the declarations page for this policy version.',
    `effective_date` DATE COMMENT 'Date when this policy version becomes effective and coverage begins or changes take effect.',
    `expiration_date` DATE COMMENT 'Date when this policy version expires and coverage ends or changes cease.',
    `fee_amount` DECIMAL(18,2) COMMENT 'Total policy fees (policy fee, installment fee, inspection fee) charged on this policy version.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Total gross written premium for this policy version before any reinsurance cessions.',
    `lob_code` STRING COMMENT 'Code identifying the line of business (e.g., Personal Auto, Commercial Property, Workers Compensation, General Liability).',
    `modified_by_user_code` STRING COMMENT 'User identifier of the person or system that last modified this policy version.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy version record was last modified.',
    `notice_date` DATE COMMENT 'Date when notice of cancellation or non-renewal was sent to the insured.',
    `number` BIGINT COMMENT 'Sequential version number within the policy lifecycle. Increments with each transaction (NB, ENDT, REN, CANC, reinstatement).',
    `nwp_amount` DECIMAL(18,2) COMMENT 'Net written premium after reinsurance cessions for this policy version.',
    `product_code` STRING COMMENT 'Code identifying the specific insurance product or program within the line of business.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this version reverses a prior transaction.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that created this policy version.. Valid values are `GUIDEWIRE_PC|DUCK_CREEK_POLICY|SAPIENS_IDIT`',
    `source_version_id` STRING COMMENT 'Native version identifier from the source policy administration system.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total taxes (premium tax, surplus lines tax, stamping fees) applicable to this policy version.',
    `total_premium_amount` DECIMAL(18,2) COMMENT 'Total amount due including premium, taxes, and fees for this policy version.',
    `transaction_effective_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the transaction that created this version became effective.',
    `transaction_type_code` STRING COMMENT 'Type of transaction that created this version: New Business (NB), Endorsement (ENDT), Renewal (REN), Cancellation (CANC), Reinstatement (REINST), or Rewrite.. Valid values are `NB|ENDT|REN|CANC|REINST|REWRITE`',
    `underwriter_code` BIGINT COMMENT 'Reference to the underwriter who approved or processed this version.',
    `underwriting_tier` STRING COMMENT 'Risk tier or rating class assigned by underwriting (e.g., Preferred, Standard, Non-Standard).',
    `version_status` STRING COMMENT 'Current lifecycle status of this policy version snapshot. [ENUM-REF-CANDIDATE: DRAFT|QUOTED|BOUND|ISSUED|ACTIVE|EXPIRED|CANCELLED — 7 candidates stripped; promote to reference product]',
    CONSTRAINT pk_version PRIMARY KEY(`version_id`)
) COMMENT 'Immutable snapshot of a policy at each transaction (NB, ENDT, REN, CANC, reinstatement). Tracks effective and expiration dates per version, enabling full audit lineage of policy changes over time.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` (
    `policy_coverage_id` BIGINT COMMENT 'Unique identifier for the policy coverage junction record.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Coverage parts map to lines of business for NAIC statutory reporting, reinsurance treaty attachment, and loss ratio analysis. FK to shared.lob_code standardizes line classification.',
    `part_id` BIGINT COMMENT 'Foreign key to the coverage definition being applied to this policy.',
    `policy_form_id` BIGINT COMMENT 'Foreign key linking to policy.policy_form. Business justification: Policy coverage references specific coverage forms via coverage_form_number and coverage_form_edition_date.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy that this coverage is attached to.',
    `prior_coverage_id` BIGINT COMMENT 'Reference to the previous version of this coverage attachment if this is an endorsement or renewal.',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Policy coverages change with endorsements (limits adjusted, coverages added/removed). Each coverage record should link to the version in which it became effective.',
    `agreed_value_amount` DECIMAL(18,2) COMMENT 'Pre-agreed value of covered property, eliminating coinsurance penalties at time of loss.',
    `benefit_period_days` BIGINT COMMENT 'Maximum number of days benefits will be paid under this coverage after the elimination period.',
    `blanket_coverage_flag` BOOLEAN COMMENT 'Indicates whether this coverage applies on a blanket basis across multiple locations or items.',
    `change_reason_code` STRING COMMENT 'Reason code indicating why this coverage was added, modified, or removed.. Valid values are `new_business|renewal|endorsement|reinstatement|cancellation|audit`',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Percentage of the loss shared by the insured after the deductible is met, expressed as a decimal.',
    `coverage_status` STRING COMMENT 'Current lifecycle status of the coverage on this policy.. Valid values are `active|suspended|cancelled|expired|pending|bound`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy coverage record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Dollar amount the insured must pay out-of-pocket before coverage applies.',
    `deductible_type` STRING COMMENT 'Type of deductible applied, such as flat dollar amount, percentage of loss, or aggregate.. Valid values are `flat|percentage|franchise|disappearing|aggregate`',
    `effective_date` DATE COMMENT 'Date when this coverage becomes effective on the policy.',
    `elimination_period_days` BIGINT COMMENT 'Number of days after a loss before benefits begin to be paid under this coverage.',
    `endorsement_number` STRING COMMENT 'Endorsement number if this coverage was added or modified via policy endorsement.. Valid values are `^[A-Z0-9-]{1,20}$`',
    `expiration_date` DATE COMMENT 'Date when this coverage expires or terminates on the policy.',
    `extended_reporting_period_days` BIGINT COMMENT 'Number of days after policy expiration during which claims may be reported for prior occurrences.',
    `inflation_guard_percentage` DECIMAL(5,2) COMMENT 'Annual percentage increase applied to coverage limits to account for inflation.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy coverage record was last updated.',
    `limit_amount` DECIMAL(18,2) COMMENT 'Maximum dollar amount the insurer will pay for covered losses under this coverage.',
    `limit_type` STRING COMMENT 'Type of limit applied, such as per occurrence, aggregate, or combined single limit.. Valid values are `per_occurrence|aggregate|per_person|per_accident|combined_single_limit|split_limit`',
    `optional_coverage_flag` BOOLEAN COMMENT 'Indicates whether this coverage is optional or mandatory for the policy.',
    `per_location_limit_amount` DECIMAL(18,2) COMMENT 'Maximum coverage limit applicable to each individual location under a blanket coverage.',
    `premium_amount` DECIMAL(18,2) COMMENT 'Premium charged for this specific coverage on the policy.',
    `premium_basis` STRING COMMENT 'The rating basis used to calculate premium, such as payroll, sales, area, or number of units.',
    `premium_basis_amount` DECIMAL(18,2) COMMENT 'Numeric value of the premium basis used in rating calculations.',
    `rate` DECIMAL(12,6) COMMENT 'Rate applied to the premium basis to calculate the coverage premium.',
    `rate_type` STRING COMMENT 'Type of rating method applied, such as manual, experience-rated, or schedule-rated.. Valid values are `manual|experience|schedule|composite|flat`',
    `retroactive_date` DATE COMMENT 'Earliest date of loss or occurrence for which claims-made coverage will respond.',
    `sequence_number` BIGINT COMMENT 'Ordinal position of this coverage within the policy structure for display and processing order.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Dollar amount of loss the insured retains before coverage applies, similar to a deductible but with different legal implications.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this coverage attachment originated.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `territory_code` STRING COMMENT 'Geographic territory where this coverage applies, using ISO territory codes.. Valid values are `^[A-Z]{2,3}$`',
    `trigger_type` STRING COMMENT 'Type of trigger that activates coverage, such as occurrence-based or claims-made.. Valid values are `occurrence|claims_made|claims_made_reported|manifestation`',
    `underwriter_code` BIGINT COMMENT 'Identifier of the underwriter who approved this coverage attachment.',
    `valuation_method` STRING COMMENT 'Method used to value covered property at time of loss: Actual Cash Value, Replacement Cost Value, or other.. Valid values are `ACV|RCV|agreed_value|stated_amount|market_value`',
    `version_number` BIGINT COMMENT 'Version number tracking changes to this coverage attachment over the policy lifecycle.',
    `waiting_period_days` BIGINT COMMENT 'Number of days from policy inception before this coverage becomes active.',
    CONSTRAINT pk_policy_coverage PRIMARY KEY(`policy_coverage_id`)
) COMMENT 'Junction table resolving the M:N relationship between policies and coverages. Carries coverage-specific limits, deductibles, SIR, and effective dates as they apply to a specific policy version.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` (
    `policy_insured_id` BIGINT COMMENT 'Unique identifier for the insured party record. Primary key.',
    `insured_id` BIGINT COMMENT 'Reference to the party entity representing the insured individual or organization.',
    `mailing_country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: Policy insured mailing country supports international additional insureds and certificate holders. FK to shared.country enforces referential integrity for cross-border policies.',
    `mailing_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Policy insured mailing state (for additional insureds, certificate holders) is required for certificate issuance and notice delivery. FK to shared.state standardizes state references.',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Insureds are added/removed via endorsements (additional insureds, certificate holders). Each policy_insured record should link to the version in which the insured was added.',
    `added_by_endorsement_number` STRING COMMENT 'Endorsement (ENDT) number that added this insured to the policy, if applicable.',
    `additional_insured_type_code` STRING COMMENT 'Code specifying the type of additional insured coverage provided (e.g., blanket, scheduled, contractual). [ENUM-REF-CANDIDATE: BLKT|SCHD|CNTR|OWNR|LSEE|MGMT|VEND|GENL — promote to reference product]',
    `business_description` STRING COMMENT 'Free-text description of the insureds business operations for commercial policies.',
    `cancellation_date` DATE COMMENT 'Date on which this insureds association with the policy was cancelled, if applicable.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason for cancelling this insured from the policy: Non-Payment (NPAY), Frequency (FREQ), Material Misrepresentation (MATL), Insured Request (INSREQ), Underwriting (UW), Other (OTH).. Valid values are `NPAY|FREQ|MATL|INSREQ|UW|OTH`',
    `certificate_holder_flag` BOOLEAN COMMENT 'Indicates whether this insured is also a certificate holder requiring proof of insurance documentation.',
    `clue_report_date` DATE COMMENT 'Date when the CLUE report was obtained for this insured.',
    `clue_report_ordered_flag` BOOLEAN COMMENT 'Indicates whether a CLUE report was ordered for this insured during underwriting.',
    `contact_email_address` STRING COMMENT 'Primary email address for electronic communication with the insured.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_phone_number` STRING COMMENT 'Primary phone number for contacting the insured regarding policy matters.',
    `created_by_user_code` STRING COMMENT 'Identifier of the user or system process that created this policy-insured association record.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this policy-insured association record was first created in the system.',
    `credit_score` BIGINT COMMENT 'Credit-based insurance score used for underwriting and rating, where permitted by state regulation.',
    `credit_score_date` DATE COMMENT 'Date when the credit score was obtained or last refreshed.',
    `date_of_birth` DATE COMMENT 'Birth date of the individual insured, used for underwriting and rating purposes.',
    `dba_name` STRING COMMENT 'Trade name or DBA under which the insured operates, if different from legal name.',
    `effective_date` DATE COMMENT 'Date on which this insured role becomes active on the policy.',
    `email_address` STRING COMMENT 'Primary email address for electronic correspondence and policy documents delivery.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `entity_type` STRING COMMENT 'Legal structure of the insured: individual, sole proprietor, partnership, LLC, corporation, trust, estate, or government entity. [ENUM-REF-CANDIDATE: individual|sole_proprietor|partnership|llc|corporation|trust|estate|government — 8 candidates stripped',
    `expiration_date` DATE COMMENT 'Date when this insureds coverage under the policy expires or was removed.',
    `fein` STRING COMMENT 'IRS-issued FEIN for commercial entities. Format: XX-XXXXXXX.. Valid values are `^d{2}-d{7}$`',
    `gender` STRING COMMENT 'Gender of the individual insured. M=Male, F=Female, X=Non-binary, U=Unknown or not disclosed.. Valid values are `M|F|X|U`',
    `industry_code` STRING COMMENT 'NAICS or SIC code representing the insureds primary business industry for commercial insureds.',
    `insurable_interest_description` STRING COMMENT 'Narrative description of the insureds insurable interest in the covered property or exposure.',
    `insured_name` STRING COMMENT 'Full legal name of the insured party as it appears on the policy declarations page (DEC).',
    `interest_description` STRING COMMENT 'Detailed description of the insureds interest in the covered property or risk.',
    `interest_type` STRING COMMENT 'Nature of the insureds financial interest in the covered property or risk: owner, lessee, mortgagor, bailee, trustee, or beneficiary.. Valid values are `owner|lessee|mortgagor|bailee|trustee|beneficiary`',
    `interest_type_code` STRING COMMENT 'Code representing the nature of the insureds interest in the covered property or risk: Owner (OWN), Lessee (LSE), Mortgagee (MTG), Vendor (VND), Bailee (BLR), Other (OTH).. Valid values are `OWN|LSE|MTG|VND|BLR|OTH`',
    `language_preference` STRING COMMENT 'Two-letter ISO language code for the insureds preferred communication language.. Valid values are `^[a-z]{2}$`',
    `last_modified_by_user_code` STRING COMMENT 'Identifier of the user or system process that last modified this policy-insured association record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this policy-insured association record was last updated.',
    `legal_name` STRING COMMENT 'Full legal name of the insured party as it appears on official documents and declarations page (DEC).',
    `loan_number` STRING COMMENT 'Loan or mortgage account number associated with the insureds interest, applicable for mortgagees and lienholders.',
    `mailing_address_line1` STRING COMMENT 'First line of the insureds mailing address for policy correspondence.',
    `mailing_address_line2` STRING COMMENT 'Second line of the insureds mailing address, typically suite or unit number.',
    `mailing_city` STRING COMMENT 'City name for the insureds mailing address.',
    `mailing_postal_code` STRING COMMENT 'ZIP or postal code for the insureds mailing address. Format: XXXXX or XXXXX-XXXX.. Valid values are `^d{5}(-d{4})?$`',
    `marital_status` STRING COMMENT 'Marital status of the individual insured, used for underwriting and rating in personal lines.. Valid values are `single|married|divorced|widowed|separated|domestic_partner`',
    `mobile_phone` STRING COMMENT 'Mobile telephone number for the insured, used for SMS notifications and mobile contact.. Valid values are `^+?[0-9]{10,15}$`',
    `mvr_order_date` DATE COMMENT 'Date when the MVR was obtained for this insured.',
    `mvr_ordered_flag` BOOLEAN COMMENT 'Indicates whether a Motor Vehicle Report was ordered for this insured during underwriting.',
    `naics_code` STRING COMMENT 'Six-digit NAICS code classifying the insureds primary business activity for commercial risks.. Valid values are `^d{6}$`',
    `occupation` STRING COMMENT 'Primary occupation or profession of the individual insured, used for risk classification.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of ownership or interest the insured holds in the covered property or entity.',
    `paperless_delivery_flag` BOOLEAN COMMENT 'Indicates whether the insured has elected paperless delivery of policy documents and correspondence.',
    `policy_insured_status` STRING COMMENT 'Current lifecycle status of the insured on the policy: active, inactive, suspended, deceased, or removed.. Valid values are `active|inactive|suspended|deceased|removed`',
    `policy_insured_type` STRING COMMENT 'Classification of the insured role on the policy: named insured, additional insured, loss payee, mortgagee, lienholder, or certificate holder.. Valid values are `named|additional|loss_payee|mortgagee|lienholder|certificate_holder`',
    `primary_insured_flag` BOOLEAN COMMENT 'Indicates whether this party is the primary or named insured on the policy.',
    `primary_phone` STRING COMMENT 'Primary contact telephone number for the insured.. Valid values are `^+?[0-9]{10,15}$`',
    `prior_carrier_name` STRING COMMENT 'Name of the insureds previous insurance carrier, used for underwriting continuity assessment.',
    `prior_policy_number` STRING COMMENT 'Policy number with the prior carrier, used for loss history verification.',
    `removed_by_endorsement_number` STRING COMMENT 'Endorsement (ENDT) number that removed this insured from the policy, if applicable.',
    `role_code` STRING COMMENT 'Code indicating the role of the insured on the policy: Named Insured (NI), Additional Insured (AI), Loss Payee (LP), Mortgagee (MTG), Lienholder (LH), or Additional Interest (INT).. Valid values are `NI|AI|LP|MTG|LH|INT`',
    `role_description` STRING COMMENT 'Full text description of the insured role on the policy.',
    `sequence` BIGINT COMMENT 'Ordinal position of this insured on the policy for display and reporting purposes.',
    `sequence_number` BIGINT COMMENT 'Ordinal position of this insured within the policy, used for display and sorting purposes.',
    `sic_code` STRING COMMENT 'Four-digit SIC code classifying the insureds industry for underwriting and rating purposes.. Valid values are `^d{4}$`',
    `source_record_code` STRING COMMENT 'Unique identifier of this insured record in the source operational system.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this insured record originated: Guidewire (GW), Duck Creek (DC), Sapiens (SAP), ISO (ISO), Legacy (LEG), Other (OTH).. Valid values are `GW|DC|SAP|ISO|LEG|OTH`',
    `ssn` STRING COMMENT 'Social Security Number for individual insureds, used for underwriting and claims purposes.. Valid values are `^d{3}-d{2}-d{4}$`',
    `status_code` STRING COMMENT 'Current status of the insured association: Active (ACT), Inactive (INA), Pending (PND), Cancelled (CAN), Expired (EXP).. Valid values are `ACT|INA|PND|CAN|EXP`',
    `underwriter_notes` STRING COMMENT 'Free-text notes from the underwriter regarding this insureds risk profile or special considerations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this insured record was last modified.',
    `waiver_of_subrogation_flag` BOOLEAN COMMENT 'Indicates whether the insurer has waived subrogation rights against this insured party.',
    `years_in_business` BIGINT COMMENT 'Number of years the insured has been operating in their current business, used for underwriting assessment.',
    `years_with_prior_carrier` BIGINT COMMENT 'Number of continuous years the insured was with their prior carrier, used for loyalty and persistency rating.',
    CONSTRAINT pk_policy_insured PRIMARY KEY(`policy_insured_id`)
) COMMENT 'Master record for the named insured or additional insured on a policy. Captures party identity (individual or commercial entity), FEIN/SSN, DBA, and insured type. SSOT for insured party within the policy domain.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`insured` (
    `insured_id` BIGINT COMMENT 'Primary key for insured',
    `policy_id` BIGINT COMMENT 'Auto-generated FK linking siloed insured to policy',
    CONSTRAINT pk_insured PRIMARY KEY(`insured_id`)
) COMMENT 'Association table linking insureds to a policy version with role (named insured, additional insured, loss payee, mortgagee). Supports multiple insured parties per policy and tracks role effective dates.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` (
    `declarations_id` BIGINT COMMENT 'Unique identifier for the declarations page record.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Declarations page displays premium amounts in a specific currency. FK to shared.currency ensures consistent currency formatting and symbol display on dec pages.',
    `declarations_producers_producer_id` BIGINT COMMENT 'Reference to the producer entity who sold or serviced this policy.',
    `declarations_producers_producers_producer_id` BIGINT COMMENT 'Reference to the underwriter who approved this policy.',
    `mailing_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Declarations page mailing state determines delivery compliance and state-specific disclosure requirements. FK to shared.state enables state-specific dec page generation rules.',
    `policy_form_id` BIGINT COMMENT 'Foreign key linking to policy.policy_form. Business justification: Declarations page references policy forms via form_numbers (denormalized STRING). Adding FK to primary policy_form enables proper form resolution and retrieval of form metadata',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy for which this declarations page was issued.',
    `policy_insured_id` BIGINT COMMENT 'Reference to the party entity representing the named insured.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Declaration pages are generated for specific policy transactions (NB, ENDT, REN, CANC).',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Declarations page represents a specific policy version snapshot. Currently uses policy_version_number (INT) for loose coupling.',
    `company_name` STRING COMMENT 'Legal name of the insurance company issuing this policy, as shown on the declarations page.',
    `coverage_summary_text` STRING COMMENT 'High-level textual summary of coverages included in this policy, as displayed on the declarations page.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this declarations page record was first created in the system.',
    `dec_page_number` STRING COMMENT 'Unique document control number assigned to this declarations page.. Valid values are `^DEC-[0-9]{6,12}$`',
    `dec_page_status` STRING COMMENT 'Current lifecycle status of the declarations page document.. Valid values are `draft|issued|superseded|cancelled|void`',
    `document_generated_timestamp` TIMESTAMP COMMENT 'Timestamp when the declarations page document was generated.',
    `document_url` STRING COMMENT 'URL or file path to the generated declarations page document in the content management system.. Valid values are `^https?://.*`',
    `effective_date` DATE COMMENT 'Date on which the policy coverage described in this declarations page becomes effective.',
    `endorsement_numbers` STRING COMMENT 'Comma-separated list of endorsement numbers that modify the base policy.',
    `expiration_date` DATE COMMENT 'Date on which the policy coverage described in this declarations page expires.',
    `fee_amount` DECIMAL(18,2) COMMENT 'Total fees included in the premium, such as policy fees or stamping fees.',
    `form_numbers` STRING COMMENT 'Comma-separated list of ISO or proprietary form numbers attached to this policy.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Total gross written premium for the policy term before any reinsurance cessions.',
    `issue_date` DATE COMMENT 'Date on which the declarations page was formally issued to the insured.',
    `lob_code` STRING COMMENT 'Code identifying the primary line of business for this policy.. Valid values are `^[A-Z]{2,6}$`',
    `lob_description` STRING COMMENT 'Full description of the line of business.',
    `mailing_address_line1` STRING COMMENT 'First line of the insured mailing address as shown on the declarations page.',
    `mailing_address_line2` STRING COMMENT 'Second line of the insured mailing address, typically suite or unit number.',
    `mailing_city` STRING COMMENT 'City of the insured mailing address.',
    `mailing_postal_code` STRING COMMENT 'ZIP or postal code for the insured mailing address.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC code identifying the insurance company issuing this policy.. Valid values are `^[0-9]{5}$`',
    `named_insured` STRING COMMENT 'Full legal name of the primary insured party as it appears on the declarations page.',
    `policy_type_code` STRING COMMENT 'Code indicating the transaction type: New Business, Renewal, Endorsement, Cancellation, or Reinstatement.. Valid values are `NB|REN|ENDT|CANC|REINST`',
    `producer_code` STRING COMMENT 'Alphanumeric code assigned to the producer for commission and reporting purposes.. Valid values are `^[A-Z0-9]{4,12}$`',
    `producer_name` STRING COMMENT 'Name of the agent or broker who produced this policy, as shown on the declarations page.',
    `regulatory_state_code` STRING COMMENT 'Two-letter state code of the jurisdiction governing this policy.. Valid values are `^[A-Z]{2}$`',
    `source_system_code` STRING COMMENT 'Code identifying the source system that generated this declarations page record.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax amount included in the premium, such as state premium tax or surplus lines tax.',
    `total_insured_value_amount` DECIMAL(18,2) COMMENT 'Total insured value representing the sum of all insured property and liability limits.',
    `total_premium_amount` DECIMAL(18,2) COMMENT 'Total premium amount due for the policy term, including all taxes and fees.',
    `underwriter_name` STRING COMMENT 'Name of the underwriter who approved this policy.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this declarations page record was last updated.',
    CONSTRAINT pk_declarations PRIMARY KEY(`declarations_id`)
) COMMENT 'DEC page record for a policy version: summarizes insured name, policy number, LOB, coverage summary, TIV, total premium, and effective/expiration dates. Represents the formal policy document snapshot issued to the insured.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` (
    `uw_decision_id` BIGINT COMMENT 'Unique identifier for the underwriting decision record.',
    `policy_id` BIGINT COMMENT 'Reference to the policy submission or renewal being underwritten.',
    `quote_id` BIGINT COMMENT 'Reference to the quote associated with this underwriting decision.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to policy.submission. Business justification: Underwriting decisions evaluate submissions (accept, decline, refer). uw_decision already links to quote and policy, but should also link to submission to establish the full pre-bind',
    `adverse_action_notice_date` DATE COMMENT 'The date when the adverse action notice was sent to the applicant.',
    `adverse_action_notice_sent_flag` BOOLEAN COMMENT 'Indicates whether an adverse action notice was sent to the applicant following a decline or unfavorable decision.',
    `approval_date` DATE COMMENT 'The date when the underwriting decision was approved by the required authority.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether additional approval is required before the underwriting decision can be finalized.',
    `approved_by_underwriter_code` BIGINT COMMENT 'Reference to the senior underwriter or authority who approved the decision.',
    `authority_level` STRING COMMENT 'The level of underwriting authority exercised for this decision, indicating approval hierarchy.. Valid values are `line_underwriter|senior_underwriter|chief_underwriter|automated|delegated_authority|binding_authority`',
    `automated_decision_flag` BOOLEAN COMMENT 'Indicates whether the underwriting decision was made by an automated underwriting system or by a human underwriter.',
    `business_type` STRING COMMENT 'Type of business transaction: new business, renewal, endorsement, or reinstatement.. Valid values are `new_business|renewal|endorsement|reinstatement`',
    `conditions_imposed` STRING COMMENT 'Description of any conditions or requirements imposed as part of the underwriting decision, such as risk mitigation measures.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the underwriting decision record was first created in the system.',
    `decision_action` STRING COMMENT 'The underwriting action taken: accept, decline, refer to senior underwriter, modify terms, counter offer, or conditional acceptance.. Valid values are `accept|decline|refer|modify|counter_offer|conditional_accept`',
    `decision_date` DATE COMMENT 'The date when the underwriting decision was made.',
    `decision_model_name` STRING COMMENT 'Name of the automated underwriting model or rules engine used to generate the decision.',
    `decision_model_version` STRING COMMENT 'Version of the automated underwriting model or rules engine used.',
    `decision_number` STRING COMMENT 'Business identifier for the underwriting decision, externally visible and used for tracking and reference.',
    `decision_status` STRING COMMENT 'Current lifecycle status of the underwriting decision in the workflow.. Valid values are `draft|pending_review|approved|rejected|superseded|withdrawn`',
    `decision_timestamp` TIMESTAMP COMMENT 'Precise date and time when the underwriting decision was finalized.',
    `declination_reason` STRING COMMENT 'Detailed reason for declining the submission, required for regulatory compliance and adverse action notices.',
    `deductible_adjustment` DECIMAL(15,2) COMMENT 'Adjustment to the policy deductible amount imposed by the underwriting decision.',
    `effective_date` DATE COMMENT 'The date from which the underwriting decision becomes effective for the policy.',
    `exclusions_applied` STRING COMMENT 'Description of any exclusions applied to the policy coverage as a result of the underwriting decision.',
    `expiration_date` DATE COMMENT 'The date when the underwriting decision expires and must be re-evaluated.',
    `limit_adjustment` DECIMAL(15,2) COMMENT 'Adjustment to the policy coverage limit imposed by the underwriting decision.',
    `lob` STRING COMMENT 'The line of business for which the underwriting decision applies, such as commercial general liability or personal auto.',
    `notes` STRING COMMENT 'Additional notes or comments recorded by the underwriter regarding the decision.',
    `override_flag` BOOLEAN COMMENT 'Indicates whether the underwriter manually overrode an automated decision or guideline recommendation.',
    `override_reason` STRING COMMENT 'Explanation for why the underwriter overrode the automated decision or guideline recommendation.',
    `premium_adjustment_amount` DECIMAL(15,2) COMMENT 'Dollar amount of premium adjustment resulting from the underwriting decision.',
    `premium_adjustment_pct` DECIMAL(5,2) COMMENT 'Percentage adjustment to the base premium resulting from the underwriting decision, positive for surcharges and negative for credits.',
    `primary_reason_code` STRING COMMENT 'Primary reason code explaining the underwriting decision, aligned with regulatory and internal classification standards.',
    `reason_description` STRING COMMENT 'Detailed narrative explanation of the underwriting decision rationale and any specific conditions or concerns.',
    `referral_reason` STRING COMMENT 'Reason for referring the submission to a higher authority level or specialist underwriter.',
    `referred_to_underwriter_code` BIGINT COMMENT 'Reference to the underwriter to whom the submission was referred for further review.',
    `risk_score` DECIMAL(10,2) COMMENT 'Numerical risk score calculated during underwriting evaluation, used to quantify exposure level.',
    `risk_tier` STRING COMMENT 'The risk classification tier assigned to the submission based on underwriting assessment.. Valid values are `preferred|standard|substandard|declined|high_risk|catastrophe_exposed`',
    `secondary_reason_code` STRING COMMENT 'Secondary reason code providing additional context for the underwriting decision.',
    `sir_adjustment` DECIMAL(15,2) COMMENT 'Adjustment to the self-insured retention amount imposed by the underwriting decision.',
    `underwriter_code` BIGINT COMMENT 'Reference to the underwriter who made the decision.',
    `underwriting_guidelines_version` STRING COMMENT 'Version of the underwriting guidelines applied when making this decision, for audit and compliance tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the underwriting decision record was last modified.',
    CONSTRAINT pk_uw_decision PRIMARY KEY(`uw_decision_id`)
) COMMENT 'Underwriting decision record for a policy submission or renewal: UW action (accept, decline, refer, modify), decision date, UW authority level, reason codes, and any conditions or exclusions imposed.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`quote` (
    `quote_id` BIGINT COMMENT 'Unique system identifier for the quote record. Primary key.',
    `agency_id` BIGINT COMMENT 'Reference to the agency organization through which this quote was submitted.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Quote amounts (quoted_gwp, quoted_taxes_fees, quoted_total_premium) are denominated in a currency. FK to shared.currency supports multi-currency quoting and conversion.',
    `parent_quote_id` BIGINT COMMENT 'Reference to the original quote if this is a revised version, enabling quote lineage tracking.',
    `policy_id` BIGINT COMMENT 'Reference to the policy if this quote was bound and converted to an active policy.',
    `policy_insured_id` BIGINT COMMENT 'Reference to the primary named insured party for this quote.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the agent or broker who originated this quote and will earn commission if bound.',
    `rating_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Rating state determines which rate filing and underwriting rules apply to the quote. FK to shared.state enables state-specific rating algorithm selection and surplus lines eligibility.',
    `binder_effective_date` DATE COMMENT 'Actual effective date of temporary binder coverage if binding authority was exercised.',
    `binder_expiration_date` DATE COMMENT 'Expiration date of temporary binder, typically 30-90 days pending formal policy issuance.',
    `binder_number` STRING COMMENT 'Temporary binder identifier issued when binding authority is exercised prior to formal policy issuance.. Valid values are `^BND-[0-9]{6,10}$`',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has binding authority to convert this quote to a binder without underwriter approval.',
    `binding_authority_limit` DECIMAL(15,2) COMMENT 'Maximum premium amount the producer is authorized to bind without underwriter review.',
    `bound_timestamp` TIMESTAMP COMMENT 'Timestamp when the quote was bound and converted to active coverage or binder.',
    `clue_report_ordered_flag` BOOLEAN COMMENT 'Indicates whether a CLUE loss history report was ordered during the quoting process.',
    `created_by_user_code` STRING COMMENT 'System user identifier of the person who created this quote record.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the quote record was first created in the policy administration system.',
    `credit_score` BIGINT COMMENT 'Insurance credit score used for rating in jurisdictions where permitted, typically 300-850 range.',
    `decline_reason_code` STRING COMMENT 'Standardized code indicating the primary reason for quote declination by underwriting.. Valid values are `^[A-Z0-9]{2,6}$`',
    `decline_reason_description` STRING COMMENT 'Detailed explanation of why the quote was declined, provided to the agent and insured per regulatory requirements.',
    `declined_timestamp` TIMESTAMP COMMENT 'Timestamp when the quote was declined by underwriting or rejected by the customer.',
    `effective_date` DATE COMMENT 'Proposed effective date when coverage would begin if the quote is bound.',
    `expiration_date` DATE COMMENT 'Proposed expiration date when coverage would end, typically one year from effective date for annual policies.',
    `last_modified_by_user_code` STRING COMMENT 'System user identifier of the person who last modified this quote record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to this quote record.',
    `lob` STRING COMMENT 'Insurance line of business category for this quote, determining product rules, rating, and underwriting guidelines. [ENUM-REF-CANDIDATE: personal_auto|homeowners|commercial_auto|general_liability|workers_comp|bop|cpp|umbrella — 8 candidates stripped',
    `mvr_ordered_flag` BOOLEAN COMMENT 'Indicates whether motor vehicle reports were ordered for drivers on auto quotes.',
    `number` STRING COMMENT 'Externally visible business identifier for the quote, used in customer communications and agent references.. Valid values are `^[A-Z]{2,3}-[0-9]{6,10}$`',
    `pml` DECIMAL(18,2) COMMENT 'Estimated probable maximum loss for catastrophe modeling and reinsurance placement purposes.',
    `presented_timestamp` TIMESTAMP COMMENT 'Timestamp when the quote was formally presented to the customer or agent.',
    `prior_carrier_name` STRING COMMENT 'Name of the insurance carrier providing coverage immediately prior to this quote, used for continuity verification.',
    `prior_policy_number` STRING COMMENT 'Policy number from the prior carrier, used for loss history and CLUE report verification.',
    `product_code` STRING COMMENT 'Specific insurance product identifier within the line of business, linking to filed rates and forms.. Valid values are `^[A-Z0-9]{3,10}$`',
    `quote_status` STRING COMMENT 'Current lifecycle status of the quote indicating its progression through the underwriting and binding workflow.. Valid values are `draft|presented|bound|declined|expired|withdrawn`',
    `quote_type` STRING COMMENT 'Classification indicating whether this is a new business quote, renewal quote, rewrite, or endorsement quote.. Valid values are `new_business|renewal|rewrite|endorsement_quote`',
    `quoted_gwp` DECIMAL(15,2) COMMENT 'Total gross written premium amount quoted before any reinsurance cessions or adjustments.',
    `quoted_taxes_fees` DECIMAL(15,2) COMMENT 'Total taxes, surplus lines taxes, stamping fees, and regulatory assessments included in the quote.',
    `quoted_total_premium` DECIMAL(15,2) COMMENT 'Total amount due from the insured including base premium, taxes, fees, and surcharges.',
    `rating_state` STRING COMMENT 'Two-letter state code determining which filed rates, forms, and regulatory rules apply to this quote.. Valid values are `^[A-Z]{2}$`',
    `surplus_lines_flag` BOOLEAN COMMENT 'Indicates whether this quote is for surplus lines coverage placed outside the admitted market.',
    `tiv` DECIMAL(18,2) COMMENT 'Total insured value representing the maximum potential exposure across all coverages in this quote.',
    `underwriter_code` BIGINT COMMENT 'Reference to the underwriter assigned to review and approve this quote.',
    `uw_score` DECIMAL(5,2) COMMENT 'Numeric underwriting score from automated rating and risk assessment models, typically 0-100 scale.',
    `uw_tier` STRING COMMENT 'Risk tier assigned during underwriting indicating the quality and pricing level of the quoted risk.. Valid values are `preferred|standard|non_standard|declined`',
    `valid_until_date` DATE COMMENT 'Date until which the quoted premium and terms remain valid for binding, typically 30-60 days from quote date.',
    `version_number` BIGINT COMMENT 'Version number tracking iterations and revisions of the quote as coverage options or pricing are adjusted.',
    `years_with_prior_carrier` BIGINT COMMENT 'Number of continuous years the insured maintained coverage with the prior carrier, used for loyalty discounts.',
    CONSTRAINT pk_quote PRIMARY KEY(`quote_id`)
) COMMENT 'Pre-bind quote and temporary binder: rated premium, coverage options, TIV, quote and binder effective/expiration dates, binding authority, binder number, and status (draft, presented, bound, declined).';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`submission` (
    `submission_id` BIGINT COMMENT 'Unique identifier for the underwriting submission record.',
    `agency_id` BIGINT COMMENT 'Identifier of the agency through which the submission was received.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Submission TIV and requested premium are denominated in a currency. FK to shared.currency supports multi-currency submission intake and conversion to home currency.',
    `policy_id` BIGINT COMMENT 'Identifier of the policy issued from this submission, if the submission was bound.',
    `producers_producer_id` BIGINT COMMENT 'Identifier of the agent or broker who submitted the application.',
    `quote_id` BIGINT COMMENT 'Identifier of the quote generated from this submission, if the submission progressed to the quoted stage.',
    `risk_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Submission risk state drives underwriting appetite, rate filing applicability, and producer licensing validation.',
    `applicant_email` STRING COMMENT 'Primary email address for the applicant.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `applicant_name` STRING COMMENT 'Full legal name of the individual or organization applying for coverage.',
    `applicant_phone` STRING COMMENT 'Primary contact phone number for the applicant.. Valid values are `^+?[1-9]d{1,14}$`',
    `applicant_type` STRING COMMENT 'Legal entity type of the applicant.. Valid values are `individual|corporation|partnership|llc|trust|other`',
    `business_type` STRING COMMENT 'Classification indicating whether the submission is for new business, renewal, or rewrite.. Valid values are `new_business|renewal|rewrite`',
    `clue_report_ordered` BOOLEAN COMMENT 'Indicates whether a CLUE report was ordered to retrieve loss history for the applicant.',
    `created_by_user` STRING COMMENT 'Username or identifier of the user who created the submission record.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the submission record was first created in the system.',
    `credit_score` BIGINT COMMENT 'Credit-based insurance score used for underwriting and rating purposes.',
    `declined_reason` STRING COMMENT 'Explanation or code indicating why the submission was declined, if applicable.',
    `effective_date` DATE COMMENT 'Requested policy effective date for coverage to begin if the submission is bound.',
    `expiration_date` DATE COMMENT 'Requested policy expiration date for coverage to end if the submission is bound.',
    `lob` STRING COMMENT 'Primary line of business for the submission, indicating the type of coverage requested. [ENUM-REF-CANDIDATE: personal_auto|homeowners|commercial_auto|general_liability|workers_comp|bop|umbrella — 7 candidates stripped; promote to reference product]',
    `loss_history_years` BIGINT COMMENT 'Number of years of loss history provided or requested for underwriting evaluation.',
    `mvr_ordered` BOOLEAN COMMENT 'Indicates whether a motor vehicle report was ordered for the applicant or drivers.',
    `naics_code` STRING COMMENT 'Six-digit NAICS code classifying the applicants business industry for commercial submissions.. Valid values are `^d{6}$`',
    `notes` STRING COMMENT 'Free-text notes or comments recorded by underwriters or agents regarding the submission.',
    `number` STRING COMMENT 'Externally-known business identifier for the submission, typically system-generated or agent-provided reference number.. Valid values are `^SUB-[0-9]{8,12}$`',
    `prior_carrier_name` STRING COMMENT 'Name of the insurance carrier that previously provided coverage to the applicant, if applicable.',
    `prior_policy_number` STRING COMMENT 'Policy number from the prior carrier, used for underwriting evaluation and loss history retrieval.',
    `requested_premium` DECIMAL(15,2) COMMENT 'Estimated or requested premium amount for the coverage being applied for.',
    `risk_address_line1` STRING COMMENT 'Primary street address of the risk location being insured.',
    `risk_address_line2` STRING COMMENT 'Secondary address information for the risk location, such as suite or unit number.',
    `risk_city` STRING COMMENT 'City where the risk location is situated.',
    `risk_country` STRING COMMENT 'Three-letter ISO country code for the risk location.. Valid values are `^[A-Z]{3}$`',
    `risk_postal_code` STRING COMMENT 'ZIP or postal code for the risk location.. Valid values are `^d{5}(-d{4})?$`',
    `sic_code` STRING COMMENT 'Four-digit SIC code classifying the applicants business industry for commercial submissions.. Valid values are `^d{4}$`',
    `source_channel` STRING COMMENT 'Distribution channel through which the submission was received.. Valid values are `agent|broker|direct|online_portal|call_center|mobile_app`',
    `submission_date` DATE COMMENT 'Date the submission was received or entered into the system.',
    `submission_status` STRING COMMENT 'Current lifecycle state of the submission in the underwriting workflow. [ENUM-REF-CANDIDATE: new|in_review|quoted|bound|declined|withdrawn|expired — 7 candidates stripped; promote to reference product]',
    `timestamp` TIMESTAMP COMMENT 'Precise date and time the submission was received or created.',
    `tiv` DECIMAL(18,2) COMMENT 'Total insured value representing the sum of all property values and limits requested in the submission.',
    `underwriter_code` BIGINT COMMENT 'Identifier of the underwriter assigned to review and evaluate the submission.',
    `updated_by_user` STRING COMMENT 'Username or identifier of the user who last updated the submission record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the submission record was last modified.',
    CONSTRAINT pk_submission PRIMARY KEY(`submission_id`)
) COMMENT 'Underwriting submission record representing an application for coverage: submission date, source channel, LOB, applicant details, risk information, and submission status (new, in-review, quoted, bound, declined).';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` (
    `policy_producer_id` BIGINT COMMENT 'Unique identifier for the policy-producer relationship record.',
    `agency_id` BIGINT COMMENT 'Foreign key reference to the agency under which this producer is writing or servicing the policy.',
    `policy_id` BIGINT COMMENT 'Foreign key reference to the policy being serviced or written by the producer.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key reference to the producer (agent or broker) associated with this policy.',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Producer assignments can change via endorsements (producer of record changes, commission splits adjusted).',
    `appointment_effective_date` DATE COMMENT 'Date when the producers appointment to write or service this policy became effective.',
    `appointment_expiration_date` DATE COMMENT 'Date when the producers appointment to write or service this policy expires or was terminated.',
    `assignment_date` DATE COMMENT 'Date when the producer was assigned to this policy, which may differ from appointment effective date for servicing transfers.',
    `binding_authority_flag` BOOLEAN COMMENT 'Indicates whether the producer has binding authority to issue this policy without prior underwriting approval.',
    `commission_basis_code` STRING COMMENT 'Basis on which commission is calculated: Gross Written Premium (GWP), Net Written Premium (NWP), Earned Premium (EP), or flat fee.. Valid values are `GWP|NWP|EP|FLAT`',
    `commission_holdback_percentage` DECIMAL(5,2) COMMENT 'Percentage of commission withheld by the insurer for this policy-producer relationship, typically for quality or performance reasons.',
    `commission_payment_method_code` STRING COMMENT 'Method by which commission is paid to the producer for this policy: ACH transfer, check, wire, or offset against debit balance.. Valid values are `ACH|CHECK|WIRE|OFFSET`',
    `commission_plan_code` STRING COMMENT 'Code identifying the commission plan or schedule applicable to this producer for this policy.',
    `commission_split_percentage` DECIMAL(5,2) COMMENT 'Percentage of total commission allocated to this producer on the policy, expressed as a decimal (e.g., 75.00 for 75%).',
    `commission_statement_frequency_code` STRING COMMENT 'Frequency at which commission statements are generated for this producer-policy relationship.. Valid values are `MONTHLY|QUARTERLY|ANNUAL|TRANSACTION`',
    `contact_email` STRING COMMENT 'Primary email address of the producer for policy-related communication and commission statements.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_phone` STRING COMMENT 'Primary phone number of the producer for policy servicing and customer inquiries.',
    `contingent_commission_eligible_flag` BOOLEAN COMMENT 'Indicates whether this policy-producer relationship is eligible for contingent or bonus commission based on performance metrics.',
    `created_by_user_code` STRING COMMENT 'User ID of the system user or process that created this policy-producer relationship record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy-producer relationship record was first created in the system.',
    `effective_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy-producer relationship record became effective in the system.',
    `expiration_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy-producer relationship record expired or was superseded by a new record.',
    `license_number` STRING COMMENT 'State-issued license number of the producer valid at the time of policy association, for regulatory compliance tracking.',
    `license_state_code` STRING COMMENT 'Two-letter state code where the producer holds the license applicable to this policy.',
    `lob_code` STRING COMMENT 'Line of business code for which the producer is appointed on this policy (e.g., Personal Auto, Commercial Property).',
    `modified_by_user_code` STRING COMMENT 'User ID of the system user or process that last modified this policy-producer relationship record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy-producer relationship record was last modified in the system.',
    `naic_producer_code` STRING COMMENT 'NAIC-assigned producer code for regulatory reporting and cross-state producer identification.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this policy-producer relationship, such as special arrangements or servicing instructions.',
    `override_commission_rate` DECIMAL(5,2) COMMENT 'Override commission rate percentage applied to this specific policy-producer relationship, if different from standard plan.',
    `policy_transaction_type_code` STRING COMMENT 'Type of policy transaction that established or modified this producer relationship: New Business (NB), Renewal (REN), Endorsement (ENDT), Cancellation (CANC), Reinstatement.. Valid values are `NB|REN|ENDT|CANC|REINSTATE`',
    `primary_producer_flag` BOOLEAN COMMENT 'Indicates whether this producer is the primary or lead producer for the policy (true) or a secondary/split producer (false).',
    `producer_code` STRING COMMENT 'Unique alphanumeric code assigned to the producer by the insurer for identification and commission tracking.',
    `record_version_number` BIGINT COMMENT 'Version number of this policy-producer relationship record, incremented with each modification for audit trail purposes.',
    `relationship_status` STRING COMMENT 'Current status of the producer-policy relationship indicating whether the producer is actively servicing or earning commission.. Valid values are `ACTIVE|INACTIVE|SUSPENDED|TERMINATED`',
    `role_code` STRING COMMENT 'Role of the producer on this policy: writing agent, servicing agent, referring agent, or split commission arrangement.. Valid values are `WRITING|SERVICING|REFERRING|SPLIT`',
    `servicing_office_code` STRING COMMENT 'Code identifying the producers office or branch location responsible for servicing this policy.',
    `source_system_code` STRING COMMENT 'Code identifying the source system from which this policy-producer relationship record originated.. Valid values are `GUIDEWIRE_PC|DUCK_CREEK|SAPIENS|LEGACY`',
    `sub_producer_code` STRING COMMENT 'Code identifying a sub-producer or sub-agent under the primary producer for hierarchical commission tracking.',
    `tax_identification_number` STRING COMMENT 'Federal Employer Identification Number (FEIN) or Social Security Number (SSN) of the producer for tax reporting (1099 generation).',
    `termination_date` DATE COMMENT 'Date when the producers relationship with this policy was terminated or transferred to another producer.',
    `termination_reason_code` STRING COMMENT 'Reason code explaining why the producer-policy relationship was terminated or changed.. Valid values are `TRANSFER|RETIREMENT|TERMINATION|POLICY_CANCEL|VOLUNTARY`',
    `territory_code` STRING COMMENT 'Geographic territory code assigned to the producer for this policy, used for commission and performance tracking.',
    `tier_code` STRING COMMENT 'Tier or performance level of the producer at the time of policy association, affecting commission rates and incentives.. Valid values are `PLATINUM|GOLD|SILVER|BRONZE|STANDARD`',
    CONSTRAINT pk_policy_producer PRIMARY KEY(`policy_producer_id`)
) COMMENT 'Junction table linking a policy to the writing producer (agent/broker) and servicing producer. Captures producer role, commission split percentage, appointment effective date, and producer code.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` (
    `status_history_id` BIGINT COMMENT 'Unique identifier for the policy status history record.',
    `policy_id` BIGINT COMMENT 'Reference to the policy that experienced the status transition.',
    `policy_transaction_id` BIGINT COMMENT 'Reference to the specific policy transaction that initiated this status change.',
    `reversed_by_status_history_id` BIGINT COMMENT 'Reference to the subsequent status history record that reversed this transition.',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Status transitions correspond to policy versions (each transaction creates a version and may trigger a status change).',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether the status transition required managerial or underwriting approval.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the status transition was approved.',
    `approved_by_user_code` STRING COMMENT 'System user identifier of the approver, if approval was required.',
    `approved_by_user_name` STRING COMMENT 'Full name of the user who approved the status transition.',
    `cancellation_notice_date` DATE COMMENT 'Date when cancellation notice was issued to the insured, if applicable.',
    `cancellation_type` STRING COMMENT 'Specific type of cancellation when the transition involves policy cancellation. [ENUM-REF-CANDIDATE: flat|short_rate|pro_rata|insured_request|non_payment|underwriting|fraud — 7 candidates stripped; promote to reference product]',
    `comments` STRING COMMENT 'Free-form comments or notes regarding the status transition.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this status history record was first created in the system.',
    `effective_date` DATE COMMENT 'The date on which the new status became effective for the policy.',
    `initiated_by_party_type` STRING COMMENT 'The type of party that initiated the status transition.. Valid values are `insured|insurer|agent|underwriter|system|regulator`',
    `initiated_by_user_code` STRING COMMENT 'System user identifier of the person who initiated the status change.',
    `initiated_by_user_name` STRING COMMENT 'Full name of the user who initiated the status transition.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this status history record was last updated.',
    `lob` STRING COMMENT 'The line of business of the policy at the time of status transition.',
    `new_status` STRING COMMENT 'The status of the policy after this transition was applied. [ENUM-REF-CANDIDATE: active|cancelled|lapsed|expired|reinstated|non_renewed|pending|suspended|bound|quoted — 10 candidates stripped; promote to reference product]',
    `non_renewal_reason` STRING COMMENT 'Explanation for why the policy was not renewed at expiration.',
    `notification_method` STRING COMMENT 'The method used to notify the insured of the status transition.. Valid values are `email|mail|phone|portal|fax`',
    `notification_sent_flag` BOOLEAN COMMENT 'Indicates whether a notification was sent to the insured regarding the status change.',
    `notification_sent_timestamp` TIMESTAMP COMMENT 'Date and time when notification was sent to the insured.',
    `premium_impact_amount` DECIMAL(18,2) COMMENT 'The financial impact on premium resulting from this status transition.',
    `prior_status` STRING COMMENT 'The status of the policy immediately before this transition occurred. [ENUM-REF-CANDIDATE: active|cancelled|lapsed|expired|reinstated|non_renewed|pending|suspended|bound|quoted — 10 candidates stripped; promote to reference product]',
    `regulatory_filing_date` DATE COMMENT 'Date when the status transition was filed with the regulatory authority.',
    `regulatory_filing_required_flag` BOOLEAN COMMENT 'Indicates whether this status transition requires regulatory reporting or filing.',
    `reinstatement_date` DATE COMMENT 'Date when a lapsed or cancelled policy was reinstated, if applicable.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this status transition was later reversed or corrected.',
    `state_code` STRING COMMENT 'Two-letter state code where the policy is domiciled for regulatory purposes.',
    `system_source` STRING COMMENT 'The source system that recorded this status transition event.',
    `transition_reason_code` STRING COMMENT 'Standardized code indicating the reason for the status change.',
    `transition_reason_description` STRING COMMENT 'Detailed explanation of why the policy status transition occurred.',
    `transition_timestamp` TIMESTAMP COMMENT 'The exact date and time when the policy status transition occurred.',
    `triggering_transaction_type` STRING COMMENT 'The type of policy transaction that caused this status transition. [ENUM-REF-CANDIDATE: new_business|renewal|endorsement|cancellation|reinstatement|non_renewal|lapse|expiration — 8 candidates stripped; promote to reference product]',
    `unearned_premium_returned_amount` DECIMAL(18,2) COMMENT 'Amount of unearned premium returned to insured due to cancellation or status change.',
    CONSTRAINT pk_status_history PRIMARY KEY(`status_history_id`)
) COMMENT 'Audit trail of all policy status transitions (active, cancelled, lapsed, expired, reinstated, non-renewed). Records prior status, new status, transition timestamp, and the triggering transaction reference.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` (
    `policy_form_id` BIGINT COMMENT 'Unique identifier for the policy form record.',
    `superseded_by_form_policy_form_id` BIGINT COMMENT 'Reference to the newer policy form that replaces this form, establishing form version lineage.',
    `approval_date` DATE COMMENT 'The date the form received regulatory approval from the state insurance department, allowing it to be used in policies.',
    `coverage_category` STRING COMMENT 'The broad coverage category this form provides or modifies, such as liability, property damage, bodily injury, medical payments, or uninsured motorist.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this policy form record was first created in the system.',
    `document_reference` STRING COMMENT 'Reference identifier or URI to the stored PDF or document image of the official form in the document management system.',
    `edition_date` DATE COMMENT 'The official edition or publication date of the form version, indicating when this form version was released by ISO or the carrier.',
    `effective_date` DATE COMMENT 'The date from which this form version becomes effective and can be bound on new or renewing policies.',
    `expiration_date` DATE COMMENT 'The date after which this form version is no longer available for new business, typically when superseded by a newer edition.',
    `filing_date` DATE COMMENT 'The date the form was filed with the state insurance department for regulatory approval.',
    `filing_status` STRING COMMENT 'Current regulatory filing status indicating whether the form is approved for use, pending state approval, withdrawn, rejected, or superseded by a newer version.. Valid values are `approved|pending|withdrawn|rejected|superseded`',
    `form_description` STRING COMMENT 'Detailed description of the coverage, exclusions, or modifications provided by this form, including key terms and conditions.',
    `form_name` STRING COMMENT 'The descriptive name of the policy form, such as Commercial General Liability Coverage Form or Homeowners Policy Special Form.',
    `form_number` STRING COMMENT 'The official form number assigned by ISO or carrier, such as CG 00 01 or HO 00 03, uniquely identifying the policy form document.. Valid values are `^[A-Z]{2,4}[s-]?[0-9]{2,4}[s-]?[0-9]{2,4}$`',
    `form_type` STRING COMMENT 'Classification of the form indicating its purpose: base coverage form, endorsement modifying coverage, exclusion limiting coverage, schedule, condition, or declaration page.. Valid values are `base|endorsement|exclusion|schedule|condition|declaration`',
    `iso_source_flag` BOOLEAN COMMENT 'Indicates whether this form originates from ISO standard forms or is a proprietary carrier-developed form.',
    `language` STRING COMMENT 'The full legal text and language of the policy form as filed with regulators, stored as a text field or reference to document storage.',
    `lob` STRING COMMENT 'The insurance line of business this form applies to, such as General Liability, Commercial Package Policy, Workers Compensation, or Auto. [ENUM-REF-CANDIDATE: GL|CGL|CPP|BOP|WC|CAT|auto|property|umbrella|professional_liability|inland_marine — 11',
    `mandatory_flag` BOOLEAN COMMENT 'Indicates whether this form is mandatory for the line of business or optional based on underwriting rules or state requirements.',
    `naic_code` STRING COMMENT 'The five-digit NAIC company code of the carrier that filed or uses this form, linking the form to the insurer.. Valid values are `^[0-9]{5}$`',
    `policy_form_status` STRING COMMENT 'Current lifecycle status of the form in the system: active and available for use, inactive but retained, archived for historical reference, or draft pending finalization.. Valid values are `active|inactive|archived|draft`',
    `premium_bearing_flag` BOOLEAN COMMENT 'Indicates whether this form carries an additional premium charge or is included at no extra cost.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this policy form record was last modified in the system.',
    `usage_count` BIGINT COMMENT 'The number of active policies currently using this form, providing insight into form adoption and usage trends.',
    CONSTRAINT pk_policy_form PRIMARY KEY(`policy_form_id`)
) COMMENT 'Reference catalog of policy forms and ISO form numbers used across LOBs: form number, edition date, form type (base, endorsement, exclusion), applicable states, and regulatory filing status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`condition` (
    `condition_id` BIGINT COMMENT 'Unique identifier for the policy condition record. Primary key.',
    `assigned_to_party_id` BIGINT COMMENT 'Reference to the party responsible for satisfying the condition, typically the insured or producer.',
    `policy_form_id` BIGINT COMMENT 'Foreign key linking to policy.policy_form. Business justification: Policy conditions reference specific forms via form_number and form_edition_date. Adding policy_form_id FK normalizes this relationship and removes redundant form identification.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy to which this condition is attached.',
    `regulatory_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Policy conditions may be state-mandated (e.g., California earthquake disclosure). FK to shared.state enables state-specific condition library and compliance tracking.',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to policy.uw_decision. Business justification: Policy conditions are often imposed by underwriting decisions (special requirements, warranties, exclusions). Adding uw_decision_id FK establishes which UW decision mandated the condition.',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Policy conditions are attached to specific policy versions (added via endorsements, removed via subsequent transactions). Currently uses policy_version_number (INT).',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason the condition was cancelled or removed from the policy.. Valid values are `CONDITION_SATISFIED|POLICY_CANCELLED|CONDITION_NO_LONGER_APPLICABLE|ERROR_CORRECTION|REPLACED_BY_ENDORSEMENT`',
    `condition_category` STRING COMMENT 'Timing category indicating when the condition applies: pre-bind, post-bind, ongoing during policy term, or at renewal.. Valid values are `PRE_BIND|POST_BIND|ONGOING|RENEWAL`',
    `compliance_due_date` DATE COMMENT 'Date by which the insured must satisfy or comply with the condition. Critical for underwriting and risk management tracking.',
    `compliance_flag` BOOLEAN COMMENT 'Indicator of whether the condition has been satisfied or is in compliance. True if satisfied, false if outstanding.',
    `condition_number` STRING COMMENT 'Business identifier for the condition, unique within the policy context. Used for external reference and communication.. Valid values are `^[A-Z0-9]{1,20}$`',
    `condition_status` STRING COMMENT 'Current lifecycle status of the condition: pending, satisfied, outstanding, waived, expired, or cancelled.. Valid values are `PENDING|SATISFIED|OUTSTANDING|WAIVED|EXPIRED|CANCELLED`',
    `coverage_impact_flag` BOOLEAN COMMENT 'Indicator of whether non-compliance with this condition affects coverage. True if coverage may be denied or restricted for non-compliance.',
    `created_by_user_code` STRING COMMENT 'User identifier of the person who created this condition record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this condition record was first created in the system.',
    `condition_description` STRING COMMENT 'Detailed narrative description of the condition, including specific requirements, actions, or restrictions imposed on the insured or policy.',
    `effective_date` DATE COMMENT 'Date when the condition becomes effective and binding on the policy.',
    `expiration_date` DATE COMMENT 'Date when the condition expires or is no longer applicable. Null for conditions that remain in force for the policy term.',
    `last_modified_by_user_code` STRING COMMENT 'User identifier of the person who last modified this condition record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this condition record was last updated.',
    `lob_code` STRING COMMENT 'Line of business code to which this condition applies, supporting multi-line policy condition management.. Valid values are `^[A-Z0-9]{2,10}$`',
    `mandatory_flag` BOOLEAN COMMENT 'Indicator of whether the condition is mandatory for policy binding or renewal. True if mandatory, false if optional or informational.',
    `notes` STRING COMMENT 'Free-text notes or comments related to the condition, including underwriter rationale, insured responses, or follow-up actions.',
    `premium_impact_flag` BOOLEAN COMMENT 'Indicator of whether satisfaction or non-compliance with this condition affects premium calculation or rating.',
    `regulatory_requirement_flag` BOOLEAN COMMENT 'Indicator of whether this condition is imposed to satisfy a regulatory or statutory requirement. True if regulatory-driven.',
    `satisfied_date` DATE COMMENT 'Date when the condition was marked as satisfied or fulfilled by the insured.',
    `source_document_reference` STRING COMMENT 'Reference number or identifier of the source document that triggered this condition.',
    `source_document_type` STRING COMMENT 'Type of document or source that triggered or justified the imposition of this condition.. Valid values are `INSPECTION_REPORT|LOSS_RUN|RISK_SURVEY|APPLICATION|ENDORSEMENT|REGULATORY_FILING`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this condition originated.. Valid values are `GUIDEWIRE_PC|DUCK_CREEK_POLICY|SAPIENS_IDIT|MANUAL_ENTRY`',
    `source_system_record_code` STRING COMMENT 'Unique identifier of this condition in the source operational system, supporting data lineage and reconciliation.',
    `text` STRING COMMENT 'Full legal or contractual text of the condition as it appears on the policy declarations page or endorsement.',
    `title` STRING COMMENT 'Short descriptive title of the condition for quick identification and reporting purposes.',
    `type_code` STRING COMMENT 'Classification of the condition: warranty, special condition, underwriting requirement, compliance requirement, risk improvement, or inspection.. Valid values are `WARRANTY|SPECIAL_CONDITION|UW_REQUIREMENT|COMPLIANCE_REQUIREMENT|RISK_IMPROVEMENT|INSPECTION`',
    `underwriter_code` BIGINT COMMENT 'Reference to the underwriter who imposed or approved this condition.',
    `waived_date` DATE COMMENT 'Date when the condition was waived by the underwriter or authorized party.',
    `waiver_approved_by_code` BIGINT COMMENT 'Reference to the underwriter or manager who approved the waiver of this condition.',
    `waiver_reason_code` STRING COMMENT 'Code indicating the reason the condition was waived, if applicable.. Valid values are `UW_DISCRETION|RISK_IMPROVEMENT_COMPLETED|ALTERNATIVE_MITIGATION|BUSINESS_DECISION|REGULATORY_EXEMPTION|ERROR_CORRECTION`',
    CONSTRAINT pk_condition PRIMARY KEY(`condition_id`)
) COMMENT 'Records special conditions, warranties, and UW requirements attached to a policy version: condition type, description, compliance due date, and whether the condition has been satisfied or is outstanding.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`document` (
    `document_id` BIGINT COMMENT 'Unique identifier for the policy document record. Primary key.',
    `user_account_id` BIGINT COMMENT 'User identifier of the person or system account that initiated document generation.',
    `policy_form_id` BIGINT COMMENT 'Foreign key linking to policy.policy_form. Business justification: Document references a specific policy form via form_number and form_edition_date. Adding policy_form_id FK normalizes this relationship and removes redundant form identification columns.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this document was generated.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Policy documents (DEC pages, endorsements, cancellation notices, binders, COIs) are generated for specific policy transactions.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the producer or agent associated with the policy for which this document was generated.',
    `recipient_country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: Document recipient country supports international policy servicing and cross-border delivery. FK to shared.country enforces valid country codes and enables international mailing rules.',
    `recipient_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Document recipient state determines delivery method compliance and notice period requirements. FK to shared.state enables state-specific document delivery rules.',
    `document_template_id` BIGINT COMMENT 'Identifier of the document template used to generate this document instance.',
    `underwriter_id` BIGINT COMMENT 'Reference to the underwriter who approved or reviewed the document issuance.',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Documents are generated for specific policy transactions/versions (DEC pages, endorsements, cancellation notices).',
    `approval_date` DATE COMMENT 'Date when the document was approved for issuance by an authorized user.',
    `approved_by_user_code` STRING COMMENT 'User identifier of the person who approved the document for issuance or delivery.',
    `certificate_holder_address` STRING COMMENT 'Full mailing address of the certificate holder for COI documents.',
    `certificate_holder_name` STRING COMMENT 'Name of the certificate holder for Certificate of Insurance (COI) documents.',
    `cms_reference_code` STRING COMMENT 'Reference identifier linking this document record to the stored file in the CMS (OpenText or FileNet).',
    `cms_url` STRING COMMENT 'Direct URL or path to retrieve the document file from the content management system.',
    `delivery_date` DATE COMMENT 'Date when the document was delivered or sent to the recipient.',
    `delivery_method` STRING COMMENT 'Method by which the document was or will be delivered to the policyholder or recipient.. Valid values are `email|postal_mail|portal|fax|in_person|electronic`',
    `delivery_status` STRING COMMENT 'Status of the document delivery process indicating whether delivery was successful.. Valid values are `pending|sent|delivered|failed|bounced`',
    `document_description` STRING COMMENT 'Detailed description of the document content, purpose, or scope for business context.',
    `document_status` STRING COMMENT 'Current lifecycle status of the document in the document management workflow.. Valid values are `draft|pending|issued|delivered|archived|voided`',
    `effective_date` DATE COMMENT 'Date when the document becomes effective or binding for the policy or endorsement.',
    `expiration_date` DATE COMMENT 'Date when the document expires or is no longer valid, typically aligned with policy term end.',
    `file_format` STRING COMMENT 'File format of the stored document (PDF, DOCX, HTML, XML, TXT).. Valid values are `PDF|DOCX|HTML|XML|TXT`',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes for storage and transmission tracking.',
    `generation_date` DATE COMMENT 'Date when the document was generated or created by the system or user.',
    `generation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the document was generated, including time zone information.',
    `language_code` STRING COMMENT 'Two-letter ISO language code indicating the language in which the document was generated.',
    `lob_code` STRING COMMENT 'Line of business code (e.g., GL, WC, BOP, CPP) associated with the policy document.',
    `number` STRING COMMENT 'Business-assigned unique document number or control identifier for tracking and reference.',
    `page_count` BIGINT COMMENT 'Total number of pages in the document for printing and archival purposes.',
    `recipient_address_line1` STRING COMMENT 'First line of the recipient mailing address for postal document delivery.',
    `recipient_address_line2` STRING COMMENT 'Second line of the recipient mailing address for additional address details.',
    `recipient_city` STRING COMMENT 'City name of the recipient mailing address.',
    `recipient_email` STRING COMMENT 'Email address of the recipient for electronic document delivery.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `recipient_name` STRING COMMENT 'Name of the individual or entity to whom the document was addressed or delivered.',
    `recipient_postal_code` STRING COMMENT 'Postal or ZIP code of the recipient mailing address.',
    `regulatory_state_code` STRING COMMENT 'Two-letter state code indicating the regulatory jurisdiction governing this document.',
    `signature_date` DATE COMMENT 'Date when the document was signed by the policyholder or authorized party.',
    `signature_received_flag` BOOLEAN COMMENT 'Indicates whether the required signature has been received and recorded.',
    `signature_required_flag` BOOLEAN COMMENT 'Indicates whether the document requires a signature from the policyholder or other party.',
    `source_system_code` STRING COMMENT 'Code identifying the source system that generated the document (e.g., PolicyCenter, Duck Creek Policy).',
    `template_version` STRING COMMENT 'Version number of the document template used for generation and audit trail.',
    `title` STRING COMMENT 'Human-readable title or name of the document for display and identification purposes.',
    `type_code` STRING COMMENT 'Type of policy document: DEC (Declarations Page), ENDT (Endorsement), CANC (Cancellation Notice), BINDER, COI (Certificate of Insurance), RENEWAL.. Valid values are `DEC|ENDT|CANC|BINDER|COI|RENEWAL`',
    CONSTRAINT pk_document PRIMARY KEY(`document_id`)
) COMMENT 'Metadata registry for policy documents: DEC page instance, ENDT, CANC notice, binder, and COI. Stores document type, DEC snapshot fields, certificate-holder details, generation date, delivery method, and CMS reference.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`binder` (
    `binder_id` BIGINT COMMENT 'Unique identifier for the temporary insurance binder record.',
    `binder_producers_producer_id` BIGINT COMMENT 'Reference to the agent or broker who issued the binder under binding authority.',
    `binder_producers_producers_producer_id` BIGINT COMMENT 'Reference to the underwriter who authorized or will review the binder for policy conversion.',
    `binding_authority_id` BIGINT COMMENT 'Reference to the binding authority agreement under which this binder was issued.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Binder estimated premium is denominated in a currency. FK to shared.currency supports multi-currency binding authority and premium conversion.',
    `mailing_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Binder mailing state determines delivery compliance for binding authority documentation. FK to shared.state enables state-specific binder issuance rules.',
    `policy_form_id` BIGINT COMMENT 'Foreign key linking to policy.policy_form. Business justification: Binder references policy forms via form_numbers (denormalized STRING). Adding FK to primary policy_form enables proper form resolution.',
    `policy_id` BIGINT COMMENT 'Reference to the formal policy that will replace this binder upon issuance.',
    `policy_insured_id` BIGINT COMMENT 'Reference to the party entity representing the insured individual or organization.',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to policy.policy_transaction. Business justification: Binders are temporary insurance instruments that get converted to formal policies through a policy transaction. This FK tracks which transaction converted/formalized the binder.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to policy.quote. Business justification: Binder is issued based on an accepted quote. Business flow: submission → quote → binder → policy. Tracking the originating quote provides critical lineage for the binder.',
    `source_binder_id` BIGINT COMMENT 'Original binder identifier from the source system before transformation to enterprise standard.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to policy.submission. Business justification: Binder originates from a submission (the application for coverage). Business flow: submission → quote → binder → policy.',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Binders represent a specific version of coverage terms and conditions. When a binder is issued, it should be associated with a policy version to track the exact terms, coverages, and premium',
    `binder_status` STRING COMMENT 'Current lifecycle status of the binder indicating whether it is active, converted to policy, or terminated.. Valid values are `active|expired|converted|cancelled|voided|pending`',
    `binding_timestamp` TIMESTAMP COMMENT 'Precise date and time when the binder was bound and coverage was confirmed by the producer.',
    `cancellation_date` DATE COMMENT 'Date when the binder was cancelled, voiding coverage before the scheduled expiration.',
    `cancellation_reason_code` STRING COMMENT 'Code indicating the reason if the binder was cancelled before conversion or expiration.. Valid values are `^[A-Z0-9]{2,6}$`',
    `conversion_date` DATE COMMENT 'Date when the binder was converted to a formal policy, marking the end of temporary coverage status.',
    `coverage_summary` STRING COMMENT 'Brief narrative description of the coverages, limits, and perils included in the temporary binder.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this binder record was first created in the enterprise data platform.',
    `declaration_page_url` STRING COMMENT 'URL or document path to the binder declarations page stored in the document management system.. Valid values are `^https?://.*`',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Amount the insured must pay out-of-pocket before coverage under the binder applies.',
    `effective_date` DATE COMMENT 'Date when coverage under the temporary binder becomes effective and risk transfer begins.',
    `endorsement_numbers` STRING COMMENT 'Comma-separated list of endorsement form numbers modifying the standard binder coverage.',
    `estimated_premium_amount` DECIMAL(18,2) COMMENT 'Preliminary premium amount charged for the temporary binder coverage period.',
    `expiration_date` DATE COMMENT 'Date when the temporary binder coverage expires and must be replaced by a formal policy or terminated.',
    `form_numbers` STRING COMMENT 'Comma-separated list of ISO or proprietary form numbers attached to the binder for coverage terms.',
    `lob_code` STRING COMMENT 'Code identifying the insurance line of business covered by this binder such as GL, WC, CPP, or BOP.. Valid values are `^[A-Z]{2,6}$`',
    `mailing_address_line1` STRING COMMENT 'Primary street address line for the insured party on the binder declarations.',
    `mailing_address_line2` STRING COMMENT 'Secondary address line for suite, unit, or apartment number on the binder declarations.',
    `mailing_city` STRING COMMENT 'City name for the insured party mailing address on the binder.',
    `mailing_postal_code` STRING COMMENT 'ZIP or postal code for the insured party mailing address on the binder.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `named_insured` STRING COMMENT 'Full legal name of the primary insured party covered under this temporary binder.',
    `notes` STRING COMMENT 'Free-text notes or special instructions related to the binder issuance, coverage, or conversion requirements.',
    `number` STRING COMMENT 'Externally-known unique business identifier for the temporary binder document.. Valid values are `^BND-[A-Z0-9]{8,15}$`',
    `per_occurrence_limit_amount` DECIMAL(18,2) COMMENT 'Maximum amount payable for any single occurrence or claim event under the binder.',
    `regulatory_state_code` STRING COMMENT 'Two-letter code for the state Department of Insurance with jurisdiction over this binder.. Valid values are `^[A-Z]{2}$`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this binder such as PolicyCenter or Duck Creek.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `total_limit_amount` DECIMAL(18,2) COMMENT 'Aggregate limit of liability provided under the binder across all covered perils and exposures.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this binder record was last modified in the enterprise data platform.',
    CONSTRAINT pk_binder PRIMARY KEY(`binder_id`)
) COMMENT 'Temporary insurance binder record providing coverage confirmation prior to formal policy issuance. Captures binder number, effective date, expiration date, coverage summary, and binding authority used.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` (
    `policy_rate_filing_id` BIGINT COMMENT 'Unique identifier for the rate filing record. Primary key.',
    `policy_form_id` BIGINT COMMENT 'Foreign key linking to policy.policy_form. Business justification: Rate filings include policy forms (form_numbers_included is a denormalized STRING list). Adding FK to primary policy_form enables linking the filing to its primary form.',
    `prior_filing_policy_rate_filing_id` BIGINT COMMENT 'Reference to the previous rate filing that this submission replaces, supersedes, or amends, establishing filing lineage.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Rate filing state is the regulatory jurisdiction for rate approval. FK to shared.state enables state-specific filing workflow, deemer date calculation, and DOI contact lookup.',
    `actuarial_justification_summary` STRING COMMENT 'Brief summary of the actuarial analysis and loss experience supporting the rate change, including loss ratio trends and expense considerations.',
    `affected_policy_count` BIGINT COMMENT 'Number of in-force policies expected to be impacted by the rate filing at renewal or endorsement.',
    `approval_date` DATE COMMENT 'Date the state regulator officially approved the rate filing, allowing the insurer to implement the rates and forms.',
    `company_code` STRING COMMENT 'Internal or NAIC company code identifying the legal insurance entity submitting the rate filing.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the rate filing record was first created in the system, supporting audit trail and data lineage requirements.',
    `deemer_date` DATE COMMENT 'Date on which the filing is deemed approved by operation of law if the regulator has not acted within the statutory review period.',
    `effective_date` DATE COMMENT 'Date on which the approved rates and forms become effective and may be used for new business and renewals.',
    `expiration_date` DATE COMMENT 'Date on which the filed rates and forms expire and are no longer valid for new business, if applicable.',
    `filing_contact_email` STRING COMMENT 'Email address of the filing contact for regulatory correspondence and questions regarding the rate filing.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `filing_contact_name` STRING COMMENT 'Name of the actuary or regulatory affairs professional responsible for this filing and serving as primary contact with the state regulator.',
    `filing_contact_phone` STRING COMMENT 'Phone number of the filing contact for regulatory inquiries and follow-up discussions regarding the rate filing.',
    `filing_method` STRING COMMENT 'Regulatory filing method required by the state indicating whether rates must be approved before use or may be implemented immediately.. Valid values are `file_and_use|use_and_file|prior_approval|flex_rating|no_file`',
    `filing_number` STRING COMMENT 'External filing number assigned by the state Department of Insurance (DOI) or insurer for tracking and reference purposes.',
    `filing_status` STRING COMMENT 'Current regulatory approval status of the rate filing in the state review and approval workflow. [ENUM-REF-CANDIDATE: draft|submitted|under_review|approved|rejected|withdrawn|objected|deemer_approved — 8 candidates stripped; promote to reference product]',
    `filing_type` STRING COMMENT 'Category of the filing submission indicating whether it is a rate change, form update, rule modification, or combination thereof.. Valid values are `rate|form|rule|rate_and_form|rate_and_rule|informational`',
    `form_numbers_included` STRING COMMENT 'Comma-separated list of policy form numbers and endorsement form numbers included in this filing for regulatory approval.',
    `iso_program_edition_date` DATE COMMENT 'Edition date of the ISO program being adopted or referenced in this filing, if applicable.',
    `iso_program_indicator` BOOLEAN COMMENT 'Flag indicating whether this filing adopts or references ISO standard forms and rates or represents a proprietary insurer program.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the rate filing record, tracking changes throughout the regulatory review lifecycle.',
    `lob_code` STRING COMMENT 'Code identifying the insurance line of business covered by this filing such as personal auto, homeowners, commercial property, general liability, or workers compensation.',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code uniquely identifying the insurance legal entity for regulatory reporting and filing purposes.. Valid values are `^[0-9]{5}$`',
    `objection_reason` STRING COMMENT 'Explanation provided by the state regulator for objecting to or rejecting the rate filing, including specific deficiencies or concerns.',
    `overall_rate_change_percent` DECIMAL(5,2) COMMENT 'Percentage change in overall premium rates proposed in this filing, expressed as a signed decimal where positive indicates increase and negative indicates decrease.',
    `projected_premium_impact_amount` DECIMAL(15,2) COMMENT 'Estimated dollar impact on total written premium resulting from the rate change, used for regulatory and financial planning purposes.',
    `rate_change_type` STRING COMMENT 'Indicates whether the filing represents an overall rate increase, decrease, no change, or introduction of a new rating program.. Valid values are `increase|decrease|no_change|new_program`',
    `regulatory_review_days` BIGINT COMMENT 'Number of calendar days the filing has been under regulatory review, used to track compliance with statutory review period limits.',
    `resubmission_flag` BOOLEAN COMMENT 'Indicates whether this filing is a resubmission of a previously objected or withdrawn filing with modifications addressing regulator concerns.',
    `serff_tracking_number` STRING COMMENT 'Unique tracking number assigned by the SERFF system for electronic rate and form submissions to state regulators.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this rate filing data originated, such as rating engine or regulatory management system.',
    `submission_date` DATE COMMENT 'Date the rate filing was officially submitted to the state Department of Insurance for regulatory review.',
    `supporting_document_url` STRING COMMENT 'Reference URL or document management system path to the complete actuarial memorandum, rate manual, and supporting exhibits filed with the regulator.',
    `withdrawal_date` DATE COMMENT 'Date the insurer voluntarily withdrew the rate filing from regulatory consideration before approval or rejection.',
    CONSTRAINT pk_policy_rate_filing PRIMARY KEY(`policy_rate_filing_id`)
) COMMENT 'Reference record for approved rate and form filings with state DOIs. Tracks filing number, LOB, effective date, state, filing type (rate, rule, form), approval status, and SERFF tracking number.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` (
    `policy_transaction_id` BIGINT COMMENT 'Unique identifier for each policy transaction record in the system.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Policy transaction amounts (written_premium_amount, premium_change_amount, tax_amount, fee_amount, total_transaction_amount) are denominated in a currency.',
    `policy_form_id` BIGINT COMMENT 'Foreign key linking to policy.policy_form. Business justification: Policy transactions reference forms (endorsement forms, cancellation forms). Currently stores form_number and form_edition_date.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy for which this transaction was executed.',
    `prior_transaction_policy_transaction_id` BIGINT COMMENT 'Reference to the previous transaction in the policy version chain for audit trail and lineage.',
    `producers_producer_id` BIGINT COMMENT 'Reference to the agent or broker who serviced this transaction.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to policy.quote. Business justification: New business (NB) transactions are based on accepted quotes. The quote contains the rated premium and coverage terms that the NB transaction executes.',
    `regulatory_state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Transaction regulatory state determines premium tax rate and statutory accounting treatment. FK to shared.state enables state-specific transaction processing and tax calculation.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to policy.submission. Business justification: New business (NB) transactions originate from underwriting submissions. Tracking the originating submission for NB transactions provides critical lineage from application to bound policy.',
    `version_id` BIGINT COMMENT 'Foreign key linking to policy.version. Business justification: Policy transactions create version snapshots (NB creates version 1, ENDT creates version 2, etc.). Adding version_id FK establishes which version the transaction created.',
    `audit_type` STRING COMMENT 'Type of audit conducted when transaction type is audit, determining premium adjustment methodology.. Valid values are `premium_audit|physical_audit|final_audit|interim_audit`',
    `booking_date` DATE COMMENT 'Accounting date when the transaction was booked for financial and statutory reporting purposes.',
    `cancellation_type` STRING COMMENT 'Type of cancellation method applied when transaction type is cancellation, determining premium refund calculation. [ENUM-REF-CANDIDATE: flat|short_rate|pro_rata|insured_request|non_payment|underwriting|fraud — 7 candidates stripped; promote to reference',
    `commission_amount` DECIMAL(15,2) COMMENT 'Total commission amount earned by the producer on this transaction.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Commission percentage rate applied to this transaction for producer compensation calculation.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this transaction record was first created in the database.',
    `declaration_page_generated_flag` BOOLEAN COMMENT 'Indicates whether a declarations page was generated and issued for this transaction.',
    `declaration_page_url` STRING COMMENT 'Document management system URL or path to the generated declarations page for this transaction.',
    `effective_date` DATE COMMENT 'Date when the transaction becomes effective and coverage or changes take effect.',
    `expiration_date` DATE COMMENT 'Date when the transaction or resulting policy version expires.',
    `fee_amount` DECIMAL(15,2) COMMENT 'Total fees charged for this transaction including policy fees, endorsement fees, and administrative charges.',
    `initiating_party_type` STRING COMMENT 'Type of party who initiated or requested this transaction.. Valid values are `insured|insurer|producer|underwriter|system|regulator`',
    `initiating_user_code` STRING COMMENT 'System user identifier of the person who created or initiated this transaction.',
    `lob_code` STRING COMMENT 'Code identifying the line of business for this transaction such as Commercial Auto, General Liability, or Workers Compensation.',
    `notice_compliance_flag` BOOLEAN COMMENT 'Indicates whether required notice period was met for regulatory and contractual compliance.',
    `notice_date` DATE COMMENT 'Date when notice of the transaction was sent to the insured or other parties as required by policy terms or regulation.',
    `notice_days_required` BIGINT COMMENT 'Number of days advance notice required by policy terms or state regulation for this transaction type.',
    `premium_change_amount` DECIMAL(15,2) COMMENT 'Net change in premium resulting from this transaction, positive for increases and negative for decreases.',
    `reason_code` STRING COMMENT 'Code indicating the business reason for the transaction such as coverage change, rate revision, or insured request.',
    `reason_description` STRING COMMENT 'Detailed explanation of why the transaction was initiated or what changes were made.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this transaction reverses or voids a prior transaction.',
    `reversal_reason` STRING COMMENT 'Explanation of why this transaction was reversed or voided.',
    `source_system_code` STRING COMMENT 'Code identifying the originating system that created this transaction record.',
    `source_transaction_id` STRING COMMENT 'Original transaction identifier from the source system for reconciliation and traceability.',
    `tax_amount` DECIMAL(15,2) COMMENT 'Total tax amount assessed on this transaction including state premium taxes and surplus lines taxes.',
    `total_transaction_amount` DECIMAL(15,2) COMMENT 'Total amount due or refunded for this transaction including premium, taxes, and fees.',
    `transaction_number` STRING COMMENT 'Business-facing unique transaction number displayed on declarations and endorsements.',
    `transaction_status` STRING COMMENT 'Current lifecycle status of the transaction indicating its processing state. [ENUM-REF-CANDIDATE: draft|quoted|bound|issued|voided|declined|withdrawn — 7 candidates stripped; promote to reference product]',
    `transaction_timestamp` TIMESTAMP COMMENT 'Precise date and time when the transaction was executed or recorded in the system.',
    `type_code` STRING COMMENT 'Code indicating the type of policy transaction: New Business, Renewal, Endorsement, Cancellation, Reinstatement, Non-Renewal, Rewrite, Audit, or Flat Cancellation.',
    `underwriter_code` BIGINT COMMENT 'Reference to the underwriter who reviewed and approved this transaction.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this transaction record was last modified.',
    `written_premium_amount` DECIMAL(15,2) COMMENT 'Total premium amount written for this transaction before any adjustments or cessions.',
    CONSTRAINT pk_policy_transaction PRIMARY KEY(`policy_transaction_id`)
) COMMENT 'Unified transaction ledger per policy version: transaction type (NB, ENDT, CANC, REN, reinstatement, non-renewal), effective date, premium impact, reason code, initiating party, form/ISO reference, and notice-compliance fields.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` (
    `location_condition_id` BIGINT COMMENT 'Unique identifier for this location-condition association record. Primary key.',
    `condition_id` BIGINT COMMENT 'Foreign key linking to the policy condition imposed on this location',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to the insured location subject to this condition',
    `policy_condition_id` BIGINT COMMENT 'Foreign key to the policy condition imposed on this location',
    `compliance_due_date` DATE COMMENT 'Date by which this specific location must satisfy this condition',
    `compliance_flag` BOOLEAN COMMENT 'Indicator of whether this location is in compliance with this condition',
    `created_by_user_code` STRING COMMENT 'User who created this location-condition association record',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this location-condition association was created',
    `inspection_required_flag` BOOLEAN COMMENT 'Indicator of whether physical inspection is required to verify compliance at this location',
    `last_inspection_date` DATE COMMENT 'Date of most recent inspection to verify condition compliance at this location',
    `notes` STRING COMMENT 'Free-text notes specific to this location-condition combination',
    `satisfied_date` DATE COMMENT 'Date when this location satisfied this condition requirement',
    `waived_date` DATE COMMENT 'Date when this condition was waived for this location',
    `waiver_reason_code` STRING COMMENT 'Code indicating why this condition was waived for this specific location',
    CONSTRAINT pk_location_condition PRIMARY KEY(`location_condition_id`)
) COMMENT 'Association between policy conditions and insured locations. Tracks compliance status, due dates, and satisfaction for underwriting requirements imposed on specific premises..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` (
    `vehicle_form_application_id` BIGINT COMMENT 'Unique identifier for this vehicle form application record. Primary key.',
    `form_policy_form_id` BIGINT COMMENT 'Foreign key linking to the policy form applied to this vehicle',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to the insured vehicle to which this form applies',
    `application_policy_form_id` BIGINT COMMENT 'Foreign key to the policy form applied to this vehicle',
    `application_reason` STRING COMMENT 'Business reason why this form was applied to the vehicle: new business, renewal, endorsement, mid-term change, or regulatory requirement',
    `application_timestamp` TIMESTAMP COMMENT 'Date and time when this form was applied to the vehicle in the policy administration system',
    `applied_by_user_code` BIGINT COMMENT 'Reference to the underwriter or system user who applied this form to the vehicle',
    `effective_date` DATE COMMENT 'Date from which this form becomes effective for this specific vehicle, may differ from policy effective date for mid-term changes',
    `expiration_date` DATE COMMENT 'Date on which this form application expires or is removed from the vehicle',
    `mandatory_flag` BOOLEAN COMMENT 'Indicates whether this form is mandatory for this vehicle based on state regulations, vehicle type, or coverage selections',
    `premium_impact_amount` DECIMAL(15,2) COMMENT 'Additional premium or credit amount associated with applying this form to this vehicle, zero if form is included in base premium',
    `state_specific_version` STRING COMMENT 'State-specific version identifier when the form has variations by state, critical for regulatory compliance',
    `vehicle_form_application_status` STRING COMMENT 'Current lifecycle status of this form application: active, pending approval, expired, cancelled, or superseded by newer version',
    CONSTRAINT pk_vehicle_form_application PRIMARY KEY(`vehicle_form_application_id`)
) COMMENT 'Association between policy forms and insured vehicles, tracking which forms apply to each vehicle with effective dates, mandatory status, and state-specific versions for regulatory compliance and coverage verification..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` (
    `premium_cession_allocation_id` BIGINT COMMENT 'Unique identifier for each premium cession allocation record',
    `ceded_premium_transaction_id` BIGINT COMMENT 'Foreign key linking to the reinsurance ceded premium transaction receiving the allocated premium',
    `policy_transaction_id` BIGINT COMMENT 'Foreign key linking to the direct policy transaction whose premium is being ceded',
    `accounting_period` STRING COMMENT 'Accounting period (YYYY-MM or YYYY-Q#) to which this premium allocation is attributed for bordereaux reporting',
    `allocated_premium_amount` DECIMAL(18,2) COMMENT 'Dollar amount of premium from the policy transaction allocated to this ceded premium transaction',
    `allocation_created_by_user_code` STRING COMMENT 'User identifier of the reinsurance accountant who created this allocation record',
    `allocation_created_timestamp` TIMESTAMP COMMENT 'System timestamp when this premium allocation record was created',
    `allocation_effective_date` DATE COMMENT 'Date when this premium allocation becomes effective for reinsurance accounting purposes',
    `allocation_status` STRING COMMENT 'Current lifecycle status of this premium allocation record from draft through settlement',
    `bordereaux_submission_date` DATE COMMENT 'Date when this allocation was included in a bordereaux submission to the reinsurer',
    `cession_percentage` DECIMAL(7,4) COMMENT 'Percentage of the policy transaction premium allocated to this specific ceded premium transaction under treaty or FAC terms',
    `premium_allocation_basis` STRING COMMENT 'Method used to allocate premium between policy and ceded transactions: written basis, earned basis, pro-rata, or risk-attaching basis',
    CONSTRAINT pk_premium_cession_allocation PRIMARY KEY(`premium_cession_allocation_id`)
) COMMENT 'Association product representing the allocation of direct policy premium transactions to reinsurance ceded premium transactions. Each record links one policy transaction to one ceded premium transaction with cession-specific allocation attributes..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` (
    `coverage_cession_id` BIGINT COMMENT 'Unique surrogate identifier for each coverage-cession allocation record.',
    `policy_coverage_id` BIGINT COMMENT 'Foreign key linking to the specific policy coverage being ceded to reinsurance.',
    `reinsurance_cession_id` BIGINT COMMENT 'Foreign key linking to the reinsurance cession transaction accepting the ceded risk.',
    `attachment_point` DECIMAL(18,2) COMMENT 'Dollar threshold at which this cession begins to respond for losses under this specific coverage, enabling coverage-specific excess of loss structures.',
    `ceded_limit_amount` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery limit for this specific coverage under this cession, reflecting the layer or share allocated to this coverage-cession pairing.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Portion of the coverage premium ceded to the reinsurer under this specific cession transaction.',
    `ceded_share_pct` DECIMAL(7,4) COMMENT 'Percentage of this specific coverage ceded to the reinsurer under this cession transaction, enabling pro-rata allocation across multiple treaties.',
    `coverage_cession_status` STRING COMMENT 'Current lifecycle state of this coverage-cession allocation, supporting workflow management and audit trails.',
    `coverage_layer_allocation` STRING COMMENT 'Identifies the reinsurance layer or structure to which this coverage is allocated under this cession, such as primary, working excess, or catastrophe excess.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage-cession allocation record was first created in the reinsurance management system.',
    `effective_date` DATE COMMENT 'Date when this coverage-cession allocation becomes effective, which may differ from the underlying policy coverage or treaty effective dates.',
    `expiry_date` DATE COMMENT 'Date when this coverage-cession allocation expires, supporting mid-term treaty changes or coverage-specific cession adjustments.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Cedant retained loss amount for this coverage before this cession responds, supporting coverage-specific retention strategies.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this coverage-cession allocation, supporting audit and change tracking.',
    CONSTRAINT pk_coverage_cession PRIMARY KEY(`coverage_cession_id`)
) COMMENT 'Junction table resolving the M:N relationship between policy coverages and reinsurance cessions. Captures coverage-specific ceded limits, share percentages, layer allocations, and effective dates for each coverage-cession pairing..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` (
    `form_filing_id` BIGINT COMMENT 'Unique identifier for the form filing record',
    `form_policy_form_id` BIGINT COMMENT 'Foreign key linking to the policy form being filed',
    `policy_form_id` BIGINT COMMENT 'Foreign key to the policy form being filed in this state',
    `state_id` BIGINT COMMENT 'Foreign key linking to the state where the form is filed',
    `applicable_states` STRING COMMENT 'Comma-separated list of US state codes where this form is approved for use, such as CA,NY,TX. Empty if approved nationwide. [Moved from policy_form: This comma-separated list is a denormalized representation of the many-to-many relationship.',
    `approval_date` DATE COMMENT 'Date the form received regulatory approval from this state',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this filing record was created in the system',
    `effective_date` DATE COMMENT 'Date from which this form version becomes effective in this state',
    `expiration_date` DATE COMMENT 'Date after which this form version is no longer available in this state',
    `filing_date` DATE COMMENT 'Date the form was filed with this states insurance department',
    `filing_status` STRING COMMENT 'Current regulatory filing status for this form in this state',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this filing record was last modified',
    CONSTRAINT pk_form_filing PRIMARY KEY(`form_filing_id`)
) COMMENT 'Represents the regulatory filing and approval of a policy form in a specific state. Each record tracks the filing status, approval dates, and effective period for one form-state combination managed by compliance teams..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` (
    `document_template_id` BIGINT COMMENT 'Primary key for document_template',
    `predecessor_template_id` BIGINT COMMENT 'Reference to the previous version of this template in the version history chain.',
    `acord_form_number` STRING COMMENT 'Standard ACORD form number if this template is based on an industry-standard form.',
    `approved_by` STRING COMMENT 'User identifier of the person who approved this template for production use.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this template was approved for production use.',
    `checksum` STRING COMMENT 'SHA-256 hash of the template content for integrity verification and change detection.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this template record was first created in the system.',
    `delivery_method` STRING COMMENT 'Primary method by which documents generated from this template are delivered.',
    `document_template_description` STRING COMMENT 'Detailed business description of the templates purpose, usage, and applicability.',
    `effective_date` DATE COMMENT 'Date when this template version becomes available for use in policy document generation.',
    `expiration_date` DATE COMMENT 'Date when this template version is no longer valid for new document generation.',
    `file_format` STRING COMMENT 'Output file format produced when this template is rendered.',
    `is_customer_facing` BOOLEAN COMMENT 'Indicates whether this template generates documents delivered directly to policyholders.',
    `is_default` BOOLEAN COMMENT 'Indicates whether this is the default template for its type and line of business combination.',
    `iso_form_number` STRING COMMENT 'Insurance Services Office form number if this template uses ISO standard language.',
    `jurisdiction_code` STRING COMMENT 'Two-letter state or province code where this template is approved for use.',
    `language_code` STRING COMMENT 'Two-letter ISO language code indicating the primary language of the template content.',
    `last_modified_by` STRING COMMENT 'User identifier of the person who last modified this template record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this template record was last updated.',
    `last_used_date` DATE COMMENT 'Most recent date this template was used to generate a document.',
    `line_of_business` STRING COMMENT 'Insurance line of business this template applies to, such as personal or commercial lines.',
    `merge_field_count` BIGINT COMMENT 'Number of dynamic merge fields or placeholders in the template requiring data injection.',
    `notes` STRING COMMENT 'Additional notes or comments about the template for internal reference and documentation.',
    `page_count` BIGINT COMMENT 'Number of pages in the rendered template document.',
    `print_specification` STRING COMMENT 'Printing requirements for documents generated from this template.',
    `regulatory_approval_date` DATE COMMENT 'Date when regulatory approval was granted for this template.',
    `regulatory_approval_number` STRING COMMENT 'State insurance department approval or filing number for this template.',
    `regulatory_approval_required` BOOLEAN COMMENT 'Indicates whether this template requires state insurance department approval before use.',
    `requires_signature` BOOLEAN COMMENT 'Indicates whether documents generated from this template require policyholder signature.',
    `retention_period_years` BIGINT COMMENT 'Number of years documents generated from this template must be retained per policy.',
    `signature_type` STRING COMMENT 'Type of signature required for documents generated from this template.',
    `document_template_status` STRING COMMENT 'Current lifecycle status of the document template indicating availability for use.',
    `template_category` STRING COMMENT 'Broad category classification of the template by document function.',
    `template_code` STRING COMMENT 'Unique business code identifying the template across systems and business units.',
    `template_content_path` STRING COMMENT 'Storage location or URI reference to the physical template file or content.',
    `template_name` STRING COMMENT 'Human-readable name of the document template for business user identification.',
    `template_type` STRING COMMENT 'Classification of the template by document purpose within the policy lifecycle.',
    `template_version` STRING COMMENT 'Version number of the template following semantic versioning convention.',
    `usage_count` BIGINT COMMENT 'Total number of times this template has been used to generate documents.',
    `created_by` STRING COMMENT 'User identifier of the person who created this template record.',
    CONSTRAINT pk_document_template PRIMARY KEY(`document_template_id`)
) COMMENT 'Master reference table for document_template. Referenced by template_id.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` (
    `underwriter_id` BIGINT COMMENT 'Primary key for underwriter',
    `supervisor_underwriter_id` BIGINT COMMENT 'Identifier of the senior underwriter or manager who supervises this underwriter and reviews escalated submissions.',
    `authority_level` STRING COMMENT 'Binding authority tier that determines the maximum premium, risk exposure, and policy complexity the underwriter can approve without escalation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the underwriter record was first created in the system.',
    `email_address` STRING COMMENT 'Primary business email address for the underwriter used for policy correspondence and internal communication.',
    `first_name` STRING COMMENT 'Legal first name of the underwriter.',
    `hire_date` DATE COMMENT 'Date the underwriter was hired or contracted by the organization.',
    `home_office_location` STRING COMMENT 'Primary office location or branch where the underwriter is based for operational and reporting purposes.',
    `last_name` STRING COMMENT 'Legal last name of the underwriter.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal performance review or evaluation conducted for the underwriter.',
    `license_effective_date` DATE COMMENT 'Date when the underwriter license became effective and valid for binding coverage.',
    `license_expiration_date` DATE COMMENT 'Date when the underwriter license expires and requires renewal to continue binding authority.',
    `license_number` STRING COMMENT 'State or regulatory authority issued license number authorizing the underwriter to bind insurance policies.',
    `license_state` STRING COMMENT 'Two-letter state code where the underwriter holds their primary insurance license.',
    `maximum_exposure_authority` DECIMAL(18,2) COMMENT 'Maximum total insured value or limit of liability the underwriter is authorized to bind on a single risk or policy without escalation.',
    `maximum_premium_authority` DECIMAL(15,2) COMMENT 'Maximum annual premium amount the underwriter is authorized to bind without requiring senior approval or referral.',
    `performance_rating` STRING COMMENT 'Most recent performance evaluation rating reflecting the underwriter quality of risk selection, loss ratio, and productivity.',
    `phone_number` STRING COMMENT 'Primary business phone number for the underwriter.',
    `professional_designations` STRING COMMENT 'Industry certifications and professional designations held by the underwriter such as CPCU, AU, ARe, or CIC.',
    `region` STRING COMMENT 'Geographic region or territory the underwriter is assigned to for policy binding and risk evaluation.',
    `specialization` STRING COMMENT 'Primary line of business or risk specialty area the underwriter is trained and authorized to evaluate, such as commercial property, personal auto, or workers compensation.',
    `termination_date` DATE COMMENT 'Date the underwriter employment or contract was terminated. Null if currently active.',
    `underwriter_code` STRING COMMENT 'Business identifier code assigned to the underwriter for external reference and system integration.',
    `underwriter_status` STRING COMMENT 'Current employment and authorization status of the underwriter within the organization.',
    `underwriter_type` STRING COMMENT 'Classification of the underwriter role indicating employment relationship and seniority level.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the underwriter record was last modified or updated in the system.',
    `years_of_experience` BIGINT COMMENT 'Total number of years the underwriter has worked in insurance underwriting across all employers and lines of business.',
    CONSTRAINT pk_underwriter PRIMARY KEY(`underwriter_id`)
) COMMENT 'Master reference table for underwriter. Referenced by underwriter_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_source_policy_id` FOREIGN KEY (`source_policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ADD CONSTRAINT `fk_policy_version_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ADD CONSTRAINT `fk_policy_version_prior_version_id` FOREIGN KEY (`prior_version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ADD CONSTRAINT `fk_policy_policy_coverage_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ADD CONSTRAINT `fk_policy_policy_coverage_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ADD CONSTRAINT `fk_policy_policy_coverage_prior_coverage_id` FOREIGN KEY (`prior_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_coverage`(`policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ADD CONSTRAINT `fk_policy_policy_coverage_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ADD CONSTRAINT `fk_policy_policy_insured_insured_id` FOREIGN KEY (`insured_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`insured`(`insured_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ADD CONSTRAINT `fk_policy_policy_insured_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`insured` ADD CONSTRAINT `fk_policy_insured_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_policy_insured_id` FOREIGN KEY (`policy_insured_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_insured`(`policy_insured_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ADD CONSTRAINT `fk_policy_uw_decision_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ADD CONSTRAINT `fk_policy_uw_decision_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ADD CONSTRAINT `fk_policy_uw_decision_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ADD CONSTRAINT `fk_policy_quote_parent_quote_id` FOREIGN KEY (`parent_quote_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ADD CONSTRAINT `fk_policy_quote_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ADD CONSTRAINT `fk_policy_quote_policy_insured_id` FOREIGN KEY (`policy_insured_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_insured`(`policy_insured_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ADD CONSTRAINT `fk_policy_submission_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ADD CONSTRAINT `fk_policy_submission_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ADD CONSTRAINT `fk_policy_status_history_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ADD CONSTRAINT `fk_policy_status_history_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ADD CONSTRAINT `fk_policy_status_history_reversed_by_status_history_id` FOREIGN KEY (`reversed_by_status_history_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`status_history`(`status_history_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ADD CONSTRAINT `fk_policy_status_history_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ADD CONSTRAINT `fk_policy_policy_form_superseded_by_form_policy_form_id` FOREIGN KEY (`superseded_by_form_policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ADD CONSTRAINT `fk_policy_condition_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ADD CONSTRAINT `fk_policy_condition_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ADD CONSTRAINT `fk_policy_condition_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ADD CONSTRAINT `fk_policy_condition_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_document_template_id` FOREIGN KEY (`document_template_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`document_template`(`document_template_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_underwriter_id` FOREIGN KEY (`underwriter_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`underwriter`(`underwriter_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_policy_insured_id` FOREIGN KEY (`policy_insured_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_insured`(`policy_insured_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_source_binder_id` FOREIGN KEY (`source_binder_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`binder`(`binder_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ADD CONSTRAINT `fk_policy_policy_rate_filing_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ADD CONSTRAINT `fk_policy_policy_rate_filing_prior_filing_policy_rate_filing_id` FOREIGN KEY (`prior_filing_policy_rate_filing_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing`(`policy_rate_filing_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_prior_transaction_policy_transaction_id` FOREIGN KEY (`prior_transaction_policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ADD CONSTRAINT `fk_policy_location_condition_condition_id` FOREIGN KEY (`condition_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`condition`(`condition_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ADD CONSTRAINT `fk_policy_location_condition_policy_condition_id` FOREIGN KEY (`policy_condition_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`condition`(`condition_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ADD CONSTRAINT `fk_policy_vehicle_form_application_form_policy_form_id` FOREIGN KEY (`form_policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ADD CONSTRAINT `fk_policy_vehicle_form_application_application_policy_form_id` FOREIGN KEY (`application_policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ADD CONSTRAINT `fk_policy_premium_cession_allocation_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ADD CONSTRAINT `fk_policy_coverage_cession_policy_coverage_id` FOREIGN KEY (`policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_coverage`(`policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ADD CONSTRAINT `fk_policy_form_filing_form_policy_form_id` FOREIGN KEY (`form_policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ADD CONSTRAINT `fk_policy_form_filing_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_form`(`policy_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ADD CONSTRAINT `fk_policy_document_template_predecessor_template_id` FOREIGN KEY (`predecessor_template_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`document_template`(`document_template_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ADD CONSTRAINT `fk_policy_underwriter_supervisor_underwriter_id` FOREIGN KEY (`supervisor_underwriter_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`underwriter`(`underwriter_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`policy` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_v499`.`policy` SET TAGS ('dbx_domain' = 'policy');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `regulatory_state_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `source_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Source Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Audit Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'none|physical|financial|payroll');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `billing_method` SET TAGS ('dbx_business_glossary_term' = 'Billing Method');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `billing_method` SET TAGS ('dbx_value_regex' = 'direct|agency|list');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `bind_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Bind Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `business_type` SET TAGS ('dbx_business_glossary_term' = 'Business Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `business_type` SET TAGS ('dbx_value_regex' = 'NB|REN|ENDT|CANC|REINST');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_value_regex' = 'flat|short_rate|pro_rata');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `cat_exposure_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Issue Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_city` SET TAGS ('dbx_business_glossary_term' = 'Mailing City');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Mailing Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_state_code` SET TAGS ('dbx_business_glossary_term' = 'Mailing State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `mailing_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `module` SET TAGS ('dbx_business_glossary_term' = 'Policy Module');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `module` SET TAGS ('dbx_value_regex' = '^[0-9]{3,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Line Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `naic_line_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `named_insured_name` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `named_insured_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `named_insured_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `payment_plan_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_business_glossary_term' = 'Policy Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_value_regex' = 'personal|commercial|specialty');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `quote_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Quote Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `renewal_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Renewal Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `renewal_policy_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `symbol` SET TAGS ('dbx_business_glossary_term' = 'Policy Symbol');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `symbol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `term_months` SET TAGS ('dbx_business_glossary_term' = 'Policy Term in Months');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `total_insured_value` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `underwriting_company_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `underwriting_company_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `underwriting_company_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `underwriting_company_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Version Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `named_insured_id` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `prior_version_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Version Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `regulatory_state_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `booking_date` SET TAGS ('dbx_business_glossary_term' = 'Booking Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_value_regex' = 'FLAT|SHORT_RATE|PRO_RATA|NON_PAYMENT');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `declaration_page_generated_flag` SET TAGS ('dbx_business_glossary_term' = 'Declarations (DEC) Page Generated Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `declaration_page_generated_flag` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `declaration_page_generated_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_business_glossary_term' = 'Declarations (DEC) Page Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `notice_date` SET TAGS ('dbx_business_glossary_term' = 'Notice Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_PC|DUCK_CREEK_POLICY|SAPIENS_IDIT');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `source_version_id` SET TAGS ('dbx_business_glossary_term' = 'Source Version Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `total_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `transaction_effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `transaction_type_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `transaction_type_code` SET TAGS ('dbx_value_regex' = 'NB|ENDT|REN|CANC|REINST|REWRITE');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ALTER COLUMN `version_status` SET TAGS ('dbx_business_glossary_term' = 'Version Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `part_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `prior_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `prior_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `prior_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `agreed_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `benefit_period_days` SET TAGS ('dbx_business_glossary_term' = 'Benefit Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `blanket_coverage_flag` SET TAGS ('dbx_business_glossary_term' = 'Blanket Coverage Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `blanket_coverage_flag` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `blanket_coverage_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `change_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Change Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `change_reason_code` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|reinstatement|cancellation|audit');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_value_regex' = 'active|suspended|cancelled|expired|pending|bound');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `coverage_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|franchise|disappearing|aggregate');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `elimination_period_days` SET TAGS ('dbx_business_glossary_term' = 'Elimination Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{1,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Extended Reporting Period (ERP) Days');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `extended_reporting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `inflation_guard_percentage` SET TAGS ('dbx_business_glossary_term' = 'Inflation Guard Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `inflation_guard_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `inflation_guard_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `limit_type` SET TAGS ('dbx_value_regex' = 'per_occurrence|aggregate|per_person|per_accident|combined_single_limit|split_limit');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `optional_coverage_flag` SET TAGS ('dbx_business_glossary_term' = 'Optional Coverage Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `optional_coverage_flag` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `optional_coverage_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `per_location_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Location Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Premium Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `premium_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Basis Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `rate` SET TAGS ('dbx_business_glossary_term' = 'Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'Rate Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `rate_type` SET TAGS ('dbx_value_regex' = 'manual|experience|schedule|composite|flat');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Trigger Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'occurrence|claims_made|claims_made_reported|manifestation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'ACV|RCV|agreed_value|stated_amount|market_value');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Coverage Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Waiting Period Days');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `policy_insured_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `insured_id` SET TAGS ('dbx_business_glossary_term' = 'Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_country_id` SET TAGS ('dbx_business_glossary_term' = 'Mailing Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_state_id` SET TAGS ('dbx_business_glossary_term' = 'Mailing State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `added_by_endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Added by Endorsement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `additional_insured_type_code` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `business_description` SET TAGS ('dbx_business_glossary_term' = 'Business Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = 'NPAY|FREQ|MATL|INSREQ|UW|OTH');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `certificate_holder_flag` SET TAGS ('dbx_business_glossary_term' = 'Certificate Holder Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `clue_report_date` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `clue_report_ordered_flag` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Ordered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `contact_email_address` SET TAGS ('dbx_business_glossary_term' = 'Contact Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `contact_email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `contact_email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `contact_email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `contact_phone_number` SET TAGS ('dbx_business_glossary_term' = 'Contact Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `contact_phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `contact_phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Credit Score');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `credit_score_date` SET TAGS ('dbx_business_glossary_term' = 'Credit Score Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Date of Birth');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Entity Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^d{2}-d{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `gender` SET TAGS ('dbx_business_glossary_term' = 'Gender');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `gender` SET TAGS ('dbx_value_regex' = 'M|F|X|U');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `gender` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `gender` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `gender` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `gender` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `industry_code` SET TAGS ('dbx_business_glossary_term' = 'Industry Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `insurable_interest_description` SET TAGS ('dbx_business_glossary_term' = 'Insurable Interest Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `insured_name` SET TAGS ('dbx_business_glossary_term' = 'Insured Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `insured_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `insured_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `interest_description` SET TAGS ('dbx_business_glossary_term' = 'Interest Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `interest_type` SET TAGS ('dbx_business_glossary_term' = 'Interest Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `interest_type` SET TAGS ('dbx_value_regex' = 'owner|lessee|mortgagor|bailee|trustee|beneficiary');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `interest_type_code` SET TAGS ('dbx_business_glossary_term' = 'Interest Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `interest_type_code` SET TAGS ('dbx_value_regex' = 'OWN|LSE|MTG|VND|BLR|OTH');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `language_preference` SET TAGS ('dbx_business_glossary_term' = 'Language Preference');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `language_preference` SET TAGS ('dbx_value_regex' = '^[a-z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `language_preference` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `language_preference` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `loan_number` SET TAGS ('dbx_business_glossary_term' = 'Loan Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `loan_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_city` SET TAGS ('dbx_business_glossary_term' = 'Mailing City');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Mailing Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_value_regex' = '^d{5}(-d{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_business_glossary_term' = 'Marital Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_value_regex' = 'single|married|divorced|widowed|separated|domestic_partner');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_business_glossary_term' = 'Mobile Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9]{10,15}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mvr_order_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Order Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `mvr_ordered_flag` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Ordered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^d{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `occupation` SET TAGS ('dbx_business_glossary_term' = 'Occupation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `paperless_delivery_flag` SET TAGS ('dbx_business_glossary_term' = 'Paperless Delivery Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `policy_insured_status` SET TAGS ('dbx_business_glossary_term' = 'Insured Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `policy_insured_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|deceased|removed');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `policy_insured_type` SET TAGS ('dbx_business_glossary_term' = 'Insured Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `policy_insured_type` SET TAGS ('dbx_value_regex' = 'named|additional|loss_payee|mortgagee|lienholder|certificate_holder');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `primary_insured_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Insured Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `primary_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `primary_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9]{10,15}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `removed_by_endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Removed by Endorsement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `role_code` SET TAGS ('dbx_business_glossary_term' = 'Insured Role Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `role_code` SET TAGS ('dbx_value_regex' = 'NI|AI|LP|MTG|LH|INT');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `role_description` SET TAGS ('dbx_business_glossary_term' = 'Insured Role Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `sequence` SET TAGS ('dbx_business_glossary_term' = 'Insured Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Insured Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^d{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `source_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source Record ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GW|DC|SAP|ISO|LEG|OTH');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `ssn` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number (SSN)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `ssn` SET TAGS ('dbx_value_regex' = '^d{3}-d{2}-d{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `ssn` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `ssn` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `status_code` SET TAGS ('dbx_business_glossary_term' = 'Status Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `status_code` SET TAGS ('dbx_value_regex' = 'ACT|INA|PND|CAN|EXP');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `waiver_of_subrogation_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver of Subrogation Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `years_in_business` SET TAGS ('dbx_business_glossary_term' = 'Years in Business');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ALTER COLUMN `years_with_prior_carrier` SET TAGS ('dbx_business_glossary_term' = 'Years with Prior Carrier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`insured` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`insured` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`insured` ALTER COLUMN `insured_id` SET TAGS ('dbx_business_glossary_term' = 'insured Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`insured` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Reference to policy');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `declarations_id` SET TAGS ('dbx_business_glossary_term' = 'Declarations (DEC) Page ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `declarations_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `declarations_producers_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_state_id` SET TAGS ('dbx_business_glossary_term' = 'Mailing State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `policy_insured_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `company_name` SET TAGS ('dbx_business_glossary_term' = 'Company Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `company_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `company_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `coverage_summary_text` SET TAGS ('dbx_business_glossary_term' = 'Coverage Summary Text');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `coverage_summary_text` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `coverage_summary_text` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `dec_page_number` SET TAGS ('dbx_business_glossary_term' = 'Declarations (DEC) Page Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `dec_page_number` SET TAGS ('dbx_value_regex' = '^DEC-[0-9]{6,12}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `dec_page_number` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `dec_page_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `dec_page_status` SET TAGS ('dbx_business_glossary_term' = 'Declarations (DEC) Page Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `dec_page_status` SET TAGS ('dbx_value_regex' = 'draft|issued|superseded|cancelled|void');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `dec_page_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `dec_page_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `document_generated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Document Generated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `document_url` SET TAGS ('dbx_value_regex' = '^https?://.*');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `endorsement_numbers` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Numbers');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `form_numbers` SET TAGS ('dbx_business_glossary_term' = 'Form Numbers');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Issue Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `lob_description` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_city` SET TAGS ('dbx_business_glossary_term' = 'Mailing City');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Mailing Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `named_insured` SET TAGS ('dbx_business_glossary_term' = 'Named Insured');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `named_insured` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `named_insured` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `policy_type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `policy_type_code` SET TAGS ('dbx_value_regex' = 'NB|REN|ENDT|CANC|REINST');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `producer_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `producer_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,12}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `producer_name` SET TAGS ('dbx_business_glossary_term' = 'Producer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `producer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `producer_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `total_insured_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `total_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` SET TAGS ('dbx_subdomain' = 'risk_evaluation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `adverse_action_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Adverse Action Notice Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `adverse_action_notice_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Adverse Action Notice Sent Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `approved_by_underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `authority_level` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Authority Level');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `authority_level` SET TAGS ('dbx_value_regex' = 'line_underwriter|senior_underwriter|chief_underwriter|automated|delegated_authority|binding_authority');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `automated_decision_flag` SET TAGS ('dbx_business_glossary_term' = 'Automated Decision Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `business_type` SET TAGS ('dbx_business_glossary_term' = 'Business Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `business_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|reinstatement');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `conditions_imposed` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Conditions Imposed');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_action` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Action');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_action` SET TAGS ('dbx_value_regex' = 'accept|decline|refer|modify|counter_offer|conditional_accept');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_model_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Model Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_model_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_model_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_model_version` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Model Version');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_number` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_status` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|approved|rejected|superseded|withdrawn');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `decision_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `declination_reason` SET TAGS ('dbx_business_glossary_term' = 'Declination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `deductible_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Deductible Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Decision Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `exclusions_applied` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Exclusions Applied');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Decision Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `limit_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Override Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Override Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `premium_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `premium_adjustment_pct` SET TAGS ('dbx_business_glossary_term' = 'Premium Adjustment Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `primary_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Primary Underwriting (UW) Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Referral Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `referred_to_underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Referred To Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Risk Score');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `risk_tier` SET TAGS ('dbx_business_glossary_term' = 'Risk Tier Classification');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `risk_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined|high_risk|catastrophe_exposed');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `secondary_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Secondary Underwriting (UW) Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `sir_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `underwriting_guidelines_version` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Guidelines Version');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `underwriting_guidelines_version` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `underwriting_guidelines_version` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`uw_decision` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` SET TAGS ('dbx_subdomain' = 'risk_evaluation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `parent_quote_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Quote Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `policy_insured_id` SET TAGS ('dbx_business_glossary_term' = 'Named Insured Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `rating_state_id` SET TAGS ('dbx_business_glossary_term' = 'Rating State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `rating_state_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `rating_state_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `binder_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Binder Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `binder_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Binder Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `binder_number` SET TAGS ('dbx_business_glossary_term' = 'Binder Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `binder_number` SET TAGS ('dbx_value_regex' = '^BND-[0-9]{6,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `binding_authority_limit` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `bound_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Quote Bound Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `clue_report_ordered_flag` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Ordered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Quote Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Credit Score');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `decline_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `decline_reason_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `decline_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `declined_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Quote Declined Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `mvr_ordered_flag` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Ordered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Quote Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}-[0-9]{6,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `pml` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `presented_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Quote Presented Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `product_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `quote_status` SET TAGS ('dbx_business_glossary_term' = 'Quote Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `quote_status` SET TAGS ('dbx_value_regex' = 'draft|presented|bound|declined|expired|withdrawn');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `quote_type` SET TAGS ('dbx_business_glossary_term' = 'Quote Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `quote_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|rewrite|endorsement_quote');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `quoted_gwp` SET TAGS ('dbx_business_glossary_term' = 'Quoted Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `quoted_taxes_fees` SET TAGS ('dbx_business_glossary_term' = 'Quoted Taxes and Fees');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `quoted_total_premium` SET TAGS ('dbx_business_glossary_term' = 'Quoted Total Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `rating_state` SET TAGS ('dbx_business_glossary_term' = 'Rating State');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `rating_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `rating_state` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `rating_state` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `surplus_lines_flag` SET TAGS ('dbx_business_glossary_term' = 'Surplus Lines Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `uw_score` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Score');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `uw_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `uw_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|declined');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `valid_until_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Valid Until Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Quote Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ALTER COLUMN `years_with_prior_carrier` SET TAGS ('dbx_business_glossary_term' = 'Years with Prior Carrier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` SET TAGS ('dbx_subdomain' = 'risk_evaluation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_state_id` SET TAGS ('dbx_business_glossary_term' = 'Risk State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_email` SET TAGS ('dbx_business_glossary_term' = 'Applicant Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_name` SET TAGS ('dbx_business_glossary_term' = 'Applicant Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_phone` SET TAGS ('dbx_business_glossary_term' = 'Applicant Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_phone` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_type` SET TAGS ('dbx_business_glossary_term' = 'Applicant Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `applicant_type` SET TAGS ('dbx_value_regex' = 'individual|corporation|partnership|llc|trust|other');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `business_type` SET TAGS ('dbx_business_glossary_term' = 'Business Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `business_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|rewrite');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `clue_report_ordered` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Ordered');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Credit Score');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `declined_reason` SET TAGS ('dbx_business_glossary_term' = 'Declined Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `loss_history_years` SET TAGS ('dbx_business_glossary_term' = 'Loss History Years');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `mvr_ordered` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Ordered');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^d{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Submission Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Submission Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^SUB-[0-9]{8,12}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `requested_premium` SET TAGS ('dbx_business_glossary_term' = 'Requested Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Risk Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Risk Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_city` SET TAGS ('dbx_business_glossary_term' = 'Risk City');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_country` SET TAGS ('dbx_business_glossary_term' = 'Risk Country');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Risk Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_postal_code` SET TAGS ('dbx_value_regex' = '^d{5}(-d{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `risk_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^d{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `source_channel` SET TAGS ('dbx_business_glossary_term' = 'Source Channel');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `source_channel` SET TAGS ('dbx_value_regex' = 'agent|broker|direct|online_portal|call_center|mobile_app');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'Submission Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Submission Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `policy_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_business_glossary_term' = 'Agency ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `appointment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `appointment_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Assignment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `binding_authority_flag` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_basis_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_basis_code` SET TAGS ('dbx_value_regex' = 'GWP|NWP|EP|FLAT');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_holdback_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Holdback Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_holdback_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_holdback_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_payment_method_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Payment Method Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_payment_method_code` SET TAGS ('dbx_value_regex' = 'ACH|CHECK|WIRE|OFFSET');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Plan Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_split_percentage` SET TAGS ('dbx_business_glossary_term' = 'Commission Split Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_split_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_split_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_statement_frequency_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Statement Frequency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `commission_statement_frequency_code` SET TAGS ('dbx_value_regex' = 'MONTHLY|QUARTERLY|ANNUAL|TRANSACTION');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Producer Contact Email');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Producer Contact Phone');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contingent_commission_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Contingent Commission Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contingent_commission_eligible_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `contingent_commission_eligible_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Effective Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `expiration_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Expiration Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'Producer License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `license_state_code` SET TAGS ('dbx_business_glossary_term' = 'Producer License State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `license_state_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `license_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Modified By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `naic_producer_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Producer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `override_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Override Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `policy_transaction_type_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `policy_transaction_type_code` SET TAGS ('dbx_value_regex' = 'NB|REN|ENDT|CANC|REINSTATE');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `primary_producer_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Producer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `producer_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `record_version_number` SET TAGS ('dbx_business_glossary_term' = 'Record Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Relationship Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `relationship_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|SUSPENDED|TERMINATED');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `role_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Role Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `role_code` SET TAGS ('dbx_value_regex' = 'WRITING|SERVICING|REFERRING|SPLIT');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `servicing_office_code` SET TAGS ('dbx_business_glossary_term' = 'Servicing Office Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_PC|DUCK_CREEK|SAPIENS|LEGACY');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `sub_producer_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Producer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Producer Tax ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Producer Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `termination_reason_code` SET TAGS ('dbx_value_regex' = 'TRANSFER|RETIREMENT|TERMINATION|POLICY_CANCEL|VOLUNTARY');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `tier_code` SET TAGS ('dbx_business_glossary_term' = 'Producer Tier Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ALTER COLUMN `tier_code` SET TAGS ('dbx_value_regex' = 'PLATINUM|GOLD|SILVER|BRONZE|STANDARD');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `status_history_id` SET TAGS ('dbx_business_glossary_term' = 'Status History ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Triggering Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `reversed_by_status_history_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed By Status History ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `cancellation_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Notice Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Comments');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Status Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `initiated_by_party_type` SET TAGS ('dbx_business_glossary_term' = 'Initiated By Party Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `initiated_by_party_type` SET TAGS ('dbx_value_regex' = 'insured|insurer|agent|underwriter|system|regulator');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Initiated By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `initiated_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `initiated_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Initiated By User Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `initiated_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `initiated_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `new_status` SET TAGS ('dbx_business_glossary_term' = 'New Policy Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `non_renewal_reason` SET TAGS ('dbx_business_glossary_term' = 'Non-Renewal (REN) Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `notification_method` SET TAGS ('dbx_business_glossary_term' = 'Notification Method');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `notification_method` SET TAGS ('dbx_value_regex' = 'email|mail|phone|portal|fax');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `notification_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `notification_sent_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `prior_status` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `regulatory_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `regulatory_filing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `system_source` SET TAGS ('dbx_business_glossary_term' = 'System Source');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `transition_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `transition_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `transition_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `triggering_transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Triggering Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`status_history` ALTER COLUMN `unearned_premium_returned_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Returned Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `superseded_by_form_policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Form Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `coverage_category` SET TAGS ('dbx_business_glossary_term' = 'Coverage Category');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `coverage_category` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `coverage_category` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Document Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `edition_date` SET TAGS ('dbx_business_glossary_term' = 'Edition Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'approved|pending|withdrawn|rejected|superseded');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `form_description` SET TAGS ('dbx_business_glossary_term' = 'Form Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `form_name` SET TAGS ('dbx_business_glossary_term' = 'Form Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `form_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `form_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `form_number` SET TAGS ('dbx_business_glossary_term' = 'Form Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `form_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,4}[s-]?[0-9]{2,4}[s-]?[0-9]{2,4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `form_type` SET TAGS ('dbx_business_glossary_term' = 'Form Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `form_type` SET TAGS ('dbx_value_regex' = 'base|endorsement|exclusion|schedule|condition|declaration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `iso_source_flag` SET TAGS ('dbx_business_glossary_term' = 'ISO (Insurance Services Office) Source Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'Form Language');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `language` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `language` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Form Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `naic_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC (National Association of Insurance Commissioners) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `policy_form_status` SET TAGS ('dbx_business_glossary_term' = 'Form Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `policy_form_status` SET TAGS ('dbx_value_regex' = 'active|inactive|archived|draft');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `premium_bearing_flag` SET TAGS ('dbx_business_glossary_term' = 'Premium Bearing Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `usage_count` SET TAGS ('dbx_business_glossary_term' = 'Usage Count');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `usage_count` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_form` ALTER COLUMN `usage_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `condition_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Condition Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `assigned_to_party_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned To Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `regulatory_state_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = 'CONDITION_SATISFIED|POLICY_CANCELLED|CONDITION_NO_LONGER_APPLICABLE|ERROR_CORRECTION|REPLACED_BY_ENDORSEMENT');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `condition_category` SET TAGS ('dbx_business_glossary_term' = 'Condition Category');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `condition_category` SET TAGS ('dbx_value_regex' = 'PRE_BIND|POST_BIND|ONGOING|RENEWAL');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `compliance_due_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `condition_number` SET TAGS ('dbx_business_glossary_term' = 'Condition Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `condition_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `condition_status` SET TAGS ('dbx_business_glossary_term' = 'Condition Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `condition_status` SET TAGS ('dbx_value_regex' = 'PENDING|SATISFIED|OUTSTANDING|WAIVED|EXPIRED|CANCELLED');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `coverage_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Coverage Impact Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `coverage_impact_flag` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `coverage_impact_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `condition_description` SET TAGS ('dbx_business_glossary_term' = 'Condition Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Condition Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `premium_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `regulatory_requirement_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `satisfied_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Satisfied Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `source_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Document Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `source_document_type` SET TAGS ('dbx_business_glossary_term' = 'Source Document Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `source_document_type` SET TAGS ('dbx_value_regex' = 'INSPECTION_REPORT|LOSS_RUN|RISK_SURVEY|APPLICATION|ENDORSEMENT|REGULATORY_FILING');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'GUIDEWIRE_PC|DUCK_CREEK_POLICY|SAPIENS_IDIT|MANUAL_ENTRY');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `text` SET TAGS ('dbx_business_glossary_term' = 'Condition Text');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Condition Title');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Condition Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = 'WARRANTY|SPECIAL_CONDITION|UW_REQUIREMENT|COMPLIANCE_REQUIREMENT|RISK_IMPROVEMENT|INSPECTION');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `waived_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Waived Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `waiver_approved_by_code` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approved By Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `waiver_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ALTER COLUMN `waiver_reason_code` SET TAGS ('dbx_value_regex' = 'UW_DISCRETION|RISK_IMPROVEMENT_COMPLETED|ALTERNATIVE_MITIGATION|BUSINESS_DECISION|REGULATORY_EXEMPTION|ERROR_CORRECTION');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `document_id` SET TAGS ('dbx_business_glossary_term' = 'Document Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `user_account_id` SET TAGS ('dbx_business_glossary_term' = 'Generated By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `user_account_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `user_account_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_country_id` SET TAGS ('dbx_business_glossary_term' = 'Recipient Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_state_id` SET TAGS ('dbx_business_glossary_term' = 'Recipient State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `document_template_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `underwriter_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Document Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `certificate_holder_address` SET TAGS ('dbx_business_glossary_term' = 'Certificate Holder Address');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `certificate_holder_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `certificate_holder_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `certificate_holder_name` SET TAGS ('dbx_business_glossary_term' = 'Certificate Holder Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `certificate_holder_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `certificate_holder_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `cms_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Content Management System (CMS) Reference Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `cms_url` SET TAGS ('dbx_business_glossary_term' = 'Content Management System (CMS) Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Document Delivery Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Document Delivery Method');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `delivery_method` SET TAGS ('dbx_value_regex' = 'email|postal_mail|portal|fax|in_person|electronic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `delivery_status` SET TAGS ('dbx_business_glossary_term' = 'Document Delivery Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `delivery_status` SET TAGS ('dbx_value_regex' = 'pending|sent|delivered|failed|bounced');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'draft|pending|issued|delivered|archived|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Document Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'Document File Format');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `file_format` SET TAGS ('dbx_value_regex' = 'PDF|DOCX|HTML|XML|TXT');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'Document File Size in Bytes');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `generation_date` SET TAGS ('dbx_business_glossary_term' = 'Document Generation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `generation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Document Generation Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `language_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `language_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Document Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Document Page Count');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `page_count` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `page_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Recipient Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Recipient Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_city` SET TAGS ('dbx_business_glossary_term' = 'Recipient City');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_email` SET TAGS ('dbx_business_glossary_term' = 'Document Recipient Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_name` SET TAGS ('dbx_business_glossary_term' = 'Document Recipient Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Recipient Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `recipient_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `signature_date` SET TAGS ('dbx_business_glossary_term' = 'Document Signature Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `signature_received_flag` SET TAGS ('dbx_business_glossary_term' = 'Signature Received Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `signature_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Signature Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `template_version` SET TAGS ('dbx_business_glossary_term' = 'Document Template Version');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Document Title');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Document Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = 'DEC|ENDT|CANC|BINDER|COI|RENEWAL');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` SET TAGS ('dbx_subdomain' = 'risk_evaluation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `binder_id` SET TAGS ('dbx_business_glossary_term' = 'Binder Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `binder_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `binder_producers_producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `binding_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Binding Authority Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_state_id` SET TAGS ('dbx_business_glossary_term' = 'Mailing State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `policy_insured_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `source_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Source Binder Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `binder_status` SET TAGS ('dbx_business_glossary_term' = 'Binder Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `binder_status` SET TAGS ('dbx_value_regex' = 'active|expired|converted|cancelled|voided|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `binding_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Binding Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation (CANC) Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `conversion_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Conversion Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `coverage_summary` SET TAGS ('dbx_business_glossary_term' = 'Coverage Summary');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `coverage_summary` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `coverage_summary` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_business_glossary_term' = 'Declaration (DEC) Page URL');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_value_regex' = '^https?://.*');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Binder Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `endorsement_numbers` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Numbers');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `estimated_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Binder Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `form_numbers` SET TAGS ('dbx_business_glossary_term' = 'Form Numbers');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `lob_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_city` SET TAGS ('dbx_business_glossary_term' = 'Mailing City');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Mailing Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `named_insured` SET TAGS ('dbx_business_glossary_term' = 'Named Insured');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `named_insured` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `named_insured` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Binder Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Binder Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^BND-[A-Z0-9]{8,15}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `per_occurrence_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `regulatory_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `total_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` SET TAGS ('dbx_subdomain' = 'risk_evaluation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `policy_rate_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Filing Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `prior_filing_policy_rate_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Filing Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `actuarial_justification_summary` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Justification Summary');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `affected_policy_count` SET TAGS ('dbx_business_glossary_term' = 'Affected Policy Count');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `company_code` SET TAGS ('dbx_business_glossary_term' = 'Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `deemer_date` SET TAGS ('dbx_business_glossary_term' = 'Deemer Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Filing Contact Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Filing Contact Name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Filing Contact Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_method` SET TAGS ('dbx_business_glossary_term' = 'Filing Method');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_method` SET TAGS ('dbx_value_regex' = 'file_and_use|use_and_file|prior_approval|flex_rating|no_file');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_type` SET TAGS ('dbx_business_glossary_term' = 'Filing Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `filing_type` SET TAGS ('dbx_value_regex' = 'rate|form|rule|rate_and_form|rate_and_rule|informational');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `form_numbers_included` SET TAGS ('dbx_business_glossary_term' = 'Form Numbers Included');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `iso_program_edition_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Program Edition Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `iso_program_indicator` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Program Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `objection_reason` SET TAGS ('dbx_business_glossary_term' = 'Objection Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `overall_rate_change_percent` SET TAGS ('dbx_business_glossary_term' = 'Overall Rate Change Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `projected_premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Projected Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `rate_change_type` SET TAGS ('dbx_business_glossary_term' = 'Rate Change Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `rate_change_type` SET TAGS ('dbx_value_regex' = 'increase|decrease|no_change|new_program');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `regulatory_review_days` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Days');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `resubmission_flag` SET TAGS ('dbx_business_glossary_term' = 'Resubmission Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `serff_tracking_number` SET TAGS ('dbx_business_glossary_term' = 'System for Electronic Rate and Form Filing (SERFF) Tracking Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `supporting_document_url` SET TAGS ('dbx_business_glossary_term' = 'Supporting Document Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `supporting_document_url` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `supporting_document_url` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `prior_transaction_policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `regulatory_state_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Audit Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'premium_audit|physical_audit|final_audit|interim_audit');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `booking_date` SET TAGS ('dbx_business_glossary_term' = 'Booking Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `cancellation_type` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `declaration_page_generated_flag` SET TAGS ('dbx_business_glossary_term' = 'Declaration Page (DEC) Generated Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `declaration_page_generated_flag` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `declaration_page_generated_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_business_glossary_term' = 'Declaration Page (DEC) URL');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `declaration_page_url` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `initiating_party_type` SET TAGS ('dbx_business_glossary_term' = 'Initiating Party Type');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `initiating_party_type` SET TAGS ('dbx_value_regex' = 'insured|insurer|producer|underwriter|system|regulator');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `initiating_party_type` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `initiating_party_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `initiating_user_code` SET TAGS ('dbx_business_glossary_term' = 'Initiating User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `initiating_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `initiating_user_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `initiating_user_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `notice_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Notice Compliance Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `notice_date` SET TAGS ('dbx_business_glossary_term' = 'Notice Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `notice_days_required` SET TAGS ('dbx_business_glossary_term' = 'Notice Days Required');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `premium_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Change Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `source_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `total_transaction_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Transaction Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Number');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Transaction Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transaction Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` SET TAGS ('dbx_association_edges' = 'policy.policy_condition,riskexposure.insured_location');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `location_condition_id` SET TAGS ('dbx_business_glossary_term' = 'Location Condition Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `condition_id` SET TAGS ('dbx_business_glossary_term' = 'Location Condition - Policy Condition Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `condition_id` SET TAGS ('dbx_business_role' = 'location_scoped_condition_ref');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `condition_id` SET TAGS ('dbx_renamed_from' = 'condition_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Condition - Insured Location Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `policy_condition_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Condition Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `compliance_due_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `inspection_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Inspection Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Inspection Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `satisfied_date` SET TAGS ('dbx_business_glossary_term' = 'Satisfied Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `waived_date` SET TAGS ('dbx_business_glossary_term' = 'Waived Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ALTER COLUMN `waiver_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` SET TAGS ('dbx_association_edges' = 'policy.policy_form,riskexposure.insured_vehicle');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `vehicle_form_application_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Form Application ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `form_policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Form Application - Policy Form Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Form Application - Insured Vehicle Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `application_policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `application_policy_form_id` SET TAGS ('dbx_business_role' = 'application_form');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `application_reason` SET TAGS ('dbx_business_glossary_term' = 'Form Application Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `application_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Form Application Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Applied By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `applied_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Form Application Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Form Application Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Form Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Form Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `state_specific_version` SET TAGS ('dbx_business_glossary_term' = 'State Specific Form Version');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ALTER COLUMN `vehicle_form_application_status` SET TAGS ('dbx_business_glossary_term' = 'Form Application Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` SET TAGS ('dbx_association_edges' = 'policy.policy_transaction,reinsurance.ceded_premium_transaction');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `premium_cession_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Cession Allocation ID');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `ceded_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Cession Allocation - Ceded Premium Transaction Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Cession Allocation - Policy Transaction Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `allocated_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `allocation_created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Allocation Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `allocation_created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `allocation_created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `allocation_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Allocation Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `allocation_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `bordereaux_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ALTER COLUMN `premium_allocation_basis` SET TAGS ('dbx_business_glossary_term' = 'Premium Allocation Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` SET TAGS ('dbx_association_edges' = 'policy.policy_coverage,reinsurance.cession');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_cession_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession - Policy Coverage Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession - Cession Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Coverage-Specific Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `ceded_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Ceded Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `ceded_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceded Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_cession_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_cession_status` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_cession_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_layer_allocation` SET TAGS ('dbx_business_glossary_term' = 'Coverage Layer Allocation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_layer_allocation` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `coverage_layer_allocation` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage-Specific Retention');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Coverage Cession Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` SET TAGS ('dbx_association_edges' = 'policy.policy_form,shared.state');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `form_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Form Filing Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `form_policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Form Filing - Policy Form Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `policy_form_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Form Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'Form Filing - State Id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `applicable_states` SET TAGS ('dbx_business_glossary_term' = 'Applicable States');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` SET TAGS ('dbx_subdomain' = 'contract_administration');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `document_template_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `language_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `language_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `page_count` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `page_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `template_content_path` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `template_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `template_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `usage_count` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document_template` ALTER COLUMN `usage_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` SET TAGS ('dbx_subdomain' = 'risk_evaluation');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `underwriter_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `maximum_exposure_authority` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `maximum_premium_authority` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `performance_rating` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `performance_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `performance_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`underwriter` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
