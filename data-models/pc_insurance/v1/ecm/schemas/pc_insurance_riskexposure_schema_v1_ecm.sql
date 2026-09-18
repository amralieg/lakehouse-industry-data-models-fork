-- Schema for Domain: riskexposure | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:18

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_v499`.`riskexposure` COMMENT 'Provisional description for user-specified domain risk_exposure. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` (
    `insured_location_id` BIGINT COMMENT 'Unique surrogate identifier for the insured location record. Primary key for the insured_location master resource in the riskexposure domain.',
    `country_id` BIGINT COMMENT 'Foreign key linking to shared.country. Business justification: International exposures require country-level risk assessment for sanctions screening, reinsurance domicile rules, catastrophe modeling (country-specific perils), and regulatory jurisdiction',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Every insured location must be classified by state for territorial rating, premium tax calculation, regulatory compliance (state DOI jurisdiction), and catastrophe exposure analysis.',
    `address_line1` STRING COMMENT 'Primary street address of the insured location (street number and street name). Used for risk geocoding, protection class lookup, and regulatory filings.',
    `address_line2` STRING COMMENT 'Secondary address detail for the insured location such as suite, unit, floor, or building number. Supplements address_line1 for precise premises identification.',
    `alarm_type` STRING COMMENT 'Type of burglar or fire alarm system at the insured location. Central station and direct-to-fire alarms qualify for rating credits under ISO protective device schedules.. Valid values are `none|local|central_station|direct_to_fire|direct_to_police|combination`',
    `building_value` DECIMAL(18,2) COMMENT 'Insured replacement cost or actual cash value of the building structure at this location, excluding contents and business income. Component of TIV used in property rating.',
    `business_income_value` DECIMAL(18,2) COMMENT 'Insured value for business income and extra expense coverage at this location. Represents maximum indemnity for lost revenue following a covered loss event.',
    `cat_zone` STRING COMMENT 'Insurer-defined CAT accumulation zone code for the insured location. Used for CAT XL reinsurance treaty management, PML aggregation, and exposure accumulation reporting.',
    `city` STRING COMMENT 'City or municipality in which the insured location is situated. Used for territory rating, regulatory jurisdiction assignment, and CAT zone mapping.',
    `construction_type` STRING COMMENT 'ISO construction class of the insured building per COPE framework. Drives fire and wind rating factors. Frame is highest risk; fire_resistive is lowest. [ENUM-REF-CANDIDATE: promote to reference product if additional ISO classes needed]. Valid values are `frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive`',
    `contents_value` DECIMAL(18,2) COMMENT 'Insured value of business personal property and contents at this location. Separate from building value; used for contents coverage rating and TIV accumulation.',
    `county` STRING COMMENT 'County or parish in which the insured location is situated. Used for NFIP flood zone mapping, CAT modeling, and certain state-specific rating territories.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the insured location record was first created in the system of record. Used for data lineage, audit trail, and regulatory compliance tracking.',
    `distance_to_coast_miles` DECIMAL(8,2) COMMENT 'Straight-line distance in miles from the insured location to the nearest coastline. Used for wind and storm surge rating factors and CAT accumulation management in coastal territories.',
    `distance_to_fire_station_miles` DECIMAL(6,2) COMMENT 'Distance in miles from the insured location to the nearest responding fire station. Key input to ISO Public Protection Classification (PPC) and fire rating factor determination.',
    `earthquake_zone` STRING COMMENT 'Seismic hazard zone classification (0-4) for the insured location per ISO or USGS standards. Zone 4 is highest seismic risk. Used for earthquake rating and PML modeling.. Valid values are `^[0-4]$`',
    `effective_date` DATE COMMENT 'Date on which the insured location became active and covered under the associated policy. Marks the start of the locations coverage period for premium earning and loss reporting.',
    `expiration_date` DATE COMMENT 'Date on which coverage for the insured location expires or is scheduled to end. Null for open-ended locations. Used for renewal processing and earned premium calculation.',
    `flood_zone` STRING COMMENT 'FEMA National Flood Insurance Program (NFIP) flood zone designation for the insured location (e.g., AE, X, VE). Determines flood coverage eligibility, mandatory purchase requirements, and rating.. Valid values are `^[A-Z]{1,3}[0-9]{0,2}$`',
    `geocode_quality` STRING COMMENT 'Precision level of the geocoded coordinates for the insured location. Rooftop is highest precision; zip_centroid is lowest. Affects CAT model confidence and rating accuracy.. Valid values are `rooftop|parcel|street|zip_centroid|city_centroid|manual`',
    `itv_ratio` DECIMAL(6,4) COMMENT 'Ratio of the insured building value to the estimated full replacement cost. Values below 1.0 indicate underinsurance (coinsurance exposure). Used in UW review and coinsurance penalty calculation.',
    `latitude` DECIMAL(9,6) COMMENT 'WGS-84 decimal-degree latitude of the insured location centroid. Used for CAT modeling, PML estimation, flood zone determination, and proximity-to-hazard scoring.',
    `location_code` STRING COMMENT 'Externally-known alphanumeric code assigned to the insured location, used on policy declarations pages and bordereaux submissions to identify the premises.. Valid values are `^[A-Z0-9-]{2,30}$`',
    `location_name` STRING COMMENT 'Human-readable name or description of the insured premises (e.g., Main Street Warehouse, Downtown Office). Used on declarations pages and loss reports.',
    `location_status` STRING COMMENT 'Current lifecycle state of the insured location record. Active locations are covered under a policy; inactive or expired locations are no longer in force.. Valid values are `active|inactive|pending|cancelled|expired`',
    `location_type` STRING COMMENT 'Classification of the insured premises by operational role: primary business site, secondary site, storage facility, temporary, mobile, or other. Drives rating and coverage eligibility.. Valid values are `primary|secondary|storage|temporary|mobile|other`',
    `longitude` DECIMAL(9,6) COMMENT 'WGS-84 decimal-degree longitude of the insured location centroid. Used alongside latitude for CAT modeling, PML estimation, and hazard proximity analysis.',
    `naics_code` STRING COMMENT 'Six-digit NAICS code describing the primary business activity conducted at the insured location. Used for commercial lines classification, GL rating, and regulatory statistical reporting.. Valid values are `^d{6}$`',
    `number_of_stories` BIGINT COMMENT 'Total number of above-ground floors in the primary structure at the insured location. Influences fire, wind, and earthquake rating factors and PML calculations.',
    `occupancy_type` STRING COMMENT 'ISO occupancy classification describing how the insured building is used (e.g., office, retail, manufacturing, habitational). Core COPE attribute driving underwriting and rating. [ENUM-REF-CANDIDATE: promote to reference product]',
    `postal_code` STRING COMMENT 'US ZIP or ZIP+4 postal code for the insured location. Used for territory rating, CAT zone assignment, protection class lookup, and NAIC statutory reporting.. Valid values are `^d{5}(-d{4})?$`',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification (PPC) rating from 1 (best) to 10 for the insured location. Core COPE attribute reflecting fire suppression capability; directly impacts property premium.. Valid values are `^(1[0]?|[1-9]|10W?)$`',
    `roof_material` STRING COMMENT 'Primary material used in the roof covering (e.g., asphalt shingle, metal, tile, built-up). Affects wind, hail, and fire rating factors and claim severity estimates. [ENUM-REF-CANDIDATE: promote to reference product]',
    `roof_type` STRING COMMENT 'Geometric shape or style of the roof on the primary structure. Influences wind and hail rating factors, particularly in CAT-exposed territories. [ENUM-REF-CANDIDATE: flat|gable|hip|mansard|gambrel|shed|other — 7 candidates stripped; promote to reference',
    `roof_year` BIGINT COMMENT 'Four-digit year the roof was last replaced or substantially renovated. Used for wind and hail rating credits/surcharges and underwriting eligibility decisions.',
    `sic_code` STRING COMMENT 'Four-digit SIC code for the business activity at the insured location. Legacy classification used alongside NAICS for workers compensation, GL rating, and older policy systems.. Valid values are `^d{4}$`',
    `source_system_code` STRING COMMENT 'Native identifier of the insured location record in the originating system of record (e.g., Guidewire PolicyCenter location GUID or Duck Creek location key). Enables lineage tracing.',
    `sprinkler_type` STRING COMMENT 'Type of automatic fire sprinkler system installed at the insured location. Part of COPE protection assessment; presence and type provide rating credits and reduce fire PML.. Valid values are `none|wet_pipe|dry_pipe|pre_action|deluge|partial`',
    `territory_code` STRING COMMENT 'Insurer-assigned or ISO-defined rating territory code for the insured location. Determines territory-specific rate factors for property, auto, and liability lines of business.. Valid values are `^[A-Z0-9]{2,10}$`',
    `tiv` DECIMAL(18,2) COMMENT 'Aggregate insured value across all coverages at this location including building, contents, and business income. Key metric for PML, reinsurance cession, and CAT accumulation management.',
    `total_area_sqft` DECIMAL(12,2) COMMENT 'Total gross floor area of the insured structure in square feet. Used for ITV (Insurance to Value) validation, replacement cost estimation, and premium rating.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the insured location record. Used for change tracking, incremental data loads, and audit compliance.',
    `valuation_method` STRING COMMENT 'Method used to value the insured property: Replacement Cost Value (RCV), Actual Cash Value (ACV), agreed value, or functional replacement. Determines claim settlement basis.. Valid values are `RCV|ACV|agreed_value|functional_replacement`',
    `wind_pool_eligible` BOOLEAN COMMENT 'Indicates whether the insured location is eligible for placement in a state wind pool or beach and windstorm plan due to coastal exposure. Affects market availability and pricing.',
    `year_built` BIGINT COMMENT 'Four-digit calendar year in which the primary structure at the insured location was originally constructed. Used for age-of-building rating factors and replacement cost estimation.',
    CONSTRAINT pk_insured_location PRIMARY KEY(`insured_location_id`)
) COMMENT 'Master SSOT for a physical premises or location insured under a P&C policy. Captures address, COPE attributes, occupancy, TIV, protection class, and geocode.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` (
    `scheduled_item_id` BIGINT COMMENT 'Unique surrogate identifier for each individually scheduled property item record in the P&C policy administration system.',
    `policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage line (e.g., Inland Marine, Scheduled Personal Property) under which this item is scheduled.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Scheduled personal property items can be associated with vehicles for coverage purposes (e.g., electronics, tools stored in vehicle, items stolen from vehicle). Optional FK.',
    `photo_document_id` BIGINT COMMENT 'Reference identifier to the photographic documentation of the scheduled item stored in the document management system (e.g., OpenText, FileNet) for claims and underwriting.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy under which this scheduled item is insured.',
    `actual_cash_value_amount` DECIMAL(18,2) COMMENT 'Actual cash value of the scheduled item calculated as RCV less depreciation. Used for ACV settlement basis claims and reserve adequacy assessment.',
    `agreed_value_amount` DECIMAL(18,2) COMMENT 'The agreed value (AV) of the scheduled item as established at policy inception or renewal, representing the maximum insured amount payable at total loss without depreciation.',
    `agreed_value_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the agreed value amount (e.g., USD, CAD, GBP).. Valid values are `^[A-Z]{3}$`',
    `annual_premium_amount` DECIMAL(18,2) COMMENT 'Annual written premium (WP) allocated to this scheduled item, used for premium allocation, earned premium (EP) calculation, and profitability analysis.',
    `appraisal_date` DATE COMMENT 'Date on which the most recent professional appraisal of the scheduled item was conducted. Used to assess appraisal currency and trigger re-appraisal workflows.',
    `appraisal_expiry_date` DATE COMMENT 'Date on which the current appraisal expires and a new appraisal is required to maintain agreed value coverage. Typically 2-5 years from appraisal date per carrier guidelines.',
    `appraisal_value_amount` DECIMAL(18,2) COMMENT 'Most recent professionally appraised market value of the scheduled item, used to validate agreed value adequacy and insurance-to-value (ITV) compliance.',
    `appraiser_certification_number` STRING COMMENT 'Professional certification or license number of the appraiser, used to validate appraiser credentials for underwriting and claims purposes.',
    `appraiser_name` STRING COMMENT 'Name of the certified appraiser or appraisal firm that conducted the most recent valuation of the scheduled item.',
    `blanket_group_code` STRING COMMENT 'Code identifying the blanket coverage group to which this item belongs when is_blanket_covered is True. Used to aggregate items sharing a single blanket limit.',
    `coverage_type` STRING COMMENT 'Indicates whether the item is covered under a scheduled (individual item limit), blanket (group limit), or floater (open perils, no deductible) coverage arrangement.. Valid values are `scheduled|blanket|floater`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this scheduled item record was first created in the policy administration system, used for audit trail and data lineage.',
    `effective_date` DATE COMMENT 'Date on which coverage for this scheduled item becomes effective on the policy. May differ from policy effective date if item was added mid-term via endorsement.',
    `endorsement_number` STRING COMMENT 'Reference number of the policy endorsement (ENDT) through which this scheduled item was added, modified, or removed from the policy.',
    `expiration_date` DATE COMMENT 'Date on which coverage for this scheduled item expires. Typically aligns with policy expiration but may differ for mid-term removals or endorsements.',
    `is_away_from_premises` BOOLEAN COMMENT 'Indicates whether coverage extends to the scheduled item when it is away from the insured premises (worldwide coverage). True = worldwide; False = premises only.',
    `is_blanket_covered` BOOLEAN COMMENT 'Indicates whether this item is covered under a blanket limit shared with other items rather than an individual scheduled limit. True = blanket; False = individually scheduled.',
    `iso_class_code` STRING COMMENT 'ISO/Verisk classification code assigned to the scheduled item type, used for statistical reporting, rate filings, and NAIC statutory reporting.. Valid values are `^[A-Z0-9]{2,10}$`',
    `item_category` STRING COMMENT 'High-level category classifying the type of scheduled property item for underwriting, rating, and statutory reporting. [ENUM-REF-CANDIDATE: jewelry|fine_art|camera|musical_instrument|silverware|sports_equipment|collectible|tools_equipment|other — promote',
    `item_deductible_amount` DECIMAL(18,2) COMMENT 'Per-item deductible amount applicable to this scheduled item. Many scheduled item endorsements carry a zero deductible; this field captures exceptions.',
    `item_description` STRING COMMENT 'Full narrative description of the scheduled item including make, model, material, distinguishing features, and any other underwriting-relevant details.',
    `item_name` STRING COMMENT 'Short descriptive name or title of the scheduled item as it appears on the policy schedule (e.g., Diamond Engagement Ring, Leica M11 Camera).',
    `item_number` STRING COMMENT 'Externally visible alphanumeric identifier assigned to this scheduled item on the declarations page (DEC) and endorsement schedule.. Valid values are `^[A-Z0-9-]{1,30}$`',
    `item_status` STRING COMMENT 'Current lifecycle status of the scheduled item on the policy. Drives coverage eligibility and claims adjudication.. Valid values are `active|suspended|removed|expired|pending_appraisal`',
    `item_type` STRING COMMENT 'Granular sub-type within the item category (e.g., engagement ring under jewelry, oil painting under fine art) used for detailed rating and claims adjudication.',
    `lob_code` STRING COMMENT 'NAIC or carrier-defined line of business (LOB) code under which this scheduled item is reported (e.g., Inland Marine, Homeowners, Commercial Package).',
    `location_description` STRING COMMENT 'Narrative description of the primary location where the scheduled item is kept or stored (e.g., primary residence safe, bank vault, studio). Used for risk assessment.',
    `make` STRING COMMENT 'Manufacturer or brand name of the scheduled item (e.g., Rolex, Steinway, Canon) used for valuation and claims settlement.',
    `model` STRING COMMENT 'Model name or number of the scheduled item as specified by the manufacturer, used for replacement cost valuation and claims.',
    `purchase_date` DATE COMMENT 'Date on which the insured originally purchased or acquired the scheduled item, used for depreciation calculation and ACV determination.',
    `purchase_price_amount` DECIMAL(18,2) COMMENT 'Original purchase price paid by the insured for the scheduled item, used as a baseline for valuation, ITV assessment, and claims settlement reference.',
    `rate_per_hundred` DECIMAL(10,6) COMMENT 'Insurance rate expressed as cost per $100 of agreed value, used by the rating engine to calculate the annual premium for this scheduled item.',
    `removal_date` DATE COMMENT 'Date on which the scheduled item was removed from the policy via endorsement (ENDT), triggering a pro-rata premium adjustment and coverage termination.',
    `removal_reason` STRING COMMENT 'Reason code for removal of the scheduled item from the policy. Used for underwriting analysis and portfolio management. [ENUM-REF-CANDIDATE: sold|lost|stolen|destroyed|gifted|insured_request|underwriting_decision|other — promote to reference product]',
    `replacement_cost_value_amount` DECIMAL(18,2) COMMENT 'Estimated cost to replace the scheduled item with a new item of like kind and quality at current market prices. Used for RCV settlement basis claims.',
    `serial_number` STRING COMMENT 'Manufacturer serial number or unique physical identifier of the scheduled item, used for theft recovery, subrogation, and claims verification.',
    `storage_type` STRING COMMENT 'Classification of the primary storage arrangement for the scheduled item, used for risk rating and underwriting guidelines compliance.. Valid values are `home|bank_vault|safe_deposit_box|commercial_storage|on_person|other`',
    `underwriting_notes` STRING COMMENT 'Free-text underwriting notes or conditions associated with this scheduled item, capturing special risk considerations, inspection requirements, or coverage restrictions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this scheduled item record in the policy administration system, used for change tracking and audit compliance.',
    `valuation_basis` STRING COMMENT 'The contractual basis on which the scheduled item will be valued at the time of a covered loss (e.g., agreed value, RCV, ACV, stated amount).. Valid values are `agreed_value|replacement_cost|actual_cash_value|stated_amount`',
    `year_manufactured` BIGINT COMMENT 'Four-digit year the scheduled item was manufactured or created, used for depreciation, ACV calculation, and underwriting risk assessment.',
    CONSTRAINT pk_scheduled_item PRIMARY KEY(`scheduled_item_id`)
) COMMENT 'Individually scheduled personal or commercial property items (jewelry, fine art, equipment, tools). Stores item description, agreed value, appraisal date, serial number, and blanket vs scheduled coverage flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` (
    `insured_vehicle_id` BIGINT COMMENT 'Unique identifier for the insured vehicle record. Primary key.',
    `policy_id` BIGINT COMMENT 'Reference to the auto policy under which this vehicle is insured.',
    `actual_cash_value_amount` DECIMAL(15,2) COMMENT 'Current market value of the vehicle accounting for depreciation, used for claim settlement.',
    `annual_mileage` BIGINT COMMENT 'Estimated annual miles driven, used for rating and risk assessment.',
    `anti_theft_device` STRING COMMENT 'Type of anti-theft device installed on the vehicle, may qualify for premium discount.',
    `body_type` STRING COMMENT 'Physical body style of the vehicle such as sedan, coupe, SUV, pickup, van.',
    `collision_symbol` STRING COMMENT 'Rating symbol for collision coverage based on vehicle repair costs and safety features.',
    `comp_symbol` STRING COMMENT 'Rating symbol for comprehensive coverage based on vehicle theft and damage risk.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the insured vehicle record was first created in the system.',
    `effective_date` DATE COMMENT 'Date the vehicle coverage becomes effective on the policy.',
    `expiration_date` DATE COMMENT 'Date the vehicle coverage expires or is scheduled to end.',
    `garaging_address_line1` STRING COMMENT 'Primary street address where the vehicle is principally garaged or parked overnight.',
    `garaging_address_line2` STRING COMMENT 'Secondary address line for garaging location such as apartment or unit number.',
    `garaging_city` STRING COMMENT 'City where the vehicle is principally garaged.',
    `garaging_country_code` STRING COMMENT 'Three-letter ISO country code for the garaging location.. Valid values are `^[A-Z]{3}$`',
    `garaging_county` STRING COMMENT 'County where the vehicle is garaged, used for rating and regulatory reporting.',
    `garaging_postal_code` STRING COMMENT 'ZIP code of the garaging location, critical for territory rating.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `garaging_state_code` STRING COMMENT 'Two-letter state code where the vehicle is principally garaged, used for rating and regulatory compliance.. Valid values are `^[A-Z]{2}$`',
    `is_rideshare_vehicle` BOOLEAN COMMENT 'Indicates whether the vehicle is used for rideshare services such as Uber or Lyft.',
    `is_salvage_title` BOOLEAN COMMENT 'Indicates whether the vehicle has a salvage or rebuilt title, affecting insurability and valuation.',
    `license_plate_number` STRING COMMENT 'Current license plate number registered to the vehicle.',
    `license_plate_state` STRING COMMENT 'State of registration for the license plate.. Valid values are `^[A-Z]{2}$`',
    `lienholder_address` STRING COMMENT 'Mailing address of the lienholder for loss payee and certificate purposes.',
    `lienholder_name` STRING COMMENT 'Name of the financial institution or entity holding a lien or loan on the vehicle.',
    `loan_lease_indicator` STRING COMMENT 'Indicates whether the vehicle is owned outright, financed, or leased.. Valid values are `owned|financed|leased`',
    `make` STRING COMMENT 'Manufacturer or brand name of the vehicle.',
    `model` STRING COMMENT 'Specific model name or designation of the vehicle.',
    `odometer_reading` BIGINT COMMENT 'Current mileage reading of the vehicle at the time of policy binding or renewal.',
    `purchase_date` DATE COMMENT 'Date the insured purchased or acquired the vehicle.',
    `purchase_price_amount` DECIMAL(15,2) COMMENT 'Original purchase price paid for the vehicle by the insured.',
    `removal_date` DATE COMMENT 'Date the vehicle was removed from the policy if applicable.',
    `removal_reason` STRING COMMENT 'Reason the vehicle was removed from the policy.. Valid values are `sold|totaled|replaced|transferred|other`',
    `safety_features` STRING COMMENT 'Comma-separated list of safety features such as airbags, ABS, ESC that may affect rating.',
    `stated_value_amount` DECIMAL(15,2) COMMENT 'Agreed-upon value of the vehicle for insurance purposes, typically used for classic or specialty vehicles.',
    `territory_code` STRING COMMENT 'Rating territory code assigned based on garaging location for premium calculation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the insured vehicle record was last modified.',
    `vehicle_number` STRING COMMENT 'Sequential number assigned to the vehicle within the policy for identification purposes.',
    `vehicle_status` STRING COMMENT 'Current lifecycle status of the vehicle on the policy.. Valid values are `active|suspended|deleted|pending|replaced`',
    `vehicle_symbol` STRING COMMENT 'ISO or proprietary rating symbol assigned to the vehicle based on make, model, and year for premium calculation.',
    `vehicle_type` STRING COMMENT 'High-level classification of the vehicle for policy and coverage determination.. Valid values are `private_passenger|commercial|motorcycle|trailer|recreational`',
    `vehicle_use` STRING COMMENT 'Primary use classification of the vehicle for rating and underwriting purposes.. Valid values are `pleasure|commute|business|farm|artisan`',
    `vin` STRING COMMENT '17-character unique identifier assigned to the vehicle by the manufacturer. Industry-standard vehicle identifier.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `year` BIGINT COMMENT 'Model year of the vehicle as designated by the manufacturer.',
    CONSTRAINT pk_insured_vehicle PRIMARY KEY(`insured_vehicle_id`)
) COMMENT 'Master SSOT for a motor vehicle insured under a personal or commercial auto policy. Stores VIN, year, make, model, body type, garaging address, usage, and symbol.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` (
    `insured_entity_id` BIGINT COMMENT 'Unique identifier for the insured entity record. Primary key.',
    `parent_entity_insured_entity_id` BIGINT COMMENT 'Reference to the parent insured entity if this entity is a subsidiary or division, used for account hierarchy.',
    `annual_revenue_amount` DECIMAL(18,2) COMMENT 'Reported annual gross revenue of the entity in USD, used for exposure rating and premium calculation.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the insured entity record was first created in the source system.',
    `credit_score` BIGINT COMMENT 'Commercial or personal credit score used as an underwriting factor for pricing and risk selection.',
    `dba_name` STRING COMMENT 'Trade name or fictitious business name under which the entity operates, if different from legal name.',
    `effective_date` DATE COMMENT 'Date when the insured entity record became active and eligible for policy binding.',
    `entity_number` STRING COMMENT 'Business-assigned unique identifier for the insured entity, used in policy documents and correspondence.. Valid values are `^[A-Z0-9]{8,20}$`',
    `entity_status` STRING COMMENT 'Current lifecycle status of the insured entity record within the system.. Valid values are `active|inactive|suspended|dissolved|pending`',
    `entity_type` STRING COMMENT 'Legal structure classification of the insured entity for underwriting and regulatory purposes.. Valid values are `individual|sole_proprietor|partnership|llc|corporation|non_profit`',
    `expiration_date` DATE COMMENT 'Date when the insured entity record expires or is no longer active for new policy issuance.',
    `fein` STRING COMMENT 'IRS-issued tax identification number for business entities, used for underwriting and regulatory reporting.. Valid values are `^[0-9]{2}-[0-9]{7}$`',
    `is_subsidiary` BOOLEAN COMMENT 'Indicates whether this entity is a subsidiary of another insured entity, used for account structure analysis.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when the insured entity record was last updated in the source system.',
    `legal_name` STRING COMMENT 'Full legal name of the insured entity as registered with governing authorities or as appears on official documents.',
    `loss_free_years` BIGINT COMMENT 'Number of consecutive years without a reported claim, used for experience rating and premium discounts.',
    `mailing_address_line1` STRING COMMENT 'First line of the mailing address for policy documents, billing statements, and official correspondence.',
    `mailing_address_line2` STRING COMMENT 'Second line of the mailing address for suite, unit, or additional address details.',
    `mailing_city` STRING COMMENT 'City name for the mailing address of the insured entity.',
    `mailing_country_code` STRING COMMENT 'Three-letter ISO country code for the mailing address of the insured entity.. Valid values are `^[A-Z]{3}$`',
    `mailing_postal_code` STRING COMMENT 'ZIP or postal code for the mailing address, used for correspondence delivery and territory rating.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `mailing_state_code` STRING COMMENT 'Two-letter state or province code for the mailing address, used for regulatory jurisdiction and rating.. Valid values are `^[A-Z]{2}$`',
    `naics_code` STRING COMMENT 'Six-digit code classifying the primary business activity of the entity for risk classification and rating.. Valid values are `^[0-9]{6}$`',
    `number_of_employees` BIGINT COMMENT 'Total count of full-time equivalent employees, used for workers compensation and liability rating.',
    `primary_contact_name` STRING COMMENT 'Full name of the primary contact person for the insured entity, used for policy servicing and communication.',
    `primary_contact_title` STRING COMMENT 'Job title or role of the primary contact person within the insured entity organization.',
    `primary_email` STRING COMMENT 'Primary email address for policy correspondence, billing notices, and renewal communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_phone` STRING COMMENT 'Primary telephone number for contacting the insured entity for underwriting, claims, and servicing.. Valid values are `^+?[0-9]{10,15}$`',
    `prior_carrier_name` STRING COMMENT 'Name of the previous insurance carrier, used for loss history verification and underwriting continuity.',
    `prior_expiration_date` DATE COMMENT 'Expiration date of the prior insurance policy, used to assess coverage continuity and lapse risk.',
    `prior_policy_number` STRING COMMENT 'Policy number with the prior carrier, used for loss run requests and underwriting verification.',
    `sic_code` STRING COMMENT 'Four-digit code classifying the industry sector of the entity, used for legacy rating and statistical reporting.. Valid values are `^[0-9]{4}$`',
    `ssn` STRING COMMENT 'Social Security Number for individual insured entities, used for identity verification and underwriting.. Valid values are `^[0-9]{3}-[0-9]{2}-[0-9]{4}$`',
    `uw_tier` STRING COMMENT 'Risk classification tier assigned by underwriting based on loss history, financials, and risk characteristics.. Valid values are `preferred|standard|substandard|declined`',
    `website_url` STRING COMMENT 'Official website address of the insured entity, used for underwriting research and business verification.',
    `years_in_business` BIGINT COMMENT 'Number of years the entity has been operating, used as an underwriting factor for risk assessment.',
    CONSTRAINT pk_insured_entity PRIMARY KEY(`insured_entity_id`)
) COMMENT 'Master record for a named insured party (individual, household, or commercial entity) tied to a risk exposure. Captures legal name, FEIN or SSN, NAICS/SIC code, DBA, entity type, and underwriting tier.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` (
    `risk_unit_id` BIGINT COMMENT 'Unique identifier for the risk unit. Primary key. ROLE=MASTER_RESOURCE.',
    `policy_coverage_id` BIGINT COMMENT 'Foreign key to the coverage that applies to this risk unit.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: Risk units can represent entity-level risks (e.g., WC employer risk unit, GL named insured operations). Valid FK linking risk unit to the insured entity it represents.',
    `insured_location_id` BIGINT COMMENT 'Foreign key to the insured location where this risk unit is situated.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Risk units can represent vehicle risks in auto policies. The risk_unit table has VIN and vehicle attributes, indicating it can be a vehicle risk.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Risk units must be classified by line of business for rating algorithm selection, loss reserving (LOB-specific development patterns), statutory reporting (Schedule P), reinsurance treaty',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy under which this risk unit is insured.',
    `scheduled_equipment_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_equipment. Business justification: Risk units can represent scheduled equipment in equipment floater or inland marine policies. Valid FK for equipment-level risks.',
    `scheduled_item_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_item. Business justification: Risk units can represent scheduled personal property items in inland marine or personal articles floater policies. Valid FK for item-level risks.',
    `added_date` DATE COMMENT 'Date when this risk unit was added to the policy, which may differ from the policy effective date for mid-term additions.',
    `annual_premium` DECIMAL(18,2) COMMENT 'Annual premium amount charged for this risk unit based on rated exposure and applicable rates.',
    `cat_zone` STRING COMMENT 'Catastrophe zone designation for this risk unit, indicating exposure to natural perils such as hurricane, earthquake, or flood.',
    `class_code` STRING COMMENT 'ISO or NCCI classification code identifying the type of risk or business operation for rating purposes.',
    `construction_type` STRING COMMENT 'ISO construction classification for building risk units, indicating fire resistance and structural characteristics.. Valid values are `frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk unit record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount applicable to this risk unit, representing the insured retention per occurrence.',
    `earthquake_zone` STRING COMMENT 'Seismic zone classification indicating earthquake risk exposure for the risk unit.',
    `effective_date` DATE COMMENT 'Date when coverage for this risk unit becomes effective under the policy.',
    `endorsement_number` STRING COMMENT 'Endorsement number associated with the addition, modification, or removal of this risk unit.',
    `expiration_date` DATE COMMENT 'Date when coverage for this risk unit expires or terminates under the policy.',
    `exposure_base` STRING COMMENT 'The unit of measure used to rate this risk unit, such as area, payroll, receipts, or number of vehicles.',
    `exposure_quantity` DECIMAL(18,4) COMMENT 'Numeric quantity of the exposure base used for premium rating calculations.',
    `flood_zone` STRING COMMENT 'FEMA flood zone designation indicating flood risk level for the risk unit location.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk unit record was last modified in the system.',
    `risk_unit_name` STRING COMMENT 'Human-readable name or label for the risk unit, such as building name, vehicle description, or employee class title.',
    `number` STRING COMMENT 'Business identifier for the risk unit, externally known and used in policy documents and communications.',
    `number_of_employees` BIGINT COMMENT 'Count of employees in the employee class for workers compensation risk units.',
    `occupancy_type` STRING COMMENT 'Type of occupancy or business operation conducted at the risk unit location.',
    `payroll_amount` DECIMAL(18,2) COMMENT 'Annual payroll amount for workers compensation employee class risk units, used as exposure base.',
    `pml` DECIMAL(18,2) COMMENT 'Estimated probable maximum loss for this risk unit under catastrophic event scenarios, used for reinsurance and capital planning.',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification indicating fire protection quality and proximity to fire services.',
    `rate_per_unit` DECIMAL(12,6) COMMENT 'Premium rate applied per unit of exposure for this risk unit, used in premium calculation.',
    `removal_reason` STRING COMMENT 'Business reason for removing this risk unit from coverage, such as sale, disposal, or policy cancellation.',
    `removed_date` DATE COMMENT 'Date when this risk unit was removed from the policy, applicable for mid-term deletions or cancellations.',
    `risk_unit_status` STRING COMMENT 'Current lifecycle status of the risk unit within the policy term.. Valid values are `active|inactive|suspended|deleted|pending`',
    `risk_unit_type` STRING COMMENT 'Classification of the risk unit indicating the nature of the insurable asset or exposure. [ENUM-REF-CANDIDATE: building|vehicle|employee_class|gl_operation|equipment|inventory|other — 7 candidates stripped; promote to reference product]',
    `si` DECIMAL(18,2) COMMENT 'Total sum insured or limit of liability for this risk unit, representing the maximum coverage amount.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Self-insured retention amount for this risk unit, applicable before coverage attaches.',
    `territory_code` STRING COMMENT 'Geographic rating territory code assigned to this risk unit for premium calculation purposes.',
    `tiv` DECIMAL(18,2) COMMENT 'Total insured value of the risk unit, including all covered property and business income exposures.',
    `valuation_method` STRING COMMENT 'Method used to determine the insured value: Replacement Cost Value, Actual Cash Value, Agreed Value, Market Value, or Functional Replacement.. Valid values are `rcv|acv|agreed_value|market_value|functional_replacement`',
    `wind_pool_eligible` BOOLEAN COMMENT 'Indicates whether the risk unit is eligible for state wind pool or coastal insurance programs.',
    `year_built` BIGINT COMMENT 'Year the building or structure was originally constructed, used for age-based rating adjustments.',
    CONSTRAINT pk_risk_unit PRIMARY KEY(`risk_unit_id`)
) COMMENT 'Atomic unit of insurable risk on a policy (building, vehicle, employee class, or GL operation). Single SSOT for rated exposure quantity, SI, TIV, exposure base, payroll, and LOB risk characteristics. Anchors the policy-coverage-exposure FK lineage.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` (
    `cat_zone_id` BIGINT COMMENT 'Unique identifier for the catastrophe zone record.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: CAT zones are state-specific regulatory constructs (wind pools, earthquake authorities, FAIR plans).',
    `base_flood_elevation_ft` DECIMAL(8,2) COMMENT 'Base flood elevation in feet above sea level for 100-year flood event, used for NFIP compliance.',
    `cat_loading_factor` DECIMAL(8,5) COMMENT 'Catastrophe loading factor applied to premium rates for exposures in this zone, expressed as decimal.',
    `cat_model_vendor` STRING COMMENT 'Name of catastrophe modeling vendor whose model was used to define this zone.',
    `cat_model_version` STRING COMMENT 'Version identifier of the catastrophe model used to define loss characteristics for this zone.',
    `county_fips_code` STRING COMMENT 'Five-digit FIPS code identifying the county for this catastrophe zone.. Valid values are `^[0-9]{5}$`',
    `distance_to_coast_miles` DECIMAL(8,2) COMMENT 'Distance in miles from this zone centroid to nearest coastline, relevant for hurricane and storm surge risk.',
    `earthquake_magnitude_scale` DECIMAL(3,1) COMMENT 'Expected earthquake magnitude on Richter scale for seismic zones, used for exposure assessment.',
    `effective_date` DATE COMMENT 'Date when this catastrophe zone definition became effective for underwriting and rating purposes.',
    `expiration_date` DATE COMMENT 'Date when this catastrophe zone definition expires or is superseded by a new version.',
    `fema_flood_zone_code` STRING COMMENT 'FEMA flood zone designation code indicating flood risk level for this zone.. Valid values are `^[A-Z]{1,3}[0-9]{0,2}$`',
    `firm_effective_date` DATE COMMENT 'Date when the current FIRM panel became effective for this zone.',
    `firm_panel_number` STRING COMMENT 'FEMA FIRM panel number identifying the official flood map for this zone.. Valid values are `^[0-9]{10}[A-Z]{1}$`',
    `geography_type` STRING COMMENT 'Type of geographic boundary used to define this catastrophe zone.. Valid values are `county|zip|census_tract|grid_cell|custom_polygon`',
    `hurricane_wind_speed_mph` BIGINT COMMENT 'Design wind speed in miles per hour for hurricane peril zones, used for rating and building code compliance.',
    `iso_crpc_code` STRING COMMENT 'ISO CRPC code indicating fire protection class for commercial properties in this zone.. Valid values are `^[0-9]{5}$`',
    `last_updated_date` DATE COMMENT 'Date when this catastrophe zone record was last updated in the system.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the catastrophe zone centroid in decimal degrees.',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the catastrophe zone centroid in decimal degrees.',
    `mandatory_flood_purchase_indicator` BOOLEAN COMMENT 'Indicates whether flood insurance is federally mandated for mortgaged properties in this zone.',
    `nfip_community_code` STRING COMMENT 'Six-digit NFIP community identifier for jurisdictions participating in the flood insurance program.. Valid values are `^[0-9]{6}$`',
    `nfip_participation_status` STRING COMMENT 'Current NFIP participation status of the community where this zone is located.. Valid values are `participating|non_participating|suspended|probation`',
    `peril_type` STRING COMMENT 'Type of catastrophe peril this zone represents: hurricane, earthquake, flood, wildfire, hail, or tornado.. Valid values are `hurricane|earthquake|flood|wildfire|hail|tornado`',
    `pml_amount` DECIMAL(18,2) COMMENT 'Estimated probable maximum loss amount in USD for a catastrophic event in this zone.',
    `pml_tier` STRING COMMENT 'PML tier classification indicating relative catastrophe loss exposure severity for this zone.. Valid values are `tier_1|tier_2|tier_3|tier_4|tier_5`',
    `return_period_years` BIGINT COMMENT 'Statistical return period in years for the catastrophe event scenario modeled for this zone.',
    `territory_code` STRING COMMENT 'Rating territory code assigned to this catastrophe zone for premium calculation purposes.. Valid values are `^[A-Z0-9]{2,10}$`',
    `wildfire_hazard_severity` STRING COMMENT 'Wildfire hazard severity classification for this zone based on fuel load, topography, and climate.. Valid values are `very_high|high|moderate|low`',
    `wind_pool_eligible` BOOLEAN COMMENT 'Indicates whether properties in this zone are eligible for state wind pool or residual market coverage.',
    `zip_code` STRING COMMENT 'Five-digit postal ZIP code associated with this catastrophe zone, if applicable.. Valid values are `^[0-9]{5}$`',
    `zone_code` STRING COMMENT 'Business identifier code for the catastrophe zone, typically assigned by rating bureau or insurer.. Valid values are `^[A-Z0-9]{3,20}$`',
    `zone_name` STRING COMMENT 'Descriptive name of the catastrophe zone for business reference and reporting.',
    `zone_status` STRING COMMENT 'Current lifecycle status of the catastrophe zone definition.. Valid values are `active|inactive|pending|deprecated`',
    CONSTRAINT pk_cat_zone PRIMARY KEY(`cat_zone_id`)
) COMMENT 'Reference for catastrophe peril zones (hurricane, quake, flood, wildfire, hail) mapped to geography. Stores PML tier, CAT loading, FEMA/NFIP flood zone code, BFE, FIRM panel, and mandatory-purchase indicator for flood compliance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` (
    `risk_characteristic_id` BIGINT COMMENT 'Unique identifier for the risk characteristic record. Primary key.',
    `insured_location_id` BIGINT COMMENT 'Identifier of the insured location when the characteristic applies to a property location.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Risk characteristics can apply to vehicles (e.g., anti-theft device type, safety features, usage patterns). Valid optional FK for vehicle-specific underwriting factors.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Risk characteristics are LOB-specific rating variables (construction type for property, vehicle use for auto, payroll for WC).',
    `policy_id` BIGINT COMMENT 'Identifier of the policy to which this risk characteristic applies.',
    `risk_unit_id` BIGINT COMMENT 'Identifier of the specific risk unit (location, vehicle, driver, equipment) being characterized.',
    `scheduled_equipment_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_equipment. Business justification: Risk characteristics can apply to scheduled equipment (e.g., maintenance status, safety certifications, usage intensity).',
    `scheduled_item_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_item. Business justification: Risk characteristics can apply to scheduled items (e.g., appraisal status, security features for jewelry, storage conditions).',
    `boolean_value` BOOLEAN COMMENT 'Boolean representation of the characteristic value when data type is boolean (e.g., true for sprinkler_present, false for prior_claims).',
    `change_reason` STRING COMMENT 'Reason for the characteristic value change (e.g., endorsement, renewal, inspection update, correction).',
    `characteristic_category` STRING COMMENT 'High-level category grouping the characteristic (e.g., property, liability, auto, workers_comp, driver, equipment). [ENUM-REF-CANDIDATE: property|liability|auto|workers_comp|equipment|driver|occupancy|construction|protection|exposure — 10 candidates',
    `characteristic_code` STRING COMMENT 'Standardized code for the characteristic, used for rating and underwriting rules (e.g., ROOF_AGE, ALARM_TYP, DRV_AGE).. Valid values are `^[A-Z0-9_]{2,20}$`',
    `characteristic_data_type` STRING COMMENT 'Data type of the characteristic value (string, numeric, boolean, date, enumeration) to support proper rating and validation.. Valid values are `string|numeric|boolean|date|enumeration`',
    `characteristic_name` STRING COMMENT 'Name of the underwriting characteristic being captured (e.g., roof_age, alarm_type, driver_age, years_in_business, sprinkler_system).',
    `characteristic_value` DECIMAL(18,2) COMMENT 'The actual value of the characteristic as captured during underwriting (e.g., 15 for roof age, Central Station for alarm type, 42 for driver age).',
    `created_by_user` STRING COMMENT 'User ID or name of the person who created this characteristic record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk characteristic record was first created in the system.',
    `date_value` DATE COMMENT 'Date representation of the characteristic value when data type is date (e.g., roof installation date, driver license issue date).',
    `effective_date` DATE COMMENT 'Date from which this characteristic value is effective for the risk unit and policy.',
    `endorsement_number` STRING COMMENT 'Endorsement number associated with the addition or change of this characteristic value.',
    `expiration_date` DATE COMMENT 'Date on which this characteristic value expires or is superseded by a new value.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this characteristic is mandatory for policy binding and issuance in the applicable line of business.',
    `is_rating_variable` BOOLEAN COMMENT 'Indicates whether this characteristic is used as a variable in premium rating calculations.',
    `is_underwriting_factor` BOOLEAN COMMENT 'Indicates whether this characteristic is used in underwriting risk selection and eligibility decisions.',
    `iso_class_code` STRING COMMENT 'ISO classification code associated with this characteristic for standardized rating and underwriting.. Valid values are `^[A-Z0-9]{4,10}$`',
    `naics_code` STRING COMMENT 'NAICS code associated with the business or occupancy characteristic for industry classification.. Valid values are `^[0-9]{6}$`',
    `ncci_class_code` STRING COMMENT 'NCCI class code for workers compensation characteristics (e.g., job classification, payroll exposure).. Valid values are `^[0-9]{4,5}$`',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the characteristic value, its source, or underwriting considerations.',
    `numeric_value` DECIMAL(18,4) COMMENT 'Numeric representation of the characteristic value when data type is numeric (e.g., 15.0 for roof age, 42.0 for driver age, 25000.0 for payroll).',
    `rating_impact_factor` DECIMAL(10,6) COMMENT 'Multiplicative factor or credit/debit applied to premium rating based on this characteristic value (e.g., 0.95 for alarm discount, 1.20 for high-risk occupancy).',
    `sic_code` STRING COMMENT 'SIC code associated with the business or occupancy characteristic for legacy industry classification.. Valid values are `^[0-9]{4}$`',
    `source_document_type` STRING COMMENT 'Type of document or data source from which the characteristic was obtained (e.g., application, inspection_report, MVR, CLUE, third_party_data).',
    `territory_code` STRING COMMENT 'Rating territory code associated with this characteristic for geographic rating segmentation.. Valid values are `^[A-Z0-9]{1,10}$`',
    `underwriting_tier` STRING COMMENT 'Underwriting tier classification driven by this characteristic (preferred, standard, substandard, declined).. Valid values are `preferred|standard|substandard|declined`',
    `unit_of_measure` STRING COMMENT 'Unit of measure for numeric characteristics (e.g., years, miles, square_feet, dollars, employees, vehicles).',
    `updated_by_user` STRING COMMENT 'User ID or name of the person who last updated this characteristic record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk characteristic record was last updated.',
    `verification_date` DATE COMMENT 'Date on which the characteristic value was verified or last validated.',
    `verification_status` STRING COMMENT 'Status indicating whether the characteristic value has been verified through inspection, third-party data, or other means.. Valid values are `verified|unverified|pending_verification|rejected`',
    `verified_by` STRING COMMENT 'Name or identifier of the person, system, or third-party service that verified the characteristic value.',
    CONSTRAINT pk_risk_characteristic PRIMARY KEY(`risk_characteristic_id`)
) COMMENT 'Stores LOB-specific underwriting characteristics for a risk unit (e.g., roof age, alarm type, sprinkler system, driver age, MVR points, years in business). Each row is one characteristic name-value pair per risk unit.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` (
    `exposure_period_id` BIGINT COMMENT 'Unique identifier for the exposure period record.',
    `exposure_id` BIGINT COMMENT 'Reference to the specific coverage within the policy for this exposure period.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: Exposure periods can track entity-level exposure (e.g., WC employer exposure, GL named insured exposure). Valid optional FK for entity exposure tracking.',
    `insured_location_id` BIGINT COMMENT 'Reference to the insured location associated with this exposure period.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Exposure periods can track vehicle-specific exposure in auto policies (e.g., vehicle added/removed mid-term). Valid optional FK for vehicle exposure tracking.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Exposure periods drive earned premium calculation by LOB for statutory reporting (Annual Statement Schedule P), loss ratio analysis, and reinsurance premium allocation.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this exposure period exists.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Exposure periods track the time ranges during which risk units are on-risk within a policy term. Core missing relationship linking exposure tracking to the specific risk unit.',
    `scheduled_item_id` BIGINT COMMENT 'Reference to a scheduled item if this exposure period applies to a specifically scheduled asset.',
    `cancellation_date` DATE COMMENT 'Date when the exposure period was cancelled, if applicable.',
    `cancellation_reason_code` STRING COMMENT 'Standardized code indicating the reason for cancellation.',
    `cat_zone` STRING COMMENT 'Catastrophe zone classification for this exposure period.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this exposure period record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this exposure period.. Valid values are `^[A-Z]{3}$`',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount applicable to claims during this exposure period.',
    `earned_days` BIGINT COMMENT 'Number of days earned as of the calculation date within the exposure period.',
    `earned_exposure_units` DECIMAL(18,4) COMMENT 'Exposure units earned as of the calculation date, prorated over the exposure period.',
    `earned_premium_amount` DECIMAL(18,2) COMMENT 'Premium earned as of the calculation date for this exposure period.',
    `effective_date` DATE COMMENT 'Date when the exposure period begins and risk coverage starts.',
    `endorsement_effective_date` DATE COMMENT 'Effective date of the endorsement that created or modified this exposure period.',
    `endorsement_number` STRING COMMENT 'Endorsement number if this exposure period was created or modified by an endorsement.',
    `expiration_date` DATE COMMENT 'Date when the exposure period ends and risk coverage terminates.',
    `exposure_basis` STRING COMMENT 'The unit of measure used to calculate exposure for rating purposes. [ENUM-REF-CANDIDATE: area|units|payroll|sales|vehicles|employees|receipts — 7 candidates stripped; promote to reference product]',
    `exposure_days` BIGINT COMMENT 'Total number of calendar days in the exposure period.',
    `exposure_status` STRING COMMENT 'Current lifecycle status of the exposure period.. Valid values are `active|expired|cancelled|suspended|reinstated`',
    `exposure_units` DECIMAL(18,4) COMMENT 'Quantity of exposure units on risk during this period, used for premium calculation.',
    `is_cat_exposed` BOOLEAN COMMENT 'Indicates whether this exposure period is subject to catastrophe risk.',
    `limit_amount` DECIMAL(18,2) COMMENT 'Maximum coverage limit applicable during this exposure period.',
    `number` STRING COMMENT 'Business identifier for the exposure period, typically sequenced within a policy term.',
    `pml_amount` DECIMAL(18,2) COMMENT 'Estimated probable maximum loss for this exposure period under catastrophe scenarios.',
    `premium_amount` DECIMAL(18,2) COMMENT 'Total premium charged for this exposure period.',
    `pro_rata_factor` DECIMAL(8,6) COMMENT 'Pro-rata calculation factor used for mid-term adjustments and earned premium calculations.',
    `rate_per_unit` DECIMAL(12,6) COMMENT 'Premium rate applied per exposure unit for this period.',
    `reinstatement_date` DATE COMMENT 'Date when a previously cancelled exposure period was reinstated.',
    `sir_amount` DECIMAL(18,2) COMMENT 'Self-insured retention amount the insured must pay before coverage applies.',
    `territory_code` STRING COMMENT 'Geographic rating territory code applicable to this exposure period.',
    `tiv` DECIMAL(18,2) COMMENT 'Total insured value at risk during this exposure period.',
    `transaction_type` STRING COMMENT 'Type of policy transaction that created or modified this exposure period.. Valid values are `new_business|renewal|endorsement|cancellation|reinstatement`',
    `unearned_exposure_units` DECIMAL(18,4) COMMENT 'Exposure units remaining unearned as of the calculation date.',
    `unearned_premium_amount` DECIMAL(18,2) COMMENT 'Premium remaining unearned as of the calculation date.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this exposure period record was last modified.',
    `written_exposure_units` DECIMAL(18,4) COMMENT 'Total exposure units written at policy inception or endorsement effective date.',
    `written_premium_amount` DECIMAL(18,2) COMMENT 'Premium written at the start of this exposure period.',
    CONSTRAINT pk_exposure_period PRIMARY KEY(`exposure_period_id`)
) COMMENT 'Tracks the effective date range during which a risk unit is on-risk within a policy term. Captures written exposure, earned exposure, and mid-term changes due to endorsements, cancellations, or reinstatements.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` (
    `uw_survey_id` BIGINT COMMENT 'Unique identifier for the underwriting survey record.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: Underwriting surveys often result from prior claims or are referenced during claim investigation for pre-loss condition documentation, subrogation support, and coverage dispute resolution.',
    `insured_location_id` BIGINT COMMENT 'Reference to the specific insured location surveyed.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Underwriting surveys can be conducted on vehicles, especially for commercial fleets or high-value personal auto. Valid optional FK for vehicle inspections.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this survey was conducted.',
    `report_document_id` BIGINT COMMENT 'Reference identifier for the formal survey report document stored in the document management system.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Underwriting surveys are conducted on risk units (buildings, operations, fleets). This is a core missing relationship linking surveys to the specific risk unit inspected.',
    `completed_date` DATE COMMENT 'Date when the survey was finalized and all findings documented.',
    `conditions_imposed` STRING COMMENT 'Specific conditions, endorsements, or requirements imposed on the policy as a result of survey findings.',
    `cope_construction` STRING COMMENT 'Construction type observed during survey, part of COPE assessment: frame, joisted masonry, non-combustible, masonry non-combustible, modified fire resistive, or fire resistive.',
    `cope_exposure` STRING COMMENT 'External exposure factors observed during survey, part of COPE assessment: proximity to other buildings, wildfire risk, flood risk, earthquake risk.',
    `cope_occupancy` STRING COMMENT 'Occupancy type observed during survey, part of COPE assessment, describing how the building is used.',
    `cope_protection` STRING COMMENT 'Fire protection features observed during survey, part of COPE assessment: sprinklers, alarms, fire department proximity, water supply adequacy.',
    `cost_amount` DECIMAL(15,2) COMMENT 'Total cost incurred for conducting the survey, including inspector fees, travel, and third-party vendor charges.',
    `cost_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the survey cost amount.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the survey record was first created in the system.',
    `duration_minutes` BIGINT COMMENT 'Total time spent conducting the survey, measured in minutes.',
    `findings_summary` STRING COMMENT 'High-level summary of key observations, hazards, and risk characteristics identified during the survey.',
    `follow_up_date` DATE COMMENT 'Scheduled date for follow-up survey or inspection to verify compliance with recommendations.',
    `follow_up_required_flag` BOOLEAN COMMENT 'Indicates whether a follow-up survey or inspection is required to verify improvements or reassess risk.',
    `hazards_identified` STRING COMMENT 'Detailed list of specific hazards, deficiencies, or risk factors observed during the inspection.',
    `improvement_deadline_date` DATE COMMENT 'Date by which recommended improvements must be completed to maintain coverage or favorable terms.',
    `inspector_code` STRING COMMENT 'Unique identifier for the inspector or surveyor who performed the inspection.',
    `inspector_company` STRING COMMENT 'Name of the company or organization employing the inspector, relevant for third-party surveys.',
    `inspector_name` STRING COMMENT 'Full name of the individual who conducted the field survey or inspection.',
    `notes` STRING COMMENT 'Additional comments, observations, or context relevant to the survey that do not fit in other structured fields.',
    `photos_taken_count` BIGINT COMMENT 'Number of photographs captured during the survey for documentation purposes.',
    `premium_impact_amount` DECIMAL(15,2) COMMENT 'Estimated change in premium resulting from survey findings, expressed as a positive or negative dollar amount.',
    `premium_impact_percentage` DECIMAL(5,2) COMMENT 'Estimated percentage change in premium resulting from survey findings, expressed as a positive or negative percentage.',
    `recommended_improvements` STRING COMMENT 'Specific actions or modifications recommended to reduce risk exposure and improve insurability.',
    `report_url` STRING COMMENT 'Web link or file path to access the complete survey report document.',
    `review_date` DATE COMMENT 'Date when the underwriter reviewed the survey findings and made the underwriting decision.',
    `risk_grade` STRING COMMENT 'Qualitative risk grade assigned to the surveyed location: excellent, good, fair, poor, or unacceptable.. Valid values are `excellent|good|fair|poor|unacceptable`',
    `risk_score` DECIMAL(5,2) COMMENT 'Quantitative risk assessment score assigned based on survey findings, typically on a scale of 0-100.',
    `scheduled_date` DATE COMMENT 'Date when the survey was originally scheduled to occur.',
    `survey_date` DATE COMMENT 'Date when the field survey or inspection was conducted.',
    `survey_method` STRING COMMENT 'Method used to conduct the survey: on-site visit, remote assessment, desktop review, hybrid approach, aerial imagery, or drone inspection.. Valid values are `on_site|remote|desktop|hybrid|aerial|drone`',
    `survey_number` STRING COMMENT 'Business identifier for the survey, often used in external communications and documentation.',
    `survey_source` STRING COMMENT 'Origin of the survey: internal staff, ISO, third-party vendor, broker, agent, or reinsurer.. Valid values are `internal|iso|third_party|broker|agent|reinsurer`',
    `survey_status` STRING COMMENT 'Current lifecycle status of the survey: scheduled, in progress, completed, cancelled, pending review, or approved.. Valid values are `scheduled|in_progress|completed|cancelled|pending_review|approved`',
    `survey_time` TIMESTAMP COMMENT 'Precise date and time when the survey began, used for scheduling and audit purposes.',
    `survey_type` STRING COMMENT 'Classification of the survey purpose: new business evaluation, renewal inspection, mid-term review, loss control, risk improvement, catastrophe assessment, or special inspection.',
    `underwriter_code` STRING COMMENT 'Unique identifier for the underwriter who reviewed and acted on the survey findings.',
    `underwriter_name` STRING COMMENT 'Name of the underwriter who reviewed the survey and made the underwriting decision.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the survey record was last modified in the system.',
    `uw_action` STRING COMMENT 'Underwriting decision resulting from the survey: accept, decline, refer to senior underwriter, conditional acceptance, or request for re-survey.. Valid values are `accept|decline|refer|conditional_accept|request_resuervey`',
    `uw_action_reason` STRING COMMENT 'Detailed explanation of the rationale behind the underwriting action decision.',
    CONSTRAINT pk_uw_survey PRIMARY KEY(`uw_survey_id`)
) COMMENT 'Underwriting field survey or inspection record for a risk unit. Captures survey date, inspector, findings, recommended improvements, UW action (accept, decline, refer), and survey source (internal, ISO, third-party).';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` (
    `mvr_report_id` BIGINT COMMENT 'Unique identifier for the motor vehicle report record.',
    `insured_entity_id` BIGINT COMMENT 'Reference to the driver risk unit for whom this MVR was obtained.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: MVR reports can be associated with specific vehicles the driver operates (especially for commercial auto with driver-vehicle assignments). Valid optional FK.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this MVR was pulled.',
    `accident_count` BIGINT COMMENT 'Total number of accidents reported on the MVR within the lookback period.',
    `at_fault_accident_count` BIGINT COMMENT 'Number of accidents where the driver was determined to be at fault.',
    `cost_amount` DECIMAL(10,2) COMMENT 'Cost charged by the provider for obtaining the MVR report.',
    `cost_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the MVR cost amount.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the MVR report record was first created in the system.',
    `dui_count` BIGINT COMMENT 'Number of DUI or DWI convictions reported on the MVR.',
    `expiration_date` DATE COMMENT 'Date after which the MVR report is considered stale and must be refreshed for underwriting purposes.',
    `is_acceptable_for_underwriting` BOOLEAN COMMENT 'Indicates whether the MVR results meet underwriting acceptability criteria for policy issuance.',
    `license_class` STRING COMMENT 'License class or type indicating vehicle categories the driver is authorized to operate.',
    `license_expiration_date` DATE COMMENT 'Date when the driver license expires.',
    `license_issue_date` DATE COMMENT 'Date when the current driver license was issued.',
    `license_number` STRING COMMENT 'Driver license number as reported on the MVR.',
    `license_state` STRING COMMENT 'Two-letter state code of the jurisdiction that issued the driver license.. Valid values are `^[A-Z]{2}$`',
    `license_status` STRING COMMENT 'Current status of the driver license as reported on the MVR.. Valid values are `valid|suspended|revoked|expired|restricted`',
    `lookback_period_years` BIGINT COMMENT 'Number of years of driving history included in the MVR report.',
    `major_violation_count` BIGINT COMMENT 'Number of major violations such as DUI, reckless driving, or hit-and-run reported on the MVR.',
    `minor_violation_count` BIGINT COMMENT 'Number of minor violations such as speeding or failure to signal reported on the MVR.',
    `mvr_score` BIGINT COMMENT 'Composite risk score calculated by the MVR provider based on driving history.',
    `mvr_tier` STRING COMMENT 'Underwriting tier assignment based on MVR score and driving history.. Valid values are `preferred|standard|substandard|declined`',
    `not_at_fault_accident_count` BIGINT COMMENT 'Number of accidents where the driver was not determined to be at fault.',
    `order_date` DATE COMMENT 'Date when the MVR report was requested from the provider.',
    `ordered_by_user_code` STRING COMMENT 'User identifier of the underwriter or system user who ordered the MVR report.',
    `provider_name` STRING COMMENT 'Name of the third-party vendor or state agency that supplied the MVR report.',
    `received_date` DATE COMMENT 'Date when the MVR report was received from the provider.',
    `rejection_reason` STRING COMMENT 'Reason code or description if the MVR results led to policy declination or driver exclusion.',
    `report_date` DATE COMMENT 'Date as of which the MVR data was compiled by the provider.',
    `report_number` STRING COMMENT 'External report number or reference identifier assigned by the MVR provider.',
    `report_status` STRING COMMENT 'Current status of the MVR report in the underwriting workflow.. Valid values are `ordered|received|pending|error|expired`',
    `report_type` STRING COMMENT 'Type or level of detail of the MVR report obtained.. Valid values are `standard|comprehensive|instant|certified`',
    `suspension_count` BIGINT COMMENT 'Number of license suspensions reported on the MVR within the lookback period.',
    `underwriter_notes` STRING COMMENT 'Free-text notes entered by the underwriter regarding MVR findings and risk assessment.',
    `underwriter_review_required` BOOLEAN COMMENT 'Indicates whether the MVR results require manual underwriter review before policy issuance.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the MVR report record was last updated in the system.',
    `violation_count` BIGINT COMMENT 'Total number of moving violations reported on the MVR within the lookback period.',
    CONSTRAINT pk_mvr_report PRIMARY KEY(`mvr_report_id`)
) COMMENT 'Motor Vehicle Report obtained for a driver risk unit. Stores pull date, license state, license number, violation count, accident count, MVR score, and source (CLUE Auto / state DMV). Used in personal and commercial auto UW.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` (
    `clue_report_id` BIGINT COMMENT 'Unique identifier for the CLUE report record.',
    `claim_id` BIGINT COMMENT 'Foreign key linking to claims.claim. Business justification: CLUE reports are ordered during claim investigation to validate loss history, detect fraud, verify prior losses, and support coverage investigation.',
    `insured_entity_id` BIGINT COMMENT 'Reference to the party (person or organization) for whom the CLUE report was requested.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: CLUE property loss history reports are tied to specific insured locations. Formalizes the relationship and allows removal of redundant address fields (authoritative in',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: CLUE auto loss history reports are tied to specific vehicles. VIN is already captured in clue_report but is authoritative in insured_vehicle. FK formalizes the relationship.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this CLUE report was ordered.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: CLUE reports can be associated with specific risk units (e.g., a building risk unit for property CLUE, a vehicle risk unit for auto CLUE).',
    `adverse_action_required` BOOLEAN COMMENT 'Indicates whether an adverse action notice is required based on CLUE report usage.',
    `adverse_action_sent_date` DATE COMMENT 'Date when the adverse action notice was sent to the applicant.',
    `auto_loss_count` BIGINT COMMENT 'Number of auto-related losses reported in the CLUE report.',
    `catastrophe_loss_indicator` BOOLEAN COMMENT 'Indicates whether any of the reported losses were catastrophe-related events.',
    `clue_score` BIGINT COMMENT 'Numeric risk score assigned by the CLUE system based on prior loss history.',
    `clue_score_tier` STRING COMMENT 'Categorical tier classification of the CLUE score for underwriting decisioning.. Valid values are `excellent|good|average|below_average|poor`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this CLUE report record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in the report.. Valid values are `^[A-Z]{3}$`',
    `expiration_date` DATE COMMENT 'Date when the CLUE report expires and is no longer valid for underwriting decisions.',
    `fraud_indicator` BOOLEAN COMMENT 'Indicates whether any of the reported losses have fraud flags or suspicions.',
    `lookback_period_years` BIGINT COMMENT 'Number of years of loss history included in the CLUE report.',
    `order_date` DATE COMMENT 'Date when the CLUE report was ordered from the provider.',
    `prior_carrier_naic_code` STRING COMMENT 'Five-digit NAIC code identifying the prior insurance carrier.. Valid values are `^[0-9]{5}$`',
    `prior_carrier_name` STRING COMMENT 'Name of the most recent prior insurance carrier reported in the CLUE report.',
    `prior_policy_effective_date` DATE COMMENT 'Effective date of the most recent prior policy reported in the CLUE report.',
    `prior_policy_expiration_date` DATE COMMENT 'Expiration date of the most recent prior policy reported in the CLUE report.',
    `prior_policy_number` STRING COMMENT 'Policy number from the most recent prior carrier reported in the CLUE report.',
    `property_loss_count` BIGINT COMMENT 'Number of property-related losses reported in the CLUE report.',
    `provider_name` STRING COMMENT 'Name of the CLUE report provider (typically ISO/Verisk or LexisNexis).',
    `provider_transaction_code` STRING COMMENT 'Unique transaction identifier assigned by the CLUE report provider.',
    `received_date` DATE COMMENT 'Date when the CLUE report was received from the provider.',
    `report_cost_amount` DECIMAL(10,2) COMMENT 'Cost charged by the provider for the CLUE report.',
    `report_date` DATE COMMENT 'Date when the CLUE report was generated by the provider.',
    `report_number` STRING COMMENT 'Unique report number assigned by the CLUE database provider.',
    `report_status` STRING COMMENT 'Current status of the CLUE report in the underwriting workflow.. Valid values are `ordered|received|reviewed|expired|error`',
    `report_type` STRING COMMENT 'Type of CLUE report indicating whether it covers property losses, auto losses, or both.. Valid values are `property|auto|combined`',
    `total_incurred_amount` DECIMAL(15,2) COMMENT 'Total incurred loss amount across all prior losses reported in the CLUE report.',
    `total_loss_count` BIGINT COMMENT 'Total number of prior losses reported in the CLUE report.',
    `underwriter_notes` STRING COMMENT 'Free-text notes entered by the underwriter regarding the CLUE report findings.',
    `underwriter_review_required` BOOLEAN COMMENT 'Indicates whether the CLUE report findings require manual underwriter review.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this CLUE report record was last updated in the system.',
    `uw_decision` STRING COMMENT 'Underwriting decision made based on the CLUE report findings.. Valid values are `approved|declined|referred|pending`',
    `uw_decision_date` DATE COMMENT 'Date when the underwriting decision was made based on the CLUE report.',
    `uw_decision_reason` STRING COMMENT 'Reason code or description for the underwriting decision based on CLUE findings.',
    CONSTRAINT pk_clue_report PRIMARY KEY(`clue_report_id`)
) COMMENT 'Comprehensive Loss Underwriting Exchange (CLUE) property or auto loss history report for an insured entity or vehicle. Captures report date, prior carrier, prior losses, and CLUE score used in UW risk selection.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` (
    `tiv_schedule_id` BIGINT COMMENT 'Unique identifier for the TIV schedule item record.',
    `insured_location_id` BIGINT COMMENT 'Reference to the physical location where the scheduled item is situated.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this scheduled item is insured.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: TIV schedule line items represent individual risk units (buildings, contents, BI) within a commercial property schedule. Valid FK linking TIV item to its risk unit.',
    `actual_cash_value_amount` DECIMAL(18,2) COMMENT 'The replacement cost value minus depreciation, representing the current market value of the item.',
    `agreed_value_amount` DECIMAL(18,2) COMMENT 'Pre-agreed valuation amount between insurer and insured, eliminating coinsurance penalties and valuation disputes at claim time.',
    `annual_premium_amount` DECIMAL(18,2) COMMENT 'The annual premium charged for coverage of this scheduled item.',
    `appraisal_date` DATE COMMENT 'The date on which the professional appraisal was conducted.',
    `appraisal_expiry_date` DATE COMMENT 'The date after which the appraisal is no longer considered valid and a new appraisal is required.',
    `appraisal_value_amount` DECIMAL(18,2) COMMENT 'The value determined by a professional appraiser for this scheduled item, often required for high-value property.',
    `appraiser_certification_number` STRING COMMENT 'The professional certification or license number of the appraiser who performed the valuation.',
    `appraiser_name` STRING COMMENT 'The name of the professional appraiser or appraisal firm that conducted the valuation.',
    `blanket_group_code` STRING COMMENT 'Identifier for a blanket coverage group when this item is covered under a blanket limit rather than a specific limit.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'The percentage of value that must be insured to avoid a coinsurance penalty at claim time, typically 80%, 90%, or 100%.',
    `construction_type` STRING COMMENT 'The construction classification of the building or structure housing the item, relevant for rating and exposure assessment.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this TIV schedule record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'The deductible amount applicable to this scheduled item, representing the insured retention before coverage applies.',
    `deductible_type` STRING COMMENT 'The structure of the deductible, whether a flat dollar amount, percentage of loss, or franchise deductible.. Valid values are `flat|percentage|franchise`',
    `depreciation_amount` DECIMAL(18,2) COMMENT 'The calculated depreciation deducted from replacement cost to arrive at actual cash value.',
    `depreciation_basis` STRING COMMENT 'The methodology used to calculate depreciation for this scheduled item.. Valid values are `straight_line|declining_balance|units_of_production|market_based`',
    `effective_date` DATE COMMENT 'The date from which coverage for this scheduled item becomes active on the policy.',
    `endorsement_number` STRING COMMENT 'The policy endorsement number that added or modified this scheduled item on the policy.',
    `expiration_date` DATE COMMENT 'The date on which coverage for this scheduled item ceases unless renewed or extended.',
    `insurance_to_value_ratio` DECIMAL(5,4) COMMENT 'The ratio of sum insured to replacement cost value, indicating adequacy of coverage and potential coinsurance exposure.',
    `is_blanket_covered` BOOLEAN COMMENT 'Indicates whether this item is covered under a blanket limit that applies to multiple items or locations.',
    `iso_class_code` STRING COMMENT 'The ISO classification code used for rating and underwriting this type of scheduled property.',
    `item_category` STRING COMMENT 'High-level classification of the scheduled item type for coverage and rating purposes.. Valid values are `building|contents|equipment|business_income|extra_expense|improvements_betterments`',
    `item_description` STRING COMMENT 'Detailed narrative description of the scheduled item including distinguishing characteristics and identifying features.',
    `item_sequence` BIGINT COMMENT 'Sequential ordering of this item within the schedule for the policy.',
    `item_status` STRING COMMENT 'Current lifecycle status of the scheduled item on the policy.. Valid values are `active|removed|suspended|pending_appraisal`',
    `item_type` STRING COMMENT 'Specific sub-classification of the item within its category, such as machinery, furniture, or inventory.',
    `occupancy_type` STRING COMMENT 'The business use or occupancy classification of the premises where the item is located, affecting risk and rating.',
    `protection_class` STRING COMMENT 'The ISO Public Protection Classification indicating fire protection quality at the items location, ranging from 1 best to 10 worst.',
    `rate_per_hundred` DECIMAL(8,5) COMMENT 'The insurance rate applied per hundred dollars of sum insured to calculate the premium for this item.',
    `removal_date` DATE COMMENT 'The date on which this item was removed from the schedule, if applicable.',
    `removal_reason` STRING COMMENT 'The business reason why this item was removed from the schedule.. Valid values are `sold|disposed|relocated|total_loss|policy_cancellation|coverage_change`',
    `replacement_cost_value_amount` DECIMAL(18,2) COMMENT 'The cost to replace the item with new property of like kind and quality without deduction for depreciation.',
    `schedule_number` STRING COMMENT 'Business identifier for the TIV schedule, typically referenced on policy declarations and endorsements.',
    `sum_insured_amount` DECIMAL(18,2) COMMENT 'The total amount of insurance coverage provided for this scheduled item, representing the maximum claim payout.',
    `sum_insured_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the sum insured amount.. Valid values are `^[A-Z]{3}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this TIV schedule record was last modified in the system.',
    `valuation_date` DATE COMMENT 'The date on which the current valuation amounts were determined or last updated.',
    `valuation_method` STRING COMMENT 'The basis of valuation applied to determine the insured value of this item for coverage and claims settlement purposes.. Valid values are `replacement_cost|actual_cash_value|agreed_value|market_value|functional_replacement_cost`',
    CONSTRAINT pk_tiv_schedule PRIMARY KEY(`tiv_schedule_id`)
) COMMENT 'Schedule of Total Insured Values for a commercial property or inland marine risk. Each row represents one scheduled item (building, contents, equipment) with its SI, RCV, ACV, and depreciation basis.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` (
    `wc_payroll_class_id` BIGINT COMMENT 'Unique identifier for the workers compensation payroll classification record.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: WC payroll classifications are for employer entities (insured entities in WC context). Valid FK linking payroll class to the employer entity.',
    `policy_id` BIGINT COMMENT 'Reference to the workers compensation policy under which this payroll class is rated.',
    `risk_unit_id` BIGINT COMMENT 'Reference to the employer risk unit or location to which this payroll classification applies.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Workers compensation class codes and manual rates are state-specific (NCCI or independent bureau rates).',
    `audit_type` STRING COMMENT 'Type of premium audit to be conducted for this classification at policy expiration to verify actual payroll exposure.. Valid values are `physical|telephone|mail|waived`',
    `audited_payroll_amount` DECIMAL(18,2) COMMENT 'Actual payroll amount determined through premium audit after policy expiration, used for final premium adjustment.',
    `catastrophe_code` STRING COMMENT 'Code identifying if this classification is subject to catastrophe exposure loading for events like earthquakes or hurricanes.',
    `class_code` STRING COMMENT 'NCCI or state-specific classification code identifying the type of work performed by employees in this class.. Valid values are `^[0-9]{4,6}[A-Z]?$`',
    `class_description` STRING COMMENT 'Full text description of the work activities and operations covered by this classification code.',
    `class_status` STRING COMMENT 'Current status of this payroll classification on the policy, indicating whether it is actively rated or has been removed.. Valid values are `active|inactive|deleted|suspended`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this payroll classification record was first created in the system.',
    `effective_date` DATE COMMENT 'Date when this payroll classification becomes active for rating purposes on the policy.',
    `estimated_annual_payroll` DECIMAL(18,2) COMMENT 'Estimated payroll amount provided at policy inception, used for initial premium calculation subject to audit adjustment.',
    `executive_officer_payroll` DECIMAL(18,2) COMMENT 'Payroll for executive officers who may be included or excluded from coverage, subject to state-specific rules and election.',
    `experience_mod` DECIMAL(6,4) COMMENT 'Experience modification factor applied to the manual rate based on the insureds historical loss experience, where 1.0000 is neutral.',
    `expiration_date` DATE COMMENT 'Date when this payroll classification coverage ends on the policy.',
    `exposure_basis` STRING COMMENT 'The unit of measure used to calculate premium for this class, typically payroll but may be sales, units, or area for certain classifications.. Valid values are `payroll|sales|units|area|other`',
    `exposure_units` DECIMAL(18,2) COMMENT 'Number of exposure units for rating, typically payroll divided by 100 for per-hundred rating basis.',
    `final_rate` DECIMAL(10,4) COMMENT 'Final rate per hundred dollars of payroll after applying experience mod, schedule rating, and other adjustments to the manual rate.',
    `full_time_employee_count` BIGINT COMMENT 'Number of full-time employees working in this classification during the policy period.',
    `governing_class_indicator` BOOLEAN COMMENT 'Flag indicating whether this is the governing classification for the policy, used for experience rating and premium allocation.',
    `hazard_group` STRING COMMENT 'NCCI hazard group letter A through H indicating the relative risk level of this classification, with A being lowest and H highest.. Valid values are `^[A-H]$`',
    `increased_limits_factor` DECIMAL(6,4) COMMENT 'Factor applied when employer liability limits exceed statutory minimums, increasing premium proportionally.',
    `loss_cost` DECIMAL(10,4) COMMENT 'Pure premium or loss cost per hundred dollars of payroll published by NCCI, before carrier loss cost multiplier and expense loading.',
    `loss_cost_multiplier` DECIMAL(6,4) COMMENT 'Carrier-specific multiplier applied to NCCI loss costs to derive manual rates, covering expenses, profit, and other loadings.',
    `manual_premium_amount` DECIMAL(18,2) COMMENT 'Premium calculated by multiplying exposure units by the final rate, before applying policy-level adjustments or minimum premium.',
    `manual_rate` DECIMAL(10,4) COMMENT 'Base rate per hundred dollars of payroll or per exposure unit, as published by NCCI or state rating bureau for this class code.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this payroll classification record was last updated or modified.',
    `naics_code` STRING COMMENT 'Six-digit NAICS code representing the industry classification of the business operations covered by this payroll class.. Valid values are `^[0-9]{6}$`',
    `overtime_payroll_amount` DECIMAL(18,2) COMMENT 'Overtime payroll included in total payroll, with special treatment per NCCI rules where only straight-time equivalent may be rated.',
    `part_time_employee_count` BIGINT COMMENT 'Number of part-time employees working in this classification during the policy period.',
    `payroll_amount` DECIMAL(18,2) COMMENT 'Total payroll amount in dollars for employees in this classification during the policy period, used as the rating basis.',
    `payroll_currency` STRING COMMENT 'Three-letter ISO currency code for the payroll amount, typically USD for US-based policies.. Valid values are `^[A-Z]{3}$`',
    `premium_basis_type` STRING COMMENT 'Method used to calculate premium for this class, typically per hundred dollars of payroll but may be flat or minimum for certain classes.. Valid values are `per_hundred|flat|minimum|other`',
    `schedule_credit_debit` DECIMAL(6,4) COMMENT 'Schedule rating adjustment factor applied by underwriter for risk characteristics not reflected in experience mod, expressed as decimal multiplier.',
    `sic_code` STRING COMMENT 'Four-digit SIC code representing the industry classification, used for legacy reporting and cross-reference purposes.. Valid values are `^[0-9]{4}$`',
    `standard_exception_code` STRING COMMENT 'NCCI code identifying standard exceptions or special rules that apply to this classification for rating or coverage purposes.',
    `subcontractor_payroll_amount` DECIMAL(18,2) COMMENT 'Payroll amount for uninsured subcontractors included in this classification, subject to WC premium calculation if certificates not provided.',
    `terrorism_rate` DECIMAL(10,4) COMMENT 'Additional rate per hundred dollars of payroll for terrorism coverage under TRIA, if applicable to this classification.',
    CONSTRAINT pk_wc_payroll_class PRIMARY KEY(`wc_payroll_class_id`)
) COMMENT 'Master SSOT linking an employer risk unit to an NCCI or state WC classification code with payroll basis, rate, and manual premium.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` (
    `driver_assignment_id` BIGINT COMMENT 'Unique identifier for the driver assignment record.',
    `insured_entity_id` BIGINT COMMENT 'Reference to the driver (insured entity) being assigned to the vehicle.',
    `insured_vehicle_id` BIGINT COMMENT 'Reference to the insured vehicle being assigned to the driver.',
    `policy_id` BIGINT COMMENT 'Reference to the auto policy under which this driver assignment exists.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Driver assignments link drivers to vehicle risk units. Valid FK formalizing that the assignment is for a specific risk unit (the vehicle as a rated risk).',
    `accident_count_3yr` BIGINT COMMENT 'Number of at-fault accidents reported for this driver in the past three years, impacts rating tier.',
    `annual_mileage` BIGINT COMMENT 'Estimated annual miles driven by this driver in this vehicle, used for exposure rating.',
    `assignment_number` STRING COMMENT 'Business identifier for the driver assignment, used for external reference and tracking.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the driver assignment.. Valid values are `active|inactive|pending|terminated|suspended|excluded`',
    `business_use_indicator` BOOLEAN COMMENT 'Flag indicating whether the driver uses this vehicle for business purposes, affecting coverage and rating.',
    `commute_distance_miles` DECIMAL(8,2) COMMENT 'One-way commute distance in miles for this driver using this vehicle, impacts rating and classification.',
    `commute_frequency` STRING COMMENT 'How often the driver uses this vehicle for commuting purposes.. Valid values are `daily|weekly|occasional|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this driver assignment record was first created in the system.',
    `driver_designation` STRING COMMENT 'Classification of the drivers relationship to the vehicle: principal (primary), occasional (secondary), excluded, permissive, or named.. Valid values are `principal|occasional|excluded|permissive|named`',
    `driver_license_expiration_date` DATE COMMENT 'Date when the drivers license expires, monitored for underwriting compliance.',
    `driver_license_number` STRING COMMENT 'State-issued driver license number for the assigned driver, used for Motor Vehicle Report (MVR) ordering and validation.',
    `driver_license_state` STRING COMMENT 'Two-letter state code where the drivers license was issued.',
    `driver_license_status` STRING COMMENT 'Current status of the drivers license as verified through Motor Vehicle Report (MVR).. Valid values are `valid|expired|suspended|revoked|restricted`',
    `driver_training_completion_date` DATE COMMENT 'Date when the driver completed the approved training course.',
    `driver_training_completion_indicator` BOOLEAN COMMENT 'Flag indicating whether the driver has completed an approved defensive driving or driver training course, may qualify for discount.',
    `dui_indicator` BOOLEAN COMMENT 'Flag indicating whether the driver has a DUI or DWI conviction on record, critical for underwriting decisions.',
    `effective_date` DATE COMMENT 'Date when this driver assignment becomes effective on the policy.',
    `endorsement_number` STRING COMMENT 'Policy endorsement number that added, modified, or removed this driver assignment.',
    `expiration_date` DATE COMMENT 'Date when this driver assignment expires or is scheduled to end.',
    `good_student_discount_indicator` BOOLEAN COMMENT 'Flag indicating whether the driver qualifies for good student discount based on academic performance.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this driver assignment record was last updated.',
    `mvr_order_date` DATE COMMENT 'Date when the most recent Motor Vehicle Report was ordered for this driver assignment.',
    `mvr_score` BIGINT COMMENT 'Numerical score derived from the drivers Motor Vehicle Report, used in underwriting and rating decisions.',
    `rating_tier` STRING COMMENT 'Underwriting tier assigned to this driver assignment based on risk profile, directly impacts premium calculation.. Valid values are `preferred|standard|non_standard|high_risk`',
    `termination_date` DATE COMMENT 'Actual date when this driver assignment was terminated before the scheduled expiration.',
    `termination_reason` STRING COMMENT 'Business reason for early termination of the driver assignment, such as driver removed, vehicle sold, or policy cancelled.',
    `territory_code` STRING COMMENT 'Geographic rating territory code where the vehicle is principally garaged by this driver, used for rate lookup.',
    `underwriter_notes` STRING COMMENT 'Free-text notes from underwriter regarding special considerations, exceptions, or conditions for this driver assignment.',
    `usage_percentage` DECIMAL(5,2) COMMENT 'Percentage of time this driver operates the assigned vehicle, used for rating and premium calculation. Range 0.00 to 100.00.',
    `violation_count_3yr` BIGINT COMMENT 'Number of moving violations reported for this driver in the past three years, impacts rating tier.',
    CONSTRAINT pk_driver_assignment PRIMARY KEY(`driver_assignment_id`)
) COMMENT 'Junction table assigning a driver (insured entity) to an insured vehicle on a policy. Captures principal vs. occasional driver designation, assignment effective date, and usage percentage. Supports auto rating and UW.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` (
    `risk_score_id` BIGINT COMMENT 'Unique identifier for the underwriting risk score record.',
    `insured_entity_id` BIGINT COMMENT 'Reference to the insured entity being scored, if entity-specific.',
    `insured_location_id` BIGINT COMMENT 'Reference to the insured location being scored, if location-specific.',
    `insured_vehicle_id` BIGINT COMMENT 'Reference to the insured vehicle being scored, if vehicle-specific.',
    `policy_id` BIGINT COMMENT 'Reference to the policy for which this risk score was generated.',
    `quote_id` BIGINT COMMENT 'Reference to the quote for which this risk score was pulled during the quoting process.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Risk scores can be assigned to risk units (e.g., ISO FireLine score for a building risk unit). Valid FK linking the score to the rated risk unit.',
    `scheduled_equipment_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_equipment. Business justification: Risk scores can be assigned to scheduled equipment (e.g., breakdown risk score for machinery). Valid FK linking the score to the rated equipment.',
    `scheduled_item_id` BIGINT COMMENT 'Foreign key linking to riskexposure.scheduled_item. Business justification: Risk scores can be assigned to scheduled items (e.g., theft risk score for jewelry). Valid FK linking the score to the rated item.',
    `policy_transaction_id` BIGINT COMMENT 'Unique transaction identifier provided by the vendor for the score request.',
    `adverse_action_required` BOOLEAN COMMENT 'Indicates whether an adverse action notice is required based on the score result per FCRA regulations.',
    `cat_zone` STRING COMMENT 'Catastrophe zone designation relevant to the risk score, such as hurricane or earthquake zone.',
    `coverage_type` STRING COMMENT 'Specific coverage type or peril for which the risk score was generated.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the risk score record was first created in the system.',
    `data_source_count` BIGINT COMMENT 'Number of data sources used by the vendor to calculate the risk score.',
    `error_code` STRING COMMENT 'Vendor error code returned if the score request failed or encountered issues.',
    `error_message` STRING COMMENT 'Detailed error message explaining why the score request failed or returned incomplete data.',
    `lob_code` STRING COMMENT 'Insurance line of business code for which the risk score applies.',
    `model_effective_date` DATE COMMENT 'Date when the scoring model version became effective for use in underwriting.',
    `model_name` STRING COMMENT 'Specific name or identifier of the scoring model used by the vendor.',
    `model_vendor` STRING COMMENT 'Name of the third-party vendor that provided the risk scoring model. [ENUM-REF-CANDIDATE: ISO|Verisk|LexisNexis|CoreLogic|TransUnion|Experian|Equifax|Other — 8 candidates stripped; promote to reference product]',
    `model_version` STRING COMMENT 'Version number or release identifier of the scoring model used to generate the score.',
    `override_flag` BOOLEAN COMMENT 'Indicates whether the risk score was manually overridden by an underwriter.',
    `override_reason` STRING COMMENT 'Explanation provided by the underwriter for overriding the vendor-provided risk score.',
    `override_timestamp` TIMESTAMP COMMENT 'Timestamp when the risk score override was performed.',
    `override_user_code` STRING COMMENT 'User identifier of the underwriter who performed the score override.',
    `rate_modifier` DECIMAL(7,4) COMMENT 'Premium rate adjustment factor derived from the risk score for pricing purposes.',
    `request_reference_number` STRING COMMENT 'Internal reference number assigned to the score request for tracking and audit purposes.',
    `score_confidence_level` STRING COMMENT 'Vendor-provided confidence level indicating the reliability of the score based on data completeness.. Valid values are `high|medium|low`',
    `score_cost_amount` DECIMAL(10,2) COMMENT 'Cost charged by the vendor for pulling this risk score.',
    `score_cost_currency` STRING COMMENT 'Currency code for the score cost amount.. Valid values are `USD|CAD|EUR|GBP|AUD`',
    `score_expiration_date` DATE COMMENT 'Date when the risk score is no longer considered valid and must be refreshed.',
    `score_percentile` DECIMAL(5,2) COMMENT 'Percentile rank of the score within the scoring model population, expressed as a percentage.',
    `score_pull_date` DATE COMMENT 'Date when the risk score was retrieved from the third-party vendor system.',
    `score_pull_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the risk score was retrieved from the vendor API or batch feed.',
    `score_reason_code` STRING COMMENT 'Primary reason code explaining the key factors that influenced the risk score value.',
    `score_reason_description` STRING COMMENT 'Human-readable explanation of the primary factors that influenced the risk score.',
    `score_status` STRING COMMENT 'Current lifecycle status of the risk score record.. Valid values are `active|expired|superseded|invalid|pending`',
    `score_tier` STRING COMMENT 'Categorical tier or band assigned to the score value for underwriting decisioning.. Valid values are `excellent|good|average|below_average|poor|unacceptable`',
    `score_type` STRING COMMENT 'Category of risk score indicating the domain or peril being assessed.. Valid values are `property|wildfire|credit|auto|liability|catastrophe`',
    `score_value` DECIMAL(10,4) COMMENT 'Numeric risk score value returned by the third-party scoring model.',
    `territory_code` STRING COMMENT 'Geographic territory code associated with the risk unit being scored.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the risk score record was last modified.',
    `uw_action_code` STRING COMMENT 'Recommended underwriting action based on the risk score result.. Valid values are `accept|refer|decline|quote_with_conditions`',
    CONSTRAINT pk_risk_score PRIMARY KEY(`risk_score_id`)
) COMMENT 'Underwriting risk score record for a risk unit derived from third-party models (ISO FireLine, Verisk Wildfire, LexisNexis, credit-based insurance score). Stores score value, model version, pull date, and score tier.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` (
    `pml_estimate_id` BIGINT COMMENT 'Unique identifier for the PML estimate record.',
    `insured_location_id` BIGINT COMMENT 'Reference to the insured location being assessed for probable maximum loss.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Probable maximum loss estimates are calculated per line of business for reinsurance treaty structuring (property cat XOL), capital modeling (RBC CAT charge), and risk appetite monitoring.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this PML estimate is calculated.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: PML estimates are calculated for risk units (buildings, locations, portfolios). Valid FK linking the PML estimate to the specific risk unit being modeled.',
    `superseded_by_estimate_pml_estimate_id` BIGINT COMMENT 'Reference to the newer PML estimate that supersedes this one, if applicable.',
    `annual_aggregate_deductible_amount` DECIMAL(18,2) COMMENT 'Annual aggregate deductible applied in the PML calculation for the policy or location.',
    `approved_by` STRING COMMENT 'Name or identifier of the underwriter or actuary who approved this PML estimate.',
    `approved_date` DATE COMMENT 'Date when this PML estimate was formally approved for use in underwriting decisions.',
    `cat_zone_code` STRING COMMENT 'Catastrophe zone code assigned to the location for rating and exposure management.',
    `confidence_level_percentage` DECIMAL(5,2) COMMENT 'Statistical confidence level associated with the PML estimate, typically 90% or 95%.',
    `construction_type` STRING COMMENT 'Construction type of the insured building used in the catastrophe model.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this PML estimate record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this estimate.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date from which this PML estimate is effective for underwriting and risk management decisions.',
    `estimate_number` STRING COMMENT 'Business identifier for the PML estimate used for tracking and reporting purposes.',
    `estimate_status` STRING COMMENT 'Current lifecycle status of the PML estimate in the review and approval workflow.. Valid values are `draft|pending_review|approved|rejected|superseded|expired`',
    `exceedance_probability` DECIMAL(8,6) COMMENT 'Probability that the actual loss will exceed the estimated PML amount.',
    `expiration_date` DATE COMMENT 'Date when this PML estimate expires and should be refreshed or superseded.',
    `gross_pml_amount` DECIMAL(18,2) COMMENT 'Estimated probable maximum loss amount before reinsurance recoveries.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this PML estimate record was last updated or modified.',
    `model_run_code` STRING COMMENT 'Unique identifier for the specific model execution batch that produced this estimate.',
    `model_run_date` DATE COMMENT 'Date when the catastrophe model was executed to produce this PML estimate.',
    `model_vendor` STRING COMMENT 'Vendor or provider of the catastrophe model used to generate the PML estimate.. Valid values are `AIR|RMS|CoreLogic|KCC|Internal`',
    `model_version` STRING COMMENT 'Version identifier of the catastrophe model used for the PML calculation.',
    `net_pml_amount` DECIMAL(18,2) COMMENT 'Estimated probable maximum loss amount after reinsurance recoveries and risk transfer.',
    `number_of_stories` BIGINT COMMENT 'Number of stories in the insured building, used as a factor in the PML calculation.',
    `occupancy_type` STRING COMMENT 'Type of occupancy for the insured location used in the catastrophe model.',
    `per_occurrence_limit_amount` DECIMAL(18,2) COMMENT 'Maximum limit per occurrence applied in the PML calculation.',
    `peril_type` STRING COMMENT 'Type of catastrophic peril for which the probable maximum loss is being estimated.. Valid values are `earthquake|hurricane|flood|wildfire|tornado|hail`',
    `pml_percentage` DECIMAL(5,2) COMMENT 'PML expressed as a percentage of total insured value for the location or portfolio.',
    `reinsurance_structure_applied` STRING COMMENT 'Type of reinsurance structure applied when calculating net PML from gross PML.. Valid values are `none|quota_share|excess_of_loss|cat_xl|facultative`',
    `review_notes` STRING COMMENT 'Free-text notes from the underwriter or actuary reviewing the PML estimate.',
    `scenario_description` STRING COMMENT 'Detailed description of the catastrophe scenario modeled, including magnitude and geographic scope.',
    `scenario_return_period_years` BIGINT COMMENT 'Return period in years for the catastrophe scenario, typically 100, 250, or 500 years.',
    `territory_code` STRING COMMENT 'Rating territory code for the location used in the PML assessment.',
    `tiv` DECIMAL(18,2) COMMENT 'Total insured value of the property or portfolio used as the basis for PML calculation.',
    `year_built` BIGINT COMMENT 'Year the insured building was constructed, used as a factor in the PML calculation.',
    CONSTRAINT pk_pml_estimate PRIMARY KEY(`pml_estimate_id`)
) COMMENT 'Probable Maximum Loss estimate for a property or CAT-exposed risk unit. Stores PML percentage, scenario (1-in-100, 1-in-250), peril, model vendor (AIR, RMS, CoreLogic), run date, and gross vs. net of reinsurance values.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` (
    `flood_zone_assignment_id` BIGINT COMMENT 'Unique identifier for the flood zone assignment record.',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to riskexposure.cat_zone. Business justification: Flood zone assignments reference the broader catastrophe zone master. Links FEMA-specific flood data to the enterprise cat zone reference.',
    `insured_location_id` BIGINT COMMENT 'Reference to the insured location for which the flood zone is assigned.',
    `policy_id` BIGINT COMMENT 'Reference to the policy associated with this flood zone assignment.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Flood zone determinations require state-level NFIP participation status tracking, state-specific mandatory purchase requirements, and state regulatory oversight of flood insurance placement.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the flood zone assignment record.. Valid values are `active|expired|superseded|pending|cancelled`',
    `base_flood_elevation_ft` DECIMAL(10,2) COMMENT 'Elevation in feet above sea level at which there is a one percent chance of flooding in any given year.',
    `cbrs_unit_code` STRING COMMENT 'Identifier for the specific CBRS unit if the location falls within a designated coastal barrier area.',
    `coastal_barrier_system_indicator` BOOLEAN COMMENT 'Flag indicating whether the location is within a Coastal Barrier Resources System area where federal flood insurance is restricted.',
    `comments` STRING COMMENT 'Additional notes or remarks regarding the flood zone assignment, determination process, or special circumstances.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the flood zone assignment record was first created in the system.',
    `determination_date` DATE COMMENT 'Date when the flood zone determination was performed for the insured location.',
    `determination_method` STRING COMMENT 'Method used to determine the flood zone classification for the location.. Valid values are `automated|manual|life_of_loan|standard`',
    `determination_number` STRING COMMENT 'Unique tracking number issued by the flood determination service provider for this assessment.',
    `determination_provider` STRING COMMENT 'Name of the third-party vendor or service that performed the flood zone determination.',
    `effective_date` DATE COMMENT 'Date when this flood zone assignment became effective for underwriting and rating purposes.',
    `elevation_certificate_available` BOOLEAN COMMENT 'Flag indicating whether a FEMA Elevation Certificate has been obtained for the insured structure.',
    `elevation_certificate_date` DATE COMMENT 'Date when the Elevation Certificate was completed by a licensed surveyor or engineer.',
    `elevation_difference_ft` DECIMAL(10,2) COMMENT 'Difference between the lowest floor elevation and the base flood elevation, used for rating purposes.',
    `expiration_date` DATE COMMENT 'Date when this flood zone assignment expires or is superseded by a new determination.',
    `firm_panel_effective_date` DATE COMMENT 'Date when the current FIRM panel became effective for the location.',
    `firm_panel_number` STRING COMMENT 'Unique identifier for the FEMA Flood Insurance Rate Map panel covering the insured location.',
    `firm_panel_revision_date` DATE COMMENT 'Most recent date when the FIRM panel was revised or updated by FEMA.',
    `flood_zone_rating_factor` DECIMAL(8,4) COMMENT 'Numerical factor applied to premium calculation based on the flood zone classification and risk level.',
    `grandfathering_eligible_indicator` BOOLEAN COMMENT 'Flag indicating whether the property is eligible for grandfathered flood insurance rates due to map changes.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the flood zone assignment record was most recently updated.',
    `lender_name` STRING COMMENT 'Name of the mortgage lender requiring flood zone determination for loan compliance purposes.',
    `loan_number` STRING COMMENT 'Mortgage loan number associated with the flood zone determination requirement.',
    `loma_lomr_case_number` STRING COMMENT 'FEMA case number for the LOMA or LOMR if one has been issued for this location.',
    `loma_lomr_effective_date` DATE COMMENT 'Date when the LOMA or LOMR became effective, modifying the flood zone designation.',
    `loma_lomr_indicator` BOOLEAN COMMENT 'Flag indicating whether a LOMA or LOMR has been issued by FEMA for this location, potentially changing the flood zone designation.',
    `lowest_floor_elevation_ft` DECIMAL(10,2) COMMENT 'Elevation of the lowest floor of the insured structure in feet above sea level.',
    `mandatory_purchase_indicator` BOOLEAN COMMENT 'Flag indicating whether federal flood insurance purchase is mandatory for mortgage compliance at this location.',
    `modified_by_user` STRING COMMENT 'Username or identifier of the system user who last modified the flood zone assignment record.',
    `nfip_community_code` STRING COMMENT 'Six-digit identifier assigned by FEMA to the participating NFIP community where the property is located.',
    `nfip_community_name` STRING COMMENT 'Name of the NFIP participating community jurisdiction covering the insured location.',
    `nfip_participation_status` STRING COMMENT 'Current participation status of the community in the NFIP, affecting insurance availability and requirements.. Valid values are `participating|suspended|probation|emergency|regular`',
    `preferred_risk_policy_eligible` BOOLEAN COMMENT 'Flag indicating whether the location qualifies for NFIP Preferred Risk Policy lower-cost coverage.',
    `redetermination_required_date` DATE COMMENT 'Date by which a new flood zone determination must be obtained to maintain compliance.',
    `sfha_indicator` BOOLEAN COMMENT 'Flag indicating whether the location is within a Special Flood Hazard Area subject to mandatory flood insurance purchase requirements.',
    `surveyor_license_number` STRING COMMENT 'Professional license number of the surveyor or engineer who completed the Elevation Certificate.',
    `surveyor_name` STRING COMMENT 'Name of the licensed surveyor or engineer who completed the Elevation Certificate.',
    CONSTRAINT pk_flood_zone_assignment PRIMARY KEY(`flood_zone_assignment_id`)
) COMMENT 'FEMA/NFIP flood zone designation assigned to an insured location. Stores flood zone code, BFE (Base Flood Elevation), FIRM panel number, determination date, and mandatory purchase indicator for mortgage compliance.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` (
    `gl_operation_id` BIGINT COMMENT 'Unique identifier for the general liability operation record.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: GL operations are business activities conducted by insured entities (commercial insureds). Valid FK linking the operation to the entity conducting it.',
    `insured_location_id` BIGINT COMMENT 'Reference to the physical location where this GL operation is conducted.',
    `policy_id` BIGINT COMMENT 'Reference to the commercial policy under which this GL operation is insured.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: GL operations are themselves risk units in the GL rating structure. Valid FK linking the operation to its parent risk unit record.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: General liability operations are rated by state territory for ISO GL class code application, state-specific tort law exposure assessment, and regulatory compliance.',
    `added_date` DATE COMMENT 'Date on which this operation was added to the policy, which may differ from effective date for mid-term endorsements.',
    `annual_payroll_amount` DECIMAL(18,2) COMMENT 'Total annual payroll for employees engaged in this operation, used as rating exposure basis for certain class codes.',
    `annual_premium_amount` DECIMAL(18,2) COMMENT 'Total annual premium charged for GL coverage on this operation, calculated from exposure and rate.',
    `annual_receipts_amount` DECIMAL(18,2) COMMENT 'Total gross receipts or sales revenue generated by this operation during the policy term, used as rating exposure basis.',
    `area_sqft` DECIMAL(12,2) COMMENT 'Total square footage of premises or operational area, used as rating exposure basis for area-rated classes.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this GL operation record was first created in the source system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this operation record.. Valid values are `USD|CAD|EUR|GBP|AUD|MXN`',
    `effective_date` DATE COMMENT 'Date on which this GL operation became active and coverage commenced.',
    `endorsement_number` STRING COMMENT 'Policy endorsement number under which this operation was added, modified, or removed.',
    `expiration_date` DATE COMMENT 'Date on which coverage for this GL operation expires or is scheduled to terminate.',
    `exposure_basis` STRING COMMENT 'The rating basis used to calculate premium for this operation: area, payroll, gross receipts, units sold, or other measure.. Valid values are `area|payroll|receipts|units|admissions|per_location`',
    `hazard_grade` STRING COMMENT 'Underwriting assessment of the relative hazard or risk level of this operation: low, moderate, high, or severe.. Valid values are `low|moderate|high|severe`',
    `iso_gl_class_code` STRING COMMENT 'ISO standard classification code identifying the type of business operation for rating and underwriting purposes.',
    `iso_gl_class_description` STRING COMMENT 'Full text description of the ISO GL class code as published in the ISO rating manual.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this GL operation record was most recently updated in the source system.',
    `naics_code` STRING COMMENT 'Six-digit NAICS code classifying the primary industry sector of the operation.',
    `number_of_employees` BIGINT COMMENT 'Total count of full-time equivalent employees engaged in this operation during the policy term.',
    `number_of_units` BIGINT COMMENT 'Count of discrete units produced, sold, or serviced by this operation, used as rating exposure basis for unit-rated classes.',
    `operation_description` STRING COMMENT 'Detailed narrative describing the nature, scope, and activities of the insured business operation.',
    `operation_name` STRING COMMENT 'Short descriptive name or title of the business operation being insured.',
    `operation_number` STRING COMMENT 'Business-assigned sequential or coded identifier for this operation within the policy.',
    `operation_status` STRING COMMENT 'Current lifecycle status of the GL operation record within the policy term.. Valid values are `active|inactive|suspended|pending|cancelled`',
    `operation_type` STRING COMMENT 'Category of GL exposure this operation represents: premises operations, products liability, completed operations, or other.. Valid values are `premises|products|completed_operations|contractual|independent_contractors`',
    `premises_operations_split_pct` DECIMAL(5,2) COMMENT 'Percentage of total receipts or exposure allocated to premises and ongoing operations hazard.',
    `products_completed_ops_split_pct` DECIMAL(5,2) COMMENT 'Percentage of total receipts or exposure allocated to products and completed operations hazard, as opposed to premises operations.',
    `rate_per_exposure_unit` DECIMAL(10,6) COMMENT 'The manual rate applied per unit of exposure (per hundred of payroll, per thousand of receipts, per square foot) for this operation.',
    `removal_reason` STRING COMMENT 'Reason code explaining why this operation was removed from coverage before expiration.. Valid values are `discontinued|sold|non_renewal|underwriting|insured_request|other`',
    `removed_date` DATE COMMENT 'Date on which this operation was removed from the policy prior to natural expiration.',
    `sic_code` STRING COMMENT 'Four-digit SIC code classifying the business activity for regulatory and statistical purposes.',
    `subcontractor_receipts_amount` DECIMAL(18,2) COMMENT 'Total payments made to uninsured subcontractors for work performed under this operation, subject to additional premium.',
    `subcontractor_work_indicator` BOOLEAN COMMENT 'Flag indicating whether this operation involves the use of subcontractors or independent contractors.',
    `territory_code` STRING COMMENT 'ISO or carrier-specific geographic territory code used for rating this operation.',
    `underwriting_notes` STRING COMMENT 'Free-text underwriting comments, special conditions, or risk assessment notes related to this operation.',
    CONSTRAINT pk_gl_operation PRIMARY KEY(`gl_operation_id`)
) COMMENT 'General Liability operations record describing the business activities of a commercial insured risk unit. Stores ISO GL class code, operation description, receipts, area, payroll, and products-completed operations split.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` (
    `scheduled_equipment_id` BIGINT COMMENT 'Unique identifier for the scheduled equipment item record.',
    `policy_coverage_id` BIGINT COMMENT 'Reference to the specific coverage part or endorsement under which this equipment is insured.',
    `insured_location_id` BIGINT COMMENT 'Reference to the insured location where the equipment is primarily situated or garaged.',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_vehicle. Business justification: Scheduled equipment can be attached to vehicles (e.g., specialized equipment on commercial trucks, mobile equipment).',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this equipment is scheduled.',
    `acv_amount` DECIMAL(18,2) COMMENT 'Actual cash value of the equipment reflecting depreciation and wear, used for claims settlement.',
    `added_date` DATE COMMENT 'Date on which this equipment item was added to the policy schedule.',
    `agreed_value_amount` DECIMAL(18,2) COMMENT 'Mutually agreed upon value between insured and insurer for the equipment, binding for claims settlement.',
    `annual_premium_amount` DECIMAL(18,2) COMMENT 'Annual premium charged for insuring this specific equipment item.',
    `appraisal_date` DATE COMMENT 'Date on which the equipment appraisal was conducted.',
    `appraisal_value_amount` DECIMAL(18,2) COMMENT 'Professionally appraised value of the equipment as determined by a certified appraiser.',
    `appraiser_name` STRING COMMENT 'Name of the certified appraiser or appraisal firm that valued the equipment.',
    `blanket_group_code` STRING COMMENT 'Code identifying the blanket coverage group to which this equipment belongs if applicable.',
    `coverage_type` STRING COMMENT 'Designation indicating whether the equipment is covered under blanket, specific, or scheduled coverage.. Valid values are `blanket|specific|scheduled`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this scheduled equipment record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts associated with this equipment item.. Valid values are `USD|CAD|EUR|GBP|MXN`',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount applicable to this specific equipment item for claims.',
    `effective_date` DATE COMMENT 'Date on which coverage for this scheduled equipment item becomes effective.',
    `endorsement_number` STRING COMMENT 'Policy endorsement number under which this equipment item was added, modified, or removed.',
    `equipment_category` STRING COMMENT 'Broader grouping or line of business category for the equipment such as inland marine or equipment floater.',
    `equipment_description` STRING COMMENT 'Detailed narrative description of the equipment including distinguishing features and characteristics.',
    `equipment_name` STRING COMMENT 'Business-friendly name or title of the scheduled equipment item.',
    `equipment_status` STRING COMMENT 'Current lifecycle status of the scheduled equipment item on the policy.. Valid values are `active|removed|suspended|pending`',
    `equipment_type` STRING COMMENT 'Classification of the equipment by functional category for rating and underwriting purposes.. Valid values are `contractor_equipment|mobile_equipment|electronic_equipment|medical_equipment|agricultural_equipment|other`',
    `expiration_date` DATE COMMENT 'Date on which coverage for this scheduled equipment item expires or terminates.',
    `is_away_from_premises` BOOLEAN COMMENT 'Indicator whether the equipment is covered while away from the primary insured premises.',
    `is_blanket_covered` BOOLEAN COMMENT 'Indicator whether this equipment is included under a blanket coverage limit rather than individually scheduled.',
    `iso_class_code` STRING COMMENT 'ISO classification code for the equipment type used for rating and statistical reporting.',
    `item_number` STRING COMMENT 'Sequential or business-assigned number identifying this equipment item within the policy schedule.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this scheduled equipment record was last updated or modified.',
    `lob_code` STRING COMMENT 'Line of business code classifying the equipment coverage such as inland marine or commercial property.',
    `location_description` STRING COMMENT 'Narrative description of where the equipment is normally kept or garaged.',
    `make` STRING COMMENT 'Manufacturer or brand name of the equipment.',
    `model` STRING COMMENT 'Specific model designation or number assigned by the manufacturer.',
    `purchase_date` DATE COMMENT 'Date on which the insured purchased or acquired the equipment.',
    `purchase_price_amount` DECIMAL(18,2) COMMENT 'Original purchase price paid by the insured for the equipment.',
    `rate_per_hundred` DECIMAL(10,4) COMMENT 'Rating factor expressed as premium per hundred dollars of insured value for this equipment.',
    `rcv_amount` DECIMAL(18,2) COMMENT 'Replacement cost value representing the cost to replace the equipment with new property of like kind and quality.',
    `removal_date` DATE COMMENT 'Date on which this equipment item was removed from the policy schedule.',
    `removal_reason` STRING COMMENT 'Business reason code explaining why the equipment was removed from coverage.. Valid values are `sold|disposed|transferred|total_loss|policy_cancellation|other`',
    `serial_number` STRING COMMENT 'Manufacturer-assigned serial number uniquely identifying the physical equipment unit.',
    `storage_type` STRING COMMENT 'Classification of how and where the equipment is stored when not in use.. Valid values are `indoor|outdoor|secured_facility|mobile`',
    `territory_code` STRING COMMENT 'Geographic rating territory code applicable to the equipment location for premium calculation.',
    `valuation_basis` STRING COMMENT 'Method used to determine the insured value of the equipment for coverage and claims purposes.. Valid values are `acv|rcv|agreed_value|stated_amount`',
    `year_manufactured` BIGINT COMMENT 'Calendar year in which the equipment was manufactured or built.',
    CONSTRAINT pk_scheduled_equipment PRIMARY KEY(`scheduled_equipment_id`)
) COMMENT 'Scheduled inland marine or equipment floater item record. Captures equipment type, serial number, year, ACV, RCV, location, and blanket vs. specific coverage designation. Used for CPP and BOP equipment scheduling.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` (
    `experience_mod_id` BIGINT COMMENT 'Unique identifier for the experience modification record.',
    `insured_entity_id` BIGINT COMMENT 'Reference to the insured entity for which the experience modification was calculated.',
    `policy_id` BIGINT COMMENT 'Reference to the policy to which this experience modification applies.',
    `risk_unit_id` BIGINT COMMENT 'Foreign key linking to riskexposure.risk_unit. Business justification: Experience modification factors apply to specific risk units (typically WC employer risk units). Valid FK linking the e-mod to the rated risk unit.',
    `state_id` BIGINT COMMENT 'Foreign key linking to shared.state. Business justification: Experience modification factors are calculated by state rating bureau (NCCI or independent) with state-specific loss development and credibility rules.',
    `superseded_by_mod_id` BIGINT COMMENT 'Reference to the experience modification record that supersedes this one, used to track modification history.',
    `actual_loss_amount` DECIMAL(15,2) COMMENT 'Actual incurred loss amount for the insured during the rating period, used as the numerator in the EMod calculation.',
    `appeal_date` DATE COMMENT 'Date on which the insured filed an appeal to contest the experience modification.',
    `appeal_resolution_date` DATE COMMENT 'Date on which the appeal was resolved by the rating bureau.',
    `appeal_status` STRING COMMENT 'Status of any appeal filed by the insured to contest the experience modification calculation.. Valid values are `not_appealed|pending|approved|denied`',
    `ballast_value` DECIMAL(15,2) COMMENT 'Ballast or credibility factor applied in the experience modification calculation to stabilize the mod for smaller insureds.',
    `bureau_code` STRING COMMENT 'Code identifying the rating bureau that issued the experience modification, such as NCCI or a state-specific bureau.',
    `bureau_name` STRING COMMENT 'Name of the rating bureau that issued the experience modification.',
    `calculation_date` DATE COMMENT 'Date on which the experience modification was calculated by the rating bureau.',
    `claim_count` BIGINT COMMENT 'Total number of claims included in the experience period used to calculate the modification factor.',
    `class_code` STRING COMMENT 'Primary classification code for the insured, linking to NCCI or ISO class code tables for rating purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the experience modification record was first created in the system.',
    `credibility_factor` DECIMAL(5,4) COMMENT 'Statistical credibility factor applied to the experience modification, reflecting the reliability of the insureds loss history.',
    `effective_date` DATE COMMENT 'Date on which the experience modification becomes effective for rating purposes.',
    `excess_loss_component` DECIMAL(15,2) COMMENT 'Dollar amount of excess losses used in the experience modification calculation, representing losses above the primary threshold.',
    `expected_excess_loss_amount` DECIMAL(15,2) COMMENT 'Expected excess loss amount used in the experience modification formula.',
    `expected_loss_amount` DECIMAL(15,2) COMMENT 'Expected loss amount for the insured based on industry averages and exposure, used as the denominator in the EMod calculation.',
    `expected_primary_loss_amount` DECIMAL(15,2) COMMENT 'Expected primary loss amount used in the experience modification formula.',
    `expiration_date` DATE COMMENT 'Date on which the experience modification expires and is no longer applicable for rating.',
    `indemnity_claim_count` BIGINT COMMENT 'Number of indemnity claims included in the experience period, representing claims with wage replacement payments.',
    `interstate_mod_indicator` BOOLEAN COMMENT 'Indicates whether the experience modification applies across multiple states or is state-specific.',
    `issued_date` DATE COMMENT 'Date on which the experience modification worksheet was issued to the insured or agent.',
    `medical_only_claim_count` BIGINT COMMENT 'Number of medical-only claims included in the experience period, representing claims with no indemnity payments.',
    `mod_change_reason` STRING COMMENT 'Reason for change in the experience modification value compared to the prior period, such as improved loss experience or increased claims.',
    `mod_number` STRING COMMENT 'Business identifier for the experience modification record, typically assigned by the rating bureau.',
    `mod_status` STRING COMMENT 'Current lifecycle status of the experience modification record.. Valid values are `active|expired|superseded|pending|cancelled`',
    `mod_type` STRING COMMENT 'Type of experience modification, indicating the line of business or adjustment category.. Valid values are `workers_compensation|general_liability|schedule_credit|debit|other`',
    `mod_value` DECIMAL(5,2) COMMENT 'The calculated experience modification factor applied to the base premium. A value of 1.00 is neutral; below 1.00 is a credit; above 1.00 is a debit.',
    `naics_code` STRING COMMENT 'NAICS code representing the primary business activity of the insured, used for industry classification and benchmarking.',
    `notes` STRING COMMENT 'Free-text notes regarding the experience modification, including underwriter comments, special circumstances, or bureau explanations.',
    `payroll_amount` DECIMAL(15,2) COMMENT 'Total payroll amount for the rating period, used as the exposure base for workers compensation experience rating.',
    `primary_loss_component` DECIMAL(15,2) COMMENT 'Dollar amount of primary losses used in the experience modification calculation, typically capped per occurrence.',
    `prior_mod_value` DECIMAL(5,2) COMMENT 'Experience modification value from the immediately preceding rating period, used for trend analysis and comparison.',
    `rating_period_end_date` DATE COMMENT 'End date of the experience period used to calculate the modification factor.',
    `rating_period_start_date` DATE COMMENT 'Start date of the experience period used to calculate the modification factor.',
    `revised_mod_value` DECIMAL(5,2) COMMENT 'Revised experience modification value resulting from a successful appeal or correction.',
    `sic_code` STRING COMMENT 'SIC code representing the primary business activity of the insured, used for legacy industry classification.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the experience modification record was last updated in the system.',
    `worksheet_number` STRING COMMENT 'Unique identifier for the experience rating worksheet provided by the rating bureau, used for audit and reference.',
    CONSTRAINT pk_experience_mod PRIMARY KEY(`experience_mod_id`)
) COMMENT 'Experience modification factor (EMod) record for a WC or GL insured, including WC payroll classification linkage. Stores NCCI or state bureau EMod value, effective date, interstate designation, primary and excess loss components, and history.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` (
    `sir_retention_id` BIGINT COMMENT 'Unique identifier for the self-insured retention record.',
    `policy_coverage_id` BIGINT COMMENT 'Reference to the coverage part to which this SIR retention applies.',
    `insured_entity_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_entity. Business justification: SIR/large deductible programs are established for specific insured entities (commercial insureds). Valid FK linking the retention program to the entity.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to riskexposure.insured_location. Business justification: SIR programs can be location-specific (e.g., per-location retention in a multi-location property program). Valid optional FK for location-level retentions.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Self-insured retention programs are LOB-specific structures (GL SIR, WC deductible programs) with line-specific regulatory approval requirements, collateral rules, and claims handling',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this SIR retention applies.',
    `risk_unit_id` BIGINT COMMENT 'Reference to the specific risk unit subject to this SIR retention.',
    `administrator_contact_name` STRING COMMENT 'Primary contact person at the program administrator organization.',
    `administrator_email` STRING COMMENT 'Email address of the program administrator primary contact.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `administrator_name` STRING COMMENT 'Name of the third-party administrator managing claims and loss fund for the SIR program.',
    `administrator_phone` STRING COMMENT 'Phone number of the program administrator primary contact.',
    `aggregate_limit_amount` DECIMAL(18,2) COMMENT 'Maximum total amount the insured retains across all claims during the policy period.',
    `cancellation_date` DATE COMMENT 'Date on which the SIR retention program was cancelled prior to expiration.',
    `cancellation_reason` STRING COMMENT 'Reason for cancellation of the SIR retention program.',
    `claims_handling_arrangement` STRING COMMENT 'Arrangement defining who handles claims within the SIR layer.. Valid values are `insured_handles|carrier_handles|tpa_handles|shared`',
    `collateral_amount` DECIMAL(18,2) COMMENT 'Total value of collateral posted to secure the SIR retention obligation.',
    `collateral_expiration_date` DATE COMMENT 'Date on which the collateral instrument expires and must be renewed or replaced.',
    `collateral_provider_name` STRING COMMENT 'Name of the financial institution or entity providing the collateral instrument.',
    `collateral_type` STRING COMMENT 'Type of collateral provided by the insured to secure the SIR obligation.. Valid values are `letter_of_credit|cash|surety_bond|trust_fund|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this SIR retention record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this SIR retention record.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date on which the SIR retention program becomes effective.',
    `expiration_date` DATE COMMENT 'Date on which the SIR retention program expires or terminates.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this SIR retention record was last updated.',
    `loss_control_services_included` BOOLEAN COMMENT 'Indicates whether loss control and risk management services are included in the SIR program.',
    `loss_fund_amount` DECIMAL(18,2) COMMENT 'Amount of funds set aside or reserved by the insured to cover losses within the SIR layer.',
    `notes` STRING COMMENT 'Free-form notes and comments regarding the SIR retention program.',
    `peril_code` STRING COMMENT 'Code identifying the specific peril or coverage type subject to this SIR retention.',
    `prior_program_number` STRING COMMENT 'Program number of the prior SIR retention program if this is a renewal.',
    `program_name` STRING COMMENT 'Descriptive name of the SIR or large deductible program.',
    `program_number` STRING COMMENT 'Business identifier for the SIR or large deductible program.',
    `program_status` STRING COMMENT 'Current lifecycle status of the SIR retention program.. Valid values are `active|inactive|suspended|expired|cancelled`',
    `program_type` STRING COMMENT 'Type of self-insured retention program.. Valid values are `sir|large_deductible|self_insured|captive`',
    `regulatory_approval_date` DATE COMMENT 'Date on which regulatory approval was granted for this SIR retention program.',
    `regulatory_approval_required` BOOLEAN COMMENT 'Indicates whether state insurance department approval is required for this SIR program.',
    `regulatory_filing_number` STRING COMMENT 'Filing number assigned by the state insurance department for this SIR program.',
    `renewal_indicator` BOOLEAN COMMENT 'Indicates whether this SIR retention is a renewal of a prior program.',
    `retention_basis` STRING COMMENT 'Basis on which the SIR retention amount applies.. Valid values are `per_occurrence|per_claim|aggregate|per_policy_period`',
    `sir_amount` DECIMAL(18,2) COMMENT 'Per-occurrence or per-claim SIR amount the insured retains before insurance coverage applies.',
    `underwriter_approval_date` DATE COMMENT 'Date on which the underwriter approved this SIR retention program.',
    `underwriter_name` STRING COMMENT 'Name of the underwriter who approved this SIR retention program.',
    CONSTRAINT pk_sir_retention PRIMARY KEY(`sir_retention_id`)
) COMMENT 'Self-Insured Retention or large deductible program record for a commercial risk. Stores SIR amount, aggregate limit, collateral type, collateral amount, loss fund, and program administrator. Links to the risk unit and policy.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` (
    `risk_change_event_id` BIGINT COMMENT 'Unique identifier for the risk change event record.',
    `insured_location_id` BIGINT COMMENT 'Identifier of the insured location affected by this change, if applicable.',
    `insured_vehicle_id` BIGINT COMMENT 'Identifier of the insured vehicle affected by this change, if applicable.',
    `lob_code_id` BIGINT COMMENT 'Foreign key linking to shared.lob_code. Business justification: Risk change events (endorsements, mid-term adjustments) must be tracked by LOB for earned premium recalculation, exposure reporting, and reinsurance premium adjustment.',
    `policy_id` BIGINT COMMENT 'Identifier of the policy under which the risk change occurred.',
    `producers_producer_id` BIGINT COMMENT 'Identifier of the producer or agent who requested the risk change.',
    `reversed_event_id` BIGINT COMMENT 'Identifier of the original risk change event that this event reverses.',
    `risk_unit_id` BIGINT COMMENT 'Identifier of the risk unit affected by this change event.',
    `scheduled_item_id` BIGINT COMMENT 'Identifier of the scheduled item affected by this change, if applicable.',
    `policy_transaction_id` BIGINT COMMENT 'Transaction identifier from the source system for traceability.',
    `approved_date` DATE COMMENT 'Date when the risk change was approved by underwriting.',
    `change_reason_code` STRING COMMENT 'Code indicating the business reason for the risk change.',
    `change_reason_description` STRING COMMENT 'Detailed description of the reason for the risk change.',
    `change_status` STRING COMMENT 'Current status of the risk change event in the workflow.. Valid values are `pending|approved|rejected|applied|reversed`',
    `change_type` STRING COMMENT 'Type of change applied to the risk unit: addition, removal, replacement, modification, upgrade, or downgrade.. Valid values are `addition|removal|replacement|modification|upgrade|downgrade`',
    `changed_attribute_name` STRING COMMENT 'Name of the specific risk attribute that was changed.',
    `class_code` STRING COMMENT 'ISO or NCCI class code applicable to the changed risk.',
    `created_by_user` STRING COMMENT 'User ID or name of the person who created this risk change event record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk change event record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date when the risk change becomes effective on the policy.',
    `endorsement_number` STRING COMMENT 'The endorsement number that triggered this risk change event.',
    `is_cat_exposed` BOOLEAN COMMENT 'Indicates whether the changed risk is exposed to catastrophe perils.',
    `last_modified_by_user` STRING COMMENT 'User ID or name of the person who last modified this risk change event record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk change event record was last modified.',
    `new_cat_zone` STRING COMMENT 'Catastrophe zone code after the change was applied.',
    `new_exposure_units` DECIMAL(18,4) COMMENT 'Exposure units after the change was applied.',
    `new_premium_amount` DECIMAL(18,2) COMMENT 'Premium amount after the change was applied.',
    `new_tiv` DECIMAL(18,2) COMMENT 'Total insured value after the change was applied.',
    `new_value` DECIMAL(18,2) COMMENT 'The value of the risk attribute after the change was applied.',
    `premium_impact_amount` DECIMAL(18,2) COMMENT 'Net change in premium resulting from this risk change event.',
    `prior_cat_zone` STRING COMMENT 'Catastrophe zone code before the change was applied.',
    `prior_exposure_units` DECIMAL(18,4) COMMENT 'Exposure units before the change was applied.',
    `prior_premium_amount` DECIMAL(18,2) COMMENT 'Premium amount before the change was applied.',
    `prior_tiv` DECIMAL(18,2) COMMENT 'Total insured value before the change was applied.',
    `prior_value` DECIMAL(18,2) COMMENT 'The value of the risk attribute before the change was applied.',
    `requested_date` DATE COMMENT 'Date when the risk change was requested by the insured or agent.',
    `reversal_indicator` BOOLEAN COMMENT 'Indicates whether this event represents a reversal of a prior change.',
    `territory_code` STRING COMMENT 'Rating territory code applicable to the changed risk.',
    `transaction_date` DATE COMMENT 'Date when the risk change transaction was recorded in the system.',
    `underwriter_code` BIGINT COMMENT 'Identifier of the underwriter who approved the risk change.',
    `underwriter_notes` STRING COMMENT 'Notes or comments entered by the underwriter regarding the risk change.',
    CONSTRAINT pk_risk_change_event PRIMARY KEY(`risk_change_event_id`)
) COMMENT 'Transactional record of a mid-term change to a risk unit (e.g., location added, vehicle replaced, payroll updated, construction upgrade). Captures change type, effective date, prior and new values, and triggering endorsement.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` (
    `vehicle_claimant_involvement_id` BIGINT COMMENT 'Unique identifier for the vehicle-claimant involvement record. Primary key.',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to the claimant asserting loss related to this vehicle',
    `insured_vehicle_id` BIGINT COMMENT 'Foreign key linking to the insured vehicle involved in the claim event',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this vehicle-claimant involvement record was created in the system.',
    `driver_at_time_of_loss` BOOLEAN COMMENT 'Indicates whether this claimant was the driver of this vehicle at the time of the loss event.',
    `fault_percentage` DECIMAL(5,2) COMMENT 'Percentage of fault allocated to this vehicle for this claimants injuries or damages, used for comparative negligence calculations.',
    `injury_caused_by_vehicle` STRING COMMENT 'Description of injury or damage this claimant sustained specifically from this vehicle.',
    `relationship_to_insured` STRING COMMENT 'Relationship of this claimant to the named insured of this vehicle at time of loss.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this vehicle-claimant involvement record was last updated.',
    `vehicle_occupant_position` STRING COMMENT 'Position of the claimant in or relative to this vehicle at time of loss.',
    CONSTRAINT pk_vehicle_claimant_involvement PRIMARY KEY(`vehicle_claimant_involvement_id`)
) COMMENT 'Association representing the involvement of a claimant with a specific insured vehicle in a claim event. Captures driver status, occupant position, fault allocation, and injury details specific to the vehicle-claimant relationship..';

