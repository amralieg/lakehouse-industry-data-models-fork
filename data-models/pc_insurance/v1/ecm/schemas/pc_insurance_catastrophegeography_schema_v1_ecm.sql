-- Schema for Domain: catastrophegeography | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:30

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`catastrophegeography` COMMENT 'Provisional description for user-specified domain catastrophe_geography. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` (
    `catastrophe_event_id` BIGINT COMMENT 'Unique identifier for the catastrophe event. Primary key.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Each catastrophe event has a primary peril type. Adding peril_id FK to peril reference table for referential integrity. peril_type remains for operational queries.',
    `aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount attributed to this type of catastrophe event based on historical modeling in USD.',
    `acres_burned` BIGINT COMMENT 'Total number of acres burned during the wildfire event.',
    `actual_loss_amount` DECIMAL(18,2) COMMENT 'Actual reported insured loss amount for this catastrophe event after claims settlement in USD.',
    `affected_countries` STRING COMMENT 'Comma-separated list of ISO 3-letter country codes where the catastrophe event caused insured losses.',
    `affected_states` STRING COMMENT 'Comma-separated list of US state postal codes where the catastrophe event caused insured losses.',
    `cat_bond_trigger_flag` BOOLEAN COMMENT 'Indicates whether this catastrophe event triggered a catastrophe bond payout.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe event record was first created in the system.',
    `data_source` STRING COMMENT 'Source system or organization that provided the catastrophe event data (e.g., ISO, PCS, RMS, AIR, NOAA, USGS).',
    `declaration_date` DATE COMMENT 'Date when the event was officially declared a catastrophe by industry or regulatory bodies.',
    `epicenter_latitude` DECIMAL(10,7) COMMENT 'Latitude coordinate of the catastrophe event epicenter or origin point.',
    `epicenter_longitude` DECIMAL(10,7) COMMENT 'Longitude coordinate of the catastrophe event epicenter or origin point.',
    `estimated_claim_count` BIGINT COMMENT 'Estimated total number of insurance claims expected to be filed industry-wide for this catastrophe event.',
    `event_description` STRING COMMENT 'Detailed narrative description of the catastrophe event including impact, path, and key characteristics.',
    `event_duration_days` BIGINT COMMENT 'Total number of days the catastrophe event lasted from start to end.',
    `event_end_date` DATE COMMENT 'Date when the catastrophe event concluded or was declared over.',
    `event_name` STRING COMMENT 'Official name assigned to the catastrophe event (e.g., Hurricane Katrina, Northridge Earthquake).',
    `event_start_date` DATE COMMENT 'Date when the catastrophe event began.',
    `event_status` STRING COMMENT 'Current lifecycle status of the catastrophe event record.. Valid values are `active|closed|under_review|pending_declaration`',
    `event_type` STRING COMMENT 'High-level classification of the catastrophe event origin.. Valid values are `natural|man-made|terrorism|pandemic|cyber`',
    `federal_disaster_declaration_flag` BOOLEAN COMMENT 'Indicates whether a federal disaster declaration was issued for this catastrophe event.',
    `fema_disaster_number` STRING COMMENT 'Official FEMA disaster declaration number assigned to the event.. Valid values are `^[A-Z]{2}-[0-9]{4}$`',
    `geographic_footprint_description` STRING COMMENT 'Narrative description of the geographic area impacted by the catastrophe event.',
    `industry_loss_estimate_amount` DECIMAL(18,2) COMMENT 'Estimated total insured loss across the entire insurance industry for this catastrophe event in USD.',
    `industry_loss_estimate_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the industry loss estimate.. Valid values are `^[A-Z]{3}$`',
    `iso_cat_serial_number` STRING COMMENT 'Industry-standard ISO serial number uniquely identifying the catastrophe event for cross-carrier reporting.. Valid values are `^[A-Z0-9]{6,12}$`',
    `loss_development_factor` DECIMAL(5,4) COMMENT 'Factor representing the ratio of ultimate loss to reported loss, used for IBNR estimation.',
    `magnitude_scale` STRING COMMENT 'Name of the scale used to measure event magnitude (e.g., Richter, Moment Magnitude, Saffir-Simpson, Enhanced Fujita).',
    `magnitude_value` DECIMAL(5,2) COMMENT 'Quantitative measure of event intensity (e.g., Richter scale for earthquakes, Saffir-Simpson for hurricanes).',
    `modeled_loss_amount` DECIMAL(18,2) COMMENT 'Loss amount calculated by catastrophe modeling software for this event in USD.',
    `nfip_participation_flag` BOOLEAN COMMENT 'Indicates whether the event triggered NFIP claims and participation.',
    `notes` STRING COMMENT 'Additional notes or comments regarding the catastrophe event for internal reference.',
    `peril_type` STRING COMMENT 'Primary peril classification of the catastrophe event.. Valid values are `hurricane|earthquake|wildfire|flood|tornado|hail`',
    `pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for this catastrophe event based on exposure modeling in USD.',
    `pml_class` STRING COMMENT 'Classification of the event based on probable maximum loss severity.. Valid values are `minor|moderate|major|severe|catastrophic`',
    `precipitation_inches` DECIMAL(6,2) COMMENT 'Total precipitation recorded during the event in inches, applicable to flood and storm events.',
    `reinsurance_trigger_flag` BOOLEAN COMMENT 'Indicates whether this catastrophe event triggered reinsurance treaty or facultative coverage.',
    `return_period_years` BIGINT COMMENT 'Statistical return period in years indicating the expected frequency of an event of this magnitude.',
    `storm_surge_feet` DECIMAL(6,2) COMMENT 'Maximum storm surge height recorded in feet, applicable to hurricanes and coastal flooding events.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe event record was last modified.',
    `wind_speed_mph` BIGINT COMMENT 'Maximum sustained wind speed recorded during the event in miles per hour, applicable to hurricanes and tornadoes.',
    CONSTRAINT pk_catastrophe_event PRIMARY KEY(`catastrophe_event_id`)
) COMMENT 'Master record of a named CAT event (hurricane, quake, wildfire, flood, tornado), one row per event. Captures event type, peril, date range, footprint, industry loss estimate, PML class, ISO CAT serial number, event name, and affected states for statutory';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` (
    `cat_zone_id` BIGINT COMMENT 'Unique identifier for the catastrophe zone. Primary key.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: CAT zone definitions and PML values are based on specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: CAT zones are defined by peril type. Adding peril_id FK to peril reference table for referential integrity. peril_type remains for operational queries.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: CAT zones have geographic scope and should link to the geography hierarchy for spatial analysis.',
    `aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount in USD expected from catastrophe events in this zone, used for reinsurance treaty pricing and capital allocation.',
    `concentration_threshold_amount` DECIMAL(18,2) COMMENT 'Maximum total insured value in USD allowed in this zone before underwriting referral or capacity restrictions are triggered.',
    `concentration_threshold_percentage` DECIMAL(5,2) COMMENT 'Maximum percentage of total company exposure allowed in this zone before underwriting referral or capacity restrictions are triggered.',
    `country_code` STRING COMMENT 'Three-letter ISO country code where this catastrophe zone is located, used for international exposure reporting.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe zone record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when this catastrophe zone definition became effective for underwriting and exposure aggregation.',
    `expiration_date` DATE COMMENT 'Date when this catastrophe zone definition expires or is superseded by a new version. Null for open-ended zones.',
    `geographic_scope` STRING COMMENT 'Geographic boundaries of the catastrophe zone, such as county list, ZIP code ranges, or latitude/longitude bounding box.',
    `iso_territory_code` STRING COMMENT 'ISO-standardized territory code used for rating and catastrophe zone classification in ISO-based rating plans.',
    `last_cat_event_date` DATE COMMENT 'Date of the most recent catastrophe event that impacted this zone, used for loss history and model validation.',
    `last_cat_event_loss_amount` DECIMAL(18,2) COMMENT 'Total incurred loss amount in USD from the most recent catastrophe event in this zone, used for model validation and pricing.',
    `last_cat_event_name` STRING COMMENT 'Name of the most recent catastrophe event that impacted this zone, such as Hurricane Ian or Northridge Earthquake.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe zone record was most recently modified, including model updates or threshold changes.',
    `model_update_date` DATE COMMENT 'Date when the catastrophe model version for this zone was last updated or recalibrated.',
    `model_version` STRING COMMENT 'Version identifier of the catastrophe model used to define this zone, such as RMS v21.0 or AIR v18.1.',
    `modeling_vendor` STRING COMMENT 'Catastrophe modeling vendor whose model defines this zone: RMS, AIR, CoreLogic, KCC, or Internal proprietary model.. Valid values are `RMS|AIR|CoreLogic|KCC|Internal`',
    `moratorium_end_date` DATE COMMENT 'Date when the current catastrophe moratorium is scheduled to end for this zone. Null if no moratorium or open-ended.',
    `moratorium_flag` BOOLEAN COMMENT 'Indicates whether a catastrophe moratorium is currently in effect, prohibiting new business or policy changes in this zone.',
    `moratorium_start_date` DATE COMMENT 'Date when the current catastrophe moratorium began for this zone. Null if no moratorium is in effect.',
    `naic_territory_code` STRING COMMENT 'NAIC-standardized territory code mapping this catastrophe zone to regulatory reporting categories.',
    `peril_type` STRING COMMENT 'Primary catastrophe peril associated with this zone: wind, earthquake, flood, hail, wildfire, or tornado.. Valid values are `wind|earthquake|flood|hail|wildfire|tornado`',
    `pml_100_year_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount in USD for a 100-year return period event in this zone, used for reinsurance attachment point determination.',
    `pml_250_year_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount in USD for a 250-year return period event in this zone, used for catastrophe excess of loss treaty structuring.',
    `pml_500_year_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount in USD for a 500-year return period event in this zone, used for regulatory capital and solvency modeling.',
    `policy_count` BIGINT COMMENT 'Number of active policies currently assigned to this catastrophe zone for exposure aggregation and concentration monitoring.',
    `regulatory_reporting_code` STRING COMMENT 'Code used for catastrophe zone reporting to state departments of insurance and NAIC annual statement Schedule P catastrophe supplement.',
    `reinsurance_attachment_point` DECIMAL(18,2) COMMENT 'Loss amount in USD at which catastrophe excess of loss reinsurance coverage attaches for events in this zone.',
    `reinsurance_limit` DECIMAL(18,2) COMMENT 'Maximum reinsurance recovery amount in USD available for catastrophe events in this zone under current treaty structure.',
    `state_code` STRING COMMENT 'Two-letter US state code where this catastrophe zone is primarily located, used for regulatory jurisdiction determination.. Valid values are `^[A-Z]{2}$`',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value in USD of all policies and insured risks currently assigned to this catastrophe zone.',
    `underwriting_restriction_flag` BOOLEAN COMMENT 'Indicates whether new business or renewal underwriting restrictions are currently in effect for this catastrophe zone.',
    `zone_code` STRING COMMENT 'Insurer-defined alphanumeric code uniquely identifying the catastrophe zone for rating and exposure aggregation.. Valid values are `^[A-Z0-9]{2,20}$`',
    `zone_description` STRING COMMENT 'Detailed description of the catastrophe zone, including geographic boundaries, peril characteristics, and modeling assumptions.',
    `zone_name` STRING COMMENT 'Human-readable name of the catastrophe zone, such as Florida Wind Zone 1 or California Earthquake Zone A.',
    `zone_status` STRING COMMENT 'Current lifecycle status of the catastrophe zone: active for rating, inactive, suspended, or under review for model updates.. Valid values are `active|inactive|suspended|under_review`',
    `zone_tier` STRING COMMENT 'Risk tier classification of the catastrophe zone based on loss frequency and severity: tier 1 highest risk, tier 4 lowest risk.. Valid values are `tier_1|tier_2|tier_3|tier_4`',
    CONSTRAINT pk_cat_zone PRIMARY KEY(`cat_zone_id`)
) COMMENT 'Insurer-defined CAT zone or territory used for exposure aggregation and PML modeling. One row per zone. Zones map to peril types (wind, quake, flood) and carry AAL and PML thresholds for reinsurance treaty attachment.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` (
    `geography_id` BIGINT COMMENT 'Unique identifier for the geography hierarchy node. Primary key.',
    `parent_geography_id` BIGINT COMMENT 'Reference to the parent geography node in the hierarchy, enabling recursive drill-up from ZIP to county to state to country.',
    `catastrophe_zone` STRING COMMENT 'Catastrophe exposure zone classification (e.g., hurricane, earthquake, wildfire, flood) for PML (Probable Maximum Loss) and AAL (Average Annual Loss) modeling.',
    `census_tract_code` STRING COMMENT 'US Census Bureau tract identifier, an 11-digit code combining state, county, and tract, used for demographic and socioeconomic analysis.',
    `coastal_indicator` BOOLEAN COMMENT 'Flag indicating whether the geography unit is within a coastal exposure zone, subject to hurricane, storm surge, or coastal flood risk.',
    `geography_code` STRING COMMENT 'Standard code for the geography unit: ISO 3166 country code, FIPS state/county code, ZIP code, CRESTA zone code, or census tract identifier.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code for the geography unit, enabling global aggregation and regulatory reporting.. Valid values are `^[A-Z]{3}$`',
    `county_code` STRING COMMENT 'FIPS county code, a five-digit identifier combining state and county codes, used for granular territory rating and catastrophe aggregation.',
    `cresta_zone_code` STRING COMMENT 'CRESTA zone identifier for catastrophe modeling and reinsurance reporting, standardizing geographic aggregation for CAT exposure.',
    `earthquake_zone` STRING COMMENT 'Seismic hazard zone classification for earthquake exposure, used in catastrophe modeling and underwriting.',
    `effective_date` DATE COMMENT 'Date when this geography record became effective, supporting temporal analysis and historical territory rating.',
    `expiration_date` DATE COMMENT 'Date when this geography record expires or is superseded, supporting temporal analysis and historical territory rating. Null for current records.',
    `flood_zone` STRING COMMENT 'FEMA flood hazard zone designation (e.g., A, AE, X, V) for flood exposure assessment and NFIP (National Flood Insurance Program) compliance.',
    `geography_status` STRING COMMENT 'Current lifecycle status of the geography record: active for in-use geographies, inactive for discontinued, deprecated for superseded, pending for future.. Valid values are `active|inactive|deprecated|pending`',
    `geography_type` STRING COMMENT 'Classification of the geography node: country, state, county, ZIP, CRESTA zone, or census tract.. Valid values are `country|state|county|zip|cresta_zone|census_tract`',
    `hail_zone` STRING COMMENT 'Hail hazard zone classification for severe convective storm exposure, used in catastrophe modeling and underwriting.',
    `last_updated_date` DATE COMMENT 'Date when this geography record was last updated, supporting data quality audits and change tracking.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate in decimal degrees for the centroid of the geography unit, enabling spatial analysis and catastrophe modeling.',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate in decimal degrees for the centroid of the geography unit, enabling spatial analysis and catastrophe modeling.',
    `median_household_income` DECIMAL(15,2) COMMENT 'Median household income in US dollars for the geography unit, used for socioeconomic segmentation and underwriting.',
    `geography_name` STRING COMMENT 'Human-readable name of the geography unit, such as United States, California, Los Angeles County, or 90210.',
    `population` BIGINT COMMENT 'Total population count for the geography unit, used for exposure density analysis and market sizing.',
    `rating_territory` STRING COMMENT 'Actuarial rating territory grouping for premium calculation, aggregating geographies into homogeneous risk pools.',
    `state_code` STRING COMMENT 'Two-letter state or province abbreviation (e.g., CA, NY, TX) for US and Canadian geographies, used in territory rating and statutory reporting.',
    `territory_code` STRING COMMENT 'Insurer-defined territory code used in rating and pricing, mapping geography to rate tables and underwriting rules.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the geography unit, used for timestamp normalization and operational scheduling.',
    `tornado_zone` STRING COMMENT 'Tornado hazard zone classification for severe convective storm exposure, used in catastrophe modeling and underwriting.',
    `urban_rural_code` STRING COMMENT 'US Census Bureau urban-rural classification code, used for demographic segmentation and territory rating.',
    `wildfire_zone` STRING COMMENT 'Wildfire hazard zone classification for wildfire exposure, used in catastrophe modeling and underwriting.',
    `wind_zone` STRING COMMENT 'Wind hazard zone classification for hurricane and windstorm exposure, used in catastrophe modeling and underwriting.',
    `zip_code` STRING COMMENT 'Five-digit or nine-digit ZIP code (ZIP+4) for US locations, used in rating, underwriting, and catastrophe exposure aggregation.',
    CONSTRAINT pk_geography PRIMARY KEY(`geography_id`)
) COMMENT 'Enterprise geography hierarchy node (country, state, county, ZIP, CRESTA zone, census tract). One row per geography unit. Provides the spatial backbone for territory rating, CAT aggregation, and regulatory reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` (
    `geography_hierarchy_id` BIGINT COMMENT 'Unique identifier for each ancestor-descendant pair in the geography hierarchy closure table.',
    `primary_ancestor_geography_id` BIGINT COMMENT 'Identifier of the ancestor node in the geography hierarchy. Links to the parent or higher-level geography entity.',
    `aggregation_weight` DECIMAL(10,4) COMMENT 'Weighting factor applied when aggregating exposure or premium from descendant to ancestor. Used for proportional allocation in overlapping territories or catastrophe zones.',
    `ancestor_geography_type` STRING COMMENT 'Classification of the ancestor geography node. Indicates the hierarchical level such as national, region, state, territory, county, zip, or catastrophe zone.',
    `cat_zone_indicator` BOOLEAN COMMENT 'Indicates whether this hierarchy path includes a catastrophe zone node. True when the relationship is used for catastrophe exposure aggregation and Probable Maximum Loss (PML) modeling.',
    `country_code` STRING COMMENT 'Three-letter ISO country code for the geography node. Supports international operations and cross-border exposure aggregation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this hierarchy relationship record was first created in the system. Used for audit trail and data lineage tracking.',
    `depth_level` BIGINT COMMENT 'Number of levels between ancestor and descendant. Zero indicates self-reference, one indicates direct parent-child, higher values indicate multi-level relationships.',
    `descendant_geography_type` STRING COMMENT 'Classification of the descendant geography node. Indicates the hierarchical level such as national, region, state, territory, county, zip, or catastrophe zone.',
    `effective_date` DATE COMMENT 'Date when this ancestor-descendant relationship became effective. Supports temporal hierarchy changes such as territory realignments or catastrophe zone redefinitions.',
    `expiration_date` DATE COMMENT 'Date when this ancestor-descendant relationship expired or was superseded. Null indicates the relationship is currently active.',
    `hierarchy_status` STRING COMMENT 'Current status of this hierarchy relationship. Active indicates in use, inactive indicates retired, pending indicates future effective, superseded indicates replaced by newer version.. Valid values are `active|inactive|pending|superseded`',
    `hierarchy_version` STRING COMMENT 'Version identifier for the geography hierarchy structure. Allows tracking of hierarchy changes over time for regulatory reporting and historical analysis.',
    `is_leaf_node` BOOLEAN COMMENT 'Indicates whether the descendant node is a leaf node with no children. True for terminal nodes such as zip codes or specific locations.',
    `is_root_node` BOOLEAN COMMENT 'Indicates whether the ancestor node is a root node with no parent. True for top-level nodes such as national or enterprise-wide geography.',
    `iso_territory_code` STRING COMMENT 'ISO territory code for rating and underwriting purposes. Links geography hierarchy to ISO rating territories for premium calculation and risk classification.',
    `lob_code` STRING COMMENT 'Line of business code for which this hierarchy path is applicable. Allows different geographic hierarchies for different product lines such as Personal Auto (PAP), Homeowners (HO), or Commercial General Liability (CGL).',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this hierarchy relationship record was last modified. Used for audit trail and change tracking.',
    `naic_company_code` STRING COMMENT 'NAIC company code for which this hierarchy path is applicable. Supports multi-company operations with different geographic structures.',
    `notes` STRING COMMENT 'Free-text notes or comments about this hierarchy relationship. Used to document special aggregation rules, exceptions, or business context.',
    `path_length` BIGINT COMMENT 'Total number of edges in the path from ancestor to descendant. Used for traversal optimization and distance calculation.',
    `relationship_type` STRING COMMENT 'Type of hierarchical relationship between ancestor and descendant. Self indicates same node, direct parent indicates immediate parent-child, ancestor indicates multi-level, rollup indicates aggregation path.. Valid values are `self|direct_parent|ancestor|rollup`',
    `schedule_p_territory_code` STRING COMMENT 'NAIC Schedule P territory code associated with this hierarchy path. Used for statutory financial reporting and loss reserve disclosure by geographic territory.',
    `state_code` STRING COMMENT 'Two-letter state code for the geography node. Denormalized for regulatory reporting and state-level aggregation. Follows USPS state abbreviation standards.',
    CONSTRAINT pk_geography_hierarchy PRIMARY KEY(`geography_hierarchy_id`)
) COMMENT 'Parent-child closure table for the geography hierarchy. Stores ancestor-descendant pairs with depth level so any node can be rolled up to state, region, or national level for exposure aggregation and Schedule P reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` (
    `territory_id` BIGINT COMMENT 'Unique identifier for the rating territory. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Territories are associated with CAT zones for exposure aggregation and PML analysis. Adding cat_zone_id FK for referential integrity.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Territories are geographic rating units that should link to the geography hierarchy for spatial analysis.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Rating territories are LOB-specific constructs—personal auto territories differ from homeowners, commercial property, and workers compensation territories.',
    `aal_contribution_pct` DECIMAL(5,2) COMMENT 'Percentage contribution of this territory to the overall portfolio AAL for catastrophe risk management.',
    `approval_date` DATE COMMENT 'Date on which the Department of Insurance approved the rate filing containing this territory definition.',
    `base_rate` DECIMAL(12,2) COMMENT 'The base premium rate per unit of exposure for this territory, as filed with the DOI.',
    `territory_code` STRING COMMENT 'The filed territory code as submitted to and approved by the Department of Insurance for rating purposes.. Valid values are `^[A-Z0-9]{1,10}$`',
    `county_list` STRING COMMENT 'Comma-separated list of county names or FIPS codes included in this territory definition.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this territory record was first created in the system.',
    `crime_index` DECIMAL(8,4) COMMENT 'Composite crime index score for the territory, used in underwriting and pricing for property and liability lines.',
    `effective_date` DATE COMMENT 'Date on which this territory definition and its associated rate relativities become effective for new and renewal business.',
    `expiration_date` DATE COMMENT 'Date on which this territory definition expires or is superseded by a new filing. Null if currently in force.',
    `exposure_base` STRING COMMENT 'The unit of exposure to which the rate or loss cost applies, such as per policy, per vehicle, per location, per 100 of payroll.. Valid values are `per_policy|per_vehicle|per_location|per_100_payroll|per_1000_si`',
    `filing_date` DATE COMMENT 'Date on which the rate filing containing this territory definition was submitted to the Department of Insurance.',
    `filing_number` STRING COMMENT 'The official rate filing number assigned by the Department of Insurance for this territory definition.. Valid values are `^[A-Z0-9-]{1,20}$`',
    `filing_status` STRING COMMENT 'Current regulatory status of the rate filing containing this territory definition.. Valid values are `pending|approved|rejected|withdrawn|superseded`',
    `geographic_region` STRING COMMENT 'Classification of the territory by geographic characteristics relevant to risk assessment and pricing.. Valid values are `coastal|inland|urban|suburban|rural`',
    `loss_cost` DECIMAL(12,2) COMMENT 'The expected loss cost per unit of exposure for this territory, used in actuarial pricing and rate development.',
    `median_household_income` DECIMAL(12,2) COMMENT 'Median household income for the territory, used in underwriting and socioeconomic risk assessment.',
    `moratorium_effective_date` DATE COMMENT 'Date on which the current moratorium became effective, if applicable.',
    `moratorium_expiration_date` DATE COMMENT 'Date on which the current moratorium is scheduled to expire, if applicable.',
    `moratorium_flag` BOOLEAN COMMENT 'Indicates whether a binding or quoting moratorium is currently in effect for this territory due to catastrophe or regulatory action.',
    `territory_name` STRING COMMENT 'Human-readable name or description of the territory, often referencing geographic boundaries or county groupings.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this territory definition, including special instructions or historical context.',
    `pml_contribution_pct` DECIMAL(5,2) COMMENT 'Percentage contribution of this territory to the overall portfolio PML for catastrophe risk management.',
    `population_density` DECIMAL(10,2) COMMENT 'Average population density per square mile for the territory, used in risk assessment and pricing.',
    `protection_class_range` STRING COMMENT 'Range of ISO Public Protection Classification codes applicable to this territory for property rating.',
    `rate_relativity` DECIMAL(10,6) COMMENT 'The filed rate relativity factor for this territory, representing the multiplicative adjustment to base rates.',
    `residual_market_flag` BOOLEAN COMMENT 'Indicates whether this territory is designated as a residual or involuntary market territory requiring special handling.',
    `state_code` STRING COMMENT 'Two-letter postal abbreviation of the state or jurisdiction where this territory is filed and effective.. Valid values are `^[A-Z]{2}$`',
    `tier` STRING COMMENT 'Tiering classification within the territory for additional rate segmentation, if applicable.. Valid values are `^[A-Z0-9]{1,5}$`',
    `tiv_concentration` DECIMAL(18,2) COMMENT 'Total insured value concentration within this territory, used for exposure management and catastrophe aggregation.',
    `underwriting_tier` STRING COMMENT 'Underwriting tier classification for this territory, indicating appetite and risk selection guidelines.. Valid values are `preferred|standard|substandard|declined`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this territory record was last modified in the system.',
    `weather_zone` STRING COMMENT 'Code identifying the weather or climate zone for this territory, relevant for catastrophe and weather-related perils.. Valid values are `^[A-Z0-9]{1,10}$`',
    `wind_pool_flag` BOOLEAN COMMENT 'Indicates whether this territory is subject to state wind pool or catastrophe fund requirements for coastal exposure.',
    `zip_code_list` STRING COMMENT 'Comma-separated list of ZIP codes or ZIP code ranges included in this territory definition.',
    CONSTRAINT pk_territory PRIMARY KEY(`territory_id`)
) COMMENT 'Rating territory as filed with the DOI per state and LOB. One row per territory per LOB per state. Carries territory code, effective date, filed rate relativities, residual-market/wind-pool designation flags, and links to the geography hierarchy for';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` (
    `catastrophegeography_peril_id` BIGINT COMMENT 'Unique identifier for the peril. Primary key.',
    `cat_model_peril_code` STRING COMMENT 'Peril code used in catastrophe modeling platforms such as RMS RiskLink or AIR Touchstone for exposure and loss estimation.',
    `catastrophegeography_peril_status` STRING COMMENT 'Current lifecycle status of the peril definition: active for use, inactive, deprecated, or pending regulatory approval.. Valid values are `active|inactive|deprecated|pending`',
    `catastrophegeography_peril_category` STRING COMMENT 'High-level classification of the peril into natural disasters, man-made events, liability exposures, or other categories.. Valid values are `natural|man-made|liability|other`',
    `catastrophegeography_peril_code` STRING COMMENT 'Standard alphanumeric code identifying the peril type, used across policy administration and claims systems.. Valid values are `^[A-Z0-9]{2,10}$`',
    `coverage_form_applicability` STRING COMMENT 'Comma-separated list of ISO or proprietary coverage forms where this peril is included or excluded, such as HO-3, DP-1, CP 10 30, CGL.',
    `catastrophegeography_peril_description` STRING COMMENT 'Detailed description of the peril, including scope, typical coverage scenarios, and exclusions.',
    `effective_date` DATE COMMENT 'Date when this peril definition became effective for underwriting, rating, and claims purposes.',
    `endorsement_required` STRING COMMENT 'ISO or proprietary endorsement form number required to add coverage for this peril, if not included in base policy.',
    `expiration_date` DATE COMMENT 'Date when this peril definition expires or is superseded by a new version, nullable for currently active perils.',
    `fraud_risk_level` STRING COMMENT 'Assessment of the relative fraud risk associated with claims for this peril, used for SIU referral and investigation prioritization.. Valid values are `high|medium|low`',
    `frequency_classification` STRING COMMENT 'Actuarial classification of the perils expected frequency of occurrence: high, medium, low, or rare.. Valid values are `high|medium|low|rare`',
    `geographic_restriction` STRING COMMENT 'Description of geographic zones or territories where this peril is restricted, excluded, or subject to special underwriting rules.',
    `is_cat_peril` BOOLEAN COMMENT 'Indicates whether the peril is classified as a catastrophe peril for exposure aggregation, PML modeling, and reinsurance treaty purposes.',
    `is_covered_by_standard_policy` BOOLEAN COMMENT 'Indicates whether the peril is typically covered under standard policy forms or requires special endorsement or separate policy.',
    `is_excluded_by_default` BOOLEAN COMMENT 'Indicates whether the peril is excluded from standard coverage and requires explicit endorsement or separate policy to be covered.',
    `is_reportable_to_naic` BOOLEAN COMMENT 'Indicates whether losses from this peril must be reported separately in NAIC Annual Statement Schedule P or other statutory filings.',
    `is_subject_to_state_regulation` BOOLEAN COMMENT 'Indicates whether coverage for this peril is subject to special state-level regulatory requirements, rate approval, or mandatory availability.',
    `iso_cause_of_loss_code` STRING COMMENT 'ISO-standardized cause-of-loss code used in policy forms, rating, and claims adjudication.. Valid values are `^[A-Z0-9]{2,6}$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this peril record was last modified in the reference catalog.',
    `lob_applicability` STRING COMMENT 'Comma-separated list of lines of business where this peril is relevant, such as Homeowners, Commercial Property, Auto Physical Damage, General Liability.',
    `naic_peril_code` STRING COMMENT 'NAIC-standardized numeric code for statutory reporting and regulatory filings, used in Schedule P and Annual Statement.. Valid values are `^[0-9]{2,4}$`',
    `catastrophegeography_peril_name` STRING COMMENT 'Full business name of the peril, such as Wind, Hail, Earthquake, Flood, Fire, Theft, or Liability.',
    `nfip_covered` BOOLEAN COMMENT 'Indicates whether the peril is covered under the National Flood Insurance Program, relevant for flood perils.',
    `notes` STRING COMMENT 'Free-text field for additional notes, special instructions, or clarifications regarding the peril definition and usage.',
    `reinsurance_treaty_peril_mapping` STRING COMMENT 'Mapping code or identifier used to link this peril to reinsurance treaty terms, cession rules, and recovery calculations.',
    `requires_separate_deductible` BOOLEAN COMMENT 'Indicates whether the peril requires a separate deductible, often expressed as a percentage of insured value for CAT perils.',
    `requires_separate_limit` BOOLEAN COMMENT 'Indicates whether the peril requires a separate coverage limit distinct from the main policy limit, common for flood, earthquake, or wind.',
    `requires_specialist_adjuster` BOOLEAN COMMENT 'Indicates whether claims for this peril typically require assignment to a specialist adjuster with specific expertise.',
    `salvage_potential` STRING COMMENT 'Assessment of the likelihood that damaged property from this peril can be salvaged and sold to offset claim costs.. Valid values are `high|medium|low|none`',
    `seasonal_pattern` STRING COMMENT 'Description of seasonal occurrence patterns for the peril, such as hurricane season June-November, wildfire season summer-fall.',
    `severity_classification` STRING COMMENT 'Actuarial classification of the perils expected loss severity: catastrophic, severe, moderate, or minor.. Valid values are `catastrophic|severe|moderate|minor`',
    `subrogation_potential` STRING COMMENT 'Assessment of the likelihood that losses from this peril can be recovered through subrogation against third parties.. Valid values are `high|medium|low|none`',
    `typical_deductible_type` STRING COMMENT 'Standard deductible structure applied to this peril: flat dollar amount, percentage of insured value, franchise, or disappearing deductible.. Valid values are `flat|percentage|franchise|disappearing`',
    `typical_investigation_complexity` STRING COMMENT 'Standard level of investigation complexity required for claims involving this peril, affecting adjuster assignment and LAE.. Valid values are `simple|moderate|complex|highly_complex`',
    `version_number` STRING COMMENT 'Version identifier for this peril definition, incremented when classification, codes, or business rules change.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_catastrophegeography_peril PRIMARY KEY(`catastrophegeography_peril_id`)
) COMMENT 'Reference catalog of insured perils (wind, hail, earthquake, flood, fire, theft, liability). One row per peril. Carries NAIC peril code, CAT vs. non-CAT flag, reinsurance treaty peril mapping, and ISO cause-of-loss code.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` (
    `hazard_score_id` BIGINT COMMENT 'Unique identifier for the hazard score record. Primary key.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Hazard scores are produced by specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `cat_zone_id` BIGINT COMMENT 'Reference to the catastrophe zone or territory containing this location.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Hazard scores are calculated per peril. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `location_id` BIGINT COMMENT 'Reference to the geographic location being scored.',
    `aal_amount` DECIMAL(18,2) COMMENT 'Expected average annual loss amount for this location and peril, expressed in USD.',
    `building_area_sqft` DECIMAL(12,2) COMMENT 'Total building area in square feet at the location.',
    `cat_model_vendor` STRING COMMENT 'Vendor providing the catastrophe model: RMS, AIR, EQECAT, Karen Clark, or internal proprietary model.. Valid values are `RMS|AIR|EQECAT|KAREN_CLARK|INTERNAL`',
    `construction_type` STRING COMMENT 'ISO construction class of the building at the location: frame, joisted masonry, non-combustible, masonry non-combustible, modified fire resistive, or fire resistive.. Valid values are `FRAME|JOISTED_MASONRY|NON_COMBUSTIBLE|MASONRY_NON_COMBUSTIBLE|MODIFIED_FIRE_RESISTIVE|FIRE_RESISTIVE`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this hazard score record was first created in the system.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Numeric score indicating the quality and completeness of input data used for hazard modeling, typically ranging from 0 to 100.',
    `distance_to_coast_miles` DECIMAL(8,2) COMMENT 'Distance from the location to the nearest coastline in miles, relevant for hurricane and storm surge modeling.',
    `elevation_feet` DECIMAL(10,2) COMMENT 'Elevation of the location above sea level in feet, relevant for flood and storm surge modeling.',
    `eligibility_reason` STRING COMMENT 'Explanation for underwriting eligibility determination, including any risk appetite thresholds exceeded or met.',
    `exceedance_probability` DECIMAL(8,6) COMMENT 'Annual probability that losses will exceed a specified threshold for this location and peril, expressed as a decimal between 0 and 1.',
    `flood_zone` STRING COMMENT 'FEMA flood zone designation for the location, indicating flood risk level.',
    `geocode_quality` STRING COMMENT 'Precision level of the geocoding used for hazard scoring: rooftop, parcel, street, ZIP code, city, or county level.. Valid values are `ROOFTOP|PARCEL|STREET|ZIP|CITY|COUNTY`',
    `hazard_band` STRING COMMENT 'Categorical risk band assigned based on hazard score: low, moderate, high, severe, or extreme. Used for underwriting eligibility screening.. Valid values are `LOW|MODERATE|HIGH|SEVERE|EXTREME`',
    `hazard_score` DECIMAL(10,4) COMMENT 'Normalized hazard intensity score for the location and peril, typically ranging from 0 to 100 or 0 to 1000 depending on vendor scale.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the scored location in decimal degrees.',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the scored location in decimal degrees.',
    `model_confidence_level` STRING COMMENT 'Confidence level in the hazard score based on data quality and model certainty: high, medium, or low.. Valid values are `HIGH|MEDIUM|LOW`',
    `model_run_date` DATE COMMENT 'Date when the catastrophe model was executed to produce this hazard score.',
    `model_version` STRING COMMENT 'Version identifier of the catastrophe model used to generate this score.',
    `number_of_stories` BIGINT COMMENT 'Total number of above-ground stories in the building at the location.',
    `occupancy_type` STRING COMMENT 'Primary use or occupancy classification of the building at the location.',
    `peril_code` STRING COMMENT 'Type of catastrophe peril being modeled: wind, earthquake, flood, hail, fire, tornado, hurricane, wildfire, storm surge, or tsunami. [ENUM-REF-CANDIDATE: WIND|QUAKE|FLOOD|HAIL|FIRE|TORNADO|HURRICANE|WILDFIRE|STORM_SURGE|TSUNAMI — 10 candidates stripped',
    `pml_1000_year` DECIMAL(18,2) COMMENT 'Estimated loss amount at the 1000-year return period for this location and peril, expressed in USD.',
    `pml_100_year` DECIMAL(18,2) COMMENT 'Estimated loss amount at the 100-year return period for this location and peril, expressed in USD.',
    `pml_250_year` DECIMAL(18,2) COMMENT 'Estimated loss amount at the 250-year return period for this location and peril, expressed in USD.',
    `pml_500_year` DECIMAL(18,2) COMMENT 'Estimated loss amount at the 500-year return period for this location and peril, expressed in USD.',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification code indicating fire protection quality at the location, ranging from 1 (best) to 10 (worst).',
    `score_effective_date` DATE COMMENT 'Date from which this hazard score is effective for underwriting and pricing decisions.',
    `score_expiration_date` DATE COMMENT 'Date after which this hazard score is no longer valid and should be refreshed.',
    `soil_type` STRING COMMENT 'Soil classification at the location, relevant for earthquake modeling: rock, stiff soil, soft soil, or very soft soil.. Valid values are `ROCK|STIFF_SOIL|SOFT_SOIL|VERY_SOFT_SOIL`',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value at the location used as the basis for loss calculations, expressed in USD.',
    `underwriting_eligibility_flag` BOOLEAN COMMENT 'Indicates whether the location passes underwriting eligibility criteria based on hazard score and band. True if eligible, false if ineligible.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this hazard score record was last modified.',
    `year_built` BIGINT COMMENT 'Year the building at the location was originally constructed.',
    CONSTRAINT pk_hazard_score PRIMARY KEY(`hazard_score_id`)
) COMMENT 'Point-in-time hazard score assigned to a geographic location for a specific peril by the CAT model (RMS/AIR). One row per location per peril per model version. Stores AAL, PML return periods, and hazard band for underwriting eligibility.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` (
    `exposure_summary_id` BIGINT COMMENT 'Unique identifier for the exposure summary record. Primary key.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Exposure summaries with PML and AAL are calculated using specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Exposure summaries can be aggregated by CAT zone. zone_code is a STRING denormalized attribute; adding proper zone_id FK for referential integrity.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to a specific catastrophe event if this exposure summary is event-specific (e.g., post-event exposure analysis). Null for general exposure summaries.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Exposure summaries are aggregated by peril. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `geography_id` BIGINT COMMENT 'Reference to the geographic hierarchy node (state, county, ZIP, territory, zone) for which exposure is aggregated.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Normalize lob_code string to FK reference to shared.line_of_business master data. Exposure summary currently stores lob_code as string; replacing with FK enables consistent LOB',
    `aal_amount` DECIMAL(18,2) COMMENT 'The average annual loss estimate for this geography, peril, and LOB combination. Represents the expected loss in a typical year from catastrophe events.',
    `as_of_date` DATE COMMENT 'The accounting or valuation date for which this exposure snapshot was calculated. Enables point-in-time exposure reporting.',
    `calculation_timestamp` TIMESTAMP COMMENT 'The date and time when this exposure summary was calculated. Enables tracking of calculation runs and data freshness.',
    `concentration_index` DECIMAL(10,6) COMMENT 'A normalized measure of exposure concentration within this geography, peril, and LOB. Higher values indicate greater concentration risk. Calculated as TIV divided by geographic area or policy count.',
    `construction_class` STRING COMMENT 'The predominant construction type of insured risks within this exposure aggregation: frame, masonry, steel, concrete, or mixed construction.. Valid values are `FRAME|MASONRY|STEEL|CONCRETE|MIXED`',
    `currency_code` STRING COMMENT 'The ISO 4217 three-letter currency code for all monetary amounts in this record. Typically USD for US-based P&C insurers.. Valid values are `USD`',
    `data_quality_score` DECIMAL(5,2) COMMENT 'A quality score (0-100) indicating the completeness and accuracy of underlying exposure data used in this aggregation. Higher scores indicate better data quality.',
    `exposure_basis` STRING COMMENT 'The basis on which exposure is measured: TIV (Total Insured Value), LIMIT (Policy Limit), PREMIUM (Written Premium), UNIT_COUNT (Number of Units/Risks).. Valid values are `TIV|LIMIT|PREMIUM|UNIT_COUNT`',
    `geocoding_accuracy` STRING COMMENT 'The predominant geocoding accuracy level of insured locations within this aggregation: rooftop (most precise), street, ZIP code, county, or state level.. Valid values are `ROOFTOP|STREET|ZIP|COUNTY|STATE`',
    `gwp_amount` DECIMAL(18,2) COMMENT 'The gross written premium aggregated across all policies within this geography, peril, and LOB combination as of the as-of date. Represents premium exposure.',
    `insured_risk_count` BIGINT COMMENT 'The number of distinct insured risks (locations, buildings, vehicles, drivers) contributing to this exposure aggregation as of the as-of date.',
    `model_version` STRING COMMENT 'The version identifier of the catastrophe model used to calculate PML and AAL estimates (e.g., RMS v21.0, AIR v23.1). Enables model version tracking and comparison.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this exposure summary, including data quality issues, modeling assumptions, or special considerations.',
    `nwp_amount` DECIMAL(18,2) COMMENT 'The net written premium (gross written premium less ceded reinsurance premium) aggregated across all policies within this geography, peril, and LOB combination as of the as-of date.',
    `occupancy_class` STRING COMMENT 'The predominant occupancy class of insured risks within this exposure aggregation: residential, commercial, industrial, agricultural, or mixed use.. Valid values are `RESIDENTIAL|COMMERCIAL|INDUSTRIAL|AGRICULTURAL|MIXED`',
    `peril_code` STRING COMMENT 'The insured peril or cause of loss for which exposure is aggregated (fire, wind, hail, flood, earthquake, theft, liability, collision, comprehensive, other).',
    `pml_amount` DECIMAL(18,2) COMMENT 'The probable maximum loss estimate for this geography, peril, and LOB combination at a specified return period (typically 250-year or 500-year). Represents catastrophe exposure.',
    `pml_return_period_years` BIGINT COMMENT 'The return period in years for which the PML amount was calculated (e.g., 100, 250, 500). Standard catastrophe modeling return periods.',
    `policy_count` BIGINT COMMENT 'The number of distinct policies in force contributing to this exposure aggregation as of the as-of date.',
    `protection_class` STRING COMMENT 'The ISO Public Protection Classification (PPC) or fire protection class code representing the quality of fire protection services in this geography. Lower numbers indicate better protection (1-10 scale).',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this exposure summary is used for regulatory reporting purposes (NAIC Annual Statement, catastrophe reporting, RBC calculations). True if used for regulatory reporting.',
    `retention_amount` DECIMAL(18,2) COMMENT 'The company retention amount (deductible or self-insured retention) before reinsurance coverage applies for this geography, peril, and LOB combination.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'The total insured value (sum insured) aggregated across all policies and insured risks within this geography, peril, and LOB combination as of the as-of date.',
    `treaty_share_percent` DECIMAL(5,2) COMMENT 'The percentage of exposure ceded to reinsurance treaties for this geography, peril, and LOB combination. Used for net exposure calculations.',
    `zone_code` STRING COMMENT 'The catastrophe zone or territory code within the geography node. Used for catastrophe modeling and rating purposes (e.g., hurricane zone, earthquake zone, flood zone).',
    CONSTRAINT pk_exposure_summary PRIMARY KEY(`exposure_summary_id`)
) COMMENT 'Single authoritative accumulation snapshot: aggregated TIV, policy count, and concentration by geography node, peril, and LOB as of an accounting date. One row per geography per peril per LOB per as-of date.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` (
    `cat_event_loss_id` BIGINT COMMENT 'Unique identifier for the catastrophe event loss record. Primary key for this table.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: CAT event loss estimates are produced by specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key to the catastrophe event that triggered this loss estimate.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: CAT event losses are tracked by peril. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `claimfinancials_accounting_period_id` BIGINT COMMENT 'Foreign key to the accounting period for which this CAT loss estimate is reported.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Catastrophe event loss estimates are segmented by LOB for Schedule P regulatory reporting, reinsurance treaty attachment point evaluation, and GAAP/SAP financial statement',
    `treaty_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty. Business justification: Catastrophe event loss estimates drive treaty layer attachment and exhaustion calculations for reinsurance purchasing decisions, capital modeling, and reinstatement premium triggers.',
    `accident_year` BIGINT COMMENT 'Accident year in which the catastrophe event occurred, used for loss development and reserving.',
    `alae_amount` DECIMAL(18,2) COMMENT 'Allocated loss adjustment expenses directly attributable to this CAT event loss segment.',
    `average_annual_loss` DECIMAL(18,2) COMMENT 'Average annual loss estimate for this segment based on catastrophe modeling.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'Portion of gross loss ceded to reinsurers under treaty or facultative agreements.',
    `claim_count_estimate` BIGINT COMMENT 'Estimated or actual number of claims arising from this CAT event within this segment.',
    `confidence_level_percent` DECIMAL(5,2) COMMENT 'Statistical confidence level for modeled loss estimates (e.g., 90%, 95%, 99%).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this CAT event loss record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this record (e.g., USD).. Valid values are `^[A-Z]{3}$`',
    `data_quality_score` DECIMAL(3,2) COMMENT 'Quality score for the underlying exposure data used in this estimate, ranging from 0.00 to 1.00.',
    `estimate_date` DATE COMMENT 'Date on which this CAT loss estimate was generated or last updated.',
    `estimate_status` STRING COMMENT 'Current status of this CAT loss estimate in the reporting lifecycle.. Valid values are `preliminary|interim|final|revised|superseded`',
    `geography_code` STRING COMMENT 'Geographic zone or territory code for aggregating exposure (state, region, or custom zone).. Valid values are `^[A-Z0-9]{2,10}$`',
    `gross_loss_amount` DECIMAL(18,2) COMMENT 'Total estimated or actual loss before reinsurance cessions and recoveries.',
    `ibnr_loading_amount` DECIMAL(18,2) COMMENT 'Additional reserve loading for incurred but not reported losses within this CAT event and segment.',
    `loss_estimate_type` STRING COMMENT 'Indicates whether the loss is modeled (pre-event), actual (post-event), hybrid, preliminary, or final.. Valid values are `modeled|actual|hybrid|preliminary|final`',
    `loss_ratio_percent` DECIMAL(5,2) COMMENT 'Loss ratio for this CAT event segment, calculated as net loss divided by earned premium.',
    `model_vendor` STRING COMMENT 'Vendor of the catastrophe model used for this loss estimate.. Valid values are `RMS|AIR|CoreLogic|KCC|Internal|Other`',
    `model_version` STRING COMMENT 'Version identifier of the catastrophe model used to generate this loss estimate (e.g., RMS v21.0).',
    `net_loss_amount` DECIMAL(18,2) COMMENT 'Net loss retained by the insurer after reinsurance cessions (gross minus ceded).',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this CAT loss estimate, including assumptions or caveats.',
    `peril_code` STRING COMMENT 'Code identifying the catastrophe peril (e.g., HU for hurricane, EQ for earthquake, WF for wildfire).. Valid values are `^[A-Z]{2,6}$`',
    `policy_count` BIGINT COMMENT 'Number of policies in force within this CAT event, LOB, and geography segment.',
    `probable_maximum_loss` DECIMAL(18,2) COMMENT 'Probable maximum loss estimate for this segment at a specified return period (e.g., 250-year PML).',
    `report_year` BIGINT COMMENT 'Calendar year in which this CAT loss estimate was reported or filed.',
    `return_period_years` BIGINT COMMENT 'Return period in years for the PML estimate (e.g., 100, 250, 500 years).',
    `total_insured_value` DECIMAL(18,2) COMMENT 'Total insured value of all exposures within this CAT event, LOB, and geography segment.',
    `ulae_amount` DECIMAL(18,2) COMMENT 'Unallocated loss adjustment expenses apportioned to this CAT event loss segment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this CAT event loss record was last modified.',
    CONSTRAINT pk_cat_event_loss PRIMARY KEY(`cat_event_loss_id`)
) COMMENT 'CAT-attribution loss ESTIMATE per CAT event per LOB per geography (one row each). Holds modeled/actual gross, ceded, and net loss and IBNR loading for Schedule P CAT reporting only -- NOT the financial ledger; authoritative payments/reserves live in';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` (
    `cat_event_zone_xref_id` BIGINT COMMENT 'Unique identifier for the catastrophe event zone cross-reference record. One row per CAT event per zone.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Zone impact data is produced by specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: CAT event zone cross-reference links events to zones. zone_code is a STRING denormalized attribute; adding proper zone_id FK for referential integrity.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key to the catastrophe event that impacted this zone.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: CAT event zone impacts are peril-specific. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `calculation_timestamp` TIMESTAMP COMMENT 'Timestamp when the impact metrics for this zone were calculated or last refreshed. Used for data lineage and staleness detection.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe event zone cross-reference record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this record. Typically USD for US-based catastrophe events.. Valid values are `USD|CAD|EUR|GBP|AUD`',
    `data_quality_score` DECIMAL(4,2) COMMENT 'Composite data quality score for this zone impact record, ranging from 0 to 100. Reflects completeness, accuracy, and timeliness of impact data.',
    `data_source` STRING COMMENT 'Source of the impact data for this zone: model-generated, observed from weather stations, or hybrid combining both.. Valid values are `model|observed|hybrid`',
    `exposed_policy_count` BIGINT COMMENT 'Number of in-force policies with insured risks located in this zone at the time of the catastrophe event. Used for FNOL triage and exposure reporting.',
    `exposed_tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value of all insured risks located in this zone at the time of the catastrophe event. Used for PML and AAL calculations.',
    `exposure_end_timestamp` TIMESTAMP COMMENT 'Timestamp when the catastrophe event ceased impacting this zone. Used to define the loss occurrence window.',
    `exposure_start_timestamp` TIMESTAMP COMMENT 'Timestamp when the catastrophe event began impacting this zone. Used to determine policy in-force status at loss inception.',
    `fire_perimeter_flag` BOOLEAN COMMENT 'Indicates whether this zone was within the fire perimeter during a wildfire catastrophe event. Used to identify direct fire exposure.',
    `fire_proximity_miles` DECIMAL(6,2) COMMENT 'Distance in miles from the zone centroid to the nearest wildfire perimeter. Null for non-wildfire perils.',
    `flood_depth_ft` DECIMAL(5,2) COMMENT 'Maximum flood water depth in feet recorded in this zone during the catastrophe event. Null for non-flood perils.',
    `fnol_priority_score` BIGINT COMMENT 'Calculated priority score for FNOL triage based on severity, exposure, and modeled loss. Higher scores indicate higher priority for claims outreach.',
    `geocoding_accuracy` STRING COMMENT 'Accuracy level of the geocoding used to assign insured risks to this zone. Impacts confidence in exposure aggregation.. Valid values are `rooftop|parcel|street|zip|county`',
    `hail_size_inches` DECIMAL(4,2) COMMENT 'Maximum hail diameter in inches recorded in this zone during the catastrophe event. Null for non-hail perils.',
    `impact_severity_band` STRING COMMENT 'Categorical severity classification of the catastrophe impact within this zone. Used to prioritize FNOL triage and reserve estimation.. Valid values are `minimal|light|moderate|severe|catastrophic|extreme`',
    `model_vendor` STRING COMMENT 'Vendor of the catastrophe model used to generate impact metrics for this zone. Used for model version tracking and reconciliation.. Valid values are `RMS|AIR|CoreLogic|KCC|Internal`',
    `model_version` STRING COMMENT 'Version identifier of the catastrophe model used to generate impact metrics for this zone. Critical for audit and model change tracking.',
    `modeled_damage_percent` DECIMAL(5,2) COMMENT 'Catastrophe model-predicted average damage percentage to insured structures in this zone. Used for reserve estimation and exposure aggregation.',
    `modeled_loss_ratio` DECIMAL(6,4) COMMENT 'Catastrophe model-predicted loss ratio for this zone based on exposure and hazard intensity. Used for initial reserve estimation and FNOL prioritization.',
    `notes` STRING COMMENT 'Free-text notes capturing additional context about this zone impact, such as data source anomalies, manual adjustments, or special handling instructions.',
    `peak_ground_acceleration` DECIMAL(6,4) COMMENT 'Peak ground acceleration in g-force units recorded in this zone during an earthquake event. Null for non-earthquake perils.',
    `peril_code` STRING COMMENT 'Code identifying the primary peril type for this catastrophe event zone impact. Examples: WIND, QUAKE, FLOOD, HAIL, FIRE, TORNADO.',
    `rainfall_inches` DECIMAL(6,2) COMMENT 'Total rainfall accumulation in inches recorded in this zone during the catastrophe event. Null for non-precipitation perils.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this zone impact must be included in regulatory catastrophe reporting to state DOI or NAIC.',
    `shake_intensity` STRING COMMENT 'Modified Mercalli Intensity scale value representing earthquake shaking intensity in this zone. Null for non-earthquake perils.',
    `storm_surge_flag` BOOLEAN COMMENT 'Indicates whether storm surge was present in this zone during the catastrophe event. Used to filter coastal exposure for FNOL triage.',
    `storm_surge_height_ft` DECIMAL(5,2) COMMENT 'Maximum storm surge height in feet above normal tide level recorded in this zone. Null if storm surge was not present.',
    `sub_peril_code` STRING COMMENT 'Code identifying the secondary or sub-peril type for this catastrophe event zone impact. Examples: STORM_SURGE, WIND_DRIVEN_RAIN, LIQUEFACTION.',
    `tornado_rating` STRING COMMENT 'Enhanced Fujita scale rating for tornado intensity in this zone. Null for non-tornado perils.. Valid values are `EF0|EF1|EF2|EF3|EF4|EF5`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe event zone cross-reference record was last modified.',
    `wind_gust_mph` DECIMAL(5,2) COMMENT 'Peak wind gust speed in miles per hour recorded in this zone during the catastrophe event. Null for non-wind perils.',
    `wind_speed_mph` DECIMAL(5,2) COMMENT 'Maximum sustained wind speed in miles per hour recorded in this zone during the catastrophe event. Null for non-wind perils.',
    `zone_code` STRING COMMENT 'Code identifying the geographic zone impacted by the catastrophe event. Typically county FIPS, ZIP code, or model-specific zone identifier.',
    `zone_type` STRING COMMENT 'Type of geographic zone definition used for this cross-reference. Determines the granularity and source of zone boundaries.. Valid values are `county|zip|cresta|model_zone|custom`',
    CONSTRAINT pk_cat_event_zone_xref PRIMARY KEY(`cat_event_zone_xref_id`)
) COMMENT 'Association between a CAT event and the CAT zones it impacted. One row per CAT event per zone. Carries impact severity band, wind speed or shake intensity, and storm surge flag used to filter exposed policies for FNOL triage.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` (
    `location_geocode_id` BIGINT COMMENT 'Unique identifier for the location geocode record. Primary key.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Location hazard data (PML, AAL by peril) is produced by specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `flood_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.flood_zone. Business justification: Location geocodes reference FEMA flood zones for flood hazard assessment. Adding flood_zone_id FK for referential integrity.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Location geocodes represent specific geographic points that should link to the geography hierarchy.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk this geocode represents.',
    `location_id` BIGINT COMMENT 'Foreign key to the location master record.',
    `address_line_1` STRING COMMENT 'Primary street address of the insured location.',
    `address_line_2` STRING COMMENT 'Secondary address information such as suite, unit, or building number.',
    `base_flood_elevation_ft` DECIMAL(8,2) COMMENT 'Base flood elevation in feet above sea level from FEMA FIRM.',
    `cat_model_vendor` STRING COMMENT 'Vendor of the catastrophe model used for hazard assessment.. Valid values are `RMS|AIR|CoreLogic|KCC|None`',
    `cat_model_version` STRING COMMENT 'Version identifier of the catastrophe model used.',
    `city` STRING COMMENT 'City name of the insured location.',
    `country_code` STRING COMMENT 'Three-letter ISO country code.. Valid values are `^[A-Z]{3}$`',
    `cresta_zone_code` STRING COMMENT 'CRESTA zone code for catastrophe risk aggregation.',
    `earthquake_aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount for earthquake peril.',
    `earthquake_pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for earthquake peril.',
    `effective_date` DATE COMMENT 'Date when this geocode record becomes effective.',
    `expiration_date` DATE COMMENT 'Date when this geocode record expires or is superseded.',
    `fema_firm_panel_number` STRING COMMENT 'FEMA FIRM panel identifier for the location.',
    `fema_flood_zone` STRING COMMENT 'FEMA flood zone designation from Flood Insurance Rate Map.',
    `fips_county_code` STRING COMMENT 'Five-digit FIPS code identifying the county.. Valid values are `^[0-9]{5}$`',
    `fips_state_code` STRING COMMENT 'Two-digit FIPS code identifying the state.. Valid values are `^[0-9]{2}$`',
    `fire_protection_class` STRING COMMENT 'ISO Public Protection Classification rating, 1 to 10 scale.. Valid values are `^(1|2|3|4|5|6|7|8|9|10)$`',
    `flood_aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount for flood peril.',
    `flood_pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for flood peril.',
    `geocode_match_level` STRING COMMENT 'Precision level of the geocode match. [ENUM-REF-CANDIDATE: rooftop|parcel|street|zip|city|county|state — 7 candidates stripped; promote to reference product]',
    `geocode_quality_score` DECIMAL(5,2) COMMENT 'Quality score of the geocoding result, typically 0-100 scale.',
    `geocode_source` STRING COMMENT 'Name of the geocoding service or vendor used.',
    `geocode_timestamp` TIMESTAMP COMMENT 'Date and time when the geocoding was performed.',
    `hail_aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount for hail peril.',
    `hail_pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for hail peril.',
    `hazard_band_earthquake` STRING COMMENT 'Categorical hazard band for earthquake peril.. Valid values are `low|moderate|high|very_high|extreme`',
    `hazard_band_flood` STRING COMMENT 'Categorical hazard band for flood peril.. Valid values are `low|moderate|high|very_high|extreme`',
    `hazard_band_hurricane` STRING COMMENT 'Categorical hazard band for hurricane peril.. Valid values are `low|moderate|high|very_high|extreme`',
    `hazard_band_wildfire` STRING COMMENT 'Categorical hazard band for wildfire peril.. Valid values are `low|moderate|high|very_high|extreme`',
    `hurricane_aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount for hurricane peril.',
    `hurricane_pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for hurricane peril.',
    `iso_territory_code` STRING COMMENT 'ISO territory code for rating and pricing purposes.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate in decimal degrees.',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate in decimal degrees.',
    `pml_return_period_years` BIGINT COMMENT 'Return period in years for PML calculation, typically 100, 250, or 500 years.',
    `postal_code` STRING COMMENT 'Five or nine-digit postal code (ZIP code in US).. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `state_province_code` STRING COMMENT 'Two-letter state or province code.. Valid values are `^[A-Z]{2}$`',
    `tornado_aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount for tornado peril.',
    `tornado_pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for tornado peril.',
    `wildfire_aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount for wildfire peril.',
    `wildfire_pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for wildfire peril.',
    CONSTRAINT pk_location_geocode PRIMARY KEY(`location_geocode_id`)
) COMMENT 'Per-location SSOT for geocode and hazard: one row per insured location. Stores lat/long, FIPS, CRESTA zone, FEMA FIRM flood zone, base flood elevation, FIRM panel, fire protection class, and model-derived AAL/PML/hazard band per peril and CAT model';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` (
    `flood_zone_id` BIGINT COMMENT 'Unique identifier for the flood zone record. Primary key.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Flood zones are peril-specific (flood peril). Adding peril_id FK to peril reference table for referential integrity and to enable peril-based queries across all hazard data.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Flood zones are geographic areas that should link to the geography hierarchy.',
    `area_square_miles` DECIMAL(12,4) COMMENT 'Total geographic area of this flood zone in square miles.',
    `base_flood_elevation_feet` DECIMAL(8,2) COMMENT 'Elevation in feet above mean sea level of the 1-percent-annual-chance flood, used for rating and building requirements.',
    `base_rate_factor` DECIMAL(8,5) COMMENT 'Multiplicative rating factor applied to base premium for properties in this flood zone.',
    `catastrophe_zone_code` STRING COMMENT 'Internal catastrophe zone code linking this flood zone to catastrophe exposure aggregation and PML modeling.',
    `coastal_barrier_flag` BOOLEAN COMMENT 'Indicates whether this zone is within a Coastal Barrier Resources System area where federal flood insurance is prohibited.',
    `community_name` STRING COMMENT 'Name of the local government jurisdiction participating in NFIP where this flood zone is located.',
    `community_number` STRING COMMENT 'Six-digit FEMA community identifier for the jurisdiction participating in the National Flood Insurance Program.. Valid values are `^[0-9]{6}$`',
    `county_fips_code` STRING COMMENT 'Five-digit FIPS code identifying the county where this flood zone is located.. Valid values are `^[0-9]{5}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this flood zone record was first created in the system.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Numeric score from 0 to 100 indicating the completeness and accuracy of this flood zone record.',
    `depth_feet` DECIMAL(6,2) COMMENT 'Average or typical flood depth in feet for shallow flooding areas such as AO zones.',
    `digital_conversion_date` DATE COMMENT 'Date when this flood zone was converted from paper FIRM to digital format as part of FEMA Map Modernization.',
    `effective_date` DATE COMMENT 'Date when this FIRM panel and flood zone designation became officially effective for regulatory and rating purposes.',
    `elevation_datum` STRING COMMENT 'Vertical datum reference system used for base flood elevation measurement.. Valid values are `NAVD88|NGVD29|LOCAL`',
    `expiration_date` DATE COMMENT 'Date when this flood zone designation is superseded by a new FIRM panel, if applicable.',
    `firm_panel_number` STRING COMMENT 'Ten-digit FEMA FIRM panel identifier uniquely identifying the map panel containing this flood zone.. Valid values are `^[0-9]{10}$`',
    `flood_frequency_percent` DECIMAL(5,2) COMMENT 'Annual probability of flooding expressed as a percentage for this zone.',
    `flood_hazard_description` STRING COMMENT 'Narrative description of the flood hazard characteristics and risk profile for this zone.',
    `flood_source` STRING COMMENT 'Name or description of the water body or flooding source creating the hazard in this zone.',
    `flood_zone_status` STRING COMMENT 'Current lifecycle status of this flood zone record indicating whether it is in force or has been replaced.. Valid values are `ACTIVE|SUPERSEDED|PENDING|WITHDRAWN`',
    `floodway_flag` BOOLEAN COMMENT 'Indicates whether this zone includes a regulatory floodway with additional building and development restrictions.',
    `geocode_latitude` DECIMAL(10,7) COMMENT 'Latitude coordinate of the centroid or representative point of this flood zone for spatial analysis.',
    `geocode_longitude` DECIMAL(10,7) COMMENT 'Longitude coordinate of the centroid or representative point of this flood zone for spatial analysis.',
    `geometry_wkt` STRING COMMENT 'Well-Known Text representation of the flood zone polygon boundary for GIS and spatial queries.',
    `insurance_mandatory_flag` BOOLEAN COMMENT 'Indicates whether flood insurance is federally mandated for mortgaged properties in this zone per NFIP requirements.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this flood zone record was most recently modified.',
    `last_verified_date` DATE COMMENT 'Date when this flood zone record was last verified against official FEMA FIRM data for accuracy.',
    `letter_of_map_change_number` STRING COMMENT 'FEMA-issued identifier for any Letter of Map Amendment or Letter of Map Revision affecting this zone.',
    `lomc_effective_date` DATE COMMENT 'Date when the most recent Letter of Map Change became effective for this flood zone.',
    `notes` STRING COMMENT 'Free-text field for additional comments, exceptions, or special instructions related to this flood zone.',
    `preliminary_flag` BOOLEAN COMMENT 'Indicates whether this flood zone is from a preliminary FIRM not yet officially adopted for regulatory use.',
    `rating_territory` STRING COMMENT 'Internal rating territory code used for premium calculation and risk segmentation for this flood zone.',
    `reinsurance_treaty_applicability` STRING COMMENT 'Indicator of which reinsurance treaties apply to flood losses originating in this zone.',
    `revision_date` DATE COMMENT 'Date of the most recent revision or amendment to this flood zone boundary or designation.',
    `special_flood_hazard_area_flag` BOOLEAN COMMENT 'Indicates whether this zone is designated as a Special Flood Hazard Area with 1-percent-annual-chance flood risk.',
    `state_code` STRING COMMENT 'Two-letter postal abbreviation for the state where this flood zone is located.. Valid values are `^[A-Z]{2}$`',
    `static_bfe_feet` DECIMAL(8,2) COMMENT 'Base flood elevation excluding wave effects, used in coastal areas to separate stillwater elevation from wave action.',
    `study_type` STRING COMMENT 'Type of hydrologic and hydraulic study used to determine flood elevations and boundaries for this zone.',
    `underwriting_eligibility_code` STRING COMMENT 'Insurer-specific code indicating underwriting eligibility and appetite for properties in this flood zone.. Valid values are `ELIGIBLE|INELIGIBLE|RESTRICTED|REFER`',
    `velocity_fps` DECIMAL(6,2) COMMENT 'Average flood water velocity in feet per second for high-velocity coastal zones such as V zones.',
    `wave_height_feet` DECIMAL(6,2) COMMENT 'Design wave height in feet for coastal high hazard areas subject to wave action.',
    `zone_designation` STRING COMMENT 'FEMA flood zone classification code indicating flood risk level and insurance requirements. [ENUM-REF-CANDIDATE: A|AE|AH|AO|AR|A99|V|VE|X|B|C|D — 12 candidates stripped; promote to reference product]',
    `zone_subtype` STRING COMMENT 'Additional classification detail within the primary zone designation for specialized flood hazard areas.',
    CONSTRAINT pk_flood_zone PRIMARY KEY(`flood_zone_id`)
) COMMENT 'FEMA National Flood Insurance Program (NFIP) flood zone classification. One row per FIRM panel zone. Carries flood zone designation (AE, VE, X), base flood elevation, FIRM panel number, and effective date for underwriting eligibility and rating.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` (
    `pml_run_id` BIGINT COMMENT 'Unique identifier for the PML modeling run. Primary key. One row per run.',
    `approved_by_user_party_id` BIGINT COMMENT 'Identifier of the user who validated and approved this PML run results.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: PML runs are executed using specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: PML runs are executed for specific perils. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `exposure_summary_id` BIGINT COMMENT 'Reference to the exposure portfolio snapshot used as input for this run.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: PML runs are executed per LOB for reinsurance program design, treaty pricing, and regulatory capital modeling. Rating agencies and regulators require LOB-specific PML disclosure.',
    `run_owner_party_id` BIGINT COMMENT 'Identifier of the user who initiated and executed this PML run.',
    `ri_agreement_id` BIGINT COMMENT 'Reference to the reinsurance program applied in net PML calculations.',
    `treaty_id` BIGINT COMMENT 'Foreign key linking to reinsurance.treaty. Business justification: PML runs model treaty structures to calculate net retained loss for capital adequacy, rating agency submissions (AM Best BCAR, S&P capital model), and reinsurance program optimization.',
    `aal_gross` DECIMAL(18,2) COMMENT 'Gross average annual loss before reinsurance recoveries.',
    `aal_net` DECIMAL(18,2) COMMENT 'Net average annual loss after reinsurance recoveries.',
    `approval_date` DATE COMMENT 'Date when the PML run results were formally approved for use.',
    `completion_timestamp` TIMESTAMP COMMENT 'Timestamp when the PML modeling run completed processing.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this run.. Valid values are `^[A-Z]{3}$`',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Composite quality score of the exposure data used in this run, expressed as percentage.',
    `demand_surge_applied` BOOLEAN COMMENT 'Indicates whether demand surge factors were applied in loss calculations.',
    `event_set_version` STRING COMMENT 'Version identifier of the stochastic event set used in this run.',
    `exposure_as_of_date` DATE COMMENT 'Effective date of the exposure portfolio snapshot used in this run.',
    `geocoding_accuracy_percent` DECIMAL(5,2) COMMENT 'Percentage of exposure locations successfully geocoded to precise coordinates.',
    `geography_scope` STRING COMMENT 'Geographic region or territory scope covered by this PML run.',
    `location_count` BIGINT COMMENT 'Number of insured locations included in the exposure portfolio for this run.',
    `loss_amplification_applied` BOOLEAN COMMENT 'Indicates whether loss amplification factors were applied in calculations.',
    `model_name` STRING COMMENT 'Name of the specific catastrophe model used for the run.',
    `model_vendor` STRING COMMENT 'Vendor providing the catastrophe modeling platform used for this run.. Valid values are `RMS|AIR|CoreLogic|KCC|EQECAT|Other`',
    `model_version` STRING COMMENT 'Version identifier of the catastrophe model used for this run.',
    `notes` STRING COMMENT 'Free-text notes or comments about this PML run, including assumptions or special conditions.',
    `peril_code` STRING COMMENT 'Primary peril or multi-peril code modeled in this run.',
    `policy_count` BIGINT COMMENT 'Number of policies included in the exposure portfolio for this run.',
    `rating_agency_submission_flag` BOOLEAN COMMENT 'Indicates whether this PML run is submitted to rating agencies for capital assessment.',
    `regulatory_filing_flag` BOOLEAN COMMENT 'Indicates whether this PML run is used for regulatory reporting or filing purposes.',
    `return_period_1000_gross_pml` DECIMAL(18,2) COMMENT 'Gross PML amount at 1000-year return period before reinsurance.',
    `return_period_1000_net_pml` DECIMAL(18,2) COMMENT 'Net PML amount at 1000-year return period after reinsurance recoveries.',
    `return_period_100_gross_pml` DECIMAL(18,2) COMMENT 'Gross PML amount at 100-year return period before reinsurance.',
    `return_period_100_net_pml` DECIMAL(18,2) COMMENT 'Net PML amount at 100-year return period after reinsurance recoveries.',
    `return_period_250_gross_pml` DECIMAL(18,2) COMMENT 'Gross PML amount at 250-year return period before reinsurance.',
    `return_period_250_net_pml` DECIMAL(18,2) COMMENT 'Net PML amount at 250-year return period after reinsurance recoveries.',
    `return_period_500_gross_pml` DECIMAL(18,2) COMMENT 'Gross PML amount at 500-year return period before reinsurance.',
    `return_period_500_net_pml` DECIMAL(18,2) COMMENT 'Net PML amount at 500-year return period after reinsurance recoveries.',
    `run_date` DATE COMMENT 'Date when the PML modeling run was executed.',
    `run_duration_minutes` BIGINT COMMENT 'Total elapsed time in minutes from run initiation to completion.',
    `run_name` STRING COMMENT 'Descriptive name assigned to the PML run for identification and reporting purposes.',
    `run_number` STRING COMMENT 'Business-assigned unique run number or code for external reference and tracking.',
    `run_status` STRING COMMENT 'Current lifecycle status of the PML modeling run.. Valid values are `Pending|Running|Completed|Failed|Cancelled|Validated`',
    `run_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the PML modeling run was initiated.',
    `run_type` STRING COMMENT 'Classification of the PML run based on its business purpose and frequency.. Valid values are `Annual|Quarterly|Ad-Hoc|Regulatory|Treaty|Facultative`',
    `simulation_count` BIGINT COMMENT 'Number of stochastic simulations executed in this modeling run.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value of the exposure portfolio included in this run.',
    `treaty_effective_date` DATE COMMENT 'Effective date of the reinsurance treaty used in net PML calculations.',
    `vulnerability_set_version` STRING COMMENT 'Version identifier of the vulnerability functions used in this run.',
    CONSTRAINT pk_pml_run PRIMARY KEY(`pml_run_id`)
) COMMENT 'A probabilistic PML modeling run executed against the exposure portfolio. One row per run. Captures model vendor, model version, run date, return period set, gross and net PML at each return period, and the exposure snapshot used as input.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` (
    `pml_return_period_id` BIGINT COMMENT 'Unique identifier for the PML return period result record. Primary key.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: PML return period results are from specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: PML return periods can be calculated per CAT zone. zone_code is a STRING denormalized attribute; adding proper zone_id FK for referential integrity.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: PML return periods are calculated per peril. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `geography_id` BIGINT COMMENT 'Foreign key to the geography hierarchy node representing the geographic scope of this PML result (e.g., state, region, country).',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Return period loss estimates feed LOB-specific reinsurance pricing, capital allocation, and risk-adjusted return calculations.',
    `pml_run_id` BIGINT COMMENT 'Foreign key to the parent PML run that generated this return period result.',
    `aal_amount` DECIMAL(18,2) COMMENT 'The average annual loss amount expected over the long term at this return period, used for pricing and reserving.',
    `as_of_date` DATE COMMENT 'The business date for which this PML return period result is effective. Represents the exposure snapshot date used in the model run.',
    `calculation_timestamp` TIMESTAMP COMMENT 'The date and time when this return period result was calculated by the catastrophe model.',
    `ceded_loss_amount` DECIMAL(18,2) COMMENT 'The estimated loss amount ceded to reinsurers at this return period, based on treaty structures and facultative agreements.',
    `coefficient_of_variation` DECIMAL(10,6) COMMENT 'Statistical measure of relative variability in the loss distribution at this return period. Used to assess uncertainty and volatility in loss estimates.',
    `confidence_level_percent` DECIMAL(5,2) COMMENT 'The statistical confidence level for this return period estimate, typically 90%, 95%, or 99%.',
    `currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code for all monetary amounts in this return period result.. Valid values are `^[A-Z]{3}$`',
    `data_quality_score` DECIMAL(5,2) COMMENT 'A quality score for the input exposure data used in this return period calculation, ranging from 0 to 100.',
    `exceedance_probability` DECIMAL(10,8) COMMENT 'The probability that the loss will be exceeded in any given year, expressed as a decimal (e.g., 0.01 for 1% or 100-year return period).',
    `geocoding_accuracy` STRING COMMENT 'The level of geocoding accuracy for the exposure locations included in this return period result.. Valid values are `rooftop|street|zip|city|county|state`',
    `gross_loss_amount` DECIMAL(18,2) COMMENT 'The estimated gross loss amount before reinsurance recovery at this return period. Represents total insured loss to the company.',
    `insured_risk_count` BIGINT COMMENT 'The number of individual insured risks (locations, buildings, vehicles) included in this return period calculation.',
    `loss_ratio` DECIMAL(10,6) COMMENT 'The ratio of gross loss to total insured value at this return period, expressed as a decimal. Used to assess severity relative to exposure.',
    `model_vendor` STRING COMMENT 'The vendor of the catastrophe modeling platform used for this analysis.. Valid values are `RMS|AIR|CoreLogic|KCC|Other`',
    `model_version` STRING COMMENT 'The version identifier of the catastrophe model used to generate this return period result (e.g., RMS v21.0, AIR v19.1).. Valid values are `^[A-Za-z0-9._-]{1,50}$`',
    `net_retained_loss_amount` DECIMAL(18,2) COMMENT 'The net loss retained by the company after reinsurance recovery at this return period. Calculated as gross loss minus ceded loss.',
    `notes` STRING COMMENT 'Free-text notes or comments about this return period result, including assumptions, limitations, or special considerations.',
    `orsa_scenario_flag` BOOLEAN COMMENT 'Indicates whether this return period result is part of an ORSA stress testing scenario.',
    `percentile_rank` DECIMAL(5,2) COMMENT 'The percentile rank of this return period in the loss distribution (e.g., 99th percentile for a 100-year return period).',
    `peril_code` STRING COMMENT 'The catastrophe peril code for this return period result (e.g., EQ for earthquake, HU for hurricane, WS for windstorm).. Valid values are `^[A-Z0-9]{2,10}$`',
    `pml_return_period_status` STRING COMMENT 'The current status of this return period result in its lifecycle.. Valid values are `draft|final|superseded|archived`',
    `policy_count` BIGINT COMMENT 'The number of policies included in the exposure set for this return period result.',
    `rbc_contribution_amount` DECIMAL(18,2) COMMENT 'The contribution of this return period result to the companys risk-based capital calculation for catastrophe risk.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this return period result is required for regulatory reporting to state DOI or NAIC.',
    `retention_amount` DECIMAL(18,2) COMMENT 'The retention or deductible amount applied before reinsurance recovery at this return period. Represents the companys self-insured retention.',
    `return_period_years` BIGINT COMMENT 'The return period in years for this loss estimate (e.g., 100, 250, 500, 1000). Represents the average recurrence interval of a loss event of this magnitude.',
    `rol_percent` DECIMAL(8,4) COMMENT 'The rate on line percentage for reinsurance pricing at this return period, calculated as premium divided by limit.',
    `simulation_count` BIGINT COMMENT 'The number of Monte Carlo simulations or stochastic trials used to generate this return period result.',
    `standard_deviation_amount` DECIMAL(18,2) COMMENT 'The standard deviation of the loss distribution at this return period, measuring the dispersion of potential loss outcomes.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'The total insured value of exposure included in this return period calculation. Represents the sum of all policy limits in the modeled portfolio.',
    `treaty_share_percent` DECIMAL(8,4) COMMENT 'The percentage of loss ceded to reinsurance treaties at this return period, based on quota share and excess of loss treaty structures.',
    `zone_code` STRING COMMENT 'The catastrophe zone code for this return period result, representing a specific geographic hazard zone.. Valid values are `^[A-Z0-9]{1,10}$`',
    CONSTRAINT pk_pml_return_period PRIMARY KEY(`pml_return_period_id`)
) COMMENT 'Individual return-period result within a PML run. One row per PML run per return period (e.g., 100-yr, 250-yr, 500-yr). Stores gross loss, ceded loss, net retained loss, AAL, and coefficient of variation for reinsurance treaty sizing.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` (
    `accumulation_limit_id` BIGINT COMMENT 'Unique identifier for the accumulation limit record. Primary key.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Accumulation limits are informed by CAT model versions for PML-based thresholds. Adding cat_model_version_id FK for model lineage tracking.',
    `cat_zone_id` BIGINT COMMENT 'Reference to the catastrophe zone to which this accumulation limit applies.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Accumulation limits are set per peril. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Accumulation limits are set per LOB per peril per zone to control underwriting authority and manage capacity concentration.',
    `reinsurance_treaty_id` BIGINT COMMENT 'Reference to the reinsurance treaty that provides capacity supporting this accumulation limit, if applicable.',
    `accumulation_limit_status` STRING COMMENT 'Current lifecycle status of the accumulation limit: active, suspended, expired, pending approval, or withdrawn.. Valid values are `active|suspended|expired|pending|withdrawn`',
    `approval_authority` STRING COMMENT 'Role or title of the individual or committee authorized to approve this accumulation limit, such as Chief Underwriting Officer or Risk Committee.',
    `approval_date` DATE COMMENT 'Date on which this accumulation limit was formally approved by the designated authority.',
    `approved_by` STRING COMMENT 'Name or identifier of the person who approved this accumulation limit.',
    `available_capacity` DECIMAL(18,2) COMMENT 'Remaining capacity available under this accumulation limit, calculated as limit amount minus utilization amount.',
    `business_justification` STRING COMMENT 'Textual explanation of the business rationale for setting this accumulation limit at the specified level.',
    `calculation_timestamp` TIMESTAMP COMMENT 'Timestamp when the utilization and available capacity were last calculated for this accumulation limit.',
    `ceded_percent` DECIMAL(5,2) COMMENT 'Percentage of exposure ceded to reinsurers under treaties applicable to this zone and peril.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this accumulation limit record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the limit amount.. Valid values are `^[A-Z]{3}$`',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Score from 0 to 100 indicating the quality and completeness of the underlying exposure data used to calculate utilization against this limit.',
    `effective_date` DATE COMMENT 'Date from which this accumulation limit becomes active and enforceable.',
    `expiration_date` DATE COMMENT 'Date on which this accumulation limit ceases to be active. Null indicates an open-ended limit.',
    `geographic_scope` STRING COMMENT 'Textual description of the geographic area covered by this accumulation limit, such as state, region, or custom zone definition.',
    `hard_threshold_percent` DECIMAL(5,2) COMMENT 'Utilization percentage at which new business is declined or suspended, typically 95-100 percent of the limit.',
    `last_review_date` DATE COMMENT 'Date on which this accumulation limit was last reviewed by underwriting or risk management.',
    `limit_amount` DECIMAL(18,2) COMMENT 'Maximum aggregate exposure amount allowed in this zone for this peril and line of business. Enforces underwriting appetite constraints.',
    `limit_basis` STRING COMMENT 'Basis on which the limit is applied: per occurrence, aggregate across all events, or annual aggregate.. Valid values are `occurrence|aggregate|annual`',
    `limit_type` STRING COMMENT 'Type of exposure measure this limit applies to: Total Insured Value, Gross Written Premium, policy count, insured risk count, Probable Maximum Loss, or Average Annual Loss.. Valid values are `tiv|gwp|policy_count|insured_risk_count|pml|aal`',
    `model_vendor` STRING COMMENT 'Vendor of the catastrophe model used to define exposure and set this limit: RMS, AIR, Karen Clark, EQECAT, internal model, or other.. Valid values are `rms|air|karen_clark|eqecat|internal|other`',
    `model_version` STRING COMMENT 'Version identifier of the catastrophe model used to calculate exposure and set this accumulation limit.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this accumulation limit record was last modified.',
    `net_retention_amount` DECIMAL(18,2) COMMENT 'Amount of exposure retained net of reinsurance under this accumulation limit.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of this accumulation limit.',
    `notes` STRING COMMENT 'Free-text field for additional comments, exceptions, or context related to this accumulation limit.',
    `override_allowed_flag` BOOLEAN COMMENT 'Indicates whether underwriters are permitted to override this accumulation limit with appropriate authority. True if override allowed, false otherwise.',
    `override_authority_level` STRING COMMENT 'Minimum authority level required to override this accumulation limit, such as Senior Underwriter, Chief Underwriting Officer, or Risk Committee.',
    `peril_code` STRING COMMENT 'Code identifying the catastrophe peril for this limit, such as hurricane, earthquake, flood, wildfire, tornado, hail.. Valid values are `^[A-Z0-9_]{2,10}$`',
    `pml_return_period_years` BIGINT COMMENT 'Return period in years for the Probable Maximum Loss calculation used to inform this limit, such as 100, 250, 500, or 1000 years.',
    `regulatory_reference` STRING COMMENT 'Citation or reference to the specific regulation, statute, or guideline that mandates or informs this accumulation limit.',
    `regulatory_requirement_flag` BOOLEAN COMMENT 'Indicates whether this accumulation limit is mandated by regulatory or statutory requirements. True if mandated, false otherwise.',
    `review_frequency` STRING COMMENT 'Frequency at which this accumulation limit is reviewed and potentially adjusted: daily, weekly, monthly, quarterly, annually, or event-driven.. Valid values are `daily|weekly|monthly|quarterly|annually|event_driven`',
    `soft_threshold_percent` DECIMAL(5,2) COMMENT 'Utilization percentage at which referral or enhanced monitoring is triggered, typically 80-90 percent of the limit.',
    `threshold_action` STRING COMMENT 'Action to be taken when utilization exceeds defined thresholds: allow with monitoring, refer to senior underwriter, decline new business, or suspend writing.. Valid values are `allow|refer|decline|suspend`',
    `utilization_amount` DECIMAL(18,2) COMMENT 'Current aggregate exposure amount utilized against this limit, calculated from in-force policies and insured risks in the zone.',
    `utilization_percent` DECIMAL(5,2) COMMENT 'Percentage of the accumulation limit currently utilized, calculated as utilization amount divided by limit amount times 100.',
    CONSTRAINT pk_accumulation_limit PRIMARY KEY(`accumulation_limit_id`)
) COMMENT 'Insurer-defined maximum aggregate exposure limit per CAT zone, peril, and LOB. One row per zone per peril per LOB. Enforces underwriting appetite constraints; triggers referral or declination when TIV in zone exceeds the approved accumulation cap.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` (
    `cat_model_version_id` BIGINT COMMENT 'Unique identifier for the catastrophe model version record. Primary key.',
    `superseded_by_version_cat_model_version_id` BIGINT COMMENT 'Reference to the newer catastrophe model version that replaces this version when it is deprecated.',
    `approved_jurisdictions` STRING COMMENT 'Comma-separated list of state or jurisdiction codes where this model version has received regulatory approval for rate filing.',
    `benchmark_comparison_flag` BOOLEAN COMMENT 'Indicates whether this model version has been benchmarked against prior versions or alternative vendor models.',
    `cat_model_version_status` STRING COMMENT 'Current lifecycle status of this catastrophe model version within the organization.. Valid values are `active|deprecated|retired|pending|testing`',
    `climate_scenario` STRING COMMENT 'Climate change scenario or baseline climate period used in this model version for hazard frequency and severity.',
    `country_codes` STRING COMMENT 'Comma-separated list of ISO 3-letter country codes where this model version is applicable.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe model version record was first created in the system.',
    `documentation_url` STRING COMMENT 'URL or file path to the vendor technical documentation and methodology guide for this model version.',
    `effective_date` DATE COMMENT 'Date from which this model version is authoritative for catastrophe exposure analysis and pricing decisions.',
    `event_set_size` BIGINT COMMENT 'Number of simulated catastrophe events in the stochastic event set for probabilistic models.',
    `expiration_date` DATE COMMENT 'Date after which this model version is no longer authoritative and should be superseded by a newer version.',
    `financial_module_version` STRING COMMENT 'Version identifier for the financial loss calculation and insurance terms module used in this model release.',
    `geographic_coverage` STRING COMMENT 'Description of the geographic regions and territories covered by this model version.',
    `hazard_module_version` STRING COMMENT 'Version identifier for the hazard generation and intensity module used in this model release.',
    `license_expiration_date` DATE COMMENT 'Date when the organization license to use this model version expires and requires renewal.',
    `lob_applicability` STRING COMMENT 'Comma-separated list of insurance line of business codes for which this model version is designed and validated.',
    `model_name` STRING COMMENT 'Official name of the catastrophe model product line from the vendor.',
    `model_type` STRING COMMENT 'Classification of the modeling methodology used by this version.. Valid values are `probabilistic|deterministic|hybrid`',
    `notes` STRING COMMENT 'Free-text notes capturing implementation decisions, known issues, or special considerations for this model version.',
    `pml_return_periods` STRING COMMENT 'Comma-separated list of return period years for which this model version can calculate PML estimates.',
    `primary_use_case` STRING COMMENT 'Primary business function for which this model version is designated within the organization.. Valid values are `underwriting|pricing|reinsurance|capital|regulatory|portfolio`',
    `regulatory_approval_status` STRING COMMENT 'Status of regulatory approval or acceptance of this model version by relevant state insurance departments.. Valid values are `approved|pending|not_required|rejected`',
    `release_date` DATE COMMENT 'Date when the vendor officially released this model version to the market.',
    `resolution_level` STRING COMMENT 'Spatial resolution or granularity at which this model version performs hazard and vulnerability analysis.',
    `simulation_years` BIGINT COMMENT 'Number of years of simulated catastrophe activity represented in the stochastic event set.',
    `state_province_coverage` STRING COMMENT 'Comma-separated list of state or province codes covered by this model version for sub-national analysis.',
    `supported_perils` STRING COMMENT 'Comma-separated list of peril codes that this model version can analyze and score.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe model version record was last modified.',
    `usage_restrictions` STRING COMMENT 'Description of any contractual or technical restrictions on how this model version may be used within the organization.',
    `validation_date` DATE COMMENT 'Date when internal actuarial and catastrophe modeling teams completed validation testing of this model version.',
    `validation_status` STRING COMMENT 'Status of internal validation and acceptance testing for this model version.. Valid values are `passed|failed|in_progress|not_started`',
    `vendor_name` STRING COMMENT 'Name of the catastrophe modeling vendor who developed and maintains this model version. [ENUM-REF-CANDIDATE: RMS|AIR|CoreLogic|KCC|EQECAT|JBA|Fathom|Other — 8 candidates stripped; promote to reference product]',
    `version_number` STRING COMMENT 'Version identifier assigned by the vendor to this specific model release.',
    `vulnerability_functions_version` STRING COMMENT 'Version identifier for the damage and vulnerability functions used in this model release.',
    CONSTRAINT pk_cat_model_version PRIMARY KEY(`cat_model_version_id`)
) COMMENT 'Reference record for a CAT model vendor version (e.g., RMS v23, AIR Touchstone 2024). One row per vendor per version. Tracks release date, supported perils, geographic coverage, and the effective date range for which results are authoritative.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` (
    `policy_cat_exposure_id` BIGINT COMMENT 'Unique identifier for the policy catastrophe exposure record. One row per policy per CAT event or zone.',
    `cat_model_version_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_model_version. Business justification: Policy CAT exposure estimates are produced by specific CAT model versions. Adding cat_model_version_id FK for model lineage tracking.',
    `cat_zone_id` BIGINT COMMENT 'Reference to the catastrophe zone in which the insured risk resides.',
    `catastrophe_event_id` BIGINT COMMENT 'Reference to the specific catastrophe event to which this policy is exposed. Null if exposure is zone-based only.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: Policy CAT exposures are tracked by peril. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `coverage_id` BIGINT COMMENT 'Reference to the primary coverage providing protection against the catastrophe peril.',
    `insured_risk_id` BIGINT COMMENT 'Reference to the specific insured risk (property, building, vehicle) exposed to the catastrophe.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Catastrophe exposure aggregation and PML calculation require LOB segmentation for reinsurance treaty attachment, regulatory capital calculation (RBC), and ORSA scenario analysis.',
    `location_id` BIGINT COMMENT 'Reference to the geographic location of the insured risk for exposure aggregation.',
    `policy_id` BIGINT COMMENT 'Reference to the in-force policy exposed to the catastrophe event or zone.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term period during which the exposure exists.',
    `aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount for this exposure, used for pricing and reinsurance treaty structuring.',
    `as_of_date` DATE COMMENT 'Snapshot date for which this catastrophe exposure record is valid, supporting point-in-time analysis.',
    `bordereaux_reporting_flag` BOOLEAN COMMENT 'Indicates whether this exposure must be reported to reinsurers via bordereaux submissions.',
    `building_area_sqft` DECIMAL(12,2) COMMENT 'Total building area in square feet, used for exposure density and loss estimation.',
    `cat_model_vendor` STRING COMMENT 'Vendor of the catastrophe model used to generate loss estimates (RMS, AIR, CoreLogic, KCC).. Valid values are `RMS|AIR|CoreLogic|KCC`',
    `cat_model_version` STRING COMMENT 'Version identifier of the catastrophe model used for this exposure calculation.',
    `construction_class` STRING COMMENT 'Construction type classification (frame, masonry, fire-resistive, non-combustible) per COPE framework.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe exposure record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this exposure record.. Valid values are `USD|CAD|EUR|GBP|AUD|MXN`',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Quality score (0-100) indicating completeness and accuracy of exposure data used in modeling.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount or percentage applicable to catastrophe claims for this exposure.',
    `deductible_type` STRING COMMENT 'Type of deductible applied to catastrophe losses (flat dollar, percentage of TIV, franchise).. Valid values are `flat|percentage|franchise`',
    `estimated_gross_loss_amount` DECIMAL(18,2) COMMENT 'Modeled or estimated gross loss amount for this exposure, used in FNOL triage and reinsurance bordereaux.',
    `estimated_net_loss_amount` DECIMAL(18,2) COMMENT 'Estimated net loss after deductible and policy limits, used for reserving and reinsurance recovery estimation.',
    `exposure_effective_date` DATE COMMENT 'Date when the catastrophe exposure begins for this policy and location.',
    `exposure_expiration_date` DATE COMMENT 'Date when the catastrophe exposure ends for this policy and location.',
    `exposure_status` STRING COMMENT 'Current status of the catastrophe exposure record (active, expired, cancelled, suspended).. Valid values are `active|expired|cancelled|suspended`',
    `fnol_triage_priority` STRING COMMENT 'Priority level for FNOL triage based on estimated loss severity and policy characteristics.. Valid values are `critical|high|medium|low`',
    `geocode_quality` STRING COMMENT 'Quality level of the geocoding result (rooftop, parcel, street, zip) indicating precision of coordinates.. Valid values are `rooftop|parcel|street|zip`',
    `latitude` DECIMAL(10,7) COMMENT 'Latitude coordinate of the insured location for geocoding and catastrophe zone assignment.',
    `limit_amount` DECIMAL(18,2) COMMENT 'Maximum coverage limit applicable to the catastrophe peril for this policy and location.',
    `longitude` DECIMAL(10,7) COMMENT 'Longitude coordinate of the insured location for geocoding and catastrophe zone assignment.',
    `model_run_date` DATE COMMENT 'Date when the catastrophe model was executed to generate loss estimates for this exposure.',
    `notes` STRING COMMENT 'Free-text notes capturing additional context, exceptions, or special handling instructions for this exposure.',
    `number_of_stories` BIGINT COMMENT 'Number of stories or floors in the insured building, used for wind and earthquake modeling.',
    `occupancy_class` STRING COMMENT 'Occupancy classification of the insured property (residential, commercial, industrial, agricultural) per COPE framework.',
    `peril_code` STRING COMMENT 'Code identifying the catastrophe peril type (hurricane, earthquake, flood, wildfire, tornado, hail).',
    `pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for this exposure at a specified return period, used for capital and reinsurance planning.',
    `pml_return_period_years` BIGINT COMMENT 'Return period in years for the PML calculation (e.g., 100, 250, 500, 1000 year event).',
    `protection_class` STRING COMMENT 'Fire protection class or ISO Public Protection Classification (PPC) for the location.',
    `reinsurance_program_code` STRING COMMENT 'Code identifying the reinsurance program or treaty applicable to this catastrophe exposure.',
    `retention_amount` DECIMAL(18,2) COMMENT 'Net retention amount after reinsurance cession for this catastrophe exposure.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value of the risk exposed to the catastrophe, used for PML and AAL calculations.',
    `treaty_share_percent` DECIMAL(5,2) COMMENT 'Percentage of exposure ceded to reinsurance treaties, used for bordereaux generation and net exposure calculation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this catastrophe exposure record was last modified.',
    `year_built` BIGINT COMMENT 'Year the insured building or structure was originally constructed, used for vulnerability assessment.',
    CONSTRAINT pk_policy_cat_exposure PRIMARY KEY(`policy_cat_exposure_id`)
) COMMENT 'Association linking an in-force policy to a CAT event or CAT zone for exposure tracking. One row per policy per CAT event or zone. Carries TIV, coverage type, and estimated gross loss used in FNOL triage and reinsurance bordereaux generation.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` (
    `iso_cat_serial_id` BIGINT COMMENT 'Unique identifier for the ISO CAT serial record. Primary key.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.catastrophe_event. Business justification: ISO CAT serials are industry-standard identifiers for catastrophe events and should link to the insurers internal catastrophe_event records.',
    `catastrophegeography_peril_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.peril. Business justification: ISO CAT serials are assigned per peril. Adding peril_id FK to peril reference table for referential integrity. peril_code remains for operational queries.',
    `affected_counties` STRING COMMENT 'Comma-separated list of county names or FIPS codes within affected states where losses occurred, providing granular geographic detail for exposure analysis.',
    `affected_lob_codes` STRING COMMENT 'Comma-separated list of insurance line of business codes impacted by the catastrophe, such as HO for homeowners, PAP for personal auto, CGL for commercial general liability.',
    `affected_states` STRING COMMENT 'Comma-separated list of US state postal codes where the catastrophe event caused insured losses, used for geographic exposure aggregation and regulatory reporting.',
    `cat_bond_trigger` BOOLEAN COMMENT 'Indicates whether this catastrophe event triggered catastrophe bond or insurance-linked securities ILS payout conditions based on parametric or indemnity triggers.',
    `cat_event_name` STRING COMMENT 'Official name of the catastrophe event as designated by ISO PCS, such as Hurricane Katrina, Northridge Earthquake, or Texas Winter Storm Uri.',
    `data_source` STRING COMMENT 'Originating system or vendor that provided the ISO CAT serial record, such as ISO PCS, catastrophe modeling platform, or internal catastrophe management system.',
    `earthquake_magnitude` DECIMAL(3,1) COMMENT 'Richter or moment magnitude scale measurement of earthquake intensity for seismic catastrophe events, used for loss modeling and exposure analysis.',
    `event_category` STRING COMMENT 'High-level classification of the catastrophe event origin, distinguishing between natural disasters, man-made events, terrorism, pandemic, or cyber incidents.. Valid values are `natural|man-made|terrorism|pandemic|cyber`',
    `event_duration_days` BIGINT COMMENT 'Total number of days the catastrophe event lasted, calculated from start to end date for exposure and loss analysis.',
    `event_end_date` DATE COMMENT 'Date when the catastrophe event concluded, marking the last day of active loss occurrence for the designated event period.',
    `event_start_date` DATE COMMENT 'Date when the catastrophe event began, marking the first day of loss occurrence for policy and claim matching purposes.',
    `fema_disaster_number` STRING COMMENT 'Federal disaster declaration number assigned by FEMA for major disasters or emergencies, linking insurance catastrophe events to federal disaster assistance programs.. Valid values are `^(DR|EM|FM|FS)-[0-9]{4,5}$`',
    `hurricane_category` STRING COMMENT 'Saffir-Simpson hurricane wind scale category at landfall for hurricane events, ranging from Tropical Depression TD, Tropical Storm TS, to Category 1 through 5.. Valid values are `^(CAT[1-5]|TS|TD)$`',
    `industry_insured_loss_estimate` DECIMAL(18,2) COMMENT 'ISO PCS estimated total insured loss amount across all insurers for this catastrophe event, expressed in US dollars, used for industry benchmarking and market share analysis.',
    `iso_serial_effective_date` DATE COMMENT 'Date when the ISO CAT serial number was officially assigned and became effective for industry use in claim coding and loss reporting.',
    `iso_serial_expiration_date` DATE COMMENT 'Date when the ISO CAT serial number expires or is superseded, typically null for active catastrophe designations unless event is reclassified or withdrawn.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this ISO CAT serial record was last modified in the data warehouse, supporting data freshness monitoring and change tracking.',
    `loss_estimate_date` DATE COMMENT 'Date when the industry insured loss estimate was published or last updated by ISO PCS, reflecting the valuation point for the estimate.',
    `loss_estimate_status` STRING COMMENT 'Current status of the industry loss estimate indicating whether it is preliminary, revised with updated data, final, or withdrawn due to threshold changes.. Valid values are `preliminary|revised|final|withdrawn`',
    `naic_cat_code` STRING COMMENT 'NAIC-assigned catastrophe code used for statutory annual statement Schedule P reporting, enabling consistent regulatory catastrophe loss tracking.. Valid values are `^[0-9]{3,6}$`',
    `notes` STRING COMMENT 'Free-form text field for additional context, special instructions, or clarifications regarding the catastrophe event or ISO serial assignment.',
    `number` STRING COMMENT 'Industry-standard ISO-assigned catastrophe serial number for recognized CAT events. Used for statutory reporting and industry loss aggregation.. Valid values are `^[A-Z0-9]{6,12}$`',
    `pcs_threshold_amount` DECIMAL(18,2) COMMENT 'Minimum insured loss amount in US dollars required for ISO PCS to designate an event as a catastrophe, used to validate threshold compliance.',
    `pcs_threshold_met` BOOLEAN COMMENT 'Indicates whether the catastrophe event met the ISO PCS minimum loss threshold for designation as an industry catastrophe, typically 25 million USD in insured losses.',
    `peril_code` STRING COMMENT 'Standardized code identifying the primary peril type for the catastrophe event, such as HU for hurricane, EQ for earthquake, WS for windstorm, FL for flood, WF for wildfire.. Valid values are `^[A-Z]{2,6}$`',
    `peril_description` STRING COMMENT 'Full text description of the catastrophe peril type for business user clarity and reporting purposes.',
    `primary_state` STRING COMMENT 'Two-letter postal code of the state with the highest concentration of insured losses for this catastrophe event, used for primary jurisdiction reporting.. Valid values are `^[A-Z]{2}$`',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether this catastrophe event requires special regulatory reporting to state departments of insurance or NAIC beyond standard annual statement filings.',
    `reinsurance_treaty_trigger` BOOLEAN COMMENT 'Indicates whether this catastrophe event triggered reinsurance treaty coverage thresholds, requiring cession and recovery processing for affected policies and claims.',
    `schedule_p_reportable` BOOLEAN COMMENT 'Indicates whether losses from this catastrophe event must be separately identified in NAIC Annual Statement Schedule P Part 3 catastrophe loss reporting.',
    `serial_status` STRING COMMENT 'Current lifecycle status of the ISO CAT serial number indicating whether it is active for use, inactive, superseded by a revised serial, or withdrawn.. Valid values are `active|inactive|superseded|withdrawn`',
    `severity_classification` STRING COMMENT 'Qualitative severity rating of the catastrophe event based on insured loss magnitude, geographic scope, and impact on the insurance industry.. Valid values are `minor|moderate|major|severe|catastrophic`',
    `total_precipitation_inches` DECIMAL(6,2) COMMENT 'Total rainfall or liquid equivalent precipitation in inches recorded during the catastrophe event, relevant for flood and storm loss analysis.',
    `wind_speed_mph` BIGINT COMMENT 'Maximum sustained wind speed in miles per hour recorded during the catastrophe event, applicable to hurricanes, tornadoes, and windstorms.',
    CONSTRAINT pk_iso_cat_serial PRIMARY KEY(`iso_cat_serial_id`)
) COMMENT 'ISO-assigned CAT serial number record for a recognized industry CAT event. One row per ISO CAT serial. Carries ISO serial number, event name, peril, date range, affected states, and industry insured loss estimate for statutory CAT reporting.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` (
    `cat_event_zone_impact_id` BIGINT COMMENT 'Unique identifier for this catastrophe event zone impact record. Primary key.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to the catastrophe zone that was impacted by this event.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key to catastrophe_event. Identifies which event impacted this zone.',
    `exposed_policy_count` BIGINT COMMENT 'Number of active policies in this zone that were exposed to this catastrophe event.',
    `exposed_tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value in USD of all policies in this zone that were exposed to this catastrophe event.',
    `exposure_end_timestamp` TIMESTAMP COMMENT 'Date and time when this zone ceased experiencing exposure to the catastrophe event.',
    `exposure_start_timestamp` TIMESTAMP COMMENT 'Date and time when this zone first experienced exposure to the catastrophe event.',
    `flood_depth_ft` DECIMAL(6,2) COMMENT 'Maximum flood water depth recorded in this zone during the event, in feet.',
    `hail_size_inches` DECIMAL(4,2) COMMENT 'Maximum hail stone diameter recorded in this zone during the event, in inches.',
    `impact_severity_band` STRING COMMENT 'Categorical severity classification of the event impact on this zone: None, Minor, Moderate, Severe, Catastrophic.',
    `modeled_damage_percent` DECIMAL(5,2) COMMENT 'Catastrophe model estimated percentage of physical damage to insured property in this zone from this event.',
    `modeled_loss_ratio` DECIMAL(7,4) COMMENT 'Catastrophe model estimated loss ratio for this zone from this event, expressed as decimal.',
    `rainfall_inches` DECIMAL(6,2) COMMENT 'Total rainfall accumulation recorded in this zone during the event, in inches.',
    `shake_intensity` STRING COMMENT 'Modified Mercalli Intensity scale value for earthquake shaking experienced in this zone.',
    `storm_surge_flag` BOOLEAN COMMENT 'Indicates whether storm surge was recorded in this zone during the event.',
    `storm_surge_height_ft` DECIMAL(6,2) COMMENT 'Maximum storm surge height recorded in this zone during the event, in feet.',
    `wind_gust_mph` BIGINT COMMENT 'Maximum wind gust speed recorded in this zone during the event, in miles per hour.',
    `wind_speed_mph` BIGINT COMMENT 'Maximum sustained wind speed recorded in this zone during the event, in miles per hour.',
    CONSTRAINT pk_cat_event_zone_impact PRIMARY KEY(`cat_event_zone_impact_id`)
) COMMENT 'Records the impact of a catastrophe event on a specific CAT zone. One row per event per zone. Captures modeled loss, exposure metrics, physical parameters, and timestamps for loss estimation, reinsurance triggers, and regulatory reporting..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` (
    `catastrophe_event_geography_exposure_id` BIGINT COMMENT 'Unique identifier for this catastrophe event geography exposure record. Primary key.',
    `catastrophe_event_id` BIGINT COMMENT 'Foreign key linking to the catastrophe event being analyzed for exposure.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to the geography unit within the catastrophe event footprint.',
    `aal_amount` DECIMAL(18,2) COMMENT 'Average annual loss amount attributed to this geography for this type of catastrophe event, used for pricing and reserving.',
    `as_of_date` DATE COMMENT 'Point-in-time date when this exposure snapshot was calculated, enabling temporal analysis of exposure accumulation and portfolio changes.',
    `concentration_index` DECIMAL(10,4) COMMENT 'Calculated concentration risk index for this event-geography combination, used for portfolio diversification analysis and reinsurance purchasing decisions.',
    `gwp_amount` DECIMAL(18,2) COMMENT 'Gross written premium for policies exposed in this geography for this catastrophe event, used for loss ratio and exposure density analysis.',
    `insured_risk_count` BIGINT COMMENT 'Number of individual insured risks (locations, buildings, vehicles) exposed in this geography for this catastrophe event.',
    `nwp_amount` DECIMAL(18,2) COMMENT 'Net written premium (after reinsurance cessions) for policies exposed in this geography for this catastrophe event.',
    `pml_amount` DECIMAL(18,2) COMMENT 'Probable maximum loss amount for this geography within this catastrophe event, calculated by actuarial models for capital adequacy and reinsurance structuring.',
    `policy_count` BIGINT COMMENT 'Number of in-force policies with exposure in this geography at the time of the catastrophe event.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value of all insured risks within this geography for this catastrophe event, used for PML and concentration calculations.',
    CONSTRAINT pk_catastrophe_event_geography_exposure PRIMARY KEY(`catastrophe_event_geography_exposure_id`)
) COMMENT 'Association between catastrophe events and affected geographies capturing exposure metrics. One row per catastrophe event per geography unit. Tracks TIV, policy count, insured risk count, concentration index, PML, AAL, and premium for each event-geography';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ADD CONSTRAINT `fk_catastrophegeography_catastrophe_event_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ADD CONSTRAINT `fk_catastrophegeography_cat_zone_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ADD CONSTRAINT `fk_catastrophegeography_cat_zone_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ADD CONSTRAINT `fk_catastrophegeography_cat_zone_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ADD CONSTRAINT `fk_catastrophegeography_geography_parent_geography_id` FOREIGN KEY (`parent_geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ADD CONSTRAINT `fk_catastrophegeography_geography_hierarchy_primary_ancestor_geography_id` FOREIGN KEY (`primary_ancestor_geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ADD CONSTRAINT `fk_catastrophegeography_territory_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ADD CONSTRAINT `fk_catastrophegeography_territory_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ADD CONSTRAINT `fk_catastrophegeography_hazard_score_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ADD CONSTRAINT `fk_catastrophegeography_hazard_score_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ADD CONSTRAINT `fk_catastrophegeography_hazard_score_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ADD CONSTRAINT `fk_catastrophegeography_exposure_summary_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ADD CONSTRAINT `fk_catastrophegeography_exposure_summary_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ADD CONSTRAINT `fk_catastrophegeography_exposure_summary_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ADD CONSTRAINT `fk_catastrophegeography_exposure_summary_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ADD CONSTRAINT `fk_catastrophegeography_exposure_summary_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ADD CONSTRAINT `fk_catastrophegeography_cat_event_zone_xref_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ADD CONSTRAINT `fk_catastrophegeography_cat_event_zone_xref_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ADD CONSTRAINT `fk_catastrophegeography_cat_event_zone_xref_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ADD CONSTRAINT `fk_catastrophegeography_cat_event_zone_xref_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ADD CONSTRAINT `fk_catastrophegeography_location_geocode_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ADD CONSTRAINT `fk_catastrophegeography_location_geocode_flood_zone_id` FOREIGN KEY (`flood_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone`(`flood_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ADD CONSTRAINT `fk_catastrophegeography_location_geocode_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ADD CONSTRAINT `fk_catastrophegeography_flood_zone_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ADD CONSTRAINT `fk_catastrophegeography_flood_zone_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_exposure_summary_id` FOREIGN KEY (`exposure_summary_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary`(`exposure_summary_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ADD CONSTRAINT `fk_catastrophegeography_pml_return_period_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ADD CONSTRAINT `fk_catastrophegeography_pml_return_period_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ADD CONSTRAINT `fk_catastrophegeography_pml_return_period_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ADD CONSTRAINT `fk_catastrophegeography_pml_return_period_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ADD CONSTRAINT `fk_catastrophegeography_pml_return_period_pml_run_id` FOREIGN KEY (`pml_run_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run`(`pml_run_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ADD CONSTRAINT `fk_catastrophegeography_cat_model_version_superseded_by_version_cat_model_version_id` FOREIGN KEY (`superseded_by_version_cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ADD CONSTRAINT `fk_catastrophegeography_iso_cat_serial_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ADD CONSTRAINT `fk_catastrophegeography_iso_cat_serial_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ADD CONSTRAINT `fk_catastrophegeography_cat_event_zone_impact_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ADD CONSTRAINT `fk_catastrophegeography_cat_event_zone_impact_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ADD CONSTRAINT `fk_catastrophegeography_catastrophe_event_geography_exposure_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ADD CONSTRAINT `fk_catastrophegeography_catastrophe_event_geography_exposure_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`catastrophegeography` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`catastrophegeography` SET TAGS ('dbx_domain' = 'catastrophegeography');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` SET TAGS ('dbx_subdomain' = 'event_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `acres_burned` SET TAGS ('dbx_business_glossary_term' = 'Acres Burned');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `actual_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `affected_countries` SET TAGS ('dbx_business_glossary_term' = 'Affected Countries');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `affected_states` SET TAGS ('dbx_business_glossary_term' = 'Affected States');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `cat_bond_trigger_flag` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Bond Trigger Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `declaration_date` SET TAGS ('dbx_business_glossary_term' = 'Declaration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `epicenter_latitude` SET TAGS ('dbx_business_glossary_term' = 'Epicenter Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `epicenter_latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `epicenter_latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `epicenter_longitude` SET TAGS ('dbx_business_glossary_term' = 'Epicenter Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `epicenter_longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `epicenter_longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `estimated_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Estimated Claim Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Event Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Event Duration in Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_end_date` SET TAGS ('dbx_business_glossary_term' = 'Event End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_name` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_start_date` SET TAGS ('dbx_business_glossary_term' = 'Event Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Event Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'active|closed|under_review|pending_declaration');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Event Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `event_type` SET TAGS ('dbx_value_regex' = 'natural|man-made|terrorism|pandemic|cyber');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `federal_disaster_declaration_flag` SET TAGS ('dbx_business_glossary_term' = 'Federal Disaster Declaration Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `fema_disaster_number` SET TAGS ('dbx_business_glossary_term' = 'Federal Emergency Management Agency (FEMA) Disaster Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `fema_disaster_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}-[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `geographic_footprint_description` SET TAGS ('dbx_business_glossary_term' = 'Geographic Footprint Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `industry_loss_estimate_amount` SET TAGS ('dbx_business_glossary_term' = 'Industry Loss Estimate Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `industry_loss_estimate_currency` SET TAGS ('dbx_business_glossary_term' = 'Industry Loss Estimate Currency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `industry_loss_estimate_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `iso_cat_serial_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Catastrophe Serial Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `iso_cat_serial_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,12}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `loss_development_factor` SET TAGS ('dbx_business_glossary_term' = 'Loss Development Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `magnitude_scale` SET TAGS ('dbx_business_glossary_term' = 'Magnitude Scale');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `magnitude_value` SET TAGS ('dbx_business_glossary_term' = 'Magnitude Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `modeled_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Modeled Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `nfip_participation_flag` SET TAGS ('dbx_business_glossary_term' = 'National Flood Insurance Program (NFIP) Participation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `peril_type` SET TAGS ('dbx_business_glossary_term' = 'Peril Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `peril_type` SET TAGS ('dbx_value_regex' = 'hurricane|earthquake|wildfire|flood|tornado|hail');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `pml_class` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `pml_class` SET TAGS ('dbx_value_regex' = 'minor|moderate|major|severe|catastrophic');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `precipitation_inches` SET TAGS ('dbx_business_glossary_term' = 'Total Precipitation in Inches');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `reinsurance_trigger_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Trigger Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Return Period in Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `storm_surge_feet` SET TAGS ('dbx_business_glossary_term' = 'Storm Surge Height in Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ALTER COLUMN `wind_speed_mph` SET TAGS ('dbx_business_glossary_term' = 'Maximum Wind Speed in Miles Per Hour (MPH)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` SET TAGS ('dbx_subdomain' = 'event_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `concentration_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Concentration Threshold Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `concentration_threshold_percentage` SET TAGS ('dbx_business_glossary_term' = 'Concentration Threshold Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `iso_territory_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `last_cat_event_date` SET TAGS ('dbx_business_glossary_term' = 'Last Catastrophe (CAT) Event Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `last_cat_event_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Last Catastrophe (CAT) Event Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `last_cat_event_name` SET TAGS ('dbx_business_glossary_term' = 'Last Catastrophe (CAT) Event Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `last_cat_event_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `model_update_date` SET TAGS ('dbx_business_glossary_term' = 'Model Update Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `modeling_vendor` SET TAGS ('dbx_business_glossary_term' = 'Modeling Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `modeling_vendor` SET TAGS ('dbx_value_regex' = 'RMS|AIR|CoreLogic|KCC|Internal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `moratorium_end_date` SET TAGS ('dbx_business_glossary_term' = 'Moratorium End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `moratorium_flag` SET TAGS ('dbx_business_glossary_term' = 'Moratorium Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `moratorium_start_date` SET TAGS ('dbx_business_glossary_term' = 'Moratorium Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `naic_territory_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `peril_type` SET TAGS ('dbx_business_glossary_term' = 'Peril Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `peril_type` SET TAGS ('dbx_value_regex' = 'wind|earthquake|flood|hail|wildfire|tornado');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `pml_100_year_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) 100-Year Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `pml_250_year_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) 250-Year Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `pml_500_year_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) 500-Year Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `regulatory_reporting_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `reinsurance_attachment_point` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Attachment Point');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `reinsurance_limit` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `underwriting_restriction_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Restriction Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_code` SET TAGS ('dbx_business_glossary_term' = 'Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_description` SET TAGS ('dbx_business_glossary_term' = 'Zone Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_name` SET TAGS ('dbx_business_glossary_term' = 'Zone Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_status` SET TAGS ('dbx_business_glossary_term' = 'Zone Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|under_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_tier` SET TAGS ('dbx_business_glossary_term' = 'Zone Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ALTER COLUMN `zone_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` SET TAGS ('dbx_subdomain' = 'spatial_reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `parent_geography_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Geography Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `catastrophe_zone` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `census_tract_code` SET TAGS ('dbx_business_glossary_term' = 'Census Tract Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `coastal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Coastal Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `geography_code` SET TAGS ('dbx_business_glossary_term' = 'Geography Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `county_code` SET TAGS ('dbx_business_glossary_term' = 'County Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `cresta_zone_code` SET TAGS ('dbx_business_glossary_term' = 'CRESTA (Catastrophe Risk Evaluating and Standardizing Target Accumulations) Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `earthquake_zone` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `flood_zone` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `geography_status` SET TAGS ('dbx_business_glossary_term' = 'Geography Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `geography_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `geography_type` SET TAGS ('dbx_business_glossary_term' = 'Geography Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `geography_type` SET TAGS ('dbx_value_regex' = 'country|state|county|zip|cresta_zone|census_tract');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `hail_zone` SET TAGS ('dbx_business_glossary_term' = 'Hail Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `last_updated_date` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `median_household_income` SET TAGS ('dbx_business_glossary_term' = 'Median Household Income');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `median_household_income` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `geography_name` SET TAGS ('dbx_business_glossary_term' = 'Geography Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `geography_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `population` SET TAGS ('dbx_business_glossary_term' = 'Population');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `rating_territory` SET TAGS ('dbx_business_glossary_term' = 'Rating Territory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `tornado_zone` SET TAGS ('dbx_business_glossary_term' = 'Tornado Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `urban_rural_code` SET TAGS ('dbx_business_glossary_term' = 'Urban Rural Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `wildfire_zone` SET TAGS ('dbx_business_glossary_term' = 'Wildfire Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `wind_zone` SET TAGS ('dbx_business_glossary_term' = 'Wind Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `zip_code` SET TAGS ('dbx_business_glossary_term' = 'ZIP Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `zip_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography` ALTER COLUMN `zip_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` SET TAGS ('dbx_subdomain' = 'spatial_reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `geography_hierarchy_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Hierarchy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `primary_ancestor_geography_id` SET TAGS ('dbx_business_glossary_term' = 'Ancestor Geography Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `aggregation_weight` SET TAGS ('dbx_business_glossary_term' = 'Aggregation Weight Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `aggregation_weight` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `ancestor_geography_type` SET TAGS ('dbx_business_glossary_term' = 'Ancestor Geography Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `cat_zone_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `depth_level` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Depth Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `descendant_geography_type` SET TAGS ('dbx_business_glossary_term' = 'Descendant Geography Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `hierarchy_status` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Relationship Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `hierarchy_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `hierarchy_version` SET TAGS ('dbx_business_glossary_term' = 'Geography Hierarchy Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `is_leaf_node` SET TAGS ('dbx_business_glossary_term' = 'Is Leaf Node Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `is_root_node` SET TAGS ('dbx_business_glossary_term' = 'Is Root Node Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `iso_territory_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `naic_company_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Company Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Relationship Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `path_length` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Path Length');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Relationship Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `relationship_type` SET TAGS ('dbx_value_regex' = 'self|direct_parent|ancestor|rollup');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `schedule_p_territory_code` SET TAGS ('dbx_business_glossary_term' = 'Schedule P Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography_hierarchy` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` SET TAGS ('dbx_subdomain' = 'spatial_reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `aal_contribution_pct` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Contribution Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `base_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Rate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `county_list` SET TAGS ('dbx_business_glossary_term' = 'County List');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `crime_index` SET TAGS ('dbx_business_glossary_term' = 'Crime Index');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `exposure_base` SET TAGS ('dbx_business_glossary_term' = 'Exposure Base');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `exposure_base` SET TAGS ('dbx_value_regex' = 'per_policy|per_vehicle|per_location|per_100_payroll|per_1000_si');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `filing_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{1,20}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|withdrawn|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `geographic_region` SET TAGS ('dbx_value_regex' = 'coastal|inland|urban|suburban|rural');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `loss_cost` SET TAGS ('dbx_business_glossary_term' = 'Loss Cost');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `median_household_income` SET TAGS ('dbx_business_glossary_term' = 'Median Household Income');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `median_household_income` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `moratorium_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Moratorium Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `moratorium_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Moratorium Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `moratorium_flag` SET TAGS ('dbx_business_glossary_term' = 'Moratorium Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `territory_name` SET TAGS ('dbx_business_glossary_term' = 'Territory Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `territory_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `pml_contribution_pct` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Contribution Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `population_density` SET TAGS ('dbx_business_glossary_term' = 'Population Density');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `protection_class_range` SET TAGS ('dbx_business_glossary_term' = 'Protection Class Range');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `rate_relativity` SET TAGS ('dbx_business_glossary_term' = 'Rate Relativity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `residual_market_flag` SET TAGS ('dbx_business_glossary_term' = 'Residual Market Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `tier` SET TAGS ('dbx_business_glossary_term' = 'Territory Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `tier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `tiv_concentration` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Concentration');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `weather_zone` SET TAGS ('dbx_business_glossary_term' = 'Weather Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `weather_zone` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `wind_pool_flag` SET TAGS ('dbx_business_glossary_term' = 'Wind Pool Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `zip_code_list` SET TAGS ('dbx_business_glossary_term' = 'ZIP Code List');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `zip_code_list` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ALTER COLUMN `zip_code_list` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` SET TAGS ('dbx_subdomain' = 'hazard_modeling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `cat_model_peril_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_status` SET TAGS ('dbx_business_glossary_term' = 'Peril Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_category` SET TAGS ('dbx_business_glossary_term' = 'Peril Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_category` SET TAGS ('dbx_value_regex' = 'natural|man-made|liability|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `coverage_form_applicability` SET TAGS ('dbx_business_glossary_term' = 'Coverage Form Applicability');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_description` SET TAGS ('dbx_business_glossary_term' = 'Peril Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `endorsement_required` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `fraud_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Fraud Risk Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `fraud_risk_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `frequency_classification` SET TAGS ('dbx_business_glossary_term' = 'Frequency Classification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `frequency_classification` SET TAGS ('dbx_value_regex' = 'high|medium|low|rare');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `geographic_restriction` SET TAGS ('dbx_business_glossary_term' = 'Geographic Restriction');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `is_cat_peril` SET TAGS ('dbx_business_glossary_term' = 'Is Catastrophe (CAT) Peril Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `is_covered_by_standard_policy` SET TAGS ('dbx_business_glossary_term' = 'Is Covered by Standard Policy Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `is_excluded_by_default` SET TAGS ('dbx_business_glossary_term' = 'Is Excluded by Default Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `is_reportable_to_naic` SET TAGS ('dbx_business_glossary_term' = 'Is Reportable to National Association of Insurance Commissioners (NAIC) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `is_subject_to_state_regulation` SET TAGS ('dbx_business_glossary_term' = 'Is Subject to State Regulation Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `is_subject_to_state_regulation` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `iso_cause_of_loss_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Cause of Loss Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `iso_cause_of_loss_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `lob_applicability` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Applicability');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `naic_peril_code` SET TAGS ('dbx_business_glossary_term' = 'National Association of Insurance Commissioners (NAIC) Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `naic_peril_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_name` SET TAGS ('dbx_business_glossary_term' = 'Peril Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `catastrophegeography_peril_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `nfip_covered` SET TAGS ('dbx_business_glossary_term' = 'National Flood Insurance Program (NFIP) Covered Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Peril Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `reinsurance_treaty_peril_mapping` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Peril Mapping');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `requires_separate_deductible` SET TAGS ('dbx_business_glossary_term' = 'Requires Separate Deductible Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `requires_separate_limit` SET TAGS ('dbx_business_glossary_term' = 'Requires Separate Limit Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `requires_specialist_adjuster` SET TAGS ('dbx_business_glossary_term' = 'Requires Specialist Adjuster Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `salvage_potential` SET TAGS ('dbx_business_glossary_term' = 'Salvage Potential');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `salvage_potential` SET TAGS ('dbx_value_regex' = 'high|medium|low|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `seasonal_pattern` SET TAGS ('dbx_business_glossary_term' = 'Seasonal Pattern');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `severity_classification` SET TAGS ('dbx_business_glossary_term' = 'Severity Classification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `severity_classification` SET TAGS ('dbx_value_regex' = 'catastrophic|severe|moderate|minor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `subrogation_potential` SET TAGS ('dbx_business_glossary_term' = 'Subrogation Potential');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `subrogation_potential` SET TAGS ('dbx_value_regex' = 'high|medium|low|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `typical_deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Typical Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `typical_deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|franchise|disappearing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `typical_investigation_complexity` SET TAGS ('dbx_business_glossary_term' = 'Typical Investigation Complexity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `typical_investigation_complexity` SET TAGS ('dbx_value_regex' = 'simple|moderate|complex|highly_complex');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` SET TAGS ('dbx_subdomain' = 'hazard_modeling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `hazard_score_id` SET TAGS ('dbx_business_glossary_term' = 'Hazard Score Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Zone Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `building_area_sqft` SET TAGS ('dbx_business_glossary_term' = 'Building Area Square Feet (sqft)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `cat_model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `cat_model_vendor` SET TAGS ('dbx_value_regex' = 'RMS|AIR|EQECAT|KAREN_CLARK|INTERNAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'FRAME|JOISTED_MASONRY|NON_COMBUSTIBLE|MASONRY_NON_COMBUSTIBLE|MODIFIED_FIRE_RESISTIVE|FIRE_RESISTIVE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `distance_to_coast_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Coast Miles');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `elevation_feet` SET TAGS ('dbx_business_glossary_term' = 'Elevation Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `eligibility_reason` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `exceedance_probability` SET TAGS ('dbx_business_glossary_term' = 'Exceedance Probability');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `flood_zone` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `geocode_quality` SET TAGS ('dbx_business_glossary_term' = 'Geocode Quality');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `geocode_quality` SET TAGS ('dbx_value_regex' = 'ROOFTOP|PARCEL|STREET|ZIP|CITY|COUNTY');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `hazard_band` SET TAGS ('dbx_business_glossary_term' = 'Hazard Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `hazard_band` SET TAGS ('dbx_value_regex' = 'LOW|MODERATE|HIGH|SEVERE|EXTREME');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `hazard_score` SET TAGS ('dbx_business_glossary_term' = 'Hazard Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `model_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Model Confidence Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `model_confidence_level` SET TAGS ('dbx_value_regex' = 'HIGH|MEDIUM|LOW');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `model_run_date` SET TAGS ('dbx_business_glossary_term' = 'Model Run Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `pml_1000_year` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) 1000-Year Return Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `pml_100_year` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) 100-Year Return Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `pml_250_year` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) 250-Year Return Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `pml_500_year` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) 500-Year Return Period');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `score_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Score Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `score_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Score Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `soil_type` SET TAGS ('dbx_business_glossary_term' = 'Soil Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `soil_type` SET TAGS ('dbx_value_regex' = 'ROCK|STIFF_SOIL|SOFT_SOIL|VERY_SOFT_SOIL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `underwriting_eligibility_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Eligibility Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` SET TAGS ('dbx_subdomain' = 'accumulation_control');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `exposure_summary_id` SET TAGS ('dbx_business_glossary_term' = 'Exposure Summary Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Node Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `as_of_date` SET TAGS ('dbx_business_glossary_term' = 'As-Of Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `concentration_index` SET TAGS ('dbx_business_glossary_term' = 'Concentration Index');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `construction_class` SET TAGS ('dbx_business_glossary_term' = 'Construction Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `construction_class` SET TAGS ('dbx_value_regex' = 'FRAME|MASONRY|STEEL|CONCRETE|MIXED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_business_glossary_term' = 'Exposure Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_value_regex' = 'TIV|LIMIT|PREMIUM|UNIT_COUNT');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `geocoding_accuracy` SET TAGS ('dbx_business_glossary_term' = 'Geocoding Accuracy Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `geocoding_accuracy` SET TAGS ('dbx_value_regex' = 'ROOFTOP|STREET|ZIP|COUNTY|STATE');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium (GWP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `insured_risk_count` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Exposure Summary Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium (NWP) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `occupancy_class` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `occupancy_class` SET TAGS ('dbx_value_regex' = 'RESIDENTIAL|COMMERCIAL|INDUSTRIAL|AGRICULTURAL|MIXED');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `pml_return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Return Period (Years)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `treaty_share_percent` SET TAGS ('dbx_business_glossary_term' = 'Treaty Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ALTER COLUMN `zone_code` SET TAGS ('dbx_business_glossary_term' = 'Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` SET TAGS ('dbx_subdomain' = 'event_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `cat_event_loss_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Loss ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `claimfinancials_accounting_period_id` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `accident_year` SET TAGS ('dbx_business_glossary_term' = 'Accident Year (AY)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `alae_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Loss Adjustment Expense (ALAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `average_annual_loss` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `claim_count_estimate` SET TAGS ('dbx_business_glossary_term' = 'Claim Count Estimate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `confidence_level_percent` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level Percent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `estimate_date` SET TAGS ('dbx_business_glossary_term' = 'Estimate Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `estimate_status` SET TAGS ('dbx_business_glossary_term' = 'Estimate Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `estimate_status` SET TAGS ('dbx_value_regex' = 'preliminary|interim|final|revised|superseded');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `geography_code` SET TAGS ('dbx_business_glossary_term' = 'Geography Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `geography_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `ibnr_loading_amount` SET TAGS ('dbx_business_glossary_term' = 'Incurred But Not Reported (IBNR) Loading Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `loss_estimate_type` SET TAGS ('dbx_business_glossary_term' = 'Loss Estimate Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `loss_estimate_type` SET TAGS ('dbx_value_regex' = 'modeled|actual|hybrid|preliminary|final');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `loss_ratio_percent` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR) Percent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `model_vendor` SET TAGS ('dbx_value_regex' = 'RMS|AIR|CoreLogic|KCC|Internal|Other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `net_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `probable_maximum_loss` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Return Period Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `total_insured_value` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `ulae_amount` SET TAGS ('dbx_business_glossary_term' = 'Unallocated Loss Adjustment Expense (ULAE) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` SET TAGS ('dbx_subdomain' = 'event_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `cat_event_zone_xref_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Zone Cross-Reference ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'model|observed|hybrid');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `exposed_policy_count` SET TAGS ('dbx_business_glossary_term' = 'Exposed Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `exposed_tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Exposed Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `exposure_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exposure End Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `exposure_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exposure Start Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `fire_perimeter_flag` SET TAGS ('dbx_business_glossary_term' = 'Fire Perimeter Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `fire_proximity_miles` SET TAGS ('dbx_business_glossary_term' = 'Fire Proximity (Miles)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `flood_depth_ft` SET TAGS ('dbx_business_glossary_term' = 'Flood Depth (Feet)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `fnol_priority_score` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Priority Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `geocoding_accuracy` SET TAGS ('dbx_business_glossary_term' = 'Geocoding Accuracy');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `geocoding_accuracy` SET TAGS ('dbx_value_regex' = 'rooftop|parcel|street|zip|county');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `hail_size_inches` SET TAGS ('dbx_business_glossary_term' = 'Hail Size (Inches)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `impact_severity_band` SET TAGS ('dbx_business_glossary_term' = 'Impact Severity Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `impact_severity_band` SET TAGS ('dbx_value_regex' = 'minimal|light|moderate|severe|catastrophic|extreme');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `model_vendor` SET TAGS ('dbx_value_regex' = 'RMS|AIR|CoreLogic|KCC|Internal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `modeled_damage_percent` SET TAGS ('dbx_business_glossary_term' = 'Modeled Damage Percent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `modeled_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Modeled Loss Ratio');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `peak_ground_acceleration` SET TAGS ('dbx_business_glossary_term' = 'Peak Ground Acceleration (PGA)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `rainfall_inches` SET TAGS ('dbx_business_glossary_term' = 'Rainfall (Inches)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `shake_intensity` SET TAGS ('dbx_business_glossary_term' = 'Shake Intensity (Modified Mercalli Intensity)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `storm_surge_flag` SET TAGS ('dbx_business_glossary_term' = 'Storm Surge Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `storm_surge_height_ft` SET TAGS ('dbx_business_glossary_term' = 'Storm Surge Height (Feet)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `storm_surge_height_ft` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `sub_peril_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `tornado_rating` SET TAGS ('dbx_business_glossary_term' = 'Tornado Rating (Enhanced Fujita Scale)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `tornado_rating` SET TAGS ('dbx_value_regex' = 'EF0|EF1|EF2|EF3|EF4|EF5');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `wind_gust_mph` SET TAGS ('dbx_business_glossary_term' = 'Wind Gust Speed (Miles Per Hour)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `wind_speed_mph` SET TAGS ('dbx_business_glossary_term' = 'Wind Speed (Miles Per Hour)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `zone_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `zone_type` SET TAGS ('dbx_business_glossary_term' = 'Zone Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_xref` ALTER COLUMN `zone_type` SET TAGS ('dbx_value_regex' = 'county|zip|cresta|model_zone|custom');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` SET TAGS ('dbx_subdomain' = 'spatial_reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `location_geocode_id` SET TAGS ('dbx_business_glossary_term' = 'Location Geocode ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `flood_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `address_line_1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `address_line_2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `base_flood_elevation_ft` SET TAGS ('dbx_business_glossary_term' = 'Base Flood Elevation (BFE) in Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `cat_model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `cat_model_vendor` SET TAGS ('dbx_value_regex' = 'RMS|AIR|CoreLogic|KCC|None');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `cat_model_version` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `cresta_zone_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Risk Evaluating and Standardizing Target Accumulations (CRESTA) Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `earthquake_aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `earthquake_pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fema_firm_panel_number` SET TAGS ('dbx_business_glossary_term' = 'Federal Emergency Management Agency (FEMA) Flood Insurance Rate Map (FIRM) Panel ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fema_flood_zone` SET TAGS ('dbx_business_glossary_term' = 'Federal Emergency Management Agency (FEMA) Flood Zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fips_county_code` SET TAGS ('dbx_business_glossary_term' = 'Federal Information Processing Standards (FIPS) County Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fips_county_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fips_state_code` SET TAGS ('dbx_business_glossary_term' = 'Federal Information Processing Standards (FIPS) State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fips_state_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fips_state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fire_protection_class` SET TAGS ('dbx_business_glossary_term' = 'Fire Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `fire_protection_class` SET TAGS ('dbx_value_regex' = '^(1|2|3|4|5|6|7|8|9|10)$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `flood_aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Flood Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `flood_pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Flood Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `geocode_match_level` SET TAGS ('dbx_business_glossary_term' = 'Geocode Match Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `geocode_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Geocode Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `geocode_source` SET TAGS ('dbx_business_glossary_term' = 'Geocode Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `geocode_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Geocode Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hail_aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Hail Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hail_pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Hail Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hazard_band_earthquake` SET TAGS ('dbx_business_glossary_term' = 'Hazard Band for Earthquake');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hazard_band_earthquake` SET TAGS ('dbx_value_regex' = 'low|moderate|high|very_high|extreme');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hazard_band_flood` SET TAGS ('dbx_business_glossary_term' = 'Hazard Band for Flood');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hazard_band_flood` SET TAGS ('dbx_value_regex' = 'low|moderate|high|very_high|extreme');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hazard_band_hurricane` SET TAGS ('dbx_business_glossary_term' = 'Hazard Band for Hurricane');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hazard_band_hurricane` SET TAGS ('dbx_value_regex' = 'low|moderate|high|very_high|extreme');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hazard_band_wildfire` SET TAGS ('dbx_business_glossary_term' = 'Hazard Band for Wildfire');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hazard_band_wildfire` SET TAGS ('dbx_value_regex' = 'low|moderate|high|very_high|extreme');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hurricane_aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Hurricane Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `hurricane_pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Hurricane Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `iso_territory_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `pml_return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Return Period in Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `state_province_code` SET TAGS ('dbx_business_glossary_term' = 'State or Province Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `state_province_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `state_province_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `tornado_aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Tornado Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `tornado_pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Tornado Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `wildfire_aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Wildfire Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ALTER COLUMN `wildfire_pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Wildfire Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` SET TAGS ('dbx_subdomain' = 'spatial_reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `flood_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `area_square_miles` SET TAGS ('dbx_business_glossary_term' = 'Area in Square Miles');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `base_flood_elevation_feet` SET TAGS ('dbx_business_glossary_term' = 'Base Flood Elevation (BFE) in Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `base_rate_factor` SET TAGS ('dbx_business_glossary_term' = 'Base Rate Factor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `catastrophe_zone_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `coastal_barrier_flag` SET TAGS ('dbx_business_glossary_term' = 'Coastal Barrier Resources System (CBRS) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `community_name` SET TAGS ('dbx_business_glossary_term' = 'NFIP Community Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `community_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `community_number` SET TAGS ('dbx_business_glossary_term' = 'NFIP Community Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `community_number` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `county_fips_code` SET TAGS ('dbx_business_glossary_term' = 'County Federal Information Processing Standards (FIPS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `county_fips_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `depth_feet` SET TAGS ('dbx_business_glossary_term' = 'Flood Depth in Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `digital_conversion_date` SET TAGS ('dbx_business_glossary_term' = 'Digital Conversion Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'FIRM Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `elevation_datum` SET TAGS ('dbx_business_glossary_term' = 'Elevation Datum');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `elevation_datum` SET TAGS ('dbx_value_regex' = 'NAVD88|NGVD29|LOCAL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `firm_panel_number` SET TAGS ('dbx_business_glossary_term' = 'Flood Insurance Rate Map (FIRM) Panel Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `firm_panel_number` SET TAGS ('dbx_value_regex' = '^[0-9]{10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `flood_frequency_percent` SET TAGS ('dbx_business_glossary_term' = 'Annual Flood Frequency Percent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `flood_hazard_description` SET TAGS ('dbx_business_glossary_term' = 'Flood Hazard Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `flood_source` SET TAGS ('dbx_business_glossary_term' = 'Flood Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `flood_zone_status` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `flood_zone_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|SUPERSEDED|PENDING|WITHDRAWN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `floodway_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Floodway Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `geocode_latitude` SET TAGS ('dbx_business_glossary_term' = 'Geocode Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `geocode_latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `geocode_latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `geocode_longitude` SET TAGS ('dbx_business_glossary_term' = 'Geocode Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `geocode_longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `geocode_longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `geometry_wkt` SET TAGS ('dbx_business_glossary_term' = 'Geometry Well-Known Text (WKT)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `insurance_mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Flood Insurance Mandatory Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `last_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Last Verified Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `letter_of_map_change_number` SET TAGS ('dbx_business_glossary_term' = 'Letter of Map Change (LOMC) Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `lomc_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Letter of Map Change (LOMC) Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `preliminary_flag` SET TAGS ('dbx_business_glossary_term' = 'Preliminary FIRM Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `rating_territory` SET TAGS ('dbx_business_glossary_term' = 'Rating Territory');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `reinsurance_treaty_applicability` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Applicability');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `revision_date` SET TAGS ('dbx_business_glossary_term' = 'FIRM Revision Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `special_flood_hazard_area_flag` SET TAGS ('dbx_business_glossary_term' = 'Special Flood Hazard Area (SFHA) Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `state_code` SET TAGS ('dbx_business_glossary_term' = 'State Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `state_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `static_bfe_feet` SET TAGS ('dbx_business_glossary_term' = 'Static Base Flood Elevation (BFE) in Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `study_type` SET TAGS ('dbx_business_glossary_term' = 'Flood Study Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `underwriting_eligibility_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Eligibility Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `underwriting_eligibility_code` SET TAGS ('dbx_value_regex' = 'ELIGIBLE|INELIGIBLE|RESTRICTED|REFER');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `velocity_fps` SET TAGS ('dbx_business_glossary_term' = 'Flood Velocity in Feet Per Second (FPS)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `wave_height_feet` SET TAGS ('dbx_business_glossary_term' = 'Wave Height in Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `wave_height_feet` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `zone_designation` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Designation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone` ALTER COLUMN `zone_subtype` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Subtype');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` SET TAGS ('dbx_subdomain' = 'hazard_modeling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `pml_run_id` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Run Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `approved_by_user_party_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `approved_by_user_party_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `approved_by_user_party_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `exposure_summary_id` SET TAGS ('dbx_business_glossary_term' = 'Exposure Snapshot Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_owner_party_id` SET TAGS ('dbx_business_glossary_term' = 'Executed By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_owner_party_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_owner_party_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `ri_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Program Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Treaty Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `aal_gross` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Gross');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `aal_net` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Net');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `completion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Completion Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `demand_surge_applied` SET TAGS ('dbx_business_glossary_term' = 'Demand Surge Applied Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `event_set_version` SET TAGS ('dbx_business_glossary_term' = 'Event Set Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `exposure_as_of_date` SET TAGS ('dbx_business_glossary_term' = 'Exposure As-Of Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `geocoding_accuracy_percent` SET TAGS ('dbx_business_glossary_term' = 'Geocoding Accuracy Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `geography_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `location_count` SET TAGS ('dbx_business_glossary_term' = 'Location Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `loss_amplification_applied` SET TAGS ('dbx_business_glossary_term' = 'Loss Amplification Applied Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'Model Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `model_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `model_vendor` SET TAGS ('dbx_value_regex' = 'RMS|AIR|CoreLogic|KCC|EQECAT|Other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `rating_agency_submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency Submission Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `regulatory_filing_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `return_period_1000_gross_pml` SET TAGS ('dbx_business_glossary_term' = '1000-Year Return Period Gross Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `return_period_1000_net_pml` SET TAGS ('dbx_business_glossary_term' = '1000-Year Return Period Net Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `return_period_100_gross_pml` SET TAGS ('dbx_business_glossary_term' = '100-Year Return Period Gross Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `return_period_100_net_pml` SET TAGS ('dbx_business_glossary_term' = '100-Year Return Period Net Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `return_period_250_gross_pml` SET TAGS ('dbx_business_glossary_term' = '250-Year Return Period Gross Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `return_period_250_net_pml` SET TAGS ('dbx_business_glossary_term' = '250-Year Return Period Net Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `return_period_500_gross_pml` SET TAGS ('dbx_business_glossary_term' = '500-Year Return Period Gross Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `return_period_500_net_pml` SET TAGS ('dbx_business_glossary_term' = '500-Year Return Period Net Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_date` SET TAGS ('dbx_business_glossary_term' = 'Run Execution Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Run Duration in Minutes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_name` SET TAGS ('dbx_business_glossary_term' = 'Run Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_number` SET TAGS ('dbx_business_glossary_term' = 'Run Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_status` SET TAGS ('dbx_business_glossary_term' = 'Run Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_status` SET TAGS ('dbx_value_regex' = 'Pending|Running|Completed|Failed|Cancelled|Validated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Run Execution Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_type` SET TAGS ('dbx_business_glossary_term' = 'Run Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `run_type` SET TAGS ('dbx_value_regex' = 'Annual|Quarterly|Ad-Hoc|Regulatory|Treaty|Facultative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `simulation_count` SET TAGS ('dbx_business_glossary_term' = 'Simulation Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `treaty_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Treaty Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ALTER COLUMN `vulnerability_set_version` SET TAGS ('dbx_business_glossary_term' = 'Vulnerability Set Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` SET TAGS ('dbx_subdomain' = 'hazard_modeling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `pml_return_period_id` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Return Period ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Node ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `pml_run_id` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Run ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `as_of_date` SET TAGS ('dbx_business_glossary_term' = 'As-Of Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `ceded_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceded Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `coefficient_of_variation` SET TAGS ('dbx_business_glossary_term' = 'Coefficient of Variation (CV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `confidence_level_percent` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level Percent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `exceedance_probability` SET TAGS ('dbx_business_glossary_term' = 'Exceedance Probability');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `geocoding_accuracy` SET TAGS ('dbx_business_glossary_term' = 'Geocoding Accuracy Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `geocoding_accuracy` SET TAGS ('dbx_value_regex' = 'rooftop|street|zip|city|county|state');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `insured_risk_count` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio (LR)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `model_vendor` SET TAGS ('dbx_value_regex' = 'RMS|AIR|CoreLogic|KCC|Other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `model_version` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9._-]{1,50}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `net_retained_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Retained Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `orsa_scenario_flag` SET TAGS ('dbx_business_glossary_term' = 'Own Risk and Solvency Assessment (ORSA) Scenario Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `percentile_rank` SET TAGS ('dbx_business_glossary_term' = 'Percentile Rank');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `pml_return_period_status` SET TAGS ('dbx_business_glossary_term' = 'Return Period Result Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `pml_return_period_status` SET TAGS ('dbx_value_regex' = 'draft|final|superseded|archived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `rbc_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Capital (RBC) Contribution Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Return Period Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `rol_percent` SET TAGS ('dbx_business_glossary_term' = 'Rate on Line (ROL) Percent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `simulation_count` SET TAGS ('dbx_business_glossary_term' = 'Simulation Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `standard_deviation_amount` SET TAGS ('dbx_business_glossary_term' = 'Standard Deviation Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `treaty_share_percent` SET TAGS ('dbx_business_glossary_term' = 'Treaty Share Percent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `zone_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ALTER COLUMN `zone_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` SET TAGS ('dbx_subdomain' = 'accumulation_control');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `accumulation_limit_id` SET TAGS ('dbx_business_glossary_term' = 'Accumulation Limit Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `reinsurance_treaty_id` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `accumulation_limit_status` SET TAGS ('dbx_business_glossary_term' = 'Accumulation Limit Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `accumulation_limit_status` SET TAGS ('dbx_value_regex' = 'active|suspended|expired|pending|withdrawn');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `available_capacity` SET TAGS ('dbx_business_glossary_term' = 'Available Capacity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `business_justification` SET TAGS ('dbx_business_glossary_term' = 'Business Justification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `ceded_percent` SET TAGS ('dbx_business_glossary_term' = 'Ceded Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `hard_threshold_percent` SET TAGS ('dbx_business_glossary_term' = 'Hard Threshold Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Accumulation Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `limit_basis` SET TAGS ('dbx_business_glossary_term' = 'Limit Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `limit_basis` SET TAGS ('dbx_value_regex' = 'occurrence|aggregate|annual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Limit Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_value_regex' = 'tiv|gwp|policy_count|insured_risk_count|pml|aal');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `model_vendor` SET TAGS ('dbx_value_regex' = 'rms|air|karen_clark|eqecat|internal|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `net_retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `override_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Allowed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `override_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Override Authority Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,10}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `pml_return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Return Period in Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `regulatory_requirement_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annually|event_driven');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `soft_threshold_percent` SET TAGS ('dbx_business_glossary_term' = 'Soft Threshold Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `threshold_action` SET TAGS ('dbx_business_glossary_term' = 'Threshold Action');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `threshold_action` SET TAGS ('dbx_value_regex' = 'allow|refer|decline|suspend');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `utilization_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Utilization Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ALTER COLUMN `utilization_percent` SET TAGS ('dbx_business_glossary_term' = 'Utilization Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` SET TAGS ('dbx_subdomain' = 'hazard_modeling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Version Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `superseded_by_version_cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Version Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `approved_jurisdictions` SET TAGS ('dbx_business_glossary_term' = 'Approved Jurisdictions List');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `benchmark_comparison_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Comparison Completed Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `cat_model_version_status` SET TAGS ('dbx_business_glossary_term' = 'Model Version Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `cat_model_version_status` SET TAGS ('dbx_value_regex' = 'active|deprecated|retired|pending|testing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `climate_scenario` SET TAGS ('dbx_business_glossary_term' = 'Climate Change Scenario');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `country_codes` SET TAGS ('dbx_business_glossary_term' = 'Supported Country Codes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `country_codes` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Model Documentation URL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Model Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `event_set_size` SET TAGS ('dbx_business_glossary_term' = 'Stochastic Event Set Size');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Model Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `financial_module_version` SET TAGS ('dbx_business_glossary_term' = 'Financial Module Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `geographic_coverage` SET TAGS ('dbx_business_glossary_term' = 'Geographic Coverage Scope');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `hazard_module_version` SET TAGS ('dbx_business_glossary_term' = 'Hazard Module Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Model License Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `lob_applicability` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Applicability');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `model_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `model_type` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `model_type` SET TAGS ('dbx_value_regex' = 'probabilistic|deterministic|hybrid');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Model Version Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `pml_return_periods` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Return Periods');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `primary_use_case` SET TAGS ('dbx_business_glossary_term' = 'Primary Use Case');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `primary_use_case` SET TAGS ('dbx_value_regex' = 'underwriting|pricing|reinsurance|capital|regulatory|portfolio');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|not_required|rejected');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `release_date` SET TAGS ('dbx_business_glossary_term' = 'Model Release Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `resolution_level` SET TAGS ('dbx_business_glossary_term' = 'Model Resolution Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `simulation_years` SET TAGS ('dbx_business_glossary_term' = 'Simulation Years Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `state_province_coverage` SET TAGS ('dbx_business_glossary_term' = 'State and Province Coverage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `state_province_coverage` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `supported_perils` SET TAGS ('dbx_business_glossary_term' = 'Supported Perils List');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `usage_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Model Usage Restrictions');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `validation_date` SET TAGS ('dbx_business_glossary_term' = 'Internal Validation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Internal Validation Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'passed|failed|in_progress|not_started');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Vendor Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `vendor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Model Version Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version` ALTER COLUMN `vulnerability_functions_version` SET TAGS ('dbx_business_glossary_term' = 'Vulnerability Functions Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` SET TAGS ('dbx_subdomain' = 'accumulation_control');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `policy_cat_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Catastrophe (CAT) Exposure Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `cat_model_version_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Model Version Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Event Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss (AAL) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `as_of_date` SET TAGS ('dbx_business_glossary_term' = 'As Of Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `bordereaux_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Bordereaux Reporting Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `building_area_sqft` SET TAGS ('dbx_business_glossary_term' = 'Building Area Square Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `cat_model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `cat_model_vendor` SET TAGS ('dbx_value_regex' = 'RMS|AIR|CoreLogic|KCC');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `cat_model_version` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `construction_class` SET TAGS ('dbx_business_glossary_term' = 'Construction Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD|MXN');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|franchise');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `estimated_gross_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Gross Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `estimated_net_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Net Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `exposure_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Exposure Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `exposure_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Exposure Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_business_glossary_term' = 'Exposure Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_value_regex' = 'active|expired|cancelled|suspended');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `fnol_triage_priority` SET TAGS ('dbx_business_glossary_term' = 'First Notice of Loss (FNOL) Triage Priority');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `fnol_triage_priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `geocode_quality` SET TAGS ('dbx_business_glossary_term' = 'Geocode Quality');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `geocode_quality` SET TAGS ('dbx_value_regex' = 'rooftop|parcel|street|zip');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `model_run_date` SET TAGS ('dbx_business_glossary_term' = 'Model Run Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `occupancy_class` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `pml_return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Return Period Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `reinsurance_program_code` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Program Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `retention_amount` SET TAGS ('dbx_business_glossary_term' = 'Retention Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `treaty_share_percent` SET TAGS ('dbx_business_glossary_term' = 'Treaty Share Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` SET TAGS ('dbx_subdomain' = 'event_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `iso_cat_serial_id` SET TAGS ('dbx_business_glossary_term' = 'ISO (Insurance Services Office) CAT (Catastrophe) Serial ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `catastrophegeography_peril_id` SET TAGS ('dbx_business_glossary_term' = 'Peril Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `affected_counties` SET TAGS ('dbx_business_glossary_term' = 'Affected Counties');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `affected_lob_codes` SET TAGS ('dbx_business_glossary_term' = 'Affected LOB (Line of Business) Codes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `affected_states` SET TAGS ('dbx_business_glossary_term' = 'Affected States');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `cat_bond_trigger` SET TAGS ('dbx_business_glossary_term' = 'CAT (Catastrophe) Bond Trigger');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `cat_event_name` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `cat_event_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `earthquake_magnitude` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Magnitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `event_category` SET TAGS ('dbx_business_glossary_term' = 'Event Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `event_category` SET TAGS ('dbx_value_regex' = 'natural|man-made|terrorism|pandemic|cyber');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `event_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Event Duration Days');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `event_end_date` SET TAGS ('dbx_business_glossary_term' = 'Event End Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `event_start_date` SET TAGS ('dbx_business_glossary_term' = 'Event Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `fema_disaster_number` SET TAGS ('dbx_business_glossary_term' = 'FEMA (Federal Emergency Management Agency) Disaster Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `fema_disaster_number` SET TAGS ('dbx_value_regex' = '^(DR|EM|FM|FS)-[0-9]{4,5}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `hurricane_category` SET TAGS ('dbx_business_glossary_term' = 'Hurricane Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `hurricane_category` SET TAGS ('dbx_value_regex' = '^(CAT[1-5]|TS|TD)$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `industry_insured_loss_estimate` SET TAGS ('dbx_business_glossary_term' = 'Industry Insured Loss Estimate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `iso_serial_effective_date` SET TAGS ('dbx_business_glossary_term' = 'ISO (Insurance Services Office) Serial Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `iso_serial_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'ISO (Insurance Services Office) Serial Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `loss_estimate_date` SET TAGS ('dbx_business_glossary_term' = 'Loss Estimate Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `loss_estimate_status` SET TAGS ('dbx_business_glossary_term' = 'Loss Estimate Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `loss_estimate_status` SET TAGS ('dbx_value_regex' = 'preliminary|revised|final|withdrawn');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `naic_cat_code` SET TAGS ('dbx_business_glossary_term' = 'NAIC (National Association of Insurance Commissioners) CAT (Catastrophe) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `naic_cat_code` SET TAGS ('dbx_value_regex' = '^[0-9]{3,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'ISO (Insurance Services Office) CAT (Catastrophe) Serial Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,12}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `pcs_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'PCS (Property Claim Services) Threshold Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `pcs_threshold_met` SET TAGS ('dbx_business_glossary_term' = 'PCS (Property Claim Services) Threshold Met');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `peril_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `peril_description` SET TAGS ('dbx_business_glossary_term' = 'Peril Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `primary_state` SET TAGS ('dbx_business_glossary_term' = 'Primary State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `primary_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `primary_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `reinsurance_treaty_trigger` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance Treaty Trigger');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `schedule_p_reportable` SET TAGS ('dbx_business_glossary_term' = 'Schedule P Reportable');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `serial_status` SET TAGS ('dbx_business_glossary_term' = 'Serial Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `serial_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|withdrawn');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `severity_classification` SET TAGS ('dbx_business_glossary_term' = 'Severity Classification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `severity_classification` SET TAGS ('dbx_value_regex' = 'minor|moderate|major|severe|catastrophic');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `total_precipitation_inches` SET TAGS ('dbx_business_glossary_term' = 'Total Precipitation Inches');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`iso_cat_serial` ALTER COLUMN `wind_speed_mph` SET TAGS ('dbx_business_glossary_term' = 'Wind Speed MPH (Miles Per Hour)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` SET TAGS ('dbx_subdomain' = 'event_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` SET TAGS ('dbx_association_edges' = 'catastrophegeography.catastrophe_event,catastrophegeography.cat_zone');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `cat_event_zone_impact_id` SET TAGS ('dbx_business_glossary_term' = 'CAT Event Zone Impact ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Event Zone Impact - Cat Zone Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `exposed_policy_count` SET TAGS ('dbx_business_glossary_term' = 'Exposed Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `exposed_tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Exposed TIV Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `exposure_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exposure End Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `exposure_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exposure Start Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `flood_depth_ft` SET TAGS ('dbx_business_glossary_term' = 'Flood Depth Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `hail_size_inches` SET TAGS ('dbx_business_glossary_term' = 'Hail Size Inches');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `impact_severity_band` SET TAGS ('dbx_business_glossary_term' = 'Impact Severity Band');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `modeled_damage_percent` SET TAGS ('dbx_business_glossary_term' = 'Modeled Damage Percent');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `modeled_loss_ratio` SET TAGS ('dbx_business_glossary_term' = 'Modeled Loss Ratio');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `rainfall_inches` SET TAGS ('dbx_business_glossary_term' = 'Rainfall Inches');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `shake_intensity` SET TAGS ('dbx_business_glossary_term' = 'Shake Intensity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `storm_surge_flag` SET TAGS ('dbx_business_glossary_term' = 'Storm Surge Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `storm_surge_height_ft` SET TAGS ('dbx_business_glossary_term' = 'Storm Surge Height Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `storm_surge_height_ft` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `wind_gust_mph` SET TAGS ('dbx_business_glossary_term' = 'Wind Gust MPH');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_zone_impact` ALTER COLUMN `wind_speed_mph` SET TAGS ('dbx_business_glossary_term' = 'Wind Speed MPH');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` SET TAGS ('dbx_subdomain' = 'event_management');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` SET TAGS ('dbx_association_edges' = 'catastrophegeography.catastrophe_event,catastrophegeography.geography');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `catastrophe_event_geography_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Geography Exposure Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `catastrophe_event_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Geography Exposure - Catastrophe Event Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Event Geography Exposure - Geography Id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `aal_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Annual Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `as_of_date` SET TAGS ('dbx_business_glossary_term' = 'As Of Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `concentration_index` SET TAGS ('dbx_business_glossary_term' = 'Concentration Index');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `gwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Written Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `insured_risk_count` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `nwp_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Written Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `policy_count` SET TAGS ('dbx_business_glossary_term' = 'Policy Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event_geography_exposure` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value Amount');
