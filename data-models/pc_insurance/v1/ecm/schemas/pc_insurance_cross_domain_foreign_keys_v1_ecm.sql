-- Cross-Domain Foreign Keys for Business: Pc_Insurance | Version: v1_ecm
-- Generated on: 2026-09-20 14:33:32
-- Total cross-domain FK constraints: 795
--
-- EXECUTION ORDER:
--   1. Run ALL domain schema files first (any order).
--   2. Run this file LAST.
--
-- PREREQUISITE DOMAINS: billing, catastrophegeography, claimfinancials, claims, coverage, party, policy, premium, producers, reinsurance, riskexposure, shared, underwriting

-- ========= billing --> catastrophegeography (6 constraint(s)) =========
-- Requires: billing schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ADD CONSTRAINT `fk_billing_payment_plan_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);

-- ========= billing --> claimfinancials (10 constraint(s)) =========
-- Requires: billing schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`returned_payment` ADD CONSTRAINT `fk_billing_returned_payment_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`write_off` ADD CONSTRAINT `fk_billing_write_off_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_claim_payment_id` FOREIGN KEY (`claim_payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment`(`claim_payment_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`billing_transaction` ADD CONSTRAINT `fk_billing_billing_transaction_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`suspense_item` ADD CONSTRAINT `fk_billing_suspense_item_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);

-- ========= billing --> claims (5 constraint(s)) =========
-- Requires: billing schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`escrow_account` ADD CONSTRAINT `fk_billing_escrow_account_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);

-- ========= billing --> coverage (7 constraint(s)) =========
-- Requires: billing schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);