CREATE OR REPLACE TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` (
    `location_claimant_interest_id` BIGINT COMMENT 'Unique surrogate identifier for the location-claimant interest record. Primary key.',
    `claimant_id` BIGINT COMMENT 'Foreign key linking to the claimant asserting property interest or loss at this location.',
    `insured_location_id` BIGINT COMMENT 'Foreign key linking to the insured location where the claimant has asserted interest or sustained loss.',
    `effective_date` DATE COMMENT 'Date on which the claimant interest at this location became effective. Typically the loss date or the date interest was established.',
    `injury_location_description` STRING COMMENT 'Narrative description of where within the insured location the claimant sustained injury or damage (e.g., parking lot, loading dock, second floor hallway). Supports premises liability claims.',
    `location_claimant_interest_status` STRING COMMENT 'Current status of the claimant interest at this location: active, settled, withdrawn, denied, or subrogated.',
    `loss_exposure_percentage` DECIMAL(5,2) COMMENT 'Percentage of total loss exposure at this location allocated to this claimant. Used for multi-party loss allocation and subrogation. Sum across all claimants for a location should equal 100.',
    `property_interest_type` STRING COMMENT 'Type of legal or financial interest the claimant holds in the property at this location: owner, lessee, mortgagee, secured party, bailee, contractor, or none for third-party claimants.',
    `role` STRING COMMENT 'Role of the claimant at this specific location: insured party, tenant, lienholder, additional insured, contractor, third-party, mortgagee, or loss payee.',
    `termination_date` DATE COMMENT 'Date on which the claimant interest at this location was terminated or settled. Null if interest is still active.',
    CONSTRAINT pk_location_claimant_interest PRIMARY KEY(`location_claimant_interest_id`)
) COMMENT 'Association between insured locations and claimants capturing property interest, loss exposure allocation, and claimant role at specific premises. Supports multi-party claims where multiple claimants assert interest in a single location or a claimant has';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ADD CONSTRAINT `fk_riskexposure_scheduled_item_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ADD CONSTRAINT `fk_riskexposure_insured_entity_parent_entity_insured_entity_id` FOREIGN KEY (`parent_entity_insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ADD CONSTRAINT `fk_riskexposure_risk_unit_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ADD CONSTRAINT `fk_riskexposure_risk_unit_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ADD CONSTRAINT `fk_riskexposure_risk_unit_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ADD CONSTRAINT `fk_riskexposure_risk_unit_scheduled_equipment_id` FOREIGN KEY (`scheduled_equipment_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment`(`scheduled_equipment_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ADD CONSTRAINT `fk_riskexposure_risk_unit_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_scheduled_equipment_id` FOREIGN KEY (`scheduled_equipment_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment`(`scheduled_equipment_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ADD CONSTRAINT `fk_riskexposure_exposure_period_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ADD CONSTRAINT `fk_riskexposure_exposure_period_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ADD CONSTRAINT `fk_riskexposure_exposure_period_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ADD CONSTRAINT `fk_riskexposure_exposure_period_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ADD CONSTRAINT `fk_riskexposure_exposure_period_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ADD CONSTRAINT `fk_riskexposure_uw_survey_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ADD CONSTRAINT `fk_riskexposure_uw_survey_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ADD CONSTRAINT `fk_riskexposure_uw_survey_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ADD CONSTRAINT `fk_riskexposure_mvr_report_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ADD CONSTRAINT `fk_riskexposure_mvr_report_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ADD CONSTRAINT `fk_riskexposure_clue_report_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ADD CONSTRAINT `fk_riskexposure_clue_report_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ADD CONSTRAINT `fk_riskexposure_clue_report_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ADD CONSTRAINT `fk_riskexposure_clue_report_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ADD CONSTRAINT `fk_riskexposure_tiv_schedule_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ADD CONSTRAINT `fk_riskexposure_tiv_schedule_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ADD CONSTRAINT `fk_riskexposure_wc_payroll_class_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ADD CONSTRAINT `fk_riskexposure_wc_payroll_class_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ADD CONSTRAINT `fk_riskexposure_driver_assignment_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ADD CONSTRAINT `fk_riskexposure_driver_assignment_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ADD CONSTRAINT `fk_riskexposure_driver_assignment_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_scheduled_equipment_id` FOREIGN KEY (`scheduled_equipment_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment`(`scheduled_equipment_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ADD CONSTRAINT `fk_riskexposure_pml_estimate_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ADD CONSTRAINT `fk_riskexposure_pml_estimate_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ADD CONSTRAINT `fk_riskexposure_pml_estimate_superseded_by_estimate_pml_estimate_id` FOREIGN KEY (`superseded_by_estimate_pml_estimate_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate`(`pml_estimate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ADD CONSTRAINT `fk_riskexposure_flood_zone_assignment_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ADD CONSTRAINT `fk_riskexposure_flood_zone_assignment_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ADD CONSTRAINT `fk_riskexposure_gl_operation_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ADD CONSTRAINT `fk_riskexposure_gl_operation_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ADD CONSTRAINT `fk_riskexposure_gl_operation_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ADD CONSTRAINT `fk_riskexposure_scheduled_equipment_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ADD CONSTRAINT `fk_riskexposure_scheduled_equipment_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ADD CONSTRAINT `fk_riskexposure_experience_mod_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ADD CONSTRAINT `fk_riskexposure_experience_mod_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ADD CONSTRAINT `fk_riskexposure_experience_mod_superseded_by_mod_id` FOREIGN KEY (`superseded_by_mod_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod`(`experience_mod_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ADD CONSTRAINT `fk_riskexposure_sir_retention_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ADD CONSTRAINT `fk_riskexposure_sir_retention_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ADD CONSTRAINT `fk_riskexposure_sir_retention_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_reversed_event_id` FOREIGN KEY (`reversed_event_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event`(`risk_change_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ADD CONSTRAINT `fk_riskexposure_vehicle_claimant_involvement_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ADD CONSTRAINT `fk_riskexposure_location_claimant_interest_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_v499`.`riskexposure` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_v499`.`riskexposure` SET TAGS ('dbx_domain' = 'riskexposure');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Country Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `alarm_type` SET TAGS ('dbx_business_glossary_term' = 'Alarm Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `alarm_type` SET TAGS ('dbx_value_regex' = 'none|local|central_station|direct_to_fire|direct_to_police|combination');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `building_value` SET TAGS ('dbx_business_glossary_term' = 'Building Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `business_income_value` SET TAGS ('dbx_business_glossary_term' = 'Business Income Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `cat_zone` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Zone (CAT Zone)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type (COPE - Construction)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `contents_value` SET TAGS ('dbx_business_glossary_term' = 'Contents Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `county` SET TAGS ('dbx_business_glossary_term' = 'County');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `distance_to_coast_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Coast (Miles)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `distance_to_fire_station_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Fire Station (Miles)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `earthquake_zone` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `earthquake_zone` SET TAGS ('dbx_value_regex' = '^[0-4]$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `flood_zone` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone (FEMA/NFIP Flood Zone)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `flood_zone` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,3}[0-9]{0,2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `geocode_quality` SET TAGS ('dbx_business_glossary_term' = 'Geocode Quality');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `geocode_quality` SET TAGS ('dbx_value_regex' = 'rooftop|parcel|street|zip_centroid|city_centroid|manual');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `itv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value Ratio (ITV Ratio)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude (Geocode)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_code` SET TAGS ('dbx_business_glossary_term' = 'Location Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{2,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_name` SET TAGS ('dbx_business_glossary_term' = 'Location Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_name` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_status` SET TAGS ('dbx_business_glossary_term' = 'Location Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|cancelled|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_type` SET TAGS ('dbx_business_glossary_term' = 'Location Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `location_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|storage|temporary|mobile|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude (Geocode)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System Code (NAICS Code)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^d{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type (COPE - Occupancy)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code (ZIP Code)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^d{5}(-d{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class (COPE - Protection)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `protection_class` SET TAGS ('dbx_value_regex' = '^(1[0]?|[1-9]|10W?)$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `roof_material` SET TAGS ('dbx_business_glossary_term' = 'Roof Material');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `roof_type` SET TAGS ('dbx_business_glossary_term' = 'Roof Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `roof_year` SET TAGS ('dbx_business_glossary_term' = 'Roof Year (Year Roof Last Replaced)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification Code (SIC Code)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^d{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `sprinkler_type` SET TAGS ('dbx_business_glossary_term' = 'Sprinkler Type (COPE - Protection)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `sprinkler_type` SET TAGS ('dbx_value_regex' = 'none|wet_pipe|dry_pipe|pre_action|deluge|partial');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `total_area_sqft` SET TAGS ('dbx_business_glossary_term' = 'Total Area (Square Feet)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (RCV/ACV)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'RCV|ACV|agreed_value|functional_replacement');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `wind_pool_eligible` SET TAGS ('dbx_business_glossary_term' = 'Wind Pool Eligible');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `photo_document_id` SET TAGS ('dbx_business_glossary_term' = 'Photo Document ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `actual_cash_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `actual_cash_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `actual_cash_value_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `agreed_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `agreed_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `agreed_value_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `agreed_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Currency (ISO 4217)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `agreed_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `annual_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `annual_premium_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `annual_premium_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraisal_date` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraisal_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraisal_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraisal_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraisal_value_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraiser_certification_number` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Certification Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `blanket_group_code` SET TAGS ('dbx_business_glossary_term' = 'Blanket Group Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `coverage_type` SET TAGS ('dbx_value_regex' = 'scheduled|blanket|floater');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `is_away_from_premises` SET TAGS ('dbx_business_glossary_term' = 'Away From Premises Coverage Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `is_blanket_covered` SET TAGS ('dbx_business_glossary_term' = 'Blanket Coverage Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `iso_class_code` SET TAGS ('dbx_business_glossary_term' = 'ISO Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `iso_class_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_category` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Category');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Item Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_description` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_name` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_number` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{1,30}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_status` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_status` SET TAGS ('dbx_value_regex' = 'active|suspended|removed|expired|pending_appraisal');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `item_type` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `location_description` SET TAGS ('dbx_business_glossary_term' = 'Item Location Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `make` SET TAGS ('dbx_business_glossary_term' = 'Item Make / Manufacturer');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `model` SET TAGS ('dbx_business_glossary_term' = 'Item Model');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `purchase_date` SET TAGS ('dbx_business_glossary_term' = 'Purchase Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `purchase_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Purchase Price Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `purchase_price_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `purchase_price_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `rate_per_hundred` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Hundred (RPP)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `removal_date` SET TAGS ('dbx_business_glossary_term' = 'Item Removal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'Item Removal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `replacement_cost_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Replacement Cost Value (RCV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `replacement_cost_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `replacement_cost_value_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `serial_number` SET TAGS ('dbx_business_glossary_term' = 'Item Serial Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `serial_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `storage_type` SET TAGS ('dbx_business_glossary_term' = 'Storage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `storage_type` SET TAGS ('dbx_value_regex' = 'home|bank_vault|safe_deposit_box|commercial_storage|on_person|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `storage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `storage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_business_glossary_term' = 'Valuation Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_value_regex' = 'agreed_value|replacement_cost|actual_cash_value|stated_amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ALTER COLUMN `year_manufactured` SET TAGS ('dbx_business_glossary_term' = 'Year Manufactured');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `actual_cash_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_business_glossary_term' = 'Annual Mileage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `anti_theft_device` SET TAGS ('dbx_business_glossary_term' = 'Anti-Theft Device');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `body_type` SET TAGS ('dbx_business_glossary_term' = 'Body Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `collision_symbol` SET TAGS ('dbx_business_glossary_term' = 'Collision Coverage Symbol');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `comp_symbol` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Coverage Symbol');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Garaging Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Garaging Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_city` SET TAGS ('dbx_business_glossary_term' = 'Garaging City');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_country_code` SET TAGS ('dbx_business_glossary_term' = 'Garaging Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_county` SET TAGS ('dbx_business_glossary_term' = 'Garaging County');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Garaging Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_state_code` SET TAGS ('dbx_business_glossary_term' = 'Garaging State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_state_code` SET TAGS ('dbx_pii_category' = 'general');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `garaging_state_code` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `is_rideshare_vehicle` SET TAGS ('dbx_business_glossary_term' = 'Rideshare Vehicle Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `is_salvage_title` SET TAGS ('dbx_business_glossary_term' = 'Salvage Title Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `is_salvage_title` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `is_salvage_title` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `license_plate_number` SET TAGS ('dbx_business_glossary_term' = 'License Plate Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `license_plate_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `license_plate_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `license_plate_state` SET TAGS ('dbx_business_glossary_term' = 'License Plate State');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `license_plate_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `lienholder_address` SET TAGS ('dbx_business_glossary_term' = 'Lienholder Address');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `lienholder_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `lienholder_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `lienholder_name` SET TAGS ('dbx_business_glossary_term' = 'Lienholder Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `lienholder_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `lienholder_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `loan_lease_indicator` SET TAGS ('dbx_business_glossary_term' = 'Loan Lease Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `loan_lease_indicator` SET TAGS ('dbx_value_regex' = 'owned|financed|leased');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `make` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Make');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `model` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `odometer_reading` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `purchase_date` SET TAGS ('dbx_business_glossary_term' = 'Purchase Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `purchase_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Purchase Price Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `removal_date` SET TAGS ('dbx_business_glossary_term' = 'Removal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'Removal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `removal_reason` SET TAGS ('dbx_value_regex' = 'sold|totaled|replaced|transferred|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `safety_features` SET TAGS ('dbx_business_glossary_term' = 'Safety Features');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `stated_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Stated Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vehicle_number` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vehicle_status` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vehicle_status` SET TAGS ('dbx_value_regex' = 'active|suspended|deleted|pending|replaced');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vehicle_symbol` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Symbol');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vehicle_type` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vehicle_type` SET TAGS ('dbx_value_regex' = 'private_passenger|commercial|motorcycle|trailer|recreational');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vehicle_use` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Use');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vehicle_use` SET TAGS ('dbx_value_regex' = 'pleasure|commute|business|farm|artisan');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vin` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `vin` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ALTER COLUMN `year` SET TAGS ('dbx_business_glossary_term' = 'Model Year');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `parent_entity_insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Entity Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `annual_revenue_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `annual_revenue_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Credit Score');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `entity_number` SET TAGS ('dbx_business_glossary_term' = 'Entity Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `entity_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `entity_status` SET TAGS ('dbx_business_glossary_term' = 'Entity Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `entity_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|dissolved|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Entity Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'individual|sole_proprietor|partnership|llc|corporation|non_profit');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `fein` SET TAGS ('dbx_business_glossary_term' = 'Federal Employer Identification Number (FEIN)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `fein` SET TAGS ('dbx_value_regex' = '^[0-9]{2}-[0-9]{7}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `fein` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `fein` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `is_subsidiary` SET TAGS ('dbx_business_glossary_term' = 'Is Subsidiary Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `loss_free_years` SET TAGS ('dbx_business_glossary_term' = 'Loss-Free Years');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 1');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Mailing Address Line 2');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_city` SET TAGS ('dbx_business_glossary_term' = 'Mailing City');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_country_code` SET TAGS ('dbx_business_glossary_term' = 'Mailing Country Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Mailing Postal Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_state_code` SET TAGS ('dbx_business_glossary_term' = 'Mailing State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_state_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_state_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `mailing_state_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `number_of_employees` SET TAGS ('dbx_business_glossary_term' = 'Number of Employees');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_contact_title` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Title');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9]{10,15}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `prior_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `ssn` SET TAGS ('dbx_business_glossary_term' = 'Social Security Number (SSN)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `ssn` SET TAGS ('dbx_value_regex' = '^[0-9]{3}-[0-9]{2}-[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `ssn` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `ssn` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `uw_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `uw_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Website Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity` ALTER COLUMN `years_in_business` SET TAGS ('dbx_business_glossary_term' = 'Years in Business');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `scheduled_equipment_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Equipment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `added_date` SET TAGS ('dbx_business_glossary_term' = 'Added Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `annual_premium` SET TAGS ('dbx_business_glossary_term' = 'Annual Premium');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `cat_zone` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `earthquake_zone` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `exposure_base` SET TAGS ('dbx_business_glossary_term' = 'Exposure Base');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `exposure_quantity` SET TAGS ('dbx_business_glossary_term' = 'Exposure Quantity');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `flood_zone` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `risk_unit_name` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `risk_unit_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `risk_unit_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `number_of_employees` SET TAGS ('dbx_business_glossary_term' = 'Number of Employees');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `payroll_amount` SET TAGS ('dbx_business_glossary_term' = 'Payroll Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `payroll_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `pml` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `rate_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Unit');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'Removal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `removed_date` SET TAGS ('dbx_business_glossary_term' = 'Removed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `risk_unit_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `risk_unit_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|deleted|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `risk_unit_type` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `si` SET TAGS ('dbx_business_glossary_term' = 'Sum Insured (SI)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'rcv|acv|agreed_value|market_value|functional_replacement');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `wind_pool_eligible` SET TAGS ('dbx_business_glossary_term' = 'Wind Pool Eligible');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `base_flood_elevation_ft` SET TAGS ('dbx_business_glossary_term' = 'Base Flood Elevation (BFE) in Feet');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `cat_loading_factor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Loading Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `cat_model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Vendor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `cat_model_version` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Model Version');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `county_fips_code` SET TAGS ('dbx_business_glossary_term' = 'County Federal Information Processing Standards (FIPS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `county_fips_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `distance_to_coast_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Coast in Miles');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `earthquake_magnitude_scale` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Magnitude Scale');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `fema_flood_zone_code` SET TAGS ('dbx_business_glossary_term' = 'Federal Emergency Management Agency (FEMA) Flood Zone Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `fema_flood_zone_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,3}[0-9]{0,2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `firm_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Flood Insurance Rate Map (FIRM) Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `firm_panel_number` SET TAGS ('dbx_business_glossary_term' = 'Flood Insurance Rate Map (FIRM) Panel Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `firm_panel_number` SET TAGS ('dbx_value_regex' = '^[0-9]{10}[A-Z]{1}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `geography_type` SET TAGS ('dbx_business_glossary_term' = 'Geography Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `geography_type` SET TAGS ('dbx_value_regex' = 'county|zip|census_tract|grid_cell|custom_polygon');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `hurricane_wind_speed_mph` SET TAGS ('dbx_business_glossary_term' = 'Hurricane Wind Speed in Miles Per Hour (MPH)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `iso_crpc_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Commercial Risk Public Protection Classification (CRPC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `iso_crpc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `last_updated_date` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `mandatory_flood_purchase_indicator` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Flood Purchase Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `nfip_community_code` SET TAGS ('dbx_business_glossary_term' = 'National Flood Insurance Program (NFIP) Community ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `nfip_community_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `nfip_participation_status` SET TAGS ('dbx_business_glossary_term' = 'National Flood Insurance Program (NFIP) Participation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `nfip_participation_status` SET TAGS ('dbx_value_regex' = 'participating|non_participating|suspended|probation');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `peril_type` SET TAGS ('dbx_business_glossary_term' = 'Peril Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `peril_type` SET TAGS ('dbx_value_regex' = 'hurricane|earthquake|flood|wildfire|hail|tornado');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `pml_tier` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `pml_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4|tier_5');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Return Period in Years');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `wildfire_hazard_severity` SET TAGS ('dbx_business_glossary_term' = 'Wildfire Hazard Severity');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `wildfire_hazard_severity` SET TAGS ('dbx_value_regex' = 'very_high|high|moderate|low');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `wind_pool_eligible` SET TAGS ('dbx_business_glossary_term' = 'Wind Pool Eligible');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zip_code` SET TAGS ('dbx_business_glossary_term' = 'ZIP Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zip_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zip_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zip_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zone_code` SET TAGS ('dbx_business_glossary_term' = 'Zone Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zone_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zone_name` SET TAGS ('dbx_business_glossary_term' = 'Zone Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zone_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zone_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zone_status` SET TAGS ('dbx_business_glossary_term' = 'Zone Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ALTER COLUMN `zone_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|deprecated');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `risk_characteristic_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Characteristic ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `scheduled_equipment_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Equipment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `boolean_value` SET TAGS ('dbx_business_glossary_term' = 'Boolean Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Change Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_category` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Category');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_code` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_data_type` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Data Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_data_type` SET TAGS ('dbx_value_regex' = 'string|numeric|boolean|date|enumeration');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_name` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_value` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `date_value` SET TAGS ('dbx_business_glossary_term' = 'Date Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `is_rating_variable` SET TAGS ('dbx_business_glossary_term' = 'Is Rating Variable');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `is_rating_variable` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `is_rating_variable` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `is_underwriting_factor` SET TAGS ('dbx_business_glossary_term' = 'Is Underwriting Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `is_underwriting_factor` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `is_underwriting_factor` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `iso_class_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `iso_class_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `ncci_class_code` SET TAGS ('dbx_business_glossary_term' = 'National Council on Compensation Insurance (NCCI) Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `ncci_class_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4,5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `numeric_value` SET TAGS ('dbx_business_glossary_term' = 'Numeric Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `rating_impact_factor` SET TAGS ('dbx_business_glossary_term' = 'Rating Impact Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `rating_impact_factor` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `rating_impact_factor` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `source_document_type` SET TAGS ('dbx_business_glossary_term' = 'Source Document Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'verified|unverified|pending_verification|rejected');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `verified_by` SET TAGS ('dbx_business_glossary_term' = 'Verified By');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `exposure_period_id` SET TAGS ('dbx_business_glossary_term' = 'Exposure Period Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `cancellation_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason Code (CANC)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `cat_zone` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `earned_days` SET TAGS ('dbx_business_glossary_term' = 'Earned Days');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `earned_exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Earned Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `earned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Earned Premium (EP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `endorsement_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Endorsement Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_business_glossary_term' = 'Exposure Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `exposure_days` SET TAGS ('dbx_business_glossary_term' = 'Exposure Days');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `exposure_status` SET TAGS ('dbx_business_glossary_term' = 'Exposure Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `exposure_status` SET TAGS ('dbx_value_regex' = 'active|expired|cancelled|suspended|reinstated');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `is_cat_exposed` SET TAGS ('dbx_business_glossary_term' = 'Is Catastrophe (CAT) Exposed');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Exposure Period Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `pro_rata_factor` SET TAGS ('dbx_business_glossary_term' = 'Pro Rata Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `rate_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Unit');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_business_glossary_term' = 'Reinstatement Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'new_business|renewal|endorsement|cancellation|reinstatement');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `unearned_exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Unearned Exposure Units (UEP)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `unearned_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Unearned Premium (UEP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `written_exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Written Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ALTER COLUMN `written_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Written Premium (WP) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` SET TAGS ('dbx_subdomain' = 'underwriting_intelligence');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `uw_survey_id` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Survey ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `report_document_id` SET TAGS ('dbx_business_glossary_term' = 'Report Document ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `completed_date` SET TAGS ('dbx_business_glossary_term' = 'Completed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `conditions_imposed` SET TAGS ('dbx_business_glossary_term' = 'Conditions Imposed');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `cope_construction` SET TAGS ('dbx_business_glossary_term' = 'Construction Occupancy Protection Exposure (COPE) Construction');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `cope_exposure` SET TAGS ('dbx_business_glossary_term' = 'Construction Occupancy Protection Exposure (COPE) Exposure');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `cope_occupancy` SET TAGS ('dbx_business_glossary_term' = 'Construction Occupancy Protection Exposure (COPE) Occupancy');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `cope_protection` SET TAGS ('dbx_business_glossary_term' = 'Construction Occupancy Protection Exposure (COPE) Protection');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Cost Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Cost Currency');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `cost_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Duration Minutes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Findings Summary');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `follow_up_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `follow_up_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `hazards_identified` SET TAGS ('dbx_business_glossary_term' = 'Hazards Identified');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `improvement_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Improvement Deadline Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `inspector_code` SET TAGS ('dbx_business_glossary_term' = 'Inspector ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `inspector_company` SET TAGS ('dbx_business_glossary_term' = 'Inspector Company');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `inspector_name` SET TAGS ('dbx_business_glossary_term' = 'Inspector Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `inspector_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `inspector_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `photos_taken_count` SET TAGS ('dbx_business_glossary_term' = 'Photos Taken Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `premium_impact_percentage` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `premium_impact_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `premium_impact_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `recommended_improvements` SET TAGS ('dbx_business_glossary_term' = 'Recommended Improvements');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `report_url` SET TAGS ('dbx_business_glossary_term' = 'Report Uniform Resource Locator (URL)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `risk_grade` SET TAGS ('dbx_business_glossary_term' = 'Risk Grade');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `risk_grade` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor|unacceptable');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_date` SET TAGS ('dbx_business_glossary_term' = 'Survey Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_method` SET TAGS ('dbx_business_glossary_term' = 'Survey Method');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_method` SET TAGS ('dbx_value_regex' = 'on_site|remote|desktop|hybrid|aerial|drone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_number` SET TAGS ('dbx_business_glossary_term' = 'Survey Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_source` SET TAGS ('dbx_business_glossary_term' = 'Survey Source');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_source` SET TAGS ('dbx_value_regex' = 'internal|iso|third_party|broker|agent|reinsurer');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_status` SET TAGS ('dbx_business_glossary_term' = 'Survey Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_status` SET TAGS ('dbx_value_regex' = 'scheduled|in_progress|completed|cancelled|pending_review|approved');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_time` SET TAGS ('dbx_business_glossary_term' = 'Survey Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `survey_type` SET TAGS ('dbx_business_glossary_term' = 'Survey Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `uw_action` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Action');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `uw_action` SET TAGS ('dbx_value_regex' = 'accept|decline|refer|conditional_accept|request_resuervey');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ALTER COLUMN `uw_action_reason` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Action Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` SET TAGS ('dbx_subdomain' = 'underwriting_intelligence');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `mvr_report_id` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Report ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Driver ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `accident_count` SET TAGS ('dbx_business_glossary_term' = 'Accident Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `at_fault_accident_count` SET TAGS ('dbx_business_glossary_term' = 'At-Fault Accident Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Cost Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Cost Currency');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `cost_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `dui_count` SET TAGS ('dbx_business_glossary_term' = 'Driving Under the Influence (DUI) Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `is_acceptable_for_underwriting` SET TAGS ('dbx_business_glossary_term' = 'Acceptable for Underwriting (UW) Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `is_acceptable_for_underwriting` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `is_acceptable_for_underwriting` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_class` SET TAGS ('dbx_business_glossary_term' = 'Driver License Class');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Driver License Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Driver License Issue Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'Driver License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_state` SET TAGS ('dbx_business_glossary_term' = 'Driver License State Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_status` SET TAGS ('dbx_business_glossary_term' = 'Driver License Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `license_status` SET TAGS ('dbx_value_regex' = 'valid|suspended|revoked|expired|restricted');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `lookback_period_years` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Years');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `major_violation_count` SET TAGS ('dbx_business_glossary_term' = 'Major Violation Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `minor_violation_count` SET TAGS ('dbx_business_glossary_term' = 'Minor Violation Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `mvr_score` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Score');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `mvr_tier` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `mvr_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|substandard|declined');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `not_at_fault_accident_count` SET TAGS ('dbx_business_glossary_term' = 'Not-At-Fault Accident Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `order_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Order Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `ordered_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Ordered By User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `ordered_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `ordered_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `provider_name` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Provider Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `provider_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `provider_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Report Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `report_number` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Report Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'ordered|received|pending|error|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Report Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'standard|comprehensive|instant|certified');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `suspension_count` SET TAGS ('dbx_business_glossary_term' = 'License Suspension Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `underwriter_review_required` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Review Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ALTER COLUMN `violation_count` SET TAGS ('dbx_business_glossary_term' = 'Violation Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` SET TAGS ('dbx_subdomain' = 'underwriting_intelligence');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `clue_report_id` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Party ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `adverse_action_required` SET TAGS ('dbx_business_glossary_term' = 'Adverse Action Required');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `adverse_action_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Adverse Action Sent Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `auto_loss_count` SET TAGS ('dbx_business_glossary_term' = 'Auto Loss Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `catastrophe_loss_indicator` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Loss Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `clue_score` SET TAGS ('dbx_business_glossary_term' = 'CLUE Risk Score');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `clue_score_tier` SET TAGS ('dbx_business_glossary_term' = 'CLUE Score Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `clue_score_tier` SET TAGS ('dbx_value_regex' = 'excellent|good|average|below_average|poor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Report Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `fraud_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fraud Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `lookback_period_years` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Years');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `order_date` SET TAGS ('dbx_business_glossary_term' = 'Report Order Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `prior_carrier_naic_code` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier National Association of Insurance Commissioners (NAIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `prior_carrier_naic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `prior_policy_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `prior_policy_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `property_loss_count` SET TAGS ('dbx_business_glossary_term' = 'Property Loss Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `provider_name` SET TAGS ('dbx_business_glossary_term' = 'CLUE Provider Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `provider_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `provider_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `provider_transaction_code` SET TAGS ('dbx_business_glossary_term' = 'Provider Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Report Received Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `report_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Report Cost Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Generation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `report_number` SET TAGS ('dbx_business_glossary_term' = 'CLUE Report Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'CLUE Report Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'ordered|received|reviewed|expired|error');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'CLUE Report Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'property|auto|combined');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `total_incurred_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Incurred Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `total_loss_count` SET TAGS ('dbx_business_glossary_term' = 'Total Loss Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `underwriter_review_required` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Review Required');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `uw_decision` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `uw_decision` SET TAGS ('dbx_value_regex' = 'approved|declined|referred|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `uw_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ALTER COLUMN `uw_decision_reason` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Decision Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `tiv_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Schedule ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `actual_cash_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `agreed_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `annual_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `appraisal_date` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `appraisal_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Expiry Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `appraisal_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `appraiser_certification_number` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Certification Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `blanket_group_code` SET TAGS ('dbx_business_glossary_term' = 'Blanket Group Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|franchise');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `depreciation_amount` SET TAGS ('dbx_business_glossary_term' = 'Depreciation Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `depreciation_basis` SET TAGS ('dbx_business_glossary_term' = 'Depreciation Basis Method');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `depreciation_basis` SET TAGS ('dbx_value_regex' = 'straight_line|declining_balance|units_of_production|market_based');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `insurance_to_value_ratio` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Ratio');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `is_blanket_covered` SET TAGS ('dbx_business_glossary_term' = 'Is Blanket Covered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `iso_class_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `item_category` SET TAGS ('dbx_business_glossary_term' = 'Item Category');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `item_category` SET TAGS ('dbx_value_regex' = 'building|contents|equipment|business_income|extra_expense|improvements_betterments');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `item_description` SET TAGS ('dbx_business_glossary_term' = 'Item Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `item_sequence` SET TAGS ('dbx_business_glossary_term' = 'Item Sequence Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `item_status` SET TAGS ('dbx_business_glossary_term' = 'Item Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `item_status` SET TAGS ('dbx_value_regex' = 'active|removed|suspended|pending_appraisal');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `item_type` SET TAGS ('dbx_business_glossary_term' = 'Item Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `rate_per_hundred` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Hundred Dollars');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `removal_date` SET TAGS ('dbx_business_glossary_term' = 'Removal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'Removal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `removal_reason` SET TAGS ('dbx_value_regex' = 'sold|disposed|relocated|total_loss|policy_cancellation|coverage_change');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `replacement_cost_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Replacement Cost Value (RCV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `schedule_number` SET TAGS ('dbx_business_glossary_term' = 'Schedule Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `sum_insured_amount` SET TAGS ('dbx_business_glossary_term' = 'Sum Insured (SI) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `sum_insured_currency` SET TAGS ('dbx_business_glossary_term' = 'Sum Insured Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `sum_insured_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'replacement_cost|actual_cash_value|agreed_value|market_value|functional_replacement_cost');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `wc_payroll_class_id` SET TAGS ('dbx_business_glossary_term' = 'Workers Compensation (WC) Payroll Class ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Audit Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'physical|telephone|mail|waived');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `audited_payroll_amount` SET TAGS ('dbx_business_glossary_term' = 'Audited Payroll Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `catastrophe_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Workers Compensation (WC) Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `class_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4,6}[A-Z]?$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `class_description` SET TAGS ('dbx_business_glossary_term' = 'Class Code Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `class_status` SET TAGS ('dbx_business_glossary_term' = 'Class Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `class_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deleted|suspended');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `estimated_annual_payroll` SET TAGS ('dbx_business_glossary_term' = 'Estimated Annual Payroll');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `executive_officer_payroll` SET TAGS ('dbx_business_glossary_term' = 'Executive Officer Payroll');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `experience_mod` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification Factor (Mod)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_business_glossary_term' = 'Exposure Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_value_regex' = 'payroll|sales|units|area|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `final_rate` SET TAGS ('dbx_business_glossary_term' = 'Final Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `full_time_employee_count` SET TAGS ('dbx_business_glossary_term' = 'Full-Time Employee Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `governing_class_indicator` SET TAGS ('dbx_business_glossary_term' = 'Governing Class Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `hazard_group` SET TAGS ('dbx_business_glossary_term' = 'Hazard Group');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `hazard_group` SET TAGS ('dbx_value_regex' = '^[A-H]$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `increased_limits_factor` SET TAGS ('dbx_business_glossary_term' = 'Increased Limits Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `loss_cost` SET TAGS ('dbx_business_glossary_term' = 'Loss Cost');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `loss_cost_multiplier` SET TAGS ('dbx_business_glossary_term' = 'Loss Cost Multiplier (LCM)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `manual_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Manual Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `manual_rate` SET TAGS ('dbx_business_glossary_term' = 'Manual Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `overtime_payroll_amount` SET TAGS ('dbx_business_glossary_term' = 'Overtime Payroll Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `part_time_employee_count` SET TAGS ('dbx_business_glossary_term' = 'Part-Time Employee Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `payroll_amount` SET TAGS ('dbx_business_glossary_term' = 'Payroll Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `payroll_currency` SET TAGS ('dbx_business_glossary_term' = 'Payroll Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `payroll_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `premium_basis_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Basis Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `premium_basis_type` SET TAGS ('dbx_value_regex' = 'per_hundred|flat|minimum|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `schedule_credit_debit` SET TAGS ('dbx_business_glossary_term' = 'Schedule Credit or Debit');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `standard_exception_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Exception Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `subcontractor_payroll_amount` SET TAGS ('dbx_business_glossary_term' = 'Subcontractor Payroll Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ALTER COLUMN `terrorism_rate` SET TAGS ('dbx_business_glossary_term' = 'Terrorism Rate');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Assignment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `accident_count_3yr` SET TAGS ('dbx_business_glossary_term' = 'Accident Count 3 Year');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_business_glossary_term' = 'Annual Mileage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'Assignment Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated|suspended|excluded');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `business_use_indicator` SET TAGS ('dbx_business_glossary_term' = 'Business Use Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `commute_distance_miles` SET TAGS ('dbx_business_glossary_term' = 'Commute Distance Miles');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `commute_frequency` SET TAGS ('dbx_business_glossary_term' = 'Commute Frequency');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `commute_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|occasional|none');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_designation` SET TAGS ('dbx_business_glossary_term' = 'Driver Designation');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_designation` SET TAGS ('dbx_value_regex' = 'principal|occasional|excluded|permissive|named');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Driver License Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_expiration_date` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_expiration_date` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_business_glossary_term' = 'Driver License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_business_glossary_term' = 'Driver License State');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_status` SET TAGS ('dbx_business_glossary_term' = 'Driver License Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_status` SET TAGS ('dbx_value_regex' = 'valid|expired|suspended|revoked|restricted');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_status` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_license_status` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_training_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Driver Training Completion Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `driver_training_completion_indicator` SET TAGS ('dbx_business_glossary_term' = 'Driver Training Completion Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `dui_indicator` SET TAGS ('dbx_business_glossary_term' = 'Driving Under the Influence (DUI) Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `good_student_discount_indicator` SET TAGS ('dbx_business_glossary_term' = 'Good Student Discount Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `mvr_order_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Order Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `mvr_score` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Report (MVR) Score');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `rating_tier` SET TAGS ('dbx_business_glossary_term' = 'Rating Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `rating_tier` SET TAGS ('dbx_value_regex' = 'preferred|standard|non_standard|high_risk');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `rating_tier` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `rating_tier` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `usage_percentage` SET TAGS ('dbx_business_glossary_term' = 'Usage Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `usage_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `usage_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ALTER COLUMN `violation_count_3yr` SET TAGS ('dbx_business_glossary_term' = 'Violation Count 3 Year');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `risk_score_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Score ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `scheduled_equipment_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Equipment Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `adverse_action_required` SET TAGS ('dbx_business_glossary_term' = 'Adverse Action Required Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `cat_zone` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `data_source_count` SET TAGS ('dbx_business_glossary_term' = 'Data Source Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `error_code` SET TAGS ('dbx_business_glossary_term' = 'Error Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `error_message` SET TAGS ('dbx_business_glossary_term' = 'Error Message');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `error_message` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `error_message` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Model Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'Scoring Model Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Scoring Model Vendor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Scoring Model Version');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Override Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_user_code` SET TAGS ('dbx_business_glossary_term' = 'Override User ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `rate_modifier` SET TAGS ('dbx_business_glossary_term' = 'Rate Modifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `request_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Request Reference Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Score Confidence Level');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Score Cost Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Score Cost Currency');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_cost_currency` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Score Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_percentile` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Percentile');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_pull_date` SET TAGS ('dbx_business_glossary_term' = 'Score Pull Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_pull_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Score Pull Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Score Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Score Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_status` SET TAGS ('dbx_value_regex' = 'active|expired|superseded|invalid|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_tier` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Tier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_tier` SET TAGS ('dbx_value_regex' = 'excellent|good|average|below_average|poor|unacceptable');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_type` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_type` SET TAGS ('dbx_value_regex' = 'property|wildfire|credit|auto|liability|catastrophe');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_value` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `uw_action_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Action Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ALTER COLUMN `uw_action_code` SET TAGS ('dbx_value_regex' = 'accept|refer|decline|quote_with_conditions');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `pml_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Estimate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `superseded_by_estimate_pml_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Estimate ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `annual_aggregate_deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Aggregate Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Approved Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `cat_zone_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `confidence_level_percentage` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `confidence_level_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `confidence_level_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `estimate_number` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Estimate Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `estimate_status` SET TAGS ('dbx_business_glossary_term' = 'Estimate Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `estimate_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|approved|rejected|superseded|expired');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `exceedance_probability` SET TAGS ('dbx_business_glossary_term' = 'Exceedance Probability');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `gross_pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `model_run_code` SET TAGS ('dbx_business_glossary_term' = 'Model Run ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `model_run_date` SET TAGS ('dbx_business_glossary_term' = 'Model Run Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe Model Vendor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `model_vendor` SET TAGS ('dbx_value_regex' = 'AIR|RMS|CoreLogic|KCC|Internal');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `net_pml_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Probable Maximum Loss (PML) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `per_occurrence_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `peril_type` SET TAGS ('dbx_business_glossary_term' = 'Peril Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `peril_type` SET TAGS ('dbx_value_regex' = 'earthquake|hurricane|flood|wildfire|tornado|hail');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `pml_percentage` SET TAGS ('dbx_business_glossary_term' = 'Probable Maximum Loss (PML) Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `pml_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `pml_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `reinsurance_structure_applied` SET TAGS ('dbx_business_glossary_term' = 'Reinsurance (RI) Structure Applied');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `reinsurance_structure_applied` SET TAGS ('dbx_value_regex' = 'none|quota_share|excess_of_loss|cat_xl|facultative');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `reinsurance_structure_applied` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `reinsurance_structure_applied` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `review_notes` SET TAGS ('dbx_business_glossary_term' = 'Review Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `scenario_description` SET TAGS ('dbx_business_glossary_term' = 'Scenario Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `scenario_return_period_years` SET TAGS ('dbx_business_glossary_term' = 'Scenario Return Period Years');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `flood_zone_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Assignment Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Assignment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|expired|superseded|pending|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `base_flood_elevation_ft` SET TAGS ('dbx_business_glossary_term' = 'Base Flood Elevation (BFE) in Feet');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `cbrs_unit_code` SET TAGS ('dbx_business_glossary_term' = 'Coastal Barrier Resources System (CBRS) Unit Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `coastal_barrier_system_indicator` SET TAGS ('dbx_business_glossary_term' = 'Coastal Barrier System Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Assignment Comments');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `determination_date` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Determination Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `determination_method` SET TAGS ('dbx_business_glossary_term' = 'Determination Method');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `determination_method` SET TAGS ('dbx_value_regex' = 'automated|manual|life_of_loan|standard');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `determination_number` SET TAGS ('dbx_business_glossary_term' = 'Flood Determination Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `determination_provider` SET TAGS ('dbx_business_glossary_term' = 'Flood Determination Service Provider');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `elevation_certificate_available` SET TAGS ('dbx_business_glossary_term' = 'Elevation Certificate Available');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `elevation_certificate_date` SET TAGS ('dbx_business_glossary_term' = 'Elevation Certificate Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `elevation_difference_ft` SET TAGS ('dbx_business_glossary_term' = 'Elevation Difference in Feet');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `firm_panel_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Flood Insurance Rate Map (FIRM) Panel Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `firm_panel_number` SET TAGS ('dbx_business_glossary_term' = 'Flood Insurance Rate Map (FIRM) Panel Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `firm_panel_revision_date` SET TAGS ('dbx_business_glossary_term' = 'Flood Insurance Rate Map (FIRM) Panel Revision Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `flood_zone_rating_factor` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Rating Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `flood_zone_rating_factor` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `flood_zone_rating_factor` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `grandfathering_eligible_indicator` SET TAGS ('dbx_business_glossary_term' = 'Grandfathering Eligible Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `lender_name` SET TAGS ('dbx_business_glossary_term' = 'Lender Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `lender_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `lender_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `loan_number` SET TAGS ('dbx_business_glossary_term' = 'Loan Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `loan_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `loma_lomr_case_number` SET TAGS ('dbx_business_glossary_term' = 'Letter of Map Amendment (LOMA) or Letter of Map Revision (LOMR) Case Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `loma_lomr_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Letter of Map Amendment (LOMA) or Letter of Map Revision (LOMR) Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `loma_lomr_indicator` SET TAGS ('dbx_business_glossary_term' = 'Letter of Map Amendment (LOMA) or Letter of Map Revision (LOMR) Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `lowest_floor_elevation_ft` SET TAGS ('dbx_business_glossary_term' = 'Lowest Floor Elevation in Feet');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `mandatory_purchase_indicator` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Purchase Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `nfip_community_code` SET TAGS ('dbx_business_glossary_term' = 'National Flood Insurance Program (NFIP) Community Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `nfip_community_name` SET TAGS ('dbx_business_glossary_term' = 'National Flood Insurance Program (NFIP) Community Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `nfip_community_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `nfip_community_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `nfip_participation_status` SET TAGS ('dbx_business_glossary_term' = 'National Flood Insurance Program (NFIP) Participation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `nfip_participation_status` SET TAGS ('dbx_value_regex' = 'participating|suspended|probation|emergency|regular');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `preferred_risk_policy_eligible` SET TAGS ('dbx_business_glossary_term' = 'Preferred Risk Policy (PRP) Eligible');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `redetermination_required_date` SET TAGS ('dbx_business_glossary_term' = 'Redetermination Required Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `sfha_indicator` SET TAGS ('dbx_business_glossary_term' = 'Special Flood Hazard Area (SFHA) Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `surveyor_license_number` SET TAGS ('dbx_business_glossary_term' = 'Surveyor License Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `surveyor_license_number` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `surveyor_license_number` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `surveyor_name` SET TAGS ('dbx_business_glossary_term' = 'Surveyor Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `surveyor_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ALTER COLUMN `surveyor_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `gl_operation_id` SET TAGS ('dbx_business_glossary_term' = 'General Liability (GL) Operation Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `added_date` SET TAGS ('dbx_business_glossary_term' = 'Added Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `annual_payroll_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Payroll Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `annual_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `annual_receipts_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Receipts Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `area_sqft` SET TAGS ('dbx_business_glossary_term' = 'Area Square Feet');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|AUD|MXN');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_business_glossary_term' = 'Exposure Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_value_regex' = 'area|payroll|receipts|units|admissions|per_location');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `hazard_grade` SET TAGS ('dbx_business_glossary_term' = 'Hazard Grade');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `hazard_grade` SET TAGS ('dbx_value_regex' = 'low|moderate|high|severe');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `iso_gl_class_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) General Liability (GL) Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `iso_gl_class_description` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) General Liability (GL) Class Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `number_of_employees` SET TAGS ('dbx_business_glossary_term' = 'Number of Employees');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `number_of_units` SET TAGS ('dbx_business_glossary_term' = 'Number of Units');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_description` SET TAGS ('dbx_business_glossary_term' = 'Operation Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_name` SET TAGS ('dbx_business_glossary_term' = 'Operation Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_number` SET TAGS ('dbx_business_glossary_term' = 'Operation Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_status` SET TAGS ('dbx_business_glossary_term' = 'Operation Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_type` SET TAGS ('dbx_business_glossary_term' = 'Operation Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `operation_type` SET TAGS ('dbx_value_regex' = 'premises|products|completed_operations|contractual|independent_contractors');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `premises_operations_split_pct` SET TAGS ('dbx_business_glossary_term' = 'Premises Operations Split Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `products_completed_ops_split_pct` SET TAGS ('dbx_business_glossary_term' = 'Products and Completed Operations Split Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `rate_per_exposure_unit` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Exposure Unit');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'Removal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `removal_reason` SET TAGS ('dbx_value_regex' = 'discontinued|sold|non_renewal|underwriting|insured_request|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `removed_date` SET TAGS ('dbx_business_glossary_term' = 'Removed Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `subcontractor_receipts_amount` SET TAGS ('dbx_business_glossary_term' = 'Subcontractor Receipts Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `subcontractor_work_indicator` SET TAGS ('dbx_business_glossary_term' = 'Subcontractor Work Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriting (UW) Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ALTER COLUMN `underwriting_notes` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` SET TAGS ('dbx_subdomain' = 'asset_inventory');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `scheduled_equipment_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Equipment ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `acv_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `added_date` SET TAGS ('dbx_business_glossary_term' = 'Equipment Added Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `agreed_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `annual_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `appraisal_date` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `appraisal_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Value Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `blanket_group_code` SET TAGS ('dbx_business_glossary_term' = 'Blanket Group Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `coverage_type` SET TAGS ('dbx_value_regex' = 'blanket|specific|scheduled');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `coverage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|MXN');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Equipment Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_category` SET TAGS ('dbx_business_glossary_term' = 'Equipment Category');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_description` SET TAGS ('dbx_business_glossary_term' = 'Equipment Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_name` SET TAGS ('dbx_business_glossary_term' = 'Equipment Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_status` SET TAGS ('dbx_business_glossary_term' = 'Equipment Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_status` SET TAGS ('dbx_value_regex' = 'active|removed|suspended|pending');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_type` SET TAGS ('dbx_business_glossary_term' = 'Equipment Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `equipment_type` SET TAGS ('dbx_value_regex' = 'contractor_equipment|mobile_equipment|electronic_equipment|medical_equipment|agricultural_equipment|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Equipment Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `is_away_from_premises` SET TAGS ('dbx_business_glossary_term' = 'Is Away From Premises Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `is_blanket_covered` SET TAGS ('dbx_business_glossary_term' = 'Is Blanket Covered Flag');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `iso_class_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `item_number` SET TAGS ('dbx_business_glossary_term' = 'Equipment Item Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `lob_code` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `location_description` SET TAGS ('dbx_business_glossary_term' = 'Equipment Location Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `make` SET TAGS ('dbx_business_glossary_term' = 'Equipment Make');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `model` SET TAGS ('dbx_business_glossary_term' = 'Equipment Model');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `purchase_date` SET TAGS ('dbx_business_glossary_term' = 'Purchase Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `purchase_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Purchase Price Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `rate_per_hundred` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Hundred');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `rcv_amount` SET TAGS ('dbx_business_glossary_term' = 'Replacement Cost Value (RCV) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `removal_date` SET TAGS ('dbx_business_glossary_term' = 'Equipment Removal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'Equipment Removal Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `removal_reason` SET TAGS ('dbx_value_regex' = 'sold|disposed|transferred|total_loss|policy_cancellation|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `serial_number` SET TAGS ('dbx_business_glossary_term' = 'Equipment Serial Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `storage_type` SET TAGS ('dbx_business_glossary_term' = 'Storage Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `storage_type` SET TAGS ('dbx_value_regex' = 'indoor|outdoor|secured_facility|mobile');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `storage_type` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `storage_type` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_business_glossary_term' = 'Valuation Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_value_regex' = 'acv|rcv|agreed_value|stated_amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ALTER COLUMN `year_manufactured` SET TAGS ('dbx_business_glossary_term' = 'Year Manufactured');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `experience_mod_id` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification (EMod) Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `state_id` SET TAGS ('dbx_business_glossary_term' = 'State Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `superseded_by_mod_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Experience Modification (EMod) Identifier');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `actual_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `appeal_date` SET TAGS ('dbx_business_glossary_term' = 'Appeal Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `appeal_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Appeal Resolution Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `appeal_status` SET TAGS ('dbx_business_glossary_term' = 'Appeal Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `appeal_status` SET TAGS ('dbx_value_regex' = 'not_appealed|pending|approved|denied');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `ballast_value` SET TAGS ('dbx_business_glossary_term' = 'Ballast Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `bureau_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Bureau Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `bureau_name` SET TAGS ('dbx_business_glossary_term' = 'Rating Bureau Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `bureau_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `bureau_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `claim_count` SET TAGS ('dbx_business_glossary_term' = 'Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Workers Compensation (WC) or General Liability (GL) Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `credibility_factor` SET TAGS ('dbx_business_glossary_term' = 'Credibility Factor');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `excess_loss_component` SET TAGS ('dbx_business_glossary_term' = 'Excess Loss Component');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `expected_excess_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Expected Excess Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `expected_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Expected Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `expected_primary_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Expected Primary Loss Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `indemnity_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Indemnity Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `interstate_mod_indicator` SET TAGS ('dbx_business_glossary_term' = 'Interstate Modification Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `issued_date` SET TAGS ('dbx_business_glossary_term' = 'Issued Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `medical_only_claim_count` SET TAGS ('dbx_business_glossary_term' = 'Medical Only Claim Count');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `medical_only_claim_count` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `medical_only_claim_count` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `mod_change_reason` SET TAGS ('dbx_business_glossary_term' = 'Modification Change Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `mod_number` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification (EMod) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `mod_status` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `mod_status` SET TAGS ('dbx_value_regex' = 'active|expired|superseded|pending|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `mod_type` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `mod_type` SET TAGS ('dbx_value_regex' = 'workers_compensation|general_liability|schedule_credit|debit|other');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `mod_value` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification (EMod) Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Experience Modification Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `payroll_amount` SET TAGS ('dbx_business_glossary_term' = 'Workers Compensation (WC) Payroll Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `payroll_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `primary_loss_component` SET TAGS ('dbx_business_glossary_term' = 'Primary Loss Component');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `prior_mod_value` SET TAGS ('dbx_business_glossary_term' = 'Prior Experience Modification (EMod) Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `rating_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Period End Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `rating_period_end_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `rating_period_end_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `rating_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Period Start Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `rating_period_start_date` SET TAGS ('dbx_pii_category' = 'sensitive_id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `rating_period_start_date` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `revised_mod_value` SET TAGS ('dbx_business_glossary_term' = 'Revised Experience Modification (EMod) Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ALTER COLUMN `worksheet_number` SET TAGS ('dbx_business_glossary_term' = 'Experience Rating Worksheet Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `sir_retention_id` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Retention ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `policy_coverage_id` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `insured_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Entity Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Administrator Contact Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_contact_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_contact_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_email` SET TAGS ('dbx_business_glossary_term' = 'Administrator Email Address');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_name` SET TAGS ('dbx_business_glossary_term' = 'Program Administrator Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_phone` SET TAGS ('dbx_business_glossary_term' = 'Administrator Phone Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `administrator_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `aggregate_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Limit Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `claims_handling_arrangement` SET TAGS ('dbx_business_glossary_term' = 'Claims Handling Arrangement');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `claims_handling_arrangement` SET TAGS ('dbx_value_regex' = 'insured_handles|carrier_handles|tpa_handles|shared');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `collateral_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Collateral Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `collateral_provider_name` SET TAGS ('dbx_business_glossary_term' = 'Collateral Provider Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `collateral_provider_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `collateral_provider_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'letter_of_credit|cash|surety_bond|trust_fund|none');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `loss_control_services_included` SET TAGS ('dbx_business_glossary_term' = 'Loss Control Services Included Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `loss_fund_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Fund Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `peril_code` SET TAGS ('dbx_business_glossary_term' = 'Peril Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `prior_program_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Program Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Program Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `program_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `program_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `program_number` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Program Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `program_status` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Program Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `program_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|expired|cancelled');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `program_type` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Program Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `program_type` SET TAGS ('dbx_value_regex' = 'sir|large_deductible|self_insured|captive');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `regulatory_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Required Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `regulatory_filing_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `renewal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Renewal Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `retention_basis` SET TAGS ('dbx_business_glossary_term' = 'Retention Basis');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `retention_basis` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|aggregate|per_policy_period');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `sir_amount` SET TAGS ('dbx_business_glossary_term' = 'Self-Insured Retention (SIR) Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `underwriter_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Approval Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` SET TAGS ('dbx_subdomain' = 'peril_assessment');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `risk_change_event_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Change Event ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Location ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Vehicle ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `lob_code_id` SET TAGS ('dbx_business_glossary_term' = 'Lob Code Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `producers_producer_id` SET TAGS ('dbx_business_glossary_term' = 'Producer ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `reversed_event_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Event ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `risk_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `scheduled_item_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Item ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `policy_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Source Transaction ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Approved Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `change_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Change Reason Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `change_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Change Reason Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `change_status` SET TAGS ('dbx_business_glossary_term' = 'Change Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `change_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|applied|reversed');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `change_type` SET TAGS ('dbx_business_glossary_term' = 'Change Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `change_type` SET TAGS ('dbx_value_regex' = 'addition|removal|replacement|modification|upgrade|downgrade');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `changed_attribute_name` SET TAGS ('dbx_business_glossary_term' = 'Changed Attribute Name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `changed_attribute_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `changed_attribute_name` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `class_code` SET TAGS ('dbx_business_glossary_term' = 'Class Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `endorsement_number` SET TAGS ('dbx_business_glossary_term' = 'Endorsement (ENDT) Number');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `is_cat_exposed` SET TAGS ('dbx_business_glossary_term' = 'Is Catastrophe (CAT) Exposed');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `last_modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `new_cat_zone` SET TAGS ('dbx_business_glossary_term' = 'New Catastrophe (CAT) Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `new_exposure_units` SET TAGS ('dbx_business_glossary_term' = 'New Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `new_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'New Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `new_tiv` SET TAGS ('dbx_business_glossary_term' = 'New Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `new_value` SET TAGS ('dbx_business_glossary_term' = 'New Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `prior_cat_zone` SET TAGS ('dbx_business_glossary_term' = 'Prior Catastrophe (CAT) Zone');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `prior_exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Prior Exposure Units');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `prior_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Premium Amount');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `prior_tiv` SET TAGS ('dbx_business_glossary_term' = 'Prior Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `prior_value` SET TAGS ('dbx_business_glossary_term' = 'Prior Value');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `requested_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Reversal Indicator');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `underwriter_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Notes');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` SET TAGS ('dbx_subdomain' = 'underwriting_intelligence');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` SET TAGS ('dbx_association_edges' = 'riskexposure.insured_vehicle,claims.claimant');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `vehicle_claimant_involvement_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Claimant Involvement ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Claimant Involvement - Claimant Id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `insured_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Claimant Involvement - Insured Vehicle Id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `driver_at_time_of_loss` SET TAGS ('dbx_business_glossary_term' = 'Driver at Time of Loss');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `fault_percentage` SET TAGS ('dbx_business_glossary_term' = 'Fault Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `fault_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `fault_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `injury_caused_by_vehicle` SET TAGS ('dbx_business_glossary_term' = 'Injury Caused by Vehicle');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `relationship_to_insured` SET TAGS ('dbx_business_glossary_term' = 'Relationship to Insured');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ALTER COLUMN `vehicle_occupant_position` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Occupant Position');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` SET TAGS ('dbx_subdomain' = 'underwriting_intelligence');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` SET TAGS ('dbx_association_edges' = 'riskexposure.insured_location,claims.claimant');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `location_claimant_interest_id` SET TAGS ('dbx_business_glossary_term' = 'Location Claimant Interest ID');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `claimant_id` SET TAGS ('dbx_business_glossary_term' = 'Location Claimant Interest - Claimant Id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `insured_location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Claimant Interest - Insured Location Id');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `injury_location_description` SET TAGS ('dbx_business_glossary_term' = 'Injury Location Description');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `location_claimant_interest_status` SET TAGS ('dbx_business_glossary_term' = 'Interest Status');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `loss_exposure_percentage` SET TAGS ('dbx_business_glossary_term' = 'Loss Exposure Percentage');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `loss_exposure_percentage` SET TAGS ('dbx_pii_category' = 'demographic');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `loss_exposure_percentage` SET TAGS ('dbx_pii_flag' = 'true');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `property_interest_type` SET TAGS ('dbx_business_glossary_term' = 'Property Interest Type');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `role` SET TAGS ('dbx_business_glossary_term' = 'Claimant Location Role');
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
