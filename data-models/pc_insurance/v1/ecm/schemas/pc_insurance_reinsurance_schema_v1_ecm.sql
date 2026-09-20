-- Schema for Domain: reinsurance | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:32

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`reinsurance` COMMENT 'Manages risk transfer to reinsurers. Owns Reinsurance Agreement, Treaty (QS/XOL/SL/CAT XL), Facultative Agreement, Cession, and Reinsurance Recovery linked to ceded Policy and Claim.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` (
    `ri_agreement_id` BIGINT COMMENT 'Unique surrogate identifier for the reinsurance agreement record. Primary key. One row per reinsurance agreement between the cedant and one or more reinsurers.',
    `broker_agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Treaty agreements are placed through reinsurance brokers (agencies). Formalizing broker_name as FK enables producer performance tracking on treaty placements, commission reconciliation, and',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Reinsurance agreements are multi-currency contracts; currency master provides exchange rates, rounding rules, and display formats for financial reporting, settlement, and collateral',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Normalize lob_code string to FK reference to shared.line_of_business master data. RI agreement currently stores lob_code as string; replacing with FK enables consistent LOB',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Treaty agreements may credit lead producer on cedant side who structured the reinsurance program.',
    `aggregate_limit_amt` DECIMAL(18,2) COMMENT 'Maximum cumulative reinsurance recovery across all losses in the treaty period. Caps total reinsurer exposure for Stop Loss and aggregate XOL structures. Null if no aggregate cap.',
    `agreement_name` STRING COMMENT 'Descriptive name or title of the reinsurance agreement (e.g., 2024 Property CAT XL Layer 1). Used for human-readable identification in reports and workbenches.',
    `agreement_number` STRING COMMENT 'Externally-known unique reference number assigned to the reinsurance agreement by the cedant or reinsurance management system. Used in bordereaux and Schedule F reporting.',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the reinsurance agreement. Active indicates the agreement is in force and cessions may be made. Expired indicates the term has ended with no renewal.. Valid values are `Draft|Active|Expired|Cancelled|Suspended`',
    `agreement_type` STRING COMMENT 'Broad classification of the reinsurance arrangement: Treaty (automatic cession under standing contract), Facultative (individual risk negotiation), or Facultative-Obligatory.. Valid values are `Treaty|Facultative|Facultative_Obligatory`',
    `arbitration_clause` BOOLEAN COMMENT 'Indicates whether the agreement contains a mandatory arbitration clause for dispute resolution in lieu of litigation. True if arbitration is required.',
    `attachment_point_amt` DECIMAL(18,2) COMMENT 'The loss threshold at which the reinsurance layer attaches and begins to respond for XOL and CAT XL treaties. Expressed in agreement currency. Null for proportional treaties.',
    `authorized_status` STRING COMMENT 'Regulatory authorization status of the lead reinsurer in the cedants domicile state: Authorized, Unauthorized, Certified (under NAIC Credit for Reinsurance Model Law), or Reciprocal.. Valid values are `Authorized|Unauthorized|Certified|Reciprocal`',
    `cat_event_scope` STRING COMMENT 'Defines the loss aggregation basis for CAT XL treaties: Per Risk, Per Occurrence, Per Event (hours clause), or Aggregate. Determines how losses from a single CAT event are combined.. Valid values are `Per_Risk|Per_Occurrence|Per_Event|Aggregate`',
    `cedant_legal_entity` STRING COMMENT 'Legal name of the ceding company (cedant) that is transferring risk under this agreement. Corresponds to the licensed insurance entity on the NAIC Annual Statement.',
    `cedant_naic_code` STRING COMMENT 'Five-digit NAIC company code identifying the cedant legal entity. Required for NAIC Schedule F statutory reporting and regulatory filings.. Valid values are `^[0-9]{5}$`',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to the cedant as a ceding commission under proportional (QS/Surplus) treaties to offset acquisition and overhead costs.',
    `cession_pct` DECIMAL(7,4) COMMENT 'Percentage of risk ceded to reinsurers under a Quota Share treaty (e.g., 25.0000 = 25%). Null for XOL and non-proportional treaties where cession is loss-triggered.',
    `collateral_required` BOOLEAN COMMENT 'Indicates whether the reinsurer is required to post collateral (LOC, trust, funds withheld) due to unauthorized/alien reinsurer status. Drives Schedule F credit allowance.',
    `collateral_type` STRING COMMENT 'Type of collateral posted by the reinsurer: Letter of Credit (LOC), Trust Account, Funds Withheld, Cash, or None. Required for unauthorized reinsurer credit under SAP SSAP No. 62R.. Valid values are `LOC|Trust|Funds_Withheld|Cash|None`',
    `coverage_basis` STRING COMMENT 'Defines which losses are covered: Losses Occurring (loss event in treaty period), Risks Attaching (policy incepting in treaty period), or Claims Made (claim reported in treaty period).. Valid values are `Losses_Occurring|Risks_Attaching|Claims_Made`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the reinsurance agreement record was first created in the reinsurance management system. Used for audit trail and data lineage tracking.',
    `deposit_premium_amt` DECIMAL(18,2) COMMENT 'Initial premium paid by the cedant at inception of the treaty year, subject to adjustment at year-end based on actual subject premium. Used in ROL and premium settlement calculations.',
    `expiry_date` DATE COMMENT 'The date on which the reinsurance agreement expires and no new cessions may be made. Null for evergreen or open-ended agreements. Used in Schedule F run-off reporting.',
    `funds_withheld` BOOLEAN COMMENT 'Indicates whether the cedant withholds ceded premium reserves rather than remitting to the reinsurer. Affects Schedule F credit and collateral requirements under SAP SSAP No. 62R.',
    `governing_law` STRING COMMENT 'Legal jurisdiction whose laws govern interpretation and enforcement of the agreement (e.g., New York, England and Wales). Required for dispute resolution and regulatory compliance.',
    `hours_clause_hrs` BIGINT COMMENT 'Number of consecutive hours within which losses from a single occurrence are aggregated for CAT XL recovery purposes (e.g., 72 hours for wind, 168 hours for flood). Null if not applicable.',
    `inception_date` DATE COMMENT 'The date on which the reinsurance agreement becomes effective and cessions may begin. Aligns with the treaty year start for annual treaties.',
    `insolvency_clause` BOOLEAN COMMENT 'Indicates whether the agreement contains an insolvency clause ensuring reinsurer obligations survive cedant insolvency. Required under SAP SSAP No. 62R for credit as reinsurance.',
    `lead_reinsurer_naic_code` STRING COMMENT 'Five-digit NAIC company code for the lead reinsurer. Required for Schedule F counterparty identification and credit risk assessment under SAP SSAP No. 62R.. Valid values are `^[0-9]{5}$`',
    `lead_reinsurer_name` STRING COMMENT 'Legal name of the lead reinsurer on the agreement. For syndicated treaties, this is the lead market that sets terms. Used in bordereaux and Schedule F counterparty reporting.',
    `limit_amt` DECIMAL(18,2) COMMENT 'Maximum amount the reinsurer will pay per risk, per occurrence, or in aggregate under this agreement. Defines the top of the reinsurance layer for XOL treaties.',
    `loss_corridor_pct` DECIMAL(7,4) COMMENT 'Loss ratio band within which the cedant retains losses before the reinsurer re-engages, used in Stop Loss and aggregate structures. Null if no loss corridor provision.',
    `minimum_premium_amt` DECIMAL(18,2) COMMENT 'Minimum reinsurance premium guaranteed to the reinsurer regardless of actual subject premium volume. Protects reinsurer against cedant portfolio shrinkage.',
    `offset_clause` BOOLEAN COMMENT 'Indicates whether the agreement permits mutual offset of amounts owed between cedant and reinsurer. Relevant for credit risk management and Schedule F balance netting.',
    `profit_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of reinsurer profit returned to the cedant under a profit commission clause. Calculated on the treaty year result after losses and expenses. Null if no profit commission.',
    `program_layer` STRING COMMENT 'Identifies the layer within a multi-layer reinsurance program (e.g., Layer 1, Layer 2, Top Layer). Used to sequence layers for loss allocation and PML modeling.',
    `reinstatement_count` BIGINT COMMENT 'Number of times the reinsurance limit may be reinstated after a loss exhausts the layer. Common in CAT XL treaties. Zero indicates no reinstatement provision.',
    `reinstatement_premium_pct` DECIMAL(7,4) COMMENT 'Percentage of the original reinsurance premium charged to reinstate the limit after a loss. Expressed as a percentage of the annual deposit premium (e.g., 100% = pro-rata reinstatement).',
    `retention_amt` DECIMAL(18,2) COMMENT 'The cedants net retained amount per risk or per occurrence before reinsurance responds. For XOL, this is the attachment point (SIR). For QS, this is the retained share in currency.',
    `retrocession_flag` BOOLEAN COMMENT 'Indicates whether this agreement is a retrocession (reinsurer ceding risk to another reinsurer) rather than a primary cession from the cedant. Affects Schedule F netting.',
    `rol_pct` DECIMAL(7,4) COMMENT 'Rate on Line expressed as a percentage: reinsurance premium divided by the reinsurance limit. Key pricing metric for XOL and CAT XL layers used in actuarial and underwriting analysis.',
    `signed_date` DATE COMMENT 'The date the reinsurance agreement was formally executed and signed by all parties. May differ from inception date for retroactive or late-signed treaties.',
    `territory_scope` STRING COMMENT 'Geographic scope of risks covered by the agreement (e.g., USA and Canada, Worldwide excluding War Zones). Drives exposure aggregation and CAT model alignment.',
    `treaty_type` STRING COMMENT 'Sub-classification for Treaty agreements: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), Catastrophe Excess of Loss (CAT XL), Surplus Share, or Other. Null for Facultative agreements.. Valid values are `QS|XOL|SL|CAT_XL|Surplus|Other`',
    `unl_basis` STRING COMMENT 'Defines how Ultimate Net Loss is calculated for recovery purposes: Gross (before other RI), Net of Inuring RI (after lower layers), or Net of All RI. Critical for layered program structures.. Valid values are `Gross|Net_of_Inuring|Net_of_All_RI`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the reinsurance agreement record was most recently modified. Used for change tracking, audit compliance, and incremental data pipeline processing.',
    CONSTRAINT pk_ri_agreement PRIMARY KEY(`ri_agreement_id`)
) COMMENT 'Master record for a reinsurance agreement between the cedant and one or more reinsurers. One row per agreement. Captures agreement type (Treaty/Facultative), status, inception/expiry, governing law, and currency.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` (
    `treaty_id` BIGINT COMMENT 'Unique surrogate identifier for a reinsurance treaty record. Primary key. One row per treaty under a reinsurance agreement.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Treaty financial terms require currency master for exchange rate application, premium settlement, and multi-currency reporting.',
    `intermediary_agency_id` BIGINT COMMENT 'Foreign key linking to producers.agency. Business justification: Treaties track intermediary/broker by name; should formalize as FK to agency. Enables broker performance analysis on treaty placements, commission tracking for reinsurance intermediation',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Treaty structuring, rate adequacy analysis, and regulatory reporting require LOB master for NAIC line codes, loss ratio targets, and treaty applicability rules.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.reinsurer. Business justification: Treaty has denormalized reinsurer attributes (reinsurer_name, reinsurer_naic_code, reinsurer_share_pct). Adding FK to reinsurer master and removing redundant name and NAIC code.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the parent reinsurance agreement under which this treaty is placed. Links treaty to the master agreement record.',
    `aggregate_deductible` DECIMAL(18,2) COMMENT 'Cumulative loss amount the cedant must absorb before aggregate stop loss or aggregate XOL reinsurance attaches. Also known as the annual aggregate retention.',
    `aggregate_limit` DECIMAL(18,2) COMMENT 'Maximum total reinsurance recovery across all occurrences during the treaty period. Caps cumulative recoveries for aggregate XOL and Stop Loss treaties.',
    `attachment_point` DECIMAL(18,2) COMMENT 'Dollar amount at which reinsurance coverage attaches for XOL and CAT XL treaties. Losses below this threshold are retained by the cedant. Null for proportional treaties.',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized/accredited in the cedants domicile state. Affects credit for reinsurance on the statutory balance sheet per NAIC requirements.',
    `brokerage_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium paid to the reinsurance intermediary as brokerage commission. Expressed as a decimal (e.g., 0.0250 = 2.5%).',
    `catastrophe_event_type` STRING COMMENT 'Peril type covered by a CAT XL treaty. Restricts recovery eligibility to specified catastrophe perils. Null for non-CAT treaties. [ENUM-REF-CANDIDATE: WINDSTORM|EARTHQUAKE|FLOOD|WILDFIRE|HAIL|ALL_PERILS|OTHER — promote to reference product]',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to the cedant as ceding commission under a proportional treaty. Expressed as a decimal (e.g., 0.3000 = 30%). Null for XOL treaties.',
    `cession_pct` DECIMAL(7,4) COMMENT 'Percentage of risk ceded to reinsurers under a Quota Share treaty. Expressed as a decimal (e.g., 0.7500 = 75%). Null for non-proportional treaties.',
    `collateral_required_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer must post collateral (letter of credit or trust fund) to support credit for reinsurance on the cedants statutory balance sheet.',
    `coverage_basis` STRING COMMENT 'Defines which losses are covered: Risks Attaching (policies incepting in treaty period), Losses Occurring (losses occurring in treaty period), or Claims Made.. Valid values are `RISKS_ATTACHING|LOSSES_OCCURRING|CLAIMS_MADE`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this treaty record was first created in the reinsurance management system. Used for audit trail and data lineage tracking.',
    `deposit_premium` DECIMAL(18,2) COMMENT 'Provisional premium paid at treaty inception, subject to adjustment at year-end based on actual subject premium. Common in proportional and adjustable XOL treaties.',
    `effective_date` DATE COMMENT 'Date on which the treaty becomes binding and cessions may attach. Policies with inception on or after this date are eligible for cession under this treaty.',
    `expiration_date` DATE COMMENT 'Date on which the treaty expires and no new cessions may attach. Null for evergreen treaties. Used in Schedule F period-end calculations.',
    `hours_clause` BIGINT COMMENT 'Maximum number of consecutive hours within which losses from a single catastrophe event are aggregated for recovery purposes (e.g., 72 hours for windstorm, 168 hours for flood).',
    `inception_year` BIGINT COMMENT 'Calendar year in which the treaty incepted. Used for underwriting year (UY) and policy year (PY) loss triangle segmentation in actuarial reserving.',
    `layer_number` BIGINT COMMENT 'Sequential layer number within a tower of XOL or CAT XL protection (e.g., Layer 1, Layer 2). Distinguishes multiple treaties in the same program year.',
    `limit` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery available under this treaty per occurrence or in aggregate. Defines the top of the layer for XOL/CAT XL treaties.',
    `loss_corridor_lower` DECIMAL(7,4) COMMENT 'Lower bound of the loss ratio corridor retained by the cedant in a Stop Loss treaty. Expressed as a decimal loss ratio (e.g., 0.7000 = 70%). Null for non-SL treaties.',
    `loss_corridor_upper` DECIMAL(7,4) COMMENT 'Upper bound of the loss ratio corridor at which Stop Loss reinsurance attaches. Expressed as a decimal loss ratio (e.g., 0.9000 = 90%). Null for non-SL treaties.',
    `minimum_premium` DECIMAL(18,2) COMMENT 'Minimum reinsurance premium guaranteed to the reinsurer regardless of ceded subject premium volume. Protects reinsurer against low-volume years.',
    `treaty_name` STRING COMMENT 'Descriptive name of the treaty (e.g., Property CAT XL Layer 1 2024). Used for human identification in reinsurance management system and bordereaux.',
    `number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to the treaty by the cedant or reinsurer. Used in bordereaux reporting and Schedule F filings.',
    `occurrence_limit` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery per single occurrence or event under this treaty. Distinct from aggregate limit. Applies to per-occurrence XOL and CAT XL structures.',
    `placement_pct` DECIMAL(7,4) COMMENT 'Total percentage of treaty capacity placed with all reinsurers combined. A value less than 1.0000 indicates a partially placed treaty with net retained gap.',
    `premium` DECIMAL(18,2) COMMENT 'Total reinsurance premium ceded to reinsurers under this treaty for the treaty period. For QS treaties, this is the ceded written premium. For XOL, this is the flat or deposit premium.',
    `profit_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of treaty profit returned to the cedant as profit commission under a sliding scale or profit-sharing arrangement. Null if no profit commission applies.',
    `reinstatement_count` BIGINT COMMENT 'Number of times the treaty limit may be reinstated after a loss exhausts the layer. Common in CAT XL treaties. Zero indicates no reinstatements available.',
    `reinstatement_premium_pct` DECIMAL(7,4) COMMENT 'Percentage of the original treaty premium charged to reinstate the treaty limit after a loss. Expressed as a decimal (e.g., 1.0000 = 100% pro-rata reinstatement).',
    `reinsurer_share_pct` DECIMAL(7,4) COMMENT 'Percentage of the treaty capacity subscribed by the lead reinsurer. For fully placed treaties this may be 100%; for syndicated treaties it reflects the lead line.',
    `retention_amount` DECIMAL(18,2) COMMENT 'The cedants net retained loss amount before reinsurance attaches. For XOL, this is the attachment point per occurrence. For QS, this is the retained percentage expressed as a dollar floor.',
    `retention_pct` DECIMAL(7,4) COMMENT 'Percentage of risk retained by the cedant under a proportional (QS or Surplus) treaty. Expressed as a decimal (e.g., 0.2500 = 25%). Null for non-proportional treaties.',
    `retrocession_flag` BOOLEAN COMMENT 'Indicates whether this treaty is a retrocession arrangement (reinsurer ceding risk to another reinsurer). True = retrocession; False = standard cedant-to-reinsurer treaty.',
    `rol_pct` DECIMAL(7,4) COMMENT 'Rate on Line expressed as a decimal: treaty premium divided by treaty limit. Key pricing metric for XOL and CAT XL treaties used in reinsurance pricing analytics.',
    `subject_premium_basis` STRING COMMENT 'Defines the premium base used to calculate ceded premium under proportional treaties: Gross Written Premium (GWP), Net Written Premium (NWP), Direct Premium Written (DPW), or Net Earned.. Valid values are `GWP|NWP|DPW|NET_EARNED`',
    `territory` STRING COMMENT 'Geographic scope of risks covered by this treaty (e.g., USA, USA and Canada, Worldwide Excluding). Defines eligible cession geography for bordereaux reporting.',
    `treaty_status` STRING COMMENT 'Current lifecycle state of the treaty. Controls whether new cessions can be written against it and whether recoveries are eligible.. Valid values are `ACTIVE|EXPIRED|CANCELLED|SUSPENDED|PENDING`',
    `treaty_type` STRING COMMENT 'Classification of the treaty structure: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), Catastrophe Excess of Loss (CAT XL), or Surplus. Drives cession and recovery calculation logic.. Valid values are `QS|XOL|SL|CAT_XL|STOP_LOSS|SURPLUS`',
    `unl_basis` STRING COMMENT 'Defines how Ultimate Net Loss (UNL) is calculated for recovery purposes: gross of inuring reinsurance, net of inuring reinsurance, net of salvage/subrogation, or full UNL.. Valid values are `GROSS|NET_OF_INURING|NET_OF_SALVAGE|ULTIMATE_NET_LOSS`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this treaty record in the reinsurance management system. Supports change tracking and audit compliance.',
    CONSTRAINT pk_treaty PRIMARY KEY(`treaty_id`)
) COMMENT 'Defines a proportional or non-proportional treaty under a reinsurance agreement. One row per treaty. Captures treaty type (QS/XOL/SL/CAT XL), layer, retention, limit, ROL, and UNL basis.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` (
    `treaty_layer_id` BIGINT COMMENT 'Unique surrogate identifier for a single attachment/exhaustion layer within an XOL or CAT XL reinsurance treaty. One row per layer per treaty.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Treaty layers often have zone-specific attachment points and limits for concentration management, regulatory capital calculations, and underwriting guidelines.',
    `coverage_type_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage_type. Business justification: Treaty layers often restrict coverage by type (e.g., layer covers only general liability, not property).',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Layer limits and premiums are currency-denominated; currency master provides exchange rates for multi-currency treaty structures and ensures consistent financial reporting across layers.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the parent reinsurance agreement under which this layer is structured. Links the layer to its governing treaty contract.',
    `treaty_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty. Business justification: treaty_layer represents individual attachment/exhaustion layers within a treaty. Currently only references ri_agreement, but should also reference the parent treaty.',
    `parent_treaty_layer_id` BIGINT COMMENT 'Self-referencing identifier of the immediately underlying treaty layer in a multi-layer tower. Null for the first layer above the cedant retention.',
    `accounting_basis` STRING COMMENT 'Basis on which losses are covered: losses_occurring (losses that occur during the treaty period) or risks_attaching (policies attaching during the treaty period).. Valid values are `losses_occurring|risks_attaching`',
    `annual_aggregate_deductible` DECIMAL(18,2) COMMENT 'Cumulative loss amount the cedant must retain across all occurrences before the annual aggregate limit of this layer begins to respond.',
    `annual_aggregate_limit` DECIMAL(18,2) COMMENT 'Maximum total dollar amount recoverable from reinsurers under this layer across all occurrences within the treaty year. Null if no aggregate cap applies.',
    `attachment_point` DECIMAL(18,2) COMMENT 'Dollar amount of loss per occurrence at which this reinsurance layer begins to respond. Losses below this threshold are retained by the cedant.',
    `broker_reference` STRING COMMENT 'Reinsurance brokers reference number or slip identifier for this layer as used in placement correspondence and market submissions.',
    `cedant_retention_pct` DECIMAL(7,4) COMMENT 'Percentage of loss within this layer retained by the cedant (co-participation). Expressed as a decimal (e.g., 0.1000 = 10%). Remainder is ceded to reinsurers.',
    `ceded_pct` DECIMAL(7,4) COMMENT 'Percentage of loss within this layer ceded to reinsurers. Equals 1 minus cedant_retention_pct. Stored explicitly for bordereaux and Schedule F reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this treaty layer record was first created in the reinsurance management system. Used for audit trail and data lineage.',
    `deposit_premium` DECIMAL(18,2) COMMENT 'Provisional premium paid at inception of the treaty layer, subject to adjustment at year-end based on actual subject premium earned.',
    `effective_date` DATE COMMENT 'Date on which this treaty layer becomes binding and coverage obligations commence. Used to determine which layer applies to a given loss date.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'Dollar amount at which this layer is fully exhausted, equal to attachment_point plus layer_limit. Stored explicitly for bordereaux reporting and PML tower analysis.',
    `expiration_date` DATE COMMENT 'Date on which this treaty layer expires and coverage obligations cease. Nullable for evergreen or continuous layers.',
    `hours_clause` BIGINT COMMENT 'Maximum number of consecutive hours within which losses from a single catastrophic event are aggregated as one occurrence (e.g., 168 for windstorm, 72 for earthquake).',
    `index_basis` STRING COMMENT 'Name or description of the index used for the index clause (e.g., CPI, Marshall & Swift construction cost index). Null if index_clause_flag is false.',
    `index_clause_flag` BOOLEAN COMMENT 'Indicates whether an index or stability clause applies to this layer, adjusting the attachment point and limit in line with an inflation or price index.',
    `layer_code` STRING COMMENT 'Externally-known alphanumeric code identifying this layer as referenced in bordereaux, reinsurer slips, and Schedule F filings.. Valid values are `^[A-Z0-9_-]{1,30}$`',
    `layer_limit` DECIMAL(18,2) COMMENT 'Maximum dollar amount recoverable from reinsurers under this layer for a single occurrence or event. Defines the exhaustion point as attachment_point + layer_limit.',
    `layer_name` STRING COMMENT 'Descriptive name for this layer (e.g., 1st XOL Layer, 2nd CAT XL Layer) used in reinsurer communications and internal reporting.',
    `layer_notes` STRING COMMENT 'Free-text field for underwriter or reinsurance analyst notes regarding special terms, conditions, or exceptions applicable to this layer not captured in structured fields.',
    `layer_number` BIGINT COMMENT 'Sequential ordinal position of this layer within the treaty tower, starting at 1 for the first layer above the retention. Used to reconstruct the full tower order.',
    `layer_status` STRING COMMENT 'Current lifecycle state of the treaty layer indicating whether it is actively in force, expired, cancelled, pending placement, or suspended.. Valid values are `active|expired|cancelled|pending|suspended`',
    `layer_type` STRING COMMENT 'Classification of the reinsurance layer structure. XOL=Excess of Loss, CAT_XL=Catastrophe Excess of Loss, QS=Quota Share, SL=Stop Loss, WORKING=working layer, CLASH=clash cover.. Valid values are `XOL|CAT_XL|QS|SL|WORKING|CLASH`',
    `lob_scope` STRING COMMENT 'Comma-delimited list of Lines of Business covered by this layer (e.g., HO, PAP, CGL, BOP). Defines the subject business eligible for recovery under this layer.',
    `loss_corridor_lower` DECIMAL(18,2) COMMENT 'Lower bound of a loss corridor within this layer where the cedant retains losses. Used in structured XOL layers with embedded retentions.',
    `loss_corridor_upper` DECIMAL(18,2) COMMENT 'Upper bound of a loss corridor within this layer where the cedant retains losses. Losses above this bound revert to reinsurer coverage within the layer.',
    `loss_occurrence_definition` STRING COMMENT 'Contractual definition of a single occurrence for this layer (e.g., 168-hour clause for windstorm, 72-hour clause for earthquake). Critical for CAT XL aggregation.',
    `minimum_premium` DECIMAL(18,2) COMMENT 'Minimum reinsurance premium guaranteed to reinsurers for this layer regardless of subject premium volume. Protects reinsurers against low-volume scenarios.',
    `peril_scope` STRING COMMENT 'Comma-delimited list of perils covered by this layer (e.g., WIND, QUAKE, FLOOD, FIRE, ALL). Determines which catastrophe events trigger recovery under this layer.',
    `placed_pct` DECIMAL(7,4) COMMENT 'Percentage of this layer that has been placed with reinsurers. A value less than 1.0 indicates the layer is not fully subscribed.',
    `profit_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of underwriting profit returned to the cedant by reinsurers under a profit commission clause for this layer. Expressed as a decimal.',
    `reinstatement_basis` STRING COMMENT 'Basis on which reinstatement premium is calculated: pro_rata (proportional to loss), flat (fixed percentage), or free (no additional premium charged).. Valid values are `pro_rata|flat|free`',
    `reinstatement_count` BIGINT COMMENT 'Number of reinstatements available for this layer after a loss exhausts the layer limit. Zero indicates no reinstatements; null indicates unlimited reinstatements.',
    `reinstatement_premium_pct` DECIMAL(7,4) COMMENT 'Percentage of the original layer premium charged per reinstatement to restore the layer limit after a loss. Expressed as a decimal (e.g., 1.0000 = 100% pro-rata).',
    `reinsurance_premium` DECIMAL(18,2) COMMENT 'Gross reinsurance premium payable by the cedant to reinsurers for this layer for the treaty period. Used in bordereaux and Schedule F premium reporting.',
    `retrocession_flag` BOOLEAN COMMENT 'Indicates whether this layer is a retrocession layer (reinsurance of reinsurance) rather than a direct cession from the primary insurer.',
    `rol_pct` DECIMAL(7,4) COMMENT 'Rate on Line expressed as a decimal; the reinsurance premium for this layer divided by the layer limit. Key pricing metric for XOL and CAT XL layers.',
    `signed_line_pct` DECIMAL(7,4) COMMENT 'Total signed line percentage across all reinsurers participating in this layer after signing-down from written lines. Should sum to placed_pct.',
    `sliding_scale_flag` BOOLEAN COMMENT 'Indicates whether a sliding scale commission arrangement applies to this layer, where the ceding commission varies inversely with the loss ratio.',
    `subject_premium_basis` STRING COMMENT 'Premium base used to calculate the reinsurance premium for this layer. GWP=Gross Written Premium, NWP=Net Written Premium, DPW=Direct Premium Written, NEP=Net Earned Premium, GEP=Gross Earned Premium.. Valid values are `GWP|NWP|DPW|NEP|GEP`',
    `territory_scope` STRING COMMENT 'Geographic territory covered by this layer (e.g., USA, USA_GULF, NATIONWIDE). Defines the geographic boundary of eligible subject business for this layer.',
    `unl_basis` STRING COMMENT 'Defines how Ultimate Net Loss is calculated for recovery under this layer: gross of all recoveries, net of other recoveries, or net of underlying reinsurance.. Valid values are `gross|net_of_recoveries|net_of_underlying_ri`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this treaty layer record. Used for change tracking, audit compliance, and incremental data loading.',
    CONSTRAINT pk_treaty_layer PRIMARY KEY(`treaty_layer_id`)
) COMMENT 'Individual attachment/exhaustion layer within an XOL or CAT XL treaty. One row per layer per treaty. Stores attachment point, limit per occurrence, annual aggregate limit, and reinstatement terms.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` (
    `fac_agreement_id` BIGINT COMMENT 'Unique surrogate primary key for the facultative reinsurance agreement. One row per FAC placement covering a single risk or policy.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to a catastrophe event record if this FAC placement was triggered or influenced by a specific CAT event exposure.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Facultative certificates are often in foreign currencies; currency master provides exchange rates for premium settlement, collateral valuation, and financial reporting.',
    `fac_broker_party_id` BIGINT COMMENT 'Reference to the party record for the reinsurance intermediary/broker who placed this FAC agreement on behalf of the cedant.',
    `fac_cedant_party_id` BIGINT COMMENT 'Reference to the party record representing the ceding insurer (Pc_Insurance) transferring risk under this FAC agreement.',
    `fac_reinsurer_party_id` BIGINT COMMENT 'Reference to the party record representing the assuming reinsurer accepting the ceded risk under this FAC placement.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Facultative certificates require LOB master for Schedule F reporting, reinsurer authorization by line, and collateral requirement calculations.',
    `policy_id` BIGINT COMMENT 'Reference to the underlying policy whose risk is being ceded under this facultative agreement.',
    `producers_producer_id` BIGINT COMMENT 'Foreign key linking to producers.producers_producer. Business justification: Facultative certificates are often placed by individual producers who negotiate coverage with reinsurers.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to coverage.quote. Business justification: Facultative underwriting evaluates quote terms (limits, deductibles, pricing) before issuing certificates. Reinsurers review quote details to price fac participation.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.reinsurer. Business justification: fac_agreement has reinsurer_party_id pointing to generic party table, but also needs FK to specialized reinsurer master for reinsurer-specific attributes (ratings, authorization status',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the parent reinsurance agreement record under which this facultative placement is administered.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Facultative reinsurance is placed on specific high-value or unusual individual risks. Underwriters submit detailed risk characteristics to reinsurers for facultative quotes.',
    `submission_id` BIGINT COMMENT 'Reference to the underwriting submission associated with this FAC placement, used when the FAC is placed prior to policy binding.',
    `uw_decision_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_decision. Business justification: Facultative reinsurers require underwriting decision context (risk tier, referral reasons, conditions, decline rationale) to assess participation and price fac certificates.',
    `uw_referral_id` BIGINT COMMENT 'Foreign key linking to coverage.uw_referral. Business justification: High-risk submissions triggering underwriting referrals often require facultative reinsurance.',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the FAC agreement. Tracks progression from offer through binding, active coverage, and termination.. Valid values are `draft|bound|active|expired|cancelled|declined`',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized/accredited in the cedants state of domicile. Affects Schedule F credit and collateral requirements.',
    `bound_date` DATE COMMENT 'Date on which the reinsurer formally bound coverage under this facultative agreement, confirming acceptance of the ceded risk.',
    `broker_commission_rate` DECIMAL(7,4) COMMENT 'Percentage of ceded premium payable to the reinsurance broker as intermediary commission for placing this FAC agreement.',
    `cancellation_date` DATE COMMENT 'Date on which the facultative agreement was cancelled, if applicable. Null for agreements that run to natural expiry.',
    `ceded_limit_amount` DECIMAL(18,2) COMMENT 'Maximum dollar amount of loss the reinsurer will pay under this FAC agreement. Represents the reinsurers liability cap for the placement.',
    `ceded_percentage` DECIMAL(7,4) COMMENT 'Percentage of the original risk ceded to the reinsurer under this FAC agreement, expressed as a decimal (e.g., 0.5000 = 50%). Applies to pro-rata placements.',
    `ceded_premium_amount` DECIMAL(18,2) COMMENT 'Dollar amount of premium ceded to the reinsurer under this FAC agreement. Reduces net written premium (NWP) for the cedant.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Dollar amount of ceding commission receivable from the reinsurer. Calculated as ceded premium multiplied by the ceding commission rate.',
    `ceding_commission_rate` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to the cedant by the reinsurer as a ceding commission to offset acquisition and administrative costs.',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Dollar amount of collateral posted by the reinsurer (letter of credit or trust) to secure obligations under this FAC agreement.',
    `collateral_required_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is required to post collateral (letter of credit or trust fund) due to unauthorized status under NAIC credit for reinsurance rules.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this FAC agreement record was first created in the reinsurance management system. Used for audit trail and data lineage.',
    `expiry_date` DATE COMMENT 'Date on which the facultative reinsurance coverage expires. Typically co-terminus with the underlying policy expiration date.',
    `fac_certificate_number` STRING COMMENT 'Certificate number issued by the reinsurer confirming acceptance of the facultative placement. Used for claims recovery and bordereaux reconciliation.',
    `fac_premium_rate` DECIMAL(10,6) COMMENT 'Rate applied to the ceded limit or TIV to derive the FAC reinsurance premium. Expressed as a decimal (e.g., 0.005000 = 0.50%). Also known as Rate on Line (ROL) for XOL placements.',
    `fac_reference_number` STRING COMMENT 'Externally-known business identifier assigned to this FAC placement, used in bordereaux reporting and reinsurer correspondence. Unique per placement.',
    `fac_type` STRING COMMENT 'Structural type of the facultative placement: pro-rata (quota share basis) or excess of loss. Determines how premium and losses are shared.. Valid values are `pro_rata|excess_of_loss`',
    `gross_written_premium` DECIMAL(18,2) COMMENT 'Total gross written premium on the underlying policy before cession. Basis for calculating the ceded reinsurance premium.',
    `inception_date` DATE COMMENT 'Date on which the facultative reinsurance coverage becomes effective. Must align with or precede the underlying policy effective date.',
    `loss_participation_rate` DECIMAL(7,4) COMMENT 'Percentage of losses the cedant participates in alongside the reinsurer under profit-sharing or loss-sensitive FAC structures.',
    `original_insured_tiv` DECIMAL(18,2) COMMENT 'Total Insured Value of the underlying risk at the time of FAC placement. Used to calculate ceded exposure and Rate on Line (ROL).',
    `placement_basis` STRING COMMENT 'Basis on which the FAC agreement responds: risks attaching (policies incepting during the period) or losses occurring (losses during the period).. Valid values are `risks_attaching|losses_occurring`',
    `reinstatement_premium_rate` DECIMAL(7,4) COMMENT 'Rate applied to the original FAC premium to calculate the reinstatement premium payable when the ceded limit is reinstated after a loss.',
    `reinstatement_provision` BOOLEAN COMMENT 'Indicates whether the FAC agreement includes a reinstatement provision allowing the ceded limit to be restored after a loss, typically for XOL placements.',
    `reinsurer_share_percentage` DECIMAL(7,4) COMMENT 'Percentage of the FAC placement accepted by this specific reinsurer. Relevant when a single FAC risk is placed with multiple reinsurers (co-reinsurance).',
    `reinsurer_underwriter_name` STRING COMMENT 'Name of the underwriter at the assuming reinsurer who accepted and bound this FAC placement.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Dollar amount of loss retained by the cedant (Pc_Insurance) before the reinsurers liability attaches. Applies to excess-of-loss FAC placements.',
    `retrocession_flag` BOOLEAN COMMENT 'Indicates whether this FAC agreement is a retrocession (reinsurance of reinsurance), where the cedant is itself a reinsurer passing risk further.',
    `schedule_f_category` STRING COMMENT 'NAIC Schedule F classification of the reinsurer for statutory reporting: authorized, unauthorized, certified, or reciprocal jurisdiction reinsurer.. Valid values are `authorized|unauthorized|certified|reciprocal_jurisdiction`',
    `slip_reference` STRING COMMENT 'Market slip or cover note reference number associated with this FAC placement, used in London Market or broker-placed reinsurance transactions.',
    `special_conditions` STRING COMMENT 'Free-text description of any special terms, conditions, exclusions, or warranties specific to this facultative placement not captured in structured fields.',
    `underwriter_name` STRING COMMENT 'Name of the cedants underwriter responsible for placing and managing this facultative reinsurance agreement.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this FAC agreement record was last modified in the reinsurance management system. Supports audit trail and change tracking.',
    CONSTRAINT pk_fac_agreement PRIMARY KEY(`fac_agreement_id`)
) COMMENT 'Facultative reinsurance agreement covering a single risk or policy. One row per FAC placement. Captures cedant, reinsurer, ceded percentage, premium rate, inception/expiry, and the linked policy or submission.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` (
    `reinsurer_id` BIGINT COMMENT 'Unique surrogate identifier for each reinsurance counterparty record. Primary key of the reinsurer master table. One row per reinsurer entity.',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Reinsurer credit limits and collateral are currency-denominated; currency master provides exchange rates for credit monitoring, collateral adequacy assessment, and multi-currency reinsurer',
    `parent_reinsurer_id` BIGINT COMMENT 'Self-referencing identifier pointing to the parent reinsurer entity for group-level exposure aggregation, credit limit monitoring, and group Schedule F reporting.',
    `party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Reinsurer entities are parties requiring KYC, address, contact, and identifier management. Multiple reinsurance products already use reinsurer_party_id FK to party.party, but reinsurer table',
    `am_best_outlook` STRING COMMENT 'AM Best rating outlook indicating the likely direction of the reinsurers financial strength rating over the medium term. Informs counterparty risk monitoring.. Valid values are `stable|positive|negative|developing|under_review`',
    `am_best_rating` STRING COMMENT 'AM Best Financial Strength Rating (FSR) assigned to the reinsurer. Used in underwriting guidelines to validate counterparty credit quality and treaty eligibility thresholds.. Valid values are `^(A++|A+|A|A-|B++|B+|B|B-|C++|C+|C|C-|D|E|F|S|NR)$`',
    `am_best_rating_date` DATE COMMENT 'Date on which the current AM Best Financial Strength Rating was assigned or last affirmed. Used to assess rating currency and trigger counterparty review workflows.',
    `approval_date` DATE COMMENT 'Date on which the reinsurer was most recently approved by the internal credit committee for new cession activity. Supports counterparty governance audit trails.',
    `approval_expiry_date` DATE COMMENT 'Date on which the current internal approval for the reinsurer expires and must be renewed by the credit committee. Drives counterparty review scheduling.',
    `approved_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer has been formally approved by the cedants internal credit and counterparty risk committee for placement of new reinsurance agreements.',
    `authorization_status` STRING COMMENT 'Indicates whether the reinsurer is authorized, unauthorized, certified, or accredited in the cedants domicile state. Determines Schedule F credit for reinsurance and collateral obligations.. Valid values are `authorized|unauthorized|certified|accredited|reciprocal_jurisdiction`',
    `broker_intermediary_name` STRING COMMENT 'Name of the reinsurance broker or intermediary through which business is placed with this reinsurer. Used for commission tracking and intermediary credit risk assessment.',
    `reinsurer_code` STRING COMMENT 'Internal alphanumeric code assigned to uniquely identify the reinsurer within the Reinsurance Management System for bordereaux and cession processing.',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Total USD amount of collateral currently posted by the reinsurer. Used in Schedule F credit calculations and counterparty exposure monitoring.',
    `collateral_required_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is required to post collateral (letter of credit, trust fund, or funds withheld) to support Schedule F credit for unauthorized reinsurers.',
    `collateral_type` STRING COMMENT 'Type of collateral arrangement posted by the reinsurer to secure Schedule F credit. Applicable to unauthorized and certified reinsurers per NAIC Model Law #785.. Valid values are `letter_of_credit|trust_fund|funds_withheld|cash_deposit|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the reinsurer master record was first created in the system. Supports audit trail, data lineage, and SOX compliance requirements.',
    `credit_limit_amount` DECIMAL(18,2) COMMENT 'Maximum aggregate ceded exposure (in USD) approved for this reinsurer by the internal credit committee. Enforced at cession booking to prevent counterparty concentration breaches.',
    `domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction where the reinsurer is legally domiciled. Used for Schedule F foreign reinsurer classification and credit determination.. Valid values are `^[A-Z]{3}$`',
    `domicile_state` STRING COMMENT 'Two-letter US state or territory code where the reinsurer is domiciled, if a domestic entity. Used for state-level authorization and credit for reinsurance analysis.. Valid values are `^[A-Z]{2}$`',
    `federal_excise_tax_exempt_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is exempt from US Federal Excise Tax on reinsurance premiums under a tax treaty or qualified jurisdiction status per IRC Section 4371.',
    `fein` STRING COMMENT 'IRS-assigned Federal Employer Identification Number (FEIN) for the reinsurer entity. Used for tax reporting, 1099 issuance, and AP payment processing.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `group_name` STRING COMMENT 'Name of the reinsurance group or holding company to which this reinsurer belongs. Used for group-level credit exposure aggregation and counterparty concentration risk.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal counterparty credit review conducted by the cedants reinsurance credit committee. Supports ORSA and governance audit requirements.',
    `lloyds_syndicate_number` STRING COMMENT 'Four-digit Lloyds of London syndicate number. Populated only when reinsurer_type is lloyds_syndicate. Required for Lloyds-specific bordereaux and premium trust fund reporting.. Valid values are `^[0-9]{4}$`',
    `minimum_am_best_rating` STRING COMMENT 'Minimum AM Best Financial Strength Rating required by internal policy for this reinsurer to remain eligible for new cessions. Triggers review if current rating falls below threshold.',
    `moodys_rating` STRING COMMENT 'Moodys Investors Service insurance financial strength rating for the reinsurer. Used as a tertiary credit quality indicator in counterparty risk frameworks.',
    `naic_code` STRING COMMENT 'Five-digit NAIC company code assigned to the reinsurer. Required for NAIC Schedule F statutory reporting and credit for reinsurance determinations.. Valid values are `^[0-9]{5}$`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal counterparty credit review. Drives workflow alerts in the Reinsurance Management System to ensure timely governance compliance.',
    `notes` STRING COMMENT 'Free-text field for underwriting, credit, or operational notes about the reinsurer, such as special collateral arrangements, run-off status details, or relationship history.',
    `pool_name` STRING COMMENT 'Name of the reinsurance pool or facility when the reinsurer participates as a pool member. Used for pool-level aggregation in bordereaux and Schedule F reporting.',
    `reinsurer_status` STRING COMMENT 'Current operational status of the reinsurer in the cedants system. Controls eligibility for new cessions and triggers collection escalation for run-off or insolvent counterparties.. Valid values are `active|inactive|suspended|run_off|insolvent`',
    `reinsurer_type` STRING COMMENT 'Classification of the reinsurer entity structure. Drives Schedule F credit treatment and collateral requirements. [ENUM-REF-CANDIDATE: assuming_company|lloyds_syndicate|pool|captive|government|other — promote to reference product]. Valid values are `assuming_company|lloyds_syndicate|pool|captive|government|other`',
    `relationship_inception_date` DATE COMMENT 'Date on which the cedant first entered into a reinsurance agreement with this counterparty. Used for relationship tenure analysis and counterparty history reporting.',
    `retrocession_flag` BOOLEAN COMMENT 'Indicates whether this reinsurer also acts as a retrocessionaire, accepting ceded risk from other reinsurers. Used to identify retrocession (RETRO) relationships in the reinsurance chain.',
    `schedule_f_category` STRING COMMENT 'NAIC Schedule F reporting category for this reinsurer. Determines the statutory credit treatment, penalty charges, and collateral requirements in the Annual Statement.. Valid values are `authorized|unauthorized_with_collateral|unauthorized_without_collateral|certified|accredited|reciprocal_jurisdiction`',
    `short_name` STRING COMMENT 'Abbreviated or commonly used trading name of the reinsurer used in bordereaux reports, internal systems, and operational communications.',
    `sp_rating` STRING COMMENT 'S&P Global Ratings financial strength rating for the reinsurer. Supplementary credit quality indicator used alongside AM Best for counterparty risk assessment.',
    `tax_withholding_rate` DECIMAL(5,4) COMMENT 'Federal excise tax or withholding rate applicable to premium payments to this reinsurer, expressed as a decimal (e.g., 0.01 = 1%). Applies to foreign unauthorized reinsurers per IRC Section 4371.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the reinsurer master record was most recently modified. Used for change data capture, audit trails, and data quality monitoring in the Silver layer.',
    CONSTRAINT pk_reinsurer PRIMARY KEY(`reinsurer_id`)
) COMMENT 'Master record for each reinsurance counterparty (assuming company, Lloyds syndicate, or pool). One row per reinsurer. Stores legal name, NAIC code, AM Best rating, domicile, and authorized/unauthorized status for Schedule F credit.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` (
    `ri_participant_id` BIGINT COMMENT 'Unique surrogate identifier for a reinsurers participation record within a treaty or facultative agreement. One row per reinsurer per agreement.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.reinsurer. Business justification: ri_participant has reinsurer_party_id but also extensive denormalized reinsurer attributes.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the parent reinsurance agreement (treaty or facultative) under which this participation is recorded.',
    `ri_party_id` BIGINT COMMENT 'Reference to the reinsurance intermediary (broker) who placed this participants line. Used for broker commission settlement and bordereaux routing.',
    `ri_reinsurer_party_id` BIGINT COMMENT 'Reference to the Party record representing the reinsurer entity participating in this agreement.',
    `account_current_basis` STRING COMMENT 'Basis on which the account current (bordereaux) is prepared for this participant: written premium basis, earned premium basis, or cash basis.. Valid values are `written|earned|cash`',
    `agreement_type` STRING COMMENT 'Type of reinsurance agreement: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), Catastrophe XL (CAT XL), or Facultative (FAC). Determines cession and recovery mechanics.. Valid values are `treaty_qs|treaty_xol|treaty_sl|treaty_cat_xl|facultative`',
    `brokerage_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium payable to the reinsurance broker for placing this participants line. Applied to the participants share of written premium.',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of ceded premium returned to the cedant by this reinsurer as a ceding commission, covering acquisition and overhead costs. Applicable primarily to QS treaties.',
    `cession_share_pct` DECIMAL(7,4) COMMENT 'Effective share of each cession allocated to this participant, derived from signed line and order hereon. Used to compute this reinsurers portion of premium and loss.',
    `commutation_amount` DECIMAL(18,2) COMMENT 'Lump-sum amount agreed upon in the commutation to settle all outstanding reserves and future obligations for this reinsurers participation share.',
    `commutation_date` DATE COMMENT 'Date on which the commutation agreement was executed, extinguishing all future obligations between the cedant and this reinsurer under this participation.',
    `commutation_flag` BOOLEAN COMMENT 'Indicates whether this participation has been commuted, meaning all outstanding obligations have been settled by a lump-sum payment and the agreement extinguished.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which premiums, losses, and settlements with this reinsurer are denominated (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `cut_through_clause_flag` BOOLEAN COMMENT 'Indicates whether a cut-through endorsement exists allowing the cedants policyholders to claim directly against this reinsurer in the event of the cedants insolvency.',
    `effective_date` DATE COMMENT 'Date on which the reinsurers participation in the agreement becomes binding and cessions may be allocated to this participant.',
    `expiration_date` DATE COMMENT 'Date on which the reinsurers participation ends. Null for open-ended participations. Used to determine in-force panel at any given date.',
    `funds_withheld_flag` BOOLEAN COMMENT 'Indicates whether the cedant withholds ceded premium from this reinsurer under a funds-withheld arrangement, used as collateral for unauthorized reinsurers.',
    `insolvency_clause_flag` BOOLEAN COMMENT 'Indicates whether the standard insolvency clause is included, requiring the reinsurer to pay claims even if the cedant becomes insolvent, per NAIC model law requirements.',
    `lc_amount` DECIMAL(18,2) COMMENT 'Dollar amount of the letter of credit posted by this reinsurer as collateral. Required for Schedule F credit for reinsurance calculations for unauthorized reinsurers.',
    `lc_required_flag` BOOLEAN COMMENT 'Indicates whether this reinsurer is required to post a letter of credit as collateral for credit for reinsurance purposes under state regulation.',
    `offset_clause_flag` BOOLEAN COMMENT 'Indicates whether the participation agreement includes an offset clause allowing mutual debts between cedant and reinsurer to be netted in settlement.',
    `order_hereon_pct` DECIMAL(7,4) COMMENT 'The cedants order percentage representing the total share of risk placed with the reinsurance market. Used to scale signed and written lines to the actual ceded amount.',
    `participant_reference_number` STRING COMMENT 'Externally-known unique identifier assigned by the reinsurance management system to this participation line, used in bordereaux and Schedule F reporting.',
    `participant_status` STRING COMMENT 'Current lifecycle state of the reinsurers participation in the agreement. Controls whether cessions and recoveries can be posted against this participant.. Valid values are `active|inactive|pending|terminated|suspended`',
    `participation_type` STRING COMMENT 'Classifies the reinsurers role in the panel: leader sets terms, followers subscribe, sole reinsurer takes 100%. Drives bordereaux and settlement logic.. Valid values are `leader|follower|sole_reinsurer|co_reinsurer|retrocessionaire`',
    `placement_date` DATE COMMENT 'Date on which the reinsurers line was formally placed and agreed, which may precede the participation effective date. Used for audit trail and contract management.',
    `profit_commission_pct` DECIMAL(7,4) COMMENT 'Percentage of underwriting profit returned to the cedant by this reinsurer under a profit commission clause. Calculated after losses and expenses against this participants share.',
    `retrocession_flag` BOOLEAN COMMENT 'Indicates whether this participation is part of a retrocession arrangement where the reinsurer is itself ceding risk onward to a retrocessionaire.',
    `rol_pct` DECIMAL(7,4) COMMENT 'Rate on Line expressed as a percentage of the limit, representing the reinsurance premium as a proportion of the coverage limit for this participants share. Key XOL pricing metric.',
    `settlement_frequency` STRING COMMENT 'Frequency at which premium and loss accounts are settled between the cedant and this reinsurer. Drives bordereaux generation and cash settlement scheduling.. Valid values are `monthly|quarterly|semi_annual|annual|as_agreed`',
    `signed_line_pct` DECIMAL(7,4) COMMENT 'The percentage of the agreements risk that the reinsurer has formally signed and committed to. Signed lines across all participants must sum to 100% for a fully placed agreement.',
    `signing_date` DATE COMMENT 'Date on which the reinsurer formally signed the slip or contract, confirming their committed signed line percentage. Distinct from placement date.',
    `source_system_code` STRING COMMENT 'Identifier of the originating reinsurance management system record (e.g., Sapiens ReinsurancePro participant ID) for lineage and reconciliation purposes.',
    `termination_date` DATE COMMENT 'Date on which the reinsurers participation was terminated prior to the scheduled expiration date, such as due to insolvency, commutation, or mutual agreement.',
    `termination_reason` STRING COMMENT 'Reason code for early termination of the reinsurers participation. Used in commutation accounting and Schedule F disclosures.. Valid values are `commutation|insolvency|mutual_agreement|regulatory|non_renewal`',
    `trust_fund_amount` DECIMAL(18,2) COMMENT 'Amount held in a reinsurance trust fund by this reinsurer as an alternative collateral mechanism for credit for reinsurance under NAIC model law.',
    `written_line_pct` DECIMAL(7,4) COMMENT 'The percentage of the agreement initially offered to and accepted by the reinsurer before signing-down. May differ from signed line when the placement is oversubscribed.',
    CONSTRAINT pk_ri_participant PRIMARY KEY(`ri_participant_id`)
) COMMENT 'Allocation of a reinsurers share within a treaty or FAC agreement. One row per reinsurer per agreement. Captures signed line percentage, written line percentage, and participation effective dates.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` (
    `reinsurance_cession_id` BIGINT COMMENT 'Unique surrogate identifier for each cession record. One row per policy term per treaty layer or facultative agreement. Primary key of the cession table.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the catastrophe event associated with this cession when is_catastrophe_cession is true. Links to the catastrophe event for PML and AAL aggregation.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Cessions must identify the triggering peril for treaty allocation, bordereaux reporting, Schedule F classification, and reinsurer accounting.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this cession is booked for statutory and GAAP financial reporting purposes.',
    `coverage_id` BIGINT COMMENT 'Foreign key linking to coverage.coverage. Business justification: Cessions record the actual transfer of risk to reinsurers. Premium and claim cessions must trace to the specific coverage being ceded for accurate bordereaux reporting, treaty allocation',
    `currency_id` BIGINT COMMENT 'Foreign key linking to shared.currency. Business justification: Cession accounting requires currency master for exchange rate application, multi-currency premium and loss aggregation, and statutory reporting in reporting currency.',
    `fac_agreement_id` BIGINT COMMENT 'Reference to the facultative reinsurance agreement if this is a FAC cession. Null for treaty cessions.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Cession accounting and bordereaux submission require LOB master for consistent line classification, treaty applicability rules, and regulatory reporting.',
    `policy_term_id` BIGINT COMMENT 'Reference to the policy term being ceded. Links the cession to the specific time-bounded policy period in force at the time of cession.',
    `premium_transaction_id` BIGINT COMMENT 'Foreign key linking to premium.premium_transaction. Business justification: Each cession records the reinsurance share of a specific gross premium transaction.',
    `reinsurer_party_id` BIGINT COMMENT 'Reference to the reinsurer party accepting this cession. Supports multi-reinsurer panels where each reinsurer has a separate cession row.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the parent reinsurance agreement (treaty or facultative) under which this cession is placed.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: Cessions represent the actual transfer of specific risk exposure to reinsurers. Exposure management and catastrophe modeling require linking cessions to underlying insured risks to',
    `treaty_layer_id` BIGINT COMMENT 'Reference to the specific treaty layer (e.g., first excess layer, second excess layer) within the reinsurance agreement to which this cession attaches.',
    `accident_year` BIGINT COMMENT 'Accident Year (AY) associated with losses ceded under this cession. Used for loss development triangles and IBNR reserving on ceded basis.',
    `agreement_type` STRING COMMENT 'Classifies the cession as treaty-based (automatic, per agreed terms) or facultative (individually negotiated per risk).. Valid values are `treaty|facultative`',
    `attachment_point` DECIMAL(18,2) COMMENT 'Dollar threshold at which the reinsurers liability begins under an XOL or CAT XL treaty. Equivalent to the cedants retention for excess layers.',
    `booking_date` DATE COMMENT 'Date on which this cession was recorded in the Reinsurance Management System and booked to the general ledger for statutory reporting.',
    `bordereaux_period` STRING COMMENT 'Reporting period (YYYY-MM or YYYY-Q#) for which this cession is included in the reinsurance bordereaux submission to the reinsurer.. Valid values are `^[0-9]{4}-(Q[1-4]|[0-9]{2})$`',
    `ceded_case_reserve` DECIMAL(18,2) COMMENT 'Reinsurers share of the case reserve for known reported losses ceded under this cession. Used for ceded reserve reporting on Schedule F.',
    `ceded_earned_premium` DECIMAL(18,2) COMMENT 'Portion of the ceded premium that has been earned as of the reporting date, based on the pro-rata exposure period elapsed.',
    `ceded_gwp` DECIMAL(18,2) COMMENT 'Gross Written Premium (GWP) ceded to the reinsurer for this policy term. Represents the cedants cost of reinsurance before ceding commission.',
    `ceded_ibnr_reserve` DECIMAL(18,2) COMMENT 'Reinsurers share of the IBNR reserve for losses incurred but not yet reported under this cession. Required for ceded IBNR disclosure on Schedule F.',
    `ceded_limit` DECIMAL(18,2) COMMENT 'Maximum reinsurer liability under this cession. For XOL treaties, this is the layer limit; for QS, it is the proportional share of the policy limit.',
    `ceded_tiv` DECIMAL(18,2) COMMENT 'Total Insured Value (TIV) transferred to the reinsurer under this cession. Represents the gross exposure ceded for property lines.',
    `ceded_unearned_premium` DECIMAL(18,2) COMMENT 'Portion of the ceded premium not yet earned as of the reporting date. Represents the reinsurers liability for the unexpired risk period.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Commission paid by the reinsurer to the cedant to offset acquisition and administrative costs. Reduces the net cost of reinsurance.',
    `ceding_commission_pct` DECIMAL(7,4) COMMENT 'Ceding commission expressed as a percentage of ceded written premium. Used to calculate the ceding commission amount for QS treaties.',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Amount of collateral (letters of credit, trust funds) posted by an unauthorized reinsurer to secure their obligations under this cession.',
    `collateral_type` STRING COMMENT 'Type of collateral instrument posted by the reinsurer to secure obligations. Required for unauthorized reinsurers per NAIC credit for reinsurance rules.. Valid values are `letter_of_credit|trust_fund|cash|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this cession record was first created in the Reinsurance Management System. Used for audit trail and data lineage.',
    `direction` STRING COMMENT 'Indicates whether this is an outward cession (cedant to reinsurer) or a retrocession (reinsurer ceding further). Distinguishes primary cession from retro.. Valid values are `outward|retrocession`',
    `effective_date` DATE COMMENT 'Date on which this cession becomes effective and the reinsurer assumes the ceded risk. Aligns with the policy term effective date for automatic treaty cessions.',
    `exhaustion_point` DECIMAL(18,2) COMMENT 'Dollar amount at which the reinsurers layer is fully exhausted (attachment point plus ceded limit). Defines the upper boundary of the reinsurers liability.',
    `expiration_date` DATE COMMENT 'Date on which the cession expires and the reinsurers liability ceases. Typically aligns with the policy term expiration date.',
    `funds_held_amount` DECIMAL(18,2) COMMENT 'Amount of reinsurance premium held by the cedant as funds held under the reinsurance agreement, rather than remitted to the reinsurer.',
    `is_catastrophe_cession` BOOLEAN COMMENT 'Indicates whether this cession is associated with a catastrophe event (CAT XL treaty). Flags cessions for CAT PML aggregation and catastrophe bordereaux reporting.',
    `number` STRING COMMENT 'Externally-known business identifier for this cession, used in bordereaux reporting and reinsurer correspondence. Assigned by the Reinsurance Management System.',
    `policy_year` BIGINT COMMENT 'Policy Year (PY) in which the ceded policy term incepted. Used for actuarial loss development, Schedule P, and reinsurance year-of-account reporting.',
    `rate_on_line` DECIMAL(7,4) COMMENT 'Rate on Line (ROL) expressed as a percentage of the ceded limit. Key pricing metric for XOL and CAT XL layers; equals ceded premium divided by ceded limit.',
    `reinsurance_cession_status` STRING COMMENT 'Current lifecycle state of the cession record within the reinsurance management workflow.. Valid values are `active|pending|cancelled|expired|suspended`',
    `reinsurer_authorization_status` STRING COMMENT 'NAIC authorization classification of the assuming reinsurer: authorized, accredited, certified, unauthorized, or reciprocal. Drives collateral and credit requirements.. Valid values are `authorized|accredited|certified|unauthorized|reciprocal`',
    `reinsurer_domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the reinsurers domicile. Determines whether the reinsurer is authorized, accredited, or unauthorized under NAIC Schedule F.. Valid values are `^[A-Z]{3}$`',
    `reinsurer_naic_code` STRING COMMENT 'Five-digit NAIC company code of the assuming reinsurer. Required for NAIC Schedule F statutory reporting and reinsurer credit risk assessment.. Valid values are `^[0-9]{5}$`',
    `retention_amount` DECIMAL(18,2) COMMENT 'Amount retained by the cedant (Self-Insured Retention / SIR) before the reinsurers liability attaches. Attachment point for XOL; retained share for QS.',
    `share_pct` DECIMAL(7,4) COMMENT 'Proportional share (as a percentage) ceded to the reinsurer. Applicable for Quota Share treaties. For XOL, this represents the reinsurers participation percentage in the layer.',
    `source_system_code` STRING COMMENT 'Identifier of the originating Reinsurance Management System record (e.g., Sapiens ReinsurancePro cession ID or SICS record key) for traceability and reconciliation.',
    `treaty_type` STRING COMMENT 'Type of reinsurance treaty structure: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), or Catastrophe Excess of Loss (CAT XL). Null for FAC cessions.. Valid values are `quota_share|excess_of_loss|stop_loss|cat_xl`',
    `ultimate_net_loss` DECIMAL(18,2) COMMENT 'Ultimate Net Loss (UNL) ceded under this cession, representing the reinsurers share of total incurred losses including LAE. Key metric for XOL treaty performance.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this cession record. Used for change tracking and incremental data pipeline processing.',
    CONSTRAINT pk_reinsurance_cession PRIMARY KEY(`reinsurance_cession_id`)
) COMMENT 'Records risk transfer of a policy term to a treaty layer or FAC. Grain: one row per policy term per treaty layer (or FAC). Direction flag (outward/retro) distinguishes cession from retrocession.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` (
    `ri_premium_transaction_id` BIGINT COMMENT 'Unique surrogate key for each reinsurance ceded premium financial movement. One row per written, earned, unearned, return, or reinstatement transaction for a cession. TRANSACTION_HEADER role.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period (month/quarter/year) in which this reinsurance premium transaction is booked for statutory and GAAP financial reporting purposes.',
    `fac_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_agreement. Business justification: Premium transactions can be for facultative placements in addition to treaty layers. Currently has treaty_layer_id. Adding optional fac_agreement_id for FAC premium transactions.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Premium transactions must classify by line for GL coding, treaty allocation, and statutory accounting; LOB master provides chart of accounts mappings and ensures consistent line',
    `original_transaction_id` BIGINT COMMENT 'For reversal or correction transactions, references the ri_premium_transaction_id of the original entry being reversed. Null for original transactions. Supports audit trail and net balance reconciliation.',
    `policy_id` BIGINT COMMENT 'Reference to the underlying direct policy whose premium is being ceded. Required for facultative cessions and policy-level bordereaux reporting under Schedule F.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term period for which ceded premium is being transacted. Enables reconstruction of in-force ceded premium at any historical date.',
    `premium_transaction_id` BIGINT COMMENT 'Foreign key linking to premium.premium_transaction. Business justification: Reinsurance premium transactions must trace to the originating gross premium transaction for reconciliation, bordereaux preparation, ceded/net premium calculation, and regulatory',
    `reinsurance_cession_id` BIGINT COMMENT 'Reference to the reinsurance cession record that this premium transaction belongs to. Links the financial movement to the specific risk ceded under a treaty or facultative agreement.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer party record (assuming entity in the party domain) to whom the premium is ceded. Required for Schedule F counterparty-level reporting.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which this premium transaction is recorded. Supports bordereaux reporting and treaty-level premium aggregation.',
    `treaty_layer_id` BIGINT COMMENT 'Reference to the specific treaty layer (e.g., first excess, second excess) within a multi-layer XOL or CAT XL program to which this ceded premium is allocated.',
    `accident_year` BIGINT COMMENT 'The calendar year in which losses covered by this ceded premium are expected to occur. Used for accident year (AY) loss development triangles and actuarial reserving analysis.',
    `accounting_date` DATE COMMENT 'The date on which this transaction is recognized in the general ledger and statutory accounts. May differ from transaction_date due to period-end cut-off adjustments.',
    `agreement_type` STRING COMMENT 'The structural type of the reinsurance agreement: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), Catastrophe Excess of Loss (CAT XL), or Surplus Share.. Valid values are `Quota Share|Excess of Loss|Stop Loss|CAT XL|Surplus Share`',
    `bordereaux_period` STRING COMMENT 'The YYYY-MM period for which this transaction is included in the reinsurance bordereaux submission to the reinsurer. Format: YYYY-MM. Drives bordereaux extract and reinsurer statement reconciliation.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `bordereaux_status` STRING COMMENT 'Tracks the submission lifecycle of this transaction in the reinsurance bordereaux process. Acknowledged by reinsurer confirms premium settlement; Disputed triggers reconciliation workflow.. Valid values are `Pending|Submitted|Acknowledged|Disputed|Settled`',
    `ceded_earned_premium` DECIMAL(18,2) COMMENT 'The pro-rata portion of ceded written premium recognized as earned during the accounting period. Used for ceded loss ratio and earned premium calculations in Schedule P and Schedule F.',
    `ceded_unearned_premium` DECIMAL(18,2) COMMENT 'The portion of ceded written premium not yet earned as of the accounting date. Represents the reinsurers liability for the unexpired policy period. Required for NAIC Annual Statement balance sheet.',
    `ceded_written_premium` DECIMAL(18,2) COMMENT 'The portion of written premium transferred to the reinsurer under this cession. For QS treaties, equals GWP multiplied by the cession percentage. Core field for NWP and DPW calculations.',
    `ceding_commission` DECIMAL(18,2) COMMENT 'Commission paid by the reinsurer to the cedant to offset acquisition and administrative costs. Expressed as a flat amount per transaction. Reduces the net cost of reinsurance.',
    `ceding_commission_rate` DECIMAL(7,4) COMMENT 'The rate applied to ceded written premium to calculate the ceding commission (e.g., 0.2500 = 25%). Used for sliding-scale commission calculations under profit-sharing treaties.',
    `cession_percentage` DECIMAL(7,4) COMMENT 'The percentage of the underlying risk ceded to the reinsurer under a quota share or surplus share treaty (e.g., 0.3000 = 30%). Null for XOL treaties where cession is event-triggered.',
    `cession_type` STRING COMMENT 'Indicates whether the ceded premium relates to a treaty arrangement, a facultative (FAC) placement, or a retrocession. Drives bordereaux format and Schedule F classification.. Valid values are `Treaty|Facultative|Retrocession`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reinsurance premium transaction record was first created in the reinsurance management system (Sapiens ReinsurancePro or SICS).',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this transaction (e.g., USD, GBP, EUR). Required for multi-currency reinsurance programs and foreign reinsurer reporting.. Valid values are `^[A-Z]{3}$`',
    `exchange_rate` DECIMAL(18,6) COMMENT 'Exchange rate used to convert foreign currency amounts to the cedants functional reporting currency (USD). Applied as of the accounting_date for statutory reporting purposes.',
    `gl_account_code` STRING COMMENT 'The general ledger account code to which this reinsurance premium transaction is posted in the statutory accounting system (Oracle/SAP GL). Required for Schedule F and NAIC Annual Statement mapping.',
    `gross_written_premium` DECIMAL(18,2) COMMENT 'The total direct written premium on the underlying policy before any reinsurance cession. Base for calculating the ceded share under quota share or facultative agreements.',
    `occurrence_reference_code` BIGINT COMMENT 'Reference to the loss occurrence or catastrophe event that triggered a reinstatement premium. Populated only for transaction_type = Reinstatement. Links to the loss event record.',
    `policy_effective_date` DATE COMMENT 'The date the underlying direct policy became effective. Used to assign the ceded premium to the correct policy year (PY) for actuarial and Schedule P/F reporting.',
    `policy_expiration_date` DATE COMMENT 'The date the underlying direct policy expires. Used to calculate the unearned premium period and pro-rata earning of ceded premium over the policy term.',
    `policy_year` BIGINT COMMENT 'The year in which the underlying policy was written. Used for policy year (PY) experience analysis and reinsurance program performance monitoring per NAIC Schedule F.',
    `profit_commission` DECIMAL(18,2) COMMENT 'Contingent commission earned by the cedant when the reinsurers loss ratio on the treaty falls below a specified threshold. Booked as a reduction in net reinsurance cost.',
    `rate_on_line` DECIMAL(7,4) COMMENT 'The reinsurance premium expressed as a percentage of the treaty limit (ROL = premium / limit). Key pricing metric for XOL and CAT XL treaties used in actuarial and underwriting analysis.',
    `reinstated_limit` DECIMAL(18,2) COMMENT 'The amount of treaty limit reinstated following a loss occurrence, for which the reinstatement_premium is charged. Applicable only when transaction_type = Reinstatement.',
    `reinstatement_premium` DECIMAL(18,2) COMMENT 'Additional premium paid to the reinsurer to reinstate exhausted treaty limit following a loss occurrence. Applicable to XOL and CAT XL treaties. Linked to occurrence_reference_id.',
    `reporting_currency_amount` DECIMAL(18,2) COMMENT 'Ceded written premium converted to the cedants statutory reporting currency (USD) using the exchange_rate. Used for NAIC Annual Statement and Schedule F USD-denominated filings.',
    `return_premium` DECIMAL(18,2) COMMENT 'Premium returned to the cedant from the reinsurer due to policy cancellation, mid-term endorsement reducing exposure, or audit adjustment. Negative impact on ceded written premium.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this transaction is a reversal of a previously posted reinsurance premium entry. True = reversal transaction. Used for audit trail and net premium reconciliation.',
    `risk_effective_date` DATE COMMENT 'The date from which the reinsurers coverage obligation begins for this cession. May differ from policy_effective_date for mid-term facultative placements or endorsements.',
    `risk_expiration_date` DATE COMMENT 'The date on which the reinsurers coverage obligation ends for this cession. Used to determine the ceded unearned premium reserve at any balance sheet date.',
    `source_system_code` STRING COMMENT 'Identifies the operational system that originated this reinsurance premium transaction (e.g., SICS, Sapiens ReinsurancePro, manual entry). Used for data lineage and reconciliation.. Valid values are `SICS|ReinsurancePro|Manual|PAS|BillingCenter`',
    `transaction_date` DATE COMMENT 'The business event date on which this premium movement occurred (e.g., policy effective date for written, pro-rata date for earned, cancellation date for return).',
    `transaction_number` STRING COMMENT 'Externally visible business identifier for this reinsurance premium transaction, used in bordereaux submissions, reinsurer statements, and Schedule F regulatory filings.',
    `transaction_status` STRING COMMENT 'Current workflow state of the premium transaction in the reinsurance management system. Posted transactions are included in bordereaux and statutory filings.. Valid values are `Draft|Pending|Posted|Reversed|Voided`',
    `transaction_type` STRING COMMENT 'Classification of the premium movement: Written (new cession), Earned (pro-rata recognition), Unearned (reserve release), Return (cancellation/endorsement), or Reinstatement (post-loss premium).. Valid values are `Written|Earned|Unearned|Return|Reinstatement`',
    `treaty_year` BIGINT COMMENT 'The underwriting year of the reinsurance treaty under which this premium is ceded (e.g., 2024). Used for treaty-year loss ratio monitoring and bordereaux aggregation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this reinsurance premium transaction record. Used for audit trail and incremental data pipeline processing.',
    CONSTRAINT pk_ri_premium_transaction PRIMARY KEY(`ri_premium_transaction_id`)
) COMMENT 'Ceded premium ledger. One row per financial movement (written, earned, unearned, return, reinstatement) for a cession. FK to cession, accounting period, treaty layer. Reinstatement rows carry occurrence reference and reinstated limit.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` (
    `ri_claim_cession_id` BIGINT COMMENT 'Unique surrogate primary key for the reinsurance claim cession record. One row per claim exposure per treaty layer or facultative agreement.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the catastrophe event record if this claim cession is associated with a CAT event, enabling CAT XL treaty aggregation and PML tracking.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Claim cessions require peril identification for treaty layer matching, coverage verification, and reinsurer reporting.',
    `claim_exposure_id` BIGINT COMMENT 'Reference to the claim exposure (coverage line within a claim) being ceded to the reinsurer. Links the cession to the specific coverage and insured risk.',
    `claim_id` BIGINT COMMENT 'Reference to the parent claim record associated with this cession, enabling claim-level reinsurance aggregation and bordereaux reporting.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which this cession is recognized for statutory and GAAP financial reporting purposes.',
    `fac_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_agreement. Business justification: Claim cessions can be to facultative agreements in addition to treaty layers. Description states Links a claim exposure to a reinsurance treaty layer or FAC agreement. Currently',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Claim cessions aggregate by line for treaty layer attachment, bordereaux reporting, and Schedule P reconciliation; LOB master ensures consistent classification across claims and',
    `reinsurer_id` BIGINT COMMENT 'FK to reinsurance.reinsurer',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which this claim cession is made.',
    `riskexposure_insured_risk_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_risk. Business justification: When ceding claim recoveries, reinsurers require detailed risk characteristics (TIV, construction type, occupancy, protection class, year built) to validate coverage applicability',
    `treaty_layer_id` BIGINT COMMENT 'Reference to the specific treaty layer (e.g., first XOL layer, second XOL layer) within the reinsurance agreement applicable to this cession.',
    `accident_year` BIGINT COMMENT 'Calendar year in which the loss event occurred. Used for actuarial loss triangle development and reinsurance recovery analysis by accident year.',
    `bordereaux_period` STRING COMMENT 'Reporting period (e.g., 2024-Q1 or 2024-M03) for which this cession is included in the reinsurance bordereaux submission to the reinsurer.. Valid values are `^[0-9]{4}-(Q[1-4]|M(0[1-9]|1[0-2]))$`',
    `bordereaux_submission_date` DATE COMMENT 'Date on which this cession record was included in a bordereaux submission to the reinsurer for loss recovery billing.',
    `cat_event_code` STRING COMMENT 'Industry-standard catastrophe event code (e.g., ISO PCS serial number) identifying the CAT event for aggregation under CAT XL treaty layers.',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Allocated Loss Adjustment Expense (ALAE) component of the ceded LAE, representing defense and cost containment (DCC) expenses ceded to the reinsurer.',
    `ceded_lae_amount` DECIMAL(18,2) COMMENT 'The portion of Loss Adjustment Expense (LAE) ceded to the reinsurer, including ALAE and applicable ULAE, per the treaty terms.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'The portion of the gross incurred loss ceded to the reinsurer under this agreement layer. Core financial metric for reinsurance recovery eligibility.',
    `ceded_paid_loss_amount` DECIMAL(18,2) COMMENT 'Cumulative loss payments already recovered from or billed to the reinsurer under this cession as of the reporting date.',
    `ceded_reserve_amount` DECIMAL(18,2) COMMENT 'Outstanding case reserve amount ceded to the reinsurer for this claim exposure, representing the reinsurers share of unpaid losses.',
    `cession_effective_date` DATE COMMENT 'Date on which this claim cession becomes effective under the reinsurance agreement, typically aligned with the loss date or treaty inception.',
    `cession_number` STRING COMMENT 'Externally-known business identifier for this claim cession, used in bordereaux reporting and reinsurer correspondence. Assigned by the reinsurance management system.',
    `cession_percentage` DECIMAL(7,4) COMMENT 'Proportional cession percentage applied to the gross loss for quota share treaties (e.g., 0.7500 = 75%). Null for non-proportional XOL structures.',
    `cession_status` STRING COMMENT 'Current lifecycle state of the claim cession record within the reinsurance recovery workflow.. Valid values are `pending|active|settled|disputed|withdrawn|closed`',
    `cession_type` STRING COMMENT 'Indicates whether the cession is under a treaty arrangement, a facultative (FAC) agreement, or a retrocession.. Valid values are `treaty|facultative|retrocession`',
    `commutation_date` DATE COMMENT 'Date on which the commutation agreement was executed for this cession, if applicable. Null when commutation_flag is false.',
    `commutation_flag` BOOLEAN COMMENT 'Indicates whether this cession has been subject to a commutation agreement with the reinsurer, settling all future obligations in a lump sum.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reinsurance claim cession record was first created in the reinsurance management system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this cession record (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `dispute_reason` STRING COMMENT 'Description of the reason for a reinsurer dispute on this cession, if applicable. Populated when recovery_status is disputed.',
    `funds_held_amount` DECIMAL(18,2) COMMENT 'Amount of funds held by the cedant on behalf of the reinsurer as collateral or per treaty terms, reported on Schedule F.',
    `gross_loss_amount` DECIMAL(18,2) COMMENT 'Total gross (pre-reinsurance) incurred loss amount for the claim exposure, including paid losses and outstanding reserves before any cession.',
    `is_cat_claim` BOOLEAN COMMENT 'Indicates whether this claim cession is associated with a declared catastrophe event, triggering CAT XL treaty layer eligibility review.',
    `layer_limit_amount` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery available under this treaty layer for the ceded claim exposure. Defines the per-occurrence or per-risk limit.',
    `layer_retention_amount` DECIMAL(18,2) COMMENT 'The cedants retained loss amount at the applicable treaty layer before reinsurance recovery applies. Represents the SIR or attachment point retention.',
    `loss_date` DATE COMMENT 'Date of the underlying loss event that triggered the claim, used to determine which treaty year and layer applies for cession eligibility.',
    `policy_year` BIGINT COMMENT 'Year in which the policy that generated the ceded claim was written, used for policy-year loss development and reinsurance program analysis.',
    `recovery_billed_date` DATE COMMENT 'Date on which the reinsurance recovery was formally billed to the reinsurer for this claim cession.',
    `recovery_received_date` DATE COMMENT 'Date on which payment was received from the reinsurer for this cession, used for cash flow and Schedule F counterparty aging analysis.',
    `recovery_status` STRING COMMENT 'Current status of the reinsurance recovery billing and collection process for this cession. Tracks progress from billing through settlement.. Valid values are `not_billed|billed|partially_recovered|fully_recovered|disputed|written_off`',
    `reinsurance_type` STRING COMMENT 'Classification of the reinsurance structure: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), CAT XL, or facultative variants. [ENUM-REF-CANDIDATE: quota_share|excess_of_loss|stop_loss|cat_xl|facultative_proportional|facultative_non_proportional —. Valid values are `quota_share|excess_of_loss|stop_loss|cat_xl|facultative_proportional|facultative_non_proportional`',
    `reinsurer_participation_pct` DECIMAL(7,4) COMMENT 'The reinsurers share of the treaty layer as a decimal (e.g., 0.5000 = 50%), used when multiple reinsurers participate in a single layer.',
    `report_date` DATE COMMENT 'Date the claim was reported to the cedant, used for claims-made policy cession eligibility and IBNR bordereaux reporting.',
    `rol_rate` DECIMAL(7,4) COMMENT 'Rate on Line (ROL) applicable to this treaty layer, expressed as a decimal. Used for pricing analysis and reinsurance cost allocation.',
    `schedule_f_category` STRING COMMENT 'NAIC Schedule F regulatory classification of the reinsurer for statutory reporting: authorized, unauthorized, certified, or other alien reinsurer.. Valid values are `authorized|unauthorized|certified|other_alien`',
    `treaty_year` BIGINT COMMENT 'The underwriting or treaty year (e.g., 2023) under which this cession falls, used for bordereaux aggregation and Schedule F reporting.',
    `unl_amount` DECIMAL(18,2) COMMENT 'Ultimate Net Loss (UNL) calculation basis for this cession, representing the net loss after salvage, subrogation, and other recoveries, used to determine XOL trigger.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this reinsurance claim cession record, supporting audit trail and data lineage requirements.',
    CONSTRAINT pk_ri_claim_cession PRIMARY KEY(`ri_claim_cession_id`)
) COMMENT 'Links a claim exposure to a reinsurance treaty layer or FAC agreement for loss recovery eligibility. One row per claim exposure per treaty layer. Stores ceded loss amount, ceded LAE, and UNL calculation basis.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` (
    `ri_recovery_id` BIGINT COMMENT 'Unique identifier for each reinsurance recovery financial movement. Primary key. Grain: one row per movement per cession per accounting period.',
    `bordereaux_id` BIGINT COMMENT 'Identifier of the bordereaux batch in which this recovery was reported to the reinsurer (for treaty business).',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key to the catastrophe event, if this recovery is related to a catastrophic loss.',
    `claim_exposure_id` BIGINT COMMENT 'Foreign key to the underlying claim exposure that generated this ceded loss and recovery.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period in which this recovery movement was recorded.',
    `fac_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_agreement. Business justification: Recoveries can be from facultative agreements in addition to treaty layers. Currently has reinsurance_agreement_id but no specific FAC reference.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Recoveries are analyzed by line for treaty performance monitoring and reinsurer credit evaluation; LOB master provides loss ratio targets and combined ratio benchmarks for performance',
    `reinsurer_id` BIGINT COMMENT 'Foreign key to the reinsurer party responsible for this recovery.',
    `ri_agreement_id` BIGINT COMMENT 'Foreign key to the reinsurance agreement (treaty or facultative) under which this recovery is claimed.',
    `ri_claim_cession_id` BIGINT COMMENT 'Foreign key to the reinsurance claim cession that this recovery movement applies to.',
    `accident_year` BIGINT COMMENT 'The accident year of the underlying loss for which this recovery is claimed.',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) whether the reinsurer is authorized or accredited in the ceding companys domiciliary state for statutory credit purposes.',
    `billed_date` DATE COMMENT 'The date on which the recovery was billed to the reinsurer via bordereaux or facultative certificate.',
    `bordereaux_submission_date` DATE COMMENT 'The date on which the bordereaux containing this recovery was submitted to the reinsurer.',
    `calendar_year` BIGINT COMMENT 'The calendar year in which this recovery movement was recorded.',
    `cat_code` STRING COMMENT 'Industry-standard catastrophe code (e.g., PCS number) identifying the catastrophic event.',
    `ceded_share_percentage` DECIMAL(5,2) COMMENT 'The percentage of the underlying loss that is ceded to the reinsurer under the agreement (e.g., 50.00 for 50% quota share).',
    `collateral_required_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) whether collateral (e.g., letter of credit, trust account) is required from the reinsurer for statutory credit.',
    `collected_amount` DECIMAL(18,2) COMMENT 'The actual cash amount collected from the reinsurer, which may differ from the billed recovery amount due to disputes or adjustments.',
    `collected_date` DATE COMMENT 'The date on which cash payment was received from the reinsurer for this recovery.',
    `commutation_date` DATE COMMENT 'The date on which the reinsurance agreement was commuted, if applicable.',
    `commutation_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) whether this recovery is part of a commutation (final settlement) of the reinsurance agreement.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this recovery record was first created in the reinsurance management system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the recovery amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `dispute_date` DATE COMMENT 'The date on which the reinsurer formally disputed this recovery.',
    `dispute_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) whether this recovery is currently in dispute with the reinsurer.',
    `dispute_reason` STRING COMMENT 'Free-text description of the reason for dispute, if applicable (e.g., coverage interpretation, late notice, policy exclusion).',
    `exchange_rate` DECIMAL(12,6) COMMENT 'The exchange rate applied to convert the recovery amount from policy currency to USD.',
    `facultative_certificate_number` STRING COMMENT 'The certificate number for facultative reinsurance agreements, if applicable.',
    `movement_date` DATE COMMENT 'The business date on which this recovery movement was recorded or effective.',
    `movement_type` STRING COMMENT 'Discriminator indicating the type of financial movement: reserve position (case/IBNR/LAE) or cash recovery (loss/LAE/DCC payment, subrogation, salvage). [ENUM-REF-CANDIDATE',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this recovery movement, including adjustments, disputes, or special handling instructions.',
    `outstanding_amount` DECIMAL(18,2) COMMENT 'The amount of recovery still outstanding (billed but not yet collected) from the reinsurer.',
    `payment_type` STRING COMMENT 'Type of payment for cash movements: loss (indemnity), LAE (loss adjustment expense), DCC (defense and cost containment), subrogation, salvage.. Valid values are `loss|lae|dcc|subrogation|salvage`',
    `policy_year` BIGINT COMMENT 'The policy year of the underlying policy for which this recovery is claimed.',
    `recovery_amount` DECIMAL(18,2) COMMENT 'The gross amount of reinsurance recovery for this movement, in the policy currency. Positive for recoveries due from reinsurer, negative for adjustments or reversals.',
    `recovery_amount_usd` DECIMAL(18,2) COMMENT 'The recovery amount converted to USD for statutory and consolidated reporting purposes.',
    `recovery_status` STRING COMMENT 'Current status of the recovery: pending (not yet billed), billed (invoice sent), collected (cash received), disputed, written off, or reversed.. Valid values are `pending|billed|collected|disputed|written_off|reversed`',
    `reinstatement_premium_amount` DECIMAL(18,2) COMMENT 'The amount of reinstatement premium payable to the reinsurer to restore coverage after a loss recovery.',
    `reinstatement_premium_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) whether a reinstatement premium is due to the reinsurer as a result of this recovery.',
    `reserve_type` STRING COMMENT 'Type of reserve for reserve movements: case (reported loss), IBNR (incurred but not reported), LAE (loss adjustment expense), ULAE (unallocated LAE), ALAE (allocated LAE).. Valid values are `case|ibnr|lae|ulae|alae`',
    `transaction_timestamp` TIMESTAMP COMMENT 'The precise timestamp when this recovery transaction was posted to the reinsurance ledger.',
    `treaty_year` BIGINT COMMENT 'The treaty year (underwriting year) to which this recovery applies, for treaty accounting and reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this recovery record was last modified.',
    CONSTRAINT pk_ri_recovery PRIMARY KEY(`ri_recovery_id`)
) COMMENT 'Single ceded loss ledger. Grain: one row per movement per ri_claim_cession per accounting period, discriminated by movement_type: case/IBNR/LAE reserve position, or cash recovery (loss/LAE/DCC, subrogation, salvage).';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` (
    `bordereaux_id` BIGINT COMMENT 'Unique identifier for the bordereaux submission record. Primary key.',
    `bordereaux_broker_party_id` BIGINT COMMENT 'Reference to the reinsurance broker party facilitating this bordereaux submission, if applicable.',
    `bordereaux_party_id` BIGINT COMMENT 'Reference to the ceding company party submitting this bordereaux.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period this bordereaux submission is associated with for financial reporting.',
    `fac_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_agreement. Business justification: Bordereaux submissions can cover facultative business in addition to treaty business. Currently only has treaty_id.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Bordereaux submissions report premium and loss by line; LOB master provides treaty applicability rules and regulatory line definitions required for reinsurer acceptance and statutory',
    `prior_bordereaux_id` BIGINT COMMENT 'Reference to the previous bordereaux submission this amendment replaces, if applicable.',
    `reinsurer_id` BIGINT COMMENT 'Reference to the reinsurer party receiving this bordereaux submission.',
    `ri_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.ri_agreement. Business justification: Bordereaux should have direct reference to the master reinsurance agreement. Currently navigates via treaty, but with addition of fac_agreement_id, direct ri_agreement_id provides',
    `treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty this bordereaux submission covers.',
    `accepted_date` DATE COMMENT 'Date the bordereaux submission was accepted by the reinsurer.',
    `amendment_number` BIGINT COMMENT 'Sequential number indicating how many times this bordereaux has been amended. Zero for original submission.',
    `approved_by_user_code` STRING COMMENT 'Identifier of the user who approved this bordereaux submission for transmission to the reinsurer.',
    `bordereaux_status` STRING COMMENT 'Current status of the bordereaux submission in its lifecycle.. Valid values are `draft|submitted|accepted|rejected|amended|finalized`',
    `bordereaux_type` STRING COMMENT 'Type of bordereaux submission: premium bordereaux, loss bordereaux, combined, statistical, exposure, or claim detail.. Valid values are `premium|loss|combined|statistical|exposure|claim_detail`',
    `ceded_alae_amount` DECIMAL(18,2) COMMENT 'Total ceded allocated loss adjustment expense amount reported in this bordereaux for the reporting period.',
    `ceded_earned_premium_amount` DECIMAL(18,2) COMMENT 'Total ceded earned premium amount reported in this bordereaux for the reporting period.',
    `ceded_ibnr_amount` DECIMAL(18,2) COMMENT 'Total ceded incurred but not reported reserve amount reported in this bordereaux as of the reporting period end date.',
    `ceded_lae_amount` DECIMAL(18,2) COMMENT 'Total ceded loss adjustment expense amount reported in this bordereaux for the reporting period.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Total ceded loss amount reported in this bordereaux for the reporting period, including paid and outstanding reserves.',
    `ceded_outstanding_loss_reserve_amount` DECIMAL(18,2) COMMENT 'Total ceded outstanding loss reserve amount reported in this bordereaux as of the reporting period end date.',
    `ceded_paid_loss_amount` DECIMAL(18,2) COMMENT 'Total ceded paid loss amount reported in this bordereaux for the reporting period.',
    `ceded_ulae_amount` DECIMAL(18,2) COMMENT 'Total ceded unallocated loss adjustment expense amount reported in this bordereaux for the reporting period.',
    `ceded_unearned_premium_amount` DECIMAL(18,2) COMMENT 'Total ceded unearned premium amount reported in this bordereaux as of the reporting period end date.',
    `ceded_written_premium_amount` DECIMAL(18,2) COMMENT 'Total ceded written premium amount reported in this bordereaux for the reporting period.',
    `claim_count` BIGINT COMMENT 'Number of claims included in this bordereaux submission for the reporting period.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Total ceding commission amount calculated for this bordereaux submission.',
    `commission_rate` DECIMAL(5,4) COMMENT 'Ceding commission rate applied to ceded premium in this bordereaux, expressed as a decimal.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this bordereaux submission.. Valid values are `^[A-Z]{3}$`',
    `due_date` DATE COMMENT 'Date by which the bordereaux submission is contractually due to the reinsurer per treaty terms.',
    `finalized_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux submission was finalized and locked from further changes.',
    `loss_ratio` DECIMAL(5,4) COMMENT 'Calculated loss ratio for this bordereaux period, expressed as a decimal.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux record was last modified in the system.',
    `net_balance_due_amount` DECIMAL(18,2) COMMENT 'Net amount due to or from the reinsurer based on this bordereaux submission, after offsetting premium and loss amounts.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this bordereaux submission.',
    `number` STRING COMMENT 'Business identifier for the bordereaux submission, typically assigned by the ceding company or reinsurer.',
    `policy_count` BIGINT COMMENT 'Number of policies included in this bordereaux submission for the reporting period.',
    `prepared_by_user_code` STRING COMMENT 'Identifier of the user who prepared this bordereaux submission.',
    `profit_commission_amount` DECIMAL(18,2) COMMENT 'Profit commission amount earned by the cedent based on favorable loss experience, if applicable.',
    `rejected_date` DATE COMMENT 'Date the bordereaux submission was rejected by the reinsurer, if applicable.',
    `rejection_reason` STRING COMMENT 'Reason provided by the reinsurer for rejecting the bordereaux submission, if applicable.',
    `reporting_period_end_date` DATE COMMENT 'End date of the period covered by this bordereaux submission.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the period covered by this bordereaux submission.',
    `submission_date` DATE COMMENT 'Date the bordereaux was submitted to the reinsurer.',
    `submission_format` STRING COMMENT 'Data format used for the bordereaux submission. [ENUM-REF-CANDIDATE: acord|proprietary|excel|csv|xml|json|pdf — 7 candidates stripped; promote to reference product]',
    `submission_method` STRING COMMENT 'Method used to submit the bordereaux to the reinsurer.. Valid values are `electronic|paper|email|portal|api|edi`',
    CONSTRAINT pk_bordereaux PRIMARY KEY(`bordereaux_id`)
) COMMENT 'Periodic bordereau submission record sent to reinsurers summarizing ceded premium and loss activity. One row per bordereaux run per treaty per reporting period. Captures submission date, period, status, and totals.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` (
    `reinsurance_bordereaux_line_id` BIGINT COMMENT 'Unique surrogate primary key for one bordereaux line item representing a single cession or claim cession within a bordereaux submission run. Grain: one row per cession per bordereaux.',
    `bordereaux_id` BIGINT COMMENT 'Foreign key reference to the parent bordereaux submission run that this line belongs to. Links the line to its batch/run header.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the catastrophe event associated with this claim-cession line. Used for CAT XL treaty aggregation and PML/AAL reporting.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Bordereaux lines report per-peril ceded premium and losses for treaty reconciliation, reinsurer accounting, and profit commission calculations.',
    `claim_id` BIGINT COMMENT 'Reference to the claim for claim-cession bordereaux lines. Null for premium-only cession lines. Links to the Claim entity in the claims domain.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period (calendar year/quarter/month) to which this bordereaux line is attributed for statutory and GAAP reporting.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Bordereaux reporting aggregates cessions by line for statutory filings; LOB master provides NAIC/ISO mappings and regulatory line definitions required for Schedule P and Schedule F',
    `policy_id` BIGINT COMMENT 'Reference to the ceded policy. Enables linkage from the bordereaux line back to the full policy lifecycle in the policy domain.',
    `premium_transaction_id` BIGINT COMMENT 'Foreign key linking to premium.premium_transaction. Business justification: Bordereaux lines report individual cessions to reinsurers with transaction-level detail.',
    `reinsurance_cession_id` BIGINT COMMENT 'Reference to the underlying cession record that this bordereaux line represents. Links to the Cession entity in the reinsurance domain.',
    `reinsurer_party_id` BIGINT COMMENT 'Reference to the reinsurer party record. Identifies the specific reinsurance counterparty receiving this cession for credit risk and Schedule F counterparty reporting.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which this cession is reported.',
    `agreement_number` STRING COMMENT 'Human-readable external identifier of the reinsurance treaty or facultative agreement under which this cession is reported. Used in bordereaux submissions to reinsurers.',
    `agreement_type` STRING COMMENT 'Indicates whether the cession is under a treaty (automatic) or facultative (individually negotiated) reinsurance agreement.. Valid values are `TREATY|FACULTATIVE`',
    `attachment_point` DECIMAL(18,2) COMMENT 'The loss threshold at which the XOL or CAT XL reinsurance layer attaches for this cession. Losses below this amount are retained by the cedant.',
    `bordereaux_line_type` STRING COMMENT 'Classifies the nature of this bordereaux line: premium cession, claim cession, adjustment, return premium, or reinstatement. Drives financial processing logic.. Valid values are `PREMIUM_CESSION|CLAIM_CESSION|ADJUSTMENT|RETURN_PREMIUM|REINSTATEMENT`',
    `catastrophe_code` STRING COMMENT 'Industry or internal catastrophe event code (e.g., PCS event number) associated with this cession line. Denormalized for bordereaux reporting and CAT XL aggregation.',
    `ceded_earned_premium` DECIMAL(18,2) COMMENT 'The portion of earned premium ceded to the reinsurer for the reporting period. Used for loss ratio calculations and IFRS 17 insurance revenue reporting.',
    `ceded_ibnr_reserve` DECIMAL(18,2) COMMENT 'Reinsurers share of IBNR reserves allocated to this cession line. Used in actuarial reserving and Schedule F statutory reporting.',
    `ceded_lae_paid` DECIMAL(18,2) COMMENT 'Loss Adjustment Expense (LAE) paid by the reinsurer under this cession line. Includes ALAE and ULAE components ceded per agreement terms.',
    `ceded_lae_reserve` DECIMAL(18,2) COMMENT 'Outstanding LAE reserve amount ceded to the reinsurer for this line. Represents the reinsurers share of unpaid loss adjustment expenses.',
    `ceded_loss_paid` DECIMAL(18,2) COMMENT 'Losses paid by the reinsurer under this cession line to date. Represents actual cash recoveries received from the reinsurer for indemnity payments.',
    `ceded_loss_reserve` DECIMAL(18,2) COMMENT 'Outstanding case reserve amount ceded to the reinsurer for this line. Represents the reinsurers share of unpaid loss reserves (OSLR/RBNS).',
    `ceded_unearned_premium` DECIMAL(18,2) COMMENT 'The unearned portion of ceded written premium as of the reporting date. Represents the reinsurers liability for unexpired risk. Used in balance sheet reserving.',
    `ceded_written_premium` DECIMAL(18,2) COMMENT 'The portion of written premium ceded to the reinsurer under this agreement for this line. Key metric for Schedule F and bordereaux reporting. Expressed in reporting currency.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Commission paid by the reinsurer to the cedant on ceded premium for this line. Offsets acquisition costs. Applicable to quota share and surplus treaties.',
    `ceding_commission_rate` DECIMAL(7,4) COMMENT 'The contractual rate applied to ceded premium to compute the ceding commission (e.g., 0.2500 = 25%). Defined in the reinsurance agreement terms.',
    `cession_percentage` DECIMAL(7,4) COMMENT 'The percentage of the risk ceded to the reinsurer under this agreement line (e.g., 0.3000 = 30%). Applicable primarily to quota share treaties.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux line record was first created in the data platform. Supports audit trail and data lineage requirements per SOX and MAR.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this bordereaux line (e.g., USD, GBP, EUR). Supports multi-currency reinsurance agreements.. Valid values are `^[A-Z]{3}$`',
    `exchange_rate` DECIMAL(18,6) COMMENT 'Foreign exchange rate used to convert cession amounts to the reporting currency. Applicable when the ceded policy is denominated in a currency other than USD.',
    `gross_written_premium` DECIMAL(18,2) COMMENT 'Total gross written premium on the ceded policy for the cession period before reinsurance. Basis for computing ceded written premium. Expressed in reporting currency.',
    `insured_name` STRING COMMENT 'Name of the insured party on the ceded policy as reported on the bordereaux. Required by reinsurers for risk identification and facultative certificate matching.',
    `is_retrocession` BOOLEAN COMMENT 'Indicates whether this cession line represents a retrocession (cession of assumed reinsurance) rather than a direct cession. True = retrocession; False = direct cession.',
    `line_sequence_number` BIGINT COMMENT 'Sequential line number of this record within the parent bordereaux run. Used for ordering, reconciliation, and error identification during bordereaux processing.',
    `line_status` STRING COMMENT 'Current processing status of this bordereaux line in the reinsurer settlement workflow. Tracks lifecycle from draft through acceptance or dispute resolution.. Valid values are `DRAFT|SUBMITTED|ACCEPTED|DISPUTED|SETTLED|VOIDED`',
    `loss_date` DATE COMMENT 'Date of the insured loss event for claim-cession lines. Used to determine treaty year applicability (accident year basis) and XOL layer attachment. Null for premium lines.',
    `policy_effective_date` DATE COMMENT 'The date the ceded policy term became effective. Used to determine the applicable treaty year and cession period for bordereaux allocation.',
    `policy_expiration_date` DATE COMMENT 'The date the ceded policy term expires. Used with effective date to compute the cession period and pro-rata premium calculations.',
    `rate_on_line` DECIMAL(7,4) COMMENT 'Rate on Line (ROL) expressed as a decimal — the ratio of reinsurance premium to the reinsurers limit. Key pricing metric for XOL and CAT XL treaties.',
    `reinsurer_limit` DECIMAL(18,2) COMMENT 'Maximum amount the reinsurer is liable to pay above the attachment point for this cession line. Defines the XOL layer limit (e.g., $5M xs $1M).',
    `reinsurer_share_percentage` DECIMAL(7,4) COMMENT 'The specific reinsurers participation percentage in the reinsurance agreement for this line (e.g., 0.5000 = 50% of a 100% placed treaty layer).',
    `report_date` DATE COMMENT 'Date the claim was first reported (FNOL date) for claim-cession lines. Used for IBNR analysis and claims-made policy trigger determination.',
    `reporting_period_end_date` DATE COMMENT 'End date of the reporting period covered by this bordereaux line. Together with start date defines the bordereaux reporting window.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the reporting period covered by this bordereaux line. Defines the window for premium and loss movements included in this submission.',
    `retention_amount` DECIMAL(18,2) COMMENT 'The cedants net retained loss amount for this cession line after reinsurance recovery. For XOL treaties, this is the SIR/retention layer below the attachment point.',
    `source_system_reference` STRING COMMENT 'The originating systems unique identifier for this bordereaux line record (e.g., Sapiens ReinsurancePro internal line ID). Supports data lineage and reconciliation.',
    `treaty_type` STRING COMMENT 'Specific treaty structure: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), Catastrophe Excess of Loss (CAT XL), or Surplus. Determines cession calculation method.. Valid values are `QUOTA_SHARE|EXCESS_OF_LOSS|STOP_LOSS|CAT_XL|SURPLUS`',
    `treaty_year` BIGINT COMMENT 'The underwriting or accident year of the reinsurance treaty applicable to this cession line. Used for treaty-year loss development and Schedule F segmentation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this bordereaux line record was last modified. Used for incremental data processing, change detection, and audit trail compliance.',
    CONSTRAINT pk_reinsurance_bordereaux_line PRIMARY KEY(`reinsurance_bordereaux_line_id`)
) COMMENT 'Individual line item within a bordereaux submission, representing one cession or claim cession. One row per cession per bordereaux. Stores ceded premium, ceded loss, ceded LAE, and policy/claim reference keys. Belongs to a parent bordereaux run.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` (
    `ri_reinstatement_id` BIGINT COMMENT 'Unique surrogate primary key for each treaty layer reinstatement event. One row per reinstatement event per treaty layer occurrence.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: Reinstatements are triggered by specific catastrophe events exhausting layer limits.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Reinstatements are peril-specific (e.g., hurricane layer exhaustion triggers hurricane reinstatement premium).',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period in which the reinstatement premium is booked for statutory and GAAP financial reporting.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Reinstatement premium calculations are line-specific; LOB master provides rate-on-line benchmarks and treaty term applicability by line for accurate premium computation and treaty',
    `reinsurance_cession_id` BIGINT COMMENT 'Reference to the cession record associated with the loss occurrence that triggered this reinstatement, linking ceded exposure to the reinstated layer.',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.reinsurer. Business justification: Reinstatements track premium per reinsurer (reinsurer_share_pct, reinsurer_reinstatement_premium_amt). Should have FK to reinsurer master for reinsurer attributes.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the parent reinsurance agreement (contract) under which the treaty layer and this reinstatement event exist.',
    `treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty under which this reinstatement is triggered. Links to the Treaty master record.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty_layer. Business justification: Reinstatements occur at the layer level (when a layer limit is exhausted and reinstated). Currently has treaty_id, but reinstatements are layer-specific for XOL/CAT XL structures.',
    `bordereaux_period` STRING COMMENT 'Year-month (YYYY-MM) reporting period in which this reinstatement is included on the reinsurance bordereaux submitted to the reinsurer for reconciliation.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reinstatement record was first created in the Reinsurance Management System, used for audit trail and data lineage.',
    `dispute_reason` STRING COMMENT 'Free-text description of the reason for a disputed reinstatement status, capturing reinsurer objections or cedant counter-arguments for resolution tracking.',
    `due_date` DATE COMMENT 'Date by which the reinstatement premium must be paid to the reinsurer per the treaty credit terms, used for cash flow and delinquency tracking.',
    `effective_date` DATE COMMENT 'Date on which the reinstated treaty layer limit becomes effective and available for future losses, as agreed with the reinsurer.',
    `exhausted_limit_amt` DECIMAL(18,2) COMMENT 'The amount of the treaty layer limit that was exhausted by the triggering loss occurrence, forming the basis for calculating the reinstatement premium.',
    `expiration_date` DATE COMMENT 'Date on which the reinstated limit expires, typically aligned with the treaty year end or a specific occurrence-based expiry per treaty wording.',
    `gl_account_code` STRING COMMENT 'General Ledger account code to which the reinstatement premium expense is posted in the statutory and GAAP accounting systems for financial reporting.',
    `invoice_date` DATE COMMENT 'Date on which the reinstatement premium invoice or debit note was issued to the reinsurer for settlement.',
    `invoice_number` STRING COMMENT 'Invoice or debit note number issued to the reinsurer for the reinstatement premium, used for accounts payable reconciliation and bordereaux reporting.',
    `is_automatic` BOOLEAN COMMENT 'Indicates whether the reinstatement is triggered automatically upon layer exhaustion (true) or requires explicit reinsurer consent and notification (false).',
    `is_free_reinstatement` BOOLEAN COMMENT 'Indicates whether this reinstatement is provided at no additional premium cost per treaty wording (true = free reinstatement; false = premium-bearing reinstatement).',
    `layer_limit_amt` DECIMAL(18,2) COMMENT 'The original per-occurrence limit of the treaty layer being reinstated, expressed in the treaty currency. Represents the maximum ceded recovery per occurrence.',
    `max_reinstatements_allowed` BIGINT COMMENT 'Maximum number of reinstatements permitted under the treaty layer per treaty year as specified in the treaty wording, used to validate reinstatement_sequence.',
    `notes` STRING COMMENT 'Free-text operational notes or comments entered by the reinsurance analyst regarding special conditions, treaty wording interpretations, or settlement instructions.',
    `occurrence_date` DATE COMMENT 'Date of the loss occurrence that triggered the layer exhaustion and necessitated this reinstatement, used for accident year and treaty year attribution.',
    `occurrence_reference` STRING COMMENT 'External reference code or name for the loss occurrence that exhausted the layer (e.g., CAT event code, storm name, occurrence number per treaty wording).',
    `occurrence_reference_code` BIGINT COMMENT 'Reference to the loss occurrence or catastrophe event that exhausted the treaty layer and triggered this reinstatement.',
    `original_premium_basis_amt` DECIMAL(18,2) COMMENT 'The original treaty premium (annual deposit or minimum premium) used as the basis for computing the reinstatement premium under pro-rata-of-original-premium treaty structures.',
    `payment_date` DATE COMMENT 'Actual date on which the reinstatement premium was remitted to the reinsurer, used for cash settlement reconciliation and Schedule F reporting.',
    `payment_reference` STRING COMMENT 'Wire transfer, check, or settlement reference number confirming remittance of the reinstatement premium to the reinsurer.',
    `pro_rata_factor` DECIMAL(10,6) COMMENT 'Pro-rata time adjustment factor applied when the reinstatement is time-limited (e.g., reinstated limit covers only a partial treaty year), reducing the reinstatement premium accordingly.',
    `reinstated_limit_amt` DECIMAL(18,2) COMMENT 'The amount of treaty layer limit reinstated by this event. May equal the full layer limit or a partial amount if only partially exhausted or partially reinstated.',
    `reinstatement_number` STRING COMMENT 'Externally-known business identifier for this reinstatement event, assigned by the Reinsurance Management System for bordereaux and counterparty communication.',
    `reinstatement_premium_amt` DECIMAL(18,2) COMMENT 'Gross reinstatement premium payable to the reinsurer for restoring the exhausted layer limit, calculated as reinstated limit multiplied by the reinstatement premium rate.',
    `reinstatement_premium_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the reinstatement premium amount (e.g., USD, GBP, EUR), matching the treaty settlement currency.. Valid values are `^[A-Z]{3}$`',
    `reinstatement_premium_rate` DECIMAL(10,6) COMMENT 'Rate on Line (ROL) percentage applied to the reinstated limit to calculate the reinstatement premium due, as specified in the treaty wording (e.g., 100% pro-rata, 50%).',
    `reinstatement_sequence` BIGINT COMMENT 'Ordinal sequence of this reinstatement within the treaty layer for the treaty year (1st reinstatement, 2nd reinstatement, etc.), as defined in the treaty wording.',
    `reinstatement_status` STRING COMMENT 'Current workflow status of the reinstatement event, tracking progression from pending confirmation through premium invoicing and payment settlement.. Valid values are `pending|confirmed|invoiced|paid|cancelled|disputed`',
    `reinstatement_type` STRING COMMENT 'Classification of the reinstatement as automatic (triggered by loss), conditional (subject to reinsurer consent), free (no additional premium), or paid (premium-bearing).. Valid values are `automatic|conditional|free|paid`',
    `reinsurer_confirmation_ref` STRING COMMENT 'Reference number or acknowledgment code provided by the reinsurer confirming acceptance of the reinstatement, required for conditional reinstatements.',
    `reinsurer_reinstatement_premium_amt` DECIMAL(18,2) COMMENT 'Reinsurers proportional share of the reinstatement premium, derived from the gross reinstatement premium multiplied by the reinsurer share percentage.',
    `reinsurer_share_pct` DECIMAL(7,4) COMMENT 'Percentage share of the treaty layer held by the reinsurer (or lead reinsurer on a co-reinsurance panel), used to apportion the reinstated limit and reinstatement premium.',
    `retention_amt` DECIMAL(18,2) COMMENT 'The cedants retained loss amount (attachment point or SIR) below the reinstated treaty layer, confirming the layer structure at the time of reinstatement.',
    `source_system_code` STRING COMMENT 'Code identifying the operational source system from which this reinstatement record was ingested (e.g., SAPIENS_RI, SICS), supporting data lineage in the lakehouse.',
    `treaty_year` BIGINT COMMENT 'The underwriting or treaty year (e.g., 2024) to which this reinstatement belongs, used for Schedule F and bordereaux reporting by treaty year.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this reinstatement record, supporting audit trail requirements and change tracking for regulatory compliance.',
    CONSTRAINT pk_ri_reinstatement PRIMARY KEY(`ri_reinstatement_id`)
) COMMENT 'Records the reinstatement of treaty limit after a loss occurrence exhausts a layer. One row per reinstatement event per treaty layer. Captures reinstatement premium, reinstated limit, occurrence reference, and effective date.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` (
    `ri_settlement_id` BIGINT COMMENT 'Unique surrogate primary key for each reinsurance net cash settlement record between cedant and reinsurer per period.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the accounting period (calendar quarter or month) to which this settlement belongs for statutory and GAAP reporting.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Settlement reconciliation by line requires LOB master for consistent line classification across cedant and reinsurer accounting, treaty allocation rules, and regulatory reporting',
    `reinsurer_party_id` BIGINT COMMENT 'Reference to the party record identifying the reinsurer counterparty for this settlement.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement (treaty or facultative) under which this settlement is calculated.',
    `treaty_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty. Business justification: Settlements can be at treaty level in addition to agreement level. Currently only has reinsurance_agreement_id. Adding optional treaty_id for treaty-specific settlements.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty_layer. Business justification: Settlements can be at layer level for XOL/CAT XL treaties. Adding optional treaty_layer_id for layer-specific settlements. Populated when settlement is at specific layer level.',
    `adjustment_premium_amount` DECIMAL(18,2) COMMENT 'Premium adjustment amount resulting from audit or retrospective rating, representing the difference between deposit and final premium.',
    `agreement_type` STRING COMMENT 'Indicates whether the settlement relates to a treaty or facultative reinsurance agreement.. Valid values are `treaty|facultative`',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the settlement was formally approved by the authorized approver in the reinsurance management system.',
    `approved_by` STRING COMMENT 'Name or user identifier of the individual who approved this settlement, supporting SOX segregation of duties and audit trail.',
    `authorized_reinsurer_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer is authorized/accredited in the cedants state of domicile, affecting Schedule F credit for reinsurance.',
    `bordereaux_reference_number` STRING COMMENT 'Reference number of the bordereaux submission to the reinsurer that supports the cession and loss data underlying this settlement.',
    `ceded_premium_earned_amount` DECIMAL(18,2) COMMENT 'Portion of ceded written premium earned during the settlement period, used for loss ratio and profit commission calculations.',
    `ceded_premium_written_amount` DECIMAL(18,2) COMMENT 'Gross written premium ceded to the reinsurer for the settlement period, representing the cedants premium payable obligation.',
    `ceded_unearned_premium_amount` DECIMAL(18,2) COMMENT 'Unearned portion of ceded written premium as of the settlement period end, representing the reinsurers liability for unexpired risk.',
    `ceding_commission_amount` DECIMAL(18,2) COMMENT 'Commission paid by the reinsurer to the cedant as a percentage of ceded premium, offsetting the cedants acquisition and overhead costs.',
    `cession_share_percent` DECIMAL(7,4) COMMENT 'Percentage of risk ceded to this reinsurer under a quota share or surplus share treaty, expressed as a decimal (e.g., 0.3000 = 30%).',
    `collateral_held_amount` DECIMAL(18,2) COMMENT 'Amount of collateral (letters of credit, trust funds) held by the cedant from an unauthorized reinsurer to support Schedule F credit.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this settlement record was first created in the reinsurance management system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this settlement record (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `deposit_premium_amount` DECIMAL(18,2) COMMENT 'Provisional deposit premium paid to the reinsurer at inception, subject to adjustment at final audit based on actual subject premium.',
    `dispute_reason` STRING COMMENT 'Free-text description of the reason for a disputed settlement, capturing the nature of the disagreement between cedant and reinsurer.',
    `dispute_resolution_date` DATE COMMENT 'Date on which a disputed settlement was formally resolved and agreed between the cedant and reinsurer.',
    `due_date` DATE COMMENT 'Contractual date by which the net settlement payment must be remitted per the reinsurance agreement terms.',
    `funds_withheld_amount` DECIMAL(18,2) COMMENT 'Amount of ceded premium withheld by the cedant as collateral under a funds-withheld reinsurance arrangement, reducing the cash settlement.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which the net settlement amount is posted in the statutory and GAAP accounting systems.',
    `interest_on_funds_withheld_amount` DECIMAL(18,2) COMMENT 'Interest credited to the reinsurer on funds withheld by the cedant, per the contractual interest rate in the reinsurance agreement.',
    `lae_recoverable_amount` DECIMAL(18,2) COMMENT 'Allocated and unallocated loss adjustment expenses (ALAE/ULAE) recoverable from the reinsurer under the agreement terms.',
    `loss_recoverable_amount` DECIMAL(18,2) COMMENT 'Total loss amounts recoverable from the reinsurer for paid and outstanding claims within the settlement period.',
    `net_settlement_amount` DECIMAL(18,2) COMMENT 'Net cash amount due after offsetting ceded premium payable against loss recoverable, commissions, and profit commission. Positive = cedant owes reinsurer.',
    `paid_date` DATE COMMENT 'Actual date on which the net settlement cash was remitted or received, used for cash flow and overdue tracking.',
    `profit_commission_amount` DECIMAL(18,2) COMMENT 'Profit commission payable to the cedant based on the reinsurers profitability on the ceded book, per sliding-scale or fixed formula.',
    `profit_commission_loss_ratio` DECIMAL(7,4) COMMENT 'Ceded loss ratio used as the input to the profit commission sliding-scale formula, expressed as a decimal (e.g., 0.5500 = 55%).',
    `profit_commission_rate` DECIMAL(7,4) COMMENT 'Sliding-scale or fixed commission rate applied to the reinsurers profit to derive the profit commission amount, expressed as a decimal.',
    `rate_on_line` DECIMAL(7,4) COMMENT 'Rate on Line expressed as a decimal, representing the reinsurance premium as a proportion of the reinsurance limit, used for XOL pricing analysis.',
    `reinstatement_premium_amount` DECIMAL(18,2) COMMENT 'Additional premium charged to reinstate exhausted reinsurance limits after a loss occurrence, per XOL or CAT XL agreement terms.',
    `reinsurer_domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the reinsurers domicile, used for Schedule F alien reinsurer classification and collateral requirements.. Valid values are `^[A-Z]{3}$`',
    `reinsurer_naic_code` STRING COMMENT 'Five-digit NAIC company code for the reinsurer, required for Schedule F statutory reporting and regulatory identification.. Valid values are `^[0-9]{5}$`',
    `settlement_date` DATE COMMENT 'The principal business event date on which the net cash settlement was agreed and funds were due between cedant and reinsurer.',
    `settlement_direction` STRING COMMENT 'Indicates whether the net settlement amount is payable by the cedant to the reinsurer or receivable by the cedant from the reinsurer.. Valid values are `payable_to_reinsurer|receivable_from_reinsurer`',
    `settlement_notes` STRING COMMENT 'Free-text notes capturing any special terms, adjustments, or commentary relevant to this settlement for operational and audit purposes.',
    `settlement_number` STRING COMMENT 'Externally-known business identifier for this settlement, used in bordereaux reporting and reinsurer correspondence.. Valid values are `^RI-SETL-[0-9]{4}-[0-9]{6}$`',
    `settlement_period_end_date` DATE COMMENT 'Last day of the period covered by this settlement, defining the close of the bordereaux reporting window.',
    `settlement_period_start_date` DATE COMMENT 'First day of the period covered by this settlement, used to align ceded premium and loss recoverable to the correct bordereaux period.',
    `settlement_status` STRING COMMENT 'Current lifecycle state of the settlement record from draft through final settlement or dispute resolution.. Valid values are `draft|pending_approval|approved|settled|disputed|voided`',
    `settlement_type` STRING COMMENT 'Classifies the settlement as periodic cash call, final close-out, commutation, profit commission, or reinstatement premium settlement.. Valid values are `periodic|final|commutation|profit_commission|reinstatement_premium`',
    `subject_premium_amount` DECIMAL(18,2) COMMENT 'Gross net written premium of the cedants book subject to the reinsurance agreement, used as the base for ceded premium and ROL calculations.',
    `treaty_type` STRING COMMENT 'Type of reinsurance treaty structure: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), Catastrophe XL (CAT XL), or Surplus Share.. Valid values are `quota_share|excess_of_loss|stop_loss|cat_xl|surplus_share`',
    `ultimate_net_loss_amount` DECIMAL(18,2) COMMENT 'Ultimate Net Loss as defined in the reinsurance agreement, representing the cedants retained loss after all recoveries, used for XOL trigger evaluation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this settlement record, supporting audit trail requirements.',
    CONSTRAINT pk_ri_settlement PRIMARY KEY(`ri_settlement_id`)
) COMMENT 'Net cash settlement between cedant and reinsurer, per reinsurer per period, netting ceded premium payable against loss recoverable. Includes profit commission (loss ratio, sliding-scale rate, commission amount) as a settlement component.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` (
    `ri_collateral_id` BIGINT COMMENT 'Unique surrogate identifier for each collateral instrument record posted by an unauthorized reinsurer. Primary key; one row per collateral instrument.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Reference to the statutory accounting period in which this collateral record was valued or reported. Supports Schedule F period-end snapshot reporting.',
    `fac_agreement_id` BIGINT COMMENT 'Foreign key linking to reinsurance.fac_agreement. Business justification: Collateral can be posted for facultative placements. Adding optional fac_agreement_id for FAC-specific collateral. Populated when collateral is posted for a FAC agreement.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Collateral adequacy calculations are line-specific per state regulations; LOB master provides Schedule F categories and certified reinsurer reduced collateral percentages by line for',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.reinsurer. Business justification: ri_collateral tracks collateral posted by reinsurers but currently has denormalized reinsurer attributes (reinsurer_name, reinsurer_naic_code, reinsurer_domicile_country).',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement this collateral secures. Links collateral to the treaty or facultative agreement requiring security.',
    `treaty_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty. Business justification: Collateral can be posted for specific treaties in addition to agreement level. Adding optional treaty_id for treaty-specific collateral.',
    `adequacy_status` STRING COMMENT 'Assessment of whether the available collateral amount meets or exceeds the required amount. Drives regulatory credit-for-reinsurance eligibility and remediation actions.. Valid values are `adequate|deficient|excess|under_review`',
    `available_amt` DECIMAL(18,2) COMMENT 'Current drawable or available balance of the collateral instrument, net of any prior draws or reductions. Used for credit-for-reinsurance calculations.',
    `broker_name` STRING COMMENT 'Name of the reinsurance intermediary broker who arranged the collateral instrument on behalf of the reinsurer. Used for broker reconciliation and commission tracking.',
    `cedant_legal_entity` STRING COMMENT 'Legal name of the ceding insurance company (Pc_Insurance entity) that is the beneficiary of the collateral instrument for Schedule F and regulatory reporting.',
    `cedant_naic_code` STRING COMMENT 'Five-digit NAIC company code of the ceding entity. Required for statutory Schedule F filing and regulatory identification.. Valid values are `^[0-9]{5}$`',
    `certified_reinsurer_rating` STRING COMMENT 'NAIC certified reinsurer rating tier (CR-1 through CR-6) that determines the reduced collateral percentage required. Applicable only when reinsurer_certified_flag is true.. Valid values are `CR-1|CR-2|CR-3|CR-4|CR-5|CR-6`',
    `collateral_notes` STRING COMMENT 'Free-text notes capturing special conditions, amendment history, or operational remarks about the collateral instrument not captured in structured fields.',
    `collateral_number` STRING COMMENT 'Externally assigned reference number for the collateral instrument (e.g., letter of credit number, trust account number) as issued by the financial institution.',
    `collateral_purpose` STRING COMMENT 'Business purpose for which the collateral is held. Determines how the available amount is applied against ceded liabilities for credit-for-reinsurance calculations.. Valid values are `ceded_reserves|unearned_premium|loss_reserves|lae_reserves|combined`',
    `collateral_status` STRING COMMENT 'Current lifecycle state of the collateral instrument. Active = in force and available; Drawn = cedant has drawn on the instrument; Released = returned to reinsurer.. Valid values are `active|expired|drawn|cancelled|pending|released`',
    `collateral_type` STRING COMMENT 'Classification of the collateral instrument. Drives regulatory treatment and Schedule F reporting. [ENUM-REF-CANDIDATE: letter_of_credit|trust_fund|funds_withheld|cash_deposit|surety_bond|other — promote to reference product]. Valid values are `letter_of_credit|trust_fund|funds_withheld|cash_deposit|surety_bond|other`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this collateral record was first created in the reinsurance management system. Supports audit trail and data lineage requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the collateral instrument is denominated (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `deficiency_amt` DECIMAL(18,2) COMMENT 'Shortfall between the required collateral amount and the available amount. Positive value indicates a deficiency requiring remediation or reduction of reinsurance credit.',
    `draw_deadline_date` DATE COMMENT 'Last date by which the cedant must submit a draw request before the instrument expires. Critical for operational risk management and treasury planning.',
    `drawn_amt` DECIMAL(18,2) COMMENT 'Cumulative amount drawn by the cedant against this collateral instrument to date. Reduces the available amount and triggers reinsurer replenishment obligations.',
    `effective_date` DATE COMMENT 'Date on which the collateral instrument becomes effective and the cedant may draw upon it. Aligns with the reinsurance agreement inception or renewal date.',
    `evergreen_flag` BOOLEAN COMMENT 'Indicates whether the collateral instrument contains an evergreen clause that automatically renews unless the issuer provides advance notice of non-renewal to the cedant.',
    `expiry_date` DATE COMMENT 'Date on which the collateral instrument expires and is no longer drawable unless renewed. Regulatory evergreen provisions may require automatic renewal notice.',
    `external_reference_number` STRING COMMENT 'Reference number assigned by the reinsurer or broker to this collateral arrangement. Facilitates reconciliation with counterparty records and bordereaux reporting.',
    `face_amt` DECIMAL(18,2) COMMENT 'Gross face value of the collateral instrument as stated in the instrument document. Represents the maximum drawable or available amount before any reductions.',
    `governing_law` STRING COMMENT 'Jurisdiction whose laws govern the collateral instrument agreement (e.g., New York law, English law). Determines enforceability and dispute resolution framework.',
    `issuing_institution_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the issuing financial institution. Regulators may require the issuer to be domiciled in an approved jurisdiction.. Valid values are `^[A-Z]{3}$`',
    `issuing_institution_name` STRING COMMENT 'Name of the bank, trust company, or financial institution that issued or holds the collateral instrument (e.g., the bank issuing the letter of credit).',
    `last_valuation_date` DATE COMMENT 'Date on which the collateral instrument was most recently valued or reconciled against ceded reserve liabilities. Supports quarterly and annual adequacy reviews.',
    `lc_issuing_bank_swift` STRING COMMENT 'SWIFT/BIC code of the bank issuing the letter of credit. Populated only when collateral_type = letter_of_credit. Used for bank identity verification.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next adequacy review or renewal assessment of the collateral instrument. Supports proactive monitoring and regulatory compliance.',
    `non_renewal_notice_days` BIGINT COMMENT 'Number of calendar days advance notice the issuing institution must provide before non-renewal of an evergreen collateral instrument, as specified in the instrument.',
    `reduced_collateral_pct` DECIMAL(5,4) COMMENT 'Percentage of ceded liabilities that must be collateralized for certified reinsurers (e.g., 0.10 for CR-1 = 10%). Null for non-certified unauthorized reinsurers requiring 100%.',
    `regulatory_jurisdiction` STRING COMMENT 'US state or jurisdiction whose Department of Insurance (DOI) regulations govern the collateral requirement (e.g., NY, CA, TX). Drives state-specific credit-for-reinsurance rules.',
    `reinsurer_certified_flag` BOOLEAN COMMENT 'Indicates whether the reinsurer holds certified reinsurer status under the NAIC Credit for Reinsurance Model Law, which may reduce collateral requirements.',
    `release_date` DATE COMMENT 'Date on which the collateral instrument was released back to the reinsurer upon satisfaction of all ceded obligations. Null if not yet released.',
    `renewal_date` DATE COMMENT 'Date on which the collateral instrument was most recently renewed or extended. Tracks the renewal history for evergreen and term instruments.',
    `required_amt` DECIMAL(18,2) COMMENT 'Minimum collateral amount required by the cedant or regulator to support ceded reserves and obtain credit for reinsurance. Drives adequacy monitoring.',
    `schedule_f_category` STRING COMMENT 'NAIC Schedule F classification of the reinsurer for statutory reporting. Determines whether the cedant receives full or partial credit for reinsurance on the balance sheet.. Valid values are `authorized|unauthorized_with_collateral|unauthorized_without_collateral|certified`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this collateral record was sourced (e.g., SICS, Sapiens ReinsurancePro, or manual entry).. Valid values are `SICS|SAPIENS_RI|MANUAL|OTHER`',
    `trust_account_number` STRING COMMENT 'Account number of the trust fund if the collateral type is a trust fund arrangement. Populated only when collateral_type = trust_fund; null otherwise.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this collateral record was most recently modified. Supports change tracking, audit compliance, and incremental data pipeline processing.',
    CONSTRAINT pk_ri_collateral PRIMARY KEY(`ri_collateral_id`)
) COMMENT 'Tracks collateral (letters of credit, trust funds, funds withheld) posted by unauthorized reinsurers to support ceded reserves. One row per collateral instrument. Stores type, amount, expiry, and regulatory jurisdiction.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` (
    `schedule_f_entry_id` BIGINT COMMENT 'Unique surrogate identifier for each Schedule F statutory reporting entry. One row per reinsurer per reporting year per cedant legal entity.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Schedule F statutory filing requires line-level detail with NAIC line codes; LOB master is authoritative source for regulatory line mappings and ensures filing consistency across',
    `reinsurer_id` BIGINT COMMENT 'Foreign key linking to reinsurance.reinsurer. Business justification: Schedule F entries are per reinsurer but currently have denormalized reinsurer attributes.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance agreement that generated cessions summarized in this Schedule F entry.',
    `treaty_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty. Business justification: Schedule F reporting can be at treaty level in addition to agreement level. Adding optional treaty_id for treaty-specific Schedule F entries. Populated when reporting is at treaty level.',
    `agreement_type` STRING COMMENT 'Classification of the reinsurance arrangement as treaty, facultative, or facultative-obligatory, per Schedule F reporting categorization.. Valid values are `treaty|facultative|facultative_obligatory`',
    `amendment_date` DATE COMMENT 'Date of the most recent amendment to this Schedule F entry, if the original filing was corrected or restated after initial submission.',
    `assumed_premium_written_amt` DECIMAL(18,2) COMMENT 'Total written premium assumed from other cedants by this entity under retrocession or assumed reinsurance arrangements, reported on Schedule F.',
    `authorized_status` STRING COMMENT 'Regulatory authorization status of the reinsurer in the cedants domicile state. Drives collateral requirements and Schedule F credit treatment.. Valid values are `authorized|unauthorized|certified|accredited|reciprocal_jurisdiction`',
    `cedant_legal_entity` STRING COMMENT 'Full legal name of the ceding insurance company filing this Schedule F entry with the NAIC.',
    `cedant_naic_code` STRING COMMENT 'Five-digit NAIC company code assigned to the ceding insurer, used as the primary statutory identifier on Schedule F filings.. Valid values are `^[0-9]{5}$`',
    `ceded_contingent_commission_amt` DECIMAL(18,2) COMMENT 'Profit or contingent commission receivable from the reinsurer based on favorable loss experience, per treaty terms. Reported on Schedule F.',
    `ceded_ibnr_amt` DECIMAL(18,2) COMMENT 'Actuarial IBNR reserve attributable to ceded business with this reinsurer as of year-end, per Schedule F Part 3 reporting requirements.',
    `ceded_lae_reserve_amt` DECIMAL(18,2) COMMENT 'Reserve for ceded loss adjustment expenses (ALAE and ULAE) attributable to this reinsurer as of the reporting year-end.',
    `ceded_losses_outstanding_amt` DECIMAL(18,2) COMMENT 'Case reserves for ceded losses outstanding as of year-end, representing amounts owed by the reinsurer on reported but unsettled claims.',
    `ceded_losses_paid_amt` DECIMAL(18,2) COMMENT 'Actual loss payments recovered from this reinsurer during the reporting year on ceded claims, per Schedule F Part 3.',
    `ceded_premium_earned_amt` DECIMAL(18,2) COMMENT 'Portion of ceded written premium earned during the reporting year, used in loss ratio and Schedule F collectibility analysis.',
    `ceded_premium_written_amt` DECIMAL(18,2) COMMENT 'Total gross written premium ceded to this reinsurer during the reporting year, as reported on Schedule F Part 3. Basis for NWP calculation.',
    `ceded_unearned_premium_amt` DECIMAL(18,2) COMMENT 'Unearned portion of ceded premium as of the reporting year-end, representing the reinsurers liability for unexpired risk.',
    `ceding_commission_received_amt` DECIMAL(18,2) COMMENT 'Ceding commission received from the reinsurer during the reporting year, offsetting the cedants acquisition costs on ceded business.',
    `collateral_held_amt` DECIMAL(18,2) COMMENT 'Total collateral held by the cedant (letters of credit, trust funds, funds withheld) to secure unauthorized reinsurer obligations per Schedule F.',
    `collateral_type` STRING COMMENT 'Type of collateral posted by the reinsurer to secure its obligations. Determines Schedule F credit treatment for unauthorized reinsurers.. Valid values are `letter_of_credit|trust_fund|funds_withheld|cash_deposit|none`',
    `collectibility_status` STRING COMMENT 'Assessment of the reinsurers ability and willingness to pay. Drives Schedule F provision for reinsurance recoverables and surplus impact.. Valid values are `collectible|overdue_90|overdue_180|dispute|uncollectible|partial`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this Schedule F entry record was first created in the reinsurance reporting repository.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all monetary amounts on this Schedule F entry are denominated (e.g., USD).. Valid values are `^[A-Z]{3}$`',
    `dispute_amt` DECIMAL(18,2) COMMENT 'Dollar amount of reinsurance recoverables currently in formal dispute or arbitration with this reinsurer as of the reporting year-end.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether any portion of the reinsurance recoverable from this reinsurer is subject to a formal dispute or arbitration proceeding.',
    `entry_status` STRING COMMENT 'Current lifecycle status of this Schedule F entry within the statutory filing workflow.. Valid values are `draft|submitted|filed|amended|superseded`',
    `exchange_rate` DECIMAL(12,6) COMMENT 'Exchange rate used to convert foreign-currency reinsurance balances to USD for statutory reporting purposes on Schedule F.',
    `filing_date` DATE COMMENT 'Date this Schedule F entry was submitted to the state Department of Insurance as part of the NAIC Annual Statement filing.',
    `funds_withheld_amt` DECIMAL(18,2) COMMENT 'Amount of reinsurance premium withheld by the cedant under a funds-withheld arrangement, serving as collateral for reinsurer obligations.',
    `net_balance_due_amt` DECIMAL(18,2) COMMENT 'Net amount due from (positive) or to (negative) the reinsurer as of year-end, representing the net settlement position on Schedule F.',
    `overdue_balance_amt` DECIMAL(18,2) COMMENT 'Portion of the net balance due that is overdue per contractual payment terms, triggering collectibility review and potential Schedule F provision.',
    `overdue_days` BIGINT COMMENT 'Number of days the oldest unpaid balance has been outstanding beyond contractual due date. Drives Schedule F collectibility aging buckets.',
    `provision_for_reinsurance_amt` DECIMAL(18,2) COMMENT 'Statutory provision charged to surplus for potentially uncollectible reinsurance recoverables from this reinsurer, per Schedule F Part 4 calculation.',
    `rating_agency` STRING COMMENT 'Name of the credit rating agency that issued the reinsurers financial strength rating used in Schedule F collectibility evaluation.. Valid values are `AM_Best|SP|Moodys|Fitch|Kroll`',
    `rbc_action_level` STRING COMMENT 'NAIC Risk-Based Capital action level of the reinsurer, indicating financial solvency standing. Informs collectibility and Schedule F provision decisions.. Valid values are `no_action|company_action|regulatory_action|authorized_control|mandatory_control`',
    `reinsurer_rating` STRING COMMENT 'Financial strength rating of the reinsurer from a recognized rating agency (e.g., A.M. Best, S&P) as of the reporting year-end. Used in collectibility assessment.',
    `reporting_year` BIGINT COMMENT 'Calendar year for which this Schedule F entry is filed, corresponding to the NAIC Annual Statement reporting period (e.g., 2024).',
    `schedule_f_part` STRING COMMENT 'Identifies which part of NAIC Schedule F this entry populates (e.g., Part 3 = Ceded Reinsurance, Part 4 = Provision for Reinsurance).. Valid values are `part1|part2|part3|part4|part5|part6`',
    `treaty_type` STRING COMMENT 'Specific treaty structure: Quota Share (QS), Excess of Loss (XOL), Stop Loss (SL), or Catastrophe Excess of Loss (CAT XL). Drives cession mechanics.. Valid values are `quota_share|excess_of_loss|stop_loss|cat_xl`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this Schedule F entry, supporting audit trail and amendment tracking requirements.',
    CONSTRAINT pk_schedule_f_entry PRIMARY KEY(`schedule_f_entry_id`)
) COMMENT 'Statutory Schedule F reporting entry per reinsurer per reporting year. One row per reinsurer per year. Captures assumed and ceded premium, losses, reserves, and collectibility status for NAIC Annual Statement filing.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` (
    `treaty_layer_peril_term_id` BIGINT COMMENT 'Unique surrogate identifier for this treaty layer peril term record. Primary key.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to the specific peril for which these treaty layer terms are defined.',
    `treaty_layer_id` BIGINT COMMENT 'Foreign key linking to the parent treaty layer under which these peril-specific terms apply.',
    `effective_date` DATE COMMENT 'Date on which these peril-specific terms become effective within the treaty layer. May differ from layer effective date for mid-term peril amendments.',
    `expiration_date` DATE COMMENT 'Date on which these peril-specific terms expire. Nullable for terms that remain in force through the layer expiration.',
    `notes` STRING COMMENT 'Free-text notes capturing peril-specific treaty language, exclusions, conditions, or underwriting guidance relevant to this peril within this layer.',
    `peril_attachment_point` DECIMAL(18,2) COMMENT 'Dollar amount of loss per occurrence for this specific peril at which the reinsurance layer begins to respond. May differ from the layer-wide attachment point.',
    `peril_cession_pct` DECIMAL(7,4) COMMENT 'Percentage of loss within this layer ceded to reinsurers for this specific peril. May differ from the layer-wide cession percentage to reflect peril-specific risk appetite.',
    `peril_inclusion_flag` BOOLEAN COMMENT 'Indicates whether this peril is explicitly included in the treaty layer coverage. False indicates exclusion or sublimit application.',
    `peril_limit` DECIMAL(18,2) COMMENT 'Maximum dollar amount recoverable from reinsurers under this layer for a single occurrence of this specific peril. May differ from the layer-wide limit.',
    `peril_retention` DECIMAL(18,2) COMMENT 'Dollar amount of loss for this specific peril that the cedant retains before the reinsurance layer responds. May differ from the layer-wide retention.',
    `peril_rol_pct` DECIMAL(7,4) COMMENT 'Rate on Line expressed as a decimal for this specific peril; the reinsurance premium for this peril divided by the peril-specific limit. Reflects peril-specific pricing.',
    `peril_sublimit_flag` BOOLEAN COMMENT 'Indicates whether this peril is subject to a sublimit within the treaty layer, requiring separate tracking of aggregate exposure and exhaustion.',
    CONSTRAINT pk_treaty_layer_peril_term PRIMARY KEY(`treaty_layer_peril_term_id`)
) COMMENT 'Captures peril-specific reinsurance terms within a treaty layer. Each record links one treaty layer to one peril with attachment points, limits, retention, cession percentages, and rates that vary by peril..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` (
    `agreement_peril_coverage_id` BIGINT COMMENT 'Unique surrogate identifier for the agreement peril coverage record. Primary key.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to the peril catalog record.',
    `ri_agreement_id` BIGINT COMMENT 'Foreign key linking to the reinsurance agreement record.',
    `effective_date` DATE COMMENT 'Date on which this peril coverage or exclusion becomes effective within the agreement.',
    `expiry_date` DATE COMMENT 'Date on which this peril coverage or exclusion expires within the agreement.',
    `notes` STRING COMMENT 'Free-text notes capturing additional peril-specific terms, conditions, or underwriting guidance.',
    `peril_attachment_point_amt` DECIMAL(18,2) COMMENT 'Loss threshold at which reinsurance coverage attaches for this specific peril, if different from agreement-level attachment.',
    `peril_coverage_basis` STRING COMMENT 'Coverage trigger basis specific to this peril: Losses Occurring, Claims Made, or Risk Attaching.',
    `peril_exclusion_clause` STRING COMMENT 'Text of the exclusion clause or endorsement reference if the peril is excluded from coverage under this agreement.',
    `peril_inclusion_flag` BOOLEAN COMMENT 'Indicates whether the peril is explicitly included in the reinsurance agreement coverage scope.',
    `peril_reinstatement_provision` STRING COMMENT 'Special reinstatement terms applicable to this peril, such as limited reinstatements for CAT perils.',
    `peril_specific_retention_amt` DECIMAL(18,2) COMMENT 'Cedant retention amount specific to this peril, if different from the agreement-level retention.',
    `peril_sublimit_amt` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery amount specific to this peril within the agreement, if different from the overall limit.',
    `peril_territory_restriction` STRING COMMENT 'Geographic scope restriction specific to this peril within the agreement, if narrower than the overall territory scope.',
    CONSTRAINT pk_agreement_peril_coverage PRIMARY KEY(`agreement_peril_coverage_id`)
) COMMENT 'Captures which perils are covered, excluded, or subject to special terms within each reinsurance agreement. One row per agreement per peril. Tracks inclusion/exclusion flags, peril-specific sublimits, retentions, and clauses..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` (
    `treaty_zone_terms_id` BIGINT COMMENT 'Unique surrogate identifier for a treaty zone terms record. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to the catastrophe zone for which these treaty terms are defined.',
    `treaty_id` BIGINT COMMENT 'Foreign key linking to the reinsurance treaty under which these zone-specific terms apply.',
    `effective_date` DATE COMMENT 'Date when these zone-specific treaty terms became effective. Allows for mid-term treaty amendments targeting specific catastrophe zones.',
    `expiration_date` DATE COMMENT 'Date when these zone-specific treaty terms expire. Null if terms remain in effect through treaty expiration.',
    `notes` STRING COMMENT 'Free-text notes documenting the business rationale for zone-specific treaty terms, such as reinsurer requirements or regulatory capital optimization strategies.',
    `underwriting_restriction_code` STRING COMMENT 'Code indicating underwriting restrictions imposed by reinsurers for this zone under this treaty: none, moratorium, reduced limit, increased retention, or excluded.',
    `zone_attachment_point` DECIMAL(18,2) COMMENT 'Dollar amount at which reinsurance coverage attaches for losses in this catastrophe zone. Used for zone-specific excess of loss structuring.',
    `zone_cession_pct` DECIMAL(7,4) COMMENT 'Percentage of risk ceded to reinsurers for policies in this catastrophe zone under this treaty. May differ from treaty-level cession percentage for concentration management.',
    `zone_exclusion_flag` BOOLEAN COMMENT 'Indicates whether this catastrophe zone is explicitly excluded from reinsurance coverage under this treaty. Used for high-risk zone carve-outs.',
    `zone_limit` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery available under this treaty for losses occurring in this catastrophe zone. Used for concentration control and regulatory capital optimization.',
    `zone_retention_amt` DECIMAL(18,2) COMMENT 'Cedant net retained loss amount before reinsurance attaches for losses in this catastrophe zone. May be higher than treaty-level retention for high-risk zones.',
    CONSTRAINT pk_treaty_zone_terms PRIMARY KEY(`treaty_zone_terms_id`)
) COMMENT 'Defines zone-specific reinsurance treaty terms for catastrophe exposure management. One row per treaty per cat zone. Captures zone-level cession percentages, retentions, attachment points, limits, and exclusions used for underwriting guidelines and';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_parent_treaty_layer_id` FOREIGN KEY (`parent_treaty_layer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ADD CONSTRAINT `fk_reinsurance_reinsurer_parent_reinsurer_id` FOREIGN KEY (`parent_reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ADD CONSTRAINT `fk_reinsurance_ri_participant_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ADD CONSTRAINT `fk_reinsurance_ri_participant_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_original_transaction_id` FOREIGN KEY (`original_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction`(`ri_premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_ri_claim_cession_id` FOREIGN KEY (`ri_claim_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`(`ri_claim_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_prior_bordereaux_id` FOREIGN KEY (`prior_bordereaux_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ADD CONSTRAINT `fk_reinsurance_ri_collateral_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ADD CONSTRAINT `fk_reinsurance_ri_collateral_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ADD CONSTRAINT `fk_reinsurance_ri_collateral_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ADD CONSTRAINT `fk_reinsurance_ri_collateral_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ADD CONSTRAINT `fk_reinsurance_schedule_f_entry_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ADD CONSTRAINT `fk_reinsurance_schedule_f_entry_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ADD CONSTRAINT `fk_reinsurance_schedule_f_entry_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ADD CONSTRAINT `fk_reinsurance_treaty_layer_peril_term_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ADD CONSTRAINT `fk_reinsurance_agreement_peril_coverage_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ADD CONSTRAINT `fk_reinsurance_treaty_zone_terms_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`reinsurance` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`reinsurance` SET TAGS ('dbx_domain' = 'reinsurance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `broker_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `aggregate_limit_amt` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `agreement_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `agreement_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_value_regex' = 'Draft|Active|Expired|Cancelled|Suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'Treaty|Facultative|Facultative_Obligatory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `arbitration_clause` SET TAGS ('dbx_business_glossary_term' = 'Arbitration Clause Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `attachment_point_amt` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `authorized_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Authorized Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `authorized_status` SET TAGS ('dbx_value_regex' = 'Authorized|Unauthorized|Certified|Reciprocal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `cat_event_scope` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `cat_event_scope` SET TAGS ('dbx_value_regex' = 'Per_Risk|Per_Occurrence|Per_Event|Aggregate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `cedant_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Cedant Legal Entity Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `cedant_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Cedant National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `cedant_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `cession_pct` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `collateral_required` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'LOC|Trust|Funds_Withheld|Cash|None');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_business_glossary_term' = 'Coverage Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_value_regex' = 'Losses_Occurring|Risks_Attaching|Claims_Made');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `deposit_premium_amt` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `funds_withheld` SET TAGS ('dbx_business_glossary_term' = 'Funds Withheld Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `governing_law` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `hours_clause_hrs` SET TAGS ('dbx_business_glossary_term' = 'Hours Clause Duration (Hours)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Inception Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `insolvency_clause` SET TAGS ('dbx_business_glossary_term' = 'Insolvency Clause Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `lead_reinsurer_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `lead_reinsurer_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `lead_reinsurer_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `lead_reinsurer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `limit_amt` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `loss_corridor_pct` SET TAGS ('dbx_business_glossary_term' = 'Loss Corridor Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `minimum_premium_amt` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `offset_clause` SET TAGS ('dbx_business_glossary_term' = 'Offset Clause Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `program_layer` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Program Layer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_business_glossary_term' = 'Number of Reinstatements');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `retention_amt` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `retrocession_flag` SET TAGS ('dbx_business_glossary_term' = 'Retrocession Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `rol_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `signed_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Signed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `territory_scope` SET TAGS ('dbx_business_glossary_term' = 'Agreement Territory Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'QS|XOL|SL|CAT_XL|Surplus|Other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `unl_basis` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Net Loss (UNL) Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `unl_basis` SET TAGS ('dbx_value_regex' = 'Gross|Net_of_Inuring|Net_of_All_RI');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `intermediary_agency_id` SET TAGS ('dbx_business_glossary_term' = 'Intermediary Agency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `aggregate_deductible` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Deductible');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `brokerage_pct` SET TAGS ('dbx_business_glossary_term' = 'Brokerage Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `catastrophe_event_type` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `cession_pct` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage (QS)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `collateral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_business_glossary_term' = 'Coverage Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `coverage_basis` SET TAGS ('dbx_value_regex' = 'RISKS_ATTACHING|LOSSES_OCCURRING|CLAIMS_MADE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `deposit_premium` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Treaty Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Treaty Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `hours_clause` SET TAGS ('dbx_business_glossary_term' = 'Hours Clause (Hours)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `inception_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Inception Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `layer_number` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `limit` SET TAGS ('dbx_business_glossary_term' = 'Treaty Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `loss_corridor_lower` SET TAGS ('dbx_business_glossary_term' = 'Loss Corridor Lower Bound');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `loss_corridor_upper` SET TAGS ('dbx_business_glossary_term' = 'Loss Corridor Upper Bound');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `minimum_premium` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `treaty_name` SET TAGS ('dbx_business_glossary_term' = 'Treaty Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `treaty_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Treaty Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `occurrence_limit` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `placement_pct` SET TAGS ('dbx_business_glossary_term' = 'Treaty Placement Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `premium` SET TAGS ('dbx_business_glossary_term' = 'Treaty Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `reinsurer_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Lead Reinsurer Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `retention_pct` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `retrocession_flag` SET TAGS ('dbx_business_glossary_term' = 'Retrocession Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `rol_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `subject_premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Subject Premium Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `subject_premium_basis` SET TAGS ('dbx_value_regex' = 'GWP|NWP|DPW|NET_EARNED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `territory` SET TAGS ('dbx_business_glossary_term' = 'Treaty Territory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `treaty_status` SET TAGS ('dbx_business_glossary_term' = 'Treaty Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `treaty_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|EXPIRED|CANCELLED|SUSPENDED|PENDING');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'QS|XOL|SL|CAT_XL|STOP_LOSS|SURPLUS');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `unl_basis` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Net Loss (UNL) Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `unl_basis` SET TAGS ('dbx_value_regex' = 'GROSS|NET_OF_INURING|NET_OF_SALVAGE|ULTIMATE_NET_LOSS');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `coverage_type_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `parent_treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Underlying Layer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_business_glossary_term' = 'Accounting Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_value_regex' = 'losses_occurring|risks_attaching');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `annual_aggregate_deductible` SET TAGS ('dbx_business_glossary_term' = 'Annual Aggregate Deductible (AAD)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `annual_aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Annual Aggregate Limit (AAL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `broker_reference` SET TAGS ('dbx_business_glossary_term' = 'Broker Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `cedant_retention_pct` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `ceded_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceded Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `deposit_premium` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `hours_clause` SET TAGS ('dbx_business_glossary_term' = 'Hours Clause');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `index_basis` SET TAGS ('dbx_business_glossary_term' = 'Index Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `index_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Index Clause Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_code` SET TAGS ('dbx_business_glossary_term' = 'Layer Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,30}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_limit` SET TAGS ('dbx_business_glossary_term' = 'Layer Limit (Per Occurrence)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_name` SET TAGS ('dbx_business_glossary_term' = 'Layer Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_notes` SET TAGS ('dbx_business_glossary_term' = 'Layer Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_number` SET TAGS ('dbx_business_glossary_term' = 'Layer Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_status` SET TAGS ('dbx_business_glossary_term' = 'Layer Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_status` SET TAGS ('dbx_value_regex' = 'active|expired|cancelled|pending|suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_type` SET TAGS ('dbx_business_glossary_term' = 'Layer Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `layer_type` SET TAGS ('dbx_value_regex' = 'XOL|CAT_XL|QS|SL|WORKING|CLASH');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `lob_scope` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `loss_corridor_lower` SET TAGS ('dbx_business_glossary_term' = 'Loss Corridor Lower Bound');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `loss_corridor_upper` SET TAGS ('dbx_business_glossary_term' = 'Loss Corridor Upper Bound');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `loss_occurrence_definition` SET TAGS ('dbx_business_glossary_term' = 'Loss Occurrence Definition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `minimum_premium` SET TAGS ('dbx_business_glossary_term' = 'Minimum Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `peril_scope` SET TAGS ('dbx_business_glossary_term' = 'Peril Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `placed_pct` SET TAGS ('dbx_business_glossary_term' = 'Placed Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_basis` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_basis` SET TAGS ('dbx_value_regex' = 'pro_rata|flat|free');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_count` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinstatement_premium_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `reinsurance_premium` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `retrocession_flag` SET TAGS ('dbx_business_glossary_term' = 'Retrocession Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `rol_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `signed_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Signed Line Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `sliding_scale_flag` SET TAGS ('dbx_business_glossary_term' = 'Sliding Scale Commission Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `subject_premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Subject Premium Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `subject_premium_basis` SET TAGS ('dbx_value_regex' = 'GWP|NWP|DPW|NEP|GEP');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `territory_scope` SET TAGS ('dbx_business_glossary_term' = 'Territory Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `unl_basis` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Net Loss (UNL) Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `unl_basis` SET TAGS ('dbx_value_regex' = 'gross|net_of_recoveries|net_of_underlying_ri');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_broker_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Broker Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_cedant_party_id` SET TAGS ('dbx_business_glossary_term' = 'Cedant Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_reinsurer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Placing Producer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `uw_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Decision Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `uw_referral_id` SET TAGS ('dbx_business_glossary_term' = 'Uw Referral Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Facultative Agreement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_value_regex' = 'draft|bound|active|expired|cancelled|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `bound_date` SET TAGS ('dbx_business_glossary_term' = 'FAC Bound Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `broker_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Broker Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'FAC Cancellation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `ceded_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `ceded_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ceded Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Reinsurance Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `ceded_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `ceding_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `collateral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'FAC Agreement Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_premium_rate` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Premium Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_type` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `fac_type` SET TAGS ('dbx_value_regex' = 'pro_rata|excess_of_loss');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'FAC Agreement Inception Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `loss_participation_rate` SET TAGS ('dbx_business_glossary_term' = 'Loss Participation Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `original_insured_tiv` SET TAGS ('dbx_business_glossary_term' = 'Original Insured Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `placement_basis` SET TAGS ('dbx_business_glossary_term' = 'FAC Placement Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `placement_basis` SET TAGS ('dbx_value_regex' = 'risks_attaching|losses_occurring');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `reinstatement_premium_rate` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `reinstatement_provision` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Provision Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `reinsurer_share_percentage` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `reinsurer_underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Underwriter Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `reinsurer_underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `retrocession_flag` SET TAGS ('dbx_business_glossary_term' = 'Retrocession (RETRO) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `schedule_f_category` SET TAGS ('dbx_business_glossary_term' = 'Schedule F Reinsurer Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `schedule_f_category` SET TAGS ('dbx_value_regex' = 'authorized|unauthorized|certified|reciprocal_jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `slip_reference` SET TAGS ('dbx_business_glossary_term' = 'FAC Slip Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `special_conditions` SET TAGS ('dbx_business_glossary_term' = 'FAC Special Conditions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `parent_reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Reinsurer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_outlook` SET TAGS ('dbx_business_glossary_term' = 'AM Best Rating Outlook');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_outlook` SET TAGS ('dbx_value_regex' = 'stable|positive|negative|developing|under_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_business_glossary_term' = 'AM Best Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating` SET TAGS ('dbx_value_regex' = '^(A++|A+|A|A-|B++|B+|B|B-|C++|C+|C|C-|D|E|F|S|NR)$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `am_best_rating_date` SET TAGS ('dbx_business_glossary_term' = 'AM Best Rating Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `approval_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Approval Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `approved_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Approved Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `authorization_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Authorization Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `authorization_status` SET TAGS ('dbx_value_regex' = 'authorized|unauthorized|certified|accredited|reciprocal_jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `broker_intermediary_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Broker Intermediary Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `broker_intermediary_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `collateral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|trust_fund|funds_withheld|cash_deposit|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `credit_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Credit Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `credit_limit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Domicile Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_state` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Domicile State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `domicile_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `federal_excise_tax_exempt_flag` SET TAGS ('dbx_business_glossary_term' = 'Federal Excise Tax (FET) Exempt Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `fein` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `group_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Group Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `group_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Counterparty Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `lloyds_syndicate_number` SET TAGS ('dbx_business_glossary_term' = 'Lloyds Syndicate Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `lloyds_syndicate_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `minimum_am_best_rating` SET TAGS ('dbx_business_glossary_term' = 'Minimum AM Best Rating Requirement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `moodys_rating` SET TAGS ('dbx_business_glossary_term' = 'Moodys Insurance Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `naic_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Counterparty Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `pool_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Pool Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `pool_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Lifecycle Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|run_off|insolvent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `reinsurer_type` SET TAGS ('dbx_value_regex' = 'assuming_company|lloyds_syndicate|pool|captive|government|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `relationship_inception_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Relationship Inception Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `retrocession_flag` SET TAGS ('dbx_business_glossary_term' = 'Retrocession Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `schedule_f_category` SET TAGS ('dbx_business_glossary_term' = 'NAIC Schedule F Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `schedule_f_category` SET TAGS ('dbx_value_regex' = 'authorized|unauthorized_with_collateral|unauthorized_without_collateral|certified|accredited|reciprocal_jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Short Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `short_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `sp_rating` SET TAGS ('dbx_business_glossary_term' = 'S&P Global Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `tax_withholding_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `tax_withholding_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `ri_participant_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Participant ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `ri_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Broker ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `ri_reinsurer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `account_current_basis` SET TAGS ('dbx_business_glossary_term' = 'Account Current Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `account_current_basis` SET TAGS ('dbx_value_regex' = 'written|earned|cash');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'treaty_qs|treaty_xol|treaty_sl|treaty_cat_xl|facultative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `brokerage_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Brokerage Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `cession_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Cession Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `commutation_amount` SET TAGS ('dbx_business_glossary_term' = 'Commutation Settlement Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `commutation_date` SET TAGS ('dbx_business_glossary_term' = 'Commutation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `commutation_flag` SET TAGS ('dbx_business_glossary_term' = 'Commutation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `cut_through_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Cut-Through Clause Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Participation Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Participation Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `funds_withheld_flag` SET TAGS ('dbx_business_glossary_term' = 'Funds Withheld Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `insolvency_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Insolvency Clause Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `lc_amount` SET TAGS ('dbx_business_glossary_term' = 'Letter of Credit (LC) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `lc_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Letter of Credit (LC) Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `offset_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Offset Clause Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `order_hereon_pct` SET TAGS ('dbx_business_glossary_term' = 'Order Hereon Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `participant_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Participant Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `participant_status` SET TAGS ('dbx_business_glossary_term' = 'Participant Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `participant_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated|suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `participation_type` SET TAGS ('dbx_business_glossary_term' = 'Participation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `participation_type` SET TAGS ('dbx_value_regex' = 'leader|follower|sole_reinsurer|co_reinsurer|retrocessionaire');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `placement_date` SET TAGS ('dbx_business_glossary_term' = 'Placement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `profit_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `retrocession_flag` SET TAGS ('dbx_business_glossary_term' = 'Retrocession (RETRO) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `rol_pct` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `settlement_frequency` SET TAGS ('dbx_business_glossary_term' = 'Settlement Frequency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `settlement_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|as_agreed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `signed_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Signed Line Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `signing_date` SET TAGS ('dbx_business_glossary_term' = 'Signing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Participation Termination Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Participation Termination Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'commutation|insolvency|mutual_agreement|regulatory|non_renewal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `trust_fund_amount` SET TAGS ('dbx_business_glossary_term' = 'Trust Fund Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ALTER COLUMN `written_line_pct` SET TAGS ('dbx_business_glossary_term' = 'Written Line Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `currency_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Facultative Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `attachment_point` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `booking_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Booking Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q[1-4]|[0-9]{2})$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_case_reserve` SET TAGS ('dbx_business_glossary_term' = 'Ceded Case Reserve');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_case_reserve` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (EP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_gwp` SET TAGS ('dbx_business_glossary_term' = 'Ceded Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_gwp` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_ibnr_reserve` SET TAGS ('dbx_business_glossary_term' = 'Ceded Incurred But Not Reported Reserve (IBNR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_ibnr_reserve` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_limit` SET TAGS ('dbx_business_glossary_term' = 'Ceded Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_tiv` SET TAGS ('dbx_business_glossary_term' = 'Ceded Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_tiv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium (UEP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ceding_commission_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|trust_fund|cash|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `direction` SET TAGS ('dbx_business_glossary_term' = 'Cession Direction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `direction` SET TAGS ('dbx_value_regex' = 'outward|retrocession');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_business_glossary_term' = 'Exhaustion Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `exhaustion_point` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `funds_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Funds Held Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `funds_held_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `is_catastrophe_cession` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Cession Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Cession Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `rate_on_line` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `rate_on_line` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_status` SET TAGS ('dbx_business_glossary_term' = 'Cession Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurance_cession_status` SET TAGS ('dbx_value_regex' = 'active|pending|cancelled|expired|suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_authorization_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Authorization Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_authorization_status` SET TAGS ('dbx_value_regex' = 'authorized|accredited|certified|unauthorized|reciprocal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Domicile Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_domicile_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer NAIC Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `reinsurer_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `share_pct` SET TAGS ('dbx_business_glossary_term' = 'Cession Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `share_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'quota_share|excess_of_loss|stop_loss|cat_xl');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ultimate_net_loss` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Net Loss (UNL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `ultimate_net_loss` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ri_premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Premium Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `original_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Original Transaction ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `accounting_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'Quota Share|Excess of Loss|Stop Loss|CAT XL|Surplus Share');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `bordereaux_status` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `bordereaux_status` SET TAGS ('dbx_value_regex' = 'Pending|Submitted|Acknowledged|Disputed|Settled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (CEP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium (CUEP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium (CWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceding_commission` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceding_commission` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `ceding_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `cession_type` SET TAGS ('dbx_business_glossary_term' = 'Cession Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `cession_type` SET TAGS ('dbx_value_regex' = 'Treaty|Facultative|Retrocession');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `occurrence_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `policy_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `policy_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `profit_commission` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `profit_commission` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `rate_on_line` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reinstated_limit` SET TAGS ('dbx_business_glossary_term' = 'Reinstated Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reinstated_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reinstatement_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reporting_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reporting_currency_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `return_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Return Premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `return_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `risk_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `risk_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SICS|ReinsurancePro|Manual|PAS|BillingCenter');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Premium Transaction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Premium Transaction Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Premium Transaction Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'Draft|Pending|Posted|Reversed|Voided');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Premium Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'Written|Earned|Unearned|Return|Reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Claim Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `riskexposure_insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Riskexposure Insured Risk Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q[1-4]|M(0[1-9]|1[0-2]))$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `bordereaux_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `cat_event_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `ceded_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `ceded_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `ceded_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `cession_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Cession Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `cession_number` SET TAGS ('dbx_business_glossary_term' = 'Cession Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `cession_status` SET TAGS ('dbx_business_glossary_term' = 'Cession Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `cession_status` SET TAGS ('dbx_value_regex' = 'pending|active|settled|disputed|withdrawn|closed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `cession_type` SET TAGS ('dbx_business_glossary_term' = 'Cession Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `cession_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative|retrocession');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `commutation_date` SET TAGS ('dbx_business_glossary_term' = 'Commutation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `commutation_flag` SET TAGS ('dbx_business_glossary_term' = 'Commutation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `funds_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Funds Held Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `is_cat_claim` SET TAGS ('dbx_business_glossary_term' = 'Is Catastrophe (CAT) Claim Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `layer_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Layer Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `layer_retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Layer Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `recovery_billed_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Billed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `recovery_received_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Received Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `recovery_status` SET TAGS ('dbx_business_glossary_term' = 'Recovery Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `recovery_status` SET TAGS ('dbx_value_regex' = 'not_billed|billed|partially_recovered|fully_recovered|disputed|written_off');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `reinsurance_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `reinsurance_type` SET TAGS ('dbx_value_regex' = 'quota_share|excess_of_loss|stop_loss|cat_xl|facultative_proportional|facultative_non_proportional');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `reinsurer_participation_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Participation Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `rol_rate` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `schedule_f_category` SET TAGS ('dbx_business_glossary_term' = 'Schedule F Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `schedule_f_category` SET TAGS ('dbx_value_regex' = 'authorized|unauthorized|certified|other_alien');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `unl_amount` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Net Loss (UNL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `ri_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Recovery Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Batch Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `claim_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Exposure Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `ri_claim_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Claim Cession Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `billed_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Billed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `bordereaux_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Submission Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `calendar_year` SET TAGS ('dbx_business_glossary_term' = 'Calendar Year (CY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `cat_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `ceded_share_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ceded Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `collateral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `collected_amount` SET TAGS ('dbx_business_glossary_term' = 'Collected Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `collected_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Collected Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `commutation_date` SET TAGS ('dbx_business_glossary_term' = 'Commutation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `commutation_flag` SET TAGS ('dbx_business_glossary_term' = 'Commutation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `dispute_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `facultative_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Facultative (FAC) Certificate Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `movement_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Movement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `movement_type` SET TAGS ('dbx_business_glossary_term' = 'Recovery Movement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Recovery Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `outstanding_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `payment_type` SET TAGS ('dbx_value_regex' = 'loss|lae|dcc|subrogation|salvage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `policy_year` SET TAGS ('dbx_business_glossary_term' = 'Policy Year (PY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `recovery_amount_usd` SET TAGS ('dbx_business_glossary_term' = 'Recovery Amount in United States Dollars (USD)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `recovery_status` SET TAGS ('dbx_business_glossary_term' = 'Recovery Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `recovery_status` SET TAGS ('dbx_value_regex' = 'pending|billed|collected|disputed|written_off|reversed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `reinstatement_premium_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `reserve_type` SET TAGS ('dbx_business_glossary_term' = 'Reserve Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `reserve_type` SET TAGS ('dbx_value_regex' = 'case|ibnr|lae|ulae|alae');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Recovery Transaction Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_broker_party_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_party_id` SET TAGS ('dbx_business_glossary_term' = 'Cedent Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `prior_bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Bordereaux Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Ri Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `accepted_date` SET TAGS ('dbx_business_glossary_term' = 'Accepted Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Amendment Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_status` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|accepted|rejected|amended|finalized');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_type` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `bordereaux_type` SET TAGS ('dbx_value_regex' = 'premium|loss|combined|statistical|exposure|claim_detail');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_ibnr_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Incurred But Not Reported (IBNR) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_lae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Adjustment Expense (LAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_outstanding_loss_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Outstanding Loss Reserve (OSLR) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_paid_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Paid Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_unearned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `ceded_written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `claim_count` SET TAGS ('dbx_business_glossary_term' = 'Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `finalized_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Finalized Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `net_balance_due_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Balance Due Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `prepared_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Prepared By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `prepared_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `prepared_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `rejected_date` SET TAGS ('dbx_business_glossary_term' = 'Rejected Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_format` SET TAGS ('dbx_business_glossary_term' = 'Submission Format');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_method` SET TAGS ('dbx_business_glossary_term' = 'Submission Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|email|portal|api|edi');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `reinsurance_bordereaux_line_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Bordereaux Line ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `bordereaux_id` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Run ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `premium_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Premium Transaction Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `reinsurer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'TREATY|FACULTATIVE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `bordereaux_line_type` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `bordereaux_line_type` SET TAGS ('dbx_value_regex' = 'PREMIUM_CESSION|CLAIM_CESSION|ADJUSTMENT|RETURN_PREMIUM|REINSTATEMENT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `catastrophe_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (CEP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_earned_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_ibnr_reserve` SET TAGS ('dbx_business_glossary_term' = 'Ceded Incurred But Not Reported (IBNR) Reserve');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_ibnr_reserve` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_ibnr_reserve` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_lae_paid` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Adjustment Expense (LAE) Paid');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_lae_paid` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_lae_paid` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_lae_reserve` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Adjustment Expense (LAE) Reserve');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_lae_reserve` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_lae_reserve` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_loss_paid` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Paid');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_loss_paid` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_loss_paid` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_loss_reserve` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Reserve');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_loss_reserve` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_loss_reserve` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium (CUEP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_unearned_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium (CWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceded_written_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `ceding_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `cession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Exchange Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `gross_written_premium` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `insured_name` SET TAGS ('dbx_business_glossary_term' = 'Insured Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `insured_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `insured_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `is_retrocession` SET TAGS ('dbx_business_glossary_term' = 'Is Retrocession Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `line_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Line Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Line Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'DRAFT|SUBMITTED|ACCEPTED|DISPUTED|SETTLED|VOIDED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `loss_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `policy_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `policy_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `rate_on_line` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `reinsurer_limit` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `reinsurer_share_percentage` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Claim Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `retention_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `retention_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `source_system_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'QUOTA_SHARE|EXCESS_OF_LOSS|STOP_LOSS|CAT_XL|SURPLUS');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `ri_reinstatement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Reinstatement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinsurance_cession_id` SET TAGS ('dbx_business_glossary_term' = 'Cession ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `bordereaux_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Dispute Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `exhausted_limit_amt` SET TAGS ('dbx_business_glossary_term' = 'Exhausted Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Invoice Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Invoice Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `is_automatic` SET TAGS ('dbx_business_glossary_term' = 'Automatic Reinstatement Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `is_free_reinstatement` SET TAGS ('dbx_business_glossary_term' = 'Free Reinstatement Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `layer_limit_amt` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `max_reinstatements_allowed` SET TAGS ('dbx_business_glossary_term' = 'Maximum Reinstatements Allowed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `occurrence_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Occurrence Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `occurrence_reference` SET TAGS ('dbx_business_glossary_term' = 'Loss Occurrence Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `occurrence_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Loss Occurrence ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `original_premium_basis_amt` SET TAGS ('dbx_business_glossary_term' = 'Original Premium Basis Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Payment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Payment Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `pro_rata_factor` SET TAGS ('dbx_business_glossary_term' = 'Pro-Rata Time Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstated_limit_amt` SET TAGS ('dbx_business_glossary_term' = 'Reinstated Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_number` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_premium_amt` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_premium_currency` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Currency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_premium_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_premium_rate` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Rate (ROL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_sequence` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Sequence Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_status` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|invoiced|paid|cancelled|disputed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinstatement_type` SET TAGS ('dbx_value_regex' = 'automatic|conditional|free|paid');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinsurer_confirmation_ref` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Confirmation Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinsurer_reinstatement_premium_amt` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Share Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `reinsurer_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `retention_amt` SET TAGS ('dbx_business_glossary_term' = 'Cedant Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `treaty_year` SET TAGS ('dbx_business_glossary_term' = 'Treaty Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ri_settlement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Settlement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_party_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Party ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `adjustment_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `adjustment_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `adjustment_premium_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Settlement Approval Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `authorized_reinsurer_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `bordereaux_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_premium_earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_premium_earned_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_premium_earned_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_premium_written_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_premium_written_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_premium_written_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_unearned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_unearned_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceded_unearned_premium_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ceding_commission_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `cession_share_percent` SET TAGS ('dbx_business_glossary_term' = 'Cession Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `deposit_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Deposit Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `deposit_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `deposit_premium_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Settlement Dispute Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `funds_withheld_amount` SET TAGS ('dbx_business_glossary_term' = 'Funds Withheld Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `funds_withheld_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `funds_withheld_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `interest_on_funds_withheld_amount` SET TAGS ('dbx_business_glossary_term' = 'Interest on Funds Withheld Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `interest_on_funds_withheld_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `interest_on_funds_withheld_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `lae_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Adjustment Expense (LAE) Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `lae_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `lae_recoverable_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `loss_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Recoverable Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `loss_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `loss_recoverable_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `net_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Settlement Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `net_settlement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `net_settlement_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `paid_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Paid Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `profit_commission_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `profit_commission_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `profit_commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Profit Commission Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `rate_on_line` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinstatement_premium_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Domicile Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_domicile_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer National Association of Insurance Commissioners (NAIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `reinsurer_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_direction` SET TAGS ('dbx_business_glossary_term' = 'Settlement Direction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_direction` SET TAGS ('dbx_value_regex' = 'payable_to_reinsurer|receivable_from_reinsurer');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_notes` SET TAGS ('dbx_business_glossary_term' = 'Settlement Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_number` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Settlement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_number` SET TAGS ('dbx_value_regex' = '^RI-SETL-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Period End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Period Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|settled|disputed|voided');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_type` SET TAGS ('dbx_business_glossary_term' = 'Settlement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `settlement_type` SET TAGS ('dbx_value_regex' = 'periodic|final|commutation|profit_commission|reinstatement_premium');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `subject_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Subject Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `subject_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `subject_premium_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'quota_share|excess_of_loss|stop_loss|cat_xl|surplus_share');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ultimate_net_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Net Loss (UNL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ultimate_net_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `ultimate_net_loss_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `ri_collateral_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Collateral ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `fac_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fac Agreement Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `adequacy_status` SET TAGS ('dbx_business_glossary_term' = 'Collateral Adequacy Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `adequacy_status` SET TAGS ('dbx_value_regex' = 'adequate|deficient|excess|under_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `available_amt` SET TAGS ('dbx_business_glossary_term' = 'Collateral Available Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `available_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `broker_name` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Broker Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `broker_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `cedant_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Cedant Legal Entity Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `cedant_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Cedant National Association of Insurance Commissioners (NAIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `cedant_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `certified_reinsurer_rating` SET TAGS ('dbx_business_glossary_term' = 'Certified Reinsurer Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `certified_reinsurer_rating` SET TAGS ('dbx_value_regex' = 'CR-1|CR-2|CR-3|CR-4|CR-5|CR-6');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `collateral_notes` SET TAGS ('dbx_business_glossary_term' = 'Collateral Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `collateral_number` SET TAGS ('dbx_business_glossary_term' = 'Collateral Instrument Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `collateral_purpose` SET TAGS ('dbx_business_glossary_term' = 'Collateral Purpose');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `collateral_purpose` SET TAGS ('dbx_value_regex' = 'ceded_reserves|unearned_premium|loss_reserves|lae_reserves|combined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `collateral_status` SET TAGS ('dbx_business_glossary_term' = 'Collateral Instrument Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `collateral_status` SET TAGS ('dbx_value_regex' = 'active|expired|drawn|cancelled|pending|released');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Instrument Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|trust_fund|funds_withheld|cash_deposit|surety_bond|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `deficiency_amt` SET TAGS ('dbx_business_glossary_term' = 'Collateral Deficiency Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `deficiency_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `draw_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Collateral Draw Deadline Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `drawn_amt` SET TAGS ('dbx_business_glossary_term' = 'Collateral Drawn Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `drawn_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Collateral Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `evergreen_flag` SET TAGS ('dbx_business_glossary_term' = 'Evergreen Collateral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Collateral Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `external_reference_number` SET TAGS ('dbx_business_glossary_term' = 'External Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `face_amt` SET TAGS ('dbx_business_glossary_term' = 'Collateral Face Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `face_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `governing_law` SET TAGS ('dbx_business_glossary_term' = 'Governing Law');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `issuing_institution_country` SET TAGS ('dbx_business_glossary_term' = 'Issuing Institution Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `issuing_institution_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `issuing_institution_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `issuing_institution_name` SET TAGS ('dbx_business_glossary_term' = 'Issuing Financial Institution Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `issuing_institution_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `last_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Collateral Valuation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `lc_issuing_bank_swift` SET TAGS ('dbx_business_glossary_term' = 'Letter of Credit (LC) Issuing Bank SWIFT Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `lc_issuing_bank_swift` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `lc_issuing_bank_swift` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `lc_issuing_bank_swift` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Collateral Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `non_renewal_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Non-Renewal Notice Period (Days)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `reduced_collateral_pct` SET TAGS ('dbx_business_glossary_term' = 'Reduced Collateral Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `regulatory_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `reinsurer_certified_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Certified Reinsurer Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `release_date` SET TAGS ('dbx_business_glossary_term' = 'Collateral Release Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Collateral Renewal Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `required_amt` SET TAGS ('dbx_business_glossary_term' = 'Required Collateral Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `required_amt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `schedule_f_category` SET TAGS ('dbx_business_glossary_term' = 'Schedule F Reinsurance Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `schedule_f_category` SET TAGS ('dbx_value_regex' = 'authorized|unauthorized_with_collateral|unauthorized_without_collateral|certified');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SICS|SAPIENS_RI|MANUAL|OTHER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `trust_account_number` SET TAGS ('dbx_business_glossary_term' = 'Trust Account Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `trust_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `trust_account_number` SET TAGS ('dbx_pii_category' = 'financial');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` SET TAGS ('dbx_subdomain' = 'cession_accounting');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `schedule_f_entry_id` SET TAGS ('dbx_business_glossary_term' = 'Schedule F Entry ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `reinsurer_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Agreement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'treaty|facultative|facultative_obligatory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule F Amendment Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `assumed_premium_written_amt` SET TAGS ('dbx_business_glossary_term' = 'Assumed Written Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `authorized_status` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Authorized Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `authorized_status` SET TAGS ('dbx_value_regex' = 'authorized|unauthorized|certified|accredited|reciprocal_jurisdiction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `cedant_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Cedant Legal Entity Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `cedant_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Cedant National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `cedant_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceded_contingent_commission_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceded Contingent Commission Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceded_ibnr_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceded Incurred But Not Reported (IBNR) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceded_lae_reserve_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Adjustment Expense (LAE) Reserve Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceded_losses_outstanding_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceded Outstanding Loss Reserve (OSLR) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceded_losses_paid_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceded Losses Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceded_premium_earned_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceded Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceded_premium_written_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceded Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceded_unearned_premium_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceded Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `ceding_commission_received_amt` SET TAGS ('dbx_business_glossary_term' = 'Ceding Commission Received Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `collateral_held_amt` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|trust_fund|funds_withheld|cash_deposit|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `collectibility_status` SET TAGS ('dbx_business_glossary_term' = 'Collectibility Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `collectibility_status` SET TAGS ('dbx_value_regex' = 'collectible|overdue_90|overdue_180|dispute|uncollectible|partial');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `dispute_amt` SET TAGS ('dbx_business_glossary_term' = 'Disputed Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Dispute Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `entry_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule F Entry Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `entry_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|filed|amended|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule F Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `funds_withheld_amt` SET TAGS ('dbx_business_glossary_term' = 'Funds Withheld Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `net_balance_due_amt` SET TAGS ('dbx_business_glossary_term' = 'Net Balance Due Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `overdue_balance_amt` SET TAGS ('dbx_business_glossary_term' = 'Overdue Balance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `overdue_days` SET TAGS ('dbx_business_glossary_term' = 'Overdue Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `provision_for_reinsurance_amt` SET TAGS ('dbx_business_glossary_term' = 'Provision for Reinsurance Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `rating_agency` SET TAGS ('dbx_value_regex' = 'AM_Best|SP|Moodys|Fitch|Kroll');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `rbc_action_level` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Capital (RBC) Action Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `rbc_action_level` SET TAGS ('dbx_value_regex' = 'no_action|company_action|regulatory_action|authorized_control|mandatory_control');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `reinsurer_rating` SET TAGS ('dbx_business_glossary_term' = 'Reinsurer Financial Strength Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `reporting_year` SET TAGS ('dbx_business_glossary_term' = 'Reporting Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `schedule_f_part` SET TAGS ('dbx_business_glossary_term' = 'Schedule F Part');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `schedule_f_part` SET TAGS ('dbx_value_regex' = 'part1|part2|part3|part4|part5|part6');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `treaty_type` SET TAGS ('dbx_business_glossary_term' = 'Treaty Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `treaty_type` SET TAGS ('dbx_value_regex' = 'quota_share|excess_of_loss|stop_loss|cat_xl');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` SET TAGS ('dbx_association_edges' = 'reinsurance.treaty_layer,catastrophegeography.peril');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `treaty_layer_peril_term_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Peril Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Peril Term - Peril Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `treaty_layer_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Layer Peril Term - Treaty Layer Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Peril Term Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Peril Term Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Peril Term Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `peril_attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Peril-Specific Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `peril_cession_pct` SET TAGS ('dbx_business_glossary_term' = 'Peril-Specific Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `peril_inclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Peril Inclusion Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `peril_limit` SET TAGS ('dbx_business_glossary_term' = 'Peril-Specific Layer Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `peril_retention` SET TAGS ('dbx_business_glossary_term' = 'Peril-Specific Retention');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `peril_rol_pct` SET TAGS ('dbx_business_glossary_term' = 'Peril-Specific Rate on Line');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ALTER COLUMN `peril_sublimit_flag` SET TAGS ('dbx_business_glossary_term' = 'Peril Sublimit Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` SET TAGS ('dbx_association_edges' = 'reinsurance.ri_agreement,catastrophegeography.peril');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `agreement_peril_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Peril Coverage Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Peril Coverage - Peril Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Peril Coverage - Ri Agreement Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `peril_attachment_point_amt` SET TAGS ('dbx_business_glossary_term' = 'Peril Attachment Point Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `peril_coverage_basis` SET TAGS ('dbx_business_glossary_term' = 'Peril Coverage Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `peril_exclusion_clause` SET TAGS ('dbx_business_glossary_term' = 'Peril Exclusion Clause');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `peril_inclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Peril Inclusion Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `peril_reinstatement_provision` SET TAGS ('dbx_business_glossary_term' = 'Peril Reinstatement Provision');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `peril_specific_retention_amt` SET TAGS ('dbx_business_glossary_term' = 'Peril Specific Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `peril_sublimit_amt` SET TAGS ('dbx_business_glossary_term' = 'Peril Sublimit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ALTER COLUMN `peril_territory_restriction` SET TAGS ('dbx_business_glossary_term' = 'Peril Territory Restriction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` SET TAGS ('dbx_subdomain' = 'agreement_structure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` SET TAGS ('dbx_association_edges' = 'reinsurance.treaty,catastrophegeography.cat_zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `treaty_zone_terms_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Zone Terms Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Zone Terms - Cat Zone Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Zone Terms - Treaty Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `underwriting_restriction_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Restriction Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `zone_attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Zone Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `zone_cession_pct` SET TAGS ('dbx_business_glossary_term' = 'Zone Cession Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `zone_exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Zone Exclusion Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `zone_limit` SET TAGS ('dbx_business_glossary_term' = 'Zone Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ALTER COLUMN `zone_retention_amt` SET TAGS ('dbx_business_glossary_term' = 'Zone Retention Amount');
