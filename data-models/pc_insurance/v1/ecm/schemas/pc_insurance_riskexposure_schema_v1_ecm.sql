-- Schema for Domain: riskexposure | Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:32

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `vibe_pc_insurance_blog_v499`.`riskexposure` COMMENT 'Provisional description for user-specified domain risk_exposure. Awaiting a generated description of what this domain owns.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` (
    `insured_risk_id` BIGINT COMMENT 'Unique identifier for the insured_risk data product (auto-inserted during validation).',
    `geography_id` BIGINT COMMENT 'Foreign key to the geography hierarchy for this risk. Enables aggregation by state, county, city, postal code.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Every insured risk must be classified to a line of business for rating, loss reserving, regulatory reporting (Schedule P), and reinsurance treaty attachment.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term under which this risk is insured.',
    `catastrophe_zone_code` STRING COMMENT 'Catastrophe zone code for this risk. Used in catastrophe exposure aggregation and probable maximum loss modeling.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Coinsurance percentage applicable to this risk. Triggers penalty if insurance-to-value falls below this threshold.',
    `construction_code` STRING COMMENT 'ISO or NAIC construction type code. Part of COPE data for property risks.',
    `created_by_user_code` STRING COMMENT 'User identifier of the person who created this insured risk record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this insured risk record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Standard deductible amount applicable to this risk. May be overridden at coverage level.',
    `deductible_type` STRING COMMENT 'Type of deductible applied to this risk. Determines how the deductible is calculated and applied at claim time.. Valid values are `per_occurrence|per_claim|aggregate|percentage|franchise`',
    `effective_date` DATE COMMENT 'Date when coverage for this insured risk begins. Must fall within the policy term effective period.',
    `expiration_date` DATE COMMENT 'Date when coverage for this insured risk ends. Nullable for open-ended risks. Must not exceed policy term expiration.',
    `exposure_basis` STRING COMMENT 'Unit of measure for rating exposure. Examples: square footage, payroll, sales, number of vehicles, number of employees.',
    `exposure_units` DECIMAL(18,2) COMMENT 'Quantity of exposure units for rating purposes. Used to calculate premium based on rate per unit.',
    `flood_zone_code` STRING COMMENT 'FEMA flood zone designation for this risk. Determines flood coverage eligibility and pricing.',
    `geocode_quality_score` DECIMAL(3,2) COMMENT 'Quality score for the geocoded coordinates, ranging from 0.00 to 1.00. Higher scores indicate more precise geocoding.',
    `hazard_score` DECIMAL(5,2) COMMENT 'Catastrophe hazard score for this risk location. Derived from catastrophe modeling platforms.',
    `inspection_date` DATE COMMENT 'Date when the most recent physical inspection of this risk was completed.',
    `inspection_required_flag` BOOLEAN COMMENT 'Indicates whether a physical inspection is required for this risk before binding or renewal.',
    `inspection_status` STRING COMMENT 'Current status of the inspection requirement for this risk.. Valid values are `not_required|scheduled|completed|failed|waived`',
    `itv_percentage` DECIMAL(5,2) COMMENT 'Ratio of sum insured to total insured value, expressed as percentage. Used to identify underinsurance and apply coinsurance penalties.',
    `latitude` DECIMAL(10,7) COMMENT 'Geocoded latitude coordinate for the risk location. Used in catastrophe modeling and spatial analytics.',
    `longitude` DECIMAL(10,7) COMMENT 'Geocoded longitude coordinate for the risk location. Used in catastrophe modeling and spatial analytics.',
    `modified_by_user_code` STRING COMMENT 'User identifier of the person who last modified this insured risk record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this insured risk record was last modified.',
    `occupancy_code` STRING COMMENT 'ISO or NAIC occupancy classification code. Part of COPE data for property risks.',
    `prior_loss_amount` DECIMAL(18,2) COMMENT 'Total dollar amount of prior losses for this risk or similar risks. Used in underwriting evaluation and pricing.',
    `prior_loss_count` BIGINT COMMENT 'Number of prior losses reported for this risk or similar risks. Used in underwriting evaluation and pricing.',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification or equivalent fire protection grade. Part of COPE data for property risks.',
    `rating_territory_code` STRING COMMENT 'Territory code used for rating and pricing this risk. Links to rating tables and catastrophe zones.',
    `risk_description` STRING COMMENT 'Free-text narrative describing the insured risk. Appears on policy declarations and endorsements.',
    `risk_number` STRING COMMENT 'Business identifier for the insured risk, unique within the policy. Used on declarations pages and endorsements.',
    `risk_score` DECIMAL(5,2) COMMENT 'Underwriting risk score assigned to this insured risk. Higher scores indicate higher risk. Used in pricing and underwriting decisions.',
    `risk_status` STRING COMMENT 'Current lifecycle status of the insured risk within the policy term.. Valid values are `active|suspended|deleted|excluded|pending`',
    `sum_insured_amount` DECIMAL(18,2) COMMENT 'Sum insured representing the policy limit applicable to this risk. May differ from total insured value based on underwriting decisions.',
    `tiv_amount` DECIMAL(18,2) COMMENT 'Total insured value representing the maximum exposure for this risk. Used in catastrophe modeling and aggregate exposure reporting.',
    `tiv_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the total insured value amount.. Valid values are `^[A-Z]{3}$`',
    `underwriter_notes` STRING COMMENT 'Free-text notes recorded by the underwriter regarding this insured risk. May contain risk assessment details and special conditions.',
    `valuation_date` DATE COMMENT 'Date when the insured value was last assessed or updated. Used for insurance-to-value calculations.',
    `valuation_method` STRING COMMENT 'Method used to determine the insured value of the risk. Drives claims settlement basis.. Valid values are `replacement_cost|actual_cash_value|agreed_value|market_value|stated_amount`',
    CONSTRAINT pk_insured_risk PRIMARY KEY(`insured_risk_id`)
) COMMENT 'Supertype master for every insurable object underwritten on a policy. One row per insured risk. Subtypes property_risk and auto_risk extend it via shared PK (explicit subtype FK).';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` (
    `property_risk_id` BIGINT COMMENT 'Unique identifier for the property_risk data product (auto-inserted during validation).',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the parent insured risk supertype record.',
    `line_of_business_id` BIGINT COMMENT 'Foreign key linking to shared.line_of_business. Business justification: Property risks span multiple LOBs (commercial property, homeowners, dwelling fire, inland marine) with distinct ISO forms, rating plans, and state filing requirements.',
    `location_id` BIGINT COMMENT 'Foreign key to the location record where this property risk is situated.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term under which this property risk is insured.',
    `property_owner_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Property underwriting requires direct link to property owner party for title verification, loss payee validation, and insured interest determination.',
    `actual_cash_value` DECIMAL(18,2) COMMENT 'The replacement cost value minus depreciation. Used for certain policy forms and loss settlement.',
    `basement_finish_type` STRING COMMENT 'The level of finish in the basement, if present. Impacts valuation and loss potential.. Valid values are `unfinished|partially_finished|fully_finished|none`',
    `basement_indicator` BOOLEAN COMMENT 'Indicates whether the property has a basement. Impacts flood and water damage risk.',
    `burglar_alarm_indicator` BOOLEAN COMMENT 'Indicates whether the property has a burglar or intrusion alarm system. May provide premium credit.',
    `central_station_monitoring_indicator` BOOLEAN COMMENT 'Indicates whether alarm systems are monitored by a central station. Provides additional premium credit.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'The coinsurance percentage required by the policy form, typically 80%, 90%, or 100%. Used to calculate coinsurance penalties at claim time.',
    `construction_type` STRING COMMENT 'The construction class of the building. Part of COPE attributes. Examples: frame, joisted masonry, non-combustible, masonry non-combustible, modified fire resistive, fire resistive.',
    `cooling_type` STRING COMMENT 'The type of cooling or air conditioning system. Examples: central air, window units, evaporative, none.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this property risk record was first created in the system.',
    `distance_to_fire_hydrant_feet` DECIMAL(8,2) COMMENT 'Distance in feet from the property to the nearest fire hydrant. Impacts protection class and rating.',
    `distance_to_fire_station_miles` DECIMAL(8,2) COMMENT 'Distance in miles from the property to the nearest responding fire station. Impacts protection class and rating.',
    `effective_date` DATE COMMENT 'The date from which this property risk record is effective under the policy term.',
    `electrical_system_type` STRING COMMENT 'The type of electrical system. Examples: circuit breaker, fuse box, knob and tube. Impacts fire risk.',
    `expiration_date` DATE COMMENT 'The date on which this property risk record expires or is no longer in force under the policy term.',
    `exposure_description` STRING COMMENT 'Description of external exposures that may increase risk. Part of COPE attributes. Examples: proximity to brush, adjacent buildings, hazardous operations nearby.',
    `fire_alarm_indicator` BOOLEAN COMMENT 'Indicates whether the property has a fire alarm or smoke detection system. May provide premium credit.',
    `foundation_type` STRING COMMENT 'The type of foundation supporting the structure. Impacts flood and earthquake risk.. Valid values are `slab|crawl_space|basement|pier|piling`',
    `heating_type` STRING COMMENT 'The type of heating system. Examples: forced air, electric, oil, gas, heat pump, wood stove. Impacts fire and equipment breakdown risk.',
    `insurance_to_value_percentage` DECIMAL(5,2) COMMENT 'The ratio of insured value to replacement cost value, expressed as a percentage. Used to assess adequacy of coverage and apply coinsurance penalties.',
    `iso_construction_code` STRING COMMENT 'ISO standard construction classification code used for rating and catastrophe modeling.',
    `number` STRING COMMENT 'Business identifier for the property risk, often used in underwriting and rating systems.',
    `number_of_stories` BIGINT COMMENT 'The number of above-ground stories or floors in the building.',
    `number_of_units` BIGINT COMMENT 'The number of dwelling units or rental units in the property, if applicable for multi-family or commercial properties.',
    `occupancy_type` STRING COMMENT 'The use or occupancy of the property. Part of COPE attributes for underwriting and rating. Examples: owner-occupied, tenant-occupied, retail, office, manufacturing, warehouse.',
    `plumbing_type` STRING COMMENT 'The type of plumbing material. Examples: copper, PVC, galvanized, PEX. Impacts water damage risk.',
    `primary_building_id` BIGINT COMMENT 'Foreign key to the building record if this property risk is a structure.',
    `property_status` STRING COMMENT 'Current lifecycle status of the property risk record within the policy term.. Valid values are `active|inactive|pending|cancelled|expired`',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification or similar fire protection rating. Part of COPE attributes. Lower numbers indicate better fire protection.',
    `replacement_cost_value` DECIMAL(18,2) COMMENT 'The estimated cost to replace the property with materials of like kind and quality at current prices.',
    `roof_shape` STRING COMMENT 'The architectural shape of the roof. Impacts wind resistance and catastrophe modeling.. Valid values are `gable|hip|flat|mansard|gambrel|shed`',
    `roof_type` STRING COMMENT 'The type of roofing material. Examples: asphalt shingle, tile, metal, flat, slate. Impacts wind and hail risk.',
    `roof_year` BIGINT COMMENT 'The year the roof was installed or last replaced. Used for age-based rating and underwriting decisions.',
    `sprinkler_system_indicator` BOOLEAN COMMENT 'Indicates whether the property has an automatic fire sprinkler system. Provides premium credit and reduces fire loss potential.',
    `square_footage` DECIMAL(12,2) COMMENT 'Total square footage of the property. Used for rating, valuation, and catastrophe exposure aggregation.',
    `total_insured_value` DECIMAL(18,2) COMMENT 'The total insured value of the property risk. Used for catastrophe exposure aggregation, reinsurance cession, and PML modeling.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this property risk record was last modified.',
    `valuation_date` DATE COMMENT 'The date on which the property was last valued or appraised.',
    `valuation_method` STRING COMMENT 'The method used to determine the insured value. Examples: appraisal, cost estimator tool, market value, agreed value, stated amount.. Valid values are `appraisal|cost_estimator|market_value|agreed_value|stated_amount`',
    `year_built` BIGINT COMMENT 'The year the property was originally constructed. Used for age-based rating and risk assessment.',
    `year_renovated` BIGINT COMMENT 'The year of the most recent major renovation or remodel, if applicable.',
    CONSTRAINT pk_property_risk PRIMARY KEY(`property_risk_id`)
) COMMENT 'Property-line subtype of insured_risk. One row per property risk. Captures COPE attributes (Construction, Occupancy, Protection, Exposure), ITV, year built, square footage, and ISO construction class for rating and CAT modeling.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` (
    `location_id` BIGINT COMMENT 'Unique identifier for the location data product (auto-inserted during validation).',
    `cat_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.cat_zone. Business justification: Locations require catastrophe zone assignment for real-time accumulation limit monitoring during quoting, underwriting guideline enforcement (moratorium checks), and reinsurance',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this location is insured.',
    `property_risk_id` BIGINT COMMENT 'Reference to the parent property risk entity for this location.',
    `address_line_1` STRING COMMENT 'Primary street address of the insured location. First line of physical address.',
    `address_line_2` STRING COMMENT 'Secondary address information such as suite, unit, or building number.',
    `alarm_type` STRING COMMENT 'Type of fire or burglar alarm system installed at the location. Used for rating credits.. Valid values are `none|local|central_station|proprietary`',
    `building_limit` DECIMAL(15,2) COMMENT 'Coverage limit for the building structure at this location. Part of TIV calculation.',
    `business_income_limit` DECIMAL(15,2) COMMENT 'Coverage limit for business interruption or time element coverage at this location. Part of TIV calculation.',
    `city` STRING COMMENT 'City or municipality where the insured location is situated.',
    `coastal_distance_miles` DECIMAL(8,2) COMMENT 'Distance in miles from the location to the nearest coastline. Used for hurricane and storm surge exposure assessment.',
    `construction_type` STRING COMMENT 'ISO construction class for the primary building at this location. Part of COPE data used for rating and catastrophe modeling.. Valid values are `frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive`',
    `contents_limit` DECIMAL(15,2) COMMENT 'Coverage limit for business personal property and contents at this location. Part of TIV calculation.',
    `country_code` STRING COMMENT 'Three-letter ISO country code for the location. Typically USA for domestic P&C business.. Valid values are `USA|CAN|MEX`',
    `county_name` STRING COMMENT 'County or parish name for the location. Used for regulatory and catastrophe aggregation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this location record was first created in the system. Used for audit and data lineage.',
    `deductible_amount` DECIMAL(12,2) COMMENT 'Standard deductible amount applicable to losses at this location. May be overridden by peril-specific deductibles.',
    `earthquake_deductible_percent` DECIMAL(5,2) COMMENT 'Percentage deductible applied to earthquake losses at this location. Common in seismic zones.',
    `effective_date` DATE COMMENT 'Date this location became effective under the policy. Used for temporal queries and loss date matching.',
    `elevation_feet` DECIMAL(8,2) COMMENT 'Elevation of the location above sea level in feet. Used for flood and storm surge risk modeling.',
    `expiration_date` DATE COMMENT 'Date this location expires or was removed from the policy. Null for currently active locations.',
    `fips_code` STRING COMMENT 'Five-digit FIPS code identifying the county. Used for catastrophe modeling and regulatory reporting.',
    `fire_station_distance_miles` DECIMAL(6,2) COMMENT 'Distance in miles from the location to the nearest fire station. Used for protection class rating.',
    `flood_zone` STRING COMMENT 'FEMA flood zone classification for the location. Determines flood risk and eligibility for NFIP coverage.',
    `geocode_accuracy` STRING COMMENT 'Precision level of the geocoded coordinates. Rooftop is most precise, county is least precise.. Valid values are `rooftop|parcel|street|zip|city|county`',
    `hydrant_distance_feet` DECIMAL(6,2) COMMENT 'Distance in feet from the location to the nearest fire hydrant. Used for protection class rating.',
    `latitude` DECIMAL(10,7) COMMENT 'Geocoded latitude coordinate of the location. Used for catastrophe exposure aggregation and mapping.',
    `location_status` STRING COMMENT 'Current lifecycle status of the location within the policy. Active locations are in force and contribute to exposure.. Valid values are `active|inactive|pending|deleted`',
    `longitude` DECIMAL(10,7) COMMENT 'Geocoded longitude coordinate of the location. Used for catastrophe exposure aggregation and mapping.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this location record was last modified. Used for audit and change tracking.',
    `naics_code` STRING COMMENT 'Six-digit NAICS code describing the business activity at the location. Used for risk classification and underwriting.',
    `location_name` STRING COMMENT 'Business or site name for the insured location. Human-readable label for the property.',
    `number` STRING COMMENT 'Business identifier for the location within the policy. Typically sequential or alphanumeric code assigned by underwriter.',
    `number_of_stories` BIGINT COMMENT 'Total number of above-ground stories in the primary building. Used for catastrophe modeling and underwriting.',
    `occupancy_type` STRING COMMENT 'Primary business or use classification for the location. Part of COPE data used for underwriting and rating.',
    `postal_code` STRING COMMENT 'ZIP or postal code for the insured location. Used for territory rating and catastrophe modeling.',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification or fire protection class for the location. Ranges from 1 best to 10 worst. Part of COPE data.',
    `sic_code` STRING COMMENT 'Four-digit SIC code describing the business activity at the location. Used for risk classification and underwriting.',
    `sprinkler_type` STRING COMMENT 'Type of fire sprinkler system installed at the location. Used for rating credits and underwriting decisions.. Valid values are `none|partial|full_automatic|full_manual`',
    `state_province_code` STRING COMMENT 'Two-letter state or province code for the location. Used for rating and regulatory jurisdiction.',
    `territory_code` STRING COMMENT 'Rating territory code assigned to the location. Used for premium calculation and underwriting rules.',
    `tiv` DECIMAL(15,2) COMMENT 'Total insured value for all property at this location. Sum of building, contents, and business income limits. Used for catastrophe aggregation.',
    `total_area_square_feet` DECIMAL(12,2) COMMENT 'Total building area in square feet for all structures at the location. Used for exposure calculation and rating.',
    `wind_deductible_percent` DECIMAL(5,2) COMMENT 'Percentage deductible applied to wind and hail losses at this location. Common in coastal and high-wind areas.',
    `year_built` BIGINT COMMENT 'Year the primary building at this location was originally constructed. Used for age-based rating and underwriting.',
    `year_renovated` BIGINT COMMENT 'Year of most recent major renovation or update to the building. Used for underwriting and rating adjustments.',
    CONSTRAINT pk_location PRIMARY KEY(`location_id`)
) COMMENT 'Physical address and geocoded site associated with a property risk. One row per insured location. Stores street address, lat/long, FIPS code, territory code, flood zone, and links to geography hierarchy for CAT aggregation.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` (
    `building_id` BIGINT COMMENT 'Unique identifier for the building data product (auto-inserted during validation).',
    `flood_zone_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.flood_zone. Business justification: Buildings require NFIP flood zone determination for mandatory insurance compliance, flood coverage eligibility, and rating.',
    `location_id` BIGINT COMMENT 'Foreign key to the insured location where this building is situated.',
    `property_risk_id` BIGINT COMMENT 'Foreign key to the parent property risk record that this building belongs to.',
    `actual_cash_value` DECIMAL(15,2) COMMENT 'Replacement cost value minus depreciation. Used for certain coverage types and loss settlement.',
    `agreed_value_amount` DECIMAL(15,2) COMMENT 'Pre-agreed valuation amount between insurer and insured, if applicable. Used in agreed value policies.',
    `basement_finish_type` STRING COMMENT 'Classification of basement finish: finished, partially finished, unfinished, or none.. Valid values are `finished|partially_finished|unfinished|none`',
    `basement_indicator` BOOLEAN COMMENT 'Indicates whether the building has a basement. True if basement present, false otherwise.',
    `building_status` STRING COMMENT 'Current operational status of the building: active, vacant, under construction, under renovation, or demolished.. Valid values are `active|vacant|under_construction|under_renovation|demolished`',
    `burglar_alarm_indicator` BOOLEAN COMMENT 'Indicates whether the building has a burglar or intrusion alarm system installed. True if present, false otherwise.',
    `central_station_monitoring_indicator` BOOLEAN COMMENT 'Indicates whether fire or burglar alarms are monitored by a central station. True if monitored, false otherwise.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Coinsurance requirement percentage (e.g., 80, 90, 100) that applies to this building. Used for loss settlement calculation.',
    `construction_type` STRING COMMENT 'Building construction classification per ISO standards: frame, joisted masonry, non-combustible, masonry non-combustible, modified fire resistive, or fire resistive.. Valid values are `frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive`',
    `cooling_type` STRING COMMENT 'Primary cooling system type (e.g., central air, window units, evaporative, none). Impacts equipment breakdown risk.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this building record was first created in the source system.',
    `distance_to_fire_hydrant_feet` DECIMAL(8,2) COMMENT 'Distance in feet from the building to the nearest fire hydrant. Used for protection class rating.',
    `distance_to_fire_station_miles` DECIMAL(6,2) COMMENT 'Distance in miles from the building to the nearest responding fire station. Used for protection class rating.',
    `earthquake_retrofit_indicator` BOOLEAN COMMENT 'Indicates whether the building has been retrofitted for earthquake resistance. True if retrofitted, false otherwise.',
    `effective_date` DATE COMMENT 'Date this building record became effective for the policy term. Used for temporal reconstruction of coverage.',
    `electrical_system_year` BIGINT COMMENT 'Calendar year the electrical system was last updated or replaced. Used for age-based risk assessment.',
    `expiration_date` DATE COMMENT 'Date this building record expires or is superseded. Null if currently active. Used for temporal reconstruction.',
    `exterior_wall_material` STRING COMMENT 'Primary material used for exterior walls (e.g., brick, wood siding, vinyl, stucco). Impacts fire and wind rating.',
    `fire_alarm_indicator` BOOLEAN COMMENT 'Indicates whether the building has a fire alarm system installed. True if present, false otherwise.',
    `fire_protection_class` STRING COMMENT 'ISO Public Protection Classification (PPC) code for the building location, ranging from 1 (best) to 10 (worst).',
    `flood_vents_indicator` BOOLEAN COMMENT 'Indicates whether the building has flood vents installed per NFIP (National Flood Insurance Program) standards. True if present, false otherwise.',
    `foundation_type` STRING COMMENT 'Type of building foundation: slab, crawl space, basement, pier, or other. Impacts flood and earthquake risk.. Valid values are `slab|crawl_space|basement|pier|other`',
    `heating_type` STRING COMMENT 'Primary heating system type (e.g., forced air, hot water, electric, steam). Impacts fire and equipment breakdown risk.',
    `hvac_system_year` BIGINT COMMENT 'Calendar year the HVAC system was last updated or replaced. Used for equipment breakdown risk assessment.',
    `iso_building_class` STRING COMMENT 'ISO classification code for the building type used in property rating and underwriting.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this building record was last updated in the source system.',
    `building_name` STRING COMMENT 'Descriptive name or label for the building, if applicable.',
    `number` STRING COMMENT 'Business identifier for the building within the location. Used for rating and underwriting reference.',
    `number_of_stories` BIGINT COMMENT 'Total count of above-ground floors in the building. Used for risk assessment and rating.',
    `number_of_units` BIGINT COMMENT 'Total count of dwelling units or rental units in the building, if applicable (e.g., for apartment buildings).',
    `occupancy_type` STRING COMMENT 'Primary use or occupancy classification of the building per COPE (Construction, Occupancy, Protection, Exposure) framework.',
    `plumbing_system_year` BIGINT COMMENT 'Calendar year the plumbing system was last updated or replaced. Used for water damage risk assessment.',
    `replacement_cost_value` DECIMAL(15,2) COMMENT 'Estimated cost to replace the building with materials of like kind and quality at current prices. Used for coverage limits and ITV (Insurance to Value) calculation.',
    `roof_material` STRING COMMENT 'Primary material used for the roof covering (e.g., asphalt shingle, metal, tile, slate). Impacts wind and hail rating.',
    `roof_type` STRING COMMENT 'Classification of the roof structure: flat, gable, hip, mansard, gambrel, shed, or other. [ENUM-REF-CANDIDATE: flat|gable|hip|mansard|gambrel|shed|other — 7 candidates stripped; promote to reference product]',
    `roof_year` BIGINT COMMENT 'Calendar year the roof was last replaced or substantially renovated. Used for age-based rating adjustments.',
    `sprinkler_indicator` BOOLEAN COMMENT 'Indicates whether the building has an automatic fire sprinkler system installed. True if sprinklered, false otherwise.',
    `sprinkler_type` STRING COMMENT 'Classification of the fire sprinkler system: wet pipe, dry pipe, pre-action, deluge, or none.. Valid values are `wet_pipe|dry_pipe|pre_action|deluge|none`',
    `total_square_footage` DECIMAL(12,2) COMMENT 'Total floor area of the building in square feet. Used for exposure calculation and rating.',
    `vacancy_indicator` BOOLEAN COMMENT 'Indicates whether the building is currently vacant. True if vacant, false if occupied. Impacts underwriting and rating.',
    `vacancy_start_date` DATE COMMENT 'Date the building became vacant, if applicable. Used for vacancy clause enforcement.',
    `wind_mitigation_features` STRING COMMENT 'Description of wind mitigation features present (e.g., hurricane straps, impact-resistant windows, reinforced roof deck). Used for wind rating credits.',
    `year_built` BIGINT COMMENT 'Calendar year the building was originally constructed. Used for age-based rating and underwriting.',
    CONSTRAINT pk_building PRIMARY KEY(`building_id`)
) COMMENT 'Individual structure on an insured location. One row per building. Captures number of stories, roof type, roof year, frame type, sprinkler indicator, replacement cost value, and ISO building class for property rating.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` (
    `auto_risk_id` BIGINT COMMENT 'Unique identifier for the auto_risk data product (auto-inserted during validation).',
    `garaging_address_id` BIGINT COMMENT 'Foreign key to the address where the vehicle is principally garaged, used for territory rating.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the parent insured risk supertype record.',
    `party_id` BIGINT COMMENT 'Foreign key to the party record representing the lienholder or lessor with financial interest in the vehicle.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term under which this auto risk is insured.',
    `primary_driver_id` BIGINT COMMENT 'Foreign key to the driver record designated as the primary operator of this vehicle.',
    `vehicle_id` BIGINT COMMENT 'Foreign key to the vehicle record associated with this auto risk.',
    `actual_cash_value_amount` DECIMAL(15,2) COMMENT 'Estimated actual cash value of the vehicle at policy inception, used for underwriting and claims settlement.',
    `annual_mileage` BIGINT COMMENT 'Estimated annual mileage driven, used as a rating factor for exposure and loss frequency.',
    `anti_theft_device_code` STRING COMMENT 'Code indicating the type of anti-theft device installed, used for premium discounts and underwriting.',
    `business_use_class` STRING COMMENT 'Detailed business use classification code for commercial vehicles, aligned with SIC or NAICS codes.',
    `clue_report_date` DATE COMMENT 'Date the CLUE report was pulled for this vehicle, used for loss history verification.',
    `clue_report_indicator` BOOLEAN COMMENT 'Flag indicating whether a CLUE report was obtained for underwriting this auto risk.',
    `created_by_user` STRING COMMENT 'User identifier of the person or system that created this auto risk record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this auto risk record was first created in the system.',
    `effective_date` DATE COMMENT 'Date this auto risk became effective on the policy term, used for coverage and premium proration.',
    `expiration_date` DATE COMMENT 'Date this auto risk expires or was removed from the policy term, used for coverage and premium proration.',
    `garaging_state` STRING COMMENT 'Two-letter state code where the vehicle is principally garaged, critical for rating and regulatory compliance.',
    `garaging_zip_code` STRING COMMENT 'ZIP or postal code of the garaging location, used for territory and catastrophe exposure rating.',
    `lob` STRING COMMENT 'Line of business classification for the auto risk: Personal Auto Policy, Commercial Auto, Garage, Truckers, or Motor Carrier Safety.. Valid values are `PAP|CA|Garage|Truckers|MCS90`',
    `loss_free_years` BIGINT COMMENT 'Number of consecutive years without a claim on this vehicle, used for experience rating and discounts.',
    `modified_by_user` STRING COMMENT 'User identifier of the person or system that last modified this auto risk record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this auto risk record was last modified in the system.',
    `primary_use` STRING COMMENT 'Primary use classification of the vehicle: pleasure, commuting, business, farm, or artisan, used in rating and underwriting.. Valid values are `Pleasure|Commute|Business|Farm|Artisan`',
    `prior_carrier_name` STRING COMMENT 'Name of the prior insurance carrier for this vehicle, captured for underwriting and continuity verification.',
    `prior_expiration_date` DATE COMMENT 'Expiration date of the prior policy, used to assess continuity of coverage and lapse risk.',
    `prior_policy_number` STRING COMMENT 'Policy number from the prior carrier, used for loss history verification and underwriting.',
    `radius_of_operation` STRING COMMENT 'Geographic radius classification for commercial auto: local, intermediate, or long distance, used in commercial auto rating.. Valid values are `Local|Intermediate|Long Distance`',
    `rate_group` STRING COMMENT 'Carrier-specific rate group classification for the vehicle, used in proprietary rating algorithms.',
    `rating_symbol` STRING COMMENT 'ISO rating symbol assigned to the vehicle based on make, model, and year, used in premium calculation.',
    `risk_number` STRING COMMENT 'Business identifier for the auto risk unit, often displayed on declarations pages and used in rating.',
    `risk_score` DECIMAL(5,2) COMMENT 'Numeric risk score calculated for this auto risk, used in underwriting decisioning and tiering.',
    `risk_status` STRING COMMENT 'Current lifecycle status of the auto risk unit within the policy term.. Valid values are `Active|Suspended|Deleted|Replaced`',
    `safety_feature_code` STRING COMMENT 'Code representing safety features such as airbags, ABS, or electronic stability control, used for rating discounts.',
    `stated_value_amount` DECIMAL(15,2) COMMENT 'Agreed or stated value of the vehicle for valuation purposes, used in classic or specialty auto policies.',
    `territory_code` STRING COMMENT 'ISO or carrier-specific territory code derived from garaging location, used in premium rating.',
    `tiv` DECIMAL(15,2) COMMENT 'Total insured value of the auto risk, representing maximum exposure for catastrophe and reinsurance aggregation.',
    `underwriting_tier` STRING COMMENT 'Underwriting tier assigned to this auto risk based on risk scoring and eligibility rules.. Valid values are `Preferred|Standard|Non-Standard|Assigned Risk`',
    `vehicle_ownership` STRING COMMENT 'Ownership status of the vehicle: owned, leased, financed, or hired, relevant for coverage and loss payee requirements.. Valid values are `Owned|Leased|Financed|Hired`',
    `vehicle_use_description` STRING COMMENT 'Free-text description of the vehicles specific use, captured during underwriting for risk assessment.',
    CONSTRAINT pk_auto_risk PRIMARY KEY(`auto_risk_id`)
) COMMENT 'Auto-line subtype of insured_risk. One row per auto risk unit. Captures garaging state, primary use, annual mileage, radius of operation, and links to vehicle and driver records for PAP and CA rating.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` (
    `vehicle_id` BIGINT COMMENT 'Unique identifier for the vehicle data product (auto-inserted during validation).',
    `garaging_address_id` BIGINT COMMENT 'Foreign key to the address where the vehicle is primarily garaged. Used for territory rating.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term under which this vehicle is insured.',
    `registered_owner_party_id` BIGINT COMMENT 'Foreign key linking to party.party. Business justification: Vehicle registered owner (title holder) is distinct from policyholder (auto_risk.party_id). Underwriting and claims require registered owner for lien verification, total loss settlement, and',
    `abs_indicator` BOOLEAN COMMENT 'Indicates whether the vehicle is equipped with anti-lock braking system. Safety feature for rating.',
    `actual_cash_value` DECIMAL(15,2) COMMENT 'Current market value of the vehicle accounting for depreciation. Used for total loss settlements.',
    `airbag_count` BIGINT COMMENT 'Number of airbags installed in the vehicle. Safety feature used for rating.',
    `annual_mileage` BIGINT COMMENT 'Estimated or actual annual miles driven. Key rating variable for exposure calculation.',
    `anti_theft_device_indicator` BOOLEAN COMMENT 'Indicates whether the vehicle is equipped with an anti-theft device. May qualify for premium discount.',
    `anti_theft_device_type` STRING COMMENT 'Type of anti-theft device installed. Used for discount eligibility and rating.. Valid values are `passive|active|tracking|alarm|immobilizer|none`',
    `auto_risk_id` BIGINT COMMENT 'Foreign key to the parent auto risk record that this vehicle is associated with.',
    `body_type` STRING COMMENT 'Body style or configuration of the vehicle used for rating and classification. [ENUM-REF-CANDIDATE: sedan|coupe|suv|truck|van|wagon|convertible|hatchback — 8 candidates stripped; promote to reference product]',
    `commute_miles` BIGINT COMMENT 'One-way commute distance in miles. Used for rating and risk classification.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the vehicle record was first created in the system.',
    `effective_date` DATE COMMENT 'Date the vehicle coverage became effective on the policy.',
    `engine_size` DECIMAL(5,2) COMMENT 'Engine displacement in liters. Used for vehicle classification and rating.',
    `expiration_date` DATE COMMENT 'Date the vehicle coverage expires or was removed from the policy.',
    `fuel_type` STRING COMMENT 'Type of fuel or power source used by the vehicle. May affect rating and eligibility for green vehicle discounts.. Valid values are `gasoline|diesel|electric|hybrid|plug_in_hybrid|natural_gas`',
    `garaging_zip_code` STRING COMMENT 'ZIP or postal code where the vehicle is primarily garaged. Critical for territory-based rating.. Valid values are `^[0-9]{5}(-[0-9]{4})?$`',
    `gross_vehicle_weight` BIGINT COMMENT 'Maximum loaded weight of the vehicle in pounds. Used for commercial auto classification.',
    `iso_symbol` STRING COMMENT 'ISO vehicle symbol used for rating and premium calculation. Represents vehicle risk classification.',
    `license_plate_number` STRING COMMENT 'Current license plate or registration number assigned to the vehicle.',
    `license_plate_state` STRING COMMENT 'Two-letter state code where the vehicle is registered.. Valid values are `^[A-Z]{2}$`',
    `lienholder_name` STRING COMMENT 'Name of the financial institution or party holding a lien on the vehicle.',
    `make` STRING COMMENT 'Manufacturer or brand of the vehicle (e.g., Ford, Toyota, Honda).',
    `model` STRING COMMENT 'Specific model name or designation of the vehicle (e.g., Camry, F-150, Civic).',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the vehicle record was last modified.',
    `odometer_reading` BIGINT COMMENT 'Current odometer reading in miles. Used for valuation and claims verification.',
    `odometer_reading_date` DATE COMMENT 'Date the odometer reading was recorded.',
    `ownership_type` STRING COMMENT 'Type of ownership arrangement for the vehicle. Affects loss payee and coverage requirements.. Valid values are `owned|leased|financed`',
    `purchase_date` DATE COMMENT 'Date the vehicle was purchased by the current owner.',
    `purchase_price` DECIMAL(15,2) COMMENT 'Original purchase price paid for the vehicle.',
    `registration_expiration_date` DATE COMMENT 'Date the vehicle registration expires. Used for compliance verification.',
    `safety_rating` STRING COMMENT 'NHTSA or IIHS safety rating for the vehicle. Used for underwriting and rating decisions.',
    `salvage_indicator` BOOLEAN COMMENT 'Indicates whether the vehicle has a salvage or rebuilt title. Affects underwriting eligibility and valuation.',
    `seating_capacity` BIGINT COMMENT 'Number of passengers the vehicle is designed to carry. Used for liability rating.',
    `stated_value` DECIMAL(15,2) COMMENT 'Declared or agreed value of the vehicle for insurance purposes. Used for coverage limits and premium calculation.',
    `usage_type` STRING COMMENT 'Primary use classification of the vehicle. Critical rating factor for premium calculation.. Valid values are `personal|business|commercial|farm`',
    `use_description` STRING COMMENT 'Detailed description of how the vehicle is used. Provides additional context for underwriting and rating.',
    `vehicle_status` STRING COMMENT 'Current status of the vehicle on the policy. Tracks lifecycle from addition through removal.. Valid values are `active|inactive|totaled|sold|replaced`',
    `vin` STRING COMMENT '17-character Vehicle Identification Number uniquely identifying the vehicle. Used for rating, underwriting, and claims.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `year` BIGINT COMMENT 'Model year of the vehicle as designated by the manufacturer.',
    CONSTRAINT pk_vehicle PRIMARY KEY(`vehicle_id`)
) COMMENT 'Motor vehicle associated with an auto risk. One row per vehicle. Stores VIN, year, make, model, body type, ISO symbol, stated value, anti-theft device indicator, and safety rating for auto rating and claims.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` (
    `driver_id` BIGINT COMMENT 'Unique identifier for the driver data product (auto-inserted during validation).',
    `party_id` BIGINT COMMENT 'Foreign key to the party record representing this driver as a person.',
    `primary_vehicle_id` BIGINT COMMENT 'Foreign key to the vehicle this driver primarily operates, if applicable.',
    `auto_risk_id` BIGINT COMMENT 'Foreign key to the auto risk this driver is associated with.',
    `age` BIGINT COMMENT 'Current age of the driver in years, calculated from date of birth.',
    `clue_report_order_date` DATE COMMENT 'Date the CLUE report was ordered to review the driver prior claim and loss history.',
    `clue_report_receipt_date` DATE COMMENT 'Date the CLUE report was received and available for underwriting review.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this driver record was first created in the system.',
    `date_of_birth` DATE COMMENT 'Date of birth of the driver, used for age-based rating and eligibility.',
    `defensive_driving_course_date` DATE COMMENT 'Date the driver completed the defensive driving course, if applicable.',
    `defensive_driving_course_indicator` BOOLEAN COMMENT 'Indicates whether the driver has completed an approved defensive driving or driver training course.',
    `driver_type` STRING COMMENT 'Classification of the driver role on the policy: principal operator, additional driver, excluded driver, or occasional operator.. Valid values are `principal|additional|excluded|occasional`',
    `effective_date` DATE COMMENT 'Date this driver record became effective on the policy or auto risk.',
    `excluded_driver_indicator` BOOLEAN COMMENT 'Indicates whether this driver has been formally excluded from coverage under the policy by endorsement.',
    `excluded_driver_reason` STRING COMMENT 'Reason the driver was excluded from coverage, such as poor driving record, unlicensed, or policyholder request.',
    `expiration_date` DATE COMMENT 'Date this driver record expires or is removed from the policy or auto risk. Null if currently active.',
    `gender` STRING COMMENT 'Gender of the driver: M for male, F for female, X for non-binary, U for unknown or not disclosed.. Valid values are `M|F|X|U`',
    `good_student_indicator` BOOLEAN COMMENT 'Indicates whether the driver qualifies for a good student discount based on academic performance.',
    `license_expiration_date` DATE COMMENT 'Date the driver license expires and must be renewed.',
    `license_issue_date` DATE COMMENT 'Date the driver license was originally issued.',
    `license_number` STRING COMMENT 'The driver license number issued by the licensing state or jurisdiction.',
    `license_state` STRING COMMENT 'Two-letter state or jurisdiction code where the driver license was issued.',
    `license_status` STRING COMMENT 'Current status of the driver license: valid, suspended, revoked, expired, or restricted.. Valid values are `valid|suspended|revoked|expired|restricted`',
    `marital_status` STRING COMMENT 'Marital status of the driver, used as a rating factor in personal auto underwriting.. Valid values are `single|married|divorced|widowed|separated`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this driver record was last modified or updated.',
    `mvr_accident_count` BIGINT COMMENT 'Total number of at-fault accidents recorded on the driver MVR within the underwriting review period.',
    `mvr_clean_record_indicator` BOOLEAN COMMENT 'Indicates whether the driver has a clean MVR with no violations, accidents, or suspensions in the review period.',
    `mvr_dui_indicator` BOOLEAN COMMENT 'Indicates whether the driver has a DUI or DWI conviction recorded on the MVR within the review period.',
    `mvr_most_recent_violation_date` DATE COMMENT 'Date of the most recent moving violation recorded on the driver MVR.',
    `mvr_order_date` DATE COMMENT 'Date the Motor Vehicle Record report was ordered from the state DMV or third-party vendor.',
    `mvr_receipt_date` DATE COMMENT 'Date the Motor Vehicle Record report was received and available for underwriting review.',
    `mvr_status` STRING COMMENT 'Current status of the MVR report: ordered, received, clean record, violations found, pending review, or error in retrieval.. Valid values are `ordered|received|clean|violations|pending|error`',
    `mvr_violation_count` BIGINT COMMENT 'Total number of moving violations recorded on the driver MVR within the underwriting review period.',
    `occupation` STRING COMMENT 'The driver occupation or job title, used as a rating factor in some jurisdictions.',
    `occupation_class` STRING COMMENT 'Standardized occupation classification code or category for rating purposes.',
    `rating_tier` STRING COMMENT 'Underwriting tier assigned to the driver based on risk profile: preferred, standard, non-standard, or declined.',
    `relationship_to_named_insured` STRING COMMENT 'The driver relationship to the named insured on the policy: self, spouse, child, parent, sibling, or other.. Valid values are `self|spouse|child|parent|sibling|other`',
    `score` DECIMAL(5,2) COMMENT 'Numeric risk score assigned to the driver based on MVR, CLUE, and other underwriting factors.',
    `sr22_expiration_date` DATE COMMENT 'Date the SR-22 filing requirement expires, if applicable.',
    `sr22_filing_date` DATE COMMENT 'Date the SR-22 certificate was filed with the state, if applicable.',
    `sr22_indicator` BOOLEAN COMMENT 'Indicates whether an SR-22 certificate of financial responsibility filing is required for this driver.',
    `years_licensed` BIGINT COMMENT 'Number of years the driver has held a valid driver license, used for experience-based rating.',
    CONSTRAINT pk_driver PRIMARY KEY(`driver_id`)
) COMMENT 'Licensed operator associated with an auto risk. One row per driver. Captures license number/state, DOB, gender, marital status, years licensed, SR-22 indicator, and MVR order/receipt/status and clean-record fields (absorbed from mvr_report) for auto';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` (
    `driver_violation_id` BIGINT COMMENT 'Unique identifier for the driver violation incident record.',
    `auto_risk_id` BIGINT COMMENT 'Reference to the auto risk or vehicle associated with this incident.',
    `driver_id` BIGINT COMMENT 'Reference to the driver who incurred this violation or loss.',
    `policy_id` BIGINT COMMENT 'Reference to the policy under which this violation or loss was reported.',
    `actual_speed` BIGINT COMMENT 'Actual speed of the vehicle at the time of the incident, in miles per hour.',
    `at_fault_indicator` BOOLEAN COMMENT 'Flag indicating whether the driver was determined to be at fault for the incident.',
    `chargeable_indicator` BOOLEAN COMMENT 'Flag indicating whether this incident is chargeable for underwriting and rating purposes.',
    `conviction_date` DATE COMMENT 'Date when the driver was convicted of the violation, if applicable.',
    `conviction_status` STRING COMMENT 'Legal outcome of the violation: convicted, pending, dismissed, or not guilty.. Valid values are `convicted|pending|dismissed|not_guilty`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this driver violation record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for monetary amounts. Defaults to USD for domestic operations.. Valid values are `USD`',
    `dui_indicator` BOOLEAN COMMENT 'Flag indicating whether the incident involved driving under the influence of alcohol or drugs.',
    `fatality_indicator` BOOLEAN COMMENT 'Flag indicating whether the incident resulted in a fatality.',
    `fault_percentage` DECIMAL(5,2) COMMENT 'Percentage of fault assigned to the driver for the incident, ranging from 0.00 to 100.00.',
    `incident_date` DATE COMMENT 'Date when the violation, accident, or loss occurred.',
    `incident_type` STRING COMMENT 'Classification of the incident: violation, accident, claim, or prior loss.. Valid values are `violation|accident|claim|prior_loss`',
    `injury_indicator` BOOLEAN COMMENT 'Flag indicating whether the incident resulted in bodily injury.',
    `jurisdiction_country` STRING COMMENT 'Three-letter ISO country code where the incident occurred. Defaults to USA for domestic operations.. Valid values are `USA`',
    `jurisdiction_state` STRING COMMENT 'Two-letter state code where the violation or incident occurred.',
    `light_condition` STRING COMMENT 'Lighting condition at the time of the incident: daylight, dusk, dawn, dark, or dark with street lighting.. Valid values are `daylight|dusk|dawn|dark|dark_lighted`',
    `location_description` STRING COMMENT 'Textual description of the location where the incident occurred (e.g., street address, intersection, highway mile marker).',
    `lookback_expiration_date` DATE COMMENT 'Date after which this incident is no longer considered in underwriting or rating lookback periods.',
    `loss_amount` DECIMAL(15,2) COMMENT 'Total dollar amount of the loss or claim associated with this incident.',
    `notes` STRING COMMENT 'Free-form text field for additional notes, comments, or context regarding the incident.',
    `paid_amount` DECIMAL(15,2) COMMENT 'Total dollar amount paid by the insurer for this incident.',
    `points_assessed` BIGINT COMMENT 'Number of points assessed against the driver license for this violation.',
    `rating_impact_points` DECIMAL(5,2) COMMENT 'Numeric points or factor applied to the rating algorithm as a result of this incident.',
    `report_date` DATE COMMENT 'Date when the incident was reported to the insurer or captured in the system.',
    `road_condition` STRING COMMENT 'Road surface condition at the time of the incident: dry, wet, icy, snowy, muddy, or other.. Valid values are `dry|wet|icy|snowy|muddy|other`',
    `severity_level` STRING COMMENT 'Underwriting severity classification of the incident: minor, moderate, major, or severe.. Valid values are `minor|moderate|major|severe`',
    `source_reference_number` STRING COMMENT 'External reference or tracking number from the source system (e.g., MVR report number, CLUE claim number).',
    `speed_limit` BIGINT COMMENT 'Posted speed limit at the location of the incident, in miles per hour.',
    `speeding_indicator` BOOLEAN COMMENT 'Flag indicating whether the incident involved a speeding violation.',
    `underwriting_impact_code` STRING COMMENT 'Internal code representing the underwriting impact or surcharge tier resulting from this incident.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this driver violation record was last updated in the system.',
    `vehicle_vin` STRING COMMENT '17-character Vehicle Identification Number of the vehicle involved in the incident.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `verification_date` DATE COMMENT 'Date when the incident data was verified or last reviewed.',
    `verification_status` STRING COMMENT 'Status of the incident verification process: verified, pending, unverified, or disputed.. Valid values are `verified|pending|unverified|disputed`',
    `violation_code` STRING COMMENT 'Standardized code representing the type of violation per state or NAIC classification.',
    `violation_description` STRING COMMENT 'Detailed narrative description of the violation or incident.',
    `weather_condition` STRING COMMENT 'Weather condition at the time of the incident: clear, rain, snow, fog, ice, wind, or other. [ENUM-REF-CANDIDATE: clear|rain|snow|fog|ice|wind|other — 7 candidates stripped; promote to reference product]',
    CONSTRAINT pk_driver_violation PRIMARY KEY(`driver_violation_id`)
) COMMENT 'Single SSOT for loss, violation, accident, and prior-loss history attached to a driver or insured risk, sourced from CLUE, MVR, or self-reported application data. One row per incident.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` (
    `risk_score_id` BIGINT COMMENT 'Unique identifier for the risk_score data product (auto-inserted during validation).',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk being scored (property, auto, liability exposure).',
    `party_id` BIGINT COMMENT 'User identifier of the underwriter who performed the manual score override.',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy under which this risk is scored.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this scoring occurred.',
    `acceptable_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this risk score falls within acceptable underwriting guidelines.',
    `cat_exposure_score` DECIMAL(10,4) COMMENT 'Component score representing catastrophe exposure risk (hurricane, earthquake, flood, wildfire).',
    `construction_score` DECIMAL(10,4) COMMENT 'Component score based on construction type, materials, and building characteristics.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk score record was first created in the system.',
    `credit_score` DECIMAL(10,4) COMMENT 'Credit-based insurance score component used in risk evaluation where permitted by regulation.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Percentage score indicating the completeness and quality of input data used in risk scoring.',
    `driver_score` DECIMAL(10,4) COMMENT 'Component score for auto risks based on driver characteristics (age, experience, violations, accidents).',
    `effective_date` DATE COMMENT 'Date from which this risk score is effective for underwriting and rating purposes.',
    `expiration_date` DATE COMMENT 'Date when this risk score expires and is no longer valid for underwriting decisions.',
    `hazard_score` DECIMAL(10,4) COMMENT 'Component score representing physical hazard factors (construction, occupancy, protection, exposure).',
    `lob` STRING COMMENT 'Line of business for which this risk score applies (e.g., Personal Auto, Homeowners, Commercial Property, General Liability).',
    `loss_history_score` DECIMAL(10,4) COMMENT 'Component score based on prior loss and claims history for this risk or similar risks.',
    `model_name` STRING COMMENT 'Name of the risk scoring model or algorithm used to generate this score.',
    `model_vendor` STRING COMMENT 'Vendor or provider of the risk scoring model (e.g., ISO, Verisk, internal proprietary).',
    `model_version` STRING COMMENT 'Version identifier of the risk scoring model used, enabling tracking of model changes over time.',
    `moral_hazard_score` DECIMAL(10,4) COMMENT 'Component score representing moral hazard factors (claims history, fraud indicators, financial stability).',
    `occupancy_score` DECIMAL(10,4) COMMENT 'Component score based on occupancy type and usage characteristics of the insured risk.',
    `override_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the system-generated score was manually overridden by an underwriter.',
    `override_reason` STRING COMMENT 'Reason code or description explaining why the risk score was manually overridden.',
    `override_timestamp` TIMESTAMP COMMENT 'Timestamp when the manual score override was performed.',
    `protection_class_score` DECIMAL(10,4) COMMENT 'Component score based on fire protection class and other protective device factors.',
    `referral_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this risk score triggered an underwriting referral for manual review.',
    `referral_reason` STRING COMMENT 'Reason code or description explaining why this risk was referred for underwriting review.',
    `score_confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level or reliability percentage for the calculated risk score.',
    `score_date` DATE COMMENT 'Date when the risk score was calculated and assigned.',
    `score_grade` STRING COMMENT 'Letter grade representation of the risk score for simplified classification and communication.. Valid values are `A+|A|A-|B+|B|B-|C+|C|C-|D|E|F`',
    `score_notes` STRING COMMENT 'Free-text notes or comments regarding the risk score calculation, exceptions, or special considerations.',
    `score_status` STRING COMMENT 'Current status of this risk score record (Active, Superseded, Voided, Archived).. Valid values are `Active|Superseded|Voided|Archived`',
    `score_tier` STRING COMMENT 'Underwriting tier classification based on the risk score (Preferred, Standard, Substandard, Declined).. Valid values are `Preferred|Standard|Substandard|Declined`',
    `score_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the risk score was generated by the rating or underwriting system.',
    `score_type` STRING COMMENT 'Type or purpose of the risk score (Underwriting, Renewal, Endorsement, Reunderwriting, Catastrophe, Credit).. Valid values are `Underwriting|Renewal|Endorsement|Reunderwriting|Catastrophe|Credit`',
    `score_value` DECIMAL(10,4) COMMENT 'Numeric risk score value assigned to the insured risk. Higher values typically indicate higher risk.',
    `territory_score` DECIMAL(10,4) COMMENT 'Component score reflecting geographic territory risk factors (crime, weather, loss frequency).',
    `threshold_exceeded_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the risk score exceeded acceptable underwriting thresholds.',
    `threshold_value` DECIMAL(10,4) COMMENT 'The threshold value against which this risk score was compared for acceptance decisions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk score record was last updated or modified.',
    `vehicle_score` DECIMAL(10,4) COMMENT 'Component score for auto risks based on vehicle characteristics (make, model, year, safety features).',
    CONSTRAINT pk_risk_score PRIMARY KEY(`risk_score_id`)
) COMMENT 'Point-in-time risk score attached to an insured risk for exposure grading. One row per scoring event per risk. Stores score value, model version, score date, component scores, and referral threshold flag.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` (
    `risk_inspection_id` BIGINT COMMENT 'Unique identifier for the risk inspection record. Primary key.',
    `inspector_party_id` BIGINT COMMENT 'Foreign key to the party (individual or organization) who conducted the inspection.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk being inspected (property, building, vehicle, etc.).',
    `policy_id` BIGINT COMMENT 'Foreign key to the policy under which this inspection was conducted.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the specific policy term during which the inspection occurred.',
    `completed_date` DATE COMMENT 'Date the physical or virtual inspection was completed and findings recorded.',
    `construction_type` STRING COMMENT 'Construction classification of the inspected building per COPE framework (frame, masonry, fire-resistive, etc.).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection record was first created in the system.',
    `electrical_condition` STRING COMMENT 'Condition assessment of the electrical system: excellent, good, fair, poor, or hazardous.. Valid values are `excellent|good|fair|poor|hazardous`',
    `exposure_description` STRING COMMENT 'Description of external exposures affecting the risk: proximity to other structures, hazards, or environmental factors.',
    `fire_protection_present` BOOLEAN COMMENT 'Indicates whether fire protection systems (sprinklers, alarms, extinguishers) are present at the location.',
    `fire_protection_type` STRING COMMENT 'Type of fire protection system observed: automatic sprinkler, fire alarm, standpipe, extinguishers, or combination.',
    `hazards_identified` STRING COMMENT 'Summary of hazards or deficiencies identified during the inspection that may increase loss potential.',
    `hvac_condition` STRING COMMENT 'Condition assessment of the heating, ventilation, and air conditioning system.. Valid values are `excellent|good|fair|poor|inoperative`',
    `inspection_method` STRING COMMENT 'Method used to conduct the inspection: on-site physical, desktop review, aerial (drone/satellite), virtual (video), or hybrid.. Valid values are `on_site|desktop|aerial|virtual|hybrid`',
    `inspection_number` STRING COMMENT 'Business identifier for the inspection, often used in correspondence and reporting.',
    `inspection_purpose` STRING COMMENT 'Business reason for the inspection: underwriting risk assessment, loss control, compliance verification, valuation, or post-loss evaluation.',
    `inspection_report_url` STRING COMMENT 'URL or document reference to the full inspection report stored in the document management system.',
    `inspection_status` STRING COMMENT 'Current lifecycle status of the inspection: ordered, scheduled, in progress, completed, cancelled, or deferred.. Valid values are `ordered|scheduled|in_progress|completed|cancelled|deferred`',
    `inspection_type` STRING COMMENT 'Category of inspection: new business underwriting, renewal, mid-term endorsement, loss control, compliance, reinspection, catastrophe, or special request. [ENUM-REF-CANDIDATE',
    `inspection_vendor` STRING COMMENT 'Name of the third-party inspection service provider, if applicable.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the inspected location for mapping and catastrophe modeling.',
    `location_address` STRING COMMENT 'Full street address of the inspected location or property.',
    `location_city` STRING COMMENT 'City where the inspected property or risk is located.',
    `location_country` STRING COMMENT 'Three-letter ISO country code of the inspected location.',
    `location_postal_code` STRING COMMENT 'Postal or ZIP code of the inspected location.',
    `location_state` STRING COMMENT 'State or province code where the inspected property or risk is located.',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the inspected location for mapping and catastrophe modeling.',
    `notes` STRING COMMENT 'Additional notes or observations recorded by the inspector that do not fit structured fields.',
    `occupancy_type` STRING COMMENT 'Primary use or occupancy of the inspected property per COPE framework (residential, commercial, industrial, etc.).',
    `ordered_date` DATE COMMENT 'Date the inspection was requested or ordered by underwriting or claims.',
    `overall_condition` STRING COMMENT 'Inspectors overall assessment of the risk condition: excellent, good, fair, poor, or unacceptable.. Valid values are `excellent|good|fair|poor|unacceptable`',
    `photos_count` BIGINT COMMENT 'Number of photographs taken during the inspection and attached to the report.',
    `plumbing_condition` STRING COMMENT 'Condition assessment of the plumbing system: excellent, good, fair, poor, or hazardous.. Valid values are `excellent|good|fair|poor|hazardous`',
    `protection_class` STRING COMMENT 'Fire protection classification code (ISO PPC or similar) indicating proximity to fire services and water supply.',
    `recommendations` STRING COMMENT 'Inspectors recommendations for risk improvement, hazard mitigation, or underwriting action.',
    `roof_age_years` BIGINT COMMENT 'Estimated age of the roof in years since installation or last replacement.',
    `roof_condition` STRING COMMENT 'Condition assessment of the roof: excellent, good, fair, poor, or needs replacement.. Valid values are `excellent|good|fair|poor|needs_replacement`',
    `roof_type` STRING COMMENT 'Type of roofing material observed: asphalt shingle, metal, tile, flat membrane, etc.',
    `scheduled_date` DATE COMMENT 'Date the inspection appointment was scheduled with the insured or property contact.',
    `security_system_present` BOOLEAN COMMENT 'Indicates whether security systems (burglar alarm, surveillance, access control) are present at the location.',
    `underwriting_action` STRING COMMENT 'Recommended underwriting action based on inspection findings: accept, accept with conditions, decline, refer, or request reinspection.. Valid values are `accept|accept_with_conditions|decline|refer|request_reinspection`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection record was last modified.',
    `valuation_currency` STRING COMMENT 'Three-letter ISO currency code for the valuation estimate.',
    `valuation_estimate` DECIMAL(15,2) COMMENT 'Inspectors estimated replacement cost or insurable value of the property, if applicable.',
    CONSTRAINT pk_risk_inspection PRIMARY KEY(`risk_inspection_id`)
) COMMENT 'Physical or virtual inspection of an insured risk that produces exposure facts of record (condition, hazards, valuation checks). One row per inspection. Stores inspection type, ordered/completed dates, inspector party, findings summary, and recommendation';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` (
    `risk_improvement_id` BIGINT COMMENT 'Unique identifier for the risk improvement condition record.',
    `coverage_id` BIGINT COMMENT 'Foreign key to the specific coverage to which this improvement condition applies, if applicable.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk (property, auto, etc.) to which this improvement condition is attached.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this improvement condition was imposed.',
    `actual_cost_amount` DECIMAL(15,2) COMMENT 'Actual cost incurred by the insured to complete the improvement condition, if reported.',
    `compliance_date` DATE COMMENT 'Date on which the insured completed the improvement condition and compliance was verified.',
    `compliance_method` STRING COMMENT 'Method by which compliance with the improvement condition was verified.. Valid values are `inspection|photo|invoice|certificate|self_attestation`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk improvement condition record was first created in the system.',
    `due_date` DATE COMMENT 'Date by which the improvement condition must be completed to maintain coverage or avoid premium penalty.',
    `estimated_cost_amount` DECIMAL(15,2) COMMENT 'Estimated cost to the insured to complete the improvement condition, used for underwriting and customer communication.',
    `extension_count` BIGINT COMMENT 'Number of times the due date for this improvement condition has been extended.',
    `follow_up_date` DATE COMMENT 'Scheduled date for follow-up action or review of the improvement condition status.',
    `follow_up_required_flag` BOOLEAN COMMENT 'Indicates whether follow-up action is required from underwriting or customer service regarding this improvement condition.',
    `imposed_date` DATE COMMENT 'Date on which the improvement condition was imposed by the underwriter.',
    `improvement_category` STRING COMMENT 'Broad category of the improvement condition based on the risk mitigation area.. Valid values are `fire_protection|security|structural|electrical|plumbing|roofing`',
    `improvement_code` STRING COMMENT 'Standardized code representing the improvement condition, often from ISO or carrier-specific code tables.',
    `improvement_description` STRING COMMENT 'Detailed narrative description of the improvement condition, including specific actions required or recommended.',
    `improvement_number` STRING COMMENT 'Business identifier for the improvement condition, often displayed on declarations page and correspondence.',
    `improvement_status` STRING COMMENT 'Current lifecycle status of the improvement condition tracking workflow.. Valid values are `pending|in_progress|completed|waived|expired|cancelled`',
    `improvement_type` STRING COMMENT 'Classification of the improvement condition: required (mandatory for coverage), recommended (suggested), or optional (voluntary).. Valid values are `required|recommended|optional`',
    `inspection_report_reference` STRING COMMENT 'Reference number or document identifier for the inspection report verifying completion of the improvement condition.',
    `inspector_company` STRING COMMENT 'Name of the inspection company or vendor organization that performed the verification.',
    `inspector_name` STRING COMMENT 'Name of the inspector or third-party vendor who verified completion of the improvement condition.',
    `last_extension_date` DATE COMMENT 'Date of the most recent extension granted for the improvement condition due date.',
    `modified_by` STRING COMMENT 'User identifier or name of the person who last modified this risk improvement condition record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk improvement condition record was last modified.',
    `non_compliance_action` STRING COMMENT 'Action to be taken if the improvement condition is not completed by the due date.. Valid values are `cancel_coverage|non_renew|surcharge|no_action`',
    `notification_sent_date` DATE COMMENT 'Date on which the notification regarding the improvement condition was sent to the insured.',
    `notification_sent_flag` BOOLEAN COMMENT 'Indicates whether a notification regarding the improvement condition has been sent to the insured.',
    `premium_impact_amount` DECIMAL(15,2) COMMENT 'Premium credit or surcharge associated with completion or non-completion of the improvement condition.',
    `premium_impact_type` STRING COMMENT 'Type of premium impact: credit (discount for completion), surcharge (penalty for non-completion), or none.. Valid values are `credit|surcharge|none`',
    `underwriter_notes` STRING COMMENT 'Free-text notes from the underwriter regarding the improvement condition, including rationale, special instructions, or follow-up actions.',
    `verification_date` DATE COMMENT 'Date on which the carrier or underwriter verified completion of the improvement condition.',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the underwriter or manager who approved the waiver of the improvement condition.',
    `waiver_approved_date` DATE COMMENT 'Date on which the waiver of the improvement condition was approved.',
    `waiver_reason` STRING COMMENT 'Explanation for waiving the improvement condition, if applicable, including underwriter justification.',
    `created_by` STRING COMMENT 'User identifier or name of the person who created this risk improvement condition record.',
    CONSTRAINT pk_risk_improvement PRIMARY KEY(`risk_improvement_id`)
) COMMENT 'Required or recommended risk improvement condition attached to an insured risk. One row per improvement item. Captures condition type, due date, compliance date, status, and premium impact for UW condition tracking.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` (
    `exposure_schedule_id` BIGINT COMMENT 'Unique identifier for each scheduled exposure entry. Primary key for the exposure schedule table.',
    `geography_id` BIGINT COMMENT 'Foreign key linking to catastrophegeography.geography. Business justification: Scheduled property values require geographic aggregation for PML calculations, reinsurance treaty bordereaux reporting, and Schedule P regulatory filings.',
    `insured_risk_id` BIGINT COMMENT 'Reference to the underlying insured risk unit (property, vehicle, driver, etc.) covered by this schedule entry.',
    `policy_id` BIGINT COMMENT 'Reference to the parent policy contract under which this scheduled exposure exists.',
    `policy_term_id` BIGINT COMMENT 'Reference to the specific policy term period during which this scheduled exposure is in force.',
    `blanket_group_code` STRING COMMENT 'Identifier grouping multiple schedule entries under a single blanket limit. Null if not part of a blanket arrangement.',
    `blanket_indicator` BOOLEAN COMMENT 'Indicates whether this schedule entry is part of a blanket coverage arrangement covering multiple locations or items under a single limit.',
    `building_number` STRING COMMENT 'Building identifier within a location for property schedules (e.g., Building 1, Warehouse B). Null for non-property schedules.',
    `burglar_alarm_indicator` BOOLEAN COMMENT 'Indicates whether a burglar alarm system is installed at the scheduled location or on the scheduled item.',
    `catastrophe_zone_code` STRING COMMENT 'Catastrophe zone classification for the scheduled location (e.g., hurricane zone, earthquake zone, wildfire zone).',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Coinsurance percentage applicable to this scheduled item (e.g., 80%, 90%, 100%). Null if no coinsurance clause applies.',
    `construction_type` STRING COMMENT 'ISO construction class for scheduled buildings (Frame, Joisted Masonry, Non-Combustible, Masonry Non-Combustible, Modified Fire Resistive, Fire Resistive).. Valid values are `frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this schedule entry record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Deductible amount applicable to this scheduled item. May be a flat dollar amount or percentage of scheduled value.',
    `deductible_type` STRING COMMENT 'Type of deductible applied: Flat dollar amount, Percentage of loss or value, Franchise, or Disappearing deductible.. Valid values are `flat|percentage|franchise|disappearing`',
    `effective_date` DATE COMMENT 'Date when this scheduled exposure entry becomes active and coverage begins.',
    `equipment_serial_number` STRING COMMENT 'Manufacturer serial number for scheduled equipment or machinery. Null for non-equipment schedules.',
    `expiration_date` DATE COMMENT 'Date when this scheduled exposure entry expires and coverage ends. Null indicates open-ended or coterminous with policy term.',
    `exposure_schedule_status` STRING COMMENT 'Current status of this schedule entry: Active (in force), Deleted (removed from schedule), Suspended, Pending (not yet effective), or Expired.. Valid values are `active|deleted|suspended|pending|expired`',
    `fire_alarm_indicator` BOOLEAN COMMENT 'Indicates whether a fire alarm system is installed at the scheduled location or on the scheduled item.',
    `flood_zone_designation` STRING COMMENT 'FEMA flood zone designation for the scheduled location (e.g., A, AE, X, V). Null if not in a flood zone.',
    `line_of_business` STRING COMMENT 'Insurance line of business to which this scheduled exposure applies (e.g., Commercial Property, Commercial Auto, Inland Marine). [ENUM-REF-CANDIDATE',
    `location_number` STRING COMMENT 'Business-assigned location identifier for property schedules (e.g., Location 001, Site A). Null for non-property schedules.',
    `number_of_stories` BIGINT COMMENT 'Number of stories or floors in scheduled building. Null for non-property schedules.',
    `occupancy_code` STRING COMMENT 'ISO or carrier-specific occupancy classification code for the scheduled risk (e.g., manufacturing, retail, office).',
    `premium_basis` STRING COMMENT 'Rating basis used to calculate premium for this scheduled item (e.g., per $100 of value, per vehicle, per square foot, flat charge).',
    `prior_scheduled_value_amount` DECIMAL(18,2) COMMENT 'Previous insured value before the most recent endorsement or change. Null for new entries.',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification (PPC) or fire protection class for the scheduled location (1-10 scale, 1 being best).',
    `rate_per_unit` DECIMAL(12,6) COMMENT 'Premium rate applied per unit of exposure for this scheduled item (e.g., rate per $100 of insured value, rate per vehicle).',
    `remarks` STRING COMMENT 'Free-text remarks or special instructions related to this scheduled exposure entry (e.g., special conditions, underwriting notes).',
    `risk_unit_description` STRING COMMENT 'Business description of the scheduled risk unit (e.g., Main Warehouse Building, 2023 Ford F-150 Fleet Vehicle, CNC Milling Machine).',
    `schedule_entry_number` STRING COMMENT 'Sequential or business-assigned identifier for this entry within the schedule (e.g., Location 001, Vehicle 005).',
    `schedule_type` STRING COMMENT 'Type of exposure schedule: location schedule for commercial property, fleet schedule for commercial auto, equipment schedule, or blanket coverage schedule.. Valid values are `location|vehicle|equipment|building|driver|blanket`',
    `scheduled_premium_amount` DECIMAL(18,2) COMMENT 'Premium amount calculated for this specific scheduled item, before taxes and fees.',
    `scheduled_value_amount` DECIMAL(18,2) COMMENT 'Insured value or limit assigned to this specific scheduled item (e.g., building value, vehicle stated amount, equipment replacement cost).',
    `scheduled_value_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the scheduled value amount (e.g., USD, CAD, EUR).. Valid values are `^[A-Z]{3}$`',
    `sprinkler_type` STRING COMMENT 'Type of automatic sprinkler system installed in scheduled building (None, Automatic Wet, Automatic Dry, Deluge, Pre-Action, Partial).. Valid values are `none|automatic_wet|automatic_dry|deluge|pre_action|partial`',
    `territory_code` STRING COMMENT 'Rating territory code assigned to the scheduled risk location for premium calculation purposes.',
    `total_area_square_feet` DECIMAL(12,2) COMMENT 'Total square footage of scheduled building or facility. Null for non-property schedules.',
    `transaction_effective_date` DATE COMMENT 'Effective date of the policy transaction that created or last modified this schedule entry.',
    `transaction_type` STRING COMMENT 'Type of policy transaction that created or modified this schedule entry (New Business, Endorsement, Renewal, Deletion, Reinstatement).. Valid values are `new|endorsement|renewal|deletion|reinstatement`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this schedule entry record was last modified in the system.',
    `valuation_method` STRING COMMENT 'Method used to determine the insured value: Replacement Cost (RC), Actual Cash Value (ACV), Agreed Value, Stated Amount, or Market Value.. Valid values are `replacement_cost|actual_cash_value|agreed_value|stated_amount|market_value`',
    `vehicle_identification_number` STRING COMMENT '17-character VIN for scheduled vehicles in commercial auto fleet schedules. Null for non-auto schedules.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `year_built` BIGINT COMMENT 'Year of construction for scheduled buildings or year of manufacture for scheduled vehicles/equipment. Null if not applicable.',
    CONSTRAINT pk_exposure_schedule PRIMARY KEY(`exposure_schedule_id`)
) COMMENT 'Scheduled list of insured risks or values attached to a policy term for commercial lines (location schedule, fleet schedule). One row per schedule entry per risk unit. Captures effective/expiration dates, scheduled value, and risk unit reference.';

CREATE OR REPLACE TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` (
    `risk_characteristic_id` BIGINT COMMENT 'Unique identifier for the risk characteristic record. Primary key.',
    `insured_risk_id` BIGINT COMMENT 'Foreign key to the insured risk entity this characteristic describes.',
    `policy_term_id` BIGINT COMMENT 'Foreign key to the policy term during which this characteristic was captured.',
    `alarm_type` STRING COMMENT 'The type of alarm or security system installed at the insured location.. Valid values are `none|local|central_station|direct_fire|direct_police|monitored`',
    `annual_mileage` BIGINT COMMENT 'The estimated annual mileage driven for the insured vehicle.',
    `annual_payroll` DECIMAL(15,2) COMMENT 'The total annual payroll for the insured business location.',
    `annual_revenue` DECIMAL(15,2) COMMENT 'The total annual revenue or sales for the insured business.',
    `business_description` STRING COMMENT 'Free-text description of the business operations or activities at the insured risk location.',
    `characteristic_name` STRING COMMENT 'The name or label of the risk characteristic attribute being captured.',
    `characteristic_status` STRING COMMENT 'The current status of this characteristic record in the system.. Valid values are `active|inactive|superseded|pending_verification`',
    `characteristic_type` STRING COMMENT 'The category or domain of the characteristic being captured. [ENUM-REF-CANDIDATE: physical|operational|financial|occupancy|construction|protection|exposure|business|driver|vehicle|location — 11 candidates stripped; promote to reference product]',
    `characteristic_value` DECIMAL(18,2) COMMENT 'The value of the characteristic attribute for this insured risk.',
    `claims_free_years` BIGINT COMMENT 'The number of consecutive years without a claim for this insured risk.',
    `construction_type` STRING COMMENT 'The construction classification of the building per ISO standards.. Valid values are `frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive`',
    `data_source` STRING COMMENT 'The system or source from which this characteristic was captured.',
    `distance_to_fire_station_miles` DECIMAL(5,2) COMMENT 'The distance in miles from the insured location to the nearest fire station.',
    `distance_to_hydrant_feet` BIGINT COMMENT 'The distance in feet from the insured building to the nearest fire hydrant.',
    `dog_breed` STRING COMMENT 'The breed of dog present at the insured location if applicable.',
    `driver_training_indicator` BOOLEAN COMMENT 'Indicates whether the driver has completed an approved driver training course.',
    `effective_date` DATE COMMENT 'The date from which this characteristic value became effective for the insured risk.',
    `expiration_date` DATE COMMENT 'The date on which this characteristic value ceased to be effective. Null if still current.',
    `foundation_type` STRING COMMENT 'The type of foundation supporting the insured building.',
    `garaging_location` STRING COMMENT 'The type of location where the insured vehicle is regularly parked or garaged.. Valid values are `garage|carport|driveway|street|parking_lot`',
    `good_student_indicator` BOOLEAN COMMENT 'Indicates whether the driver qualifies for a good student discount.',
    `heating_type` STRING COMMENT 'The type of heating system installed in the insured building.',
    `line_of_business` STRING COMMENT 'The insurance line of business this characteristic applies to. [ENUM-REF-CANDIDATE: property|auto|general_liability|workers_comp|commercial_package|homeowners|umbrella|inland_marine|professional_liability — 9 candidates stripped; promote to reference',
    `naics_code` STRING COMMENT 'Six-digit NAICS code classifying the business activity of the insured risk.. Valid values are `^[0-9]{6}$`',
    `notes` STRING COMMENT 'Free-text notes or comments about this risk characteristic.',
    `number_of_employees` BIGINT COMMENT 'The total number of employees at the insured business location.',
    `occupancy_type` STRING COMMENT 'The type of occupancy or use of the insured property or location.',
    `plumbing_type` STRING COMMENT 'The type of plumbing material present in the insured building.. Valid values are `copper|pvc|galvanized|pex|polybutylene|mixed`',
    `pool_indicator` BOOLEAN COMMENT 'Indicates whether the property has a swimming pool present.',
    `prior_insurance_indicator` BOOLEAN COMMENT 'Indicates whether the insured had continuous prior insurance coverage.',
    `protection_class` STRING COMMENT 'ISO Public Protection Classification code indicating fire protection quality.. Valid values are `^[1-9]|10$`',
    `roof_age_years` BIGINT COMMENT 'The age of the roof in years since last replacement or installation.',
    `roof_type` STRING COMMENT 'The type or material of the roof on the insured building.',
    `sic_code` STRING COMMENT 'Four-digit SIC code classifying the business activity of the insured risk.. Valid values are `^[0-9]{4}$`',
    `sprinkler_system_indicator` BOOLEAN COMMENT 'Indicates whether the property has an automatic sprinkler system installed.',
    `square_footage` BIGINT COMMENT 'The total square footage of the insured building or location.',
    `trampoline_indicator` BOOLEAN COMMENT 'Indicates whether the property has a trampoline present.',
    `vehicle_usage_type` STRING COMMENT 'The primary usage classification of the insured vehicle.. Valid values are `personal|business|commercial|farm|pleasure|commute`',
    `verification_date` DATE COMMENT 'The date on which this characteristic value was last verified or confirmed.',
    `verification_method` STRING COMMENT 'The method used to verify or confirm this characteristic value.. Valid values are `inspection|third_party_data|applicant_declaration|agent_verification|photo_review`',
    `wiring_type` STRING COMMENT 'The type of electrical wiring present in the insured building.. Valid values are `copper|aluminum|knob_and_tube|mixed`',
    `year_built` BIGINT COMMENT 'The year the insured building was originally constructed.',
    CONSTRAINT pk_risk_characteristic PRIMARY KEY(`risk_characteristic_id`)
) COMMENT 'Extensible per-risk attribute bag for line-specific characteristics not captured in core subtypes (pool presence, alarm type, business description, SIC/NAICS). One row per characteristic per insured risk. Enables new LOB onboarding without schema rebuild.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ADD CONSTRAINT `fk_riskexposure_location_property_risk_id` FOREIGN KEY (`property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ADD CONSTRAINT `fk_riskexposure_building_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ADD CONSTRAINT `fk_riskexposure_building_property_risk_id` FOREIGN KEY (`property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_primary_driver_id` FOREIGN KEY (`primary_driver_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`(`driver_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ADD CONSTRAINT `fk_riskexposure_driver_primary_vehicle_id` FOREIGN KEY (`primary_vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ADD CONSTRAINT `fk_riskexposure_driver_auto_risk_id` FOREIGN KEY (`auto_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk`(`auto_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ADD CONSTRAINT `fk_riskexposure_driver_violation_auto_risk_id` FOREIGN KEY (`auto_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk`(`auto_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ADD CONSTRAINT `fk_riskexposure_driver_violation_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`(`driver_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ADD CONSTRAINT `fk_riskexposure_risk_improvement_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ADD CONSTRAINT `fk_riskexposure_exposure_schedule_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= TAGS =========
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`riskexposure` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `vibe_pc_insurance_blog_v499`.`riskexposure` SET TAGS ('dbx_domain' = 'riskexposure');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for insured_risk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `catastrophe_zone_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `construction_code` SET TAGS ('dbx_business_glossary_term' = 'Construction Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'per_occurrence|per_claim|aggregate|percentage|franchise');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `exposure_basis` SET TAGS ('dbx_business_glossary_term' = 'Exposure Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `exposure_units` SET TAGS ('dbx_business_glossary_term' = 'Exposure Units');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `flood_zone_code` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `geocode_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Geocode Quality Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `hazard_score` SET TAGS ('dbx_business_glossary_term' = 'Hazard Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `inspection_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Inspection Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `inspection_status` SET TAGS ('dbx_business_glossary_term' = 'Inspection Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `inspection_status` SET TAGS ('dbx_value_regex' = 'not_required|scheduled|completed|failed|waived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `itv_percentage` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `occupancy_code` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `prior_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `prior_loss_count` SET TAGS ('dbx_business_glossary_term' = 'Prior Loss Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `rating_territory_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `risk_description` SET TAGS ('dbx_business_glossary_term' = 'Risk Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `risk_number` SET TAGS ('dbx_business_glossary_term' = 'Risk Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `risk_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `risk_status` SET TAGS ('dbx_value_regex' = 'active|suspended|deleted|excluded|pending');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `sum_insured_amount` SET TAGS ('dbx_business_glossary_term' = 'Sum Insured (SI) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `tiv_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `tiv_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV) Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `tiv_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'replacement_cost|actual_cash_value|agreed_value|market_value|stated_amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `property_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for property_risk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `line_of_business_id` SET TAGS ('dbx_business_glossary_term' = 'Line Of Business Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `property_owner_party_id` SET TAGS ('dbx_business_glossary_term' = 'Property Owner Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `actual_cash_value` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `basement_finish_type` SET TAGS ('dbx_business_glossary_term' = 'Basement Finish Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `basement_finish_type` SET TAGS ('dbx_value_regex' = 'unfinished|partially_finished|fully_finished|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `basement_indicator` SET TAGS ('dbx_business_glossary_term' = 'Basement Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `burglar_alarm_indicator` SET TAGS ('dbx_business_glossary_term' = 'Burglar Alarm Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `central_station_monitoring_indicator` SET TAGS ('dbx_business_glossary_term' = 'Central Station Monitoring Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `cooling_type` SET TAGS ('dbx_business_glossary_term' = 'Cooling Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `distance_to_fire_hydrant_feet` SET TAGS ('dbx_business_glossary_term' = 'Distance to Fire Hydrant (Feet)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `distance_to_fire_station_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Fire Station (Miles)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `electrical_system_type` SET TAGS ('dbx_business_glossary_term' = 'Electrical System Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `exposure_description` SET TAGS ('dbx_business_glossary_term' = 'Exposure Description (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `fire_alarm_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fire Alarm Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `foundation_type` SET TAGS ('dbx_business_glossary_term' = 'Foundation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `foundation_type` SET TAGS ('dbx_value_regex' = 'slab|crawl_space|basement|pier|piling');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `heating_type` SET TAGS ('dbx_business_glossary_term' = 'Heating Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `insurance_to_value_percentage` SET TAGS ('dbx_business_glossary_term' = 'Insurance to Value (ITV) Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `iso_construction_code` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Construction Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Property Risk Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `number_of_units` SET TAGS ('dbx_business_glossary_term' = 'Number of Units');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `plumbing_type` SET TAGS ('dbx_business_glossary_term' = 'Plumbing Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `primary_building_id` SET TAGS ('dbx_business_glossary_term' = 'Building Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `property_status` SET TAGS ('dbx_business_glossary_term' = 'Property Risk Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `property_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|cancelled|expired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `replacement_cost_value` SET TAGS ('dbx_business_glossary_term' = 'Replacement Cost Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `roof_shape` SET TAGS ('dbx_business_glossary_term' = 'Roof Shape');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `roof_shape` SET TAGS ('dbx_value_regex' = 'gable|hip|flat|mansard|gambrel|shed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `roof_type` SET TAGS ('dbx_business_glossary_term' = 'Roof Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `roof_year` SET TAGS ('dbx_business_glossary_term' = 'Roof Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `sprinkler_system_indicator` SET TAGS ('dbx_business_glossary_term' = 'Sprinkler System Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `square_footage` SET TAGS ('dbx_business_glossary_term' = 'Square Footage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `total_insured_value` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'appraisal|cost_estimator|market_value|agreed_value|stated_amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ALTER COLUMN `year_renovated` SET TAGS ('dbx_business_glossary_term' = 'Year Renovated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for location');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `cat_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Cat Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `property_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Property Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `address_line_1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `address_line_2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `alarm_type` SET TAGS ('dbx_business_glossary_term' = 'Alarm System Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `alarm_type` SET TAGS ('dbx_value_regex' = 'none|local|central_station|proprietary');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `building_limit` SET TAGS ('dbx_business_glossary_term' = 'Building Coverage Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `building_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `business_income_limit` SET TAGS ('dbx_business_glossary_term' = 'Business Income Coverage Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `business_income_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `business_income_limit` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `coastal_distance_miles` SET TAGS ('dbx_business_glossary_term' = 'Coastal Distance in Miles');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `contents_limit` SET TAGS ('dbx_business_glossary_term' = 'Contents Coverage Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `contents_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = 'USA|CAN|MEX');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `county_name` SET TAGS ('dbx_business_glossary_term' = 'County Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `county_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `earthquake_deductible_percent` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Deductible Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `elevation_feet` SET TAGS ('dbx_business_glossary_term' = 'Elevation in Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `fips_code` SET TAGS ('dbx_business_glossary_term' = 'Federal Information Processing Standards (FIPS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `fire_station_distance_miles` SET TAGS ('dbx_business_glossary_term' = 'Fire Station Distance in Miles');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `flood_zone` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Designation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `geocode_accuracy` SET TAGS ('dbx_business_glossary_term' = 'Geocode Accuracy Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `geocode_accuracy` SET TAGS ('dbx_value_regex' = 'rooftop|parcel|street|zip|city|county');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `hydrant_distance_feet` SET TAGS ('dbx_business_glossary_term' = 'Fire Hydrant Distance in Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `location_status` SET TAGS ('dbx_business_glossary_term' = 'Location Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `location_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|deleted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `location_name` SET TAGS ('dbx_business_glossary_term' = 'Location Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `location_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Location Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `sprinkler_type` SET TAGS ('dbx_business_glossary_term' = 'Sprinkler System Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `sprinkler_type` SET TAGS ('dbx_value_regex' = 'none|partial|full_automatic|full_manual');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `state_province_code` SET TAGS ('dbx_business_glossary_term' = 'State or Province Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `state_province_code` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `tiv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `total_area_square_feet` SET TAGS ('dbx_business_glossary_term' = 'Total Area in Square Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `wind_deductible_percent` SET TAGS ('dbx_business_glossary_term' = 'Wind Deductible Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ALTER COLUMN `year_renovated` SET TAGS ('dbx_business_glossary_term' = 'Year Renovated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `building_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for building');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `flood_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `location_id` SET TAGS ('dbx_business_glossary_term' = 'Location Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `property_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Property Risk Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `actual_cash_value` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `agreed_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Agreed Value Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `basement_finish_type` SET TAGS ('dbx_business_glossary_term' = 'Basement Finish Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `basement_finish_type` SET TAGS ('dbx_value_regex' = 'finished|partially_finished|unfinished|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `basement_indicator` SET TAGS ('dbx_business_glossary_term' = 'Basement Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `building_status` SET TAGS ('dbx_business_glossary_term' = 'Building Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `building_status` SET TAGS ('dbx_value_regex' = 'active|vacant|under_construction|under_renovation|demolished');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `burglar_alarm_indicator` SET TAGS ('dbx_business_glossary_term' = 'Burglar Alarm Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `central_station_monitoring_indicator` SET TAGS ('dbx_business_glossary_term' = 'Central Station Monitoring Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `cooling_type` SET TAGS ('dbx_business_glossary_term' = 'Cooling Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `distance_to_fire_hydrant_feet` SET TAGS ('dbx_business_glossary_term' = 'Distance to Fire Hydrant (Feet)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `distance_to_fire_station_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Fire Station (Miles)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `earthquake_retrofit_indicator` SET TAGS ('dbx_business_glossary_term' = 'Earthquake Retrofit Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `electrical_system_year` SET TAGS ('dbx_business_glossary_term' = 'Electrical System Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `exterior_wall_material` SET TAGS ('dbx_business_glossary_term' = 'Exterior Wall Material');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `fire_alarm_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fire Alarm Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `fire_protection_class` SET TAGS ('dbx_business_glossary_term' = 'Fire Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `flood_vents_indicator` SET TAGS ('dbx_business_glossary_term' = 'Flood Vents Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `foundation_type` SET TAGS ('dbx_business_glossary_term' = 'Foundation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `foundation_type` SET TAGS ('dbx_value_regex' = 'slab|crawl_space|basement|pier|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `heating_type` SET TAGS ('dbx_business_glossary_term' = 'Heating Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `hvac_system_year` SET TAGS ('dbx_business_glossary_term' = 'Heating, Ventilation, and Air Conditioning (HVAC) System Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `iso_building_class` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Building Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `building_name` SET TAGS ('dbx_business_glossary_term' = 'Building Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `building_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Building Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `number_of_units` SET TAGS ('dbx_business_glossary_term' = 'Number of Units');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `plumbing_system_year` SET TAGS ('dbx_business_glossary_term' = 'Plumbing System Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `replacement_cost_value` SET TAGS ('dbx_business_glossary_term' = 'Replacement Cost Value (RCV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `roof_material` SET TAGS ('dbx_business_glossary_term' = 'Roof Material');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `roof_type` SET TAGS ('dbx_business_glossary_term' = 'Roof Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `roof_year` SET TAGS ('dbx_business_glossary_term' = 'Roof Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `sprinkler_indicator` SET TAGS ('dbx_business_glossary_term' = 'Sprinkler Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `sprinkler_type` SET TAGS ('dbx_business_glossary_term' = 'Sprinkler Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `sprinkler_type` SET TAGS ('dbx_value_regex' = 'wet_pipe|dry_pipe|pre_action|deluge|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `total_square_footage` SET TAGS ('dbx_business_glossary_term' = 'Total Square Footage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `vacancy_indicator` SET TAGS ('dbx_business_glossary_term' = 'Vacancy Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `vacancy_start_date` SET TAGS ('dbx_business_glossary_term' = 'Vacancy Start Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `wind_mitigation_features` SET TAGS ('dbx_business_glossary_term' = 'Wind Mitigation Features');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `auto_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for auto_risk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `garaging_address_id` SET TAGS ('dbx_business_glossary_term' = 'Garaging Address ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `garaging_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `garaging_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Lienholder ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `primary_driver_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Driver ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `actual_cash_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV) Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_business_glossary_term' = 'Annual Mileage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `anti_theft_device_code` SET TAGS ('dbx_business_glossary_term' = 'Anti-Theft Device Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `business_use_class` SET TAGS ('dbx_business_glossary_term' = 'Business Use Classification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `clue_report_date` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `clue_report_indicator` SET TAGS ('dbx_business_glossary_term' = 'CLUE Report Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `garaging_state` SET TAGS ('dbx_business_glossary_term' = 'Garaging State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `garaging_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `garaging_zip_code` SET TAGS ('dbx_business_glossary_term' = 'Garaging ZIP Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `garaging_zip_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `garaging_zip_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `lob` SET TAGS ('dbx_value_regex' = 'PAP|CA|Garage|Truckers|MCS90');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `loss_free_years` SET TAGS ('dbx_business_glossary_term' = 'Loss-Free Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `primary_use` SET TAGS ('dbx_business_glossary_term' = 'Primary Use of Vehicle');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `primary_use` SET TAGS ('dbx_value_regex' = 'Pleasure|Commute|Business|Farm|Artisan');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Carrier Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `prior_carrier_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `prior_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `prior_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Prior Policy Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `radius_of_operation` SET TAGS ('dbx_business_glossary_term' = 'Radius of Operation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `radius_of_operation` SET TAGS ('dbx_value_regex' = 'Local|Intermediate|Long Distance');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `rate_group` SET TAGS ('dbx_business_glossary_term' = 'Rate Group');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `rating_symbol` SET TAGS ('dbx_business_glossary_term' = 'ISO Rating Symbol');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `risk_number` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `risk_status` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `risk_status` SET TAGS ('dbx_value_regex' = 'Active|Suspended|Deleted|Replaced');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `safety_feature_code` SET TAGS ('dbx_business_glossary_term' = 'Safety Feature Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `stated_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Stated Value Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `tiv` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value (TIV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `underwriting_tier` SET TAGS ('dbx_value_regex' = 'Preferred|Standard|Non-Standard|Assigned Risk');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `vehicle_ownership` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `vehicle_ownership` SET TAGS ('dbx_value_regex' = 'Owned|Leased|Financed|Hired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ALTER COLUMN `vehicle_use_description` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Use Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for vehicle');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `garaging_address_id` SET TAGS ('dbx_business_glossary_term' = 'Garaging Address ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `garaging_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `garaging_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `registered_owner_party_id` SET TAGS ('dbx_business_glossary_term' = 'Registered Owner Party Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `abs_indicator` SET TAGS ('dbx_business_glossary_term' = 'Anti-Lock Braking System (ABS) Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `actual_cash_value` SET TAGS ('dbx_business_glossary_term' = 'Actual Cash Value (ACV)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `airbag_count` SET TAGS ('dbx_business_glossary_term' = 'Airbag Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_business_glossary_term' = 'Annual Mileage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `anti_theft_device_indicator` SET TAGS ('dbx_business_glossary_term' = 'Anti-Theft Device Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `anti_theft_device_type` SET TAGS ('dbx_business_glossary_term' = 'Anti-Theft Device Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `anti_theft_device_type` SET TAGS ('dbx_value_regex' = 'passive|active|tracking|alarm|immobilizer|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `auto_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `body_type` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Body Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `commute_miles` SET TAGS ('dbx_business_glossary_term' = 'Commute Miles');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `engine_size` SET TAGS ('dbx_business_glossary_term' = 'Engine Size');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `fuel_type` SET TAGS ('dbx_business_glossary_term' = 'Fuel Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `fuel_type` SET TAGS ('dbx_value_regex' = 'gasoline|diesel|electric|hybrid|plug_in_hybrid|natural_gas');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `garaging_zip_code` SET TAGS ('dbx_business_glossary_term' = 'Garaging ZIP Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `garaging_zip_code` SET TAGS ('dbx_value_regex' = '^[0-9]{5}(-[0-9]{4})?$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `garaging_zip_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `garaging_zip_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `gross_vehicle_weight` SET TAGS ('dbx_business_glossary_term' = 'Gross Vehicle Weight (GVW)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `gross_vehicle_weight` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `iso_symbol` SET TAGS ('dbx_business_glossary_term' = 'Insurance Services Office (ISO) Vehicle Symbol');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `license_plate_number` SET TAGS ('dbx_business_glossary_term' = 'License Plate Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `license_plate_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `license_plate_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `license_plate_state` SET TAGS ('dbx_business_glossary_term' = 'License Plate State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `license_plate_state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `license_plate_state` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `lienholder_name` SET TAGS ('dbx_business_glossary_term' = 'Lienholder Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `lienholder_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `make` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Make');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `model` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `odometer_reading` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `odometer_reading_date` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `ownership_type` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `ownership_type` SET TAGS ('dbx_value_regex' = 'owned|leased|financed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `purchase_date` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Purchase Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `purchase_price` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Purchase Price');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `registration_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Registration Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `safety_rating` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Safety Rating');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `salvage_indicator` SET TAGS ('dbx_business_glossary_term' = 'Salvage Title Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `seating_capacity` SET TAGS ('dbx_business_glossary_term' = 'Seating Capacity');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `stated_value` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Stated Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `usage_type` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Usage Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `usage_type` SET TAGS ('dbx_value_regex' = 'personal|business|commercial|farm');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `use_description` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Use Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `vehicle_status` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `vehicle_status` SET TAGS ('dbx_value_regex' = 'active|inactive|totaled|sold|replaced');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `vin` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `vin` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ALTER COLUMN `year` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model Year');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `driver_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for driver');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `primary_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Vehicle Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `auto_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `age` SET TAGS ('dbx_business_glossary_term' = 'Driver Age');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `age` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `clue_report_order_date` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Order Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `clue_report_receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Comprehensive Loss Underwriting Exchange (CLUE) Report Receipt Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Driver Date of Birth (DOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `defensive_driving_course_date` SET TAGS ('dbx_business_glossary_term' = 'Defensive Driving Course Completion Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `defensive_driving_course_indicator` SET TAGS ('dbx_business_glossary_term' = 'Defensive Driving Course Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `driver_type` SET TAGS ('dbx_business_glossary_term' = 'Driver Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `driver_type` SET TAGS ('dbx_value_regex' = 'principal|additional|excluded|occasional');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Driver Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `excluded_driver_indicator` SET TAGS ('dbx_business_glossary_term' = 'Excluded Driver Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `excluded_driver_reason` SET TAGS ('dbx_business_glossary_term' = 'Excluded Driver Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Driver Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `gender` SET TAGS ('dbx_business_glossary_term' = 'Driver Gender');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `gender` SET TAGS ('dbx_value_regex' = 'M|F|X|U');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `gender` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `gender` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `gender` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `good_student_indicator` SET TAGS ('dbx_business_glossary_term' = 'Good Student Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Driver License Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Driver License Issue Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'Driver License Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_state` SET TAGS ('dbx_business_glossary_term' = 'Driver License State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_state` SET TAGS ('dbx_pii_category' = 'government_id');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_status` SET TAGS ('dbx_business_glossary_term' = 'Driver License Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `license_status` SET TAGS ('dbx_value_regex' = 'valid|suspended|revoked|expired|restricted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `marital_status` SET TAGS ('dbx_business_glossary_term' = 'Driver Marital Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `marital_status` SET TAGS ('dbx_value_regex' = 'single|married|divorced|widowed|separated');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `marital_status` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_accident_count` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Accident Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_clean_record_indicator` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Clean Record Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_dui_indicator` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Driving Under the Influence (DUI) Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_most_recent_violation_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Most Recent Violation Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_order_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Order Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Receipt Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_status` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_status` SET TAGS ('dbx_value_regex' = 'ordered|received|clean|violations|pending|error');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `mvr_violation_count` SET TAGS ('dbx_business_glossary_term' = 'Motor Vehicle Record (MVR) Violation Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `occupation` SET TAGS ('dbx_business_glossary_term' = 'Driver Occupation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `occupation` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `occupation_class` SET TAGS ('dbx_business_glossary_term' = 'Driver Occupation Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `occupation_class` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `rating_tier` SET TAGS ('dbx_business_glossary_term' = 'Driver Rating Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `relationship_to_named_insured` SET TAGS ('dbx_business_glossary_term' = 'Relationship to Named Insured');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `relationship_to_named_insured` SET TAGS ('dbx_value_regex' = 'self|spouse|child|parent|sibling|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `score` SET TAGS ('dbx_business_glossary_term' = 'Driver Risk Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `sr22_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'SR-22 Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `sr22_filing_date` SET TAGS ('dbx_business_glossary_term' = 'SR-22 Filing Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `sr22_indicator` SET TAGS ('dbx_business_glossary_term' = 'SR-22 Filing Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ALTER COLUMN `years_licensed` SET TAGS ('dbx_business_glossary_term' = 'Years Licensed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` SET TAGS ('dbx_subdomain' = 'exposure_assessment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `driver_violation_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Violation Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `auto_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Auto Risk Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `driver_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `actual_speed` SET TAGS ('dbx_business_glossary_term' = 'Actual Speed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `at_fault_indicator` SET TAGS ('dbx_business_glossary_term' = 'At-Fault Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `chargeable_indicator` SET TAGS ('dbx_business_glossary_term' = 'Chargeable Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `conviction_date` SET TAGS ('dbx_business_glossary_term' = 'Conviction Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `conviction_date` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `conviction_status` SET TAGS ('dbx_business_glossary_term' = 'Conviction Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `conviction_status` SET TAGS ('dbx_value_regex' = 'convicted|pending|dismissed|not_guilty');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `conviction_status` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `dui_indicator` SET TAGS ('dbx_business_glossary_term' = 'Driving Under the Influence (DUI) Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `fatality_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fatality Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `fault_percentage` SET TAGS ('dbx_business_glossary_term' = 'Fault Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `incident_date` SET TAGS ('dbx_business_glossary_term' = 'Incident Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `incident_type` SET TAGS ('dbx_business_glossary_term' = 'Incident Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `incident_type` SET TAGS ('dbx_value_regex' = 'violation|accident|claim|prior_loss');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `injury_indicator` SET TAGS ('dbx_business_glossary_term' = 'Injury Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `jurisdiction_country` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `jurisdiction_country` SET TAGS ('dbx_value_regex' = 'USA');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `jurisdiction_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `jurisdiction_state` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `jurisdiction_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `light_condition` SET TAGS ('dbx_business_glossary_term' = 'Light Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `light_condition` SET TAGS ('dbx_value_regex' = 'daylight|dusk|dawn|dark|dark_lighted');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `location_description` SET TAGS ('dbx_business_glossary_term' = 'Location Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `lookback_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Lookback Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Loss Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `points_assessed` SET TAGS ('dbx_business_glossary_term' = 'Points Assessed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `rating_impact_points` SET TAGS ('dbx_business_glossary_term' = 'Rating Impact Points');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `road_condition` SET TAGS ('dbx_business_glossary_term' = 'Road Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `road_condition` SET TAGS ('dbx_value_regex' = 'dry|wet|icy|snowy|muddy|other');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'minor|moderate|major|severe');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `source_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Source Reference Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `speed_limit` SET TAGS ('dbx_business_glossary_term' = 'Speed Limit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `speeding_indicator` SET TAGS ('dbx_business_glossary_term' = 'Speeding Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `underwriting_impact_code` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Impact Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `vehicle_vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `vehicle_vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `vehicle_vin` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'verified|pending|unverified|disputed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `violation_code` SET TAGS ('dbx_business_glossary_term' = 'Violation Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `violation_description` SET TAGS ('dbx_business_glossary_term' = 'Violation Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ALTER COLUMN `weather_condition` SET TAGS ('dbx_business_glossary_term' = 'Weather Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` SET TAGS ('dbx_subdomain' = 'exposure_assessment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `risk_score_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for risk_score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Override By User Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `acceptable_flag` SET TAGS ('dbx_business_glossary_term' = 'Risk Acceptable Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `cat_exposure_score` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Exposure Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `construction_score` SET TAGS ('dbx_business_glossary_term' = 'Construction Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `credit_score` SET TAGS ('dbx_business_glossary_term' = 'Credit-Based Insurance Score');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `credit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `driver_score` SET TAGS ('dbx_business_glossary_term' = 'Driver Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Score Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Score Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `hazard_score` SET TAGS ('dbx_business_glossary_term' = 'Hazard Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `lob` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `loss_history_score` SET TAGS ('dbx_business_glossary_term' = 'Loss History Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'Risk Scoring Model Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_vendor` SET TAGS ('dbx_business_glossary_term' = 'Risk Scoring Model Vendor');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Risk Scoring Model Version');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `moral_hazard_score` SET TAGS ('dbx_business_glossary_term' = 'Moral Hazard Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `occupancy_score` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Score Override Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Score Override Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `override_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Score Override Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `protection_class_score` SET TAGS ('dbx_business_glossary_term' = 'Protection Class Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Referral Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `referral_reason` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Referral Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Score Confidence Level Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_grade` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Grade');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_grade` SET TAGS ('dbx_value_regex' = 'A+|A|A-|B+|B|B-|C+|C|C-|D|E|F');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_notes` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_status` SET TAGS ('dbx_value_regex' = 'Active|Superseded|Voided|Archived');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_tier` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Tier');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_tier` SET TAGS ('dbx_value_regex' = 'Preferred|Standard|Substandard|Declined');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_type` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_type` SET TAGS ('dbx_value_regex' = 'Underwriting|Renewal|Endorsement|Reunderwriting|Catastrophe|Credit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `score_value` SET TAGS ('dbx_business_glossary_term' = 'Risk Score Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `territory_score` SET TAGS ('dbx_business_glossary_term' = 'Territory Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `threshold_exceeded_flag` SET TAGS ('dbx_business_glossary_term' = 'Risk Threshold Exceeded Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Risk Threshold Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ALTER COLUMN `vehicle_score` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Score Component');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` SET TAGS ('dbx_subdomain' = 'exposure_assessment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `risk_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Inspection Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspector_party_id` SET TAGS ('dbx_business_glossary_term' = 'Inspector Party Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `completed_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Completed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `electrical_condition` SET TAGS ('dbx_business_glossary_term' = 'Electrical System Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `electrical_condition` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor|hazardous');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `exposure_description` SET TAGS ('dbx_business_glossary_term' = 'Exposure Description (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `fire_protection_present` SET TAGS ('dbx_business_glossary_term' = 'Fire Protection System Present Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `fire_protection_type` SET TAGS ('dbx_business_glossary_term' = 'Fire Protection System Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `hazards_identified` SET TAGS ('dbx_business_glossary_term' = 'Hazards Identified Summary');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `hvac_condition` SET TAGS ('dbx_business_glossary_term' = 'Heating Ventilation Air Conditioning (HVAC) System Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `hvac_condition` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor|inoperative');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_method` SET TAGS ('dbx_business_glossary_term' = 'Inspection Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_method` SET TAGS ('dbx_value_regex' = 'on_site|desktop|aerial|virtual|hybrid');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_number` SET TAGS ('dbx_business_glossary_term' = 'Inspection Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_purpose` SET TAGS ('dbx_business_glossary_term' = 'Inspection Purpose');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_report_url` SET TAGS ('dbx_business_glossary_term' = 'Inspection Report Document URL');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_status` SET TAGS ('dbx_business_glossary_term' = 'Inspection Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_status` SET TAGS ('dbx_value_regex' = 'ordered|scheduled|in_progress|completed|cancelled|deferred');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_type` SET TAGS ('dbx_business_glossary_term' = 'Inspection Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `inspection_vendor` SET TAGS ('dbx_business_glossary_term' = 'Inspection Vendor Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location Latitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_address` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location Address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_city` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location City');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_city` SET TAGS ('dbx_pii_category' = 'address');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_country` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location Country');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_country` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location Postal Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_state` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location State');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `location_state` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location Longitude');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Inspection Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `ordered_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Ordered Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `overall_condition` SET TAGS ('dbx_business_glossary_term' = 'Overall Risk Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `overall_condition` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor|unacceptable');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `photos_count` SET TAGS ('dbx_business_glossary_term' = 'Inspection Photos Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `plumbing_condition` SET TAGS ('dbx_business_glossary_term' = 'Plumbing System Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `plumbing_condition` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor|hazardous');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class (COPE)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `recommendations` SET TAGS ('dbx_business_glossary_term' = 'Inspector Recommendations');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `roof_age_years` SET TAGS ('dbx_business_glossary_term' = 'Roof Age in Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `roof_age_years` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `roof_condition` SET TAGS ('dbx_business_glossary_term' = 'Roof Condition');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `roof_condition` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor|needs_replacement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `roof_type` SET TAGS ('dbx_business_glossary_term' = 'Roof Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Scheduled Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `security_system_present` SET TAGS ('dbx_business_glossary_term' = 'Security System Present Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `underwriting_action` SET TAGS ('dbx_business_glossary_term' = 'Underwriting Action Recommendation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `underwriting_action` SET TAGS ('dbx_value_regex' = 'accept|accept_with_conditions|decline|refer|request_reinspection');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ALTER COLUMN `valuation_estimate` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Estimate');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` SET TAGS ('dbx_subdomain' = 'exposure_assessment');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `risk_improvement_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Improvement ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `actual_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Cost Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `compliance_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `compliance_method` SET TAGS ('dbx_business_glossary_term' = 'Compliance Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `compliance_method` SET TAGS ('dbx_value_regex' = 'inspection|photo|invoice|certificate|self_attestation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `estimated_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Cost Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `extension_count` SET TAGS ('dbx_business_glossary_term' = 'Extension Count');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `follow_up_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `follow_up_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `imposed_date` SET TAGS ('dbx_business_glossary_term' = 'Imposed Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_category` SET TAGS ('dbx_business_glossary_term' = 'Improvement Category');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_category` SET TAGS ('dbx_value_regex' = 'fire_protection|security|structural|electrical|plumbing|roofing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_code` SET TAGS ('dbx_business_glossary_term' = 'Improvement Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_description` SET TAGS ('dbx_business_glossary_term' = 'Improvement Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_number` SET TAGS ('dbx_business_glossary_term' = 'Improvement Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_status` SET TAGS ('dbx_business_glossary_term' = 'Improvement Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|waived|expired|cancelled');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_type` SET TAGS ('dbx_business_glossary_term' = 'Improvement Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `improvement_type` SET TAGS ('dbx_value_regex' = 'required|recommended|optional');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `inspection_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Inspection Report Reference');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `inspector_company` SET TAGS ('dbx_business_glossary_term' = 'Inspector Company');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `inspector_name` SET TAGS ('dbx_business_glossary_term' = 'Inspector Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `inspector_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `last_extension_date` SET TAGS ('dbx_business_glossary_term' = 'Last Extension Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `non_compliance_action` SET TAGS ('dbx_business_glossary_term' = 'Non-Compliance Action');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `non_compliance_action` SET TAGS ('dbx_value_regex' = 'cancel_coverage|non_renew|surcharge|no_action');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `notification_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `notification_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Flag');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `premium_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `premium_impact_type` SET TAGS ('dbx_business_glossary_term' = 'Premium Impact Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `premium_impact_type` SET TAGS ('dbx_value_regex' = 'credit|surcharge|none');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `underwriter_notes` SET TAGS ('dbx_business_glossary_term' = 'Underwriter (UW) Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approved By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `waiver_approved_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approved Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `exposure_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Exposure Schedule Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `geography_id` SET TAGS ('dbx_business_glossary_term' = 'Geography Id (Foreign Key)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `blanket_group_code` SET TAGS ('dbx_business_glossary_term' = 'Blanket Group Identifier (ID)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `blanket_indicator` SET TAGS ('dbx_business_glossary_term' = 'Blanket Coverage Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `building_number` SET TAGS ('dbx_business_glossary_term' = 'Building Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `burglar_alarm_indicator` SET TAGS ('dbx_business_glossary_term' = 'Burglar Alarm Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `catastrophe_zone_code` SET TAGS ('dbx_business_glossary_term' = 'Catastrophe (CAT) Zone Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `deductible_type` SET TAGS ('dbx_business_glossary_term' = 'Deductible Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `deductible_type` SET TAGS ('dbx_value_regex' = 'flat|percentage|franchise|disappearing');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `equipment_serial_number` SET TAGS ('dbx_business_glossary_term' = 'Equipment Serial Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `exposure_schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule Entry Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `exposure_schedule_status` SET TAGS ('dbx_value_regex' = 'active|deleted|suspended|pending|expired');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `fire_alarm_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fire Alarm Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `flood_zone_designation` SET TAGS ('dbx_business_glossary_term' = 'Flood Zone Designation');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `line_of_business` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `location_number` SET TAGS ('dbx_business_glossary_term' = 'Location Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `number_of_stories` SET TAGS ('dbx_business_glossary_term' = 'Number of Stories');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `occupancy_code` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `premium_basis` SET TAGS ('dbx_business_glossary_term' = 'Premium Basis');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `prior_scheduled_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Scheduled Value Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `rate_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Unit');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Schedule Entry Remarks');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `risk_unit_description` SET TAGS ('dbx_business_glossary_term' = 'Risk Unit Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `schedule_entry_number` SET TAGS ('dbx_business_glossary_term' = 'Schedule Entry Number');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Schedule Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_value_regex' = 'location|vehicle|equipment|building|driver|blanket');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `scheduled_premium_amount` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Premium Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `scheduled_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Value Amount');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `scheduled_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Value Currency Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `scheduled_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `sprinkler_type` SET TAGS ('dbx_business_glossary_term' = 'Sprinkler System Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `sprinkler_type` SET TAGS ('dbx_value_regex' = 'none|automatic_wet|automatic_dry|deluge|pre_action|partial');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `total_area_square_feet` SET TAGS ('dbx_business_glossary_term' = 'Total Area Square Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `transaction_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'new|endorsement|renewal|deletion|reinstatement');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'replacement_cost|actual_cash_value|agreed_value|stated_amount|market_value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `vehicle_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `vehicle_identification_number` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `vehicle_identification_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `vehicle_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` SET TAGS ('dbx_subdomain' = 'asset_registry');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `risk_characteristic_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Characteristic ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `insured_risk_id` SET TAGS ('dbx_business_glossary_term' = 'Insured Risk ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `policy_term_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Term ID');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `alarm_type` SET TAGS ('dbx_business_glossary_term' = 'Alarm Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `alarm_type` SET TAGS ('dbx_value_regex' = 'none|local|central_station|direct_fire|direct_police|monitored');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `annual_mileage` SET TAGS ('dbx_business_glossary_term' = 'Annual Mileage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `annual_payroll` SET TAGS ('dbx_business_glossary_term' = 'Annual Payroll');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `annual_payroll` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `business_description` SET TAGS ('dbx_business_glossary_term' = 'Business Description');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_name` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_name` SET TAGS ('dbx_pii_category' = 'name');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_status` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Status');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|pending_verification');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_type` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `characteristic_value` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Value');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `claims_free_years` SET TAGS ('dbx_business_glossary_term' = 'Claims Free Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `construction_type` SET TAGS ('dbx_business_glossary_term' = 'Construction Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `construction_type` SET TAGS ('dbx_value_regex' = 'frame|joisted_masonry|non_combustible|masonry_non_combustible|modified_fire_resistive|fire_resistive');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `distance_to_fire_station_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance to Fire Station Miles');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `distance_to_hydrant_feet` SET TAGS ('dbx_business_glossary_term' = 'Distance to Hydrant Feet');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `dog_breed` SET TAGS ('dbx_business_glossary_term' = 'Dog Breed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `driver_training_indicator` SET TAGS ('dbx_business_glossary_term' = 'Driver Training Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `foundation_type` SET TAGS ('dbx_business_glossary_term' = 'Foundation Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `garaging_location` SET TAGS ('dbx_business_glossary_term' = 'Garaging Location');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `garaging_location` SET TAGS ('dbx_value_regex' = 'garage|carport|driveway|street|parking_lot');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `good_student_indicator` SET TAGS ('dbx_business_glossary_term' = 'Good Student Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `heating_type` SET TAGS ('dbx_business_glossary_term' = 'Heating Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `line_of_business` SET TAGS ('dbx_business_glossary_term' = 'Line of Business (LOB)');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `naics_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `number_of_employees` SET TAGS ('dbx_business_glossary_term' = 'Number of Employees');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `occupancy_type` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `plumbing_type` SET TAGS ('dbx_business_glossary_term' = 'Plumbing Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `plumbing_type` SET TAGS ('dbx_value_regex' = 'copper|pvc|galvanized|pex|polybutylene|mixed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `pool_indicator` SET TAGS ('dbx_business_glossary_term' = 'Pool Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `prior_insurance_indicator` SET TAGS ('dbx_business_glossary_term' = 'Prior Insurance Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `protection_class` SET TAGS ('dbx_business_glossary_term' = 'Protection Class');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `protection_class` SET TAGS ('dbx_value_regex' = '^[1-9]|10$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `roof_age_years` SET TAGS ('dbx_business_glossary_term' = 'Roof Age Years');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `roof_age_years` SET TAGS ('dbx_pii_sensitive' = 'true');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `roof_type` SET TAGS ('dbx_business_glossary_term' = 'Roof Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `sic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `sprinkler_system_indicator` SET TAGS ('dbx_business_glossary_term' = 'Sprinkler System Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `square_footage` SET TAGS ('dbx_business_glossary_term' = 'Square Footage');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `trampoline_indicator` SET TAGS ('dbx_business_glossary_term' = 'Trampoline Indicator');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `vehicle_usage_type` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Usage Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `vehicle_usage_type` SET TAGS ('dbx_value_regex' = 'personal|business|commercial|farm|pleasure|commute');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'Verification Method');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'inspection|third_party_data|applicant_declaration|agent_verification|photo_review');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `wiring_type` SET TAGS ('dbx_business_glossary_term' = 'Wiring Type');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `wiring_type` SET TAGS ('dbx_value_regex' = 'copper|aluminum|knob_and_tube|mixed');
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
