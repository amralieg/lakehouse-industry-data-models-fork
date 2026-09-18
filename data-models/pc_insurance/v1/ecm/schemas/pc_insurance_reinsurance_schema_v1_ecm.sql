-- Schema for Domain: reinsurance | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:18

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`reinsurance` COMMENT 'Owns RI treaty and facultative (FAC) placements, cession and bordereaux processing, XOL, QS, CAT XL, and CAT Bond structures. Tracks retention/limit layers, ceded premium, ceded loss, and recoverable balances per treaty or certificate.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` (
    `ri_treaty_id` BIGINT COMMENT 'Unique surrogate identifier for each reinsurance treaty or facultative certificate record in the Pc_Insurance reinsurance management system.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code in which treaty financial terms (retention, limit, premium) are denominated (e.g., USD, GBP, EUR).',
    `lob_code_id` BIGINT COMMENT 'NAIC or internal Line of Business (LOB) code identifying the class of business covered by the treaty (e.g., GL, WC, APD, Property). [ENUM-REF-CANDIDATE: promote to reference product]',
    `originating_agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Treaties track originating agency for premium volume aggregation and agency-level profit sharing arrangements.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Treaties specify originating producer codes for subject premium attribution in profit commission calculations and bordereaux reporting.',
    `admitted_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is admitted (licensed) in the cedants domicile state. Admitted status affects credit for reinsurance on the NAIC statutory balance sheet.',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum total amount the reinsurer will pay across all occurrences during the treaty period. Applies to aggregate stop-loss and CAT XL treaties with annual aggregate caps.',
    `aggregate_retention_amount` DECIMAL(18,2) COMMENT 'Annual aggregate deductible or retention that must be exhausted before the aggregate reinsurance limit responds. Used in stop-loss and aggregate XOL structures.',
    `am_best_rating` STRING COMMENT 'A.M. Best financial strength rating of the lead reinsurer at treaty binding (e.g., A++, A+, A, A-, B++). Used to assess reinsurer credit quality and counterparty risk.',
    `bound_date` DATE COMMENT 'Date on which the reinsurance treaty was formally bound and agreed upon by all parties, marking the transition from negotiation to a legally binding contract.',
    `broker_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium paid to the reinsurance broker as brokerage commission for placing the treaty. Expressed as a decimal (e.g., 0.0125 = 1.25%).',
    `broker_name` STRING COMMENT 'Name of the reinsurance intermediary broker (e.g., Aon, Guy Carpenter, Willis Re) who placed the treaty on behalf of Pc_Insurance.',
    `cancellation_date` DATE COMMENT 'Date on which the reinsurance treaty was cancelled prior to its natural expiry. Null if the treaty was not cancelled.',
    `cat_event_definition` STRING COMMENT 'Contractual definition of a catastrophe event for CAT XL treaties, including the hours clause (e.g., 72-hour clause for windstorm) and minimum loss threshold for event aggregation.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Total reinsurance premium ceded to the reinsurer panel for the treaty period. Represents the cost of reinsurance protection and is reported on NAIC Schedule F.',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to Pc_Insurance by the reinsurer as a ceding commission to offset acquisition and administrative costs. Applicable to QS treaties.',
    `cession_percentage` DECIMAL(7,4) COMMENT 'Percentage of risk ceded to reinsurers under a Quota Share (QS) treaty. Expressed as a decimal (e.g., 0.3000 = 30%). Null for non-QS treaty types.',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Monetary value of collateral posted by the reinsurer to secure treaty obligations. Required for non-admitted reinsurers to qualify for credit for reinsurance under NAIC rules.',
    `collateral_type` STRING COMMENT 'Type of collateral posted by the reinsurer to secure obligations, required for non-admitted reinsurers under NAIC credit-for-reinsurance rules: LOC, Trust Fund, Funds Withheld, or None.. Valid values are `LETTER_OF_CREDIT|TRUST_FUND|FUNDS_WITHHELD|NONE`',
    `coverage_basis` STRING COMMENT 'Defines the trigger basis for reinsurance coverage: Losses Occurring (events during treaty period), Risks Attaching (policies incepting during period), or Claims Made.. Valid values are `LOSSES_OCCURRING|RISKS_ATTACHING|CLAIMS_MADE`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the reinsurance treaty record was first created in the reinsurance management system. Used for audit trail and data lineage tracking.',
    `deposit_premium_amount` DECIMAL(18,2) COMMENT 'Provisional reinsurance premium paid at treaty inception, subject to adjustment at year-end based on actual subject premium earned. Common in proportional treaties.',
    `effective_date` DATE COMMENT 'Date on which the reinsurance treaty or facultative certificate becomes effective and coverage obligations commence. Aligns with the treaty inception date in the RI system.',
    `expiry_date` DATE COMMENT 'Date on which the reinsurance treaty or facultative certificate expires and coverage obligations cease. Null for evergreen or open-ended treaties.',
    `funds_withheld_flag` BOOLEAN COMMENT 'Indicates whether Pc_Insurance withholds ceded premium funds from the reinsurer under a funds-withheld collateral arrangement, common with non-admitted reinsurers.',
    `layer_number` BIGINT COMMENT 'Sequential layer number within a multi-layer XOL or CAT XL tower (e.g., Layer 1, Layer 2). Identifies the position of this treaty within the overall reinsurance program structure.',
    `lead_reinsurer_name` STRING COMMENT 'Name of the lead reinsurer on the treaty panel who sets terms and conditions. The lead reinsurers agreement is typically required for claims and endorsements.',
    `lead_reinsurer_share_pct` DECIMAL(7,4) COMMENT 'Percentage of the treaty limit subscribed by the lead reinsurer. Expressed as a decimal (e.g., 0.2500 = 25% line). Total panel shares must sum to 100%.',
    `limit_amount` DECIMAL(18,2) COMMENT 'Maximum monetary amount the reinsurer is obligated to pay under this treaty layer. For XOL, this is the layer width above the retention/attachment point.',
    `loss_corridor_lower_pct` DECIMAL(7,4) COMMENT 'Lower bound of the loss corridor (as a percentage of subject premium) within which Pc_Insurance retains losses in a stop-loss or aggregate structure. Null if not applicable.',
    `loss_corridor_upper_pct` DECIMAL(7,4) COMMENT 'Upper bound of the loss corridor (as a percentage of subject premium) above which reinsurance coverage resumes in a stop-loss or aggregate structure. Null if not applicable.',
    `minimum_premium_amount` DECIMAL(18,2) COMMENT 'Minimum reinsurance premium guaranteed to the reinsurer regardless of subject premium volume. Protects the reinsurer against low-volume treaty years.',
    `naic_reinsurer_code` STRING COMMENT 'Five-digit NAIC company code assigned to the reinsurer, used for statutory Schedule F reporting and regulatory identification of the reinsurance counterparty.. Valid values are `^[0-9]{5}$`',
    `perils_covered` STRING COMMENT 'Description of the perils or causes of loss covered by the treaty (e.g., All Natural Perils, Named Windstorm and Earthquake, Fire and Allied Lines). Free-text or coded.',
    `placement_type` STRING COMMENT 'Indicates whether the reinsurance placement is a treaty (automatic, portfolio-wide) or facultative (FAC) certificate covering a specific risk or policy.. Valid values are `TREATY|FACULTATIVE`',
    `pml_amount` DECIMAL(18,2) COMMENT 'Probable Maximum Loss (PML) estimate for the subject portfolio covered by this treaty, used to size the reinsurance limit and assess adequacy of protection.',
    `profit_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of reinsurer profit returned to Pc_Insurance as a profit commission when the treaty loss ratio falls below a defined threshold. Incentivizes underwriting quality.',
    `profit_commission_threshold_pct` DECIMAL(7,4) COMMENT 'Loss ratio threshold below which the profit commission mechanism is triggered. Expressed as a decimal (e.g., 0.6500 = 65% loss ratio). Null if no profit commission applies.',
    `program_name` STRING COMMENT 'Name of the overarching reinsurance program to which this treaty layer belongs (e.g., Property CAT Program 2024). Groups related layers for program-level reporting.',
    `rate_on_line_pct` DECIMAL(7,4) COMMENT 'Rate on Line (ROL) expressed as a percentage of the treaty limit, representing the reinsurance premium as a proportion of the limit purchased. Key pricing metric for XOL treaties.',
    `reinstatement_count` BIGINT COMMENT 'Number of reinstatements available to restore the treaty limit after a loss occurrence. Common in CAT XL treaties. Zero indicates no reinstatements permitted.',
    `reinstatement_premium_pct` DECIMAL(7,4) COMMENT 'Percentage of the original reinsurance premium charged to reinstate the treaty limit after a loss. Expressed as a decimal (e.g., 1.0000 = 100% pro-rata reinstatement premium).',
    `retention_amount` DECIMAL(18,2) COMMENT 'The monetary amount or percentage of risk that Pc_Insurance retains before the reinsurance treaty responds. For XOL, this is the per-occurrence or per-risk retention (attachment point).',
    `retention_type` STRING COMMENT 'Indicates whether the retention is expressed as a fixed monetary amount (e.g., SIR or attachment point in USD) or as a percentage of the risk (used in QS treaties).. Valid values are `MONETARY|PERCENTAGE`',
    `subject_premium_basis` STRING COMMENT 'Defines the premium base to which the treaty rate or cession percentage is applied: Gross Written Premium (GWP), Net Written Premium (NWP), Earned Premium (EP), or Written Premium (WP).. Valid values are `GWP|NWP|EP|WP`',
    `territory_scope` STRING COMMENT 'Geographic scope of risks covered by the treaty (e.g., USA and Canada, Worldwide Excluding War Zones). Defines the territorial limits of reinsurance protection.',
    `treaty_name` STRING COMMENT 'Descriptive business name of the reinsurance treaty (e.g., Property CAT XL Layer 1 2024) used for identification in bordereaux and management reporting.',
    `treaty_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to the reinsurance treaty or facultative (FAC) certificate by the reinsurance management system or lead reinsurer.',
    `treaty_status` STRING COMMENT 'Current lifecycle state of the reinsurance treaty: DRAFT (in negotiation), BOUND (signed/agreed), ACTIVE (in-force), EXPIRED, CANCELLED, or SUSPENDED.. Valid values are `DRAFT|BOUND|ACTIVE|EXPIRED|CANCELLED|SUSPENDED`',
    `treaty_type` STRING COMMENT 'Classification of the reinsurance structure: Excess of Loss (XOL), Quota Share (QS), Catastrophe Excess of Loss (CAT XL), Facultative (FAC), CAT Bond, Stop Loss, or Aggregate.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the reinsurance treaty record in the reinsurance management system. Supports audit trail and change tracking requirements.',
    CONSTRAINT pk_ri_treaty PRIMARY KEY(`ri_treaty_id`)
) COMMENT 'Master record for each reinsurance treaty (XOL, QS, CAT XL, CAT Bond) placed by Pc_Insurance. Captures treaty type, structure, effective/expiry dates, reinsurer panel, retention, limit, and placement status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` (
    `fac_certificate_id` BIGINT COMMENT 'Unique surrogate identifier for each facultative reinsurance certificate record in the Pc_Insurance lakehouse silver layer.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code in which all monetary amounts on this certificate are denominated (e.g., USD, GBP, EUR).',
    `insured_entity_id` BIGINT COMMENT 'Reference to the ceding company (Pc_Insurance entity) placing the facultative risk with the reinsurer.',
    `lob_code_id` BIGINT COMMENT 'NAIC or internal line of business code identifying the class of insurance (e.g., GL, CPP, WC, APD) covered by this facultative certificate.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Facultative certificates are underwritten against specific high-value coverages (not just policies).',
    `policy_id` BIGINT COMMENT 'Reference to the underlying primary insurance policy for which this facultative certificate provides reinsurance coverage.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer (counterparty) accepting the ceded risk under this facultative certificate.',
    `risk_unit_id` BIGINT COMMENT 'Reference to the specific insured risk or scheduled item being ceded under this facultative certificate.',
    `accounting_period` STRING COMMENT 'Financial accounting period (YYYY-MM) to which ceded premium and loss transactions on this certificate are posted in the general ledger.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized/accredited in the cedants domicile state, affecting statutory credit for reinsurance on Schedule F.',
    `bordereaux_period` STRING COMMENT 'Reporting period (YYYY-MM or YYYY-Q#) in which this certificate is included in the bordereaux submission to the reinsurer.. Valid values are `^[0-9]{4}-(Q[1-4]|[0-9]{2})$`',
    `bound_date` DATE COMMENT 'Date on which the facultative certificate was formally bound and accepted by the reinsurer, establishing the contractual obligation.',
    `cancellation_date` DATE COMMENT 'Date on which the facultative certificate was cancelled prior to its scheduled expiry, if applicable.',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether the risk ceded under this certificate is exposed to catastrophe (CAT) perils such as hurricane, earthquake, or flood.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Allocated Loss Adjustment Expense (ALAE) ceded to the reinsurer under this certificate, per treaty or certificate terms.',
    `ceded_limit_amount` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery amount the reinsurer is liable for under this facultative certificate, expressed in the certificate currency.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Total loss amount ceded to the reinsurer under this certificate, representing the reinsurers share of paid and reserved losses.',
    `ceded_retention_amount` DECIMAL(18,2) COMMENT 'Dollar amount of loss retained by the cedant before the reinsurers liability attaches under this facultative certificate.',
    `ceded_share_pct` DECIMAL(7,4) COMMENT 'Percentage of the original risk ceded to the reinsurer under this certificate. Applicable for proportional (QS/surplus) arrangements.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Absolute dollar amount of ceding commission receivable from the reinsurer, derived from ceding_commission_pct applied to gross_ceded_premium.',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to the cedant as ceding commission to offset acquisition and administrative costs.',
    `certificate_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to the facultative certificate by the reinsurer or cedant, used in bordereaux and correspondence.. Valid values are `^FAC-[A-Z0-9]{4,20}$`',
    `certificate_status` STRING COMMENT 'Current lifecycle state of the facultative certificate from placement through expiry or cancellation.. Valid values are `draft|bound|active|expired|cancelled|declined`',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Dollar amount of collateral posted by the reinsurer to secure the cedants reinsurance recoverable under this certificate.',
    `collateral_required_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is required to post collateral (trust, LOC, funds withheld) due to unauthorized status or credit terms.',
    `collateral_type` STRING COMMENT 'Type of collateral posted by the reinsurer to secure recoverable obligations: trust fund, letter of credit, funds withheld, or none.. Valid values are `trust_fund|letter_of_credit|funds_withheld|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this facultative certificate record was first created in the system of record, used for audit trail and data lineage.',
    `expiry_date` DATE COMMENT 'Date on which the facultative certificate expires and reinsurance coverage ceases. Null for open-ended certificates.',
    `fac_type` STRING COMMENT 'Classification of the facultative arrangement: proportional (quota share, surplus) or non-proportional (excess of loss). Drives cession calculation methodology.. Valid values are `proportional|non_proportional|quota_share|excess_of_loss|surplus`',
    `gross_ceded_premium` DECIMAL(18,2) COMMENT 'Gross Written Premium (GWP) ceded to the reinsurer under this certificate before deduction of ceding commission.',
    `inception_date` DATE COMMENT 'Date on which the facultative certificate becomes effective and reinsurance coverage commences.',
    `insured_name` STRING COMMENT 'Legal name of the insured party on the underlying policy, included on the facultative certificate for risk identification purposes.',
    `net_ceded_premium` DECIMAL(18,2) COMMENT 'Net Written Premium (NWP) ceded to the reinsurer after deducting ceding commission from gross ceded premium.',
    `original_tiv` DECIMAL(18,2) COMMENT 'Total Insured Value of the underlying risk at the time of facultative placement, used to size the ceded limit and premium.',
    `placement_broker` STRING COMMENT 'Name of the reinsurance intermediary or broker who facilitated the placement of this facultative certificate in the market.',
    `pml_amount` DECIMAL(18,2) COMMENT 'Probable Maximum Loss (PML) estimate for the ceded risk, used to size the facultative limit and assess reinsurer exposure.',
    `recoverable_balance` DECIMAL(18,2) COMMENT 'Outstanding reinsurance recoverable amount owed by the reinsurer to the cedant for ceded losses not yet collected.',
    `risk_description` STRING COMMENT 'Narrative description of the underlying insured risk being ceded, including COPE (Construction, Occupancy, Protection, Exposure) details for property risks.',
    `rol_pct` DECIMAL(7,4) COMMENT 'Rate on Line (ROL) expressed as a percentage of the ceded limit, used to price non-proportional (XOL) facultative certificates.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this facultative certificate record was ingested into the lakehouse.. Valid values are `SICS|SAPIENS_RI|DUCK_CREEK|GUIDEWIRE|MANUAL`',
    `underwriter_name` STRING COMMENT 'Name of the cedants underwriter responsible for placing and managing this facultative certificate.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this facultative certificate record, supporting change tracking and incremental ETL processing.',
    `xol_attachment_point` DECIMAL(18,2) COMMENT 'Loss amount at which the reinsurers liability attaches under an excess of loss (XOL) facultative arrangement. Null for proportional certificates.',
    `xol_exhaustion_point` DECIMAL(18,2) COMMENT 'Loss amount at which the reinsurers layer is fully exhausted under an XOL facultative arrangement (attachment + limit).',
    CONSTRAINT pk_fac_certificate PRIMARY KEY(`fac_certificate_id`)
) COMMENT 'Master record for each facultative (FAC) reinsurance certificate placed on a specific risk or policy. Tracks FAC type, ceded limit, ceded premium, reinsurer, and certificate status independent of treaty structures.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` (
    `treaty_layer_id` BIGINT COMMENT 'Unique surrogate identifier for each retention/limit layer record within a reinsurance treaty or facultative certificate structure.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this layer (e.g., USD, GBP, EUR). Supports multi-currency treaty structures.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Treaty layers (especially CAT XOL) are priced against location exposure schedules.',
    `lob_code_id` BIGINT COMMENT 'NAIC or internal Line of Business code identifying the class of business covered by this treaty layer (e.g., Commercial Auto, GL, Property, WC). Supports statutory reporting.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the parent reinsurance treaty or facultative certificate to which this layer belongs.',
    `adjusted_premium` DECIMAL(18,2) COMMENT 'Final reinsurance premium after year-end adjustment reconciling deposit premium against actual subject premium earned. Reflects true cost of the layer for the period.',
    `aggregate_annual_limit` DECIMAL(18,2) COMMENT 'Maximum total reinsurer liability across all occurrences within the treaty year for this layer. Caps cumulative reinsurer exposure on aggregate XOL structures.',
    `aggregate_deductible` DECIMAL(18,2) COMMENT 'Cumulative loss amount the cedant must retain before the aggregate XOL layer responds. Used in aggregate stop-loss and aggregate XOL treaty structures.',
    `alae_included` BOOLEAN COMMENT 'Indicates whether Allocated Loss Adjustment Expense (ALAE) is included within the layer limit and attachment point calculations for this treaty layer.',
    `attachment_point` DECIMAL(18,2) COMMENT 'The loss amount at which this reinsurance layer begins to respond. For XOL structures, losses must exceed this threshold before the reinsurer pays. Also known as the retention.',
    `cat_event_limit` DECIMAL(18,2) COMMENT 'Maximum reinsurer liability per defined catastrophe event under a CAT XL layer. Distinct from per-risk occurrence limit; applies to accumulation of losses from a single CAT event.',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to the cedant by the reinsurer as a ceding commission to cover acquisition and administrative costs on QS treaties.',
    `cession_percentage` DECIMAL(7,4) COMMENT 'Percentage of risk ceded to reinsurers under a Quota Share (QS) layer. Expressed as a decimal (e.g., 0.3000 = 30%). Applicable to QS and proportional treaty structures.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this treaty layer record was first created in the reinsurance management system. Supports audit trail and data lineage requirements.',
    `deposit_premium` DECIMAL(18,2) COMMENT 'Provisional premium paid to the reinsurer at inception of the treaty period, subject to adjustment at year-end based on actual subject premium earned.',
    `effective_date` DATE COMMENT 'Date on which this treaty layer becomes operative and eligible to accept ceded risk and premium.',
    `exclusions_summary` STRING COMMENT 'Free-text summary of key exclusions applicable to this layer (e.g., nuclear, cyber, war, NBCR). Supports underwriting review and reinsurer communication.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'The loss level at which this layer is fully exhausted, calculated as attachment point plus layer limit. Marks the top of the layer in the reinsurance tower.',
    `expiry_date` DATE COMMENT 'Date on which this treaty layer ceases to be operative. Null for evergreen or continuous treaty layers.',
    `hours_clause` BIGINT COMMENT 'Number of consecutive hours defining the event window for CAT XL loss aggregation. Losses occurring within this window are treated as a single occurrence (e.g., 72 or 168 hours).',
    `index_base_year` BIGINT COMMENT 'The reference year used as the base for the index or stability clause adjustment. Applicable only when index_clause is true.',
    `index_clause` BOOLEAN COMMENT 'Indicates whether an index or stability clause applies to this layer, adjusting the attachment point and limit for inflation over the treaty period.',
    `lae_treatment` STRING COMMENT 'Specifies how LAE is handled within this layer. INCLUDED=LAE erodes the limit, EXCLUDED=LAE outside limit, PRO_RATA=LAE shared proportionally with losses.. Valid values are `INCLUDED|EXCLUDED|PRO_RATA`',
    `layer_limit` DECIMAL(18,2) COMMENT 'Maximum amount the reinsurer will pay for losses within this layer per occurrence or per risk. Defines the top of the layer in the XOL tower.',
    `layer_name` STRING COMMENT 'Descriptive business name for the layer (e.g., First XOL Layer, QS Tranche A, CAT XL Working Layer) used in bordereaux and reinsurer communications.',
    `layer_number` BIGINT COMMENT 'Sequential position of this layer within the treaty structure (e.g., 1 = first XOL layer, 2 = second XOL layer). Drives ordering in multi-layer tower analysis.',
    `layer_status` STRING COMMENT 'Current lifecycle state of the treaty layer. Drives whether cessions and premium calculations are applied against this layer.. Valid values are `ACTIVE|INACTIVE|PENDING|EXPIRED|CANCELLED`',
    `layer_type` STRING COMMENT 'Classification of the reinsurance layer structure. XOL=Excess of Loss, QS=Quota Share, CAT XL=Catastrophe Excess of Loss, FAC=Facultative, AGGREGATE_XL=Aggregate Excess of Loss.. Valid values are `XOL|QS|CAT_XL|FAC|AGGREGATE_XL|CAT_BOND`',
    `loss_basis` STRING COMMENT 'Trigger basis determining how losses are measured and applied to this layer. OCCURRENCE=per event, RISK=per insured risk, AGGREGATE=cumulative annual, CLAIMS_MADE=claims-made trigger.. Valid values are `OCCURRENCE|RISK|AGGREGATE|CLAIMS_MADE`',
    `max_ceding_commission_pct` DECIMAL(7,4) COMMENT 'Ceiling ceding commission rate applicable under a sliding scale commission arrangement. The cedant receives at most this rate when loss ratio is at its lowest.',
    `min_ceding_commission_pct` DECIMAL(7,4) COMMENT 'Floor ceding commission rate applicable under a sliding scale commission arrangement. The cedant receives at least this rate regardless of loss ratio.',
    `minimum_premium` DECIMAL(18,2) COMMENT 'Minimum reinsurance premium guaranteed to the reinsurer for this layer regardless of subject premium volume. Protects reinsurer against low-volume treaty years.',
    `occurrence_limit` DECIMAL(18,2) COMMENT 'Maximum reinsurer liability per single occurrence or event under this layer. Distinct from the aggregate annual limit. Applies to per-occurrence XOL and CAT XL structures.',
    `pml_basis` STRING COMMENT 'Basis used to size the layer relative to the cedants exposure. PML=Probable Maximum Loss, TIV=Total Insured Value, EML=Estimated Maximum Loss, MFL=Maximum Foreseeable Loss.. Valid values are `PML|TIV|EML|MFL`',
    `profit_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of reinsurer profit returned to the cedant as a profit commission under proportional QS layers. Incentivizes cedant loss control.',
    `reinstatement_count` BIGINT COMMENT 'Number of reinstatements available for this layer after a loss exhausts the limit. Common in CAT XL structures where one or two reinstatements are negotiated.',
    `reinstatement_premium_pct` DECIMAL(7,4) COMMENT 'Percentage of the original layer premium charged to reinstate the full limit after a loss. Expressed as a decimal (e.g., 1.0000 = 100% pro-rata reinstatement).',
    `reinsurance_premium` DECIMAL(18,2) COMMENT 'Gross premium ceded to reinsurers for this layer for the treaty period. For XOL layers, derived from ROL times limit; for QS, from cession percentage times subject premium.',
    `rol` DECIMAL(7,4) COMMENT 'Rate on Line expressed as a decimal fraction of the layer limit. Used to price non-proportional XOL and CAT XL layers. ROL multiplied by limit yields the reinsurance premium.',
    `signed_line_pct` DECIMAL(7,4) COMMENT 'Total percentage of the layer capacity that has been signed by reinsurers at placement. Should sum to 100% for a fully placed layer. Tracks placement completeness.',
    `sliding_scale_commission` BOOLEAN COMMENT 'Indicates whether the ceding commission on this QS layer is subject to a sliding scale that varies inversely with the loss ratio, rewarding better underwriting performance.',
    `subject_premium_basis` STRING COMMENT 'Premium base used to calculate ceded premium for proportional layers. GWP=Gross Written Premium, NWP=Net Written Premium, EP=Earned Premium, WP=Written Premium.. Valid values are `GWP|NWP|EP|WP`',
    `territorial_scope` STRING COMMENT 'Geographic territory covered by this treaty layer (e.g., USA, USA and Canada, specific state codes). Defines the geographic boundary of reinsurer liability.',
    `treaty_year` BIGINT COMMENT 'The underwriting or treaty year to which this layer belongs. Used for bordereaux processing, IBNR development, and year-of-account statutory reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this treaty layer record. Used for change tracking, audit compliance, and incremental data pipeline processing.',
    `written_line_pct` DECIMAL(7,4) COMMENT 'Percentage of the layer capacity initially offered and written by reinsurers before signing. May differ from signed line if the market is oversubscribed or undersubscribed.',
    CONSTRAINT pk_treaty_layer PRIMARY KEY(`treaty_layer_id`)
) COMMENT 'Defines each retention/limit layer within a treaty (e.g., first XOL layer, second XOL layer, QS tranche). Stores attachment point, limit, ROL, and layer sequence for multi-layer treaty structures.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` (
    `reinsurer_id` BIGINT COMMENT 'Unique surrogate identifier for each reinsurance counterparty record in the Pc_Insurance reinsurance management system.',
    `am_best_outlook` STRING COMMENT 'A.M. Best rating outlook indicating the expected direction of the reinsurers financial strength rating over the medium term.. Valid values are `stable|positive|negative|developing|under_review`',
    `am_best_rating` STRING COMMENT 'A.M. Best Financial Strength Rating (FSR) assigned to the reinsurer (e.g., A++, A+, A, A-, B++). Used to assess counterparty credit quality and treaty eligibility.',
    `am_best_rating_date` DATE COMMENT 'Date on which the current A.M. Best Financial Strength Rating was assigned or last affirmed, used to assess rating currency for treaty approval.',
    `approved_lob_list` STRING COMMENT 'Comma-delimited list of Lines of Business (LOB) for which this reinsurer is approved to accept cessions (e.g., GL, WC, APD, CAT XL). Governs treaty eligibility.',
    `authorized_status` STRING COMMENT 'Regulatory authorization status of the reinsurer in the cedants domicile state, determining credit-for-reinsurance treatment under NAIC model law.. Valid values are `authorized|unauthorized|certified|accredited|suspended`',
    `bank_account_reference` STRING COMMENT 'Internal reference code for the reinsurers designated bank account used for premium and loss settlement, stored as a tokenized reference to the financial system.',
    `claims_contact_email` STRING COMMENT 'Email address of the reinsurers claims department or designated claims contact for loss notification and recovery correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `class` STRING COMMENT 'Broad classification of the reinsurer by organizational class: professional reinsurer, captive, government-sponsored, Lloyds syndicate, or industry pool.. Valid values are `professional|captive|government|lloyd_syndicate|pool`',
    `collateral_type` STRING COMMENT 'Type of collateral arrangement in place with this reinsurer to secure recoverable balances: none, letter of credit, trust fund, funds withheld, or cash deposit.. Valid values are `none|letter_of_credit|trust_fund|funds_withheld|cash_deposit`',
    `counterparty_type` STRING COMMENT 'Classification of the reinsurance counterparty indicating its structural role: reinsurer, retrocessionaire, captive, pool, Lloyds syndicate, or fronting carrier.. Valid values are `reinsurer|retrocessionaire|captive|pool|syndicate|fronting_carrier`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the reinsurer master record was first created in the system, in ISO 8601 format with timezone offset.',
    `credit_limit_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which the reinsurer credit limit is denominated (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `credit_limit_usd` DECIMAL(18,2) COMMENT 'Maximum aggregate ceded exposure in USD that Pc_Insurance is authorized to place with this reinsurer across all treaties and facultative certificates.',
    `domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction where the reinsurer is legally domiciled and holds its primary insurance license.. Valid values are `^[A-Z]{3}$`',
    `domicile_state` STRING COMMENT 'Two-letter US state code of the reinsurers state of domicile for domestic reinsurers, used in NAIC statutory reporting and credit-for-reinsurance determinations.. Valid values are `^[A-Z]{2}$`',
    `fein` STRING COMMENT 'IRS-issued Federal Employer Identification Number (FEIN) for the reinsurer entity, used in tax reporting and financial settlement.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `funds_withheld_eligible` BOOLEAN COMMENT 'Indicates whether this reinsurer is eligible for funds-withheld collateral arrangements as an alternative to letters of credit for credit-for-reinsurance purposes.',
    `last_review_date` DATE COMMENT 'Date of the most recent periodic counterparty credit and compliance review conducted by the reinsurance or risk management team.',
    `legal_name` STRING COMMENT 'Full legal registered name of the reinsurance counterparty as filed with the domicile regulator and used in treaty and facultative contracts.',
    `lifecycle_status` STRING COMMENT 'Current operational status of the reinsurer counterparty record, governing whether new treaties or facultative placements may be bound with this entity.. Valid values are `active|inactive|suspended|under_review|terminated`',
    `lloyds_syndicate_number` STRING COMMENT 'Lloyds of London syndicate number for reinsurers operating as Lloyds syndicates. Null for non-Lloyds entities.',
    `loc_required` BOOLEAN COMMENT 'Indicates whether a Letter of Credit (LOC) is required from this reinsurer as collateral to support credit-for-reinsurance on the cedants statutory balance sheet.',
    `max_single_risk_limit_usd` DECIMAL(18,2) COMMENT 'Maximum ceded limit in USD that may be placed with this reinsurer on any single risk or facultative certificate, per internal counterparty concentration policy.',
    `naic_code` STRING COMMENT 'Five-digit NAIC company code assigned to the reinsurer for statutory reporting, regulatory filings, and industry data exchange.. Valid values are `^[0-9]{5}$`',
    `naic_group_code` STRING COMMENT 'NAIC-assigned group code identifying the reinsurance holding group, used for group-level concentration risk monitoring and statutory reporting.. Valid values are `^[0-9]{4,5}$`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic counterparty credit and compliance review, based on rating tier and exposure concentration.',
    `onboarding_date` DATE COMMENT 'Date on which the reinsurer was formally approved and onboarded as an authorized counterparty in the Pc_Insurance reinsurance management system.',
    `parent_group_name` STRING COMMENT 'Name of the ultimate parent holding group or reinsurance group to which this reinsurer entity belongs, used for group-level credit limit aggregation.',
    `preferred_settlement_currency` STRING COMMENT 'ISO 4217 three-letter currency code preferred by the reinsurer for premium and loss settlement transactions.. Valid values are `^[A-Z]{3}$`',
    `primary_contact_email` STRING COMMENT 'Email address of the primary relationship contact at the reinsurer for operational communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary relationship contact at the reinsurer for treaty negotiations, claims, and bordereaux submissions.',
    `primary_contact_phone` STRING COMMENT 'Direct telephone number of the primary relationship contact at the reinsurer.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `registered_address_city` STRING COMMENT 'City of the reinsurers official registered office address.',
    `registered_address_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the reinsurers registered office address.. Valid values are `^[A-Z]{3}$`',
    `registered_address_line1` STRING COMMENT 'First line of the reinsurers official registered office address as filed with the domicile regulator.',
    `sanctions_screen_date` DATE COMMENT 'Date on which the most recent OFAC and international sanctions screening was completed for this reinsurer counterparty.',
    `sanctions_screened` BOOLEAN COMMENT 'Indicates whether this reinsurer has passed the most recent OFAC and international sanctions screening required before treaty placement or payment.',
    `settlement_terms_days` BIGINT COMMENT 'Standard number of days from bordereaux submission or loss advice to expected settlement payment from the reinsurer, per treaty or market convention.',
    `sp_rating` STRING COMMENT 'S&P Global Ratings insurer financial strength rating for the reinsurer (e.g., AAA, AA+, AA, A+, A, BBB). Supplements A.M. Best for counterparty risk assessment.',
    `sp_rating_date` DATE COMMENT 'Date on which the current S&P Global financial strength rating was assigned or last affirmed.',
    `swift_bic_code` STRING COMMENT 'SWIFT Bank Identifier Code (BIC) for the reinsurers settlement bank, used for international wire transfers of premium and loss payments.. Valid values are `^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `trading_name` STRING COMMENT 'Doing Business As (DBA) or commercial brand name used by the reinsurer in market communications, distinct from the legal registered name.',
    `trust_fund_eligible` BOOLEAN COMMENT 'Indicates whether this reinsurer maintains a qualifying US trust fund under NAIC model law, enabling credit-for-reinsurance without LOC for unauthorized reinsurers.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the reinsurer master record, used for change tracking and data lineage in the Databricks Silver layer.',
    CONSTRAINT pk_reinsurer PRIMARY KEY(`reinsurer_id`)
) COMMENT 'Master record for each reinsurance counterparty (reinsurer or retrocessionaire). Captures legal name, NAIC code, A.M. Best rating, domicile, authorized status, and credit limit for counterparty risk management.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` (
    `treaty_reinsurer_id` BIGINT COMMENT 'Unique surrogate identifier for each treaty-reinsurer participation record in the reinsurance panel.',
    `assumed_reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer party entity participating in this treaty panel.',
    `ri_broker_id` BIGINT COMMENT 'Reference to the reinsurance broker who placed this reinsurers line on the treaty, used for brokerage commission and placement tracking.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the parent reinsurance treaty to which this reinsurer participates.',
    `treaty_replacement_reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer who replaced this participant on the treaty panel following a withdrawal or capacity reduction.',
    `am_best_rating` STRING COMMENT 'A.M. Best financial strength rating of the reinsurer at the time of treaty placement, used for credit quality and security assessment.',
    `brokerage_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium payable to the reinsurance broker for placing this reinsurers line on the treaty.',
    `ceded_lae_amount` DECIMAL(18,2) COMMENT 'Total Loss Adjustment Expense (LAE) ceded to this reinsurer under this treaty participation for the current treaty period.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Total losses ceded to this reinsurer under this treaty participation for the current treaty period, in the treaty currency.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Total premium ceded to this reinsurer under this treaty participation for the current treaty period, in the treaty currency.',
    `collateral_held_amount` DECIMAL(18,2) COMMENT 'Actual amount of collateral currently held from this reinsurer (letters of credit, trust funds, funds withheld) for credit for reinsurance.',
    `collateral_required_amount` DECIMAL(18,2) COMMENT 'Amount of collateral required from this reinsurer to support credit for reinsurance, based on authorization status and applicable regulations.',
    `collateral_type` STRING COMMENT 'Type of collateral arrangement held from this reinsurer (e.g., letter of credit, trust fund, funds withheld, cash deposit).. Valid values are `letter_of_credit|trust_fund|funds_withheld|cash_deposit|other`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this treaty-reinsurer participation record was first created in the reinsurance management system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which ceded premium, losses, and recoverable balances are denominated for this reinsurer.. Valid values are `^[A-Z]{3}$`',
    `domicile_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the reinsurers domicile jurisdiction, used for credit for reinsurance and regulatory reporting.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date on which this reinsurers participation in the treaty becomes binding and effective.',
    `expiry_date` DATE COMMENT 'Date on which this reinsurers participation in the treaty expires or terminates. Null for open-ended participations.',
    `funds_withheld_amount` DECIMAL(18,2) COMMENT 'Amount of ceded premium withheld by the cedant from this reinsurer under a funds withheld arrangement, reducing settlement cash flows.',
    `is_authorized_reinsurer` BOOLEAN COMMENT 'Indicates whether this reinsurer is authorized (licensed) in the cedants domicile state, affecting credit for reinsurance treatment.',
    `is_certified_reinsurer` BOOLEAN COMMENT 'Indicates whether this reinsurer holds certified reinsurer status under NAIC Credit for Reinsurance Model Law, enabling reduced collateral requirements.',
    `is_lead_reinsurer` BOOLEAN COMMENT 'Indicates whether this reinsurer is the lead underwriter on the treaty panel, responsible for setting terms and conditions.',
    `naic_reinsurer_code` STRING COMMENT 'NAIC-assigned five-digit company code for the reinsurer, used in statutory Schedule F and reinsurance regulatory filings.. Valid values are `^[0-9]{5}$`',
    `offered_line_pct` DECIMAL(7,4) COMMENT 'The percentage of the treaty capacity initially offered to this reinsurer during placement, before signing adjustments.',
    `order_hereon_pct` DECIMAL(7,4) COMMENT 'The percentage of the total treaty order placed with this reinsurer, reflecting the cedants actual placement instruction.',
    `panel_sequence` BIGINT COMMENT 'Ordering sequence of this reinsurer within the treaty panel, used for bordereaux presentation and cession processing priority.',
    `participation_notes` STRING COMMENT 'Free-text notes capturing special conditions, side agreements, or underwriting remarks specific to this reinsurers participation on the treaty.',
    `participation_reference` STRING COMMENT 'Externally-known unique reference number assigned to this reinsurers line on the treaty, used in bordereaux and cession statements.',
    `participation_status` STRING COMMENT 'Current lifecycle status of the reinsurers participation on the treaty panel (e.g., active, signed, withdrawn, pending, cancelled, suspended).. Valid values are `active|signed|withdrawn|pending|cancelled|suspended`',
    `profit_commission_pct` DECIMAL(7,4) COMMENT 'Profit commission percentage payable by this reinsurer to the cedant if the treaty produces a profit, per the profit commission formula.',
    `rating_as_of_date` DATE COMMENT 'Date as of which the reinsurers financial strength ratings (A.M. Best, S&P) were captured for this participation record.',
    `recoverable_balance` DECIMAL(18,2) COMMENT 'Outstanding reinsurance recoverable balance owed by this reinsurer to the cedant, representing unpaid ceded losses and LAE.',
    `reinsurance_commission_pct` DECIMAL(7,4) COMMENT 'Commission percentage payable by this reinsurer to the cedant on ceded premium, applicable for quota share and proportional treaties.',
    `reinsurer_role` STRING COMMENT 'Role of the reinsurer on the treaty panel (e.g., lead, follow, co-reinsurer, fronting, security), indicating their authority and position.. Valid values are `lead|follow|co-reinsurer|fronting|security`',
    `signed_line_pct` DECIMAL(7,4) COMMENT 'The final signed share percentage allocated to this reinsurer after signing-down of the oversubscribed panel.',
    `signing_date` DATE COMMENT 'Date on which this reinsurer formally signed their line on the treaty, confirming their participation and subscribed share.',
    `sliding_scale_max_commission_pct` DECIMAL(7,4) COMMENT 'Maximum commission percentage under a sliding scale commission arrangement, applied when the loss ratio is at its minimum threshold.',
    `sliding_scale_min_commission_pct` DECIMAL(7,4) COMMENT 'Minimum commission percentage under a sliding scale commission arrangement, applied when the loss ratio reaches its maximum threshold.',
    `sp_rating` STRING COMMENT 'Standard & Poors (S&P) financial strength rating of the reinsurer at the time of treaty placement, used for panel security evaluation.',
    `subscribed_share_pct` DECIMAL(7,4) COMMENT 'The reinsurers confirmed subscribed share of the treaty, representing their proportional participation used for cession and premium allocation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this treaty-reinsurer participation record was last modified in the reinsurance management system.',
    `withdrawal_date` DATE COMMENT 'Date on which this reinsurer withdrew from the treaty panel, if applicable. Null for active participations.',
    `withdrawal_reason` STRING COMMENT 'Reason for the reinsurers withdrawal from the treaty panel (e.g., capacity reduction, credit downgrade, market exit, cedant request).. Valid values are `capacity_reduction|credit_downgrade|market_exit|cedant_request|regulatory|other`',
    `written_line_pct` DECIMAL(7,4) COMMENT 'The percentage of the treaty capacity written (committed) by this reinsurer at the time of placement, prior to signing-down.',
    CONSTRAINT pk_treaty_reinsurer PRIMARY KEY(`treaty_reinsurer_id`)
) COMMENT 'Junction table linking a treaty to its participating reinsurers with each reinsurers subscribed share percentage, signed line, written line, and participation status. Supports multi-reinsurer panel structures.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` (
    `reinsurance_cession_id` BIGINT COMMENT 'Unique surrogate identifier for each cession transaction record in the reinsurance cession ledger.',
    `bordereaux_id` BIGINT COMMENT 'Foreign key linking to reinsurance.bordereaux. Business justification: Cessions are reported in bordereaux submissions. Currently has bordereaux_period (string), should have proper FK to the actual bordereaux record for referential integrity and join',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this cession record (e.g., USD, GBP, EUR).',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_certificate. Business justification: Cessions can be under either treaty OR FAC certificate. Currently cession has treaty_id but missing fac_certificate_id for FAC-based cessions.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Property cessions reference specific insured locations to determine ceded TIV, apply retention and limit, and validate treaty coverage.',
    `lob_code_id` BIGINT COMMENT 'NAIC line of business code or description for the ceded risk (e.g., Commercial Auto, GL, Property, WC). Used in bordereaux and statutory reporting. [ENUM-REF-CANDIDATE: promote to reference product]',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Cessions must identify the specific coverage being ceded for accurate premium allocation, loss recovery calculations, and bordereaux reporting.',
    `policy_id` BIGINT COMMENT 'Reference to the underlying insurance policy whose risk is being ceded to the reinsurer.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer counterparty accepting the ceded risk on this transaction.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty or facultative (FAC) certificate under which this cession is placed.',
    `risk_unit_id` BIGINT COMMENT 'Reference to the specific risk exposure or scheduled item being ceded, enabling sub-policy cession granularity.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty_layer. Business justification: Cessions apply to specific treaty layers. Currently has layer_number (INT), should have proper FK to treaty_layer for full layer definition and terms.',
    `am_best_rating` STRING COMMENT 'A.M. Best financial strength rating of the assuming reinsurer at the time of cession placement, used for credit quality and collateral requirement assessment.',
    `attachment_point` DECIMAL(18,2) COMMENT 'Dollar threshold at which the reinsurers liability begins for excess of loss (XOL) and CAT XL structures. Null for pro-rata cessions.',
    `basis` STRING COMMENT 'Contractual basis on which losses are ceded: risks attaching, losses occurring, or claims made. Determines which policy periods are covered under the treaty.. Valid values are `risks_attaching|losses_occurring|claims_made`',
    `cat_event_code` STRING COMMENT 'Industry catastrophe event code (e.g., ISO/PCS event code) linking this cession to a declared catastrophe (CAT) occurrence for CAT XL recovery tracking.',
    `ceded_alae` DECIMAL(18,2) COMMENT 'Allocated loss adjustment expense (ALAE) ceded to the reinsurer under this transaction, representing defense and cost containment expenses.',
    `ceded_earned_premium` DECIMAL(18,2) COMMENT 'Portion of the ceded written premium that has been earned through the exposure period to date, used in loss ratio and statutory reporting.',
    `ceded_ibnr` DECIMAL(18,2) COMMENT 'Actuarial estimate of incurred but not reported (IBNR) losses ceded to the reinsurer, used in statutory reserving and Schedule F reporting.',
    `ceded_limit` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery limit ceded under this transaction. For XOL structures, this is the layer limit above the retention.',
    `ceded_loss_paid` DECIMAL(18,2) COMMENT 'Cumulative paid loss amount ceded to and recovered from the reinsurer under this cession as of the reporting date.',
    `ceded_loss_reserve` DECIMAL(18,2) COMMENT 'Outstanding case reserve (OCR) amount ceded to the reinsurer representing estimated future loss payments recoverable under this cession.',
    `ceded_share_pct` DECIMAL(7,4) COMMENT 'Percentage of the risk ceded to the reinsurer under this transaction, expressed as a decimal (e.g., 0.3000 = 30%). Used in quota share (QS) and pro-rata calculations.',
    `ceded_tiv` DECIMAL(18,2) COMMENT 'Total insured value (TIV) of the risk exposure ceded to the reinsurer under this cession, used for property and CAT accumulation tracking.',
    `ceded_unearned_premium` DECIMAL(18,2) COMMENT 'Unearned portion of the ceded written premium representing the reinsurers liability for unexpired risk as of the reporting date.',
    `ceded_written_premium` DECIMAL(18,2) COMMENT 'Portion of the gross written premium (GWP) ceded to the reinsurer under this transaction. Reduces net written premium (NWP) on the cedants books.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Dollar amount of ceding commission receivable from the reinsurer on this cession, calculated as ceded premium multiplied by the ceding commission rate.',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to the cedant by the reinsurer as a ceding commission to offset acquisition and administrative costs.',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Dollar amount of collateral posted by the reinsurer (letter of credit or trust) to secure the cedants reinsurance recoverable on this cession.',
    `collateral_required` BOOLEAN COMMENT 'Indicates whether the reinsurer is required to post collateral (e.g., letter of credit or trust fund) for this cession due to unauthorized reinsurer status.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this cession record was first created in the reinsurance management system.',
    `effective_date` DATE COMMENT 'Date on which this cession becomes effective and the reinsurer assumes its share of the ceded risk.',
    `endorsement_reference` STRING COMMENT 'Reference to the policy endorsement (ENDT) that triggered or modified this cession, linking mid-term changes to the corresponding cession adjustment.',
    `expiry_date` DATE COMMENT 'Date on which this cession expires and the reinsurers liability for new losses ceases under the ceded risk.',
    `gross_written_premium` DECIMAL(18,2) COMMENT 'Total gross written premium (GWP) on the underlying policy or risk exposure before any cession or reinsurance deduction.',
    `is_retrocession` BOOLEAN COMMENT 'Indicates whether this cession is a retrocession (i.e., the cedant is itself a reinsurer ceding risk further to a retrocessionaire).',
    `naic_company_code` STRING COMMENT 'Five-digit NAIC company code of the assuming reinsurer, required for Schedule F statutory reporting and reinsurer credit risk assessment.. Valid values are `^[0-9]{5}$`',
    `number` STRING COMMENT 'Externally-known business reference number assigned to this cession event, used in bordereaux reporting and reinsurer correspondence.. Valid values are `^CES-[0-9]{4}-[0-9]{8}$`',
    `placement_type` STRING COMMENT 'Indicates whether the cession is placed under a standing reinsurance treaty or a facultative (FAC) certificate for an individual risk.. Valid values are `treaty|facultative`',
    `profit_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of reinsurer profit returned to the cedant as a profit commission under sliding-scale or profit-sharing treaty arrangements.',
    `rate_on_line_pct` DECIMAL(7,4) COMMENT 'Rate on line (ROL) expressed as a percentage of the reinsurance limit, used to price XOL and CAT XL layers and assess cost efficiency.',
    `reinstatement_premium` DECIMAL(18,2) COMMENT 'Additional premium paid to reinstate the reinsurance limit after a loss occurrence has eroded the layer, applicable to XOL and CAT XL structures.',
    `reinsurance_cession_date` DATE COMMENT 'The business event date on which the cession was formally recorded and submitted to the reinsurer, distinct from the risk effective date.',
    `reinsurance_cession_status` STRING COMMENT 'Current lifecycle state of the cession transaction. [ENUM-REF-CANDIDATE: draft|active|amended|cancelled|expired|settled — promote to reference product if statuses expand]. Valid values are `draft|active|amended|cancelled|expired|settled`',
    `reinsurance_cession_type` STRING COMMENT 'Classification of the cession structure: pro-rata (quota share), excess of loss (XOL), facultative (FAC), catastrophe excess of loss (CAT XL), or catastrophe bond (CAT Bond).. Valid values are `pro_rata|excess_of_loss|facultative|cat_xl|cat_bond`',
    `reinsurance_recoverable` DECIMAL(18,2) COMMENT 'Total reinsurance recoverable balance on this cession, comprising ceded paid losses, ceded reserves, and ceded IBNR outstanding from the reinsurer.',
    `retention_amount` DECIMAL(18,2) COMMENT 'The cedants net retained loss amount before reinsurance recovery applies. For XOL, this is the attachment point; for QS, it is the retained share amount.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this cession record, supporting audit trail and change tracking.',
    CONSTRAINT pk_reinsurance_cession PRIMARY KEY(`reinsurance_cession_id`)
) COMMENT 'Transactional cession event linking a ceded policy or risk exposure to a treaty or FAC certificate via foreign keys. Captures ceded TIV, premium, limit, retention, effective date, share, per-policy endorsement reference, and cession basis (pro-rata or';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` (
    `policy_cession_id` BIGINT COMMENT 'Unique surrogate identifier for each policy-cession pairing record in the junction table.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this policy-cession record (e.g., USD, GBP, EUR).',
    `endorsement_id` BIGINT COMMENT 'Reference to the policy endorsement (ENDT) that triggered or modified this policy-cession pairing, if applicable.',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_certificate. Business justification: Policy_cession can link to FAC certificates. Currently has facultative_certificate_number (string), should have proper FK to fac_certificate for referential integrity.',
    `lob_code_id` BIGINT COMMENT 'NAIC or internal line of business (LOB) code for the ceded policy (e.g., GL, WC, APD, BOP, CPP). Used for bordereaux segmentation and statutory reporting.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Policy cessions often apply to specific coverages within a policy rather than all coverages uniformly.',
    `policy_id` BIGINT COMMENT 'Reference to the insurance policy being ceded under this record.',
    `reinsurance_cession_id` BIGINT COMMENT 'Reference to the reinsurance cession record (treaty or facultative certificate) under which this policy is ceded.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty or facultative (FAC) certificate governing this cession.',
    `attachment_point` DECIMAL(18,2) COMMENT 'The loss amount at which the reinsurers liability attaches under an Excess of Loss (XOL) or CAT XL layer for this policy-cession pairing.',
    `bordereaux_included` BOOLEAN COMMENT 'Indicates whether this policy-cession record has been included in a bordereaux submission to the reinsurer for the current reporting period.',
    `bordereaux_period` STRING COMMENT 'The YYYY-MM reporting period for which this policy-cession record is included in the bordereaux submission to the reinsurer.. Valid values are `^d{4}-(0[1-9]|1[0-2])$`',
    `cancellation_date` DATE COMMENT 'Date on which this policy-cession pairing was cancelled, if applicable. Null for active or expired records.',
    `cancellation_reason` STRING COMMENT 'Reason code for the cancellation of this policy-cession pairing.. Valid values are `POLICY_CANCELLED|TREATY_TERMINATED|ENDORSEMENT|REUNDERWRITING|ERROR_CORRECTION`',
    `cat_event_code` STRING COMMENT 'Industry or internal catastrophe (CAT) event code associated with this cession, used for CAT XL recovery tracking and PML reporting.',
    `ceded_alae` DECIMAL(18,2) COMMENT 'Allocated loss adjustment expense (ALAE) ceded to the reinsurer under this policy-cession pairing.',
    `ceded_ibnr` DECIMAL(18,2) COMMENT 'Actuarial estimate of ceded IBNR reserves attributable to this policy-cession pairing, representing unreported losses expected to be recovered from the reinsurer.',
    `ceded_limit_amount` DECIMAL(18,2) COMMENT 'Maximum monetary amount the reinsurer is liable for under this policy-cession pairing, representing the reinsurers limit layer.',
    `ceded_loss_paid` DECIMAL(18,2) COMMENT 'Total loss amounts paid by the reinsurer under this policy-cession pairing to date.',
    `ceded_loss_reserve` DECIMAL(18,2) COMMENT 'Outstanding case reserve (OCR) amount ceded to the reinsurer for open claims under this policy-cession pairing.',
    `ceded_premium_earned` DECIMAL(18,2) COMMENT 'Portion of the ceded written premium that has been earned as of the reporting date, based on the policy exposure period.',
    `ceded_premium_written` DECIMAL(18,2) COMMENT 'Gross written premium (GWP) ceded to the reinsurer for this policy-cession pairing at policy inception or renewal.',
    `ceded_share_pct` DECIMAL(7,4) COMMENT 'Percentage of the risk ceded to the reinsurer under this pairing, expressed as a decimal (e.g., 0.3000 = 30%). Used in Quota Share (QS) and proportional treaties.',
    `ceded_unearned_premium` DECIMAL(18,2) COMMENT 'Portion of the ceded written premium not yet earned as of the reporting date, representing the reinsurers unearned premium reserve liability.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Monetary amount of ceding commission receivable from the reinsurer for this policy-cession pairing.',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to the cedant as ceding commission by the reinsurer under proportional (QS) treaties.',
    `cession_reference_number` STRING COMMENT 'Externally-known alphanumeric reference number assigned to this policy-cession pairing, used in bordereaux and reinsurer reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy-cession record was first created in the system.',
    `effective_date` DATE COMMENT 'Date on which this policy-cession pairing becomes effective and the ceded risk transfer begins.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'The loss amount at which the reinsurers layer is fully exhausted (attachment point plus ceded limit). Defines the top of the reinsurance layer.',
    `expiration_date` DATE COMMENT 'Date on which this policy-cession pairing expires and the ceded risk transfer ends. Null for open-ended cessions.',
    `net_written_premium` DECIMAL(18,2) COMMENT 'Net written premium (NWP) retained by Pc_Insurance after cession for this policy, calculated as gross written premium minus ceded written premium.',
    `policy_term_type` STRING COMMENT 'Indicates whether this cession relates to a new business (NB), renewal (REN), endorsement (ENDT), cancellation (CANC), or reinstatement transaction.. Valid values are `NB|REN|ENDT|CANC|REINSTATE`',
    `profit_commission_amount` DECIMAL(18,2) COMMENT 'Profit commission receivable from the reinsurer based on favorable loss experience under this policy-cession pairing.',
    `reinstatement_premium` DECIMAL(18,2) COMMENT 'Additional premium paid to reinstate the reinsurance limit after a loss occurrence has partially or fully exhausted the ceded layer.',
    `reinsurance_recoverable` DECIMAL(18,2) COMMENT 'Total reinsurance recoverable balance outstanding from the reinsurer for this policy-cession pairing, including paid and reserved amounts.',
    `reinsurer_share_pct` DECIMAL(7,4) COMMENT 'Percentage of the ceded layer subscribed by a specific reinsurer where multiple reinsurers participate in the same treaty or FAC placement.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Monetary amount retained by the cedant (Pc_Insurance) before the reinsurers layer attaches. Represents the cedants net retention per policy.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this policy-cession record originated (e.g., SICS, Sapiens ReinsuranceMaster, Guidewire PolicyCenter).. Valid values are `SICS|SAPIENS_RI|GUIDEWIRE_PC|DUCK_CREEK|MANUAL`',
    `tiv_ceded` DECIMAL(18,2) COMMENT 'Total insured value (TIV) of the ceded risk exposure under this policy-cession pairing, used for property CAT modeling and PML calculations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this policy-cession record was last modified.',
    CONSTRAINT pk_policy_cession PRIMARY KEY(`policy_cession_id`)
) COMMENT 'Junction table resolving the many-to-many relationship between policies and cessions. Tracks which policies are ceded under which cession records, with ceded share, effective period, and endorsement reference per policy-cession pairing.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` (
    `bordereaux_id` BIGINT COMMENT 'Unique surrogate identifier for the bordereaux submission record in the reinsurance management system.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code in which all monetary amounts on this bordereaux are denominated.',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_certificate. Business justification: Bordereaux submissions can be for FAC certificates, not just treaties. Currently only has treaty_id. Missing FK for FAC bordereaux reporting.',
    `lob_code_id` BIGINT COMMENT 'NAIC or internal Line of Business code identifying the class of business covered by this bordereaux (e.g., GL, WC, APD, BOP).',
    `prior_bordereaux_id` BIGINT COMMENT 'Reference to the previous version of this bordereaux that was superseded by the current corrected or amended submission.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer party receiving this bordereaux submission.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty under which this bordereaux is submitted.',
    `accounting_period` STRING COMMENT 'Fiscal accounting period (e.g., 2024-Q1 or 2024-M03) to which the ceded premium and loss figures in this bordereaux are posted.. Valid values are `^[0-9]{4}-(Q[1-4]|M(0[1-9]|1[0-2]))$`',
    `acknowledgement_date` DATE COMMENT 'Date on which the reinsurer formally acknowledged receipt and acceptance of the bordereaux submission.',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized or accredited in the cedants domicile state, affecting credit for reinsurance on statutory balance sheet.',
    `bordereaux_type` STRING COMMENT 'Classifies the bordereaux as a premium bordereaux (ceded premium activity), loss bordereaux (ceded loss activity), combined, or adjustment.. Valid values are `premium|loss|combined|adjustment`',
    `cat_event_code` STRING COMMENT 'Industry or internal CAT event code (e.g., ISO PCS code) identifying a catastrophe event included in this loss bordereaux.',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether this bordereaux includes losses or premiums attributable to a declared catastrophe (CAT) event.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Allocated Loss Adjustment Expense (ALAE) ceded to the reinsurer for the reporting period, recoverable under treaty terms.',
    `ceded_ibnr_amount` DECIMAL(18,2) COMMENT 'Ceded portion of the Incurred But Not Reported (IBNR) reserve included in this bordereaux for the reporting period.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Total paid and outstanding ceded loss amount recoverable from the reinsurer for the reporting period.',
    `ceded_premium_adjustment` DECIMAL(18,2) COMMENT 'Adjustment to ceded premium arising from endorsements, cancellations, or audit premiums included in this bordereaux period.',
    `ceded_share_pct` DECIMAL(7,4) COMMENT 'Percentage of risk ceded to the reinsurer under the treaty for this bordereaux period, expressed as a decimal (e.g., 0.3000 = 30%).',
    `ceded_tiv` DECIMAL(18,2) COMMENT 'Aggregate Total Insured Value (TIV) of risks ceded to the reinsurer under this bordereaux for the reporting period.',
    `ceded_ulae_amount` DECIMAL(18,2) COMMENT 'Unallocated Loss Adjustment Expense (ULAE) ceded to the reinsurer for the reporting period where treaty terms permit recovery.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Total ceding commission earned by the cedant on ceded premium for the reporting period, reducing net ceded premium payable.',
    `claim_count` BIGINT COMMENT 'Number of individual claims included in this loss bordereaux submission for the reporting period.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux record was first created in the reinsurance management system.',
    `due_date` DATE COMMENT 'Contractual due date by which the bordereaux must be submitted to the reinsurer per treaty terms.',
    `experience_refund_amount` DECIMAL(18,2) COMMENT 'Experience refund or sliding scale commission adjustment payable under the treaty based on loss experience for the period.',
    `gross_ceded_premium` DECIMAL(18,2) COMMENT 'Total gross written premium ceded to the reinsurer for the reporting period before deduction of ceding commission.',
    `net_ceded_premium` DECIMAL(18,2) COMMENT 'Net premium ceded to the reinsurer after deducting ceding commission from gross ceded premium for the reporting period.',
    `number` STRING COMMENT 'Externally-known unique reference number assigned to this bordereaux submission, used in reinsurer correspondence and bordereaux registers.. Valid values are `^BDX-[0-9]{4}-[0-9]{6}$`',
    `placement_broker` STRING COMMENT 'Name of the reinsurance intermediary or broker who placed the treaty and through whom the bordereaux may be routed.',
    `policy_count` BIGINT COMMENT 'Number of individual policies included in this bordereaux submission for the reporting period.',
    `profit_commission_amount` DECIMAL(18,2) COMMENT 'Profit commission payable to the cedant by the reinsurer based on treaty profitability for the reporting period.',
    `recoverable_balance` DECIMAL(18,2) COMMENT 'Net outstanding reinsurance recoverable balance owed by the reinsurer as of the bordereaux reporting period end date.',
    `remarks` STRING COMMENT 'Free-text remarks or notes accompanying the bordereaux submission, such as explanations for adjustments or disputed items.',
    `reporting_period_end_date` DATE COMMENT 'Last day of the treaty period or accounting period covered by this bordereaux submission.',
    `reporting_period_start_date` DATE COMMENT 'First day of the treaty period or accounting period covered by this bordereaux submission.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Cedant net retention amount for the reporting period, representing the portion of risk not ceded to the reinsurer.',
    `submission_date` DATE COMMENT 'Calendar date on which the bordereaux was formally submitted to the reinsurer or reinsurance broker.',
    `submission_format` STRING COMMENT 'File or data format in which the bordereaux was submitted to the reinsurer (e.g., ACORD standard, CSV, XML, XLSX, PDF).. Valid values are `ACORD|CSV|XML|XLSX|PDF`',
    `submission_method` STRING COMMENT 'Channel or method used to transmit the bordereaux to the reinsurer (electronic data interchange, reinsurer portal, email, or paper).. Valid values are `electronic|portal|email|paper`',
    `submission_status` STRING COMMENT 'Current lifecycle state of the bordereaux submission workflow from draft through reinsurer acknowledgement or dispute resolution.. Valid values are `draft|submitted|acknowledged|disputed|accepted|voided`',
    `treaty_type` STRING COMMENT 'Type of reinsurance arrangement covered by this bordereaux: Quota Share (QS), Excess of Loss (XOL), Catastrophe Excess of Loss (CAT XL), surplus, or Facultative (FAC).. Valid values are `QS|XOL|CAT_XL|surplus|FAC`',
    `treaty_year` BIGINT COMMENT 'Underwriting or treaty year to which this bordereaux relates, used for year-of-account tracking and statutory reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux record was most recently modified in the reinsurance management system.',
    `version_number` BIGINT COMMENT 'Sequential version number of this bordereaux submission, incremented when a corrected or amended bordereaux replaces a prior submission.',
    CONSTRAINT pk_bordereaux PRIMARY KEY(`bordereaux_id`)
) COMMENT 'Periodic bordereaux submission record sent to reinsurers summarizing ceded premium and loss activity for a treaty period. Captures bordereaux type (premium or loss), reporting period, submission date, and aggregate ceded amounts.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` (
    `bordereaux_line_id` BIGINT COMMENT 'Unique surrogate identifier for each individual line item within a bordereaux submission. Primary key for the bordereaux_line entity.',
    `bordereaux_id` BIGINT COMMENT 'Reference to the parent bordereaux submission header that this line belongs to. Links the line to its submission batch.',
    `claim_id` BIGINT COMMENT 'Reference to the underlying claim record for claim-type bordereaux lines. Null for premium-only cession lines.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this bordereaux line (e.g., USD, GBP, EUR).',
    `fac_certificate_id` BIGINT COMMENT 'Reference to the facultative reinsurance certificate under which this line is reported. Applicable for facultative bordereaux submissions.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Bordereaux line items for property risks report location-specific details (address, TIV, construction type, occupancy) to reinsurers for premium and loss validation.',
    `lob_code_id` BIGINT COMMENT 'NAIC or internal line of business code identifying the insurance product class for this cession line (e.g., GL, WC, APD, PD, BI).',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Bordereaux lines report individual coverage exposures and losses to reinsurers per treaty terms.',
    `policy_id` BIGINT COMMENT 'Reference to the underlying insurance policy associated with this bordereaux cession or claim line.',
    `reinsurance_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.cession. Business justification: Each bordereaux line reports a specific cession. Missing the cession FK that links bordereaux line items back to the cession being reported.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty under which this cession line is reported. Applicable for treaty bordereaux submissions.',
    `cat_event_code` STRING COMMENT 'Industry or internal CAT event identifier (e.g., ISO PCS code) associated with this bordereaux line for catastrophe loss aggregation and CAT XL recovery.',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether this bordereaux line is associated with a catastrophe-exposed risk or loss event, used for CAT XL treaty aggregation.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'The Allocated Loss Adjustment Expense ceded to the reinsurer for this line, representing the reinsurers share of directly attributable claim expenses.',
    `ceded_earned_premium` DECIMAL(18,2) COMMENT 'The portion of earned premium ceded to the reinsurer for this bordereaux line, representing the time-proportionate share of ceded written premium.',
    `ceded_limit_amount` DECIMAL(18,2) COMMENT 'The maximum reinsurance recovery limit applicable to this cession line under the treaty or FAC certificate.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'The gross loss amount ceded to the reinsurer for this bordereaux line, representing the reinsurers share of paid or incurred losses.',
    `ceded_share_pct` DECIMAL(7,4) COMMENT 'The percentage of the risk ceded to the reinsurer under the treaty or FAC certificate for this line, expressed as a decimal (e.g., 0.3000 = 30%).',
    `ceded_ulae_amount` DECIMAL(18,2) COMMENT 'The Unallocated Loss Adjustment Expense ceded to the reinsurer for this line, representing the reinsurers share of overhead claim handling costs.',
    `ceded_written_premium` DECIMAL(18,2) COMMENT 'The portion of written premium ceded to the reinsurer for this bordereaux line, calculated as GWP multiplied by the ceded share percentage.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'The monetary ceding commission payable by the reinsurer to the cedant on this bordereaux line, derived from ceded premium and commission rate.',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'The commission rate payable by the reinsurer to the cedant on ceded premium for this line, expressed as a decimal (e.g., 0.2500 = 25%).',
    `certificate_number` STRING COMMENT 'The externally-known facultative certificate number carried on the line for FAC bordereaux reconciliation. Null for treaty lines.',
    `coverage_type` STRING COMMENT 'The specific coverage type ceded on this line (e.g., BI, PD, UM, UIM, PIP, MedPay, GL, WC). Aligns to the coverage part of the underlying policy.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux line record was first created in the system, used for audit trail and data lineage.',
    `date_of_loss` DATE COMMENT 'The date on which the insured loss event occurred. Populated for claim-type bordereaux lines; null for premium-only lines.',
    `dispute_reason` STRING COMMENT 'Narrative explanation of the reason this bordereaux line is in disputed status, capturing the cedant or reinsurers basis for disagreement.',
    `gross_written_premium` DECIMAL(18,2) COMMENT 'The total gross written premium on the underlying cedant policy for this bordereaux line before any cession.',
    `insured_name` STRING COMMENT 'Name of the insured party on the underlying policy for this bordereaux line, as reported to the reinsurer on the cession record.',
    `line_number` BIGINT COMMENT 'Sequential line number within the bordereaux submission, used for ordering and reconciliation of individual cession or claim entries.',
    `line_status` STRING COMMENT 'Current processing status of this bordereaux line in the reconciliation workflow between cedant and reinsurer.. Valid values are `DRAFT|SUBMITTED|ACCEPTED|DISPUTED|SETTLED|VOIDED`',
    `line_type` STRING COMMENT 'Classifies the nature of the bordereaux line: premium cession, claim loss, adjustment, reinstatement premium, or return premium.. Valid values are `PREMIUM|CLAIM|ADJUSTMENT|REINSTATEMENT|RETURN_PREMIUM`',
    `net_ceded_premium` DECIMAL(18,2) COMMENT 'The net premium remitted to the reinsurer after deducting the ceding commission from the ceded written premium for this bordereaux line.',
    `original_tiv` DECIMAL(18,2) COMMENT 'Total Insured Value of the underlying risk exposure on the cedant policy for this bordereaux line, used for proportional share calculations.',
    `policy_expiry_date` DATE COMMENT 'The expiration date of the underlying cedant policy associated with this bordereaux line.',
    `policy_inception_date` DATE COMMENT 'The effective start date of the underlying cedant policy associated with this bordereaux line.',
    `recoverable_balance` DECIMAL(18,2) COMMENT 'Outstanding reinsurance recoverable balance for this bordereaux line, representing amounts owed by the reinsurer not yet collected by the cedant.',
    `reinstatement_premium_amount` DECIMAL(18,2) COMMENT 'Premium charged to reinstate the reinsurance limit after a loss occurrence under XOL or CAT XL treaties. Populated for reinstatement-type lines only.',
    `report_period_end_date` DATE COMMENT 'End date of the reporting period covered by this bordereaux line, used for earned premium and loss period attribution.',
    `report_period_start_date` DATE COMMENT 'Start date of the reporting period covered by this bordereaux line, used for earned premium and loss period attribution.',
    `retention_amount` DECIMAL(18,2) COMMENT 'The cedants retained portion of the risk or loss for this line, representing the amount not ceded to the reinsurer.',
    `risk_description` STRING COMMENT 'Narrative description of the insured risk or exposure associated with this bordereaux line, as reported to the reinsurer.',
    `risk_expiry_date` DATE COMMENT 'The date on which the ceded risk exposure terminates under the reinsurance treaty or FAC certificate for this line.',
    `risk_inception_date` DATE COMMENT 'The date on which the ceded risk exposure commenced under the reinsurance treaty or FAC certificate for this line.',
    `settlement_date` DATE COMMENT 'The date on which this bordereaux line was financially settled between the cedant and the reinsurer.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this bordereaux line record, used for change tracking and reconciliation audit.',
    `xol_attachment_point` DECIMAL(18,2) COMMENT 'The loss threshold at which the XOL reinsurance layer attaches for this bordereaux line. Null for quota share or non-XOL treaty lines.',
    `xol_exhaustion_point` DECIMAL(18,2) COMMENT 'The loss level at which the XOL reinsurance layer is fully exhausted for this bordereaux line. Null for quota share or non-XOL treaty lines.',
    CONSTRAINT pk_bordereaux_line PRIMARY KEY(`bordereaux_line_id`)
) COMMENT 'Individual line item within a bordereaux submission representing one cession or claim entry. Stores policy reference, ceded premium, ceded loss, ceded LAE, and line-level status for granular bordereaux reconciliation.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` (
    `ceded_premium_transaction_id` BIGINT COMMENT 'Unique surrogate identifier for each ceded premium transaction record in the reinsurance ledger.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code in which the ceded premium amounts are denominated (e.g., USD, GBP, EUR).',
    `fac_certificate_id` BIGINT COMMENT 'Reference to the facultative reinsurance certificate when the cession is FAC rather than treaty-based. Null for treaty transactions.',
    `lob_code_id` BIGINT COMMENT 'NAIC or internal Line of Business code identifying the insurance product line (e.g., GL, WC, APD, BOP) for the ceded premium transaction.',
    `policy_id` BIGINT COMMENT 'Reference to the underlying insurance policy whose premium is being ceded under this transaction.',
    `reinsurance_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.cession. Business justification: Premium transactions are generated from cessions. Currently only has treaty/fac/policy FKs, missing the cession FK that ties them together.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer party entity receiving the ceded premium under this transaction.',
    `reversed_transaction_ceded_premium_transaction_id` BIGINT COMMENT 'Reference to the original ceded premium transaction that this record reverses. Populated only when reversal_flag is true.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty under which this ceded premium transaction is recorded.',
    `accounting_period_end_date` DATE COMMENT 'End date of the accounting period to which this ceded premium transaction is attributed for statutory and GAAP reporting.',
    `accounting_period_start_date` DATE COMMENT 'Start date of the accounting period (month or quarter) to which this ceded premium transaction is attributed for statutory and GAAP reporting.',
    `adjustment_premium_amount` DECIMAL(18,2) COMMENT 'Premium adjustment amount arising from the difference between deposit premium and the final calculated premium based on actual subject premium volume.',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized/accredited in the cedants domicile state, affecting credit for reinsurance on the statutory balance sheet.',
    `bordereaux_reference` STRING COMMENT 'Reference number of the bordereaux submission in which this ceded premium transaction was reported to the reinsurer for settlement.',
    `cat_event_code` STRING COMMENT 'Industry or internal CAT event code (e.g., PCS event number) associated with this ceded premium transaction when triggered by a catastrophe occurrence.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Commission received from the reinsurer on the ceded premium, representing reimbursement of acquisition and overhead costs. Reduces net ceded premium.',
    `cession_pct` DECIMAL(7,4) COMMENT 'Percentage of the original policy premium ceded to the reinsurer under this transaction, applicable to quota share and surplus treaties.',
    `cession_type` STRING COMMENT 'Indicates whether the cession is under a treaty, a facultative (FAC) certificate, or a facultative-obligatory arrangement.. Valid values are `treaty|facultative|facultative_obligatory`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ceded premium transaction record was first created in the data platform, used for audit trail and data lineage.',
    `dac_ceded_amount` DECIMAL(18,2) COMMENT 'Deferred acquisition cost attributable to the ceded portion of the policy, representing the ceded DAC asset to be amortized over the policy term.',
    `deposit_premium_amount` DECIMAL(18,2) COMMENT 'Provisional deposit premium paid to the reinsurer at inception of the treaty period, subject to adjustment when actual subject premium is known.',
    `earned_premium_ceded_amount` DECIMAL(18,2) COMMENT 'Portion of the ceded written premium that has been earned during the accounting period, computed on a pro-rata or other basis per treaty terms.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this ceded premium transaction is posted in the financial ledger (Oracle Financials GL or SAP FI).',
    `gwp_ceded_amount` DECIMAL(18,2) COMMENT 'Gross written premium ceded to the reinsurer under this transaction before deduction of ceding commission. Represents the cedants gross exposure transferred.',
    `layer_number` BIGINT COMMENT 'Numeric identifier of the XOL or CAT XL program layer to which this ceded premium transaction belongs, enabling multi-layer program analysis.',
    `nwp_ceded_amount` DECIMAL(18,2) COMMENT 'Net written premium ceded after deducting ceding commission from GWP ceded. Represents the net cost of reinsurance protection for this transaction.',
    `policy_effective_date` DATE COMMENT 'Effective date of the underlying policy term to which this ceded premium transaction relates, used for earned premium proration.',
    `policy_expiry_date` DATE COMMENT 'Expiry date of the underlying policy term, used together with effective date to compute the pro-rata earned ceded premium.',
    `profit_commission_amount` DECIMAL(18,2) COMMENT 'Profit commission receivable from the reinsurer for this accounting period, calculated when the treaty loss ratio falls below the profit commission threshold.',
    `reinstatement_premium_amount` DECIMAL(18,2) COMMENT 'Additional premium payable to reinstate the reinsurance limit after a loss occurrence, applicable to XOL and CAT XL treaties. Zero for QS transactions.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this transaction is a reversal of a previously posted ceded premium entry, used for correction and audit trail purposes.',
    `rol_pct` DECIMAL(7,4) COMMENT 'Rate on Line expressed as a percentage of the reinsurance limit, used for XOL and CAT XL layers to derive the ceded premium from the limit purchased.',
    `settlement_date` DATE COMMENT 'Actual date on which the ceded premium was remitted to or received from the reinsurer. Null if not yet settled.',
    `settlement_due_date` DATE COMMENT 'Contractual due date by which the ceded premium must be remitted to the reinsurer per the treaty or FAC certificate payment terms.',
    `settlement_status` STRING COMMENT 'Current settlement state of the ceded premium transaction with the reinsurer: pending, submitted in bordereaux, agreed, paid, or disputed.. Valid values are `pending|submitted|agreed|paid|disputed`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this ceded premium transaction (e.g., SICS, Sapiens ReinsuranceMaster, Guidewire PolicyCenter).. Valid values are `SICS|ReinsuranceMaster|Guidewire|DuckCreek|Manual`',
    `source_transaction_reference` STRING COMMENT 'The native transaction identifier from the originating source system (e.g., SICS transaction ID), enabling traceability back to the system of record.',
    `subject_premium_amount` DECIMAL(18,2) COMMENT 'The base premium amount on which the reinsurance rate or cession percentage is applied to derive the ceded premium for this transaction.',
    `transaction_date` DATE COMMENT 'The business date on which the ceded premium movement was recorded or triggered, representing the principal real-world event date.',
    `transaction_number` STRING COMMENT 'Externally visible business reference number for this ceded premium transaction, used in bordereaux and reinsurer settlement statements.. Valid values are `^CPT-[0-9]{4}-[0-9]{8}$`',
    `transaction_status` STRING COMMENT 'Current lifecycle state of the ceded premium transaction from draft through settlement or void.. Valid values are `draft|posted|settled|voided|disputed`',
    `transaction_type` STRING COMMENT 'Classifies the nature of the ceded premium movement: written (new/renewal), earned (periodic recognition), return (cancellation/endorsement), adjustment, or reinstatement premium.. Valid values are `written|earned|return|adjustment|reinstatement`',
    `treaty_type` STRING COMMENT 'Type of reinsurance structure governing this cession: Quota Share (QS), Excess of Loss (XOL), Catastrophe Excess of Loss (CAT XL), Surplus, or Stop Loss.. Valid values are `quota_share|excess_of_loss|cat_xl|surplus|stop_loss`',
    `uep_ceded_amount` DECIMAL(18,2) COMMENT 'Portion of the ceded written premium that is unearned as of the accounting period end date, representing the ceded UEP reserve on the balance sheet.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this ceded premium transaction record, supporting audit trail and change tracking requirements.',
    CONSTRAINT pk_ceded_premium_transaction PRIMARY KEY(`ceded_premium_transaction_id`)
) COMMENT 'Transactional record of each ceded premium movement (written, earned, return) under a treaty or FAC certificate. Tracks GWP ceded, NWP ceded, UEP ceded, DAC ceded, accounting period, and settlement status.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` (
    `ceded_loss_transaction_id` BIGINT COMMENT 'Unique identifier for the ceded loss transaction record.',
    `bordereaux_id` BIGINT COMMENT 'Identifier for the bordereaux batch in which this transaction was reported to the reinsurer.',
    `claim_id` BIGINT COMMENT 'Reference to the underlying claim generating this ceded loss.',
    `currency_id` BIGINT COMMENT 'Three-letter ISO currency code for all monetary amounts in this transaction.',
    `fac_certificate_id` BIGINT COMMENT 'Reference to the facultative certificate if this loss is ceded under FAC placement.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Property loss transactions must identify the loss location to determine treaty attachment (per-risk vs. CAT), apply retention, and assign CAT event codes.',
    `lob_code_id` BIGINT COMMENT 'Code identifying the line of business for this ceded loss.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Loss cessions must identify which coverage the claim arose from to apply correct treaty/fac terms, especially in multi-coverage policies.',
    `policy_id` BIGINT COMMENT 'Reference to the policy associated with the ceded loss.',
    `reinsurance_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.cession. Business justification: Loss transactions are generated from cessions. Missing the cession FK that links loss transactions back to the originating cession event.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer receiving this ceded loss transaction.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty under which this loss is ceded.',
    `accounting_date` DATE COMMENT 'Date when the transaction is recognized for financial accounting purposes.',
    `attachment_point` DECIMAL(18,2) COMMENT 'Loss threshold at which reinsurance coverage begins for excess of loss treaties.',
    `bordereaux_submission_date` DATE COMMENT 'Date when the bordereaux containing this transaction was submitted to the reinsurer.',
    `cat_event_code` STRING COMMENT 'Code identifying the catastrophe event if this loss is part of a CAT event.',
    `cat_flag` BOOLEAN COMMENT 'Indicates whether this ceded loss is associated with a catastrophe event.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Amount of allocated loss adjustment expense ceded to the reinsurer.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Amount of loss ceded to the reinsurer under this transaction.',
    `ceded_total_amount` DECIMAL(18,2) COMMENT 'Total amount ceded including loss, ALAE, and ULAE.',
    `ceded_ulae_amount` DECIMAL(18,2) COMMENT 'Amount of unallocated loss adjustment expense ceded to the reinsurer.',
    `cession_percentage` DECIMAL(5,4) COMMENT 'Percentage of the gross loss ceded to the reinsurer under this transaction.',
    `coverage_code` STRING COMMENT 'Code identifying the specific coverage under which the loss is ceded.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ceded loss transaction record was first created in the system.',
    `current_reserve_amount` DECIMAL(18,2) COMMENT 'Current ceded reserve amount after this transaction.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether this ceded loss transaction is under dispute with the reinsurer.',
    `dispute_reason` STRING COMMENT 'Reason for dispute if the transaction is contested by the reinsurer.',
    `dol` DATE COMMENT 'Date when the underlying loss event occurred.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'Loss threshold at which reinsurance coverage ends for excess of loss treaties.',
    `gross_loss_amount` DECIMAL(18,2) COMMENT 'Total gross loss amount before reinsurance cession.',
    `layer_number` BIGINT COMMENT 'Reinsurance layer number if the treaty has multiple layers.',
    `net_loss_amount` DECIMAL(18,2) COMMENT 'Net loss amount retained by the cedant after reinsurance cession.',
    `paid_recoverable_amount` DECIMAL(18,2) COMMENT 'Amount already recovered from the reinsurer for this transaction.',
    `peril_code` STRING COMMENT 'Code identifying the peril or cause of loss.',
    `prior_reserve_amount` DECIMAL(18,2) COMMENT 'Previous ceded reserve amount before this transaction.',
    `recoverable_balance` DECIMAL(18,2) COMMENT 'Outstanding balance recoverable from the reinsurer for this transaction.',
    `reinsurer_confirmation_date` DATE COMMENT 'Date when the reinsurer confirmed receipt and acceptance of this ceded loss transaction.',
    `report_date` DATE COMMENT 'Date when the loss was first reported to the insurer.',
    `reporting_period` STRING COMMENT 'Financial reporting period for this ceded loss transaction, typically YYYY-MM format.',
    `reserve_change_amount` DECIMAL(18,2) COMMENT 'Net change in ceded reserve amount from this transaction.',
    `reserve_movement_type` STRING COMMENT 'Type of reserve movement: initial establishment, increase, decrease, closure, or reopening.. Valid values are `initial|increase|decrease|closure|reopening`',
    `retention_amount` DECIMAL(18,2) COMMENT 'Cedant retention amount applied before reinsurance recovery.',
    `transaction_date` DATE COMMENT 'Date when the ceded loss transaction was recorded in the system.',
    `transaction_number` STRING COMMENT 'Business identifier for the ceded loss transaction, used in bordereaux reporting.',
    `transaction_status` STRING COMMENT 'Current status of the ceded loss transaction in the reinsurance workflow.. Valid values are `pending|reported|confirmed|disputed|settled|reversed`',
    `transaction_type` STRING COMMENT 'Type of ceded loss transaction: paid loss, case reserve, IBNR, IBNER, LAE paid, LAE reserve, salvage, or subrogation. [ENUM-REF-CANDIDATE: paid_loss|case_reserve|ibnr|ibner|lae_paid|lae_reserve|salvage|subrogation — 8 candidates stripped; promote to',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this ceded loss transaction record was last updated.',
    CONSTRAINT pk_ceded_loss_transaction PRIMARY KEY(`ceded_loss_transaction_id`)
) COMMENT 'Ledger of each ceded loss, LAE, and reserve movement (paid, case/OCR, IBNR, IBNER) reported to a reinsurer under a treaty or FAC. Single owner of ceded reserve balances after ri_loss_reserve merge.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` (
    `ri_recoverable_id` BIGINT COMMENT 'Unique identifier for the reinsurance recoverable record.',
    `bordereaux_id` BIGINT COMMENT 'Foreign key linking to reinsurance.bordereaux. Business justification: Recoverables are reported via bordereaux. Currently has bordereaux_reference (string), should have proper FK for referential integrity.',
    `claim_id` BIGINT COMMENT 'Reference to the underlying claim for which reinsurance recovery is being tracked.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this recoverable record.',
    `fac_certificate_id` BIGINT COMMENT 'Reference to the facultative certificate under which this recoverable is ceded, if applicable.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Reinsurance recoverables for property losses track the specific loss location to validate treaty coverage, determine attachment, and support recovery billing.',
    `lob_code_id` BIGINT COMMENT 'Line of business code for the underlying policy and loss exposure.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Recoverables are tracked at coverage level for reserve adequacy testing and credit risk management.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which the loss occurred and reinsurance applies.',
    `reinsurance_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.cession. Business justification: Recoverables arise from cessions. Missing the cession FK that links recoverable balances back to the originating cession.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer party from whom recovery is expected.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the treaty agreement under which this recoverable is ceded, if applicable.',
    `accounting_period` STRING COMMENT 'Accounting period in YYYY-MM format during which this recoverable was recognized for financial reporting.. Valid values are `^[0-9]{4}-[0-9]{2}$`',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized or accredited in the cedants domiciliary state, affecting statutory credit eligibility.',
    `billed_date` DATE COMMENT 'Date on which the recoverable was formally billed to the reinsurer via bordereaux or claim notice.',
    `cat_event_code` STRING COMMENT 'Industry standard catastrophe event code if this recoverable is associated with a named catastrophe.',
    `cat_event_flag` BOOLEAN COMMENT 'Indicates whether this recoverable arises from a catastrophe event loss, subject to special treaty terms.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Portion of Allocated Loss Adjustment Expense ceded to reinsurers, recoverable under the reinsurance agreement.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Portion of the gross loss amount ceded to reinsurers under treaty or facultative agreements.',
    `cession_date` DATE COMMENT 'Date on which the loss was ceded to reinsurers and the recoverable was established.',
    `collateral_held_amount` DECIMAL(18,2) COMMENT 'Amount of collateral held by the cedant to secure this recoverable, reducing credit risk exposure.',
    `collected_amount` DECIMAL(18,2) COMMENT 'Total amount collected from the reinsurer to date against this recoverable.',
    `collected_date` DATE COMMENT 'Date on which payment was received from the reinsurer, fully or partially settling the recoverable.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this recoverable record was first created in the system.',
    `credit_allowed_flag` BOOLEAN COMMENT 'Indicates whether statutory credit is allowed for this recoverable under state insurance regulations.',
    `dispute_date` DATE COMMENT 'Date on which the reinsurer formally disputed the recoverable, triggering dispute resolution procedures.',
    `disputed_amount` DECIMAL(18,2) COMMENT 'Portion of the recoverable balance currently under dispute with the reinsurer.',
    `due_date` DATE COMMENT 'Date by which payment is due from the reinsurer per the reinsurance agreement payment terms.',
    `gross_loss_amount` DECIMAL(18,2) COMMENT 'Total gross loss amount incurred by the cedant before any reinsurance recovery.',
    `loss_date` DATE COMMENT 'Date on which the underlying loss event occurred, determining treaty year and coverage applicability.',
    `loss_type` STRING COMMENT 'Type of loss component for which reinsurance recovery is being tracked.. Valid values are `indemnity|alae|ulae|salvage|subrogation`',
    `notes` STRING COMMENT 'Free-text notes capturing additional context, dispute details, or collection status updates for this recoverable.',
    `overdue_flag` BOOLEAN COMMENT 'Indicates whether the recoverable balance is overdue per the reinsurance agreement payment terms.',
    `recoverable_balance` DECIMAL(18,2) COMMENT 'Outstanding reinsurance recoverable balance owed by the reinsurer, net of any collections or adjustments.',
    `recoverable_number` STRING COMMENT 'Business identifier for the recoverable record, used for external reporting and bordereaux submission.',
    `recoverable_status` STRING COMMENT 'Current lifecycle status of the recoverable balance in the collection workflow.. Valid values are `pending|billed|acknowledged|disputed|collected|written_off`',
    `recoverable_type` STRING COMMENT 'Classification of the reinsurance arrangement type under which recovery is claimed.. Valid values are `treaty|facultative|pool|retrocession`',
    `reported_date` DATE COMMENT 'Date on which the loss was first reported to the cedant, used for IBNR and reserving calculations.',
    `reserve_category` STRING COMMENT 'Category of reserve or payment for which the recoverable is established: case reserve, Incurred But Not Reported (IBNR), Incurred But Not Enough Reported (IBNER), or paid loss.. Valid values are `case|ibnr|ibner|paid`',
    `treaty_year` BIGINT COMMENT 'Calendar or underwriting year of the reinsurance treaty under which this recoverable is ceded.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this recoverable record was last modified, tracking the most recent change to balance or status.',
    `written_off_amount` DECIMAL(18,2) COMMENT 'Portion of the recoverable balance written off as uncollectible due to reinsurer insolvency or dispute resolution.',
    `written_off_date` DATE COMMENT 'Date on which the recoverable balance was written off as uncollectible.',
    CONSTRAINT pk_ri_recoverable PRIMARY KEY(`ri_recoverable_id`)
) COMMENT 'Tracks outstanding reinsurance recoverable balances and ceded loss reserves (OCR, IBNR, IBNER) owed by reinsurers for paid and reserved losses under treaty and FAC agreements.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` (
    `ri_settlement_id` BIGINT COMMENT 'Unique identifier for the reinsurance settlement record.',
    `bordereaux_id` BIGINT COMMENT 'Foreign key linking to reinsurance.bordereaux. Business justification: Settlements are based on bordereaux submissions. Currently has bordereaux_reference (string), should have proper FK for referential integrity.',
    `currency_id` BIGINT COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this settlement.',
    `fac_certificate_id` BIGINT COMMENT 'Reference to the facultative certificate if this settlement is for facultative reinsurance; null for treaty settlements.',
    `lob_code_id` BIGINT COMMENT 'Line of business code for the risks covered by this settlement, aligned with NAIC annual statement lines.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer party with whom this settlement is conducted.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty under which this settlement is processed.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Net adjustment amount for corrections, prior period adjustments, or reconciliation items.',
    `approval_date` DATE COMMENT 'Date the settlement was approved by the cedant or reinsurer for payment processing.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual who approved the settlement for payment.',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized or admitted in the cedants domiciliary jurisdiction for statutory credit purposes.',
    `balance_direction` STRING COMMENT 'Indicates whether the net balance is due from the reinsurer, due to the reinsurer, or zero.. Valid values are `due_from_reinsurer|due_to_reinsurer|zero`',
    `broker_commission_amount` DECIMAL(18,2) COMMENT 'Commission paid to the reinsurance broker for placement and servicing of the treaty or certificate.',
    `broker_name` STRING COMMENT 'Name of the reinsurance broker or intermediary facilitating the settlement, if applicable.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Allocated loss adjustment expenses ceded to the reinsurer for the settlement period.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Total losses ceded to the reinsurer for the settlement period, including paid and reserved amounts.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Total premium ceded to the reinsurer for the settlement period.',
    `ceded_ulae_amount` DECIMAL(18,2) COMMENT 'Unallocated loss adjustment expenses ceded to the reinsurer for the settlement period.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Commission paid by the reinsurer to the cedant for acquisition and administrative costs.',
    `collateral_held_amount` DECIMAL(18,2) COMMENT 'Amount of collateral held by the cedant from the reinsurer to secure the recoverable balance.',
    `collateral_type` STRING COMMENT 'Type of collateral securing the reinsurance recoverable: letter of credit, trust account, funds withheld, or none.. Valid values are `letter_of_credit|trust_account|funds_withheld|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the settlement record was first created in the system.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether this settlement is under dispute between the cedant and reinsurer.',
    `dispute_reason` STRING COMMENT 'Description of the reason for dispute if the settlement is contested.',
    `due_date` DATE COMMENT 'Date by which the net settlement balance is due for payment.',
    `net_balance_amount` DECIMAL(18,2) COMMENT 'Net settlement balance due to or from the reinsurer after all debits and credits; positive indicates amount due from reinsurer.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the settlement, including special instructions or clarifications.',
    `payment_date` DATE COMMENT 'Actual date the settlement payment was made or received.',
    `payment_method` STRING COMMENT 'Method by which the settlement payment was or will be made: wire transfer, check, ACH, offset, or letter of credit.. Valid values are `wire_transfer|check|ach|offset|letter_of_credit`',
    `payment_reference_number` STRING COMMENT 'External reference number for the payment transaction, such as wire confirmation or check number.',
    `period_end_date` DATE COMMENT 'End date of the accounting period covered by this settlement.',
    `period_start_date` DATE COMMENT 'Start date of the accounting period covered by this settlement.',
    `profit_commission_amount` DECIMAL(18,2) COMMENT 'Additional commission paid to the cedant based on favorable loss experience under the treaty.',
    `recoverable_amount` DECIMAL(18,2) COMMENT 'Total amount recoverable from the reinsurer, including losses and expenses.',
    `reinstatement_premium_amount` DECIMAL(18,2) COMMENT 'Additional premium due for reinstatement of coverage limits after a loss event under excess of loss treaties.',
    `settlement_number` STRING COMMENT 'Business identifier for the settlement statement, typically assigned by the cedant or reinsurer.',
    `settlement_status` STRING COMMENT 'Current lifecycle status of the settlement: draft, pending, approved, paid, disputed, or cancelled.. Valid values are `draft|pending|approved|paid|disputed|cancelled`',
    `statement_date` DATE COMMENT 'Date the settlement statement was issued or prepared.',
    `statement_type` STRING COMMENT 'Type of settlement statement: account current, cash call, interim, final, or adjustment.. Valid values are `account_current|cash_call|interim|final|adjustment`',
    `treaty_year` BIGINT COMMENT 'Calendar or underwriting year of the treaty to which this settlement applies.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the settlement record was last modified in the system.',
    CONSTRAINT pk_ri_settlement PRIMARY KEY(`ri_settlement_id`)
) COMMENT 'Records each account-current statement and cash settlement of net balances between Pc_Insurance and a reinsurer for a treaty period.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` (
    `claim_ri_recovery_id` BIGINT COMMENT 'Unique identifier for the claim reinsurance recovery junction record.',
    `bordereaux_id` BIGINT COMMENT 'Foreign key reference to the bordereaux submission in which this recovery was reported to the reinsurer.',
    `claim_id` BIGINT COMMENT 'Foreign key reference to the claim for which reinsurance recovery is being recorded.',
    `currency_id` BIGINT COMMENT 'Three-letter ISO 4217 currency code in which recovery amounts are denominated.',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key reference to the facultative certificate under which recovery is claimed. Null if recovery is under treaty.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Claim recovery calculations for property losses require location data to determine which treaties respond, apply retention and limits, and calculate cession percentages.',
    `lob_code_id` BIGINT COMMENT 'Line of business code for the underlying claim, used for treaty layer matching and bordereaux reporting.',
    `coverage_policy_coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_policy_coverage. Business justification: Recovery calculations depend on coverage-specific limits, deductibles, SIR amounts, and coinsurance percentages. Claims adjusters need coverage terms to determine gross vs.',
    `reinsurance_cession_id` BIGINT COMMENT 'Foreign key linking to reinsurance.cession. Business justification: Recoveries are based on cessions. Missing the cession FK that links claim recoveries back to the cession that generated the recovery right.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key reference to the reinsurer from whom recovery is being claimed.',
    `ri_treaty_id` BIGINT COMMENT 'Foreign key reference to the reinsurance treaty under which recovery is claimed. Null if recovery is under facultative certificate.',
    `accounting_period` STRING COMMENT 'Accounting period in which this recovery is recognized for statutory and GAAP reporting, format YYYY-MM.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `acknowledgement_date` DATE COMMENT 'Date on which reinsurer acknowledged receipt and validity of the recovery claim.',
    `approval_date` DATE COMMENT 'Date on which reinsurer approved the recovery claim for payment.',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether reinsurer is authorized or accredited in the cedants domiciliary state, affecting credit for reinsurance treatment.',
    `cat_event_code` STRING COMMENT 'Industry catastrophe event code if this recovery relates to a declared catastrophe event.',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether this recovery is related to a catastrophe event, triggering CAT XL treaty layers.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Amount of allocated loss adjustment expense ceded to reinsurer under this recovery.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Amount of loss ceded to reinsurer under this recovery, net of retention and subject to treaty limits.',
    `cession_percentage` DECIMAL(5,2) COMMENT 'Percentage of loss ceded to reinsurer under quota share or surplus arrangements.',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Amount of collateral posted by reinsurer to secure this recovery, if applicable.',
    `collateral_required_flag` BOOLEAN COMMENT 'Indicates whether collateral is required from reinsurer to receive statutory credit for this recovery.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this claim reinsurance recovery record was first created in the system.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether this recovery is currently under dispute with the reinsurer.',
    `dispute_reason` STRING COMMENT 'Description of the reason for dispute if recovery is contested by reinsurer.',
    `dispute_resolution_date` DATE COMMENT 'Date on which dispute was resolved, either through negotiation, arbitration, or litigation.',
    `gross_alae_amount` DECIMAL(18,2) COMMENT 'Total allocated loss adjustment expense on the underlying claim before reinsurance recovery.',
    `gross_loss_amount` DECIMAL(18,2) COMMENT 'Total gross loss amount on the underlying claim before reinsurance recovery, used as basis for cession calculation.',
    `layer_attachment_point` DECIMAL(18,2) COMMENT 'Attachment point for excess of loss layer, loss must exceed this amount before reinsurer participates.',
    `layer_limit_amount` DECIMAL(18,2) COMMENT 'Maximum limit of the reinsurance layer applicable to this recovery.',
    `outstanding_recoverable_amount` DECIMAL(18,2) COMMENT 'Amount still outstanding from reinsurer, calculated as recoverable minus recovered.',
    `payment_date` DATE COMMENT 'Date on which reinsurer paid the recovery amount to the cedant.',
    `payment_reference_number` STRING COMMENT 'Reference number of the reinsurer payment transaction that settled this recovery, linking to cash receipt.',
    `recoverable_amount` DECIMAL(18,2) COMMENT 'Total amount recoverable from reinsurer, sum of ceded loss and ceded ALAE, subject to treaty terms and reinsurer credit quality.',
    `recovered_amount` DECIMAL(18,2) COMMENT 'Actual amount recovered from reinsurer to date, may differ from recoverable due to disputes or partial payments.',
    `recovery_basis` STRING COMMENT 'Basis on which recovery amount is calculated, defining whether loss adjustment expenses are included.. Valid values are `loss_only|loss_and_alae|loss_and_ulae|pro_rata`',
    `recovery_number` STRING COMMENT 'Business identifier for this specific recovery transaction, often used in bordereaux and settlement reporting.',
    `recovery_status` STRING COMMENT 'Current lifecycle status of the reinsurance recovery claim. [ENUM-REF-CANDIDATE: pending|submitted|acknowledged|approved|paid|disputed|denied|reversed — 8 candidates stripped; promote to reference product]',
    `recovery_type` STRING COMMENT 'Type of reinsurance arrangement under which recovery is being claimed.. Valid values are `treaty|facultative|cat_xl|xol|quota_share|surplus`',
    `reinstatement_number` BIGINT COMMENT 'Reinstatement number if this recovery exhausted the original treaty limit and triggered a reinstatement provision.',
    `reinstatement_premium_amount` DECIMAL(18,2) COMMENT 'Additional premium owed to reinsurer for reinstating treaty limit after this recovery.',
    `reinsurer_share_pct` DECIMAL(5,2) COMMENT 'Percentage share of this specific reinsurer in a co-reinsured treaty or facultative placement.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Cedant retention amount applied before calculating ceded loss, may be per-occurrence or aggregate depending on treaty terms.',
    `submission_date` DATE COMMENT 'Date on which this recovery claim was submitted to the reinsurer for acknowledgement and payment.',
    `treaty_year` BIGINT COMMENT 'Treaty year under which this recovery is claimed, relevant for multi-year treaties and reinstatement tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this claim reinsurance recovery record was last modified.',
    CONSTRAINT pk_claim_ri_recovery PRIMARY KEY(`claim_ri_recovery_id`)
) COMMENT 'Junction table resolving the many-to-many relationship between claims and reinsurance recoveries. Links a specific claim to one or more treaty/FAC recoveries, capturing recovered amount, recovery basis, and payment reference per claim-recovery pairing.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` (
    `cat_bond_id` BIGINT COMMENT 'Unique identifier for the catastrophe bond instrument record.',
    `currency_id` BIGINT COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in the catastrophe bond.',
    `lob_code_id` BIGINT COMMENT 'Insurance line of business code indicating the type of risk covered, such as property, casualty, multi-peril.',
    `org_unit_id` BIGINT COMMENT 'Identifier of the ceding insurer or reinsurer transferring risk through the catastrophe bond.',
    `ri_treaty_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_treaty. Business justification: CAT bonds are often structured alongside or as part of CAT XL treaty programs. This links the bond to its associated treaty structure, enabling integrated CAT risk management analysis.',
    `aggregate_limit_flag` BOOLEAN COMMENT 'Indicates whether the catastrophe bond has an aggregate loss limit across multiple events.',
    `attachment_point` DECIMAL(18,2) COMMENT 'Loss threshold amount at which the catastrophe bond begins to provide coverage and principal may be at risk.',
    `basis_risk_description` STRING COMMENT 'Description of potential basis risk where the trigger mechanism may not perfectly correlate with actual losses incurred by the sponsor.',
    `bond_name` STRING COMMENT 'Marketing or legal name of the catastrophe bond issuance.',
    `bond_number` STRING COMMENT 'Externally-known unique identifier or CUSIP for the catastrophe bond instrument.',
    `bond_rating` STRING COMMENT 'Credit rating assigned to the catastrophe bond by the rating agency.',
    `bond_status` STRING COMMENT 'Current lifecycle status of the catastrophe bond instrument.. Valid values are `active|matured|triggered|cancelled|suspended|pending`',
    `cat_event_definition` STRING COMMENT 'Detailed definition of what constitutes a triggering catastrophe event including magnitude, location, and measurement criteria.',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Total value of collateral held in trust to secure the catastrophe bond.',
    `collateral_type` STRING COMMENT 'Type of collateral held in trust to secure the catastrophe bond obligations.. Valid values are `cash|treasury|money_market|investment_grade|mixed`',
    `coupon_frequency` STRING COMMENT 'Frequency at which coupon interest payments are made to catastrophe bond investors.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `coupon_rate_pct` DECIMAL(5,4) COMMENT 'Annual interest rate paid to catastrophe bond investors, expressed as a decimal percentage.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe bond record was first created in the system.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'Loss amount at which the catastrophe bond coverage is fully exhausted and maximum principal loss occurs.',
    `expected_loss_pct` DECIMAL(5,4) COMMENT 'Modeled expected annual loss as a percentage of the notional amount, representing the probability-weighted average loss.',
    `issuance_date` DATE COMMENT 'Date when the catastrophe bond was issued and became effective.',
    `maturity_date` DATE COMMENT 'Date when the catastrophe bond principal is scheduled to be repaid if no trigger event occurs.',
    `modeling_firm` STRING COMMENT 'Name of the catastrophe risk modeling firm used to assess and price the bond, such as RMS, AIR Worldwide, CoreLogic.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe bond record was last modified in the system.',
    `multi_event_flag` BOOLEAN COMMENT 'Indicates whether the catastrophe bond can be triggered by multiple separate catastrophe events during its term.',
    `notional_amount` DECIMAL(18,2) COMMENT 'Original principal amount of the catastrophe bond at issuance.',
    `outstanding_notional` DECIMAL(18,2) COMMENT 'Current outstanding principal amount of the catastrophe bond after any trigger events or partial redemptions.',
    `perils_covered` STRING COMMENT 'Comma-separated list of catastrophic perils covered by the bond such as hurricane, earthquake, windstorm, flood, wildfire.',
    `placement_broker` STRING COMMENT 'Name of the broker or investment bank that placed the catastrophe bond with investors.',
    `pml_amount` DECIMAL(18,2) COMMENT 'Estimated probable maximum loss exposure that the catastrophe bond is designed to cover.',
    `principal_reduction_amount` DECIMAL(18,2) COMMENT 'Amount of principal reduced or forgiven due to a trigger event occurring.',
    `rating_agency` STRING COMMENT 'Name of the credit rating agency that rated the catastrophe bond, such as A.M. Best, S&P, Moodys, Fitch.',
    `reinstatement_provision_flag` BOOLEAN COMMENT 'Indicates whether the catastrophe bond includes provisions for reinstatement of coverage after a trigger event.',
    `sponsor_name` STRING COMMENT 'Name of the insurance or reinsurance company sponsoring the catastrophe bond issuance.',
    `spv_domicile` STRING COMMENT 'Three-letter country code of the jurisdiction where the special purpose vehicle is domiciled.. Valid values are `^[A-Z]{3}$`',
    `spv_name` STRING COMMENT 'Legal name of the special purpose vehicle entity that issued the catastrophe bond.',
    `spv_registration_number` STRING COMMENT 'Official registration or incorporation number of the special purpose vehicle with its domicile authority.',
    `territory_scope` STRING COMMENT 'Geographic regions or territories covered by the catastrophe bond, such as US Gulf Coast, Japan, Europe.',
    `trigger_event_code` STRING COMMENT 'Industry-standard code identifying the specific catastrophe event that triggered the bond.',
    `trigger_event_date` DATE COMMENT 'Date when a catastrophe event occurred that met the trigger criteria for the bond.',
    `trigger_type` STRING COMMENT 'Mechanism that determines when the catastrophe bond is activated: indemnity-based, parametric, index-based, modeled loss, hybrid, or industry loss index.. Valid values are `indemnity|parametric|index|modeled_loss|hybrid|industry_loss`',
    `trustee_name` STRING COMMENT 'Name of the trustee institution responsible for holding collateral and administering the catastrophe bond.',
    CONSTRAINT pk_cat_bond PRIMARY KEY(`cat_bond_id`)
) COMMENT 'Master record for each catastrophe bond (CAT Bond) instrument issued or held by Pc_Insurance. Tracks trigger type (indemnity, parametric, index), attachment, exhaustion, coupon, maturity date, SPV details, and outstanding notional.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` (
    `profit_commission_id` BIGINT COMMENT 'Unique identifier for the profit commission record.',
    `currency_id` BIGINT COMMENT 'ISO 4217 three-letter currency code in which profit commission amounts are denominated.',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_certificate. Business justification: Profit commissions can be calculated on FAC certificates with profit-sharing provisions, not just QS treaties. Missing FK that enables FAC profit commission tracking.',
    `lob_code_id` BIGINT COMMENT 'Line of business code for which this profit commission is calculated, aligning with treaty coverage scope.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key to the reinsurer party to whom profit commission is owed or from whom it is received.',
    `ri_treaty_id` BIGINT COMMENT 'Foreign key to the reinsurance treaty under which this profit commission is calculated.',
    `accounting_period` STRING COMMENT 'The accounting period identifier for which this profit commission is calculated, typically YYYY-MM or YYYY-QQ format.',
    `accrued_commission_amount` DECIMAL(18,2) COMMENT 'Accrued profit commission amount recognized in the financial statements for the period, may differ from calculated amount due to timing.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Net adjustment amount applied to the profit commission calculation, positive for increases and negative for decreases.',
    `adjustment_reason` STRING COMMENT 'Reason for any adjustment to the profit commission calculation, such as bordereaux correction, audit finding, or treaty amendment.',
    `amount` DECIMAL(18,2) COMMENT 'Total profit commission amount calculated for the treaty and period, computed by applying the commission rate to the net ceded premium.',
    `approval_date` DATE COMMENT 'The date on which the profit commission calculation was approved by authorized personnel.',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized or admitted in the cedants domiciliary jurisdiction, affecting statutory credit treatment.',
    `calculated_commission_rate_pct` DECIMAL(5,2) COMMENT 'Calculated profit commission rate percentage based on the treaty formula and actual loss ratio for the period.',
    `calculated_loss_ratio_pct` DECIMAL(5,2) COMMENT 'Calculated loss ratio percentage for the treaty and period, computed as total ceded loss and LAE divided by net ceded premium.',
    `calculation_date` DATE COMMENT 'The date on which the profit commission calculation was performed.',
    `calculation_method` STRING COMMENT 'Method used to determine the experience period for profit commission calculation, such as treaty year, accident year, or calendar year basis.. Valid values are `treaty_year|accident_year|underwriting_year|calendar_year`',
    `calculation_notes` STRING COMMENT 'Free-text notes documenting assumptions, adjustments, or special considerations applied in the profit commission calculation.',
    `calculation_number` STRING COMMENT 'Business identifier for the profit commission calculation, typically assigned by the reinsurance system.',
    `calculation_status` STRING COMMENT 'Current lifecycle status of the profit commission calculation. [ENUM-REF-CANDIDATE: draft|calculated|approved|accrued|paid|disputed|cancelled — 7 candidates stripped; promote to reference product]',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Total ceded allocated loss adjustment expense for the treaty and period.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Total ceded loss amount including paid and reserved losses for the treaty and period.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Total ceded premium amount for the treaty and period used as the basis for profit commission calculation.',
    `ceded_ulae_amount` DECIMAL(18,2) COMMENT 'Total ceded unallocated loss adjustment expense for the treaty and period.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Total ceding commission received from the reinsurer for the treaty and period, deducted from ceded premium.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this profit commission record was first created in the system.',
    `effective_date` DATE COMMENT 'The date from which the profit commission calculation is effective, typically aligned with treaty or accounting period start.',
    `expiry_date` DATE COMMENT 'The date through which the profit commission calculation applies, typically aligned with treaty or accounting period end.',
    `formula` STRING COMMENT 'Type of profit commission formula specified in the treaty: fixed rate, sliding scale, step function, or custom calculation.. Valid values are `fixed_rate|sliding_scale|step_function|custom`',
    `loss_ratio_threshold_pct` DECIMAL(5,2) COMMENT 'Loss ratio threshold percentage specified in the treaty profit commission clause, below which profit commission is earned.',
    `net_ceded_premium` DECIMAL(18,2) COMMENT 'Net ceded premium after deducting ceding commission, used as the denominator in loss ratio calculation.',
    `outstanding_balance` DECIMAL(18,2) COMMENT 'Outstanding profit commission balance remaining to be paid, calculated as accrued amount minus paid amount.',
    `paid_commission_amount` DECIMAL(18,2) COMMENT 'Total profit commission amount paid to date for this calculation, tracking settlement progress.',
    `payment_due_date` DATE COMMENT 'The date by which the profit commission payment is due per treaty terms.',
    `prior_calculation_amount` DECIMAL(18,2) COMMENT 'Profit commission amount from the prior calculation for the same treaty and period, used to track adjustments and movements.',
    `provisional_flag` BOOLEAN COMMENT 'Indicates whether this profit commission calculation is provisional and subject to adjustment upon final bordereaux or audit.',
    `sliding_scale_max_pct` DECIMAL(5,2) COMMENT 'Maximum profit commission percentage in a sliding scale formula, applicable when loss ratio is at or below the lower threshold.',
    `sliding_scale_min_pct` DECIMAL(5,2) COMMENT 'Minimum profit commission percentage in a sliding scale formula, applicable when loss ratio is at or above the upper threshold.',
    `total_ceded_loss_lae` DECIMAL(18,2) COMMENT 'Sum of ceded loss, ALAE, and ULAE amounts, used as the numerator in loss ratio calculation.',
    `treaty_type` STRING COMMENT 'Type of reinsurance treaty under which profit commission is calculated, typically quota share treaties with profit commission clauses.. Valid values are `quota_share|surplus|excess_of_loss|stop_loss|aggregate_xol`',
    `treaty_year` BIGINT COMMENT 'The treaty year or underwriting year for which this profit commission is calculated.',
    `updated_by` STRING COMMENT 'User identifier of the person or system that last updated this profit commission record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this profit commission record was last updated in the system.',
    `created_by` STRING COMMENT 'User identifier of the person or system that created this profit commission record.',
    CONSTRAINT pk_profit_commission PRIMARY KEY(`profit_commission_id`)
) COMMENT 'Tracks profit commission calculations and accruals owed to Pc_Insurance under QS treaties with profit commission clauses. Stores loss ratio threshold, sliding scale parameters, calculated commission rate, and accrued commission amount.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` (
    `reinstatement_id` BIGINT COMMENT 'Unique identifier for the reinstatement data product (auto-inserted during validation).',
    `bordereaux_id` BIGINT COMMENT 'Foreign key reference to the bordereaux submission batch in which this reinstatement transaction was reported to the reinsurer.',
    `currency_id` BIGINT COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this reinstatement record.',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_certificate. Business justification: Reinstatements can occur on FAC certificates with reinstatement provisions, not just treaties. Currently only has ri_treaty_id. Missing FK for FAC reinstatements.',
    `lob_code_id` BIGINT COMMENT 'Insurance line of business code covered by the reinstated treaty layer, such as property, casualty, or specialty lines.',
    `occurrence_loss_id` BIGINT COMMENT 'Foreign key linking to reinsurance.occurrence_loss. Business justification: Reinstatements are triggered by specific occurrence losses. Currently has occurrence_reference (string), should have proper FK to occurrence_loss for referential integrity and',
    `ri_treaty_id` BIGINT COMMENT 'Foreign key reference to the reinsurance treaty under which this reinstatement applies.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty_layer. Business justification: Reinstatements restore specific treaty layers. Currently has layer_number (INT), should have proper FK to treaty_layer for full layer definition.',
    `accounting_period` STRING COMMENT 'The accounting period in YYYY-MM format to which this reinstatement transaction is assigned for financial reporting purposes.. Valid values are `^d{4}-(0[1-9]|1[0-2])$`',
    `attachment_point` DECIMAL(18,2) COMMENT 'The retention or attachment point amount for the treaty layer being reinstated, defining where reinsurer coverage begins.',
    `automatic_reinstatement_flag` BOOLEAN COMMENT 'Indicates whether the treaty limit is automatically reinstated upon payment of premium, without requiring reinsurer approval.',
    `basis` STRING COMMENT 'The contractual basis on which the reinstatement is triggered and calculated, such as per-occurrence or aggregate loss basis.. Valid values are `occurrence|aggregate|loss_ratio|sliding_scale`',
    `broker_name` STRING COMMENT 'Name of the reinsurance broker or intermediary facilitating the reinstatement transaction and premium settlement.',
    `calculation_date` DATE COMMENT 'Date on which the reinstatement premium and terms were calculated based on treaty provisions and loss experience.',
    `cat_event_code` STRING COMMENT 'Industry standard code identifying the catastrophe event that exhausted treaty capacity, such as PCS or ISO CAT codes.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this reinstatement record was first created in the reinsurance management system.',
    `effective_date` DATE COMMENT 'Date on which the reinstated treaty limit becomes effective and available for subsequent losses.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'The upper limit or exhaustion point of the treaty layer being reinstated, defining where reinsurer coverage ends.',
    `free_reinstatement_flag` BOOLEAN COMMENT 'Indicates whether this reinstatement is provided at no additional premium cost per treaty terms, typically for first reinstatement.',
    `invoice_date` DATE COMMENT 'Date on which the reinstatement premium invoice was issued to the cedant by the reinsurer.',
    `lead_reinsurer_name` STRING COMMENT 'Name of the lead reinsurer responsible for coordinating the reinstatement process and premium collection across the syndicate.',
    `loss_amount_triggering` DECIMAL(18,2) COMMENT 'Total ceded loss amount from the occurrence that exhausted the treaty layer and triggered the need for reinstatement.',
    `notes` STRING COMMENT 'Free-form text field for additional comments, special conditions, or explanatory notes regarding the reinstatement transaction.',
    `number` BIGINT COMMENT 'Sequential number of the reinstatement within the treaty layer, typically 1, 2, or 3 for multiple reinstatements.',
    `payment_date` DATE COMMENT 'Actual date on which the reinstatement premium was paid by the cedant to the reinsurer.',
    `payment_due_date` DATE COMMENT 'Date by which the reinstatement premium payment is contractually due from the cedant to the reinsurer.',
    `premium_amount` DECIMAL(18,2) COMMENT 'Total premium amount due for reinstating the treaty limit, calculated as a percentage of the original treaty premium.',
    `premium_pct` DECIMAL(5,2) COMMENT 'Percentage rate applied to the original premium to calculate the reinstatement premium, as specified in the treaty terms.',
    `prorata_factor` DECIMAL(8,6) COMMENT 'Pro-rata adjustment factor applied when the reinstatement occurs partway through the treaty period, reducing the premium proportionally.',
    `prorata_premium_amount` DECIMAL(18,2) COMMENT 'Reinstatement premium adjusted for the pro-rata factor based on remaining treaty period at the time of reinstatement.',
    `reinstated_limit_amount` DECIMAL(18,2) COMMENT 'The treaty limit amount being reinstated and made available for subsequent losses after the triggering occurrence.',
    `reinstatement_status` STRING COMMENT 'Current lifecycle status of the reinstatement transaction, tracking from initial calculation through payment settlement.. Valid values are `pending|confirmed|invoiced|paid|disputed|cancelled`',
    `reinsurer_approval_date` DATE COMMENT 'Date on which the reinsurer formally approved the reinstatement of the treaty limit, if approval was required.',
    `reinsurer_approval_required_flag` BOOLEAN COMMENT 'Indicates whether explicit reinsurer approval is required before the treaty limit can be reinstated for subsequent losses.',
    `territory_scope` STRING COMMENT 'Geographic territory or region covered by the reinstated treaty layer, defining the scope of reinstated coverage.',
    `treaty_type` STRING COMMENT 'Type of reinsurance treaty structure under which this reinstatement applies, such as Excess of Loss or Catastrophe Excess of Loss.. Valid values are `XOL|CAT_XL|QS|SURPLUS|STOP_LOSS|AGGREGATE`',
    `treaty_year` BIGINT COMMENT 'The treaty underwriting year or policy year to which this reinstatement applies, important for multi-year treaty accounting.',
    `updated_by` STRING COMMENT 'User identifier or system account that last modified this reinstatement record, supporting accountability and audit requirements.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this reinstatement record was last modified, supporting audit trail and change tracking.',
    `created_by` STRING COMMENT 'User identifier or system account that created this reinstatement record, supporting accountability and audit requirements.',
    CONSTRAINT pk_reinstatement PRIMARY KEY(`reinstatement_id`)
) COMMENT 'Records reinstatement of treaty limit following a loss occurrence under XOL or CAT XL treaties. Captures reinstatement premium, reinstated limit, occurrence reference, reinstatement number, and effective date per treaty layer.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` (
    `ri_broker_id` BIGINT COMMENT 'Unique identifier for the reinsurance broker record.',
    `address_line1` STRING COMMENT 'First line of the brokers primary business address.',
    `address_line2` STRING COMMENT 'Second line of the brokers business address for suite or floor information.',
    `appointment_date` DATE COMMENT 'Date when the broker was formally appointed to represent the cedant in reinsurance placements.',
    `authorized_markets` STRING COMMENT 'Comma-separated list of reinsurance markets where the broker is authorized to place business.',
    `broker_code` STRING COMMENT 'Unique business identifier code assigned to the reinsurance broker for operational reference.. Valid values are `^[A-Z0-9]{3,10}$`',
    `broker_status` STRING COMMENT 'Current operational status of the broker relationship.. Valid values are `active|inactive|suspended|terminated|pending_approval`',
    `broker_type` STRING COMMENT 'Classification of the reinsurance broker by operational focus and market segment.. Valid values are `wholesale|retail|lloyds|specialty|cat_broker|fac_specialist`',
    `brokerage_rate_pct` DECIMAL(5,3) COMMENT 'Standard brokerage commission rate percentage charged by the broker on placed reinsurance premium.',
    `cat_placement_flag` BOOLEAN COMMENT 'Indicates whether the broker is authorized and experienced in placing catastrophe reinsurance.',
    `city` STRING COMMENT 'City name of the brokers primary business location.',
    `compliance_status` STRING COMMENT 'Current compliance status of the broker with regulatory and contractual requirements.. Valid values are `compliant|non_compliant|under_review|remediation`',
    `country_code` STRING COMMENT 'Three-letter ISO country code of the brokers domicile.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the broker record was first created in the system.',
    `credit_rating` STRING COMMENT 'Financial strength or credit rating assigned to the broker by a recognized rating agency.',
    `dba_name` STRING COMMENT 'Trade name or doing business as name used by the broker in the market.',
    `eo_coverage_amount` DECIMAL(18,2) COMMENT 'Limit of errors and omissions insurance coverage carried by the broker.',
    `eo_expiry_date` DATE COMMENT 'Expiration date of the brokers current errors and omissions insurance policy.',
    `fac_placement_flag` BOOLEAN COMMENT 'Indicates whether the broker handles facultative certificate placements.',
    `fein` STRING COMMENT 'Federal tax identification number assigned to the brokerage entity.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `last_audit_date` DATE COMMENT 'Date of the most recent compliance or financial audit conducted on the broker.',
    `legal_name` STRING COMMENT 'Full legal registered name of the reinsurance brokerage firm.',
    `lloyds_authorized_flag` BOOLEAN COMMENT 'Indicates whether the broker is authorized to place business at Lloyds of London.',
    `lloyds_broker_number` STRING COMMENT 'Unique registration number assigned by Lloyds of London for authorized Lloyds brokers.. Valid values are `^[A-Z0-9]{4,8}$`',
    `naic_code` STRING COMMENT 'Five-digit NAIC company code assigned to the broker if registered as a reinsurance intermediary.. Valid values are `^[0-9]{5}$`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review or audit of the broker relationship.',
    `notes` STRING COMMENT 'Free-form text field for additional comments or special instructions related to the broker.',
    `parent_company_name` STRING COMMENT 'Legal name of the parent company if the broker is part of a larger corporate group.',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the brokers primary business address.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact for reinsurance placement communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary contact person at the brokerage for treaty and facultative placements.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for the broker contact.',
    `rating_agency` STRING COMMENT 'Name of the rating agency that assigned the credit rating.',
    `specialty_lob` STRING COMMENT 'Primary lines of business or perils in which the broker specializes for reinsurance placements.',
    `state_province` STRING COMMENT 'State or province code of the brokers primary business location.',
    `termination_date` DATE COMMENT 'Date when the broker appointment was terminated or expired.',
    `treaty_placement_flag` BOOLEAN COMMENT 'Indicates whether the broker handles treaty reinsurance placements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the broker record was last modified.',
    `website_url` STRING COMMENT 'Official website URL of the reinsurance brokerage firm.',
    CONSTRAINT pk_ri_broker PRIMARY KEY(`ri_broker_id`)
) COMMENT 'Master record for each reinsurance intermediary (RI broker) involved in treaty or FAC placement. Captures broker legal name, Lloyds registration, brokerage rate, contact details, and authorized markets for placement management.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` (
    `ri_placement_id` BIGINT COMMENT 'Unique identifier for the reinsurance placement record.',
    `currency_id` BIGINT COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this placement.',
    `fac_certificate_id` BIGINT COMMENT 'Reference to the facultative certificate being placed. Null for treaty placements.',
    `lead_reinsurer_id` BIGINT COMMENT 'Reference to the lead reinsurer who anchors the placement and typically takes the largest share.',
    `lob_code_id` BIGINT COMMENT 'Line of business code for the reinsurance placement, aligned with statutory reporting categories.',
    `placing_agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Agency-level attribution for reinsurance placements, especially for MGA/wholesale operations that place reinsurance on behalf of retail networks.',
    `ri_broker_id` BIGINT COMMENT 'Reference to the reinsurance broker or intermediary managing the placement process.',
    `ri_treaty_id` BIGINT COMMENT 'Reference to the treaty being placed. Null for facultative (FAC) placements.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty_layer. Business justification: Placements are for specific treaty layers. Currently has layer_number (INT), should have proper FK to treaty_layer which contains the full layer definition including layer_number',
    `attachment_point` DECIMAL(18,2) COMMENT 'Loss threshold at which the reinsurance layer attaches and begins to respond. Applicable for excess of loss (XOL) structures.',
    `binding_date` DATE COMMENT 'Date the placement was bound and the reinsurance contract became effective.',
    `broker_name` STRING COMMENT 'Name of the reinsurance broker or intermediary managing the placement.',
    `brokerage_pct` DECIMAL(5,2) COMMENT 'Percentage of premium paid to the reinsurance broker as commission for placement services.',
    `cancellation_date` DATE COMMENT 'Date the placement was cancelled or terminated prior to natural expiry.',
    `cat_event_definition` STRING COMMENT 'Definition or criteria used to determine when a catastrophe event triggers coverage under this placement.',
    `cat_exposed_flag` BOOLEAN COMMENT 'Indicates whether the placement covers catastrophe (CAT) exposures such as hurricanes, earthquakes, or other large-scale events.',
    `ceding_commission_pct` DECIMAL(5,2) COMMENT 'Percentage of ceded premium returned to the cedant as commission to cover acquisition and administrative costs.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the placement record was first created in the system.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'Loss level at which the reinsurance layer is fully exhausted. Calculated as attachment point plus limit.',
    `expiry_date` DATE COMMENT 'Effective end date of the reinsurance coverage under this placement.',
    `fac_type` STRING COMMENT 'Type of facultative reinsurance structure. Applicable for FAC placements; null for treaty.. Valid values are `fac_proportional|fac_xol|fac_cat`',
    `inception_date` DATE COMMENT 'Effective start date of the reinsurance coverage under this placement.',
    `lead_reinsurer_share_pct` DECIMAL(5,2) COMMENT 'Percentage of the total placement capacity taken by the lead reinsurer.',
    `limit_amount` DECIMAL(18,2) COMMENT 'Maximum reinsurance coverage amount provided by this placement layer.',
    `markets_approached_count` BIGINT COMMENT 'Number of reinsurance markets or reinsurers approached during the placement process.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the placement record was last modified or updated.',
    `participating_reinsurers_count` BIGINT COMMENT 'Number of reinsurers who ultimately signed and participated in the bound placement.',
    `perils_covered` STRING COMMENT 'List or description of perils covered under the reinsurance placement, such as wind, earthquake, flood, or all risks.',
    `placed_capacity_amount` DECIMAL(18,2) COMMENT 'Total reinsurance capacity amount successfully placed and bound with reinsurers.',
    `placement_notes` STRING COMMENT 'Free-text notes capturing key details, negotiations, special terms, or other relevant information about the placement.',
    `placement_number` STRING COMMENT 'Business identifier for the placement workflow, typically assigned by the broker or cedant.',
    `placement_stage` STRING COMMENT 'High-level phase of the placement process indicating major workflow milestones.. Valid values are `pre_marketing|marketing|negotiation|binding|post_binding`',
    `placement_status` STRING COMMENT 'Current stage of the placement workflow from initial submission through binding or decline. [ENUM-REF-CANDIDATE: draft|slip_submitted|market_quoted|negotiation|bound|declined|cancelled — 7 candidates stripped; promote to reference product]',
    `placement_type` STRING COMMENT 'Type of reinsurance placement being executed.. Valid values are `treaty|facultative|cat_bond|sideCar`',
    `pml_amount` DECIMAL(18,2) COMMENT 'Estimated probable maximum loss amount used for pricing and capacity determination in the placement.',
    `program_name` STRING COMMENT 'Name of the broader reinsurance program or tower to which this placement belongs.',
    `quote_due_date` DATE COMMENT 'Date by which reinsurers are expected to provide their quotes or indications.',
    `quotes_received_count` BIGINT COMMENT 'Number of formal quotes or indications received from reinsurers during the placement process.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Amount of risk retained by the cedant before reinsurance coverage applies.',
    `rol_pct` DECIMAL(5,2) COMMENT 'Rate on line expressed as a percentage, calculated as premium divided by limit for excess of loss (XOL) placements.',
    `slip_submission_date` DATE COMMENT 'Date the reinsurance slip was submitted to the market for underwriting consideration.',
    `target_capacity_amount` DECIMAL(18,2) COMMENT 'Total reinsurance capacity amount the cedant is seeking to place in the market.',
    `territory_scope` STRING COMMENT 'Geographic scope of the reinsurance coverage, defining which territories or regions are included.',
    `total_signed_line_pct` DECIMAL(5,2) COMMENT 'Aggregate percentage of the placement capacity that has been signed by all participating reinsurers.',
    `treaty_type` STRING COMMENT 'Type of reinsurance treaty structure. Applicable for treaty placements; null for facultative.. Valid values are `quota_share|surplus|xol|cat_xl|aggregate_xol|stop_loss`',
    `underwriter_name` STRING COMMENT 'Name of the cedant underwriter responsible for managing the placement process and reinsurer relationships.',
    CONSTRAINT pk_ri_placement PRIMARY KEY(`ri_placement_id`)
) COMMENT 'Tracks the placement workflow for a treaty or FAC certificate from slip submission through binding. Captures placement stage, market approached, lead reinsurer, signed line percentage, brokerage, and binding date.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` (
    `occurrence_loss_id` BIGINT COMMENT 'Unique identifier for the occurrence loss record. Primary key for occurrence-based loss aggregation used in Excess of Loss (XOL) treaty application.',
    `bordereaux_id` BIGINT COMMENT 'Identifier of the bordereaux submission in which this occurrence loss was reported to reinsurers.',
    `cat_event_id` BIGINT COMMENT 'FK to reservespayments.cat_event.cat_event_id — Designates reservespayments.cat_event the single catastrophe master so XOL/CAT XL occurrence aggregation rolls up to the same catastrophe event as claims and reserves.',
    `currency_id` BIGINT COMMENT 'Three-letter ISO currency code for all monetary amounts in this occurrence loss record.',
    `fac_certificate_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_certificate. Business justification: Occurrence losses can be ceded under FAC certificates, not just treaties. Currently only has ri_treaty_id. This FK enables tracking FAC-based occurrence cessions.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: Catastrophe occurrence losses must identify affected locations for hours clause validation (168-hour rule), PML comparison, and reinstatement trigger determination.',
    `lob_code_id` BIGINT COMMENT 'Code identifying the primary line of business affected by the occurrence, used for treaty layer allocation and cession calculation.',
    `ri_treaty_id` BIGINT COMMENT 'Identifier of the primary reinsurance treaty applied to this occurrence for cession calculation and recovery.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty_layer. Business justification: Occurrence losses apply to specific treaty layers. Currently has treaty_layer_number (INT), should have proper FK to treaty_layer for full layer definition access.',
    `accounting_period` STRING COMMENT 'Accounting period in which this occurrence loss is recognized for statutory and GAAP reporting purposes.',
    `attachment_point` DECIMAL(18,2) COMMENT 'Treaty layer attachment point amount at which reinsurance coverage begins for this occurrence under XOL treaty terms.',
    `cat_flag` BOOLEAN COMMENT 'Indicator whether this occurrence qualifies as a catastrophe event under treaty definitions and triggers CAT XOL coverage.',
    `cession_date` DATE COMMENT 'Date when the occurrence loss was formally ceded to reinsurers under the applicable treaty terms.',
    `claim_count` BIGINT COMMENT 'Total number of individual claims aggregated into this occurrence loss record for treaty cession purposes.',
    `country_code` STRING COMMENT 'Three-letter ISO country code identifying the country where the occurrence event occurred.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this occurrence loss record was first created in the system.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'Treaty layer exhaustion point amount at which reinsurance coverage ends for this occurrence, representing the upper limit of the layer.',
    `finalized_date` DATE COMMENT 'Date when the occurrence loss record was closed and finalized, with no further claim additions or loss development expected.',
    `geographic_region` STRING COMMENT 'Geographic area or territory where the occurrence event took place, used for treaty territory scope validation.',
    `hours_clause_compliant_flag` BOOLEAN COMMENT 'Indicator whether all claims aggregated into this occurrence fall within the treaty hours clause time window for valid occurrence treatment.',
    `hours_clause_duration` BIGINT COMMENT 'Number of hours specified in the treaty hours clause for aggregating related losses into a single occurrence event.',
    `layer_limit_amount` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery available from the treaty layer for this occurrence, calculated as exhaustion point minus attachment point.',
    `net_loss_amount` DECIMAL(18,2) COMMENT 'Net loss amount retained by the cedant after reinsurance cession, calculated as gross loss minus ceded loss.',
    `notes` STRING COMMENT 'Free-form text notes providing additional context, special handling instructions, or commentary about the occurrence loss.',
    `occurrence_date` DATE COMMENT 'Date when the loss occurrence event took place. Critical for treaty layer attachment and hours clause determination.',
    `occurrence_end_timestamp` TIMESTAMP COMMENT 'Date and time when the occurrence event concluded, used to determine the duration window for aggregating related claims under hours clause provisions.',
    `occurrence_name` STRING COMMENT 'Descriptive name or title assigned to the occurrence event, typically used for catastrophic events or major loss incidents.',
    `occurrence_number` STRING COMMENT 'Business identifier for the occurrence event. Externally-known reference number used in reinsurance bordereaux and treaty reporting.',
    `occurrence_status` STRING COMMENT 'Current lifecycle status of the occurrence loss record in the reinsurance cession workflow.. Valid values are `open|closed|under_review|pending_cession|finalized`',
    `occurrence_timestamp` TIMESTAMP COMMENT 'Precise date and time when the occurrence event began, used for hours clause compliance verification in catastrophe treaties.',
    `peril_code` STRING COMMENT 'Standardized code identifying the type of peril that caused the occurrence loss, such as hurricane, earthquake, fire, or flood.',
    `peril_description` STRING COMMENT 'Detailed narrative description of the peril or cause of loss for the occurrence event.',
    `policy_count` BIGINT COMMENT 'Total number of distinct policies affected by this occurrence event, used for exposure analysis and treaty reporting.',
    `reinstatement_premium_amount` DECIMAL(18,2) COMMENT 'Reinstatement premium amount due to reinsurers as a result of this occurrence loss exhausting or reducing treaty layer capacity.',
    `reinstatement_triggered_flag` BOOLEAN COMMENT 'Indicator whether this occurrence loss triggered a treaty layer reinstatement, requiring additional reinstatement premium payment.',
    `reported_date` DATE COMMENT 'Date when the occurrence loss was first reported to the reinsurance department for cession processing.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Cedant retention amount applied to this occurrence under the applicable treaty terms, representing the portion of loss retained by the ceding company.',
    `state_province_code` STRING COMMENT 'Code identifying the state or province where the occurrence event took place, used for regulatory and treaty reporting.',
    `total_ceded_alae_amount` DECIMAL(18,2) COMMENT 'Total ALAE amount ceded to reinsurers for this occurrence under applicable treaty terms.',
    `total_ceded_amount` DECIMAL(18,2) COMMENT 'Total amount ceded to reinsurers for this occurrence including loss and ALAE, representing the full reinsurance recovery.',
    `total_ceded_loss_amount` DECIMAL(18,2) COMMENT 'Total loss amount ceded to reinsurers for this occurrence after applying retention and treaty layer limits.',
    `total_gross_alae_amount` DECIMAL(18,2) COMMENT 'Total gross Allocated Loss Adjustment Expense aggregated from all claims in this occurrence, before reinsurance recovery.',
    `total_gross_incurred_amount` DECIMAL(18,2) COMMENT 'Total gross incurred loss including indemnity, ALAE, and ULAE for this occurrence, representing the full exposure before reinsurance.',
    `total_gross_loss_amount` DECIMAL(18,2) COMMENT 'Total gross loss amount aggregated from all claims associated with this occurrence, before any reinsurance cession or retention deduction.',
    `total_gross_ulae_amount` DECIMAL(18,2) COMMENT 'Total gross Unallocated Loss Adjustment Expense allocated to this occurrence based on company methodology.',
    `treaty_year` BIGINT COMMENT 'Treaty year under which this occurrence loss is covered, used for multi-year treaty accounting and aggregate limit tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this occurrence loss record was last modified, used for audit trail and data lineage tracking.',
    CONSTRAINT pk_occurrence_loss PRIMARY KEY(`occurrence_loss_id`)
) COMMENT 'Aggregates losses from multiple claims into a single occurrence for XOL treaty application. Stores occurrence date, peril, total gross loss, total ceded loss, applicable treaty layer, and hours clause compliance flag.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ADD CONSTRAINT `fk_reinsurance_fac_certificate_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ADD CONSTRAINT `fk_reinsurance_treaty_reinsurer_assumed_reinsurer_id` FOREIGN KEY (`assumed_reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ADD CONSTRAINT `fk_reinsurance_treaty_reinsurer_ri_broker_id` FOREIGN KEY (`ri_broker_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker`(`ri_broker_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ADD CONSTRAINT `fk_reinsurance_treaty_reinsurer_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ADD CONSTRAINT `fk_reinsurance_treaty_reinsurer_treaty_replacement_reinsurer_id` FOREIGN KEY (`treaty_replacement_reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ADD CONSTRAINT `fk_reinsurance_policy_cession_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ADD CONSTRAINT `fk_reinsurance_policy_cession_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ADD CONSTRAINT `fk_reinsurance_policy_cession_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_prior_bordereaux_id` FOREIGN KEY (`prior_bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_premium_transaction_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_premium_transaction_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_premium_transaction_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_premium_transaction_reversed_transaction_ceded_premium_transaction_id` FOREIGN KEY (`reversed_transaction_ceded_premium_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction`(`ceded_premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_premium_transaction_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ADD CONSTRAINT `fk_reinsurance_cat_bond_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ADD CONSTRAINT `fk_reinsurance_profit_commission_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ADD CONSTRAINT `fk_reinsurance_profit_commission_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ADD CONSTRAINT `fk_reinsurance_profit_commission_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ADD CONSTRAINT `fk_reinsurance_reinstatement_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ADD CONSTRAINT `fk_reinsurance_reinstatement_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ADD CONSTRAINT `fk_reinsurance_reinstatement_occurrence_loss_id` FOREIGN KEY (`occurrence_loss_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss`(`occurrence_loss_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ADD CONSTRAINT `fk_reinsurance_reinstatement_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ADD CONSTRAINT `fk_reinsurance_reinstatement_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ADD CONSTRAINT `fk_reinsurance_ri_placement_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ADD CONSTRAINT `fk_reinsurance_ri_placement_lead_reinsurer_id` FOREIGN KEY (`lead_reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ADD CONSTRAINT `fk_reinsurance_ri_placement_ri_broker_id` FOREIGN KEY (`ri_broker_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker`(`ri_broker_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ADD CONSTRAINT `fk_reinsurance_ri_placement_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ADD CONSTRAINT `fk_reinsurance_ri_placement_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ADD CONSTRAINT `fk_reinsurance_occurrence_loss_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ADD CONSTRAINT `fk_reinsurance_occurrence_loss_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ADD CONSTRAINT `fk_reinsurance_occurrence_loss_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ADD CONSTRAINT `fk_reinsurance_occurrence_loss_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`reinsurance` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `vibe_pc_insurance_v499`.`reinsurance` SET TAGS ('dbx_domain' = 'reinsurance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` SET TAGS ('dbx_subdomain' = 'treaty_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `originating_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Originating Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `originating_agency_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `originating_agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Originating Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `admitted_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Admitted Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `admitted_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `admitted_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `aggregate_retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `aggregate_retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_business_glossary_term' = 'A.M. Best Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `bound_date` SET TAGS ('dbx_business_glossary_term' = 'Treaty Bound Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `broker_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Broker Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `broker_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `broker_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Broker Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Treaty Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `cat_event_definition` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Definition');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'LETTER_OF_CREDIT|TRUST_FUND|FUNDS_WITHHELD|NONE');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_business_glossary_term' = 'Coverage Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_value_regex' = 'LOSSES_OCCURRING|RISKS_ATTACHING|CLAIMS_MADE');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `deposit_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `deposit_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Treaty Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Treaty Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `funds_withheld_flag` SET TAGS ('dbx_business_glossary_term' = 'Funds Withheld Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `layer_number` SET TAGS ('dbx_business_glossary_term' = 'Layer Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `lead_reinsurer_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `lead_reinsurer_name` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `lead_reinsurer_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `lead_reinsurer_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `lead_reinsurer_share_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `lead_reinsurer_share_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `lead_reinsurer_share_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Treaty Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `loss_corridor_lower_pct` SET TAGS ('dbx_business_glossary_term' = 'Loss Corridor Lower Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `loss_corridor_lower_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `loss_corridor_upper_pct` SET TAGS ('dbx_business_glossary_term' = 'Loss Corridor Upper Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `loss_corridor_upper_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `minimum_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `naic_reinsurer_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Reinsurer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `naic_reinsurer_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `naic_reinsurer_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `naic_reinsurer_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `perils_covered` SET TAGS ('dbx_business_glossary_term' = 'Perils Covered');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `placement_type` SET TAGS ('dbx_business_glossary_term' = 'Placement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `placement_type` SET TAGS ('dbx_value_regex' = 'TREATY|FACULTATIVE');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `pml_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `profit_commission_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Threshold Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `profit_commission_threshold_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Program Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `program_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `program_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `rate_on_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `rate_on_line_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `retention_type` SET TAGS ('dbx_business_glossary_term' = 'Retention Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `retention_type` SET TAGS ('dbx_value_regex' = 'MONETARY|PERCENTAGE');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `subject_premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Subject Premium Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `subject_premium_basis` SET TAGS ('dbx_value_regex' = 'GWP|NWP|EP|WP');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `territory_scope` SET TAGS ('dbx_business_glossary_term' = 'Treaty Territory Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `treaty_name` SET TAGS ('dbx_business_glossary_term' = 'Treaty Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `treaty_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `treaty_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `treaty_number` SET TAGS ('dbx_business_glossary_term' = 'Treaty Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `treaty_status` SET TAGS ('dbx_business_glossary_term' = 'Treaty Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `treaty_status` SET TAGS ('dbx_value_regex' = 'DRAFT|BOUND|ACTIVE|EXPIRED|CANCELLED|SUSPENDED');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` SET TAGS ('dbx_subdomain' = 'treaty_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Cedant Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Exposure ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q[1-4]|[0-9]{2})$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `bound_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Bound Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceded Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceded_share_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `certificate_number` SET TAGS ('dbx_value_regex' = '^FAC-[A-Z0-9]{4,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `certificate_status` SET TAGS ('dbx_business_glossary_term' = 'Facultative Certificate Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `certificate_status` SET TAGS ('dbx_value_regex' = 'draft|bound|active|expired|cancelled|declined');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Collateral Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `collateral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'trust_fund|letter_of_credit|funds_withheld|none');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `fac_type` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Reinsurance Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `fac_type` SET TAGS ('dbx_value_regex' = 'proportional|non_proportional|quota_share|excess_of_loss|surplus');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `gross_ceded_premium` SET TAGS ('dbx_business_glossary_term' = 'Gross Ceded Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `gross_ceded_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Inception Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `insured_name` SET TAGS ('dbx_business_glossary_term' = 'Insured Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `insured_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `insured_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `insured_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `net_ceded_premium` SET TAGS ('dbx_business_glossary_term' = 'Net Ceded Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `net_ceded_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `original_tiv` SET TAGS ('dbx_business_glossary_term' = 'Original Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `original_tiv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `placement_broker` SET TAGS ('dbx_business_glossary_term' = 'Facultative Placement Broker Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `pml_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `risk_description` SET TAGS ('dbx_business_glossary_term' = 'Risk Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `rol_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `rol_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SICS|SAPIENS_RI|DUCK_CREEK|GUIDEWIRE|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `xol_attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Excess of Loss (XOL) Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `xol_attachment_point` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `xol_exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Excess of Loss (XOL) Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ALTER COLUMN `xol_exhaustion_point` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` SET TAGS ('dbx_subdomain' = 'treaty_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `adjusted_premium` SET TAGS ('dbx_business_glossary_term' = 'Adjusted Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `aggregate_annual_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Annual Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `aggregate_deductible` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Deductible');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `alae_included` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Included Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `cat_event_limit` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage (QS)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `deposit_premium` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Layer Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `exclusions_summary` SET TAGS ('dbx_business_glossary_term' = 'Layer Exclusions Summary');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Layer Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `hours_clause` SET TAGS ('dbx_business_glossary_term' = 'Hours Clause (CAT Event Window)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `index_base_year` SET TAGS ('dbx_business_glossary_term' = 'Index Base Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `index_clause` SET TAGS ('dbx_business_glossary_term' = 'Index Clause Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `lae_treatment` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Treatment');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `lae_treatment` SET TAGS ('dbx_value_regex' = 'INCLUDED|EXCLUDED|PRO_RATA');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `lae_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `lae_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_limit` SET TAGS ('dbx_business_glossary_term' = 'Layer Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_name` SET TAGS ('dbx_business_glossary_term' = 'Layer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_number` SET TAGS ('dbx_business_glossary_term' = 'Layer Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_status` SET TAGS ('dbx_business_glossary_term' = 'Layer Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|PENDING|EXPIRED|CANCELLED');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_type` SET TAGS ('dbx_business_glossary_term' = 'Layer Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_type` SET TAGS ('dbx_value_regex' = 'XOL|QS|CAT_XL|FAC|AGGREGATE_XL|CAT_BOND');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `loss_basis` SET TAGS ('dbx_business_glossary_term' = 'Loss Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `loss_basis` SET TAGS ('dbx_value_regex' = 'OCCURRENCE|RISK|AGGREGATE|CLAIMS_MADE');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `max_ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Maximum Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `min_ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Minimum Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `minimum_premium` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `occurrence_limit` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `pml_basis` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `pml_basis` SET TAGS ('dbx_value_regex' = 'PML|TIV|EML|MFL');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinsurance_premium` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinsurance_premium` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinsurance_premium` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `rol` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `signed_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Signed Line Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `sliding_scale_commission` SET TAGS ('dbx_business_glossary_term' = 'Sliding Scale Commission Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `subject_premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Subject Premium Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `subject_premium_basis` SET TAGS ('dbx_value_regex' = 'GWP|NWP|EP|WP');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `territorial_scope` SET TAGS ('dbx_business_glossary_term' = 'Territorial Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `written_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Written Line Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` SET TAGS ('dbx_subdomain' = 'treaty_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_outlook` SET TAGS ('dbx_business_glossary_term' = 'A.M. Best Rating Outlook');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_outlook` SET TAGS ('dbx_value_regex' = 'stable|positive|negative|developing|under_review');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_business_glossary_term' = 'A.M. Best Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating_date` SET TAGS ('dbx_business_glossary_term' = 'A.M. Best Rating Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `approved_lob_list` SET TAGS ('dbx_business_glossary_term' = 'Approved Line of Business (LOB) List');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `authorized_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Authorized Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `authorized_status` SET TAGS ('dbx_value_regex' = 'authorized|unauthorized|certified|accredited|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Bank Account Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `claims_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Claims Contact Email');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `claims_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `claims_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `claims_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `class` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Class');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `class` SET TAGS ('dbx_value_regex' = 'professional|captive|government|lloyd_syndicate|pool');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'none|letter_of_credit|trust_fund|funds_withheld|cash_deposit');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `counterparty_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Counterparty Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `counterparty_type` SET TAGS ('dbx_value_regex' = 'reinsurer|retrocessionaire|captive|pool|syndicate|fronting_carrier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `credit_limit_currency` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Currency');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `credit_limit_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `credit_limit_usd` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Credit Limit (USD)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `credit_limit_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Domicile Country');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_state` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Domicile State');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `funds_withheld_eligible` SET TAGS ('dbx_business_glossary_term' = 'Funds Withheld Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Counterparty Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Lifecycle Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|under_review|terminated');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `lloyds_syndicate_number` SET TAGS ('dbx_business_glossary_term' = 'Lloyds Syndicate Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `loc_required` SET TAGS ('dbx_business_glossary_term' = 'Letter of Credit (LOC) Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `max_single_risk_limit_usd` SET TAGS ('dbx_business_glossary_term' = 'Maximum Single Risk Limit (USD)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `max_single_risk_limit_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `naic_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `naic_group_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Group Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `naic_group_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4,5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Counterparty Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `onboarding_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Onboarding Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `parent_group_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Parent Group Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `parent_group_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `parent_group_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `preferred_settlement_currency` SET TAGS ('dbx_business_glossary_term' = 'Preferred Settlement Currency');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `preferred_settlement_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Primary Contact Email');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Primary Contact Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Primary Contact Phone');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_city` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Registered Address City');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_country` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Registered Address Country');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_country` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_country` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Registered Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `registered_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sanctions_screen_date` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sanctions_screened` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Completed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `settlement_terms_days` SET TAGS ('dbx_business_glossary_term' = 'Settlement Terms (Days)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sp_rating` SET TAGS ('dbx_business_glossary_term' = 'S&P Global Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sp_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sp_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sp_rating_date` SET TAGS ('dbx_business_glossary_term' = 'S&P Rating Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sp_rating_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sp_rating_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `swift_bic_code` SET TAGS ('dbx_business_glossary_term' = 'SWIFT Bank Identifier Code (BIC)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `swift_bic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `swift_bic_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `swift_bic_code` SET TAGS ('dbx_pii_category' = 'financial');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `swift_bic_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `trading_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Trading Name (DBA)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `trading_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `trading_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `trust_fund_eligible` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Trust Fund Eligible Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` SET TAGS ('dbx_subdomain' = 'treaty_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `treaty_reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `treaty_reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `treaty_reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `assumed_reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `assumed_reinsurer_id` SET TAGS ('dbx_business_role' = 'assumed_reinsurer');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `assumed_reinsurer_id` SET TAGS ('dbx_renamed_from' = 'reinsurer_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `assumed_reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `assumed_reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `ri_broker_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Broker ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `treaty_replacement_reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Replacement Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `treaty_replacement_reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `treaty_replacement_reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_business_glossary_term' = 'A.M. Best Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `brokerage_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Brokerage Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `brokerage_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `brokerage_commission_pct` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `brokerage_commission_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `ceded_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `ceded_lae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `collateral_required_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `collateral_required_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|trust_fund|funds_withheld|cash_deposit|other');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Treaty Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `domicile_country_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Domicile Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `domicile_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Participation Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Participation Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `funds_withheld_amount` SET TAGS ('dbx_business_glossary_term' = 'Funds Withheld Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `funds_withheld_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_authorized_reinsurer` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_authorized_reinsurer` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_authorized_reinsurer` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_certified_reinsurer` SET TAGS ('dbx_business_glossary_term' = 'Certified Reinsurer Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_certified_reinsurer` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_certified_reinsurer` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_lead_reinsurer` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_lead_reinsurer` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `is_lead_reinsurer` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `naic_reinsurer_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC Reinsurer Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `naic_reinsurer_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `naic_reinsurer_code` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `naic_reinsurer_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `offered_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Offered Line Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `order_hereon_pct` SET TAGS ('dbx_business_glossary_term' = 'Order Hereon Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `panel_sequence` SET TAGS ('dbx_business_glossary_term' = 'Panel Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `participation_notes` SET TAGS ('dbx_business_glossary_term' = 'Participation Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `participation_reference` SET TAGS ('dbx_business_glossary_term' = 'Participation Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `participation_status` SET TAGS ('dbx_business_glossary_term' = 'Participation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `participation_status` SET TAGS ('dbx_value_regex' = 'active|signed|withdrawn|pending|cancelled|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `rating_as_of_date` SET TAGS ('dbx_business_glossary_term' = 'Rating As-Of Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `rating_as_of_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `rating_as_of_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `reinsurance_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `reinsurance_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `reinsurance_commission_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `reinsurance_commission_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `reinsurer_role` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Role');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `reinsurer_role` SET TAGS ('dbx_value_regex' = 'lead|follow|co-reinsurer|fronting|security');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `reinsurer_role` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `reinsurer_role` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `signed_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Signed Line Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `signing_date` SET TAGS ('dbx_business_glossary_term' = 'Signing Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `sliding_scale_max_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Sliding Scale Maximum Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `sliding_scale_max_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `sliding_scale_min_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Sliding Scale Minimum Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `sliding_scale_min_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `sp_rating` SET TAGS ('dbx_business_glossary_term' = 'S&P Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `sp_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `sp_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `subscribed_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Subscribed Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_value_regex' = 'capacity_reduction|credit_downgrade|market_exit|cedant_request|regulatory|other');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_reinsurer` ALTER COLUMN `written_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Written Line Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` SET TAGS ('dbx_subdomain' = 'cession_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Certificate Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Exposure ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_business_glossary_term' = 'A.M. Best Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `attachment_point` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Cession Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'risks_attaching|losses_occurring|claims_made');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_alae` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_alae` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (CEP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_ibnr` SET TAGS ('dbx_business_glossary_term' = 'Ceded Incurred But Not Reported (IBNR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_ibnr` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_limit` SET TAGS ('dbx_business_glossary_term' = 'Ceded Limit');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_loss_paid` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Paid');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_loss_paid` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_loss_reserve` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Reserve');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_loss_reserve` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceded Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_tiv` SET TAGS ('dbx_business_glossary_term' = 'Ceded Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_tiv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium (CUEP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium (CWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `collateral_required` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `endorsement_reference` SET TAGS ('dbx_business_glossary_term' = 'Policy Endorsement (ENDT) Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `is_retrocession` SET TAGS ('dbx_business_glossary_term' = 'Retrocession Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Cession Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^CES-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `placement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Placement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `placement_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `rate_on_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `rate_on_line_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Transaction Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_status` SET TAGS ('dbx_business_glossary_term' = 'Cession Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|cancelled|expired|settled');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_status` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_type` SET TAGS ('dbx_business_glossary_term' = 'Cession Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_type` SET TAGS ('dbx_value_regex' = 'pro_rata|excess_of_loss|facultative|cat_xl|cat_bond');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_type` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_recoverable` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_recoverable` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_recoverable` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_recoverable` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` SET TAGS ('dbx_subdomain' = 'cession_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `policy_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Cession ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `endorsement_id` SET TAGS ('dbx_business_glossary_term' = 'Endorsement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Certificate Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `bordereaux_included` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Included Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^d{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cession Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_value_regex' = 'POLICY_CANCELLED|TREATY_TERMINATED|ENDORSEMENT|REUNDERWRITING|ERROR_CORRECTION');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_alae` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_ibnr` SET TAGS ('dbx_business_glossary_term' = 'Ceded Incurred But Not Reported (IBNR)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_loss_paid` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Paid');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_loss_reserve` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Reserve');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_premium_earned` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (EP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_premium_written` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium (WP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceded Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium (UEP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `cession_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Cession Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `net_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `policy_term_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `policy_term_type` SET TAGS ('dbx_value_regex' = 'NB|REN|ENDT|CANC|REINSTATE');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurance_recoverable` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurance_recoverable` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurance_recoverable` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurer_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Participation Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurer_share_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `reinsurer_share_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SICS|SAPIENS_RI|GUIDEWIRE_PC|DUCK_CREEK|MANUAL');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `tiv_ceded` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value Ceded (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` SET TAGS ('dbx_subdomain' = 'cession_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Certificate Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `prior_bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Bordereaux ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q[1-4]|M(0[1-9]|1[0-2]))$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Acknowledgement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_type` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_type` SET TAGS ('dbx_value_regex' = 'premium|loss|combined|adjustment');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_ibnr_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_premium_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_premium_adjustment` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceded Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_tiv` SET TAGS ('dbx_business_glossary_term' = 'Ceded Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_tiv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_ulae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `claim_count` SET TAGS ('dbx_business_glossary_term' = 'Ceded Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `experience_refund_amount` SET TAGS ('dbx_business_glossary_term' = 'Experience Refund Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `experience_refund_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `gross_ceded_premium` SET TAGS ('dbx_business_glossary_term' = 'Gross Ceded Premium (GWP Ceded)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `gross_ceded_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `net_ceded_premium` SET TAGS ('dbx_business_glossary_term' = 'Net Ceded Premium (NWP Ceded)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `net_ceded_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^BDX-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `placement_broker` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Placement Broker');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Ceded Policy Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Remarks');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_format` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Format');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_format` SET TAGS ('dbx_value_regex' = 'ACORD|CSV|XML|XLSX|PDF');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_method` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|portal|email|paper');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|acknowledged|disputed|accepted|voided');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'QS|XOL|CAT_XL|surplus|FAC');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Version Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` SET TAGS ('dbx_subdomain' = 'cession_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `bordereaux_line_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Header ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (CEP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceded Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_ulae_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium (CWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `date_of_loss` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Dispute Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `insured_name` SET TAGS ('dbx_business_glossary_term' = 'Insured Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `insured_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `insured_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `insured_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `line_number` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'DRAFT|SUBMITTED|ACCEPTED|DISPUTED|SETTLED|VOIDED');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `line_type` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `line_type` SET TAGS ('dbx_value_regex' = 'PREMIUM|CLAIM|ADJUSTMENT|REINSTATEMENT|RETURN_PREMIUM');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `net_ceded_premium` SET TAGS ('dbx_business_glossary_term' = 'Net Ceded Premium (NCP)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `net_ceded_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `original_tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `original_tiv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `policy_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `policy_inception_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Inception Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `report_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Report Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `report_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Report Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `risk_description` SET TAGS ('dbx_business_glossary_term' = 'Risk Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `risk_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `risk_inception_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Inception Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Settlement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `xol_attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Excess of Loss (XOL) Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ALTER COLUMN `xol_exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Excess of Loss (XOL) Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` SET TAGS ('dbx_subdomain' = 'cession_processing');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `ceded_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reversed_transaction_ceded_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `accounting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `accounting_period_end_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `accounting_period_end_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `accounting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `accounting_period_start_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `accounting_period_start_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `adjustment_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `adjustment_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `bordereaux_reference` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `cession_pct` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `cession_type` SET TAGS ('dbx_business_glossary_term' = 'Cession Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `cession_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative|facultative_obligatory');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `dac_ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Deferred Acquisition Cost (DAC) Ceded Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `dac_ceded_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `deposit_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `deposit_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `earned_premium_ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Ceded Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `earned_premium_ceded_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `gwp_ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Ceded Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `gwp_ceded_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `layer_number` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Layer Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `nwp_ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Ceded Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `nwp_ceded_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `policy_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `policy_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `rol_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `settlement_due_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'pending|submitted|agreed|paid|disputed');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SICS|ReinsuranceMaster|Guidewire|DuckCreek|Manual');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `source_transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction Reference');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `subject_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Subject Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `subject_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Transaction Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Transaction Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_value_regex' = '^CPT-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Transaction Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'draft|posted|settled|voided|disputed');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'written|earned|return|adjustment|reinstatement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'quota_share|excess_of_loss|cat_xl|surplus|stop_loss');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `uep_ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Ceded Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `uep_ceded_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `ceded_loss_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Batch ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `accounting_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `accounting_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `accounting_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `bordereaux_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `cat_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `ceded_total_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Total Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `ceded_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `coverage_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `coverage_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `current_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `dol` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `layer_number` SET TAGS ('dbx_business_glossary_term' = 'Layer Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `net_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `paid_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `prior_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Reserve Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurer_confirmation_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Confirmation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurer_confirmation_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reinsurer_confirmation_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reporting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reporting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reserve_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserve Change Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reserve_movement_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Movement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `reserve_movement_type` SET TAGS ('dbx_value_regex' = 'initial|increase|decrease|closure|reopening');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Transaction Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'pending|reported|confirmed|disputed|settled|reversed');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `ri_recoverable_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recoverable Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `billed_date` SET TAGS ('dbx_business_glossary_term' = 'Billed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `cat_event_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `cession_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Collected Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `collected_date` SET TAGS ('dbx_business_glossary_term' = 'Collected Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `credit_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Credit Allowed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `dispute_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `disputed_amount` SET TAGS ('dbx_business_glossary_term' = 'Disputed Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Date of Loss (DOL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `loss_type` SET TAGS ('dbx_business_glossary_term' = 'Loss Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `loss_type` SET TAGS ('dbx_value_regex' = 'indemnity|alae|ulae|salvage|subrogation');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `overdue_flag` SET TAGS ('dbx_business_glossary_term' = 'Overdue Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `recoverable_balance` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `recoverable_number` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `recoverable_status` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `recoverable_status` SET TAGS ('dbx_value_regex' = 'pending|billed|acknowledged|disputed|collected|written_off');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `recoverable_type` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `recoverable_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative|pool|retrocession');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reported_date` SET TAGS ('dbx_business_glossary_term' = 'Reported Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reserve_category` SET TAGS ('dbx_business_glossary_term' = 'Reserve Category');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `reserve_category` SET TAGS ('dbx_value_regex' = 'case|ibnr|ibner|paid');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `written_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Off Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ALTER COLUMN `written_off_date` SET TAGS ('dbx_business_glossary_term' = 'Written Off Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ri_settlement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Settlement Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `balance_direction` SET TAGS ('dbx_business_glossary_term' = 'Balance Direction');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `balance_direction` SET TAGS ('dbx_value_regex' = 'due_from_reinsurer|due_to_reinsurer|zero');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `broker_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Broker Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `broker_name` SET TAGS ('dbx_business_glossary_term' = 'Broker Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|trust_account|funds_withheld|none');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `net_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Balance Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|check|ach|offset|letter_of_credit');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_number` SET TAGS ('dbx_business_glossary_term' = 'Settlement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'draft|pending|approved|paid|disputed|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `statement_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `statement_type` SET TAGS ('dbx_business_glossary_term' = 'Statement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `statement_type` SET TAGS ('dbx_value_regex' = 'account_current|cash_call|interim|final|adjustment');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `claim_ri_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Reinsurance (RI) Recovery ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Loss Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Policy Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `coverage_policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Acknowledgement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `collateral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `gross_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `layer_attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Layer Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `layer_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Layer Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `outstanding_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `recovered_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovered Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `recovery_basis` SET TAGS ('dbx_business_glossary_term' = 'Recovery Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `recovery_basis` SET TAGS ('dbx_value_regex' = 'loss_only|loss_and_alae|loss_and_ulae|pro_rata');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `recovery_number` SET TAGS ('dbx_business_glossary_term' = 'Recovery Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `recovery_status` SET TAGS ('dbx_business_glossary_term' = 'Recovery Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `recovery_type` SET TAGS ('dbx_business_glossary_term' = 'Recovery Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `recovery_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative|cat_xl|xol|quota_share|surplus');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinstatement_number` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinstatement_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinstatement_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurer_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurer_share_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `reinsurer_share_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` SET TAGS ('dbx_subdomain' = 'treaty_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `cat_bond_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Bond (CAT Bond) Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Cedant Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Treaty Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `aggregate_limit_flag` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `basis_risk_description` SET TAGS ('dbx_business_glossary_term' = 'Basis Risk Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_name` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Bond (CAT Bond) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_number` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Bond (CAT Bond) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_rating` SET TAGS ('dbx_business_glossary_term' = 'Bond Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_status` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Bond (CAT Bond) Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `bond_status` SET TAGS ('dbx_value_regex' = 'active|matured|triggered|cancelled|suspended|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `cat_event_definition` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Definition');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|treasury|money_market|investment_grade|mixed');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_business_glossary_term' = 'Coupon Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `coupon_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `expected_loss_pct` SET TAGS ('dbx_business_glossary_term' = 'Expected Loss Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `issuance_date` SET TAGS ('dbx_business_glossary_term' = 'Issuance Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `modeling_firm` SET TAGS ('dbx_business_glossary_term' = 'Modeling Firm');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `multi_event_flag` SET TAGS ('dbx_business_glossary_term' = 'Multi-Event Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Notional Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `outstanding_notional` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Notional');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `perils_covered` SET TAGS ('dbx_business_glossary_term' = 'Perils Covered');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `placement_broker` SET TAGS ('dbx_business_glossary_term' = 'Placement Broker');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `principal_reduction_amount` SET TAGS ('dbx_business_glossary_term' = 'Principal Reduction Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `rating_agency` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `rating_agency` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `reinstatement_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Provision Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `reinstatement_provision_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `reinstatement_provision_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `spv_domicile` SET TAGS ('dbx_business_glossary_term' = 'Special Purpose Vehicle (SPV) Domicile');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `spv_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `spv_name` SET TAGS ('dbx_business_glossary_term' = 'Special Purpose Vehicle (SPV) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `spv_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `spv_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `spv_registration_number` SET TAGS ('dbx_business_glossary_term' = 'Special Purpose Vehicle (SPV) Registration Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `spv_registration_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `territory_scope` SET TAGS ('dbx_business_glossary_term' = 'Territory Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `trigger_event_code` SET TAGS ('dbx_business_glossary_term' = 'Trigger Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `trigger_event_date` SET TAGS ('dbx_business_glossary_term' = 'Trigger Event Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Trigger Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'indemnity|parametric|index|modeled_loss|hybrid|industry_loss');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `trustee_name` SET TAGS ('dbx_business_glossary_term' = 'Trustee Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `trustee_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ALTER COLUMN `trustee_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `profit_commission_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Certificate Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `accrued_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrued Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Adjustment Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `adjustment_reason` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Adjustment Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `calculated_commission_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Calculated Profit Commission Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `calculated_loss_ratio_pct` SET TAGS ('dbx_business_glossary_term' = 'Calculated Loss Ratio Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Calculation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Calculation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'treaty_year|accident_year|underwriting_year|calendar_year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `calculation_notes` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Calculation Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `calculation_number` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Calculation Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `calculation_status` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Calculation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `ceded_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `formula` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Formula Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `formula` SET TAGS ('dbx_value_regex' = 'fixed_rate|sliding_scale|step_function|custom');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `loss_ratio_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio Threshold Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `net_ceded_premium` SET TAGS ('dbx_business_glossary_term' = 'Net Ceded Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Profit Commission Balance');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `paid_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Payment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `prior_calculation_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Profit Commission Calculation Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `provisional_flag` SET TAGS ('dbx_business_glossary_term' = 'Provisional Calculation Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `sliding_scale_max_pct` SET TAGS ('dbx_business_glossary_term' = 'Sliding Scale Maximum Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `sliding_scale_min_pct` SET TAGS ('dbx_business_glossary_term' = 'Sliding Scale Minimum Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `total_ceded_loss_lae` SET TAGS ('dbx_business_glossary_term' = 'Total Ceded Loss and Loss Adjustment Expense (LAE)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'quota_share|surplus|excess_of_loss|stop_loss|aggregate_xol');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstatement_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for reinstatement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstatement_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstatement_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Batch ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Certificate Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `occurrence_loss_id` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Loss Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty ID');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^d{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `automatic_reinstatement_flag` SET TAGS ('dbx_business_glossary_term' = 'Automatic Reinstatement Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `automatic_reinstatement_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `automatic_reinstatement_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'occurrence|aggregate|loss_ratio|sliding_scale');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `broker_name` SET TAGS ('dbx_business_glossary_term' = 'Broker Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `free_reinstatement_flag` SET TAGS ('dbx_business_glossary_term' = 'Free Reinstatement Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `free_reinstatement_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `free_reinstatement_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `lead_reinsurer_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `lead_reinsurer_name` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `lead_reinsurer_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `loss_amount_triggering` SET TAGS ('dbx_business_glossary_term' = 'Loss Amount Triggering');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `premium_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `prorata_factor` SET TAGS ('dbx_business_glossary_term' = 'Pro-Rata Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `prorata_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Pro-Rata Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstated_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstated Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstated_limit_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstated_limit_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstatement_status` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstatement_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|invoiced|paid|disputed|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstatement_status` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinstatement_status` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinsurer_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinsurer_approval_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinsurer_approval_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinsurer_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Approval Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinsurer_approval_required_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `reinsurer_approval_required_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `territory_scope` SET TAGS ('dbx_business_glossary_term' = 'Territory Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'XOL|CAT_XL|QS|SURPLUS|STOP_LOSS|AGGREGATE');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` SET TAGS ('dbx_subdomain' = 'treaty_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `ri_broker_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Broker Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `appointment_date` SET TAGS ('dbx_business_glossary_term' = 'Appointment Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `authorized_markets` SET TAGS ('dbx_business_glossary_term' = 'Authorized Markets');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `broker_code` SET TAGS ('dbx_business_glossary_term' = 'Broker Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `broker_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `broker_status` SET TAGS ('dbx_business_glossary_term' = 'Broker Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `broker_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|pending_approval');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `broker_type` SET TAGS ('dbx_business_glossary_term' = 'Broker Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `broker_type` SET TAGS ('dbx_value_regex' = 'wholesale|retail|lloyds|specialty|cat_broker|fac_specialist');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `brokerage_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Brokerage Rate Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `brokerage_rate_pct` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `brokerage_rate_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `cat_placement_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Placement Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|under_review|remediation');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `credit_rating` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `credit_rating` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Coverage Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `eo_coverage_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `eo_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Errors and Omissions (E&O) Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `fac_placement_flag` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Placement Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `fein` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `fein` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `fein` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Audit Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `lloyds_authorized_flag` SET TAGS ('dbx_business_glossary_term' = 'Lloyds Authorized Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `lloyds_broker_number` SET TAGS ('dbx_business_glossary_term' = 'Lloyds Broker Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `lloyds_broker_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,8}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `naic_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `parent_company_name` SET TAGS ('dbx_business_glossary_term' = 'Parent Company Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `parent_company_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `parent_company_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `rating_agency` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `rating_agency` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `specialty_lob` SET TAGS ('dbx_business_glossary_term' = 'Specialty Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `treaty_placement_flag` SET TAGS ('dbx_business_glossary_term' = 'Treaty Placement Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_broker` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Website Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` SET TAGS ('dbx_subdomain' = 'treaty_management');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `ri_placement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Placement Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `lead_reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `lead_reinsurer_id` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `lead_reinsurer_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placing_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Placing Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placing_agency_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placing_agency_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `ri_broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `binding_date` SET TAGS ('dbx_business_glossary_term' = 'Binding Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `broker_name` SET TAGS ('dbx_business_glossary_term' = 'Broker Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `brokerage_pct` SET TAGS ('dbx_business_glossary_term' = 'Brokerage Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `brokerage_pct` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `brokerage_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `cat_event_definition` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Definition');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `cat_exposed_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposed Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `fac_type` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `fac_type` SET TAGS ('dbx_value_regex' = 'fac_proportional|fac_xol|fac_cat');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Inception Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `lead_reinsurer_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer Share Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `lead_reinsurer_share_pct` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `lead_reinsurer_share_pct` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `markets_approached_count` SET TAGS ('dbx_business_glossary_term' = 'Markets Approached Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `participating_reinsurers_count` SET TAGS ('dbx_business_glossary_term' = 'Participating Reinsurers Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `participating_reinsurers_count` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `participating_reinsurers_count` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `perils_covered` SET TAGS ('dbx_business_glossary_term' = 'Perils Covered');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placed_capacity_amount` SET TAGS ('dbx_business_glossary_term' = 'Placed Capacity Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placed_capacity_amount` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placed_capacity_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_notes` SET TAGS ('dbx_business_glossary_term' = 'Placement Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_number` SET TAGS ('dbx_business_glossary_term' = 'Placement Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_stage` SET TAGS ('dbx_business_glossary_term' = 'Placement Stage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_stage` SET TAGS ('dbx_value_regex' = 'pre_marketing|marketing|negotiation|binding|post_binding');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_stage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_stage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_status` SET TAGS ('dbx_business_glossary_term' = 'Placement Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_type` SET TAGS ('dbx_business_glossary_term' = 'Placement Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `placement_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative|cat_bond|sideCar');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'Program Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `program_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `program_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `quote_due_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Due Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `quotes_received_count` SET TAGS ('dbx_business_glossary_term' = 'Quotes Received Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `rol_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `slip_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Slip Submission Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `target_capacity_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Capacity Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `target_capacity_amount` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `target_capacity_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `territory_scope` SET TAGS ('dbx_business_glossary_term' = 'Territory Scope');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `total_signed_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Total Signed Line Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'quota_share|surplus|xol|cat_xl|aggregate_xol|stop_loss');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` SET TAGS ('dbx_subdomain' = 'financial_settlement');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_loss_id` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Loss Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `fac_certificate_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Certificate Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Loss Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `ri_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Treaty Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `accounting_period` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `cat_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `cession_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `claim_count` SET TAGS ('dbx_business_glossary_term' = 'Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `finalized_date` SET TAGS ('dbx_business_glossary_term' = 'Finalized Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `hours_clause_compliant_flag` SET TAGS ('dbx_business_glossary_term' = 'Hours Clause Compliant Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `hours_clause_duration` SET TAGS ('dbx_business_glossary_term' = 'Hours Clause Duration');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `layer_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Layer Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `net_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_date` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Occurrence End Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_name` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_number` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_status` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Status');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_status` SET TAGS ('dbx_value_regex' = 'open|closed|under_review|pending_cession|finalized');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `occurrence_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `peril_description` SET TAGS ('dbx_business_glossary_term' = 'Peril Description');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `reinstatement_triggered_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Triggered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `reinstatement_triggered_flag` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `reinstatement_triggered_flag` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `reported_date` SET TAGS ('dbx_business_glossary_term' = 'Reported Date');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `state_province_code` SET TAGS ('dbx_business_glossary_term' = 'State or Province Code');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `total_ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `total_ceded_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Ceded Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `total_ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `total_gross_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Gross Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `total_gross_incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Gross Incurred Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `total_gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Gross Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `total_gross_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Gross Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