-- ========= billing --> party (19 constraint(s)) =========
-- Requires: billing schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_billing_address_id` FOREIGN KEY (`billing_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_bill_to_party_id` FOREIGN KEY (`bill_to_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_payer_party_id` FOREIGN KEY (`payer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`returned_payment` ADD CONSTRAINT `fk_billing_returned_payment_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_party_document_id` FOREIGN KEY (`party_document_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party_document`(`party_document_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_payee_address_id` FOREIGN KEY (`payee_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_payee_party_id` FOREIGN KEY (`payee_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`billing_transaction` ADD CONSTRAINT `fk_billing_billing_transaction_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`notice` ADD CONSTRAINT `fk_billing_notice_party_document_id` FOREIGN KEY (`party_document_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party_document`(`party_document_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`notice` ADD CONSTRAINT `fk_billing_notice_recipient_contact_id` FOREIGN KEY (`recipient_contact_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`contact`(`contact_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ADD CONSTRAINT `fk_billing_payment_method_billing_address_id` FOREIGN KEY (`billing_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ADD CONSTRAINT `fk_billing_payment_method_consent_record_id` FOREIGN KEY (`consent_record_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`consent_record`(`consent_record_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_method` ADD CONSTRAINT `fk_billing_payment_method_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_bill_to_party_id` FOREIGN KEY (`bill_to_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`escrow_account` ADD CONSTRAINT `fk_billing_escrow_account_escrow_mortgagee_party_id` FOREIGN KEY (`escrow_mortgagee_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`escrow_account` ADD CONSTRAINT `fk_billing_escrow_account_escrow_policyholder_party_id` FOREIGN KEY (`escrow_policyholder_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`escrow_account` ADD CONSTRAINT `fk_billing_escrow_account_party_document_id` FOREIGN KEY (`party_document_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party_document`(`party_document_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`suspense_item` ADD CONSTRAINT `fk_billing_suspense_item_payer_party_id` FOREIGN KEY (`payer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= billing --> policy (27 constraint(s)) =========
-- Requires: billing schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_policyholder_id` FOREIGN KEY (`policyholder_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policyholder`(`policyholder_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_application` ADD CONSTRAINT `fk_billing_payment_application_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_schedule` ADD CONSTRAINT `fk_billing_installment_schedule_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`returned_payment` ADD CONSTRAINT `fk_billing_returned_payment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency` ADD CONSTRAINT `fk_billing_delinquency_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`delinquency_action` ADD CONSTRAINT `fk_billing_delinquency_action_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`write_off` ADD CONSTRAINT `fk_billing_write_off_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`billing_transaction` ADD CONSTRAINT `fk_billing_billing_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`billing_transaction` ADD CONSTRAINT `fk_billing_billing_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`notice` ADD CONSTRAINT `fk_billing_notice_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`notice` ADD CONSTRAINT `fk_billing_notice_policyholder_id` FOREIGN KEY (`policyholder_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policyholder`(`policyholder_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_policyholder_id` FOREIGN KEY (`policyholder_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policyholder`(`policyholder_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`escrow_account` ADD CONSTRAINT `fk_billing_escrow_account_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`suspense_item` ADD CONSTRAINT `fk_billing_suspense_item_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);

-- ========= billing --> premium (5 constraint(s)) =========
-- Requires: billing schema, premium schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_charge_id` FOREIGN KEY (`charge_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`charge`(`charge_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_tax_levy_id` FOREIGN KEY (`tax_levy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy`(`tax_levy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_commission_id` FOREIGN KEY (`commission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`commission`(`commission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);

-- ========= billing --> producers (16 constraint(s)) =========
-- Requires: billing schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`disbursement` ADD CONSTRAINT `fk_billing_disbursement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_commission_rule_id` FOREIGN KEY (`commission_rule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule`(`commission_rule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_commission_schedule_id` FOREIGN KEY (`commission_schedule_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule`(`commission_schedule_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`billing_transaction` ADD CONSTRAINT `fk_billing_billing_transaction_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`billing_transaction` ADD CONSTRAINT `fk_billing_billing_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account_policy` ADD CONSTRAINT `fk_billing_account_policy_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= billing --> reinsurance (2 constraint(s)) =========
-- Requires: billing schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);

-- ========= billing --> riskexposure (1 constraint(s)) =========
-- Requires: billing schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice_item` ADD CONSTRAINT `fk_billing_invoice_item_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= billing --> shared (9 constraint(s)) =========
-- Requires: billing schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`installment_plan` ADD CONSTRAINT `fk_billing_installment_plan_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`account` ADD CONSTRAINT `fk_billing_account_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`invoice` ADD CONSTRAINT `fk_billing_invoice_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment` ADD CONSTRAINT `fk_billing_payment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan` ADD CONSTRAINT `fk_billing_payment_plan_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`billing`.`commission_payable` ADD CONSTRAINT `fk_billing_commission_payable_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= catastrophegeography --> claimfinancials (1 constraint(s)) =========
-- Requires: catastrophegeography schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);

-- ========= catastrophegeography --> coverage (1 constraint(s)) =========
-- Requires: catastrophegeography schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= catastrophegeography --> party (2 constraint(s)) =========
-- Requires: catastrophegeography schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_approved_by_user_party_id` FOREIGN KEY (`approved_by_user_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_run_owner_party_id` FOREIGN KEY (`run_owner_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

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

-- ========= catastrophegeography --> riskexposure (5 constraint(s)) =========
-- Requires: catastrophegeography schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`hazard_score` ADD CONSTRAINT `fk_catastrophegeography_hazard_score_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ADD CONSTRAINT `fk_catastrophegeography_location_geocode_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`location_geocode` ADD CONSTRAINT `fk_catastrophegeography_location_geocode_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);

-- ========= catastrophegeography --> shared (7 constraint(s)) =========
-- Requires: catastrophegeography schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`territory` ADD CONSTRAINT `fk_catastrophegeography_territory_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`exposure_summary` ADD CONSTRAINT `fk_catastrophegeography_exposure_summary_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_event_loss` ADD CONSTRAINT `fk_catastrophegeography_cat_event_loss_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_run` ADD CONSTRAINT `fk_catastrophegeography_pml_run_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`pml_return_period` ADD CONSTRAINT `fk_catastrophegeography_pml_return_period_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`accumulation_limit` ADD CONSTRAINT `fk_catastrophegeography_accumulation_limit_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`policy_cat_exposure` ADD CONSTRAINT `fk_catastrophegeography_policy_cat_exposure_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= claimfinancials --> billing (1 constraint(s)) =========
-- Requires: claimfinancials schema, billing schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_payment_id` FOREIGN KEY (`payment_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment`(`payment_id`);

-- ========= claimfinancials --> catastrophegeography (13 constraint(s)) =========
-- Requires: claimfinancials schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ADD CONSTRAINT `fk_claimfinancials_loss_triangle_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ADD CONSTRAINT `fk_claimfinancials_loss_triangle_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ADD CONSTRAINT `fk_claimfinancials_ibnr_estimate_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ADD CONSTRAINT `fk_claimfinancials_ibnr_estimate_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ADD CONSTRAINT `fk_claimfinancials_lae_allocation_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ADD CONSTRAINT `fk_claimfinancials_lae_allocation_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ADD CONSTRAINT `fk_claimfinancials_payee_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ADD CONSTRAINT `fk_claimfinancials_statutory_reserve_filing_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= claimfinancials --> claims (25 constraint(s)) =========
-- Requires: claimfinancials schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_adjuster_id` FOREIGN KEY (`adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ADD CONSTRAINT `fk_claimfinancials_lae_allocation_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ADD CONSTRAINT `fk_claimfinancials_lae_allocation_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);

-- ========= claimfinancials --> coverage (12 constraint(s)) =========
-- Requires: claimfinancials schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_underwriting_loss_history_id` FOREIGN KEY (`underwriting_loss_history_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history`(`loss_history_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_underwriting_risk_score_id` FOREIGN KEY (`underwriting_risk_score_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score`(`underwriting_risk_score_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_underwriting_loss_history_id` FOREIGN KEY (`underwriting_loss_history_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history`(`loss_history_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ADD CONSTRAINT `fk_claimfinancials_ibnr_estimate_underwriting_risk_score_id` FOREIGN KEY (`underwriting_risk_score_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score`(`underwriting_risk_score_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`lae_allocation` ADD CONSTRAINT `fk_claimfinancials_lae_allocation_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ADD CONSTRAINT `fk_claimfinancials_statutory_reserve_filing_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= claimfinancials --> party (15 constraint(s)) =========
-- Requires: claimfinancials schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_approved_by_party_id` FOREIGN KEY (`approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_payee_party_id` FOREIGN KEY (`payee_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_attorney_organization_id` FOREIGN KEY (`attorney_organization_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`organization`(`organization_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_responsible_party_id` FOREIGN KEY (`responsible_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_attorney_organization_id` FOREIGN KEY (`attorney_organization_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`organization`(`organization_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_liable_party_id` FOREIGN KEY (`liable_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_approved_by_party_id` FOREIGN KEY (`approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ADD CONSTRAINT `fk_claimfinancials_loss_triangle_loss_approved_by_party_id` FOREIGN KEY (`loss_approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ADD CONSTRAINT `fk_claimfinancials_loss_triangle_loss_party_id` FOREIGN KEY (`loss_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ADD CONSTRAINT `fk_claimfinancials_ibnr_estimate_actuary_party_id` FOREIGN KEY (`actuary_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_reinsurer_party_id` FOREIGN KEY (`reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ADD CONSTRAINT `fk_claimfinancials_payee_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`statutory_reserve_filing` ADD CONSTRAINT `fk_claimfinancials_statutory_reserve_filing_actuary_party_id` FOREIGN KEY (`actuary_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= claimfinancials --> policy (1 constraint(s)) =========
-- Requires: claimfinancials schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);

-- ========= claimfinancials --> reinsurance (12 constraint(s)) =========
-- Requires: claimfinancials schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`financial_transaction` ADD CONSTRAINT `fk_claimfinancials_financial_transaction_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reinsurance_recovery` ADD CONSTRAINT `fk_claimfinancials_reinsurance_recovery_ri_recovery_id` FOREIGN KEY (`ri_recovery_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery`(`ri_recovery_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_bordereaux_id` FOREIGN KEY (`bordereaux_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux`(`bordereaux_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_bordereaux_line` ADD CONSTRAINT `fk_claimfinancials_claimfinancials_bordereaux_line_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);

-- ========= claimfinancials --> riskexposure (9 constraint(s)) =========
-- Requires: claimfinancials schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_riskexposure_property_risk_id` FOREIGN KEY (`riskexposure_property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_riskexposure_auto_risk_id` FOREIGN KEY (`riskexposure_auto_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk`(`auto_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_riskexposure_property_risk_id` FOREIGN KEY (`riskexposure_property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_riskexposure_vehicle_id` FOREIGN KEY (`riskexposure_vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_financial_snapshot` ADD CONSTRAINT `fk_claimfinancials_claim_financial_snapshot_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= claimfinancials --> shared (15 constraint(s)) =========
-- Requires: claimfinancials schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`reserve` ADD CONSTRAINT `fk_claimfinancials_reserve_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_payment` ADD CONSTRAINT `fk_claimfinancials_claim_payment_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`recovery` ADD CONSTRAINT `fk_claimfinancials_recovery_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`subrogation` ADD CONSTRAINT `fk_claimfinancials_subrogation_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`salvage` ADD CONSTRAINT `fk_claimfinancials_salvage_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense` ADD CONSTRAINT `fk_claimfinancials_claim_expense_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ADD CONSTRAINT `fk_claimfinancials_loss_triangle_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`loss_triangle` ADD CONSTRAINT `fk_claimfinancials_loss_triangle_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ADD CONSTRAINT `fk_claimfinancials_ibnr_estimate_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`ibnr_estimate` ADD CONSTRAINT `fk_claimfinancials_ibnr_estimate_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claimfinancials`.`payee` ADD CONSTRAINT `fk_claimfinancials_payee_preferred_currency_id` FOREIGN KEY (`preferred_currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);

-- ========= claims --> catastrophegeography (6 constraint(s)) =========
-- Requires: claims schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ADD CONSTRAINT `fk_claims_loss_event_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster_assignment` ADD CONSTRAINT `fk_claims_adjuster_assignment_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);

-- ========= claims --> coverage (8 constraint(s)) =========
-- Requires: claims schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_inspection_order_id` FOREIGN KEY (`inspection_order_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order`(`inspection_order_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_underwriting_risk_score_id` FOREIGN KEY (`underwriting_risk_score_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score`(`underwriting_risk_score_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_quote_coverage_id` FOREIGN KEY (`quote_coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage`(`quote_coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);

-- ========= claims --> party (16 constraint(s)) =========
-- Requires: claims schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_claim_adjuster_party_id` FOREIGN KEY (`claim_adjuster_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_primary_claimant_party_id` FOREIGN KEY (`primary_claimant_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claimant` ADD CONSTRAINT `fk_claims_claimant_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`adjuster` ADD CONSTRAINT `fk_claims_adjuster_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_reporter_party_id` FOREIGN KEY (`reporter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_reporter_party_role_id` FOREIGN KEY (`reporter_party_role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`litigation` ADD CONSTRAINT `fk_claims_litigation_defense_counsel_party_id` FOREIGN KEY (`defense_counsel_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`siu_referral` ADD CONSTRAINT `fk_claims_siu_referral_referring_party_id` FOREIGN KEY (`referring_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_note` ADD CONSTRAINT `fk_claims_claim_note_claim_author_party_id` FOREIGN KEY (`claim_author_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_note` ADD CONSTRAINT `fk_claims_claim_note_claim_last_modified_by_party_id` FOREIGN KEY (`claim_last_modified_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_document` ADD CONSTRAINT `fk_claims_claim_document_source_party_id` FOREIGN KEY (`source_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`repair_estimate` ADD CONSTRAINT `fk_claims_repair_estimate_estimator_party_id` FOREIGN KEY (`estimator_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`salvage_disposition` ADD CONSTRAINT `fk_claims_salvage_disposition_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`salvage_disposition` ADD CONSTRAINT `fk_claims_salvage_disposition_salvage_party_id` FOREIGN KEY (`salvage_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`salvage_disposition` ADD CONSTRAINT `fk_claims_salvage_disposition_salvage_subrogation_target_party_id` FOREIGN KEY (`salvage_subrogation_target_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= claims --> policy (4 constraint(s)) =========
-- Requires: claims schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);

-- ========= claims --> producers (2 constraint(s)) =========
-- Requires: claims schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= claims --> reinsurance (1 constraint(s)) =========
-- Requires: claims schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);

-- ========= claims --> riskexposure (2 constraint(s)) =========
-- Requires: claims schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure` ADD CONSTRAINT `fk_claims_claim_exposure_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`fnol` ADD CONSTRAINT `fk_claims_fnol_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= claims --> shared (5 constraint(s)) =========
-- Requires: claims schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`loss_event` ADD CONSTRAINT `fk_claims_loss_event_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`claim` ADD CONSTRAINT `fk_claims_claim_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`medical_bill` ADD CONSTRAINT `fk_claims_medical_bill_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`repair_estimate` ADD CONSTRAINT `fk_claims_repair_estimate_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`claims`.`salvage_disposition` ADD CONSTRAINT `fk_claims_salvage_disposition_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);

-- ========= coverage --> billing (1 constraint(s)) =========
-- Requires: coverage schema, billing schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ADD CONSTRAINT `fk_coverage_coverage_transaction_billing_transaction_id` FOREIGN KEY (`billing_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`billing_transaction`(`billing_transaction_id`);

-- ========= coverage --> catastrophegeography (21 constraint(s)) =========
-- Requires: coverage schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ADD CONSTRAINT `fk_coverage_risk_appetite_rule_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ADD CONSTRAINT `fk_coverage_risk_appetite_rule_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ADD CONSTRAINT `fk_coverage_eligibility_check_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ADD CONSTRAINT `fk_coverage_clearance_check_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`peril_link` ADD CONSTRAINT `fk_coverage_peril_link_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`type_peril` ADD CONSTRAINT `fk_coverage_type_peril_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);

-- ========= coverage --> claims (2 constraint(s)) =========
-- Requires: coverage schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_verified_by_adjuster_id` FOREIGN KEY (`verified_by_adjuster_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`adjuster`(`adjuster_id`);

-- ========= coverage --> party (41 constraint(s)) =========
-- Requires: coverage schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_submission_applicant_party_id` FOREIGN KEY (`submission_applicant_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_submission_party_id` FOREIGN KEY (`submission_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ADD CONSTRAINT `fk_coverage_submission_party_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_party` ADD CONSTRAINT `fk_coverage_submission_party_role_id` FOREIGN KEY (`role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_uw_approved_by_party_id` FOREIGN KEY (`uw_approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_uw_party_id` FOREIGN KEY (`uw_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision` ADD CONSTRAINT `fk_coverage_uw_decision_uw_referred_to_underwriter_party_id` FOREIGN KEY (`uw_referred_to_underwriter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_uw_assigned_underwriter_party_id` FOREIGN KEY (`uw_assigned_underwriter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_uw_party_id` FOREIGN KEY (`uw_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ADD CONSTRAINT `fk_coverage_eligibility_check_eligibility_override_user_party_id` FOREIGN KEY (`eligibility_override_user_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility_check` ADD CONSTRAINT `fk_coverage_eligibility_check_eligibility_party_id` FOREIGN KEY (`eligibility_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ADD CONSTRAINT `fk_coverage_quote_option_quoted_by_party_id` FOREIGN KEY (`quoted_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_override_user_party_id` FOREIGN KEY (`override_user_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_override_user_party_id` FOREIGN KEY (`override_user_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_uw_approved_by_underwriter_party_id` FOREIGN KEY (`uw_approved_by_underwriter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_uw_party_id` FOREIGN KEY (`uw_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_uw_referred_to_underwriter_party_id` FOREIGN KEY (`uw_referred_to_underwriter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_uw_waived_by_underwriter_party_id` FOREIGN KEY (`uw_waived_by_underwriter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ADD CONSTRAINT `fk_coverage_underwriting_mvr_report_underwriting_driver_party_id` FOREIGN KEY (`underwriting_driver_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ADD CONSTRAINT `fk_coverage_underwriting_mvr_report_underwriting_party_id` FOREIGN KEY (`underwriting_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_inspection_insured_party_id` FOREIGN KEY (`inspection_insured_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_inspection_party_id` FOREIGN KEY (`inspection_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ADD CONSTRAINT `fk_coverage_clearance_check_clearance_override_user_party_id` FOREIGN KEY (`clearance_override_user_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`clearance_check` ADD CONSTRAINT `fk_coverage_clearance_check_clearance_party_id` FOREIGN KEY (`clearance_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ADD CONSTRAINT `fk_coverage_submission_document_submission_received_from_party_id` FOREIGN KEY (`submission_received_from_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ADD CONSTRAINT `fk_coverage_submission_document_submission_uploaded_by_party_id` FOREIGN KEY (`submission_uploaded_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_bind_applicant_party_id` FOREIGN KEY (`bind_applicant_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_bind_party_id` FOREIGN KEY (`bind_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_binder_insured_party_id` FOREIGN KEY (`binder_insured_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_binder_party_id` FOREIGN KEY (`binder_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_changed_by_party_id` FOREIGN KEY (`changed_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_status_history` ADD CONSTRAINT `fk_coverage_submission_status_history_referred_to_underwriter_party_id` FOREIGN KEY (`referred_to_underwriter_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ADD CONSTRAINT `fk_coverage_part_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_coverage_party_id` FOREIGN KEY (`coverage_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_coverage_requested_by_party_id` FOREIGN KEY (`coverage_requested_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ADD CONSTRAINT `fk_coverage_additional_interest_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ADD CONSTRAINT `fk_coverage_coverage_interest_role_id` FOREIGN KEY (`role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);

-- ========= coverage --> policy (29 constraint(s)) =========
-- Requires: coverage schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_bound_policy_id` FOREIGN KEY (`bound_policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_term_id` FOREIGN KEY (`term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`risk_appetite_rule` ADD CONSTRAINT `fk_coverage_risk_appetite_rule_policy_type_id` FOREIGN KEY (`policy_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_type`(`policy_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_term_id` FOREIGN KEY (`term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_term_id` FOREIGN KEY (`term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_term_id` FOREIGN KEY (`term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_bound_policy_id` FOREIGN KEY (`bound_policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_term_id` FOREIGN KEY (`term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_condition` ADD CONSTRAINT `fk_coverage_coverage_condition_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_form` ADD CONSTRAINT `fk_coverage_coverage_form_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ADD CONSTRAINT `fk_coverage_part_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_policy_document_id` FOREIGN KEY (`policy_document_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_document`(`policy_document_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`additional_interest` ADD CONSTRAINT `fk_coverage_additional_interest_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_interest` ADD CONSTRAINT `fk_coverage_coverage_interest_policy_interest_id` FOREIGN KEY (`policy_interest_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_interest`(`policy_interest_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction` ADD CONSTRAINT `fk_coverage_coverage_transaction_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`form_attachment` ADD CONSTRAINT `fk_coverage_form_attachment_policy_form_id` FOREIGN KEY (`policy_form_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_form`(`policy_form_id`);

-- ========= coverage --> producers (16 constraint(s)) =========
-- Requires: coverage schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_ordering_agency_id` FOREIGN KEY (`ordering_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ADD CONSTRAINT `fk_coverage_submission_document_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ADD CONSTRAINT `fk_coverage_submission_document_submitting_agency_id` FOREIGN KEY (`submitting_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`bind_request` ADD CONSTRAINT `fk_coverage_bind_request_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ADD CONSTRAINT `fk_coverage_part_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`producer_coverage_authority` ADD CONSTRAINT `fk_coverage_producer_coverage_authority_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= coverage --> reinsurance (7 constraint(s)) =========
-- Requires: coverage schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_reinsurance_treaty_id` FOREIGN KEY (`reinsurance_treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ADD CONSTRAINT `fk_coverage_coverage_cession_reinsurance_cession_id` FOREIGN KEY (`reinsurance_cession_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession`(`reinsurance_cession_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_cession` ADD CONSTRAINT `fk_coverage_coverage_cession_treaty_layer_id` FOREIGN KEY (`treaty_layer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer`(`treaty_layer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`eligibility` ADD CONSTRAINT `fk_coverage_eligibility_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_quotation` ADD CONSTRAINT `fk_coverage_facultative_quotation_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`facultative_marketing` ADD CONSTRAINT `fk_coverage_facultative_marketing_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);

-- ========= coverage --> riskexposure (11 constraint(s)) =========
-- Requires: coverage schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_risk_score` ADD CONSTRAINT `fk_coverage_underwriting_risk_score_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_condition` ADD CONSTRAINT `fk_coverage_uw_condition_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`underwriting_mvr_report` ADD CONSTRAINT `fk_coverage_underwriting_mvr_report_riskexposure_driver_id` FOREIGN KEY (`riskexposure_driver_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`(`driver_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver`(`driver_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_location_id` FOREIGN KEY (`location_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`location`(`location_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission_document` ADD CONSTRAINT `fk_coverage_submission_document_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`exclusion` ADD CONSTRAINT `fk_coverage_exclusion_specific_insured_risk_id` FOREIGN KEY (`specific_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= coverage --> shared (24 constraint(s)) =========
-- Requires: coverage schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`submission` ADD CONSTRAINT `fk_coverage_submission_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral` ADD CONSTRAINT `fk_coverage_uw_referral_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote` ADD CONSTRAINT `fk_coverage_quote_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_coverage` ADD CONSTRAINT `fk_coverage_quote_coverage_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`quote_option` ADD CONSTRAINT `fk_coverage_quote_option_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_classification_code_id` FOREIGN KEY (`classification_code_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`classification_code`(`classification_code_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet` ADD CONSTRAINT `fk_coverage_rating_worksheet_unit_of_measure_id` FOREIGN KEY (`unit_of_measure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`unit_of_measure`(`unit_of_measure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rating_factor` ADD CONSTRAINT `fk_coverage_rating_factor_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`loss_history` ADD CONSTRAINT `fk_coverage_loss_history_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`inspection_order` ADD CONSTRAINT `fk_coverage_inspection_order_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`binder` ADD CONSTRAINT `fk_coverage_binder_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_exposure_unit_of_measure_id` FOREIGN KEY (`exposure_unit_of_measure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`unit_of_measure`(`unit_of_measure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage` ADD CONSTRAINT `fk_coverage_coverage_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`limit` ADD CONSTRAINT `fk_coverage_limit_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`deductible` ADD CONSTRAINT `fk_coverage_deductible_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`part` ADD CONSTRAINT `fk_coverage_part_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_endorsement` ADD CONSTRAINT `fk_coverage_coverage_endorsement_premium_impact_currency_id` FOREIGN KEY (`premium_impact_currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_classification_code_id` FOREIGN KEY (`classification_code_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`classification_code`(`classification_code_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`rate` ADD CONSTRAINT `fk_coverage_rate_rating_basis_unit_of_measure_id` FOREIGN KEY (`rating_basis_unit_of_measure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`unit_of_measure`(`unit_of_measure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type` ADD CONSTRAINT `fk_coverage_coverage_type_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= party --> catastrophegeography (4 constraint(s)) =========
-- Requires: party schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ADD CONSTRAINT `fk_party_address_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`address` ADD CONSTRAINT `fk_party_address_flood_zone_id` FOREIGN KEY (`flood_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone`(`flood_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_jurisdiction_geography_id` FOREIGN KEY (`jurisdiction_geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ADD CONSTRAINT `fk_party_license_issuing_geography_id` FOREIGN KEY (`issuing_geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= party --> claims (2 constraint(s)) =========
-- Requires: party schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ADD CONSTRAINT `fk_party_role_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);

-- ========= party --> coverage (3 constraint(s)) =========
-- Requires: party schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`kyc_verification` ADD CONSTRAINT `fk_party_kyc_verification_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ADD CONSTRAINT `fk_party_party_document_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= party --> policy (2 constraint(s)) =========
-- Requires: party schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ADD CONSTRAINT `fk_party_role_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);

-- ========= party --> premium (1 constraint(s)) =========
-- Requires: party schema, premium schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ADD CONSTRAINT `fk_party_role_commission_id` FOREIGN KEY (`commission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`commission`(`commission_id`);

-- ========= party --> riskexposure (2 constraint(s)) =========
-- Requires: party schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ADD CONSTRAINT `fk_party_party_document_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`loss_payee` ADD CONSTRAINT `fk_party_loss_payee_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= party --> shared (4 constraint(s)) =========
-- Requires: party schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`role` ADD CONSTRAINT `fk_party_role_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`segment` ADD CONSTRAINT `fk_party_segment_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`party_document` ADD CONSTRAINT `fk_party_party_document_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`party`.`license` ADD CONSTRAINT `fk_party_license_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= policy --> catastrophegeography (2 constraint(s)) =========
-- Requires: policy schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`state_reg` ADD CONSTRAINT `fk_policy_state_reg_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= policy --> claimfinancials (4 constraint(s)) =========
-- Requires: policy schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);

-- ========= policy --> coverage (1 constraint(s)) =========
-- Requires: policy schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`reinsurance_link` ADD CONSTRAINT `fk_policy_reinsurance_link_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= policy --> party (9 constraint(s)) =========
-- Requires: policy schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ADD CONSTRAINT `fk_policy_policyholder_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policyholder` ADD CONSTRAINT `fk_policy_policyholder_role_id` FOREIGN KEY (`role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_interest` ADD CONSTRAINT `fk_policy_policy_interest_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`reinsurance_link` ADD CONSTRAINT `fk_policy_reinsurance_link_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_document` ADD CONSTRAINT `fk_policy_policy_document_recipient_party_id` FOREIGN KEY (`recipient_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_document` ADD CONSTRAINT `fk_policy_policy_document_recipient_party_role_id` FOREIGN KEY (`recipient_party_role_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`role`(`role_id`);

-- ========= policy --> producers (6 constraint(s)) =========
-- Requires: policy schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer` ADD CONSTRAINT `fk_policy_policy_producer_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer_policy` ADD CONSTRAINT `fk_policy_policy_producer_policy_producers_producer_policy_id` FOREIGN KEY (`producers_producer_policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy`(`producers_producer_policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_producer_policy` ADD CONSTRAINT `fk_policy_policy_producer_policy_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= policy --> reinsurance (4 constraint(s)) =========
-- Requires: policy schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`reinsurance_link` ADD CONSTRAINT `fk_policy_reinsurance_link_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`reinsurance_link` ADD CONSTRAINT `fk_policy_reinsurance_link_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`reinsurance_link` ADD CONSTRAINT `fk_policy_reinsurance_link_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`reinsurance_link` ADD CONSTRAINT `fk_policy_reinsurance_link_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);

-- ========= policy --> riskexposure (3 constraint(s)) =========
-- Requires: policy schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_interest` ADD CONSTRAINT `fk_policy_policy_interest_building_id` FOREIGN KEY (`building_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`building`(`building_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_interest` ADD CONSTRAINT `fk_policy_policy_interest_property_risk_id` FOREIGN KEY (`property_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk`(`property_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_interest` ADD CONSTRAINT `fk_policy_policy_interest_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle`(`vehicle_id`);

-- ========= policy --> shared (7 constraint(s)) =========
-- Requires: policy schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy` ADD CONSTRAINT `fk_policy_policy_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`term` ADD CONSTRAINT `fk_policy_term_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction` ADD CONSTRAINT `fk_policy_policy_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`line` ADD CONSTRAINT `fk_policy_line_classification_code_id` FOREIGN KEY (`classification_code_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`classification_code`(`classification_code_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`policy`.`fee` ADD CONSTRAINT `fk_policy_fee_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);

-- ========= premium --> billing (7 constraint(s)) =========
-- Requires: premium schema, billing schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_payment_plan_id` FOREIGN KEY (`payment_plan_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`payment_plan`(`payment_plan_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_disbursement_id` FOREIGN KEY (`disbursement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`disbursement`(`disbursement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_adjustment_invoice_id` FOREIGN KEY (`adjustment_invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_deposit_invoice_id` FOREIGN KEY (`deposit_invoice_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`billing`.`invoice`(`invoice_id`);

-- ========= premium --> catastrophegeography (30 constraint(s)) =========
-- Requires: premium schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_cat_model_version_id` FOREIGN KEY (`cat_model_version_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_model_version`(`cat_model_version_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);

-- ========= premium --> claimfinancials (11 constraint(s)) =========
-- Requires: premium schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_claim_expense_id` FOREIGN KEY (`claim_expense_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claim_expense`(`claim_expense_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);

-- ========= premium --> claims (3 constraint(s)) =========
-- Requires: premium schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);

-- ========= premium --> coverage (18 constraint(s)) =========
-- Requires: premium schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_rating_worksheet_id` FOREIGN KEY (`rating_worksheet_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet`(`rating_worksheet_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_coverage_transaction_id` FOREIGN KEY (`coverage_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_transaction`(`coverage_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_rating_worksheet_id` FOREIGN KEY (`rating_worksheet_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet`(`rating_worksheet_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_rating_worksheet_id` FOREIGN KEY (`rating_worksheet_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`rating_worksheet`(`rating_worksheet_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);

-- ========= premium --> party (5 constraint(s)) =========
-- Requires: premium schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_license_id` FOREIGN KEY (`license_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`license`(`license_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_filing_organization_id` FOREIGN KEY (`filing_organization_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`organization`(`organization_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_auditor_individual_id` FOREIGN KEY (`auditor_individual_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`individual`(`individual_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= premium --> policy (30 constraint(s)) =========
-- Requires: premium schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_original_fee_id` FOREIGN KEY (`original_fee_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`fee`(`fee_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_policy_transaction_id` FOREIGN KEY (`policy_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy_transaction`(`policy_transaction_id`);

-- ========= premium --> producers (7 constraint(s)) =========
-- Requires: premium schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table_authorization` ADD CONSTRAINT `fk_premium_rate_table_authorization_underwriting_authority_id` FOREIGN KEY (`underwriting_authority_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority`(`underwriting_authority_id`);

-- ========= premium --> reinsurance (4 constraint(s)) =========
-- Requires: premium schema, reinsurance schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_fac_agreement_id` FOREIGN KEY (`fac_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement`(`fac_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_reinsurer_id` FOREIGN KEY (`reinsurer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer`(`reinsurer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_ri_agreement_id` FOREIGN KEY (`ri_agreement_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement`(`ri_agreement_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_treaty_id` FOREIGN KEY (`treaty_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty`(`treaty_id`);

-- ========= premium --> riskexposure (4 constraint(s)) =========
-- Requires: premium schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_insured_risk_id` FOREIGN KEY (`insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= premium --> shared (42 constraint(s)) =========
-- Requires: premium schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction` ADD CONSTRAINT `fk_premium_premium_transaction_unit_of_measure_id` FOREIGN KEY (`unit_of_measure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`unit_of_measure`(`unit_of_measure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`charge` ADD CONSTRAINT `fk_premium_charge_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`tax_levy` ADD CONSTRAINT `fk_premium_tax_levy_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`policy_fee` ADD CONSTRAINT `fk_premium_policy_fee_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`commission` ADD CONSTRAINT `fk_premium_commission_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`earned_premium_schedule` ADD CONSTRAINT `fk_premium_earned_premium_schedule_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`premium_endorsement` ADD CONSTRAINT `fk_premium_premium_endorsement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_classification_code_id` FOREIGN KEY (`classification_code_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`classification_code`(`classification_code_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rate_table` ADD CONSTRAINT `fk_premium_rate_table_unit_of_measure_id` FOREIGN KEY (`unit_of_measure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`unit_of_measure`(`unit_of_measure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`audit` ADD CONSTRAINT `fk_premium_audit_unit_of_measure_id` FOREIGN KEY (`unit_of_measure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`unit_of_measure`(`unit_of_measure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`bearing_coverage` ADD CONSTRAINT `fk_premium_bearing_coverage_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`ceded_premium` ADD CONSTRAINT `fk_premium_ceded_premium_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`minimum_earned_premium` ADD CONSTRAINT `fk_premium_minimum_earned_premium_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`retrospective_adjustment` ADD CONSTRAINT `fk_premium_retrospective_adjustment_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`rule` ADD CONSTRAINT `fk_premium_rule_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_calendar_id` FOREIGN KEY (`calendar_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`calendar`(`calendar_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`premium`.`deposit_premium` ADD CONSTRAINT `fk_premium_deposit_premium_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= producers --> catastrophegeography (5 constraint(s)) =========
-- Requires: producers schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);

-- ========= producers --> claimfinancials (3 constraint(s)) =========
-- Requires: producers schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ADD CONSTRAINT `fk_producers_commission_payment_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);

-- ========= producers --> coverage (3 constraint(s)) =========
-- Requires: producers schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ADD CONSTRAINT `fk_producers_commission_rule_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_coverage_appointment` ADD CONSTRAINT `fk_producers_agency_coverage_appointment_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);

-- ========= producers --> party (9 constraint(s)) =========
-- Requires: producers schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer` ADD CONSTRAINT `fk_producers_producers_producer_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency` ADD CONSTRAINT `fk_producers_agency_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_license` ADD CONSTRAINT `fk_producers_producer_license_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`agency_producer` ADD CONSTRAINT `fk_producers_agency_producer_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_payment` ADD CONSTRAINT `fk_producers_commission_payment_payee_party_id` FOREIGN KEY (`payee_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_compliance_event` ADD CONSTRAINT `fk_producers_producer_compliance_event_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_broker_approved_by_party_id` FOREIGN KEY (`broker_approved_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_broker_requested_by_party_id` FOREIGN KEY (`broker_requested_by_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= producers --> policy (5 constraint(s)) =========
-- Requires: producers schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ADD CONSTRAINT `fk_producers_producers_producer_policy_current_policy_id` FOREIGN KEY (`current_policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ADD CONSTRAINT `fk_producers_producers_producer_policy_prior_producer_policy_id` FOREIGN KEY (`prior_producer_policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);

-- ========= producers --> premium (3 constraint(s)) =========
-- Requires: producers schema, premium schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ADD CONSTRAINT `fk_producers_contingent_commission_premium_accounting_period_id` FOREIGN KEY (`premium_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period`(`premium_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ADD CONSTRAINT `fk_producers_producer_performance_premium_accounting_period_id` FOREIGN KEY (`premium_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_accounting_period`(`premium_accounting_period_id`);

-- ========= producers --> shared (12 constraint(s)) =========
-- Requires: producers schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_appointment` ADD CONSTRAINT `fk_producers_producer_appointment_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`distribution_channel` ADD CONSTRAINT `fk_producers_distribution_channel_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_schedule` ADD CONSTRAINT `fk_producers_commission_schedule_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_rule` ADD CONSTRAINT `fk_producers_commission_rule_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_transaction` ADD CONSTRAINT `fk_producers_commission_transaction_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`commission_statement` ADD CONSTRAINT `fk_producers_commission_statement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`contingent_commission` ADD CONSTRAINT `fk_producers_contingent_commission_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer_policy` ADD CONSTRAINT `fk_producers_producers_producer_policy_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`underwriting_authority` ADD CONSTRAINT `fk_producers_underwriting_authority_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`producer_performance` ADD CONSTRAINT `fk_producers_producer_performance_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`errors_omissions_policy` ADD CONSTRAINT `fk_producers_errors_omissions_policy_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`producers`.`broker_of_record_change` ADD CONSTRAINT `fk_producers_broker_of_record_change_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= reinsurance --> catastrophegeography (14 constraint(s)) =========
-- Requires: reinsurance schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_catastrophe_event_id` FOREIGN KEY (`catastrophe_event_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophe_event`(`catastrophe_event_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer_peril_term` ADD CONSTRAINT `fk_reinsurance_treaty_layer_peril_term_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`agreement_peril_coverage` ADD CONSTRAINT `fk_reinsurance_agreement_peril_coverage_catastrophegeography_peril_id` FOREIGN KEY (`catastrophegeography_peril_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`catastrophegeography_peril`(`catastrophegeography_peril_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_zone_terms` ADD CONSTRAINT `fk_reinsurance_treaty_zone_terms_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);

-- ========= reinsurance --> claimfinancials (9 constraint(s)) =========
-- Requires: reinsurance schema, claimfinancials schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ADD CONSTRAINT `fk_reinsurance_ri_collateral_claimfinancials_accounting_period_id` FOREIGN KEY (`claimfinancials_accounting_period_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claimfinancials`.`claimfinancials_accounting_period`(`claimfinancials_accounting_period_id`);

-- ========= reinsurance --> claims (4 constraint(s)) =========
-- Requires: reinsurance schema, claims schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_claim_exposure_id` FOREIGN KEY (`claim_exposure_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim_exposure`(`claim_exposure_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_claim_id` FOREIGN KEY (`claim_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`claims`.`claim`(`claim_id`);

-- ========= reinsurance --> coverage (6 constraint(s)) =========
-- Requires: reinsurance schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`quote`(`quote_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`submission`(`submission_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_uw_decision_id` FOREIGN KEY (`uw_decision_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_decision`(`uw_decision_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_uw_referral_id` FOREIGN KEY (`uw_referral_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`uw_referral`(`uw_referral_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= reinsurance --> party (11 constraint(s)) =========
-- Requires: reinsurance schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_fac_broker_party_id` FOREIGN KEY (`fac_broker_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_fac_cedant_party_id` FOREIGN KEY (`fac_cedant_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_fac_reinsurer_party_id` FOREIGN KEY (`fac_reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ADD CONSTRAINT `fk_reinsurance_reinsurer_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ADD CONSTRAINT `fk_reinsurance_ri_participant_ri_party_id` FOREIGN KEY (`ri_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_participant` ADD CONSTRAINT `fk_reinsurance_ri_participant_ri_reinsurer_party_id` FOREIGN KEY (`ri_reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_reinsurer_party_id` FOREIGN KEY (`reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_bordereaux_broker_party_id` FOREIGN KEY (`bordereaux_broker_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_bordereaux_party_id` FOREIGN KEY (`bordereaux_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_reinsurer_party_id` FOREIGN KEY (`reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_reinsurer_party_id` FOREIGN KEY (`reinsurer_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= reinsurance --> policy (5 constraint(s)) =========
-- Requires: reinsurance schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);

-- ========= reinsurance --> premium (3 constraint(s)) =========
-- Requires: reinsurance schema, premium schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_premium_transaction_id` FOREIGN KEY (`premium_transaction_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`premium`.`premium_transaction`(`premium_transaction_id`);

-- ========= reinsurance --> producers (4 constraint(s)) =========
-- Requires: reinsurance schema, producers schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_broker_agency_id` FOREIGN KEY (`broker_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_intermediary_agency_id` FOREIGN KEY (`intermediary_agency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`agency`(`agency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_producers_producer_id` FOREIGN KEY (`producers_producer_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`producers`.`producers_producer`(`producers_producer_id`);

-- ========= reinsurance --> riskexposure (3 constraint(s)) =========
-- Requires: reinsurance schema, riskexposure schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_riskexposure_insured_risk_id` FOREIGN KEY (`riskexposure_insured_risk_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk`(`insured_risk_id`);

-- ========= reinsurance --> shared (19 constraint(s)) =========
-- Requires: reinsurance schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_agreement` ADD CONSTRAINT `fk_reinsurance_ri_agreement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty` ADD CONSTRAINT `fk_reinsurance_treaty_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`treaty_layer` ADD CONSTRAINT `fk_reinsurance_treaty_layer_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`fac_agreement` ADD CONSTRAINT `fk_reinsurance_fac_agreement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurer` ADD CONSTRAINT `fk_reinsurance_reinsurer_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_currency_id` FOREIGN KEY (`currency_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`currency`(`currency_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_cession` ADD CONSTRAINT `fk_reinsurance_reinsurance_cession_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_premium_transaction` ADD CONSTRAINT `fk_reinsurance_ri_premium_transaction_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_claim_cession` ADD CONSTRAINT `fk_reinsurance_ri_claim_cession_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_recovery` ADD CONSTRAINT `fk_reinsurance_ri_recovery_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`bordereaux` ADD CONSTRAINT `fk_reinsurance_bordereaux_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`reinsurance_bordereaux_line` ADD CONSTRAINT `fk_reinsurance_reinsurance_bordereaux_line_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_reinstatement` ADD CONSTRAINT `fk_reinsurance_ri_reinstatement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_settlement` ADD CONSTRAINT `fk_reinsurance_ri_settlement_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`ri_collateral` ADD CONSTRAINT `fk_reinsurance_ri_collateral_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`reinsurance`.`schedule_f_entry` ADD CONSTRAINT `fk_reinsurance_schedule_f_entry_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= riskexposure --> catastrophegeography (4 constraint(s)) =========
-- Requires: riskexposure schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ADD CONSTRAINT `fk_riskexposure_location_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`building` ADD CONSTRAINT `fk_riskexposure_building_flood_zone_id` FOREIGN KEY (`flood_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`flood_zone`(`flood_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ADD CONSTRAINT `fk_riskexposure_exposure_schedule_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= riskexposure --> coverage (1 constraint(s)) =========
-- Requires: riskexposure schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ADD CONSTRAINT `fk_riskexposure_risk_improvement_coverage_id` FOREIGN KEY (`coverage_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage`(`coverage_id`);

-- ========= riskexposure --> party (8 constraint(s)) =========
-- Requires: riskexposure schema, party schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_property_owner_party_id` FOREIGN KEY (`property_owner_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_garaging_address_id` FOREIGN KEY (`garaging_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ADD CONSTRAINT `fk_riskexposure_vehicle_garaging_address_id` FOREIGN KEY (`garaging_address_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`address`(`address_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ADD CONSTRAINT `fk_riskexposure_vehicle_registered_owner_party_id` FOREIGN KEY (`registered_owner_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver` ADD CONSTRAINT `fk_riskexposure_driver_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_party_id` FOREIGN KEY (`party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_inspector_party_id` FOREIGN KEY (`inspector_party_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`party`.`party`(`party_id`);

-- ========= riskexposure --> policy (14 constraint(s)) =========
-- Requires: riskexposure schema, policy schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`location` ADD CONSTRAINT `fk_riskexposure_location_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`auto_risk` ADD CONSTRAINT `fk_riskexposure_auto_risk_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`vehicle` ADD CONSTRAINT `fk_riskexposure_vehicle_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`driver_violation` ADD CONSTRAINT `fk_riskexposure_driver_violation_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_score` ADD CONSTRAINT `fk_riskexposure_risk_score_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_inspection` ADD CONSTRAINT `fk_riskexposure_risk_inspection_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_improvement` ADD CONSTRAINT `fk_riskexposure_risk_improvement_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ADD CONSTRAINT `fk_riskexposure_exposure_schedule_policy_id` FOREIGN KEY (`policy_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`policy`(`policy_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`exposure_schedule` ADD CONSTRAINT `fk_riskexposure_exposure_schedule_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`risk_characteristic` ADD CONSTRAINT `fk_riskexposure_risk_characteristic_policy_term_id` FOREIGN KEY (`policy_term_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`policy`.`term`(`term_id`);

-- ========= riskexposure --> shared (2 constraint(s)) =========
-- Requires: riskexposure schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`insured_risk` ADD CONSTRAINT `fk_riskexposure_insured_risk_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`riskexposure`.`property_risk` ADD CONSTRAINT `fk_riskexposure_property_risk_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

-- ========= underwriting --> catastrophegeography (2 constraint(s)) =========
-- Requires: underwriting schema, catastrophegeography schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ADD CONSTRAINT `fk_underwriting_uw_guideline_cat_zone_id` FOREIGN KEY (`cat_zone_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`cat_zone`(`cat_zone_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ADD CONSTRAINT `fk_underwriting_uw_guideline_geography_id` FOREIGN KEY (`geography_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`catastrophegeography`.`geography`(`geography_id`);

-- ========= underwriting --> coverage (1 constraint(s)) =========
-- Requires: underwriting schema, coverage schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ADD CONSTRAINT `fk_underwriting_uw_guideline_coverage_type_id` FOREIGN KEY (`coverage_type_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`coverage`.`coverage_type`(`coverage_type_id`);

-- ========= underwriting --> shared (2 constraint(s)) =========
-- Requires: underwriting schema, shared schema
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ADD CONSTRAINT `fk_underwriting_uw_guideline_classification_code_id` FOREIGN KEY (`classification_code_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`classification_code`(`classification_code_id`);
ALTER TABLE `vibe_pc_insurance_blog_v499`.`underwriting`.`uw_guideline` ADD CONSTRAINT `fk_underwriting_uw_guideline_line_of_business_id` FOREIGN KEY (`line_of_business_id`) REFERENCES `vibe_pc_insurance_blog_v499`.`shared`.`line_of_business`(`line_of_business_id`);

