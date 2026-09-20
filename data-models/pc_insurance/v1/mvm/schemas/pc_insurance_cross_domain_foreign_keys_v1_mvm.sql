-- Cross-Domain Foreign Keys for Business: Pc_Insurance | Version: v1_mvm
-- Generated on: 2026-09-20 21:40:53
-- Total cross-domain FK constraints: 722
--
-- EXECUTION ORDER:
--   1. Run ALL domain schema files first (any order).
--   2. Run this file LAST.
--
-- PREREQUISITE DOMAINS: billing, catastrophegeography, claimfinancials, claims, coverage, party, policy, premium, producers, reinsurance, riskexposure, shared

-- ========= billing --> catastrophegeography (10 constraint(s)) =========
-- Requires: billing schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);

-- ========= billing --> claimfinancials (12 constraint(s)) =========
-- Requires: billing schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_claim_payment_id` FOREIGN KEY (`claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_claim_expense_id` FOREIGN KEY (`claim_expense_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense`(`claim_expense_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_claim_payment_id` FOREIGN KEY (`claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_reinsurance_recovery_id` FOREIGN KEY (`reinsurance_recovery_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery`(`reinsurance_recovery_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_claim_payment_id` FOREIGN KEY (`claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_claim_payment_id` FOREIGN KEY (`claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_claim_payment_id` FOREIGN KEY (`claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_salvage_id` FOREIGN KEY (`salvage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage`(`salvage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_subrogation_id` FOREIGN KEY (`subrogation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation`(`subrogation_id`);

-- ========= billing --> claims (5 constraint(s)) =========
-- Requires: billing schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_litigation_id` FOREIGN KEY (`litigation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`litigation`(`litigation_id`);

-- ========= billing --> coverage (5 constraint(s)) =========
-- Requires: billing schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);

-- ========= billing --> party (11 constraint(s)) =========
-- Requires: billing schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_billing_address_id` FOREIGN KEY (`billing_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_household_id` FOREIGN KEY (`household_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`household`(`household_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_bill_to_party_id` FOREIGN KEY (`bill_to_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_payer_party_id` FOREIGN KEY (`payer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_contact_party_id` FOREIGN KEY (`contact_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_payee_address_id` FOREIGN KEY (`payee_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_payee_party_id` FOREIGN KEY (`payee_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ADD CONSTRAINT `fk_billing_payment_method_billing_address_id` FOREIGN KEY (`billing_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ADD CONSTRAINT `fk_billing_payment_method_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_bill_to_party_id` FOREIGN KEY (`bill_to_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= billing --> policy (30 constraint(s)) =========
-- Requires: billing schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_policyholder_id` FOREIGN KEY (`policyholder_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policyholder`(`policyholder_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ADD CONSTRAINT `fk_billing_payment_plan_type_id` FOREIGN KEY (`type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`type`(`type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_policyholder_id` FOREIGN KEY (`policyholder_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policyholder`(`policyholder_id`);

-- ========= billing --> premium (2 constraint(s)) =========
-- Requires: billing schema, premium schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_charge_id` FOREIGN KEY (`charge_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`charge`(`charge_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_tax_levy_id` FOREIGN KEY (`tax_levy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy`(`tax_levy_id`);

-- ========= billing --> producers (16 constraint(s)) =========
-- Requires: billing schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_commission_statement_id` FOREIGN KEY (`commission_statement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement`(`commission_statement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_commission_statement_id` FOREIGN KEY (`commission_statement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement`(`commission_statement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_commission_transaction_id` FOREIGN KEY (`commission_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction`(`commission_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_payee_agency_id` FOREIGN KEY (`payee_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= billing --> reinsurance (7 constraint(s)) =========
-- Requires: billing schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_cession_id` FOREIGN KEY (`cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession`(`cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_ri_claim_cession_id` FOREIGN KEY (`ri_claim_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`(`ri_claim_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_ri_premium_transaction_id` FOREIGN KEY (`ri_premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction`(`ri_premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_ri_recovery_id` FOREIGN KEY (`ri_recovery_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`(`ri_recovery_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_ri_premium_transaction_id` FOREIGN KEY (`ri_premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction`(`ri_premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_ri_recovery_id` FOREIGN KEY (`ri_recovery_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`(`ri_recovery_id`);

-- ========= billing --> riskexposure (5 constraint(s)) =========
-- Requires: billing schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_risk_inspection_id` FOREIGN KEY (`risk_inspection_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection`(`risk_inspection_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`(`driver_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_property_risk_id` FOREIGN KEY (`property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);

-- ========= billing --> shared (21 constraint(s)) =========
-- Requires: billing schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ADD CONSTRAINT `fk_billing_payment_plan_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ADD CONSTRAINT `fk_billing_payment_method_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);

-- ========= catastrophegeography --> claimfinancials (1 constraint(s)) =========
-- Requires: catastrophegeography schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);

-- ========= catastrophegeography --> coverage (1 constraint(s)) =========
-- Requires: catastrophegeography schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= catastrophegeography --> party (3 constraint(s)) =========
-- Requires: catastrophegeography schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_pml_approved_by_user_party_id` FOREIGN KEY (`pml_approved_by_user_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_pml_run_owner_party_id` FOREIGN KEY (`pml_run_owner_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_approver_party_id` FOREIGN KEY (`approver_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= catastrophegeography --> policy (2 constraint(s)) =========
-- Requires: catastrophegeography schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);

-- ========= catastrophegeography --> reinsurance (4 constraint(s)) =========
-- Requires: catastrophegeography schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_reinsurance_treaty_id` FOREIGN KEY (`reinsurance_treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);

-- ========= catastrophegeography --> riskexposure (4 constraint(s)) =========
-- Requires: catastrophegeography schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ADD CONSTRAINT `fk_catastrophegeography_location_geocode_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ADD CONSTRAINT `fk_catastrophegeography_location_geocode_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);

-- ========= catastrophegeography --> shared (15 constraint(s)) =========
-- Requires: catastrophegeography schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ADD CONSTRAINT `fk_catastrophegeography_catastrophe_event_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event` ADD CONSTRAINT `fk_catastrophegeography_catastrophe_event_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone` ADD CONSTRAINT `fk_catastrophegeography_cat_zone_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ADD CONSTRAINT `fk_catastrophegeography_territory_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= claimfinancials --> billing (1 constraint(s)) =========
-- Requires: claimfinancials schema, billing schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_payment_id` FOREIGN KEY (`payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment`(`payment_id`);

-- ========= claimfinancials --> catastrophegeography (5 constraint(s)) =========
-- Requires: claimfinancials schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);

-- ========= claimfinancials --> claims (29 constraint(s)) =========
-- Requires: claimfinancials schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_litigation_id` FOREIGN KEY (`litigation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`litigation`(`litigation_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_litigation_id` FOREIGN KEY (`litigation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`litigation`(`litigation_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_litigation_id` FOREIGN KEY (`litigation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`litigation`(`litigation_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_litigation_id` FOREIGN KEY (`litigation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`litigation`(`litigation_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_litigation_id` FOREIGN KEY (`litigation_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`litigation`(`litigation_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claimant`(`claimant_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ADD CONSTRAINT `fk_claimfinancials_payee_claimant_id` FOREIGN KEY (`claimant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claimant`(`claimant_id`);

-- ========= claimfinancials --> coverage (3 constraint(s)) =========
-- Requires: claimfinancials schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= claimfinancials --> party (12 constraint(s)) =========
-- Requires: claimfinancials schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_approved_by_party_id` FOREIGN KEY (`approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_claim_party_id` FOREIGN KEY (`claim_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_claim_payee_party_id` FOREIGN KEY (`claim_payee_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_attorney_organization_id` FOREIGN KEY (`attorney_organization_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`organization`(`organization_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_responsible_party_id` FOREIGN KEY (`responsible_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_attorney_organization_id` FOREIGN KEY (`attorney_organization_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`organization`(`organization_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_liable_party_id` FOREIGN KEY (`liable_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_buyer_party_id` FOREIGN KEY (`buyer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_approved_by_party_id` FOREIGN KEY (`approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_reinsurer_party_id` FOREIGN KEY (`reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ADD CONSTRAINT `fk_claimfinancials_payee_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= claimfinancials --> policy (16 constraint(s)) =========
-- Requires: claimfinancials schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);

-- ========= claimfinancials --> reinsurance (18 constraint(s)) =========
-- Requires: claimfinancials schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_ri_claim_cession_id` FOREIGN KEY (`ri_claim_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`(`ri_claim_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_ri_recovery_id` FOREIGN KEY (`ri_recovery_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`(`ri_recovery_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_ri_claim_cession_id` FOREIGN KEY (`ri_claim_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`(`ri_claim_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_ri_recovery_id` FOREIGN KEY (`ri_recovery_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`(`ri_recovery_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_cession_id` FOREIGN KEY (`cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession`(`cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_ri_claim_cession_id` FOREIGN KEY (`ri_claim_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`(`ri_claim_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_ri_claim_cession_id` FOREIGN KEY (`ri_claim_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`(`ri_claim_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_ri_claim_cession_id` FOREIGN KEY (`ri_claim_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`(`ri_claim_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_ri_premium_transaction_id` FOREIGN KEY (`ri_premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction`(`ri_premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_ri_recovery_id` FOREIGN KEY (`ri_recovery_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`(`ri_recovery_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_cession_id` FOREIGN KEY (`cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession`(`cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_ri_claim_cession_id` FOREIGN KEY (`ri_claim_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession`(`ri_claim_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_ri_participant_id` FOREIGN KEY (`ri_participant_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant`(`ri_participant_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_ri_recovery_id` FOREIGN KEY (`ri_recovery_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`(`ri_recovery_id`);

-- ========= claimfinancials --> riskexposure (10 constraint(s)) =========
-- Requires: claimfinancials schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_riskexposure_auto_risk_id` FOREIGN KEY (`riskexposure_auto_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk`(`auto_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_riskexposure_property_risk_id` FOREIGN KEY (`riskexposure_property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_riskexposure_vehicle_id` FOREIGN KEY (`riskexposure_vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= claimfinancials --> shared (19 constraint(s)) =========
-- Requires: claimfinancials schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ADD CONSTRAINT `fk_claimfinancials_accounting_period_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period` ADD CONSTRAINT `fk_claimfinancials_accounting_period_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ADD CONSTRAINT `fk_claimfinancials_payee_preferred_currency_id` FOREIGN KEY (`preferred_currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);

-- ========= claims --> catastrophegeography (17 constraint(s)) =========
-- Requires: claims schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ADD CONSTRAINT `fk_claims_loss_event_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ADD CONSTRAINT `fk_claims_loss_event_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ADD CONSTRAINT `fk_claims_loss_event_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ADD CONSTRAINT `fk_claims_loss_event_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);

-- ========= claims --> coverage (4 constraint(s)) =========
-- Requires: claims schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= claims --> party (9 constraint(s)) =========
-- Requires: claims schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_claim_adjuster_party_id` FOREIGN KEY (`claim_adjuster_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_primary_claimant_party_id` FOREIGN KEY (`primary_claimant_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_mailing_address_id` FOREIGN KEY (`mailing_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ADD CONSTRAINT `fk_claims_adjuster_license_id` FOREIGN KEY (`license_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`license`(`license_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ADD CONSTRAINT `fk_claims_adjuster_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_reporter_party_id` FOREIGN KEY (`reporter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_reporter_party_role_id` FOREIGN KEY (`reporter_party_role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_defense_counsel_party_id` FOREIGN KEY (`defense_counsel_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= claims --> policy (4 constraint(s)) =========
-- Requires: claims schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);

-- ========= claims --> producers (3 constraint(s)) =========
-- Requires: claims schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= claims --> reinsurance (1 constraint(s)) =========
-- Requires: claims schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);

-- ========= claims --> riskexposure (10 constraint(s)) =========
-- Requires: claims schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_risk_score_id` FOREIGN KEY (`risk_score_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score`(`risk_score_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_building_id` FOREIGN KEY (`building_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`building`(`building_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`(`driver_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`(`driver_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);

-- ========= claims --> shared (13 constraint(s)) =========
-- Requires: claims schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ADD CONSTRAINT `fk_claims_loss_event_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ADD CONSTRAINT `fk_claims_loss_event_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ADD CONSTRAINT `fk_claims_claim_status_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_status` ADD CONSTRAINT `fk_claims_claim_status_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);

-- ========= coverage --> billing (1 constraint(s)) =========
-- Requires: coverage schema, billing schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);

-- ========= coverage --> catastrophegeography (10 constraint(s)) =========
-- Requires: coverage schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= coverage --> claims (2 constraint(s)) =========
-- Requires: coverage schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_verified_by_adjuster_id` FOREIGN KEY (`verified_by_adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);

-- ========= coverage --> party (15 constraint(s)) =========
-- Requires: coverage schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_household_id` FOREIGN KEY (`household_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`household`(`household_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_submission_applicant_party_id` FOREIGN KEY (`submission_applicant_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_submission_party_id` FOREIGN KEY (`submission_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_primary_uw_approved_by_party_id` FOREIGN KEY (`primary_uw_approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_tertiary_uw_referred_to_underwriter_party_id` FOREIGN KEY (`tertiary_uw_referred_to_underwriter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_primary_uw_assigned_underwriter_party_id` FOREIGN KEY (`primary_uw_assigned_underwriter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_household_id` FOREIGN KEY (`household_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`household`(`household_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_override_user_party_id` FOREIGN KEY (`override_user_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_primary_bind_applicant_party_id` FOREIGN KEY (`primary_bind_applicant_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_binder_insured_party_id` FOREIGN KEY (`binder_insured_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_binder_party_id` FOREIGN KEY (`binder_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_excluded_party_id` FOREIGN KEY (`excluded_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`condition` ADD CONSTRAINT `fk_coverage_condition_waived_by_party_id` FOREIGN KEY (`waived_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= coverage --> policy (13 constraint(s)) =========
-- Requires: coverage schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_term_id` FOREIGN KEY (`term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_term_id` FOREIGN KEY (`term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_line_id` FOREIGN KEY (`line_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`line`(`line_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`condition` ADD CONSTRAINT `fk_coverage_condition_condition_policy_transaction_id` FOREIGN KEY (`condition_policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`condition` ADD CONSTRAINT `fk_coverage_condition_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);

-- ========= coverage --> producers (12 constraint(s)) =========
-- Requires: coverage schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_servicing_agency_id` FOREIGN KEY (`servicing_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_servicing_producers_producer_id` FOREIGN KEY (`servicing_producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= coverage --> reinsurance (3 constraint(s)) =========
-- Requires: coverage schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_reinsurance_treaty_id` FOREIGN KEY (`reinsurance_treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);

-- ========= coverage --> riskexposure (8 constraint(s)) =========
-- Requires: coverage schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_auto_risk_id` FOREIGN KEY (`auto_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk`(`auto_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_property_risk_id` FOREIGN KEY (`property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_specific_insured_risk_id` FOREIGN KEY (`specific_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= coverage --> shared (15 constraint(s)) =========
-- Requires: coverage schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_loss_date_calendar_id` FOREIGN KEY (`loss_date_calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= party --> catastrophegeography (4 constraint(s)) =========
-- Requires: party schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ADD CONSTRAINT `fk_party_address_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_jurisdiction_geography_id` FOREIGN KEY (`jurisdiction_geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ADD CONSTRAINT `fk_party_license_issuing_geography_id` FOREIGN KEY (`issuing_geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`household` ADD CONSTRAINT `fk_party_household_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= party --> claims (2 constraint(s)) =========
-- Requires: party schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ADD CONSTRAINT `fk_party_role_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);

-- ========= party --> coverage (2 constraint(s)) =========
-- Requires: party schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= party --> policy (5 constraint(s)) =========
-- Requires: party schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ADD CONSTRAINT `fk_party_role_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ADD CONSTRAINT `fk_party_role_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);

-- ========= party --> riskexposure (1 constraint(s)) =========
-- Requires: party schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= party --> shared (4 constraint(s)) =========
-- Requires: party schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`organization` ADD CONSTRAINT `fk_party_organization_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ADD CONSTRAINT `fk_party_license_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= policy --> catastrophegeography (7 constraint(s)) =========
-- Requires: policy schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ADD CONSTRAINT `fk_policy_state_reg_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= policy --> claimfinancials (2 constraint(s)) =========
-- Requires: policy schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);

-- ========= policy --> claims (1 constraint(s)) =========
-- Requires: policy schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_loss_event_id` FOREIGN KEY (`loss_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`loss_event`(`loss_event_id`);

-- ========= policy --> coverage (9 constraint(s)) =========
-- Requires: policy schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ADD CONSTRAINT `fk_policy_form_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ADD CONSTRAINT `fk_policy_state_reg_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_binder_id` FOREIGN KEY (`binder_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`binder`(`binder_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= policy --> party (10 constraint(s)) =========
-- Requires: policy schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_household_id` FOREIGN KEY (`household_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`household`(`household_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ADD CONSTRAINT `fk_policy_policyholder_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ADD CONSTRAINT `fk_policy_policyholder_role_id` FOREIGN KEY (`role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_license_id` FOREIGN KEY (`license_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`license`(`license_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_recipient_party_id` FOREIGN KEY (`recipient_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`document` ADD CONSTRAINT `fk_policy_document_recipient_party_role_id` FOREIGN KEY (`recipient_party_role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);

-- ========= policy --> producers (15 constraint(s)) =========
-- Requires: policy schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_underwriting_authority_id` FOREIGN KEY (`underwriting_authority_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority`(`underwriting_authority_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_producer_appointment_id` FOREIGN KEY (`producer_appointment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment`(`producer_appointment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= policy --> riskexposure (7 constraint(s)) =========
-- Requires: policy schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_building_id` FOREIGN KEY (`building_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`building`(`building_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_property_risk_id` FOREIGN KEY (`property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`interest` ADD CONSTRAINT `fk_policy_interest_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);

-- ========= policy --> shared (11 constraint(s)) =========
-- Requires: policy schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`form` ADD CONSTRAINT `fk_policy_form_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`type` ADD CONSTRAINT `fk_policy_type_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ADD CONSTRAINT `fk_policy_state_reg_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);

-- ========= premium --> billing (3 constraint(s)) =========
-- Requires: premium schema, billing schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_disbursement_id` FOREIGN KEY (`disbursement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`disbursement`(`disbursement_id`);

-- ========= premium --> catastrophegeography (14 constraint(s)) =========
-- Requires: premium schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);

-- ========= premium --> claimfinancials (3 constraint(s)) =========
-- Requires: premium schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);

-- ========= premium --> claims (1 constraint(s)) =========
-- Requires: premium schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);

-- ========= premium --> coverage (4 constraint(s)) =========
-- Requires: premium schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= premium --> party (4 constraint(s)) =========
-- Requires: premium schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_household_id` FOREIGN KEY (`household_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`household`(`household_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_license_id` FOREIGN KEY (`license_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`license`(`license_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_payee_party_id` FOREIGN KEY (`payee_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_filing_organization_id` FOREIGN KEY (`filing_organization_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`organization`(`organization_id`);

-- ========= premium --> policy (20 constraint(s)) =========
-- Requires: premium schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_line_id` FOREIGN KEY (`line_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`line`(`line_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_line_id` FOREIGN KEY (`line_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`line`(`line_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_state_reg_id` FOREIGN KEY (`state_reg_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`state_reg`(`state_reg_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_policy_producer_id` FOREIGN KEY (`policy_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer`(`policy_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_type_id` FOREIGN KEY (`type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`type`(`type_id`);

-- ========= premium --> producers (11 constraint(s)) =========
-- Requires: premium schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_commission_rule_id` FOREIGN KEY (`commission_rule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule`(`commission_rule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_distribution_channel_id` FOREIGN KEY (`distribution_channel_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel`(`distribution_channel_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_producer_appointment_id` FOREIGN KEY (`producer_appointment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment`(`producer_appointment_id`);

-- ========= premium --> riskexposure (8 constraint(s)) =========
-- Requires: premium schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`(`driver_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);

-- ========= premium --> shared (18 constraint(s)) =========
-- Requires: premium schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= producers --> catastrophegeography (8 constraint(s)) =========
-- Requires: producers schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ADD CONSTRAINT `fk_producers_producers_producer_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);

-- ========= producers --> claimfinancials (1 constraint(s)) =========
-- Requires: producers schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);

-- ========= producers --> coverage (1 constraint(s)) =========
-- Requires: producers schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= producers --> party (7 constraint(s)) =========
-- Requires: producers schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ADD CONSTRAINT `fk_producers_producers_producer_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_principal_address_id` FOREIGN KEY (`principal_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ADD CONSTRAINT `fk_producers_producer_license_license_id` FOREIGN KEY (`license_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`license`(`license_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ADD CONSTRAINT `fk_producers_producer_license_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= producers --> policy (2 constraint(s)) =========
-- Requires: producers schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);

-- ========= producers --> premium (1 constraint(s)) =========
-- Requires: producers schema, premium schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);

-- ========= producers --> shared (12 constraint(s)) =========
-- Requires: producers schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ADD CONSTRAINT `fk_producers_distribution_channel_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ADD CONSTRAINT `fk_producers_commission_rule_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ADD CONSTRAINT `fk_producers_commission_rule_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= reinsurance --> catastrophegeography (18 constraint(s)) =========
-- Requires: reinsurance schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);

-- ========= reinsurance --> claimfinancials (4 constraint(s)) =========
-- Requires: reinsurance schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_accounting_period_id` FOREIGN KEY (`accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`accounting_period`(`accounting_period_id`);

-- ========= reinsurance --> claims (5 constraint(s)) =========
-- Requires: reinsurance schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_loss_event_id` FOREIGN KEY (`loss_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`loss_event`(`loss_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);

-- ========= reinsurance --> coverage (4 constraint(s)) =========
-- Requires: reinsurance schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_uw_referral_id` FOREIGN KEY (`uw_referral_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral`(`uw_referral_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_quote_coverage_id` FOREIGN KEY (`quote_coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage`(`quote_coverage_id`);

-- ========= reinsurance --> party (6 constraint(s)) =========
-- Requires: reinsurance schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_cedant_party_id` FOREIGN KEY (`cedant_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_primary_fac_broker_party_id` FOREIGN KEY (`primary_fac_broker_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_tertiary_fac_reinsurer_party_id` FOREIGN KEY (`tertiary_fac_reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ADD CONSTRAINT `fk_reinsurance_reinsurer_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ADD CONSTRAINT `fk_reinsurance_ri_participant_primary_ri_party_id` FOREIGN KEY (`primary_ri_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_reinsurer_party_id` FOREIGN KEY (`reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= reinsurance --> policy (10 constraint(s)) =========
-- Requires: reinsurance schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_line_id` FOREIGN KEY (`line_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`line`(`line_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_line_id` FOREIGN KEY (`line_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`line`(`line_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);

-- ========= reinsurance --> premium (1 constraint(s)) =========
-- Requires: reinsurance schema, premium schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);

-- ========= reinsurance --> producers (5 constraint(s)) =========
-- Requires: reinsurance schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_broker_agency_id` FOREIGN KEY (`broker_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_intermediary_agency_id` FOREIGN KEY (`intermediary_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_fac_broker_agency_id` FOREIGN KEY (`fac_broker_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= reinsurance --> riskexposure (6 constraint(s)) =========
-- Requires: reinsurance schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_auto_risk_id` FOREIGN KEY (`auto_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk`(`auto_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_property_risk_id` FOREIGN KEY (`property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= reinsurance --> shared (22 constraint(s)) =========
-- Requires: reinsurance schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ADD CONSTRAINT `fk_reinsurance_reinsurer_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ADD CONSTRAINT `fk_reinsurance_ri_participant_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`cession` ADD CONSTRAINT `fk_reinsurance_cession_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= riskexposure --> catastrophegeography (9 constraint(s)) =========
-- Requires: riskexposure schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ADD CONSTRAINT `fk_riskexposure_location_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ADD CONSTRAINT `fk_riskexposure_location_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_territory_id` FOREIGN KEY (`territory_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory`(`territory_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_peril_id` FOREIGN KEY (`peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`peril`(`peril_id`);

-- ========= riskexposure --> party (10 constraint(s)) =========
-- Requires: riskexposure schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_household_id` FOREIGN KEY (`household_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`household`(`household_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_property_owner_party_id` FOREIGN KEY (`property_owner_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ADD CONSTRAINT `fk_riskexposure_location_address_id` FOREIGN KEY (`address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_garaging_address_id` FOREIGN KEY (`garaging_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ADD CONSTRAINT `fk_riskexposure_vehicle_garaging_address_id` FOREIGN KEY (`garaging_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ADD CONSTRAINT `fk_riskexposure_vehicle_registered_owner_party_id` FOREIGN KEY (`registered_owner_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ADD CONSTRAINT `fk_riskexposure_driver_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_inspector_party_id` FOREIGN KEY (`inspector_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= riskexposure --> policy (9 constraint(s)) =========
-- Requires: riskexposure schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ADD CONSTRAINT `fk_riskexposure_location_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ADD CONSTRAINT `fk_riskexposure_vehicle_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);

-- ========= riskexposure --> producers (3 constraint(s)) =========
-- Requires: riskexposure schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_writing_producer_producers_producer_id` FOREIGN KEY (`writing_producer_producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_underwriting_authority_id` FOREIGN KEY (`underwriting_authority_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority`(`underwriting_authority_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_ordering_producer_producers_producer_id` FOREIGN KEY (`ordering_producer_producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= riskexposure --> shared (5 constraint(s)) =========
-- Requires: riskexposure schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

