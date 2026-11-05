# Checkpoint — LIVE Cameras research batch 03

Date: 5 November 2026
Branch: production
Supabase: LIVE gxsrajtqzdjvmceqcpgv

- Added three UK-new evidence rows across two existing product configurations: URSA Cine 12K LF Body (Scan £5,999.99, in stock) and URSA Cine 12K LF 100G Body (BPS-TV £13,868.10 VAT-inclusive equivalent, stock unknown; RCB Logic £8,238.00 VAT-inclusive, backorder).
- Separate source observations with differing prices are retained; do not overwrite or merge them.
- All writes returned successfully; no product master/lifecycle/valuation changes.
- LIVE only; TEST untouched. No schema/RLS/application/Edge Function/Worker/tenant/customer/order/payment/Stripe changes.
- Category-count reconciliation is open: main_category=Cameras currently yields 720 active rows, versus earlier research baseline 722. Do not publish a new total coverage percentage until category inclusion is reconciled.
- Detailed evidence and sources: PROJECT-MEMORY/2026-11-05-camera-research-batch-03.md.
