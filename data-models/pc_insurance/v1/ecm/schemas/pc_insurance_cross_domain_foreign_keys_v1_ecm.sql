-- Cross-Domain Foreign Keys for Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-18 02:30:19
-- Total cross-domain FK constraints: 528
--
-- EXECUTION ORDER:
--   1. Run ALL domain schema files first (any order).
--   2. Run this file LAST.
--
-- PREREQUISITE DOMAINS: claims, coverage, policy, premium, producers, reinsurance, reservespayments, riskexposure, shared

-- ========= claims --> coverage (11 constraint(s)) =========
-- Requires: claims schema, coverage schema
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ADD CONSTRAINT `fk_claims_claims_loss_reserve_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ADD CONSTRAINT `fk_claims_claim_note_exposure_id` FOREIGN KEY (`exposure_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`exposure`(`exposure_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_peril_causation` ADD CONSTRAINT `fk_claims_claim_peril_causation_coverage_peril_id` FOREIGN KEY (`coverage_peril_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_peril`(`coverage_peril_id`);

-- ========= claims --> policy (4 constraint(s)) =========
-- Requires: claims schema, policy schema
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_policy_insured_id` FOREIGN KEY (`policy_insured_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_insured`(`policy_insured_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ADD CONSTRAINT `fk_claims_claim_coverage_policy_coverage_id` FOREIGN KEY (`policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_coverage`(`policy_coverage_id`);

-- ========= claims --> premium (1 constraint(s)) =========
-- Requires: claims schema, premium schema
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ADD CONSTRAINT `fk_claims_disbursement_payment_id` FOREIGN KEY (`payment_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`payment`(`payment_id`);

-- ========= claims --> producers (3 constraint(s)) =========
-- Requires: claims schema, producers schema
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= claims --> reservespayments (6 constraint(s)) =========
-- Requires: claims schema, reservespayments schema
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_payee_id` FOREIGN KEY (`payee_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_payment_transaction_id` FOREIGN KEY (`payment_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction`(`payment_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ADD CONSTRAINT `fk_claims_disbursement_payee_id` FOREIGN KEY (`payee_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payee`(`payee_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_payment_transaction_id` FOREIGN KEY (`payment_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction`(`payment_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ADD CONSTRAINT `fk_claims_service_vendor_payee_id` FOREIGN KEY (`payee_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`payee`(`payee_id`);

-- ========= claims --> riskexposure (21 constraint(s)) =========
-- Requires: claims schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ADD CONSTRAINT `fk_claims_claim_coverage_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ADD CONSTRAINT `fk_claims_claim_coverage_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ADD CONSTRAINT `fk_claims_claim_coverage_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ADD CONSTRAINT `fk_claims_claims_loss_reserve_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ADD CONSTRAINT `fk_claims_claims_loss_reserve_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ADD CONSTRAINT `fk_claims_claims_reserve_transaction_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);

-- ========= claims --> shared (46 constraint(s)) =========
-- Requires: claims schema, shared schema
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_dol_calendar_id` FOREIGN KEY (`dol_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_loss_location_country_id` FOREIGN KEY (`loss_location_country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_loss_location_state_id` FOREIGN KEY (`loss_location_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_claimant_party_id` FOREIGN KEY (`claimant_party_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_dol_calendar_id` FOREIGN KEY (`dol_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_loss_location_country_id` FOREIGN KEY (`loss_location_country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_loss_location_state_id` FOREIGN KEY (`loss_location_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_country_id` FOREIGN KEY (`country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_settlement_calendar_id` FOREIGN KEY (`settlement_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ADD CONSTRAINT `fk_claims_claim_coverage_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_coverage` ADD CONSTRAINT `fk_claims_claim_coverage_loss_calendar_id` FOREIGN KEY (`loss_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ADD CONSTRAINT `fk_claims_claims_loss_reserve_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ADD CONSTRAINT `fk_claims_claims_loss_reserve_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_loss_reserve` ADD CONSTRAINT `fk_claims_claims_loss_reserve_reserve_set_calendar_id` FOREIGN KEY (`reserve_set_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ADD CONSTRAINT `fk_claims_claims_reserve_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ADD CONSTRAINT `fk_claims_claims_reserve_transaction_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_reserve_transaction` ADD CONSTRAINT `fk_claims_claims_reserve_transaction_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claims_claim_payment` ADD CONSTRAINT `fk_claims_claims_claim_payment_payment_calendar_id` FOREIGN KEY (`payment_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ADD CONSTRAINT `fk_claims_disbursement_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`disbursement` ADD CONSTRAINT `fk_claims_disbursement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ADD CONSTRAINT `fk_claims_adjuster_license_issue_calendar_id` FOREIGN KEY (`license_issue_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster` ADD CONSTRAINT `fk_claims_adjuster_license_state_id` FOREIGN KEY (`license_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_assignment_calendar_id` FOREIGN KEY (`assignment_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_note` ADD CONSTRAINT `fk_claims_claim_note_note_calendar_id` FOREIGN KEY (`note_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_document` ADD CONSTRAINT `fk_claims_claim_document_document_calendar_id` FOREIGN KEY (`document_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_suit_filed_calendar_id` FOREIGN KEY (`suit_filed_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_bill_calendar_id` FOREIGN KEY (`bill_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`damage_estimate` ADD CONSTRAINT `fk_claims_damage_estimate_estimate_calendar_id` FOREIGN KEY (`estimate_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ADD CONSTRAINT `fk_claims_service_vendor_business_country_id` FOREIGN KEY (`business_country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ADD CONSTRAINT `fk_claims_service_vendor_business_state_id` FOREIGN KEY (`business_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`service_vendor` ADD CONSTRAINT `fk_claims_service_vendor_onboarding_calendar_id` FOREIGN KEY (`onboarding_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ADD CONSTRAINT `fk_claims_claim_status_history_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`claim_status_history` ADD CONSTRAINT `fk_claims_claim_status_history_transition_calendar_id` FOREIGN KEY (`transition_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`claims`.`fraud_referral` ADD CONSTRAINT `fk_claims_fraud_referral_referral_calendar_id` FOREIGN KEY (`referral_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);

-- ========= coverage --> policy (16 constraint(s)) =========
-- Requires: coverage schema, policy schema
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ADD CONSTRAINT `fk_coverage_coverage_policy_coverage_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ADD CONSTRAINT `fk_coverage_coverage_policy_coverage_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`part` ADD CONSTRAINT `fk_coverage_part_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ADD CONSTRAINT `fk_coverage_sir_layer_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ADD CONSTRAINT `fk_coverage_endorsement_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ADD CONSTRAINT `fk_coverage_additional_insured_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ADD CONSTRAINT `fk_coverage_named_insured_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ADD CONSTRAINT `fk_coverage_itv_assessment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ADD CONSTRAINT `fk_coverage_waiver_of_subrogation_document_id` FOREIGN KEY (`document_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`document`(`document_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ADD CONSTRAINT `fk_coverage_waiver_of_subrogation_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ADD CONSTRAINT `fk_coverage_waiver_of_subrogation_version_id` FOREIGN KEY (`version_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`version`(`version_id`);

-- ========= coverage --> producers (2 constraint(s)) =========
-- Requires: coverage schema, producers schema
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ADD CONSTRAINT `fk_coverage_endorsement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= coverage --> reinsurance (2 constraint(s)) =========
-- Requires: coverage schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ADD CONSTRAINT `fk_coverage_cession_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`cession` ADD CONSTRAINT `fk_coverage_cession_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);

-- ========= coverage --> riskexposure (12 constraint(s)) =========
-- Requires: coverage schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage` ADD CONSTRAINT `fk_coverage_coverage_policy_coverage_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ADD CONSTRAINT `fk_coverage_sir_layer_sir_retention_id` FOREIGN KEY (`sir_retention_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention`(`sir_retention_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ADD CONSTRAINT `fk_coverage_additional_insured_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ADD CONSTRAINT `fk_coverage_additional_insured_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ADD CONSTRAINT `fk_coverage_named_insured_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ADD CONSTRAINT `fk_coverage_itv_assessment_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`waiver_of_subrogation` ADD CONSTRAINT `fk_coverage_waiver_of_subrogation_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_scheduled_item_id` FOREIGN KEY (`scheduled_item_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item`(`scheduled_item_id`);

-- ========= coverage --> shared (10 constraint(s)) =========
-- Requires: coverage schema, shared schema
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`sir_layer` ADD CONSTRAINT `fk_coverage_sir_layer_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`endorsement` ADD CONSTRAINT `fk_coverage_endorsement_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`additional_insured` ADD CONSTRAINT `fk_coverage_additional_insured_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`named_insured` ADD CONSTRAINT `fk_coverage_named_insured_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`amendment` ADD CONSTRAINT `fk_coverage_amendment_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`itv_assessment` ADD CONSTRAINT `fk_coverage_itv_assessment_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`coverage_peril` ADD CONSTRAINT `fk_coverage_coverage_peril_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`coverage`.`exposure` ADD CONSTRAINT `fk_coverage_exposure_effective_calendar_id` FOREIGN KEY (`effective_calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);

-- ========= policy --> coverage (2 constraint(s)) =========
-- Requires: policy schema, coverage schema
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ADD CONSTRAINT `fk_policy_version_named_insured_id` FOREIGN KEY (`named_insured_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`named_insured`(`named_insured_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ADD CONSTRAINT `fk_policy_policy_coverage_part_id` FOREIGN KEY (`part_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`part`(`part_id`);

-- ========= policy --> premium (1 constraint(s)) =========
-- Requires: policy schema, premium schema
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ADD CONSTRAINT `fk_policy_version_billing_account_id` FOREIGN KEY (`billing_account_id`) REFERENCES `vibe_pc_insurance_v499`.`premium`.`billing_account`(`billing_account_id`);

-- ========= policy --> producers (16 constraint(s)) =========
-- Requires: policy schema, producers schema
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ADD CONSTRAINT `fk_policy_version_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ADD CONSTRAINT `fk_policy_version_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_declarations_producers_producer_id` FOREIGN KEY (`declarations_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_declarations_producers_producers_producer_id` FOREIGN KEY (`declarations_producers_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ADD CONSTRAINT `fk_policy_quote_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ADD CONSTRAINT `fk_policy_quote_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ADD CONSTRAINT `fk_policy_submission_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ADD CONSTRAINT `fk_policy_submission_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_binder_producers_producer_id` FOREIGN KEY (`binder_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_binder_producers_producers_producer_id` FOREIGN KEY (`binder_producers_producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_binding_authority_id` FOREIGN KEY (`binding_authority_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`binding_authority`(`binding_authority_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= policy --> reinsurance (2 constraint(s)) =========
-- Requires: policy schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`premium_cession_allocation` ADD CONSTRAINT `fk_policy_premium_cession_allocation_ceded_premium_transaction_id` FOREIGN KEY (`ceded_premium_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction`(`ceded_premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`coverage_cession` ADD CONSTRAINT `fk_policy_coverage_cession_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);

-- ========= policy --> riskexposure (2 constraint(s)) =========
-- Requires: policy schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`location_condition` ADD CONSTRAINT `fk_policy_location_condition_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`vehicle_form_application` ADD CONSTRAINT `fk_policy_vehicle_form_application_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);

-- ========= policy --> shared (24 constraint(s)) =========
-- Requires: policy schema, shared schema
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_regulatory_state_id` FOREIGN KEY (`regulatory_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ADD CONSTRAINT `fk_policy_version_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`version` ADD CONSTRAINT `fk_policy_version_regulatory_state_id` FOREIGN KEY (`regulatory_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_coverage` ADD CONSTRAINT `fk_policy_policy_coverage_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ADD CONSTRAINT `fk_policy_policy_insured_mailing_country_id` FOREIGN KEY (`mailing_country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_insured` ADD CONSTRAINT `fk_policy_policy_insured_mailing_state_id` FOREIGN KEY (`mailing_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`declarations` ADD CONSTRAINT `fk_policy_declarations_mailing_state_id` FOREIGN KEY (`mailing_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ADD CONSTRAINT `fk_policy_quote_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`quote` ADD CONSTRAINT `fk_policy_quote_rating_state_id` FOREIGN KEY (`rating_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ADD CONSTRAINT `fk_policy_submission_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`submission` ADD CONSTRAINT `fk_policy_submission_risk_state_id` FOREIGN KEY (`risk_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ADD CONSTRAINT `fk_policy_condition_assigned_to_party_id` FOREIGN KEY (`assigned_to_party_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`condition` ADD CONSTRAINT `fk_policy_condition_regulatory_state_id` FOREIGN KEY (`regulatory_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_user_account_id` FOREIGN KEY (`user_account_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`user_account`(`user_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_recipient_country_id` FOREIGN KEY (`recipient_country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_recipient_state_id` FOREIGN KEY (`recipient_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`binder` ADD CONSTRAINT `fk_policy_binder_mailing_state_id` FOREIGN KEY (`mailing_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing` ADD CONSTRAINT `fk_policy_policy_rate_filing_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_regulatory_state_id` FOREIGN KEY (`regulatory_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`policy`.`form_filing` ADD CONSTRAINT `fk_policy_form_filing_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);

-- ========= premium --> claims (3 constraint(s)) =========
-- Requires: premium schema, claims schema
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);

-- ========= premium --> coverage (8 constraint(s)) =========
-- Requires: premium schema, coverage schema
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_endorsement_id` FOREIGN KEY (`endorsement_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`endorsement`(`endorsement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ADD CONSTRAINT `fk_premium_rate_element_coverage_form_id` FOREIGN KEY (`coverage_form_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_form`(`coverage_form_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ADD CONSTRAINT `fk_premium_rating_worksheet_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ADD CONSTRAINT `fk_premium_dac_transaction_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);

-- ========= premium --> policy (17 constraint(s)) =========
-- Requires: premium schema, policy schema
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_policy_rate_filing_id` FOREIGN KEY (`policy_rate_filing_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_rate_filing`(`policy_rate_filing_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ADD CONSTRAINT `fk_premium_rating_worksheet_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ADD CONSTRAINT `fk_premium_rating_worksheet_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ADD CONSTRAINT `fk_premium_billing_account_insured_id` FOREIGN KEY (`insured_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`insured`(`insured_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ADD CONSTRAINT `fk_premium_billing_account_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ADD CONSTRAINT `fk_premium_installment_schedule_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ADD CONSTRAINT `fk_premium_installment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ADD CONSTRAINT `fk_premium_payment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ADD CONSTRAINT `fk_premium_dac_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ADD CONSTRAINT `fk_premium_surplus_lines_tax_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ADD CONSTRAINT `fk_premium_finance_agreement_insured_id` FOREIGN KEY (`insured_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`insured`(`insured_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ADD CONSTRAINT `fk_premium_finance_agreement_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);

-- ========= premium --> producers (7 constraint(s)) =========
-- Requires: premium schema, producers schema
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ADD CONSTRAINT `fk_premium_billing_account_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ADD CONSTRAINT `fk_premium_payment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ADD CONSTRAINT `fk_premium_agency_bill_statement_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ADD CONSTRAINT `fk_premium_agency_bill_statement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= premium --> reinsurance (1 constraint(s)) =========
-- Requires: premium schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);

-- ========= premium --> shared (41 constraint(s)) =========
-- Requires: premium schema, shared schema
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_country_id` FOREIGN KEY (`country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`written_premium` ADD CONSTRAINT `fk_premium_written_premium_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_country_id` FOREIGN KEY (`country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`earned_premium` ADD CONSTRAINT `fk_premium_earned_premium_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_risk_state_id` FOREIGN KEY (`risk_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ADD CONSTRAINT `fk_premium_rate_element_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_element` ADD CONSTRAINT `fk_premium_rate_element_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ADD CONSTRAINT `fk_premium_rating_worksheet_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`rating_worksheet` ADD CONSTRAINT `fk_premium_rating_worksheet_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ADD CONSTRAINT `fk_premium_billing_account_billing_country_id` FOREIGN KEY (`billing_country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ADD CONSTRAINT `fk_premium_billing_account_billing_currency_id` FOREIGN KEY (`billing_currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`billing_account` ADD CONSTRAINT `fk_premium_billing_account_billing_state_id` FOREIGN KEY (`billing_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ADD CONSTRAINT `fk_premium_installment_schedule_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ADD CONSTRAINT `fk_premium_installment_schedule_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment_schedule` ADD CONSTRAINT `fk_premium_installment_schedule_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`installment` ADD CONSTRAINT `fk_premium_installment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`payment` ADD CONSTRAINT `fk_premium_payment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ADD CONSTRAINT `fk_premium_dac_transaction_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ADD CONSTRAINT `fk_premium_dac_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`dac_transaction` ADD CONSTRAINT `fk_premium_dac_transaction_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_jurisdiction_state_id` FOREIGN KEY (`jurisdiction_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ADD CONSTRAINT `fk_premium_surplus_lines_tax_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`surplus_lines_tax` ADD CONSTRAINT `fk_premium_surplus_lines_tax_tax_jurisdiction_state_id` FOREIGN KEY (`tax_jurisdiction_state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`finance_agreement` ADD CONSTRAINT `fk_premium_finance_agreement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ADD CONSTRAINT `fk_premium_premium_rate_filing_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`premium_rate_filing` ADD CONSTRAINT `fk_premium_premium_rate_filing_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ADD CONSTRAINT `fk_premium_agency_bill_statement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`premium`.`agency_bill_statement` ADD CONSTRAINT `fk_premium_agency_bill_statement_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);

-- ========= producers --> coverage (3 constraint(s)) =========
-- Requires: producers schema, coverage schema
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_endorsement_id` FOREIGN KEY (`endorsement_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`endorsement`(`endorsement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ADD CONSTRAINT `fk_producers_binding_authority_coverage_form_id` FOREIGN KEY (`coverage_form_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_form`(`coverage_form_id`);

-- ========= producers --> policy (1 constraint(s)) =========
-- Requires: producers schema, policy schema
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);

-- ========= producers --> shared (28 constraint(s)) =========
-- Requires: producers schema, shared schema
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producers_producer` ADD CONSTRAINT `fk_producers_producers_producer_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_license` ADD CONSTRAINT `fk_producers_producer_license_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ADD CONSTRAINT `fk_producers_appointment_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ADD CONSTRAINT `fk_producers_appointment_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`org_unit`(`org_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`appointment` ADD CONSTRAINT `fk_producers_appointment_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ADD CONSTRAINT `fk_producers_eno_policy_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`eno_policy` ADD CONSTRAINT `fk_producers_eno_policy_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ADD CONSTRAINT `fk_producers_contingent_bonus_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`contingent_bonus` ADD CONSTRAINT `fk_producers_contingent_bonus_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ADD CONSTRAINT `fk_producers_producer_agreement_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_agreement` ADD CONSTRAINT `fk_producers_producer_agreement_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ADD CONSTRAINT `fk_producers_binding_authority_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`binding_authority` ADD CONSTRAINT `fk_producers_binding_authority_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`onboarding_case` ADD CONSTRAINT `fk_producers_onboarding_case_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ADD CONSTRAINT `fk_producers_termination_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`termination` ADD CONSTRAINT `fk_producers_termination_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`producer_compliance` ADD CONSTRAINT `fk_producers_producer_compliance_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`territory` ADD CONSTRAINT `fk_producers_territory_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`producers`.`authority_territory` ADD CONSTRAINT `fk_producers_authority_territory_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);

-- ========= reinsurance --> claims (4 constraint(s)) =========
-- Requires: reinsurance schema, claims schema
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);

-- ========= reinsurance --> coverage (8 constraint(s)) =========
-- Requires: reinsurance schema, coverage schema
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ADD CONSTRAINT `fk_reinsurance_fac_certificate_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ADD CONSTRAINT `fk_reinsurance_policy_cession_endorsement_id` FOREIGN KEY (`endorsement_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`endorsement`(`endorsement_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ADD CONSTRAINT `fk_reinsurance_policy_cession_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);

-- ========= reinsurance --> policy (7 constraint(s)) =========
-- Requires: reinsurance schema, policy schema
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ADD CONSTRAINT `fk_reinsurance_fac_certificate_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ADD CONSTRAINT `fk_reinsurance_policy_cession_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_premium_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);

-- ========= reinsurance --> producers (3 constraint(s)) =========
-- Requires: reinsurance schema, producers schema
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ADD CONSTRAINT `fk_reinsurance_ri_treaty_originating_agency_id` FOREIGN KEY (`originating_agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ADD CONSTRAINT `fk_reinsurance_ri_treaty_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ADD CONSTRAINT `fk_reinsurance_ri_placement_placing_agency_id` FOREIGN KEY (`placing_agency_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`agency`(`agency_id`);

-- ========= reinsurance --> reservespayments (1 constraint(s)) =========
-- Requires: reinsurance schema, reservespayments schema
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ADD CONSTRAINT `fk_reinsurance_occurrence_loss_cat_event_id` FOREIGN KEY (`cat_event_id`) REFERENCES `vibe_pc_insurance_v499`.`reservespayments`.`cat_event`(`cat_event_id`);

-- ========= reinsurance --> riskexposure (10 constraint(s)) =========
-- Requires: reinsurance schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ADD CONSTRAINT `fk_reinsurance_fac_certificate_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ADD CONSTRAINT `fk_reinsurance_fac_certificate_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ADD CONSTRAINT `fk_reinsurance_occurrence_loss_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);

-- ========= reinsurance --> shared (35 constraint(s)) =========
-- Requires: reinsurance schema, shared schema
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ADD CONSTRAINT `fk_reinsurance_ri_treaty_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty` ADD CONSTRAINT `fk_reinsurance_ri_treaty_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ADD CONSTRAINT `fk_reinsurance_fac_certificate_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate` ADD CONSTRAINT `fk_reinsurance_fac_certificate_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ADD CONSTRAINT `fk_reinsurance_policy_cession_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`policy_cession` ADD CONSTRAINT `fk_reinsurance_policy_cession_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`bordereaux_line` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_premium_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_premium_transaction_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ceded_loss_transaction` ADD CONSTRAINT `fk_reinsurance_ceded_loss_transaction_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_recoverable` ADD CONSTRAINT `fk_reinsurance_ri_recoverable_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`claim_ri_recovery` ADD CONSTRAINT `fk_reinsurance_claim_ri_recovery_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ADD CONSTRAINT `fk_reinsurance_cat_bond_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ADD CONSTRAINT `fk_reinsurance_cat_bond_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`cat_bond` ADD CONSTRAINT `fk_reinsurance_cat_bond_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`org_unit`(`org_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ADD CONSTRAINT `fk_reinsurance_profit_commission_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`profit_commission` ADD CONSTRAINT `fk_reinsurance_profit_commission_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ADD CONSTRAINT `fk_reinsurance_reinstatement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`reinstatement` ADD CONSTRAINT `fk_reinsurance_reinstatement_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ADD CONSTRAINT `fk_reinsurance_ri_placement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`ri_placement` ADD CONSTRAINT `fk_reinsurance_ri_placement_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ADD CONSTRAINT `fk_reinsurance_occurrence_loss_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss` ADD CONSTRAINT `fk_reinsurance_occurrence_loss_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);

-- ========= reservespayments --> claims (28 constraint(s)) =========
-- Requires: reservespayments schema, claims schema
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_claim_coverage_id` FOREIGN KEY (`claim_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim_coverage`(`claim_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_attorney_id` FOREIGN KEY (`attorney_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`attorney`(`attorney_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ADD CONSTRAINT `fk_reservespayments_salvage_item_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ADD CONSTRAINT `fk_reservespayments_salvage_item_service_vendor_id` FOREIGN KEY (`service_vendor_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`service_vendor`(`service_vendor_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_service_vendor_id` FOREIGN KEY (`service_vendor_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`service_vendor`(`service_vendor_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ADD CONSTRAINT `fk_reservespayments_payment_authority_payment_adjuster_id` FOREIGN KEY (`payment_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ADD CONSTRAINT `fk_reservespayments_payment_authority_payment_delegated_by_adjuster_id` FOREIGN KEY (`payment_delegated_by_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ADD CONSTRAINT `fk_reservespayments_payment_authority_payment_escalation_adjuster_id` FOREIGN KEY (`payment_escalation_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ADD CONSTRAINT `fk_reservespayments_payment_authority_tpa_id` FOREIGN KEY (`tpa_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`tpa`(`tpa_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_payment_adjuster_id` FOREIGN KEY (`payment_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_payment_escalated_to_adjuster_id` FOREIGN KEY (`payment_escalated_to_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_payment_requestor_adjuster_id` FOREIGN KEY (`payment_requestor_adjuster_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ADD CONSTRAINT `fk_reservespayments_structured_settlement_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ADD CONSTRAINT `fk_reservespayments_structured_settlement_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claimant`(`claimant_id`);

-- ========= reservespayments --> coverage (9 constraint(s)) =========
-- Requires: reservespayments schema, coverage schema
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_part_id` FOREIGN KEY (`part_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`part`(`part_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ADD CONSTRAINT `fk_reservespayments_salvage_item_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ADD CONSTRAINT `fk_reservespayments_structured_settlement_coverage_policy_coverage_id` FOREIGN KEY (`coverage_policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`coverage_policy_coverage`(`coverage_policy_coverage_id`);

-- ========= reservespayments --> policy (5 constraint(s)) =========
-- Requires: reservespayments schema, policy schema
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);

-- ========= reservespayments --> reinsurance (9 constraint(s)) =========
-- Requires: reservespayments schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_fac_certificate_id` FOREIGN KEY (`fac_certificate_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`fac_certificate`(`fac_certificate_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_occurrence_loss_id` FOREIGN KEY (`occurrence_loss_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`occurrence_loss`(`occurrence_loss_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ADD CONSTRAINT `fk_reservespayments_cat_event_ri_treaty_id` FOREIGN KEY (`ri_treaty_id`) REFERENCES `vibe_pc_insurance_v499`.`reinsurance`.`ri_treaty`(`ri_treaty_id`);

-- ========= reservespayments --> riskexposure (26 constraint(s)) =========
-- Requires: reservespayments schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_risk_unit_id` FOREIGN KEY (`risk_unit_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit`(`risk_unit_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ADD CONSTRAINT `fk_reservespayments_ibnr_estimate_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ADD CONSTRAINT `fk_reservespayments_reserve_evaluation_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ADD CONSTRAINT `fk_reservespayments_salvage_item_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ADD CONSTRAINT `fk_reservespayments_salvage_item_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_insured_vehicle_id` FOREIGN KEY (`insured_vehicle_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle`(`insured_vehicle_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_insured_location_id` FOREIGN KEY (`insured_location_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_location`(`insured_location_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ADD CONSTRAINT `fk_reservespayments_structured_settlement_insured_entity_id` FOREIGN KEY (`insured_entity_id`) REFERENCES `vibe_pc_insurance_v499`.`riskexposure`.`insured_entity`(`insured_entity_id`);

-- ========= reservespayments --> shared (46 constraint(s)) =========
-- Requires: reservespayments schema, shared schema
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_loss_reserve` ADD CONSTRAINT `fk_reservespayments_reservespayments_loss_reserve_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_reserve_transaction` ADD CONSTRAINT `fk_reservespayments_reservespayments_reserve_transaction_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ADD CONSTRAINT `fk_reservespayments_ibnr_estimate_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ADD CONSTRAINT `fk_reservespayments_ibnr_estimate_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ADD CONSTRAINT `fk_reservespayments_ibnr_estimate_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`ibnr_estimate` ADD CONSTRAINT `fk_reservespayments_ibnr_estimate_user_account_id` FOREIGN KEY (`user_account_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`user_account`(`user_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ADD CONSTRAINT `fk_reservespayments_reserve_evaluation_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ADD CONSTRAINT `fk_reservespayments_reserve_evaluation_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reserve_evaluation` ADD CONSTRAINT `fk_reservespayments_reserve_evaluation_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reservespayments_claim_payment` ADD CONSTRAINT `fk_reservespayments_reservespayments_claim_payment_user_account_id` FOREIGN KEY (`user_account_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`user_account`(`user_account_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_transaction` ADD CONSTRAINT `fk_reservespayments_payment_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`recovery_transaction` ADD CONSTRAINT `fk_reservespayments_recovery_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`subrogation_case` ADD CONSTRAINT `fk_reservespayments_subrogation_case_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`salvage_item` ADD CONSTRAINT `fk_reservespayments_salvage_item_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`lae_allocation` ADD CONSTRAINT `fk_reservespayments_lae_allocation_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ADD CONSTRAINT `fk_reservespayments_payment_authority_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ADD CONSTRAINT `fk_reservespayments_payment_authority_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_authority` ADD CONSTRAINT `fk_reservespayments_payment_authority_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payment_approval` ADD CONSTRAINT `fk_reservespayments_payment_approval_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ADD CONSTRAINT `fk_reservespayments_payee_country_id` FOREIGN KEY (`country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ADD CONSTRAINT `fk_reservespayments_payee_preferred_currency_id` FOREIGN KEY (`preferred_currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`payee` ADD CONSTRAINT `fk_reservespayments_payee_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`reinsurance_recoverable` ADD CONSTRAINT `fk_reservespayments_reinsurance_recoverable_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ADD CONSTRAINT `fk_reservespayments_structured_settlement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ADD CONSTRAINT `fk_reservespayments_structured_settlement_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`structured_settlement` ADD CONSTRAINT `fk_reservespayments_structured_settlement_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ADD CONSTRAINT `fk_reservespayments_development_triangle_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ADD CONSTRAINT `fk_reservespayments_development_triangle_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`development_triangle` ADD CONSTRAINT `fk_reservespayments_development_triangle_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ADD CONSTRAINT `fk_reservespayments_stat_reserve_exhibit_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ADD CONSTRAINT `fk_reservespayments_stat_reserve_exhibit_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`stat_reserve_exhibit` ADD CONSTRAINT `fk_reservespayments_stat_reserve_exhibit_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`cat_event` ADD CONSTRAINT `fk_reservespayments_cat_event_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`reservespayments`.`actuarial_analyst` ADD CONSTRAINT `fk_reservespayments_actuarial_analyst_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`party`(`party_id`);

-- ========= riskexposure --> claims (4 constraint(s)) =========
-- Requires: riskexposure schema, claims schema
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ADD CONSTRAINT `fk_riskexposure_uw_survey_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ADD CONSTRAINT `fk_riskexposure_clue_report_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`vehicle_claimant_involvement` ADD CONSTRAINT `fk_riskexposure_vehicle_claimant_involvement_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`location_claimant_interest` ADD CONSTRAINT `fk_riskexposure_location_claimant_interest_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_v499`.`claims`.`claimant`(`claimant_id`);

-- ========= riskexposure --> coverage (1 constraint(s)) =========
-- Requires: riskexposure schema, coverage schema
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ADD CONSTRAINT `fk_riskexposure_exposure_period_exposure_id` FOREIGN KEY (`exposure_id`) REFERENCES `vibe_pc_insurance_v499`.`coverage`.`exposure`(`exposure_id`);

-- ========= riskexposure --> policy (28 constraint(s)) =========
-- Requires: riskexposure schema, policy schema
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ADD CONSTRAINT `fk_riskexposure_scheduled_item_policy_coverage_id` FOREIGN KEY (`policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_coverage`(`policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ADD CONSTRAINT `fk_riskexposure_scheduled_item_photo_document_id` FOREIGN KEY (`photo_document_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`document`(`document_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_item` ADD CONSTRAINT `fk_riskexposure_scheduled_item_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_vehicle` ADD CONSTRAINT `fk_riskexposure_insured_vehicle_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ADD CONSTRAINT `fk_riskexposure_risk_unit_policy_coverage_id` FOREIGN KEY (`policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_coverage`(`policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ADD CONSTRAINT `fk_riskexposure_risk_unit_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ADD CONSTRAINT `fk_riskexposure_exposure_period_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ADD CONSTRAINT `fk_riskexposure_uw_survey_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`uw_survey` ADD CONSTRAINT `fk_riskexposure_uw_survey_report_document_id` FOREIGN KEY (`report_document_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`document`(`document_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`mvr_report` ADD CONSTRAINT `fk_riskexposure_mvr_report_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`clue_report` ADD CONSTRAINT `fk_riskexposure_clue_report_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`tiv_schedule` ADD CONSTRAINT `fk_riskexposure_tiv_schedule_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ADD CONSTRAINT `fk_riskexposure_wc_payroll_class_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`driver_assignment` ADD CONSTRAINT `fk_riskexposure_driver_assignment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ADD CONSTRAINT `fk_riskexposure_pml_estimate_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ADD CONSTRAINT `fk_riskexposure_flood_zone_assignment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ADD CONSTRAINT `fk_riskexposure_gl_operation_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ADD CONSTRAINT `fk_riskexposure_scheduled_equipment_policy_coverage_id` FOREIGN KEY (`policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_coverage`(`policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`scheduled_equipment` ADD CONSTRAINT `fk_riskexposure_scheduled_equipment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ADD CONSTRAINT `fk_riskexposure_experience_mod_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ADD CONSTRAINT `fk_riskexposure_sir_retention_policy_coverage_id` FOREIGN KEY (`policy_coverage_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_coverage`(`policy_coverage_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ADD CONSTRAINT `fk_riskexposure_sir_retention_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);

-- ========= riskexposure --> producers (1 constraint(s)) =========
-- Requires: riskexposure schema, producers schema
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= riskexposure --> shared (13 constraint(s)) =========
-- Requires: riskexposure schema, shared schema
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ADD CONSTRAINT `fk_riskexposure_insured_location_country_id` FOREIGN KEY (`country_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`country`(`country_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`insured_location` ADD CONSTRAINT `fk_riskexposure_insured_location_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_unit` ADD CONSTRAINT `fk_riskexposure_risk_unit_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`cat_zone` ADD CONSTRAINT `fk_riskexposure_cat_zone_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`exposure_period` ADD CONSTRAINT `fk_riskexposure_exposure_period_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`wc_payroll_class` ADD CONSTRAINT `fk_riskexposure_wc_payroll_class_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`pml_estimate` ADD CONSTRAINT `fk_riskexposure_pml_estimate_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`flood_zone_assignment` ADD CONSTRAINT `fk_riskexposure_flood_zone_assignment_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`gl_operation` ADD CONSTRAINT `fk_riskexposure_gl_operation_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`experience_mod` ADD CONSTRAINT `fk_riskexposure_experience_mod_state_id` FOREIGN KEY (`state_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`state`(`state_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`sir_retention` ADD CONSTRAINT `fk_riskexposure_sir_retention_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);
ALTER TABLE `vibe_pc_insurance_v499`.`riskexposure`.`risk_change_event` ADD CONSTRAINT `fk_riskexposure_risk_change_event_lob_code_id` FOREIGN KEY (`lob_code_id`) REFERENCES `vibe_pc_insurance_v499`.`shared`.`lob_code`(`lob_code_id`);

